From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/11] inet_diag: Move byte-code finding up the call-stack
Date: Tue, 06 Dec 2011 21:57:26 +0400
Message-ID: <4EDE5786.4000606@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46164 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab1LFR5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:57:32 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current code calculates it at fixed offset. This offset will change, so
move the BC calculation upper to make the further patching simpler.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/inet_diag.c |   36 +++++++++++++++++-------------------
 1 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e106e3b..a406caf 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -488,15 +488,13 @@ static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 
 static int inet_csk_diag_dump(struct sock *sk,
 			      struct sk_buff *skb,
-			      struct netlink_callback *cb)
+			      struct netlink_callback *cb,
+			      const struct nlattr *bc)
 {
 	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
 
-	if (nlmsg_attrlen(cb->nlh, sizeof(*r))) {
+	if (bc != NULL) {
 		struct inet_diag_entry entry;
-		const struct nlattr *bc = nlmsg_find_attr(cb->nlh,
-							  sizeof(*r),
-							  INET_DIAG_REQ_BYTECODE);
 		struct inet_sock *inet = inet_sk(sk);
 
 		entry.family = sk->sk_family;
@@ -527,15 +525,13 @@ static int inet_csk_diag_dump(struct sock *sk,
 
 static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 			       struct sk_buff *skb,
-			       struct netlink_callback *cb)
+			       struct netlink_callback *cb,
+			       const struct nlattr *bc)
 {
 	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
 
-	if (nlmsg_attrlen(cb->nlh, sizeof(*r))) {
+	if (bc != NULL) {
 		struct inet_diag_entry entry;
-		const struct nlattr *bc = nlmsg_find_attr(cb->nlh,
-							  sizeof(*r),
-							  INET_DIAG_REQ_BYTECODE);
 
 		entry.family = tw->tw_family;
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
@@ -616,13 +612,13 @@ nlmsg_failure:
 }
 
 static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
-			       struct netlink_callback *cb)
+			       struct netlink_callback *cb,
+			       const struct nlattr *bc)
 {
 	struct inet_diag_entry entry;
 	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt;
-	const struct nlattr *bc = NULL;
 	struct inet_sock *inet = inet_sk(sk);
 	int j, s_j;
 	int reqnum, s_reqnum;
@@ -642,9 +638,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 	if (!lopt || !lopt->qlen)
 		goto out;
 
-	if (nlmsg_attrlen(cb->nlh, sizeof(*r))) {
-		bc = nlmsg_find_attr(cb->nlh, sizeof(*r),
-				     INET_DIAG_REQ_BYTECODE);
+	if (bc != NULL) {
 		entry.sport = inet->inet_num;
 		entry.userlocks = sk->sk_userlocks;
 	}
@@ -708,6 +702,10 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
 	const struct inet_diag_handler *handler;
 	struct inet_hashinfo *hashinfo;
+	const struct nlattr *bc = NULL;
+
+	if (nlmsg_attrlen(cb->nlh, sizeof(struct inet_diag_req)))
+		bc = nlmsg_find_attr(cb->nlh, sizeof(*r), INET_DIAG_REQ_BYTECODE);
 
 	handler = inet_diag_lock_handler(cb->nlh->nlmsg_type);
 	if (IS_ERR(handler))
@@ -747,7 +745,7 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 				    cb->args[3] > 0)
 					goto syn_recv;
 
-				if (inet_csk_diag_dump(sk, skb, cb) < 0) {
+				if (inet_csk_diag_dump(sk, skb, cb, bc) < 0) {
 					spin_unlock_bh(&ilb->lock);
 					goto done;
 				}
@@ -756,7 +754,7 @@ syn_recv:
 				if (!(r->idiag_states & TCPF_SYN_RECV))
 					goto next_listen;
 
-				if (inet_diag_dump_reqs(skb, sk, cb) < 0) {
+				if (inet_diag_dump_reqs(skb, sk, cb, bc) < 0) {
 					spin_unlock_bh(&ilb->lock);
 					goto done;
 				}
@@ -809,7 +807,7 @@ skip_listen_ht:
 			if (r->id.idiag_dport != inet->inet_dport &&
 			    r->id.idiag_dport)
 				goto next_normal;
-			if (inet_csk_diag_dump(sk, skb, cb) < 0) {
+			if (inet_csk_diag_dump(sk, skb, cb, bc) < 0) {
 				spin_unlock_bh(lock);
 				goto done;
 			}
@@ -831,7 +829,7 @@ next_normal:
 				if (r->id.idiag_dport != tw->tw_dport &&
 				    r->id.idiag_dport)
 					goto next_dying;
-				if (inet_twsk_diag_dump(tw, skb, cb) < 0) {
+				if (inet_twsk_diag_dump(tw, skb, cb, bc) < 0) {
 					spin_unlock_bh(lock);
 					goto done;
 				}
-- 
1.5.5.6
