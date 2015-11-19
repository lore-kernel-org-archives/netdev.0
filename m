From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 05/15] net: Eliminate NETIF_F_GEN_CSUM and NETIF_F_V[46]_CSUM
Date: Thu, 19 Nov 2015 11:55:51 -0800
Message-ID: <1447962961-2106059-6-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47051 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759106AbbKST4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:15 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJJrBQs032543
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:15 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y8rtt6nby-5
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:15 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 970f3e9e8ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:14 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These netif flags are unnecessary convolutions. It is more
straightforward to just use NETIF_F_HW_CSUM, NETIF_F_IP_CSUM,
and NETIF_F_IPV6_CSUM directly.

This patch also:
    - Cleans up can_checksum_protocol
    - Simplifies netdev_intersect_features

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/sfc/efx.c           |  2 +-
 drivers/net/macvlan.c                    |  2 +-
 include/linux/if_vlan.h                  |  2 +-
 include/linux/netdev_features.h          |  9 +++----
 include/linux/netdevice.h                | 40 ++++++++++++++++++++------------
 net/core/dev.c                           | 12 +++++-----
 net/core/pktgen.c                        |  4 ++--
 net/ipv4/ip_output.c                     |  2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c |  3 ++-
 net/ipv4/udp.c                           |  3 ++-
 net/ipv4/udp_offload.c                   |  5 ++--
 net/ipv6/ip6_output.c                    |  2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c |  3 ++-
 13 files changed, 50 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 78aaca2..a544948 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3122,7 +3122,7 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
 			      NETIF_F_HIGHDMA | NETIF_F_TSO |
 			      NETIF_F_RXCSUM);
-	if (efx->type->offload_features & NETIF_F_V6_CSUM)
+	if (efx->type->offload_features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
 		net_dev->features |= NETIF_F_TSO6;
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index ae3b486..6a57a00 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -758,7 +758,7 @@ static struct lock_class_key macvlan_netdev_xmit_lock_key;
 static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define ALWAYS_ON_FEATURES \
-	(NETIF_F_SG | NETIF_F_GEN_CSUM | NETIF_F_GSO_SOFTWARE | NETIF_F_LLTX | \
+	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE | NETIF_F_LLTX | \
 	 NETIF_F_GSO_ROBUST)
 
 #define MACVLAN_FEATURES \
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 67ce5bd..ad599c4 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -621,7 +621,7 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
 						     NETIF_F_SG |
 						     NETIF_F_HIGHDMA |
 						     NETIF_F_FRAGLIST |
-						     NETIF_F_GEN_CSUM |
+						     NETIF_F_HW_CSUM |
 						     NETIF_F_HW_VLAN_CTAG_TX |
 						     NETIF_F_HW_VLAN_STAG_TX);
 
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 2c4e94a..d9654f0e 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -146,15 +146,12 @@ enum {
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
 				 NETIF_F_TSO6 | NETIF_F_UFO)
 
-#define NETIF_F_GEN_CSUM	NETIF_F_HW_CSUM
-#define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
-#define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
-
-/* List of IP checksum features. Note that NETIF_HW_CSUM should not be
+/* List of IP checksum features. Note that NETIF_F_ HW_CSUM should not be
  * set in features when NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM are set--
  * this would be contradictory
  */
-#define NETIF_F_CSUM_MASK	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
+#define NETIF_F_CSUM_MASK	(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | \
+				 NETIF_F_HW_CSUM)
 
 #define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index aecab79..52b41c8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3660,13 +3660,24 @@ __be16 skb_network_protocol(struct sk_buff *skb, int *depth);
 static inline bool can_checksum_protocol(netdev_features_t features,
 					 __be16 protocol)
 {
-	return ((features & NETIF_F_GEN_CSUM) ||
-		((features & NETIF_F_V4_CSUM) &&
-		 protocol == htons(ETH_P_IP)) ||
-		((features & NETIF_F_V6_CSUM) &&
-		 protocol == htons(ETH_P_IPV6)) ||
-		((features & NETIF_F_FCOE_CRC) &&
-		 protocol == htons(ETH_P_FCOE)));
+	if (protocol == htons(ETH_P_FCOE))
+		return !!(features & NETIF_F_FCOE_CRC);
+
+	/* Assume this is an IP checksum (not SCTP CRC) */
+
+	if (features & NETIF_F_HW_CSUM) {
+		/* Can checksum everything */
+		return true;
+	}
+
+	switch (protocol) {
+	case htons(ETH_P_IP):
+		return !!(features & NETIF_F_IP_CSUM);
+	case htons(ETH_P_IPV6):
+		return !!(features & NETIF_F_IPV6_CSUM);
+	default:
+		return false;
+	}
 }
 
 #ifdef CONFIG_BUG
@@ -3731,15 +3742,14 @@ void linkwatch_run_queue(void);
 static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
 							  netdev_features_t f2)
 {
-	if (f1 & NETIF_F_GEN_CSUM)
-		f1 |= (NETIF_F_CSUM_MASK & ~NETIF_F_GEN_CSUM);
-	if (f2 & NETIF_F_GEN_CSUM)
-		f2 |= (NETIF_F_CSUM_MASK & ~NETIF_F_GEN_CSUM);
-	f1 &= f2;
-	if (f1 & NETIF_F_GEN_CSUM)
-		f1 &= ~(NETIF_F_CSUM_MASK & ~NETIF_F_GEN_CSUM);
+	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
+		if (f1 & NETIF_F_HW_CSUM)
+			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IP_CSUM);
+		else
+			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IP_CSUM);
+	}
 
