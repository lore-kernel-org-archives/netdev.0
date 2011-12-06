From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 10/11] inet_diag: Cleanup type2proto last user
Date: Tue, 06 Dec 2011 21:59:32 +0400
Message-ID: <4EDE5804.6080009@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32185 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab1LFR7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:59:38 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now all the code works with sock_diag_req-compatible structs, so it's
possible to stop using the inet_diag_type2proto in inet_csk_diag_fill.
Pass the inet_diag_req into it and use the sdiag_protocol field. At the
same time remove the explicit ext argument, since it's also on the req.

However, this conversion is still required in _compat code, so just move
this routine, not remove.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/inet_diag.c |   47 ++++++++++++++++++++++++-----------------------
 1 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index f1aaaec..d5ca77c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -51,18 +51,6 @@ static struct sock *sdiagnl;
 #define INET_DIAG_PUT(skb, attrtype, attrlen) \
 	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
 
-static inline int inet_diag_type2proto(int type)
-{
-	switch (type) {
-	case TCPDIAG_GETSOCK:
-		return IPPROTO_TCP;
-	case DCCPDIAG_GETSOCK:
-		return IPPROTO_DCCP;
-	default:
-		return 0;
-	}
-}
-
 static DEFINE_MUTEX(inet_diag_table_mutex);
 
 static const struct inet_diag_handler *inet_diag_lock_handler(int proto)
@@ -85,8 +73,8 @@ static inline void inet_diag_unlock_handler(
 }
 
 static int inet_csk_diag_fill(struct sock *sk,
-			      struct sk_buff *skb,
-			      int ext, u32 pid, u32 seq, u16 nlmsg_flags,
+			      struct sk_buff *skb, struct inet_diag_req *req,
+			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
 	const struct inet_sock *inet = inet_sk(sk);
@@ -97,8 +85,9 @@ static int inet_csk_diag_fill(struct sock *sk,
 	struct inet_diag_meminfo  *minfo = NULL;
 	unsigned char	 *b = skb_tail_pointer(skb);
 	const struct inet_diag_handler *handler;
+	int ext = req->idiag_ext;
 
-	handler = inet_diag_table[inet_diag_type2proto(unlh->nlmsg_type)];
+	handler = inet_diag_table[req->sdiag_protocol];
 	BUG_ON(handler == NULL);
 
 	nlh = NLMSG_PUT(skb, pid, seq, unlh->nlmsg_type, sizeof(*r));
@@ -198,8 +187,8 @@ nlmsg_failure:
 }
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
-			       struct sk_buff *skb, int ext, u32 pid,
-			       u32 seq, u16 nlmsg_flags,
+			       struct sk_buff *skb, struct inet_diag_req *req,
+			       u32 pid, u32 seq, u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
 	long tmo;
@@ -250,14 +239,14 @@ nlmsg_failure:
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
-			int ext, u32 pid, u32 seq, u16 nlmsg_flags,
+			struct inet_diag_req *r, u32 pid, u32 seq, u16 nlmsg_flags,
 			const struct nlmsghdr *unlh)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
 		return inet_twsk_diag_fill((struct inet_timewait_sock *)sk,
-					   skb, ext, pid, seq, nlmsg_flags,
+					   skb, r, pid, seq, nlmsg_flags,
 					   unlh);
-	return inet_csk_diag_fill(sk, skb, ext, pid, seq, nlmsg_flags, unlh);
+	return inet_csk_diag_fill(sk, skb, r, pid, seq, nlmsg_flags, unlh);
 }
 
 static int inet_diag_get_exact(struct sk_buff *in_skb,
@@ -317,7 +306,7 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	if (!rep)
 		goto out;
 
-	err = sk_diag_fill(sk, rep, req->idiag_ext,
+	err = sk_diag_fill(sk, rep, req,
 			   NETLINK_CB(in_skb).pid,
 			   nlh->nlmsg_seq, 0, nlh);
 	if (err < 0) {
@@ -530,7 +519,7 @@ static int inet_csk_diag_dump(struct sock *sk,
 			return 0;
 	}
 
-	return inet_csk_diag_fill(sk, skb, r->idiag_ext,
+	return inet_csk_diag_fill(sk, skb, r,
 				  NETLINK_CB(cb->skb).pid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
@@ -565,7 +554,7 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 			return 0;
 	}
 
-	return inet_twsk_diag_fill(tw, skb, r->idiag_ext,
+	return inet_twsk_diag_fill(tw, skb, r,
 				   NETLINK_CB(cb->skb).pid,
 				   cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
@@ -876,6 +865,18 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return __inet_diag_dump(skb, cb, (struct inet_diag_req *)NLMSG_DATA(cb->nlh), bc);
 }
 
+static inline int inet_diag_type2proto(int type)
+{
+	switch (type) {
+	case TCPDIAG_GETSOCK:
+		return IPPROTO_TCP;
+	case DCCPDIAG_GETSOCK:
+		return IPPROTO_DCCP;
+	default:
+		return 0;
+	}
+}
+
 static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct inet_diag_req_compat *rc = NLMSG_DATA(cb->nlh);
-- 
1.5.5.6
