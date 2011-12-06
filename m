From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 8/11] inet_diag: Switch the _dump to work with new header
Date: Tue, 06 Dec 2011 21:58:58 +0400
Message-ID: <4EDE57E2.2000702@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:24016 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab1LFR7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:59:03 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make inet_diag_dumo work with given header instead of calculating
one from the nl message.

The SOCK_DIAG_BY_FAMILY just passes skb's one through, the compat code
converts the old header to new one.

Also fix the bytecode calculation to find one at proper offset.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/inet_diag.c |   71 +++++++++++++++++++++++++++++++++++++------------
 1 files changed, 53 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 6b34071..d655f0a 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -502,10 +502,9 @@ static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 static int inet_csk_diag_dump(struct sock *sk,
 			      struct sk_buff *skb,
 			      struct netlink_callback *cb,
+			      struct inet_diag_req *r,
 			      const struct nlattr *bc)
 {
-	struct inet_diag_req_compat *r = NLMSG_DATA(cb->nlh);
-
 	if (bc != NULL) {
 		struct inet_diag_entry entry;
 		struct inet_sock *inet = inet_sk(sk);
@@ -539,10 +538,9 @@ static int inet_csk_diag_dump(struct sock *sk,
 static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 			       struct sk_buff *skb,
 			       struct netlink_callback *cb,
+			       struct inet_diag_req *r,
 			       const struct nlattr *bc)
 {
-	struct inet_diag_req_compat *r = NLMSG_DATA(cb->nlh);
-
 	if (bc != NULL) {
 		struct inet_diag_entry entry;
 
@@ -626,10 +624,10 @@ nlmsg_failure:
 
 static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 			       struct netlink_callback *cb,
+			       struct inet_diag_req *r,
 			       const struct nlattr *bc)
 {
 	struct inet_diag_entry entry;
-	struct inet_diag_req_compat *r = NLMSG_DATA(cb->nlh);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt;
 	struct inet_sock *inet = inet_sk(sk);
@@ -708,19 +706,15 @@ out:
 	return err;
 }
 
-static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
+static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
+		struct inet_diag_req *r, struct nlattr *bc)
 {
 	int i, num;
 	int s_i, s_num;
-	struct inet_diag_req_compat *r = NLMSG_DATA(cb->nlh);
 	const struct inet_diag_handler *handler;
 	struct inet_hashinfo *hashinfo;
-	const struct nlattr *bc = NULL;
-
-	if (nlmsg_attrlen(cb->nlh, sizeof(struct inet_diag_req_compat)))
-		bc = nlmsg_find_attr(cb->nlh, sizeof(*r), INET_DIAG_REQ_BYTECODE);
 
-	handler = inet_diag_lock_handler(inet_diag_type2proto(cb->nlh->nlmsg_type));
+	handler = inet_diag_lock_handler(r->sdiag_protocol);
 	if (IS_ERR(handler))
 		goto unlock;
 
@@ -758,7 +752,7 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 				    cb->args[3] > 0)
 					goto syn_recv;
 
-				if (inet_csk_diag_dump(sk, skb, cb, bc) < 0) {
+				if (inet_csk_diag_dump(sk, skb, cb, r, bc) < 0) {
 					spin_unlock_bh(&ilb->lock);
 					goto done;
 				}
@@ -767,7 +761,7 @@ syn_recv:
 				if (!(r->idiag_states & TCPF_SYN_RECV))
 					goto next_listen;
 
-				if (inet_diag_dump_reqs(skb, sk, cb, bc) < 0) {
+				if (inet_diag_dump_reqs(skb, sk, cb, r, bc) < 0) {
 					spin_unlock_bh(&ilb->lock);
 					goto done;
 				}
@@ -820,7 +814,7 @@ skip_listen_ht:
 			if (r->id.idiag_dport != inet->inet_dport &&
 			    r->id.idiag_dport)
 				goto next_normal;
-			if (inet_csk_diag_dump(sk, skb, cb, bc) < 0) {
+			if (inet_csk_diag_dump(sk, skb, cb, r, bc) < 0) {
 				spin_unlock_bh(lock);
 				goto done;
 			}
@@ -842,7 +836,7 @@ next_normal:
 				if (r->id.idiag_dport != tw->tw_dport &&
 				    r->id.idiag_dport)
 					goto next_dying;
-				if (inet_twsk_diag_dump(tw, skb, cb, bc) < 0) {
+				if (inet_twsk_diag_dump(tw, skb, cb, r, bc) < 0) {
 					spin_unlock_bh(lock);
 					goto done;
 				}
@@ -861,6 +855,36 @@ unlock:
 	return skb->len;
 }
 
+static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct nlattr *bc = NULL;
+	int hdrlen = sizeof(struct inet_diag_req);
+
+	if (nlmsg_attrlen(cb->nlh, hdrlen))
+		bc = nlmsg_find_attr(cb->nlh, hdrlen, INET_DIAG_REQ_BYTECODE);
+
+	return __inet_diag_dump(skb, cb, (struct inet_diag_req *)NLMSG_DATA(cb->nlh), bc);
+}
+
+static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct inet_diag_req_compat *rc = NLMSG_DATA(cb->nlh);
+	struct inet_diag_req req;
+	struct nlattr *bc = NULL;
+	int hdrlen = sizeof(struct inet_diag_req_compat);
+
+	req.sdiag_family = rc->idiag_family;
+	req.sdiag_protocol = inet_diag_type2proto(cb->nlh->nlmsg_type);
+	req.idiag_ext = rc->idiag_ext;
+	req.idiag_states = rc->idiag_states;
+	req.id = rc->id;
+
+	if (nlmsg_attrlen(cb->nlh, hdrlen))
+		bc = nlmsg_find_attr(cb->nlh, hdrlen, INET_DIAG_REQ_BYTECODE);
+
+	return __inet_diag_dump(skb, cb, &req, bc);
+}
+
 static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh)
 {
@@ -897,7 +921,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 
 		return netlink_dump_start(sdiagnl, skb, nlh,
-					  inet_diag_dump, NULL, 0);
+					  inet_diag_dump_compat, NULL, 0);
 	}
 
 	return inet_diag_get_exact_compat(skb, nlh);
@@ -911,7 +935,18 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		return -EINVAL;
 
 	if (h->nlmsg_flags & NLM_F_DUMP) {
-		return -EAFNOSUPPORT;
+		if (nlmsg_attrlen(h, hdrlen)) {
+			struct nlattr *attr;
+			attr = nlmsg_find_attr(h, hdrlen,
+					       INET_DIAG_REQ_BYTECODE);
+			if (attr == NULL ||
+			    nla_len(attr) < sizeof(struct inet_diag_bc_op) ||
+			    inet_diag_bc_audit(nla_data(attr), nla_len(attr)))
+				return -EINVAL;
+		}
+
+		return netlink_dump_start(sdiagnl, skb, h,
+					  inet_diag_dump, NULL, 0);
 	}
 
 	return inet_diag_get_exact(skb, h, (struct inet_diag_req *)NLMSG_DATA(h));
-- 
1.5.5.6
