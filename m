From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next v2] net: inet: diag: expose the socket mark to privileged processes.
Date: Wed,  7 Sep 2016 18:42:40 +0900
Message-ID: <1473241360-102869-1-git-send-email-lorenzo@google.com>
Cc: ek@google.com, eric.dumazet@gmail.com, davem@davemloft.net,
        dsa@cumulusnetworks.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36488 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbcIGJmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 05:42:54 -0400
Received: by mail-pf0-f176.google.com with SMTP id 128so5011451pfb.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 02:42:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the capability for a process that has CAP_NET_ADMIN on
a socket to see the socket mark in socket dumps.

Commit a52e95abf772 ("net: diag: allow socket bytecode filters to
match socket marks") recently gave privileged processes the
ability to filter socket dumps based on mark. This patch is
complementary: it ensures that the mark is also passed to
userspace in the socket's netlink attributes.  It is useful for
tools like ss which display information about sockets.

Tested: https://android-review.googlesource.com/270210
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/inet_diag.h      |  4 ++--
 include/uapi/linux/inet_diag.h |  1 +
 net/ipv4/inet_diag.c           | 49 ++++++++++++++++++++++++++++--------------
 net/ipv4/udp_diag.c            | 10 +++++----
 4 files changed, 42 insertions(+), 22 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index feb04ea..65da430 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -37,7 +37,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
 		      struct user_namespace *user_ns,
 		      u32 pid, u32 seq, u16 nlmsg_flags,
-		      const struct nlmsghdr *unlh);
+		      const struct nlmsghdr *unlh, bool net_admin);
 void inet_diag_dump_icsk(struct inet_hashinfo *h, struct sk_buff *skb,
 			 struct netlink_callback *cb,
 			 const struct inet_diag_req_v2 *r,
@@ -56,7 +56,7 @@ void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk);
 
 int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
 			     struct inet_diag_msg *r, int ext,
-			     struct user_namespace *user_ns);
+			     struct user_namespace *user_ns, bool net_admin);
 
 extern int  inet_diag_register(const struct inet_diag_handler *handler);
 extern void inet_diag_unregister(const struct inet_diag_handler *handler);
diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index 5581206..b5c366f 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -123,6 +123,7 @@ enum {
 	INET_DIAG_LOCALS,
 	INET_DIAG_PEERS,
 	INET_DIAG_PAD,
+	INET_DIAG_MARK,
 	__INET_DIAG_MAX,
 };
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index abfbe49..e4d16fc 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -99,6 +99,7 @@ static size_t inet_sk_attr_size(void)
 		+ nla_total_size(1) /* INET_DIAG_SHUTDOWN */
 		+ nla_total_size(1) /* INET_DIAG_TOS */
 		+ nla_total_size(1) /* INET_DIAG_TCLASS */
+		+ nla_total_size(4) /* INET_DIAG_MARK */
 		+ nla_total_size(sizeof(struct inet_diag_meminfo))
 		+ nla_total_size(sizeof(struct inet_diag_msg))
 		+ nla_total_size(SK_MEMINFO_VARS * sizeof(u32))
@@ -109,7 +110,8 @@ static size_t inet_sk_attr_size(void)
 
 int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
 			     struct inet_diag_msg *r, int ext,
-			     struct user_namespace *user_ns)
+			     struct user_namespace *user_ns,
+			     bool net_admin)
 {
 	const struct inet_sock *inet = inet_sk(sk);
 
@@ -136,6 +138,9 @@ int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
 	}
 #endif
 
+	if (net_admin && nla_put_u32(skb, INET_DIAG_MARK, sk->sk_mark))
+		goto errout;
+
 	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
 	r->idiag_inode = sock_i_ino(sk);
 
@@ -149,7 +154,8 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
 		      struct user_namespace *user_ns,
 		      u32 portid, u32 seq, u16 nlmsg_flags,
