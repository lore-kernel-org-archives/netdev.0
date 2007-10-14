From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/10] [IPV4]: Change ip_defrag to return an integer
Date: Sun, 14 Oct 2007 12:27:42 +0800
Message-ID: <E1Igv4o-00030U-00@gondolin.me.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1411 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751692AbXJNE2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:28:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Change ip_defrag to return an integer

Now that ip_frag always returns the packet given to it on input, we can
change it to return an integer indicating error instead.  This patch does
that and updates all its callers accordingly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/ip.h                               |    2 -
 net/ipv4/ip_fragment.c                         |    6 ++---
 net/ipv4/ip_input.c                            |    6 +----
 net/ipv4/ipvs/ip_vs_core.c                     |   26 +++++++++----------------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   20 +++++++++----------
 5 files changed, 26 insertions(+), 34 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 3af3ed9..875c5ed 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -332,7 +332,7 @@ enum ip_defrag_users
 	IP_DEFRAG_VS_FWD
 };
 
-struct sk_buff *ip_defrag(struct sk_buff *skb, u32 user);
+int ip_defrag(struct sk_buff *skb, u32 user);
 extern int ip_frag_nqueues;
 extern atomic_t ip_frag_mem;
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index d7fa2bf..32108cf 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -739,7 +739,7 @@ out_fail:
 }
 
 /* Process an incoming IP datagram fragment. */
-struct sk_buff *ip_defrag(struct sk_buff *skb, u32 user)
+int ip_defrag(struct sk_buff *skb, u32 user)
 {
 	struct ipq *qp;
 
@@ -759,12 +759,12 @@ struct sk_buff *ip_defrag(struct sk_buff *skb, u32 user)
 
 		spin_unlock(&qp->lock);
 		ipq_put(qp, NULL);
-		return ret ? NULL : skb;
+		return ret;
 	}
 
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
-	return NULL;
+	return -ENOMEM;
 }
 
 void __init ipfrag_init(void)
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 41d8964..8f75e43 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -172,8 +172,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == skb->dev->ifindex)) {
 			if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-				skb = ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN);
-				if (skb == NULL) {
+				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN)) {
 					read_unlock(&ip_ra_lock);
 					return 1;
 				}
@@ -265,8 +264,7 @@ int ip_local_deliver(struct sk_buff *skb)
 	 */
 
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		skb = ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER);
-		if (!skb)
+		if (ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER))
 			return 0;
 	}
 
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index fbca2a2..3487337 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -541,13 +541,14 @@ __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
 }
 
-static inline struct sk_buff *
-ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
+static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 {
-	skb = ip_defrag(skb, user);
-	if (skb)
+	int err = ip_defrag(skb, user);
+
+	if (!err)
 		ip_send_check(ip_hdr(skb));
-	return skb;
+
+	return err;
 }
 
 /*
@@ -619,10 +620,8 @@ static int ip_vs_out_icmp(struct sk_buff **pskb, int *related)
 
 	/* reassemble IP fragments */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		skb = ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT);
-		if (!skb)
+		if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
 			return NF_STOLEN;
-		*pskb = skb;
 	}
 
 	iph = ip_hdr(skb);
@@ -756,11 +755,9 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
 	/* reassemble IP fragments */
 	if (unlikely(iph->frag_off & htons(IP_MF|IP_OFFSET) &&
 		     !pp->dont_defrag)) {
-		skb = ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT);
-		if (!skb)
+		if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
 			return NF_STOLEN;
 		iph = ip_hdr(skb);
-		*pskb = skb;
 	}
 
 	ihl = iph->ihl << 2;
@@ -861,12 +858,9 @@ ip_vs_in_icmp(struct sk_buff **pskb, int *related, unsigned int hooknum)
 
 	/* reassemble IP fragments */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		skb = ip_vs_gather_frags(skb,
-					 hooknum == NF_IP_LOCAL_IN ?
-					 IP_DEFRAG_VS_IN : IP_DEFRAG_VS_FWD);
-		if (!skb)
+		if (ip_vs_gather_frags(skb, hooknum == NF_IP_LOCAL_IN ?
+					    IP_DEFRAG_VS_IN : IP_DEFRAG_VS_FWD))
 			return NF_STOLEN;
-		*pskb = skb;
 	}
 
 	iph = ip_hdr(skb);
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 2fcb924..48fdd9e 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -63,19 +63,20 @@ static int ipv4_print_conntrack(struct seq_file *s,
 }
 
 /* Returns new sk_buff, or NULL */
-static struct sk_buff *
-nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
+static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
 {
+	int err;
+
 	skb_orphan(skb);
 
 	local_bh_disable();
-	skb = ip_defrag(skb, user);
+	err = ip_defrag(skb, user);
 	local_bh_enable();
 
-	if (skb)
+	if (!err)
 		ip_send_check(ip_hdr(skb));
 
-	return skb;
+	return err;
 }
 
 static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
@@ -148,11 +149,10 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 
 	/* Gather fragments. */
 	if (ip_hdr(*pskb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		*pskb = nf_ct_ipv4_gather_frags(*pskb,
-						hooknum == NF_IP_PRE_ROUTING ?
-						IP_DEFRAG_CONNTRACK_IN :
-						IP_DEFRAG_CONNTRACK_OUT);
-		if (!*pskb)
+		if (nf_ct_ipv4_gather_frags(*pskb,
+					    hooknum == NF_IP_PRE_ROUTING ?
+					    IP_DEFRAG_CONNTRACK_IN :
+					    IP_DEFRAG_CONNTRACK_OUT))
 			return NF_STOLEN;
 	}
 	return NF_ACCEPT;
