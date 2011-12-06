From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 11/11] sock_diag: Move the sock_ code to net/core/
Date: Tue, 06 Dec 2011 21:59:52 +0400
Message-ID: <4EDE5818.2040502@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17396 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab1LFR76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:59:58 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the sock_ code from inet_diag.c to generic sock_diag.c
file and provides necessary request_module-s calls and a pointer on
inet_diag_compat dumping routine.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/core/Makefile    |    3 +-
 net/core/sock_diag.c |  150 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/inet_diag.c |  105 ++---------------------------------
 3 files changed, 158 insertions(+), 100 deletions(-)
 create mode 100644 net/core/sock_diag.c

diff --git a/net/core/Makefile b/net/core/Makefile
index c4ecc86..674641b 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -8,7 +8,8 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
-			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
+			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
+			sock_diag.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
new file mode 100644
index 0000000..6367ae8
--- /dev/null
+++ b/net/core/sock_diag.c
@@ -0,0 +1,150 @@
+#include <linux/mutex.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+#include <net/net_namespace.h>
+#include <linux/module.h>
+
+#include <linux/inet_diag.h>
+#include <linux/sock_diag.h>
+
+static struct sock_diag_handler *sock_diag_handlers[AF_MAX];
+static int (*inet_rcv_compat)(struct sk_buff *skb, struct nlmsghdr *nlh);
+static DEFINE_MUTEX(sock_diag_table_mutex);
+
+void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh))
+{
+	mutex_lock(&sock_diag_table_mutex);
+	inet_rcv_compat = fn;
+	mutex_unlock(&sock_diag_table_mutex);
+}
+EXPORT_SYMBOL_GPL(sock_diag_register_inet_compat);
+
+void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh))
+{
+	mutex_lock(&sock_diag_table_mutex);
+	inet_rcv_compat = NULL;
+	mutex_unlock(&sock_diag_table_mutex);
+}
+EXPORT_SYMBOL_GPL(sock_diag_unregister_inet_compat);
+
+int sock_diag_register(struct sock_diag_handler *hndl)
+{
+	int err = 0;
+
+	if (hndl->family > AF_MAX)
+		return -EINVAL;
+
+	mutex_lock(&sock_diag_table_mutex);
+	if (sock_diag_handlers[hndl->family])
+		err = -EBUSY;
+	else
+		sock_diag_handlers[hndl->family] = hndl;
+	mutex_unlock(&sock_diag_table_mutex);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(sock_diag_register);
+
+void sock_diag_unregister(struct sock_diag_handler *hnld)
+{
+	int family = hnld->family;
+
+	if (family > AF_MAX)
+		return;
+
+	mutex_lock(&sock_diag_table_mutex);
+	BUG_ON(sock_diag_handlers[family] != hnld);
+	sock_diag_handlers[family] = NULL;
+	mutex_unlock(&sock_diag_table_mutex);
+}
+EXPORT_SYMBOL_GPL(sock_diag_unregister);
+
+static inline struct sock_diag_handler *sock_diag_lock_handler(int family)
+{
+	if (sock_diag_handlers[family] == NULL)
+		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+				NETLINK_SOCK_DIAG, IPPROTO_IP);
+
+	mutex_lock(&sock_diag_table_mutex);
+	return sock_diag_handlers[family];
+}
+
+static inline void sock_diag_unlock_handler(struct sock_diag_handler *h)
+{
+	mutex_unlock(&sock_diag_table_mutex);
+}
+
+static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	int err;
+	struct sock_diag_req *req = NLMSG_DATA(nlh);
+	struct sock_diag_handler *hndl;
+
+	if (nlmsg_len(nlh) < sizeof(*req))
+		return -EINVAL;
+
+	hndl = sock_diag_lock_handler(req->sdiag_family);
+	if (hndl == NULL)
+		err = -ENOENT;
+	else
+		err = hndl->dump(skb, nlh);
+	sock_diag_unlock_handler(hndl);
+
+	return err;
+}
+
+static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	int ret;
+
+	switch (nlh->nlmsg_type) {
+	case TCPDIAG_GETSOCK:
+	case DCCPDIAG_GETSOCK:
+		if (inet_rcv_compat == NULL)
+			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+					NETLINK_SOCK_DIAG, IPPROTO_IP);
+
+		mutex_lock(&sock_diag_table_mutex);
+		if (inet_rcv_compat != NULL)
+			ret = inet_rcv_compat(skb, nlh);
+		else
+			ret = -EOPNOTSUPP;
+		mutex_unlock(&sock_diag_table_mutex);
+
+		return ret;
+	case SOCK_DIAG_BY_FAMILY:
+		return __sock_diag_rcv_msg(skb, nlh);
+	default:
+		return -EINVAL;
+	}
+}
+
+static DEFINE_MUTEX(sock_diag_mutex);
+
+static void sock_diag_rcv(struct sk_buff *skb)
+{
+	mutex_lock(&sock_diag_mutex);
+	netlink_rcv_skb(skb, &sock_diag_rcv_msg);
+	mutex_unlock(&sock_diag_mutex);
+}
+
+struct sock *sock_diag_nlsk;
+EXPORT_SYMBOL_GPL(sock_diag_nlsk);
+
+static int __init sock_diag_init(void)
+{
+	sock_diag_nlsk = netlink_kernel_create(&init_net, NETLINK_SOCK_DIAG, 0,
+					sock_diag_rcv, NULL, THIS_MODULE);
+	return sock_diag_nlsk == NULL ? -ENOMEM : 0;
+}
+
+static void __exit sock_diag_exit(void)
+{
+	netlink_kernel_release(sock_diag_nlsk);
+}
+
+module_init(sock_diag_init);
+module_exit(sock_diag_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_SOCK_DIAG);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index d5ca77c..b56b7ba 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -46,8 +46,6 @@ struct inet_diag_entry {
 	u16 userlocks;
 };
 