-	return f1;
+	return f1 & f2;
 }
 
 static inline netdev_features_t netdev_get_wanted_features(
diff --git a/net/core/dev.c b/net/core/dev.c
index 1aa9030..65784f0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6443,9 +6443,9 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 	/* UFO needs SG and checksumming */
 	if (features & NETIF_F_UFO) {
 		/* maybe split UFO into V4 and V6? */
-		if (!((features & NETIF_F_GEN_CSUM) ||
-		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
-			    == (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
+		if (!(features & NETIF_F_HW_CSUM) &&
+		    ((features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)) !=
+		     (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))) {
 			netdev_dbg(dev,
 				"Dropping NETIF_F_UFO since no checksum offload features.\n");
 			features &= ~NETIF_F_UFO;
@@ -7547,7 +7547,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 netdev_features_t netdev_increment_features(netdev_features_t all,
 	netdev_features_t one, netdev_features_t mask)
 {
-	if (mask & NETIF_F_GEN_CSUM)
+	if (mask & NETIF_F_HW_CSUM)
 		mask |= NETIF_F_CSUM_MASK;
 	mask |= NETIF_F_VLAN_CHALLENGED;
 
@@ -7555,8 +7555,8 @@ netdev_features_t netdev_increment_features(netdev_features_t all,
 	all &= one | ~NETIF_F_ALL_FOR_ALL;
 
 	/* If one device supports hw checksumming, set for all. */
-	if (all & NETIF_F_GEN_CSUM)
-		all &= ~(NETIF_F_CSUM_MASK & ~NETIF_F_GEN_CSUM);
+	if (all & NETIF_F_HW_CSUM)
+		all &= ~(NETIF_F_CSUM_MASK & ~NETIF_F_HW_CSUM);
 
 	return all;
 }
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index de8d5cc..2be1444 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2898,7 +2898,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	if (!(pkt_dev->flags & F_UDPCSUM)) {
 		skb->ip_summed = CHECKSUM_NONE;
-	} else if (odev->features & NETIF_F_V4_CSUM) {
+	} else if (odev->features & (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM)) {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 		udp4_hwcsum(skb, iph->saddr, iph->daddr);
@@ -3032,7 +3032,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 
 	if (!(pkt_dev->flags & F_UDPCSUM)) {
 		skb->ip_summed = CHECKSUM_NONE;
-	} else if (odev->features & NETIF_F_V6_CSUM) {
+	} else if (odev->features & (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM)) {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4233cbe..8432d50 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -912,7 +912,7 @@ static int __ip_append_data(struct sock *sk,
 	 */
 	if (transhdrlen &&
 	    length + fragheaderlen <= mtu &&
-	    rt->dst.dev->features & NETIF_F_V4_CSUM &&
+	    rt->dst.dev->features & (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM) &&
 	    !(flags & MSG_MORE) &&
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index 5075b7e..61c7cc2 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -132,7 +132,8 @@ static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    (!skb->dev || skb->dev->features & NETIF_F_V4_CSUM)) {
+		    (!skb->dev || skb->dev->features &
+		     (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_start = skb_headroom(skb) +
 					  skb_network_offset(skb) +
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 24ec14f..4efb85f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -773,7 +773,8 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
 	else if (skb_is_gso(skb))
 		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
 	else if (skb_dst(skb) && skb_dst(skb)->dev &&
-		 (skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {
+		 (skb_dst(skb)->dev->features &
+		  (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
 
 		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
 
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index f938616..1300426 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -60,8 +60,9 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 
 	/* Try to offload checksum if possible */
 	offload_csum = !!(need_csum &&
-			  (skb->dev->features &
-			   (is_ipv6 ? NETIF_F_V6_CSUM : NETIF_F_V4_CSUM)));
+			  ((skb->dev->features & NETIF_F_HW_CSUM) ||
+			   (skb->dev->features & (is_ipv6 ?
+			    NETIF_F_IPV6_CSUM : NETIF_F_IP_CSUM))));
 
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & features;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e6a7bd15..2f74845 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1322,7 +1322,7 @@ emsgsize:
 	    headersize == sizeof(struct ipv6hdr) &&
 	    length < mtu - headersize &&
 	    !(flags & MSG_MORE) &&
-	    rt->dst.dev->features & NETIF_F_V6_CSUM)
+	    rt->dst.dev->features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
 		csummode = CHECKSUM_PARTIAL;
 
 	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW) {
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index 238e70c..6ce3099 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -136,7 +136,8 @@ static void nf_nat_ipv6_csum_recalc(struct sk_buff *skb,
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		if (!(rt->rt6i_flags & RTF_LOCAL) &&
-		    (!skb->dev || skb->dev->features & NETIF_F_V6_CSUM)) {
+		    (!skb->dev || skb->dev->features &
+		     (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))) {
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_start = skb_headroom(skb) +
 					  skb_network_offset(skb) +
-- 
2.4.6
