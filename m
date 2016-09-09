From: Lorenzo Colitti <lorenzo@google.com>
Subject: [RFC net-next] net: diag: reduce arguments passed to fill functions.
Date: Fri,  9 Sep 2016 14:16:52 +0900
Message-ID: <1473398212-75207-1-git-send-email-lorenzo@google.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ek@google.com,
        Lorenzo Colitti <lorenzo@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33385 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbcIIFRC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:17:02 -0400
Received: by mail-pa0-f42.google.com with SMTP id cm16so24647473pac.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:17:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the arguments passed to the various diag_fill functions
are only a couple of pointer lookups away from in_skb. Instead
of passing all the arguments down the call chain, pass around
in_skb and have the fill functions get what they need from that.

This patch does not remove the "bool net_admin" parameter. This
parameter can also be derived from in_skb, but removing it would
require calculating it once per socket instead of once per dump,
and because netlink_ns_capable is more than just a couple of
pointer lookups, that might affect performance. If performance is
not a concern (which is likely, since dumping a socket already
involves things like copying data to userspace), it's easy to
remove this one as well.

Tested: Passes all existing Android sock_diag tests.
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/inet_diag.h |  6 ++--
 net/ipv4/inet_diag.c      | 75 +++++++++++++++++------------------------------
 net/ipv4/udp_diag.c       | 13 +++-----
 net/sctp/sctp_diag.c      | 36 ++++++++---------------
 4 files changed, 46 insertions(+), 84 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 65da430..da0777c 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -35,8 +35,7 @@ struct inet_diag_handler {
 struct inet_connection_sock;
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
-		      struct user_namespace *user_ns,
-		      u32 pid, u32 seq, u16 nlmsg_flags,
+		      const struct sk_buff *in_skb, u16 nlmsg_flags,
 		      const struct nlmsghdr *unlh, bool net_admin);
 void inet_diag_dump_icsk(struct inet_hashinfo *h, struct sk_buff *skb,
 			 struct netlink_callback *cb,
@@ -56,7 +55,8 @@ void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk);
 
 int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
 			     struct inet_diag_msg *r, int ext,
-			     struct user_namespace *user_ns, bool net_admin);
+			     const struct sk_buff *in_skb,
+			     bool net_admin);
 
 extern int  inet_diag_register(const struct inet_diag_handler *handler);
 extern void inet_diag_unregister(const struct inet_diag_handler *handler);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 1683bf5..de5bfa8 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -110,7 +110,7 @@ static size_t inet_sk_attr_size(void)
 
 int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
 			     struct inet_diag_msg *r, int ext,
-			     struct user_namespace *user_ns,
+			     const struct sk_buff *in_skb,
 			     bool net_admin)
 {
 	const struct inet_sock *inet = inet_sk(sk);
@@ -141,7 +141,8 @@ int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
 	if (net_admin && nla_put_u32(skb, INET_DIAG_MARK, sk->sk_mark))
 		goto errout;
 
-	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
+	r->idiag_uid = from_kuid_munged(sk_user_ns(NETLINK_CB(in_skb).sk),
+					sock_i_uid(sk));
 	r->idiag_inode = sock_i_ino(sk);
 
 	return 0;
@@ -152,10 +153,8 @@ EXPORT_SYMBOL_GPL(inet_diag_msg_attrs_fill);
 
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
-		      struct user_namespace *user_ns,
-		      u32 portid, u32 seq, u16 nlmsg_flags,
-		      const struct nlmsghdr *unlh,
-		      bool net_admin)
+		      const struct sk_buff *in_skb, u16 nlmsg_flags,
+		      const struct nlmsghdr *unlh, bool net_admin)
 {
 	const struct tcp_congestion_ops *ca_ops;
 	const struct inet_diag_handler *handler;
@@ -168,8 +167,8 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	handler = inet_diag_table[req->sdiag_protocol];
 	BUG_ON(!handler);
 
-	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
-			nlmsg_flags);
+	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).portid, unlh->nlmsg_seq,
+			unlh->nlmsg_type, sizeof(*r), nlmsg_flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -181,7 +180,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	r->idiag_timer = 0;
 	r->idiag_retrans = 0;
 
-	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns, net_admin))
+	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, in_skb, net_admin))
 		goto errout;
 
 	if (ext & (1 << (INET_DIAG_MEMINFO - 1))) {
@@ -275,30 +274,20 @@ errout:
 }
 EXPORT_SYMBOL_GPL(inet_sk_diag_fill);
 
