From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 5/6] ipv6: netfilter: comparison for inequality with NULL
Date: Sat, 25 Apr 2015 10:26:59 +0100
Message-ID: <1429954020-11763-6-git-send-email-ipm@chirality.org.uk>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36727 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758805AbbDYJ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 05:27:10 -0400
In-Reply-To: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code uses a mixture of coding styles. In some instances check for NULL
pointer is done as x != NULL and sometimes as x. x is preferred
according to checkpatch and this patch makes the code consistent by
adopting the latter form.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c         |  4 ++--
 net/ipv6/netfilter/ip6t_REJECT.c        |  2 +-
 net/ipv6/netfilter/ip6t_ah.c            | 16 ++++++++--------
 net/ipv6/netfilter/ip6t_frag.c          | 24 ++++++++++++------------
 net/ipv6/netfilter/ip6t_hbh.c           |  7 +++----
 net/ipv6/netfilter/nf_conntrack_reasm.c |  2 +-
 net/ipv6/netfilter/nf_log_ipv6.c        |  4 ++--
 net/ipv6/netfilter/nft_reject_ipv6.c    |  2 +-
 8 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index ce8c529..ed3612d 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -570,7 +570,7 @@ static void cleanup_match(struct xt_entry_match *m, struct net *net)
 	par.match     = m->u.kernel.match;
 	par.matchinfo = m->data;
 	par.family    = NFPROTO_IPV6;
-	if (par.match->destroy != NULL)
+	if (par.match->destroy)
 		par.match->destroy(&par);
 	module_put(par.match->me);
 }
@@ -793,7 +793,7 @@ static void cleanup_entry(struct ip6t_entry *e, struct net *net)
 	par.target   = t->u.kernel.target;
 	par.targinfo = t->data;
 	par.family   = NFPROTO_IPV6;
-	if (par.target->destroy != NULL)
+	if (par.target->destroy)
 		par.target->destroy(&par);
 	module_put(par.target->me);
 }
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 12331ef..9003a99 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -40,7 +40,7 @@ static unsigned int
 reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ip6t_reject_info *reject = par->targinfo;
-	struct net *net = dev_net((par->in != NULL) ? par->in : par->out);
+	struct net *net = dev_net(par->in ? par->in : par->out);
 
 	pr_debug("%s: medium point\n", __func__);
 	switch (reject->with) {
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index e504376..490a4b1 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -77,14 +77,14 @@ static bool ah_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 		 ahinfo->hdrres, ah->reserved,
 		 !(ahinfo->hdrres && ah->reserved));
 
-	return (ah != NULL) &&
-		spi_match(ahinfo->spis[0], ahinfo->spis[1],
-			  ntohl(ah->spi),
-			  !!(ahinfo->invflags & IP6T_AH_INV_SPI)) &&
-		(!ahinfo->hdrlen ||
-		 (ahinfo->hdrlen == hdrlen) ^
-		 !!(ahinfo->invflags & IP6T_AH_INV_LEN)) &&
-		!(ahinfo->hdrres && ah->reserved);
+	return ah &&
+	       spi_match(ahinfo->spis[0], ahinfo->spis[1],
+			 ntohl(ah->spi),
+			 !!(ahinfo->invflags & IP6T_AH_INV_SPI)) &&
+	       (!ahinfo->hdrlen ||
+		(ahinfo->hdrlen == hdrlen) ^
+		!!(ahinfo->invflags & IP6T_AH_INV_LEN)) &&
+	       !(ahinfo->hdrres && ah->reserved);
 }
 
 static int ah_mt6_check(const struct xt_mtchk_param *par)
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index 0e14438..a67c2c2 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -88,18 +88,18 @@ frag_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 		 !((fraginfo->flags & IP6T_FRAG_NMF) &&
 		   (ntohs(fh->frag_off) & IP6_MF)));
 