-		      const struct nlmsghdr *unlh)
+		      const struct nlmsghdr *unlh,
+		      bool net_admin)
 {
 	const struct tcp_congestion_ops *ca_ops;
 	const struct inet_diag_handler *handler;
@@ -175,7 +181,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	r->idiag_timer = 0;
 	r->idiag_retrans = 0;
 
-	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns))
+	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns, net_admin))
 		goto errout;
 
 	if (ext & (1 << (INET_DIAG_MEMINFO - 1))) {
@@ -274,10 +280,11 @@ static int inet_csk_diag_fill(struct sock *sk,
 			      const struct inet_diag_req_v2 *req,
 			      struct user_namespace *user_ns,
 			      u32 portid, u32 seq, u16 nlmsg_flags,
-			      const struct nlmsghdr *unlh)
+			      const struct nlmsghdr *unlh,
+			      bool net_admin)
 {
-	return inet_sk_diag_fill(sk, inet_csk(sk), skb, req,
-				 user_ns, portid, seq, nlmsg_flags, unlh);
+	return inet_sk_diag_fill(sk, inet_csk(sk), skb, req, user_ns,
+				 portid, seq, nlmsg_flags, unlh, net_admin);
 }
 
 static int inet_twsk_diag_fill(struct sock *sk,
@@ -319,8 +326,9 @@ static int inet_twsk_diag_fill(struct sock *sk,
 
 static int inet_req_diag_fill(struct sock *sk, struct sk_buff *skb,
 			      u32 portid, u32 seq, u16 nlmsg_flags,
-			      const struct nlmsghdr *unlh)
+			      const struct nlmsghdr *unlh, bool net_admin)
 {
+	struct request_sock *reqsk = inet_reqsk(sk);
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
 	long tmo;
@@ -334,7 +342,7 @@ static int inet_req_diag_fill(struct sock *sk, struct sk_buff *skb,
 	inet_diag_msg_common_fill(r, sk);
 	r->idiag_state = TCP_SYN_RECV;
 	r->idiag_timer = 1;
-	r->idiag_retrans = inet_reqsk(sk)->num_retrans;
+	r->idiag_retrans = reqsk->num_retrans;
 
 	BUILD_BUG_ON(offsetof(struct inet_request_sock, ir_cookie) !=
 		     offsetof(struct sock, sk_cookie));
@@ -346,6 +354,10 @@ static int inet_req_diag_fill(struct sock *sk, struct sk_buff *skb,
 	r->idiag_uid	= 0;
 	r->idiag_inode	= 0;
 
+	if (net_admin && nla_put_u32(skb, INET_DIAG_MARK,
+				     inet_rsk(reqsk)->ir_mark))
+		return -EMSGSIZE;
+
 	nlmsg_end(skb, nlh);
 	return 0;
 }
@@ -354,7 +366,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			const struct inet_diag_req_v2 *r,
 			struct user_namespace *user_ns,
 			u32 portid, u32 seq, u16 nlmsg_flags,
-			const struct nlmsghdr *unlh)
+			const struct nlmsghdr *unlh, bool net_admin)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
 		return inet_twsk_diag_fill(sk, skb, portid, seq,
@@ -362,10 +374,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 
 	if (sk->sk_state == TCP_NEW_SYN_RECV)
 		return inet_req_diag_fill(sk, skb, portid, seq,
-					  nlmsg_flags, unlh);
+					  nlmsg_flags, unlh, net_admin);
 
 	return inet_csk_diag_fill(sk, skb, r, user_ns, portid, seq,
-				  nlmsg_flags, unlh);
+				  nlmsg_flags, unlh, net_admin);
 }
 
 struct sock *inet_diag_find_one_icsk(struct net *net,
@@ -435,7 +447,8 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 	err = sk_diag_fill(sk, rep, req,
 			   sk_user_ns(NETLINK_CB(in_skb).sk),
 			   NETLINK_CB(in_skb).portid,
-			   nlh->nlmsg_seq, 0, nlh);
+			   nlh->nlmsg_seq, 0, nlh,
+			   netlink_net_capable(in_skb, CAP_NET_ADMIN));
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
 		nlmsg_free(rep);
