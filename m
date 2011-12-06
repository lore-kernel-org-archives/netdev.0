From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/11] sock_diag: Initial skeleton
Date: Tue, 06 Dec 2011 21:58:03 +0400
Message-ID: <4EDE57AB.7090206@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17727 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128Ab1LFR6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:58:09 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving the SOCK_DIAG_BY_FAMILY message we have to find the
handler for provided family and pass the nl message to it.

This patch describes an infrastructure to work with such nandlers
and implements stubs for AF_INET(6) ones.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/sock_diag.h |   23 ++++++++++
 net/ipv4/inet_diag.c      |  102 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 123 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/sock_diag.h

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
new file mode 100644
index 0000000..ba4933b
--- /dev/null
+++ b/include/linux/sock_diag.h
@@ -0,0 +1,23 @@
+#ifndef __SOCK_DIAG_H__
+#define __SOCK_DIAG_H__
+struct sk_buff;
+struct nlmsghdr;
+
+struct sock_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+};
+
+struct sock_diag_handler {
+	__u8 family;
+	int (*dump)(struct sk_buff *skb, struct nlmsghdr *nlh);
+};
+
+int sock_diag_register(struct sock_diag_handler *h);
+void sock_diag_unregister(struct sock_diag_handler *h);
+
+void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
+void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
+
+extern struct sock *sock_diag_nlsk;
+#endif
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index cf8be3e..ccbe8ea 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -33,6 +33,7 @@
 #include <linux/stddef.h>
 
 #include <linux/inet_diag.h>
+#include <linux/sock_diag.h>
 
 static const struct inet_diag_handler **inet_diag_table;
 
@@ -887,9 +888,91 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return inet_diag_get_exact(skb, nlh);
 }
 
+static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
+{
+	int hdrlen = sizeof(struct inet_diag_req);
+
+	if (nlmsg_len(h) < hdrlen)
+		return -EINVAL;
+
+	if (h->nlmsg_flags & NLM_F_DUMP) {
+		return -EAFNOSUPPORT;
+	}
+
+	return -EAFNOSUPPORT;
+}
+
+static struct sock_diag_handler inet_diag_handler = {
+	.family = AF_INET,
+	.dump = inet_diag_handler_dump,
+};
+
+static struct sock_diag_handler inet6_diag_handler = {
+	.family = AF_INET6,
+	.dump = inet_diag_handler_dump,
+};
+
+static struct sock_diag_handler *sock_diag_handlers[AF_MAX];
+static DEFINE_MUTEX(sock_diag_table_mutex);
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
+
+static inline struct sock_diag_handler *sock_diag_lock_handler(int family)
+{
+	mutex_lock(&sock_diag_table_mutex);
+	return sock_diag_handlers[family];
+}
+
+static inline void sock_diag_unlock_handler(struct sock_diag_handler *h)
+{
+	mutex_unlock(&sock_diag_table_mutex);
+}
+
 static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	return -EOPNOTSUPP;
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
 }
 
 static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
@@ -961,9 +1044,22 @@ static int __init inet_diag_init(void)
 					sock_diag_rcv, NULL, THIS_MODULE);
 	if (sdiagnl == NULL)
 		goto out_free_table;
-	err = 0;
+
+	err = sock_diag_register(&inet_diag_handler);
+	if (err)
+		goto out_free_nl;
+
+	err = sock_diag_register(&inet6_diag_handler);
+	if (err)
+		goto out_free_inet;
+
 out:
 	return err;
+
+out_free_inet:
+	sock_diag_unregister(&inet_diag_handler);
+out_free_nl:
+	netlink_kernel_release(sdiagnl);
 out_free_table:
 	kfree(inet_diag_table);
 	goto out;
@@ -971,6 +1067,8 @@ out_free_table:
 
 static void __exit inet_diag_exit(void)
 {
+	sock_diag_unregister(&inet6_diag_handler);
+	sock_diag_unregister(&inet_diag_handler);
 	netlink_kernel_release(sdiagnl);
 	kfree(inet_diag_table);
 }
-- 
1.5.5.6
