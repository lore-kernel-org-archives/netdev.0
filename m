From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/13] unix_diag: Basic module skeleton
Date: Thu, 15 Dec 2011 16:44:35 +0400
Message-ID: <4EE9EBB3.4030504@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4891 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441Ab1LOMol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:44:41 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes basic module_init/_exit functionality, dump/get_exact stubs
and declares the basic API structures for request and response.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |   24 +++++++++++++++++++
 net/unix/diag.c           |   57 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 81 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/unix_diag.h
 create mode 100644 net/unix/diag.c

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
new file mode 100644
index 0000000..445184a
--- /dev/null
+++ b/include/linux/unix_diag.h
@@ -0,0 +1,24 @@
+#ifndef __UNIX_DIAG_H__
+#define __UNIX_DIAG_H__
+
+struct unix_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u16	pad;
+	__u32	udiag_states;
+	__u32	udiag_ino;
+	__u32	udiag_show;
+	__u32	udiag_cookie[2];
+};
+
+struct unix_diag_msg {
+	__u8	udiag_family;
+	__u8	udiag_type;
+	__u8	udiag_state;
+	__u8	pad;
+
+	__u32	udiag_ino;
+	__u32	udiag_cookie[2];
+};
+
+#endif
diff --git a/net/unix/diag.c b/net/unix/diag.c
new file mode 100644
index 0000000..6be16c0
--- /dev/null
+++ b/net/unix/diag.c
@@ -0,0 +1,57 @@
+#include <linux/types.h>
+#include <linux/spinlock.h>
+#include <linux/sock_diag.h>
+#include <linux/unix_diag.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+#include <net/af_unix.h>
+#include <net/tcp_states.h>
+
+#define UNIX_DIAG_PUT(skb, attrtype, attrlen) \
+	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
+
+static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return 0;
+}
+
+static int unix_diag_get_exact(struct sk_buff *in_skb,
+			       const struct nlmsghdr *nlh,
+			       struct unix_diag_req *req)
+{
+	return -EAFNOSUPPORT;
+}
+
+static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
+{
+	int hdrlen = sizeof(struct unix_diag_req);
+
+	if (nlmsg_len(h) < hdrlen)
+		return -EINVAL;
+
+	if (h->nlmsg_flags & NLM_F_DUMP)
+		return netlink_dump_start(sock_diag_nlsk, skb, h,
+					  unix_diag_dump, NULL, 0);
+	else
+		return unix_diag_get_exact(skb, h, (struct unix_diag_req *)NLMSG_DATA(h));
+}
+
+static struct sock_diag_handler unix_diag_handler = {
+	.family = AF_UNIX,
+	.dump = unix_diag_handler_dump,
+};
+
+static int __init unix_diag_init(void)
+{
+	return sock_diag_register(&unix_diag_handler);
+}
+
+static void __exit unix_diag_exit(void)
+{
+	sock_diag_unregister(&unix_diag_handler);
+}
+
+module_init(unix_diag_init);
+module_exit(unix_diag_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 1 /* AF_LOCAL */);
-- 
1.5.5.6
