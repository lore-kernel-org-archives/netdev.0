From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/3] inet_diag: add const to inet_diag_req_v2
Date: Tue, 10 Mar 2015 07:15:54 -0700
Message-ID: <1425996954-24693-4-git-send-email-edumazet@google.com>
References: <1425996954-24693-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33672 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232AbbCJOQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 10:16:42 -0400
Received: by yhoa41 with SMTP id a41so294232yho.0
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 07:16:42 -0700 (PDT)
In-Reply-To: <1425996954-24693-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diag dumpers should not modify the request.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/inet_diag.h | 43 ++++++++++++++++++++++---------------------
 net/dccp/diag.c           |  7 ++++---
 net/ipv4/inet_diag.c      | 22 +++++++++++-----------
 net/ipv4/tcp_diag.c       |  4 ++--
 net/ipv4/udp_diag.c       | 22 +++++++++++++---------
 5 files changed, 52 insertions(+), 46 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 46da02410a09..ac48b10c9395 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -11,33 +11,34 @@ struct sk_buff;
 struct netlink_callback;
 
 struct inet_diag_handler {
-	void			(*dump)(struct sk_buff *skb,
-					struct netlink_callback *cb,
-					struct inet_diag_req_v2 *r,
-					struct nlattr *bc);
-
-	int			(*dump_one)(struct sk_buff *in_skb,
-					const struct nlmsghdr *nlh,
-					struct inet_diag_req_v2 *req);
-
-	void			(*idiag_get_info)(struct sock *sk,
-						  struct inet_diag_msg *r,
-						  void *info);
-	__u16                   idiag_type;
+	void		(*dump)(struct sk_buff *skb,
+				struct netlink_callback *cb,
+				const struct inet_diag_req_v2 *r,
+				struct nlattr *bc);
+
+	int		(*dump_one)(struct sk_buff *in_skb,
+				    const struct nlmsghdr *nlh,
+				    const struct inet_diag_req_v2 *req);
+
+	void		(*idiag_get_info)(struct sock *sk,
+					  struct inet_diag_msg *r,
+					  void *info);
+	__u16		idiag_type;
 };
 
 struct inet_connection_sock;
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
-			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
-			      struct user_namespace *user_ns,
-			      u32 pid, u32 seq, u16 nlmsg_flags,
-			      const struct nlmsghdr *unlh);
+		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
+		      struct user_namespace *user_ns,
+		      u32 pid, u32 seq, u16 nlmsg_flags,
+		      const struct nlmsghdr *unlh);
 void inet_diag_dump_icsk(struct inet_hashinfo *h, struct sk_buff *skb,
-		struct netlink_callback *cb, struct inet_diag_req_v2 *r,
-		struct nlattr *bc);
+			 struct netlink_callback *cb,
+			 const struct inet_diag_req_v2 *r,
+			 struct nlattr *bc);
 int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
-		struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req_v2 *req);
+			    struct sk_buff *in_skb, const struct nlmsghdr *nlh,
+			    const struct inet_diag_req_v2 *req);
 
 int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
 
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 028fc43aacbd..5a45f8de5d99 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -49,13 +49,14 @@ static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 }
 
 static void dccp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req_v2 *r, struct nlattr *bc)
+			   const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	inet_diag_dump_icsk(&dccp_hashinfo, skb, cb, r, bc);
 }
 
-static int dccp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req_v2 *req)
+static int dccp_diag_dump_one(struct sk_buff *in_skb,
+			      const struct nlmsghdr *nlh,
+			      const struct inet_diag_req_v2 *req)
 {
 	return inet_diag_dump_one_icsk(&dccp_hashinfo, in_skb, nlh, req);
 }
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index cd261f6e3abb..ac3bfb458afd 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -71,7 +71,7 @@ static void inet_diag_unlock_handler(const struct inet_diag_handler *handler)
 }
 
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
-		      struct sk_buff *skb, struct inet_diag_req_v2 *req,
+		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
 		      struct user_namespace *user_ns,
 		      u32 portid, u32 seq, u16 nlmsg_flags,
 		      const struct nlmsghdr *unlh)
@@ -212,7 +212,7 @@ EXPORT_SYMBOL_GPL(inet_sk_diag_fill);
 
 static int inet_csk_diag_fill(struct sock *sk,
 			      struct sk_buff *skb,
-			      struct inet_diag_req_v2 *req,
+			      const struct inet_diag_req_v2 *req,
 			      struct user_namespace *user_ns,
 			      u32 portid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
@@ -223,7 +223,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 			       struct sk_buff *skb,
-			       struct inet_diag_req_v2 *req,
+			       const struct inet_diag_req_v2 *req,
 			       u32 portid, u32 seq, u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
@@ -277,7 +277,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
-			struct inet_diag_req_v2 *r,
+			const struct inet_diag_req_v2 *r,
 			struct user_namespace *user_ns,
 			u32 portid, u32 seq, u16 nlmsg_flags,
 			const struct nlmsghdr *unlh)