-	return (fh != NULL) &&
-		id_match(fraginfo->ids[0], fraginfo->ids[1],
-			 ntohl(fh->identification),
-			 !!(fraginfo->invflags & IP6T_FRAG_INV_IDS)) &&
-		!((fraginfo->flags & IP6T_FRAG_RES) &&
-		  (fh->reserved || (ntohs(fh->frag_off) & 0x6))) &&
-		!((fraginfo->flags & IP6T_FRAG_FST) &&
-		  (ntohs(fh->frag_off) & ~0x7)) &&
-		!((fraginfo->flags & IP6T_FRAG_MF) &&
-		  !(ntohs(fh->frag_off) & IP6_MF)) &&
-		!((fraginfo->flags & IP6T_FRAG_NMF) &&
-		  (ntohs(fh->frag_off) & IP6_MF));
+	return fh &&
+	       id_match(fraginfo->ids[0], fraginfo->ids[1],
+			ntohl(fh->identification),
+			!!(fraginfo->invflags & IP6T_FRAG_INV_IDS)) &&
+	       !((fraginfo->flags & IP6T_FRAG_RES) &&
+		 (fh->reserved || (ntohs(fh->frag_off) & 0x6))) &&
+	       !((fraginfo->flags & IP6T_FRAG_FST) &&
+		 (ntohs(fh->frag_off) & ~0x7)) &&
+	       !((fraginfo->flags & IP6T_FRAG_MF) &&
+		 !(ntohs(fh->frag_off) & IP6_MF)) &&
+	       !((fraginfo->flags & IP6T_FRAG_NMF) &&
+		 (ntohs(fh->frag_off) & IP6_MF));
 }
 
 static int frag_mt6_check(const struct xt_mtchk_param *par)
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index fc6af64..a99313f 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -89,10 +89,9 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 		  ((optinfo->hdrlen == hdrlen) ^
 		   !!(optinfo->invflags & IP6T_OPTS_INV_LEN))));
 
-	ret = (oh != NULL) &&
-	      (!(optinfo->flags & IP6T_OPTS_LEN) ||
-	       ((optinfo->hdrlen == hdrlen) ^
-		!!(optinfo->invflags & IP6T_OPTS_INV_LEN)));
+	ret = oh && (!(optinfo->flags & IP6T_OPTS_LEN) ||
+		     ((optinfo->hdrlen == hdrlen) ^
+		      !!(optinfo->invflags & IP6T_OPTS_INV_LEN)));
 
 	ptr += 2;
 	hdrlen -= 2;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 51478de..0c6faf1 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -304,7 +304,7 @@ static int nf_ct_frag6_queue(struct frag_queue *fq, struct sk_buff *skb,
 		goto found;
 	}
 	prev = NULL;
-	for (next = fq->q.fragments; next != NULL; next = next->next) {
+	for (next = fq->q.fragments; next; next = next->next) {
 		if (NFCT_FRAG6_CB(next)->offset >= offset)
 			break;	/* bingo! */
 		prev = next;
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index 35166a2..de3eaf5 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -323,7 +323,7 @@ fallback:
 				p = NULL;
 		}
 
-		if (p != NULL) {
+		if (p) {
 			nf_log_buf_add(m, "%02x", *p++);
 			for (i = 1; i < len; i++)
 				nf_log_buf_add(m, ":%02x", *p++);
@@ -362,7 +362,7 @@ static void nf_log_ip6_packet(struct net *net, u_int8_t pf,
 	nf_log_dump_packet_common(m, pf, hooknum, skb, in, out,
 				  loginfo, prefix);
 
-	if (in != NULL)
+	if (in)
 		dump_ipv6_mac_header(m, loginfo, skb);
 
 	dump_ipv6_packet(m, loginfo, skb, skb_network_offset(skb), 1);
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
index d0d1540..d282995 100644
--- a/net/ipv6/netfilter/nft_reject_ipv6.c
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -24,7 +24,7 @@ static void nft_reject_ipv6_eval(const struct nft_expr *expr,
 				 const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
+	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
-- 
1.9.1
