From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/18] inet_diag: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:15 -0700 (PDT)
Message-ID: <20120626.220215.2188843873288490866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab2F0FCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:16 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 45FE8584193
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too, and remove useless
casts.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inet_diag.c |   43 ++++++++++++++++++++++++-------------------
 1 file changed, 24 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 46d1e71..27640e7 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -87,10 +87,14 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	handler = inet_diag_table[req->sdiag_protocol];
 	BUG_ON(handler == NULL);
 
-	nlh = NLMSG_PUT(skb, pid, seq, unlh->nlmsg_type, sizeof(*r));
+	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r), 0);
+	if (!nlh) {
+		nlmsg_trim(skb, b);
+		return -EMSGSIZE;
+	}
 	nlh->nlmsg_flags = nlmsg_flags;
 
-	r = NLMSG_DATA(nlh);
+	r = nlmsg_data(nlh);
 	BUG_ON(sk->sk_state == TCP_TIME_WAIT);
 
 	if (ext & (1 << (INET_DIAG_MEMINFO - 1)))
@@ -186,7 +190,6 @@ out:
 	return skb->len;
 
 rtattr_failure:
-nlmsg_failure:
 	nlmsg_trim(skb, b);
 	return -EMSGSIZE;
 }
@@ -209,10 +212,15 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	long tmo;
 	struct inet_diag_msg *r;
 	const unsigned char *previous_tail = skb_tail_pointer(skb);
-	struct nlmsghdr *nlh = NLMSG_PUT(skb, pid, seq,
-					 unlh->nlmsg_type, sizeof(*r));
+	struct nlmsghdr *nlh = nlmsg_put(skb, pid, seq,
+					 unlh->nlmsg_type, sizeof(*r), 0);
+
+	if (!nlh) {
+		nlmsg_trim(skb, previous_tail);
+		return -EMSGSIZE;
+	}
 
-	r = NLMSG_DATA(nlh);
+	r = nlmsg_data(nlh);
 	BUG_ON(tw->tw_state != TCP_TIME_WAIT);
 
 	nlh->nlmsg_flags = nlmsg_flags;
@@ -247,9 +255,6 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 #endif
 	nlh->nlmsg_len = skb_tail_pointer(skb) - previous_tail;
 	return skb->len;
-nlmsg_failure:
-	nlmsg_trim(skb, previous_tail);
-	return -EMSGSIZE;
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
@@ -597,9 +602,13 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	struct nlmsghdr *nlh;
 	long tmo;
 
-	nlh = NLMSG_PUT(skb, pid, seq, unlh->nlmsg_type, sizeof(*r));
+	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r), 0);
+	if (!nlh) {
+		nlmsg_trim(skb, b);
+		return -1;
+	}
 	nlh->nlmsg_flags = NLM_F_MULTI;
-	r = NLMSG_DATA(nlh);
+	r = nlmsg_data(nlh);
 
 	r->idiag_family = sk->sk_family;
 	r->idiag_state = TCP_SYN_RECV;
@@ -631,10 +640,6 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 
 	return skb->len;
-
-nlmsg_failure:
-	nlmsg_trim(skb, b);
-	return -1;
 }
 
 static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
@@ -892,7 +897,7 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	if (nlmsg_attrlen(cb->nlh, hdrlen))
 		bc = nlmsg_find_attr(cb->nlh, hdrlen, INET_DIAG_REQ_BYTECODE);
 
-	return __inet_diag_dump(skb, cb, (struct inet_diag_req_v2 *)NLMSG_DATA(cb->nlh), bc);
+	return __inet_diag_dump(skb, cb, nlmsg_data(cb->nlh), bc);
 }
 
 static inline int inet_diag_type2proto(int type)
@@ -909,7 +914,7 @@ static inline int inet_diag_type2proto(int type)
 
 static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct inet_diag_req *rc = NLMSG_DATA(cb->nlh);
+	struct inet_diag_req *rc = nlmsg_data(cb->nlh);
 	struct inet_diag_req_v2 req;
 	struct nlattr *bc = NULL;
 	int hdrlen = sizeof(struct inet_diag_req);
@@ -929,7 +934,7 @@ static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *c
 static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh)
 {
-	struct inet_diag_req *rc = NLMSG_DATA(nlh);
+	struct inet_diag_req *rc = nlmsg_data(nlh);
 	struct inet_diag_req_v2 req;
 
 	req.sdiag_family = rc->idiag_family;
@@ -996,7 +1001,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		}
 	}
 
-	return inet_diag_get_exact(skb, h, (struct inet_diag_req_v2 *)NLMSG_DATA(h));
+	return inet_diag_get_exact(skb, h, nlmsg_data(h));
 }
 
 static const struct sock_diag_handler inet_diag_handler = {
-- 
1.7.10.2