-static int inet_csk_diag_fill(struct sock *sk,
-			      struct sk_buff *skb,
-			      const struct inet_diag_req_v2 *req,
-			      struct user_namespace *user_ns,
-			      u32 portid, u32 seq, u16 nlmsg_flags,
-			      const struct nlmsghdr *unlh,
-			      bool net_admin)
-{
-	return inet_sk_diag_fill(sk, inet_csk(sk), skb, req, user_ns,
-				 portid, seq, nlmsg_flags, unlh, net_admin);
-}
-
 static int inet_twsk_diag_fill(struct sock *sk,
 			       struct sk_buff *skb,
-			       u32 portid, u32 seq, u16 nlmsg_flags,
+			       const struct sk_buff *in_skb,
+			       u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
 	struct inet_timewait_sock *tw = inet_twsk(sk);
+	u32 portid = NETLINK_CB(in_skb).portid;
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
 	long tmo;
 
-	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
-			nlmsg_flags);
+	nlh = nlmsg_put(skb, portid, unlh->nlmsg_seq, unlh->nlmsg_type,
+			sizeof(*r), nlmsg_flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -325,16 +314,17 @@ static int inet_twsk_diag_fill(struct sock *sk,
 }
 
 static int inet_req_diag_fill(struct sock *sk, struct sk_buff *skb,
-			      u32 portid, u32 seq, u16 nlmsg_flags,
+			      const struct sk_buff *in_skb, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh, bool net_admin)
 {
 	struct request_sock *reqsk = inet_reqsk(sk);
+	u32 portid = NETLINK_CB(in_skb).portid;
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
 	long tmo;
 
-	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
-			nlmsg_flags);
+	nlh = nlmsg_put(skb, portid, unlh->nlmsg_seq, unlh->nlmsg_type,
+			sizeof(*r), nlmsg_flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -364,20 +354,18 @@ static int inet_req_diag_fill(struct sock *sk, struct sk_buff *skb,
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			const struct inet_diag_req_v2 *r,
-			struct user_namespace *user_ns,
-			u32 portid, u32 seq, u16 nlmsg_flags,
+			const struct sk_buff *in_skb, u16 nlmsg_flags,
 			const struct nlmsghdr *unlh, bool net_admin)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
-		return inet_twsk_diag_fill(sk, skb, portid, seq,
-					   nlmsg_flags, unlh);
+		return inet_twsk_diag_fill(sk, skb, in_skb, nlmsg_flags, unlh);
 
 	if (sk->sk_state == TCP_NEW_SYN_RECV)
-		return inet_req_diag_fill(sk, skb, portid, seq,
-					  nlmsg_flags, unlh, net_admin);
+		return inet_req_diag_fill(sk, skb, in_skb, nlmsg_flags, unlh,
+					  net_admin);
 
-	return inet_csk_diag_fill(sk, skb, r, user_ns, portid, seq,
-				  nlmsg_flags, unlh, net_admin);
+	return inet_sk_diag_fill(sk, inet_csk(sk), skb, r, in_skb, nlmsg_flags,
+				 unlh, net_admin);
 }
 
 struct sock *inet_diag_find_one_icsk(struct net *net,
@@ -444,10 +432,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 		goto out;
 	}
 
-	err = sk_diag_fill(sk, rep, req,
-			   sk_user_ns(NETLINK_CB(in_skb).sk),
-			   NETLINK_CB(in_skb).portid,
-			   nlh->nlmsg_seq, 0, nlh,
+	err = sk_diag_fill(sk, rep, req, in_skb, 0, nlh,
 			   netlink_net_capable(in_skb, CAP_NET_ADMIN));
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
@@ -815,11 +800,8 @@ static int inet_csk_diag_dump(struct sock *sk,
 	if (!inet_diag_bc_sk(bc, sk))
 		return 0;
 
-	return inet_csk_diag_fill(sk, skb, r,
-				  sk_user_ns(NETLINK_CB(cb->skb).sk),
-				  NETLINK_CB(cb->skb).portid,
-				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh,
-				  net_admin);
+	return inet_sk_diag_fill(sk, inet_csk(sk), skb, r, cb->skb,
+				 NLM_F_MULTI, cb->nlh, net_admin);
 }
 
 static void twsk_build_assert(void)
@@ -961,10 +943,7 @@ skip_listen_ht:
 			if (!inet_diag_bc_sk(bc, sk))
 				goto next_normal;
 
-			res = sk_diag_fill(sk, skb, r,
-					   sk_user_ns(NETLINK_CB(cb->skb).sk),
-					   NETLINK_CB(cb->skb).portid,
-					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
+			res = sk_diag_fill(sk, skb, r, cb->skb, NLM_F_MULTI,
 					   cb->nlh, net_admin);
 			if (res < 0) {
 				spin_unlock_bh(lock);
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 9a89c10..917abac 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -25,10 +25,8 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
 	if (!inet_diag_bc_sk(bc, sk))
 		return 0;
 
-	return inet_sk_diag_fill(sk, NULL, skb, req,
-			sk_user_ns(NETLINK_CB(cb->skb).sk),
-			NETLINK_CB(cb->skb).portid,
-			cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh, net_admin);
+	return inet_sk_diag_fill(sk, NULL, skb, req, cb->skb, NLM_F_MULTI,
+				 cb->nlh, net_admin);
 }
 
 static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
@@ -73,11 +71,8 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 	if (!rep)
 		goto out;
 
-	err = inet_sk_diag_fill(sk, NULL, rep, req,
-			   sk_user_ns(NETLINK_CB(in_skb).sk),
-			   NETLINK_CB(in_skb).portid,
-			   nlh->nlmsg_seq, 0, nlh,
-			   netlink_net_capable(in_skb, CAP_NET_ADMIN));
+	err = inet_sk_diag_fill(sk, NULL, rep, req, in_skb, 0, nlh,
+				netlink_net_capable(in_skb, CAP_NET_ADMIN));
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(rep);
diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index 807158e3..ab2009e 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -104,12 +104,12 @@ static int inet_diag_msg_sctpaddrs_fill(struct sk_buff *skb,
 static int inet_sctp_diag_fill(struct sock *sk, struct sctp_association *asoc,
 			       struct sk_buff *skb,
 			       const struct inet_diag_req_v2 *req,
-			       struct user_namespace *user_ns,
-			       int portid, u32 seq, u16 nlmsg_flags,
-			       const struct nlmsghdr *unlh,
+			       const struct sk_buff *in_skb,
+			       u16 nlmsg_flags, const struct nlmsghdr *unlh,
 			       bool net_admin)
 {
 	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
+	u32 portid = NETLINK_CB(in_skb).portid;
 	struct list_head *addr_list;
 	struct inet_diag_msg *r;
 	struct nlmsghdr  *nlh;
@@ -117,8 +117,8 @@ static int inet_sctp_diag_fill(struct sock *sk, struct sctp_association *asoc,
 	struct sctp_infox infox;
 	void *info = NULL;
 
-	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
-			nlmsg_flags);
+	nlh = nlmsg_put(skb, portid, unlh->nlmsg_seq, unlh->nlmsg_type,
+			sizeof(*r), nlmsg_flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -134,7 +134,7 @@ static int inet_sctp_diag_fill(struct sock *sk, struct sctp_association *asoc,
 		r->idiag_retrans = 0;
 	}
 
-	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns, net_admin))
+	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, in_skb, net_admin))
 		goto errout;
 
 	if (ext & (1 << (INET_DIAG_SKMEMINFO - 1))) {
@@ -256,10 +256,7 @@ static int sctp_tsp_dump_one(struct sctp_transport *tsp, void *p)
 		sk = assoc->base.sk;
 		lock_sock(sk);
 	}
-	err = inet_sctp_diag_fill(sk, assoc, rep, req,
-				  sk_user_ns(NETLINK_CB(in_skb).sk),
-				  NETLINK_CB(in_skb).portid,
-				  nlh->nlmsg_seq, 0, nlh,
+	err = inet_sctp_diag_fill(sk, assoc, rep, req, in_skb, 0, nlh,
 				  commp->net_admin);
 	release_sock(sk);
 	if (err < 0) {
@@ -310,10 +307,7 @@ static int sctp_tsp_dump(struct sctp_transport *tsp, void *p)
 			goto next;
 
 		if (!cb->args[3] &&
-		    inet_sctp_diag_fill(sk, NULL, skb, r,
-					sk_user_ns(NETLINK_CB(cb->skb).sk),
-					NETLINK_CB(cb->skb).portid,
-					cb->nlh->nlmsg_seq,
+		    inet_sctp_diag_fill(sk, NULL, skb, r, cb->skb,
 					NLM_F_MULTI, cb->nlh,
 					commp->net_admin) < 0) {
 			cb->args[3] = 1;
@@ -322,11 +316,8 @@ static int sctp_tsp_dump(struct sctp_transport *tsp, void *p)
 		}
 		cb->args[3] = 1;
 
-		if (inet_sctp_diag_fill(sk, assoc, skb, r,
-					sk_user_ns(NETLINK_CB(cb->skb).sk),
-					NETLINK_CB(cb->skb).portid,
-					cb->nlh->nlmsg_seq, 0, cb->nlh,
-					commp->net_admin) < 0) {
+		if (inet_sctp_diag_fill(sk, assoc, skb, r, cb->skb,
+					0, cb->nlh, commp->net_admin) < 0) {
 			err = 2;
 			goto release;
 		}
@@ -377,11 +368,8 @@ static int sctp_ep_dump(struct sctp_endpoint *ep, void *p)
 	    r->id.idiag_dport)
 		goto next;
 
-	if (inet_sctp_diag_fill(sk, NULL, skb, r,
-				sk_user_ns(NETLINK_CB(cb->skb).sk),
-				NETLINK_CB(cb->skb).portid,
-				cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				cb->nlh, commp->net_admin) < 0) {
+	if (inet_sctp_diag_fill(sk, NULL, skb, r, cb->skb,
+				NLM_F_MULTI, cb->nlh, commp->net_admin) < 0) {
 		err = 2;
 		goto out;
 	}
-- 
2.8.0.rc3.226.g39d4020
