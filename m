From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v3 3/7] sk_buff: remove support for csum_bad in sk_buff
Date: Fri,  7 Apr 2017 16:16:06 +0200
Message-ID: <dcfac1c1e26ae19db4072bf1fa4a201af1632ebb.1491562390.git.dcaratti@redhat.com>
References: <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56496 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933627AbdDGOQf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 10:16:35 -0400
In-Reply-To: <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
In-Reply-To: <cover.1491562390.git.dcaratti@redhat.com>
References: <cover.1491562390.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bit was introduced with 5a21232983aa ("net: Support for csum_bad in
skbuff") to reduce the stack workload when processing RX packets carrying
a wrong Internet Checksum. Up to now, only one driver (besides GRO core)
are setting it.
The test on NAPI_GRO_CB(skb)->flush in dev_gro_receive() is now done
before the test on same_flow, to preserve behavior in case of wrong
checksum.

Suggested-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c |  2 +-
 include/linux/netdevice.h                        |  4 +---
 include/linux/skbuff.h                           | 23 ++---------------------
 net/bridge/netfilter/nft_reject_bridge.c         |  5 +----
 net/core/dev.c                                   |  8 +++-----
 net/ipv4/netfilter/nf_reject_ipv4.c              |  2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c              |  3 ---
 7 files changed, 9 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 0358e607..ec5579f 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -222,7 +222,7 @@ int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
 		skb->protocol = eth_type_trans(skb, ndev);
 		if (unlikely(buff->is_cso_err)) {
 			++self->stats.rx.errors;
-			__skb_mark_checksum_bad(skb);
+			skb->ip_summed = CHECKSUM_NONE;
 		} else {
 			if (buff->is_ip_cso) {
 				__skb_incr_checksum_unnecessary(skb);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e86b50e..960f6ab 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2547,9 +2547,7 @@ static inline void skb_gro_incr_csum_unnecessary(struct sk_buff *skb)
 	if (__skb_gro_checksum_validate_needed(skb, zero_okay, check))	\
 		__ret = __skb_gro_checksum_validate_complete(skb,	\
 				compute_pseudo(skb, proto));		\
-	if (__ret)							\
-		__skb_mark_checksum_bad(skb);				\
-	else								\
+	if (!__ret)							\
 		skb_gro_incr_csum_unnecessary(skb);			\
 	__ret;								\
 })
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d18b31d..aaf1072 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -742,7 +742,7 @@ struct sk_buff {
 	__u8			csum_valid:1;
 	__u8			csum_complete_sw:1;
 	__u8			csum_level:2;
-	__u8			csum_bad:1;
+	__u8			__unused:1; /* one bit hole */
 
 	__u8			dst_pending_confirm:1;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
@@ -3386,21 +3386,6 @@ static inline void __skb_incr_checksum_unnecessary(struct sk_buff *skb)
 	}
 }
 
-static inline void __skb_mark_checksum_bad(struct sk_buff *skb)
-{
-	/* Mark current checksum as bad (typically called from GRO
-	 * path). In the case that ip_summed is CHECKSUM_NONE
-	 * this must be the first checksum encountered in the packet.
-	 * When ip_summed is CHECKSUM_UNNECESSARY, this is the first
-	 * checksum after the last one validated. For UDP, a zero
-	 * checksum can not be marked as bad.
-	 */
-
-	if (skb->ip_summed == CHECKSUM_NONE ||
-	    skb->ip_summed == CHECKSUM_UNNECESSARY)
-		skb->csum_bad = 1;
-}
-
 /* Check if we need to perform checksum complete validation.
  *
  * Returns true if checksum complete is needed, false otherwise
@@ -3454,9 +3439,6 @@ static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
 			skb->csum_valid = 1;
 			return 0;
 		}
-	} else if (skb->csum_bad) {
-		/* ip_summed == CHECKSUM_NONE in this case */
-		return (__force __sum16)1;
 	}
 
 	skb->csum = psum;
@@ -3516,8 +3498,7 @@ static inline __wsum null_compute_pseudo(struct sk_buff *skb, int proto)
 
 static inline bool __skb_checksum_convert_check(struct sk_buff *skb)
 {
-	return (skb->ip_summed == CHECKSUM_NONE &&
-		skb->csum_valid && !skb->csum_bad);
+	return (skb->ip_summed == CHECKSUM_NONE && skb->csum_valid);
 }
 
 static inline void __skb_checksum_convert(struct sk_buff *skb,
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 346ef6b..c16dd3a 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -111,7 +111,7 @@ static void nft_reject_br_send_v4_unreach(struct net *net,
 	__wsum csum;
 	u8 proto;
 
-	if (oldskb->csum_bad || !nft_bridge_iphdr_validate(oldskb))
+	if (!nft_bridge_iphdr_validate(oldskb))
 		return;
 
 	/* IP header checks: fragment. */
@@ -226,9 +226,6 @@ static bool reject6_br_csum_ok(struct sk_buff *skb, int hook)
 	__be16 fo;
 	u8 proto = ip6h->nexthdr;
 
-	if (skb->csum_bad)
-		return false;
-
 	if (skb_csum_unnecessary(skb))
 		return true;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 7d59cba..91ba01a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4533,9 +4533,6 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
 
-	if (skb->csum_bad)
-		goto normal;
-
 	gro_list_prepare(napi, skb);
 
 	rcu_read_lock();
@@ -4595,11 +4592,12 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		napi->gro_count--;
 	}
 
+	if (NAPI_GRO_CB(skb)->flush)
+		goto normal;
+
 	if (same_flow)
 		goto ok;
 
-	if (NAPI_GRO_CB(skb)->flush)
-		goto normal;
 
 	if (unlikely(napi->gro_count >= MAX_GRO_SKBS)) {
 		struct sk_buff *nskb = napi->gro_list;
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 7cd8d0d..6f8d9e5 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -172,7 +172,7 @@ void nf_send_unreach(struct sk_buff *skb_in, int code, int hook)
 	struct iphdr *iph = ip_hdr(skb_in);
 	u8 proto;
 
-	if (skb_in->csum_bad || iph->frag_off & htons(IP_OFFSET))
+	if (iph->frag_off & htons(IP_OFFSET))
 		return;
 
 	if (skb_csum_unnecessary(skb_in)) {
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index eedee5d..f63b18e 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -220,9 +220,6 @@ static bool reject6_csum_ok(struct sk_buff *skb, int hook)
 	__be16 fo;
 	u8 proto;
 
-	if (skb->csum_bad)
-		return false;
-
 	if (skb_csum_unnecessary(skb))
 		return true;
 
-- 
2.7.4