@@ -293,7 +293,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 			    struct sk_buff *in_skb,
 			    const struct nlmsghdr *nlh,
-			    struct inet_diag_req_v2 *req)
+			    const struct inet_diag_req_v2 *req)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct sk_buff *rep;
@@ -358,7 +358,7 @@ EXPORT_SYMBOL_GPL(inet_diag_dump_one_icsk);
 
 static int inet_diag_get_exact(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh,
-			       struct inet_diag_req_v2 *req)
+			       const struct inet_diag_req_v2 *req)
 {
 	const struct inet_diag_handler *handler;
 	int err;
@@ -626,7 +626,7 @@ static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 static int inet_csk_diag_dump(struct sock *sk,
 			      struct sk_buff *skb,
 			      struct netlink_callback *cb,
-			      struct inet_diag_req_v2 *r,
+			      const struct inet_diag_req_v2 *r,
 			      const struct nlattr *bc)
 {
 	if (!inet_diag_bc_sk(bc, sk))
@@ -667,7 +667,7 @@ static void twsk_build_assert(void)
 static int inet_twsk_diag_dump(struct sock *sk,
 			       struct sk_buff *skb,
 			       struct netlink_callback *cb,
-			       struct inet_diag_req_v2 *r,
+			       const struct inet_diag_req_v2 *r,
 			       const struct nlattr *bc)
 {
 	twsk_build_assert();
@@ -770,7 +770,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 
 static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 			       struct netlink_callback *cb,
-			       struct inet_diag_req_v2 *r,
+			       const struct inet_diag_req_v2 *r,
 			       const struct nlattr *bc)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -842,7 +842,7 @@ out:
 
 void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 			 struct netlink_callback *cb,
-			 struct inet_diag_req_v2 *r, struct nlattr *bc)
+			 const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	struct net *net = sock_net(skb->sk);
 	int i, num, s_i, s_num;
@@ -978,7 +978,7 @@ out:
 EXPORT_SYMBOL_GPL(inet_diag_dump_icsk);
 
 static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-			    struct inet_diag_req_v2 *r,
+			    const struct inet_diag_req_v2 *r,
 			    struct nlattr *bc)
 {
 	const struct inet_diag_handler *handler;
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 0d73f9ddb55b..86dc119a3815 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -34,13 +34,13 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 }
 
 static void tcp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-			  struct inet_diag_req_v2 *r, struct nlattr *bc)
+			  const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	inet_diag_dump_icsk(&tcp_hashinfo, skb, cb, r, bc);
 }
 
 static int tcp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-			     struct inet_diag_req_v2 *req)
+			     const struct inet_diag_req_v2 *req)
 {
 	return inet_diag_dump_one_icsk(&tcp_hashinfo, in_skb, nlh, req);
 }
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 4a000f1dd757..2dbfc1f1f7b3 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -18,8 +18,9 @@
 #include <linux/sock_diag.h>
 
 static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
-		struct netlink_callback *cb, struct inet_diag_req_v2 *req,
-		struct nlattr *bc)
+			struct netlink_callback *cb,
+			const struct inet_diag_req_v2 *req,
+			struct nlattr *bc)
 {
 	if (!inet_diag_bc_sk(bc, sk))
 		return 0;
@@ -31,7 +32,8 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
 }
 
 static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
-		const struct nlmsghdr *nlh, struct inet_diag_req_v2 *req)
+			const struct nlmsghdr *nlh,
+			const struct inet_diag_req_v2 *req)
 {
 	int err = -EINVAL;
 	struct sock *sk;
@@ -90,8 +92,9 @@ out_nosk:
 	return err;
 }
 
-static void udp_dump(struct udp_table *table, struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req_v2 *r, struct nlattr *bc)
+static void udp_dump(struct udp_table *table, struct sk_buff *skb,
+		     struct netlink_callback *cb,
+		     const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	int num, s_num, slot, s_slot;
 	struct net *net = sock_net(skb->sk);
@@ -144,13 +147,13 @@ done:
 }
 
 static void udp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req_v2 *r, struct nlattr *bc)
+			  const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	udp_dump(&udp_table, skb, cb, r, bc);
 }
 
 static int udp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req_v2 *req)
+			     const struct inet_diag_req_v2 *req)
 {
 	return udp_dump_one(&udp_table, in_skb, nlh, req);
 }
@@ -170,13 +173,14 @@ static const struct inet_diag_handler udp_diag_handler = {
 };
 
 static void udplite_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req_v2 *r, struct nlattr *bc)
+			      const struct inet_diag_req_v2 *r,
+			      struct nlattr *bc)
 {
 	udp_dump(&udplite_table, skb, cb, r, bc);
 }
 
 static int udplite_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req_v2 *req)
+				 const struct inet_diag_req_v2 *req)
 {
 	return udp_dump_one(&udplite_table, in_skb, nlh, req);
 }
-- 
2.2.0.rc0.207.ga3a616c