@@ -796,7 +809,8 @@ static int inet_csk_diag_dump(struct sock *sk,
 			      struct sk_buff *skb,
 			      struct netlink_callback *cb,
 			      const struct inet_diag_req_v2 *r,
-			      const struct nlattr *bc)
+			      const struct nlattr *bc,
+			      bool net_admin)
 {
 	if (!inet_diag_bc_sk(bc, sk))
 		return 0;
@@ -804,7 +818,8 @@ static int inet_csk_diag_dump(struct sock *sk,
 	return inet_csk_diag_fill(sk, skb, r,
 				  sk_user_ns(NETLINK_CB(cb->skb).sk),
 				  NETLINK_CB(cb->skb).portid,
-				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
+				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh,
+				  net_admin);
 }
 
 static void twsk_build_assert(void)
@@ -840,6 +855,7 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	int i, num, s_i, s_num;
 	u32 idiag_states = r->idiag_states;
+	bool net_admin = netlink_net_capable(cb->skb, CAP_NET_ADMIN);
 
 	if (idiag_states & TCPF_SYN_RECV)
 		idiag_states |= TCPF_NEW_SYN_RECV;
@@ -880,7 +896,8 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 				    cb->args[3] > 0)
 					goto next_listen;
 
-				if (inet_csk_diag_dump(sk, skb, cb, r, bc) < 0) {
+				if (inet_csk_diag_dump(sk, skb, cb, r,
+						       bc, net_admin) < 0) {
 					spin_unlock_bh(&ilb->lock);
 					goto done;
 				}
@@ -948,7 +965,7 @@ skip_listen_ht:
 					   sk_user_ns(NETLINK_CB(cb->skb).sk),
 					   NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					   cb->nlh);
+					   cb->nlh, net_admin);
 			if (res < 0) {
 				spin_unlock_bh(lock);
 				goto done;
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 58b79c0..9a89c10 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -20,7 +20,7 @@
 static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
 			struct netlink_callback *cb,
 			const struct inet_diag_req_v2 *req,
-			struct nlattr *bc)
+			struct nlattr *bc, bool net_admin)
 {
 	if (!inet_diag_bc_sk(bc, sk))
 		return 0;
@@ -28,7 +28,7 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
 	return inet_sk_diag_fill(sk, NULL, skb, req,
 			sk_user_ns(NETLINK_CB(cb->skb).sk),
 			NETLINK_CB(cb->skb).portid,
-			cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
+			cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh, net_admin);
 }
 
 static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
@@ -76,7 +76,8 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 	err = inet_sk_diag_fill(sk, NULL, rep, req,
 			   sk_user_ns(NETLINK_CB(in_skb).sk),
 			   NETLINK_CB(in_skb).portid,
-			   nlh->nlmsg_seq, 0, nlh);
+			   nlh->nlmsg_seq, 0, nlh,
+			   netlink_net_capable(in_skb, CAP_NET_ADMIN));
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(rep);
@@ -97,6 +98,7 @@ static void udp_dump(struct udp_table *table, struct sk_buff *skb,
 		     struct netlink_callback *cb,
 		     const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
+	bool net_admin = netlink_net_capable(cb->skb, CAP_NET_ADMIN);
 	struct net *net = sock_net(skb->sk);
 	int num, s_num, slot, s_slot;
 
@@ -132,7 +134,7 @@ static void udp_dump(struct udp_table *table, struct sk_buff *skb,
 			    r->id.idiag_dport)
 				goto next;
 
-			if (sk_diag_dump(sk, skb, cb, r, bc) < 0) {
+			if (sk_diag_dump(sk, skb, cb, r, bc, net_admin) < 0) {
 				spin_unlock_bh(&hslot->lock);
 				goto done;
 			}
-- 
2.8.0.rc3.226.g39d4020
