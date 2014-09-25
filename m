From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 2/3] ipv6: add a struct inet6_skb_parm param to ipv6_opt_accepted()
Date: Thu, 25 Sep 2014 13:14:51 -0700
Message-ID: <1411676092-16196-3-git-send-email-edumazet@google.com>
References: <1411676092-16196-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:58990 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbaIYUPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 16:15:01 -0400
Received: by mail-ie0-f201.google.com with SMTP id rd18so1714723iec.2
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 13:15:01 -0700 (PDT)
In-Reply-To: <1411676092-16196-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_opt_accepted() assumes IP6CB(skb) holds the struct inet6_skb_parm
that it needs. Lets not assume this, as TCP stack might use a different
place.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h    | 3 ++-
 net/dccp/ipv6.c       | 2 +-
 net/ipv6/af_inet6.c   | 4 ++--
 net/ipv6/syncookies.c | 2 +-
 net/ipv6/tcp_ipv6.c   | 5 +++--
 5 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7e247e9b8765..97f472012438 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -288,7 +288,8 @@ struct ipv6_txoptions *ipv6_renew_options(struct sock *sk,
 struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 					  struct ipv6_txoptions *opt);
 
-bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb);
+bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb,
+		       const struct inet6_skb_parm *opt);
 
 static inline bool ipv6_accept_ra(struct inet6_dev *idev)
 {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 04cb17d4b0ce..ad2acfe1ca61 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -404,7 +404,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 
-	if (ipv6_opt_accepted(sk, skb) ||
+	if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
 		atomic_inc(&skb->users);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e4865a3ebe1d..34f726f59814 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -672,10 +672,10 @@ int inet6_sk_rebuild_header(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(inet6_sk_rebuild_header);
 
-bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb)
+bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb,
+		       const struct inet6_skb_parm *opt)
 {
 	const struct ipv6_pinfo *np = inet6_sk(sk);
-	const struct inet6_skb_parm *opt = IP6CB(skb);
 
 	if (np->rxopt.all) {
 		if ((opt->hop && (np->rxopt.bits.hopopts ||
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index c643dc907ce7..9a2838e93cc5 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -203,7 +203,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_num = ntohs(th->dest);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
-	if (ipv6_opt_accepted(sk, skb) ||
+	if (ipv6_opt_accepted(sk, skb, &TCP_SKB_CB(skb)->header.h6) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
 		atomic_inc(&skb->users);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index de51a88bec6f..9400b4326f22 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -742,7 +742,8 @@ static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
 		ireq->ir_iif = inet6_iif(skb);
 
 	if (!TCP_SKB_CB(skb)->tcp_tw_isn &&
-	    (ipv6_opt_accepted(sk, skb) || np->rxopt.bits.rxinfo ||
+	    (ipv6_opt_accepted(sk, skb, &TCP_SKB_CB(skb)->header.h6) ||
+	     np->rxopt.bits.rxinfo ||
 	     np->rxopt.bits.rxoinfo || np->rxopt.bits.rxhlim ||
 	     np->rxopt.bits.rxohlim || np->repflow)) {
 		atomic_inc(&skb->users);
@@ -1367,7 +1368,7 @@ ipv6_pktoptions:
 			np->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(opt_skb));
 		if (np->repflow)
 			np->flow_label = ip6_flowlabel(ipv6_hdr(opt_skb));
-		if (ipv6_opt_accepted(sk, opt_skb)) {
+		if (ipv6_opt_accepted(sk, opt_skb, &TCP_SKB_CB(opt_skb)->header.h6)) {
 			skb_set_owner_r(opt_skb, sk);
 			opt_skb = xchg(&np->pktoptions, opt_skb);
 		} else {
-- 
2.1.0.rc2.206.gedb03e5
