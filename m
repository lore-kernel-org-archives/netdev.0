From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 3/3] netlink: Diag core and basic socket info dumping (v2)
Date: Thu, 21 Mar 2013 20:33:48 +0400
Message-ID: <1363883628-7249-4-git-send-email-avagin@openvz.org>
References: <1363883628-7249-1-git-send-email-avagin@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, Thomas Graf <tgraf@suug.ch>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363883628-7249-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netlink_diag can be built as a module, just like it's done in
unix sockets.

The core dumping message carries the basic info about netlink sockets:
family, type and protocol, portis, dst_group, dst_portid, state.

Groups can be received as an optional parameter NETLINK_DIAG_GROUPS.

Netlink sockets cab be filtered by protocols.

The socket inode number and cookie is reserved for future per-socket info
retrieving. The per-protocol filtering is also reserved for future by
requiring the sdiag_protocol to be zero.

The file /proc/net/netlink doesn't provide enough information for
dumping netlink sockets. It doesn't provide dst_group, dst_portid,
groups above 32.

v2: fix NETLINK_DIAG_MAX. Now it's equal to the last constant.

Acked-by: Pavel Emelyanov <xemul@parallels.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/uapi/linux/netlink_diag.h |  42 +++++++++
 net/Kconfig                       |   1 +
 net/netlink/Kconfig               |  10 ++
 net/netlink/Makefile              |   3 +
 net/netlink/diag.c                | 188 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 244 insertions(+)
 create mode 100644 include/uapi/linux/netlink_diag.h
 create mode 100644 net/netlink/Kconfig
 create mode 100644 net/netlink/diag.c

diff --git a/include/uapi/linux/netlink_diag.h b/include/uapi/linux/netlink_diag.h
new file mode 100644
index 0000000..88009a3
--- /dev/null
+++ b/include/uapi/linux/netlink_diag.h
@@ -0,0 +1,42 @@
+#ifndef __NETLINK_DIAG_H__
+#define __NETLINK_DIAG_H__
+
+#include <linux/types.h>
+
+struct netlink_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u16	pad;
+	__u32	ndiag_ino;
+	__u32	ndiag_show;
+	__u32	ndiag_cookie[2];
+};
+
+struct netlink_diag_msg {
+	__u8	ndiag_family;
+	__u8	ndiag_type;
+	__u8	ndiag_protocol;
+	__u8	ndiag_state;
+
+	__u32	ndiag_portid;
+	__u32	ndiag_dst_portid;
+	__u32	ndiag_dst_group;
+	__u32	ndiag_ino;
+	__u32	ndiag_cookie[2];
+};
+
+enum {
+	NETLINK_DIAG_MEMINFO,
+	NETLINK_DIAG_GROUPS,
+
+	__NETLINK_DIAG_MAX,
+};
+
+#define NETLINK_DIAG_MAX (__NETLINK_DIAG_MAX - 1)
+
+#define NDIAG_PROTO_ALL		((__u8) ~0)
+
+#define NDIAG_SHOW_MEMINFO	0x00000001 /* show memory info of a socket */
+#define NDIAG_SHOW_GROUPS	0x00000002 /* show groups of a netlink socket */
+
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index 6f676ab..2ddc904 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -217,6 +217,7 @@ source "net/dns_resolver/Kconfig"
 source "net/batman-adv/Kconfig"
 source "net/openvswitch/Kconfig"
 source "net/vmw_vsock/Kconfig"
+source "net/netlink/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/netlink/Kconfig b/net/netlink/Kconfig
new file mode 100644
index 0000000..5d6e8c0
--- /dev/null
+++ b/net/netlink/Kconfig
@@ -0,0 +1,10 @@
+#
+# Netlink Sockets
+#
+
+config NETLINK_DIAG
+	tristate "NETLINK: socket monitoring interface"
+	default n
+	---help---
+	  Support for NETLINK socket monitoring interface used by the ss tool.
+	  If unsure, say Y.
diff --git a/net/netlink/Makefile b/net/netlink/Makefile
index bdd6ddf..e837917 100644
--- a/net/netlink/Makefile
+++ b/net/netlink/Makefile
@@ -3,3 +3,6 @@
 #
 
 obj-y  				:= af_netlink.o genetlink.o
