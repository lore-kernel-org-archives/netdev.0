From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v2 1/4] net: diag: split inet_diag_dump_one_icsk into two
Date: Wed, 18 Nov 2015 13:41:00 +0900
Message-ID: <1447821663-31246-1-git-send-email-lorenzo@google.com>
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com, tom@herbertland.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35131 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbbKRElP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 23:41:15 -0500
Received: by pacej9 with SMTP id ej9so31557831pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 20:41:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, inet_diag_dump_one_icsk finds a socket and then dumps
its information to userspace. Split it into a part that finds the
socket and a part that dumps the information.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/inet_diag.h |  5 +++++
 net/ipv4/inet_diag.c      | 42 +++++++++++++++++++++++++++---------------
 2 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 0e707f0..e7032f04 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -3,6 +3,7 @@
 
 #include <uapi/linux/inet_diag.h>
 
+struct net;
 struct sock;
 struct inet_hashinfo;
 struct nlattr;
@@ -41,6 +42,10 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 			    struct sk_buff *in_skb, const struct nlmsghdr *nlh,
 			    const struct inet_diag_req_v2 *req);
 
+struct sock *inet_diag_find_one_icsk(struct net *net,
+				     struct inet_hashinfo *hashinfo,
+				     const struct inet_diag_req_v2 *req);
+
 int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
 
 extern int  inet_diag_register(const struct inet_diag_handler *handler);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index ab9f8a6..cfabb8f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -350,17 +350,12 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 				  nlmsg_flags, unlh);
 }
 
-int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
-			    struct sk_buff *in_skb,
-			    const struct nlmsghdr *nlh,
-			    const struct inet_diag_req_v2 *req)
+struct sock *inet_diag_find_one_icsk(struct net *net,
+				     struct inet_hashinfo *hashinfo,
+				     const struct inet_diag_req_v2 *req)
 {
-	struct net *net = sock_net(in_skb->sk);
-	struct sk_buff *rep;
 	struct sock *sk;
-	int err;
 
-	err = -EINVAL;
 	if (req->sdiag_family == AF_INET)
 		sk = inet_lookup(net, hashinfo, req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
@@ -375,15 +370,33 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 				  req->id.idiag_if);
 #endif
 	else
-		goto out_nosk;
+		return ERR_PTR(-EINVAL);
 
-	err = -ENOENT;
 	if (!sk)
-		goto out_nosk;
+		return ERR_PTR(-ENOENT);
 
-	err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
-	if (err)
-		goto out;
+	if (sock_diag_check_cookie(sk, req->id.idiag_cookie)) {
+		sock_gen_put(sk);
+		return ERR_PTR(-ENOENT);
+	}
+
+	return sk;
+}
+EXPORT_SYMBOL_GPL(inet_diag_find_one_icsk);
+
+int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
+			    struct sk_buff *in_skb,
+			    const struct nlmsghdr *nlh,
+			    const struct inet_diag_req_v2 *req)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct sk_buff *rep;
+	struct sock *sk;
+	int err;
+
+	sk = inet_diag_find_one_icsk(net, hashinfo, req);
+	if (IS_ERR(sk))
+		return PTR_ERR(sk);
 
 	rep = nlmsg_new(inet_sk_attr_size(), GFP_KERNEL);
 	if (!rep) {
@@ -409,7 +422,6 @@ out:
 	if (sk)
 		sock_gen_put(sk);
 
-out_nosk:
 	return err;
 }
 EXPORT_SYMBOL_GPL(inet_diag_dump_one_icsk);
-- 
2.6.0.rc2.230.g3dd15c0