-static struct sock *sdiagnl;
-
 #define INET_DIAG_PUT(skb, attrtype, attrlen) \
 	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
 
@@ -314,7 +312,7 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 		kfree_skb(rep);
 		goto out;
 	}
-	err = netlink_unicast(sdiagnl, rep, NETLINK_CB(in_skb).pid,
+	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
 			      MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
@@ -931,7 +929,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 				return -EINVAL;
 		}
 
-		return netlink_dump_start(sdiagnl, skb, nlh,
+		return netlink_dump_start(sock_diag_nlsk, skb, nlh,
 					  inet_diag_dump_compat, NULL, 0);
 	}
 
@@ -956,7 +954,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 				return -EINVAL;
 		}
 
-		return netlink_dump_start(sdiagnl, skb, h,
+		return netlink_dump_start(sock_diag_nlsk, skb, h,
 					  inet_diag_dump, NULL, 0);
 	}
 
@@ -973,91 +971,6 @@ static struct sock_diag_handler inet6_diag_handler = {
 	.dump = inet_diag_handler_dump,
 };
 
-static struct sock_diag_handler *sock_diag_handlers[AF_MAX];
-static DEFINE_MUTEX(sock_diag_table_mutex);
-
-int sock_diag_register(struct sock_diag_handler *hndl)
-{
-	int err = 0;
-
-	if (hndl->family > AF_MAX)
-		return -EINVAL;
-
-	mutex_lock(&sock_diag_table_mutex);
-	if (sock_diag_handlers[hndl->family])
-		err = -EBUSY;
-	else
-		sock_diag_handlers[hndl->family] = hndl;
-	mutex_unlock(&sock_diag_table_mutex);
-
-	return err;
-}
-
-void sock_diag_unregister(struct sock_diag_handler *hnld)
-{
-	int family = hnld->family;
-
-	if (family > AF_MAX)
-		return;
-
-	mutex_lock(&sock_diag_table_mutex);
-	BUG_ON(sock_diag_handlers[family] != hnld);
-	sock_diag_handlers[family] = NULL;
-	mutex_unlock(&sock_diag_table_mutex);
-}
-
-static inline struct sock_diag_handler *sock_diag_lock_handler(int family)
-{
-	mutex_lock(&sock_diag_table_mutex);
-	return sock_diag_handlers[family];
-}
-
-static inline void sock_diag_unlock_handler(struct sock_diag_handler *h)
-{
-	mutex_unlock(&sock_diag_table_mutex);
-}
-
-static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
-{
-	int err;
-	struct sock_diag_req *req = NLMSG_DATA(nlh);
-	struct sock_diag_handler *hndl;
-
-	if (nlmsg_len(nlh) < sizeof(*req))
-		return -EINVAL;
-
-	hndl = sock_diag_lock_handler(req->sdiag_family);
-	if (hndl == NULL)
-		err = -ENOENT;
-	else
-		err = hndl->dump(skb, nlh);
-	sock_diag_unlock_handler(hndl);
-
-	return err;
-}
-
-static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
-{
-	switch (nlh->nlmsg_type) {
-	case TCPDIAG_GETSOCK:
-	case DCCPDIAG_GETSOCK:
-		return inet_diag_rcv_msg_compat(skb, nlh);
-	case SOCK_DIAG_BY_FAMILY:
-		return __sock_diag_rcv_msg(skb, nlh);
-	default:
-		return -EINVAL;
-	}
-}
-
-static DEFINE_MUTEX(sock_diag_mutex);
-
-static void sock_diag_rcv(struct sk_buff *skb)
-{
-	mutex_lock(&sock_diag_mutex);
-	netlink_rcv_skb(skb, &sock_diag_rcv_msg);
-	mutex_unlock(&sock_diag_mutex);
-}
-
 int inet_diag_register(const struct inet_diag_handler *h)
 {
 	const __u16 type = h->idiag_type;
@@ -1101,11 +1014,6 @@ static int __init inet_diag_init(void)
 	if (!inet_diag_table)
 		goto out;
 
-	sdiagnl = netlink_kernel_create(&init_net, NETLINK_SOCK_DIAG, 0,
-					sock_diag_rcv, NULL, THIS_MODULE);
-	if (sdiagnl == NULL)
-		goto out_free_table;
-
 	err = sock_diag_register(&inet_diag_handler);
 	if (err)
 		goto out_free_nl;
@@ -1114,14 +1022,13 @@ static int __init inet_diag_init(void)
 	if (err)
 		goto out_free_inet;
 
+	sock_diag_register_inet_compat(inet_diag_rcv_msg_compat);
 out:
 	return err;
 
 out_free_inet:
 	sock_diag_unregister(&inet_diag_handler);
 out_free_nl:
-	netlink_kernel_release(sdiagnl);
-out_free_table:
 	kfree(inet_diag_table);
 	goto out;
 }
@@ -1130,11 +1037,11 @@ static void __exit inet_diag_exit(void)
 {
 	sock_diag_unregister(&inet6_diag_handler);
 	sock_diag_unregister(&inet_diag_handler);
-	netlink_kernel_release(sdiagnl);
+	sock_diag_unregister_inet_compat(inet_diag_rcv_msg_compat);
 	kfree(inet_diag_table);
 }
 
 module_init(inet_diag_init);
 module_exit(inet_diag_exit);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_SOCK_DIAG);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 0);
-- 
1.5.5.6
