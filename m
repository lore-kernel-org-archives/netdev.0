From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/4] packet: Diag core and basic socket info dumping
Date: Mon, 13 Aug 2012 19:53:28 +0400
Message-ID: <502922F8.1010908@parallels.com>
References: <5029219C.20305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4399 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782Ab2HMPxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 11:53:32 -0400
In-Reply-To: <5029219C.20305@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The diag module can be built independently from the af_packet.ko one,
just like it's done in unix sockets.

The core dumping message carries the info available at socket creation
time, i.e. family, type and protocol (in the same byte order as shown in
the proc file).

The socket inode number and cookie is reserved for future per-socket info
retrieving. The per-protocol filtering is also reserved for future by
requiring the sdiag_protocol to be zero.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/Kbuild        |    1 +
 include/linux/packet_diag.h |   24 ++++++++++
 net/packet/Kconfig          |    8 +++
 net/packet/Makefile         |    2 +
 net/packet/diag.c           |  104 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 139 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/packet_diag.h
 create mode 100644 net/packet/diag.c

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index d9a7544..d823d60 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -195,6 +195,7 @@ header-y += in_route.h
 header-y += sock_diag.h
 header-y += inet_diag.h
 header-y += unix_diag.h
+header-y += packet_diag.h
 header-y += inotify.h
 header-y += input.h
 header-y += ioctl.h
diff --git a/include/linux/packet_diag.h b/include/linux/packet_diag.h
new file mode 100644
index 0000000..fa19300
--- /dev/null
+++ b/include/linux/packet_diag.h
@@ -0,0 +1,24 @@
+#ifndef __PACKET_DIAG_H__
+#define __PACKET_DIAG_H__
+
+#include <linux/types.h>
+
+struct packet_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u16	pad;
+	__u32	pdiag_ino;
+	__u32	pdiag_show;
+	__u32	pdiag_cookie[2];
+};
+
+struct packet_diag_msg {
+	__u8	pdiag_family;
+	__u8	pdiag_type;
+	__u16	pdiag_num;
+
+	__u32	pdiag_ino;
+	__u32	pdiag_cookie[2];
+};
+
+#endif
diff --git a/net/packet/Kconfig b/net/packet/Kconfig
index 0060e3b..cc55b35 100644
--- a/net/packet/Kconfig
+++ b/net/packet/Kconfig
@@ -14,3 +14,11 @@ config PACKET
 	  be called af_packet.
 
 	  If unsure, say Y.
+
+config PACKET_DIAG
+	tristate "Packet: sockets monitoring interface"
+	depends on PACKET
+	default n
+	---help---
+	  Support for PF_PACKET sockets monitoring interface used by the ss tool.
+	  If unsure, say Y.
diff --git a/net/packet/Makefile b/net/packet/Makefile
index 81183ea..9df6134 100644
--- a/net/packet/Makefile
+++ b/net/packet/Makefile
@@ -3,3 +3,5 @@
 #
 
 obj-$(CONFIG_PACKET) += af_packet.o
+obj-$(CONFIG_PACKET_DIAG) += af_packet_diag.o
+af_packet_diag-y += diag.o
diff --git a/net/packet/diag.c b/net/packet/diag.c
new file mode 100644
index 0000000..ff2f7f5
--- /dev/null
+++ b/net/packet/diag.c
@@ -0,0 +1,104 @@
+#include <linux/module.h>
+#include <linux/sock_diag.h>
+#include <linux/net.h>
+#include <linux/packet_diag.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include "internal.h"
+
+static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag_req *req,
+		u32 pid, u32 seq, u32 flags, int sk_ino)
+{
+	struct nlmsghdr *nlh;
+	struct packet_diag_msg *rp;
+	const struct packet_sock *po = pkt_sk(sk);
+
+	nlh = nlmsg_put(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rp), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	rp = nlmsg_data(nlh);
+	rp->pdiag_family = AF_PACKET;
+	rp->pdiag_type = sk->sk_type;
+	rp->pdiag_num = ntohs(po->num);
+	rp->pdiag_ino = sk_ino;
+	sock_diag_save_cookie(sk, rp->pdiag_cookie);
+
+	return nlmsg_end(skb, nlh);
+}
+
+static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int num = 0, s_num = cb->args[0];
+	struct packet_diag_req *req;
+	struct net *net;
+	struct sock *sk;
+	struct hlist_node *node;
+
+	net = sock_net(skb->sk);
+	req = nlmsg_data(cb->nlh);
+
+	rcu_read_lock();
+	sk_for_each_rcu(sk, node, &net->packet.sklist) {
+		if (!net_eq(sock_net(sk), net))
+			continue;
+		if (num < s_num)
+			goto next;
+
+		if (sk_diag_fill(sk, skb, req, NETLINK_CB(cb->skb).pid,
+					cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					sock_i_ino(sk)) < 0)
+			goto done;
+next:
+		num++;
+	}
+done:
+	rcu_read_unlock();
+	cb->args[0] = num;
+
+	return skb->len;
+}
+
+static int packet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
+{
+	int hdrlen = sizeof(struct packet_diag_req);
+	struct net *net = sock_net(skb->sk);
+	struct packet_diag_req *req;
+
+	if (nlmsg_len(h) < hdrlen)
+		return -EINVAL;
+
+	req = nlmsg_data(h);
+	/* Make it possible to support protocol filtering later */
+	if (req->sdiag_protocol)
+		return -EINVAL;
+
+	if (h->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = packet_diag_dump,
+		};
+		return netlink_dump_start(net->diag_nlsk, skb, h, &c);
+	} else
+		return -EOPNOTSUPP;
+}
+
+static const struct sock_diag_handler packet_diag_handler = {
+	.family = AF_PACKET,
+	.dump = packet_diag_handler_dump,
+};
+
+static int __init packet_diag_init(void)
+{
+	return sock_diag_register(&packet_diag_handler);
+}
+
+static void __exit packet_diag_exit(void)
+{
+	sock_diag_unregister(&packet_diag_handler);
+}
+
+module_init(packet_diag_init);
+module_exit(packet_diag_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 17 /* AF_PACKET */);
-- 
1.7.6.5