+
+obj-$(CONFIG_NETLINK_DIAG)	+= netlink_diag.o
+netlink_diag-y			:= diag.o
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
new file mode 100644
index 0000000..5ffb1d1
--- /dev/null
+++ b/net/netlink/diag.c
@@ -0,0 +1,188 @@
+#include <linux/module.h>
+
+#include <net/sock.h>
+#include <linux/netlink.h>
+#include <linux/sock_diag.h>
+#include <linux/netlink_diag.h>
+
+#include "af_netlink.h"
+
+static int sk_diag_dump_groups(struct sock *sk, struct sk_buff *nlskb)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	if (nlk->groups == NULL)
+		return 0;
+
+	return nla_put(nlskb, NETLINK_DIAG_GROUPS, NLGRPSZ(nlk->ngroups),
+		       nlk->groups);
+}
+
+static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
+			struct netlink_diag_req *req,
+			u32 portid, u32 seq, u32 flags, int sk_ino)
+{
+	struct nlmsghdr *nlh;
+	struct netlink_diag_msg *rep;
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	nlh = nlmsg_put(skb, portid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep),
+			flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	rep = nlmsg_data(nlh);
+	rep->ndiag_family	= AF_NETLINK;
+	rep->ndiag_type		= sk->sk_type;
+	rep->ndiag_protocol	= sk->sk_protocol;
+	rep->ndiag_state	= sk->sk_state;
+
+	rep->ndiag_ino		= sk_ino;
+	rep->ndiag_portid	= nlk->portid;
+	rep->ndiag_dst_portid	= nlk->dst_portid;
+	rep->ndiag_dst_group	= nlk->dst_group;
+	sock_diag_save_cookie(sk, rep->ndiag_cookie);
+
+	if ((req->ndiag_show & NDIAG_SHOW_GROUPS) &&
+	    sk_diag_dump_groups(sk, skb))
+		goto out_nlmsg_trim;
+
+	if ((req->ndiag_show & NDIAG_SHOW_MEMINFO) &&
+	    sock_diag_put_meminfo(sk, skb, NETLINK_DIAG_MEMINFO))
+		goto out_nlmsg_trim;
+
+	return nlmsg_end(skb, nlh);
+
+out_nlmsg_trim:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
+				int protocol, int s_num)
+{
+	struct netlink_table *tbl = &nl_table[protocol];
+	struct nl_portid_hash *hash = &tbl->hash;
+	struct net *net = sock_net(skb->sk);
+	struct netlink_diag_req *req;
+	struct sock *sk;
+	int ret = 0, num = 0, i;
+
+	req = nlmsg_data(cb->nlh);
+
+	for (i = 0; i <= hash->mask; i++) {
+		sk_for_each(sk, &hash->table[i]) {
+			if (!net_eq(sock_net(sk), net))
+				continue;
+			if (num < s_num) {
+				num++;
+				continue;
+			}
+
+			if (sk_diag_fill(sk, skb, req,
+					 NETLINK_CB(cb->skb).portid,
+					 cb->nlh->nlmsg_seq,
+					 NLM_F_MULTI,
+					 sock_i_ino(sk)) < 0) {
+				ret = 1;
+				goto done;
+			}
+
+			num++;
+		}
+	}
+
+	sk_for_each_bound(sk, &tbl->mc_list) {
+		if (sk_hashed(sk))
+			continue;
+		if (!net_eq(sock_net(sk), net))
+			continue;
+		if (num < s_num) {
+			num++;
+			continue;
+		}
+
+		if (sk_diag_fill(sk, skb, req,
+				 NETLINK_CB(cb->skb).portid,
+				 cb->nlh->nlmsg_seq,
+				 NLM_F_MULTI,
+				 sock_i_ino(sk)) < 0) {
+			ret = 1;
+			goto done;
+		}
+		num++;
+	}
+done:
+	cb->args[0] = num;
+	cb->args[1] = protocol;
+
+	return ret;
+}
+
+static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct netlink_diag_req *req;
+	int s_num = cb->args[0];
+
+	req = nlmsg_data(cb->nlh);
+
+	read_lock(&nl_table_lock);
+
+	if (req->sdiag_protocol == NDIAG_PROTO_ALL) {
+		int i;
+
+		for (i = cb->args[1]; i < MAX_LINKS; i++) {
+			if (__netlink_diag_dump(skb, cb, i, s_num))
+				break;
+			s_num = 0;
+		}
+	} else {
+		if (req->sdiag_protocol >= MAX_LINKS) {
+			read_unlock(&nl_table_lock);
+			return -ENOENT;
+		}
+
+		__netlink_diag_dump(skb, cb, req->sdiag_protocol, s_num);
+	}
+
+	read_unlock(&nl_table_lock);
+
+	return skb->len;
+}
+
+static int netlink_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
+{
+	int hdrlen = sizeof(struct netlink_diag_req);
+	struct net *net = sock_net(skb->sk);
+
+	if (nlmsg_len(h) < hdrlen)
+		return -EINVAL;
+
+	if (h->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = netlink_diag_dump,
+		};
+		return netlink_dump_start(net->diag_nlsk, skb, h, &c);
+	} else
+		return -EOPNOTSUPP;
+}
+
+static const struct sock_diag_handler netlink_diag_handler = {
+	.family = AF_NETLINK,
+	.dump = netlink_diag_handler_dump,
+};
+
+static int __init netlink_diag_init(void)
+{
+	return sock_diag_register(&netlink_diag_handler);
+}
+
+static void __exit netlink_diag_exit(void)
+{
+	sock_diag_unregister(&netlink_diag_handler);
+}
+
+module_init(netlink_diag_init);
+module_exit(netlink_diag_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 16 /* AF_NETLINK */);
-- 
1.8.1.4
