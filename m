From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH net-next] net: sock_diag_handler structs can be const
Date: Wed, 25 Apr 2012 12:21:07 +0800
Message-ID: <4F977BB3.5040201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, davidshan <davidshan@tencent.com>
To: David Miller <davem@davemloft.net>, xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61949 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab2DYEUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 00:20:20 -0400
Received: by pbbro12 with SMTP id ro12so937968pbb.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 21:20:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <davidshan@tencent.com>

read only, so change it to const.

Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 include/linux/sock_diag.h |    4 ++--
 net/core/sock_diag.c      |   12 ++++++------
 net/ipv4/inet_diag.c      |    4 ++--
 net/unix/diag.c           |    2 +-
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 251729a..db4bae7 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -32,8 +32,8 @@ struct sock_diag_handler {
 	int (*dump)(struct sk_buff *skb, struct nlmsghdr *nlh);
 };
 
-int sock_diag_register(struct sock_diag_handler *h);
-void sock_diag_unregister(struct sock_diag_handler *h);
+int sock_diag_register(const struct sock_diag_handler *h);
+void sock_diag_unregister(const struct sock_diag_handler *h);
 
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
 void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index b9868e1..5fd1467 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -10,7 +10,7 @@
 #include <linux/inet_diag.h>
 #include <linux/sock_diag.h>
 
-static struct sock_diag_handler *sock_diag_handlers[AF_MAX];
+static const struct sock_diag_handler *sock_diag_handlers[AF_MAX];
 static int (*inet_rcv_compat)(struct sk_buff *skb, struct nlmsghdr *nlh);
 static DEFINE_MUTEX(sock_diag_table_mutex);
 
@@ -70,7 +70,7 @@ void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlms
 }
 EXPORT_SYMBOL_GPL(sock_diag_unregister_inet_compat);
 
-int sock_diag_register(struct sock_diag_handler *hndl)
+int sock_diag_register(const struct sock_diag_handler *hndl)
 {
 	int err = 0;
 
@@ -88,7 +88,7 @@ int sock_diag_register(struct sock_diag_handler *hndl)
 }
 EXPORT_SYMBOL_GPL(sock_diag_register);
 
-void sock_diag_unregister(struct sock_diag_handler *hnld)
+void sock_diag_unregister(const struct sock_diag_handler *hnld)
 {
 	int family = hnld->family;
 
@@ -102,7 +102,7 @@ void sock_diag_unregister(struct sock_diag_handler *hnld)
 }
 EXPORT_SYMBOL_GPL(sock_diag_unregister);
 
-static inline struct sock_diag_handler *sock_diag_lock_handler(int family)
+static const inline struct sock_diag_handler *sock_diag_lock_handler(int family)
 {
 	if (sock_diag_handlers[family] == NULL)
 		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
@@ -112,7 +112,7 @@ static inline struct sock_diag_handler *sock_diag_lock_handler(int family)
 	return sock_diag_handlers[family];
 }
 
-static inline void sock_diag_unlock_handler(struct sock_diag_handler *h)
+static inline void sock_diag_unlock_handler(const struct sock_diag_handler *h)
 {
 	mutex_unlock(&sock_diag_table_mutex);
 }
@@ -121,7 +121,7 @@ static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err;
 	struct sock_diag_req *req = NLMSG_DATA(nlh);
-	struct sock_diag_handler *hndl;
+	const struct sock_diag_handler *hndl;
 
 	if (nlmsg_len(nlh) < sizeof(*req))
 		return -EINVAL;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 8f8db72..46d1e71 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -999,12 +999,12 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 	return inet_diag_get_exact(skb, h, (struct inet_diag_req_v2 *)NLMSG_DATA(h));
 }
 
-static struct sock_diag_handler inet_diag_handler = {
+static const struct sock_diag_handler inet_diag_handler = {
 	.family = AF_INET,
 	.dump = inet_diag_handler_dump,
 };
 
-static struct sock_diag_handler inet6_diag_handler = {
+static const struct sock_diag_handler inet6_diag_handler = {
 	.family = AF_INET6,
 	.dump = inet_diag_handler_dump,
 };
diff --git a/net/unix/diag.c b/net/unix/diag.c
index f0486ae..47d3002 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -310,7 +310,7 @@ static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		return unix_diag_get_exact(skb, h, (struct unix_diag_req *)NLMSG_DATA(h));
 }
 
-static struct sock_diag_handler unix_diag_handler = {
+static const struct sock_diag_handler unix_diag_handler = {
 	.family = AF_UNIX,
 	.dump = unix_diag_handler_dump,
 };
-- 
1.7.1
