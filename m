From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 08/15] ehea: Simplify ehea_xmit2 and ehea_xmit3
Date: Thu, 12 May 2011 10:52:21 +1000
Message-ID: <20110512005623.193505368@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39816 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418Ab1ELB2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:28:00 -0400
Content-Disposition: inline; filename=ehea_11.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch from Michael Ellerman, clean up a significant
portion of the transmit path. There was a lot of duplication here.
Even worse, we were always checksumming tx packets and ignoring the
skb->ip_summed field.

Also remove NETIF_F_FRAGLIST from dev->features, I'm not sure why
it was enabled.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:55.870215448 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:58.020249537 +1000
@@ -1677,37 +1677,6 @@ static int ehea_clean_portres(struct ehe
 	return ret;
 }
 
-/*
- * The write_* functions store information in swqe which is used by
- * the hardware to calculate the ip/tcp/udp checksum
- */
-
-static inline void write_ip_start_end(struct ehea_swqe *swqe,
-				      const struct sk_buff *skb)
-{
-	swqe->ip_start = skb_network_offset(skb);
-	swqe->ip_end = (u8)(swqe->ip_start + ip_hdrlen(skb) - 1);
-}
-
-static inline void write_tcp_offset_end(struct ehea_swqe *swqe,
-					const struct sk_buff *skb)
-{
-	swqe->tcp_offset =
-		(u8)(swqe->ip_end + 1 + offsetof(struct tcphdr, check));
-
-	swqe->tcp_end = (u16)skb->len - 1;
-}
-
-static inline void write_udp_offset_end(struct ehea_swqe *swqe,
-					const struct sk_buff *skb)
-{
-	swqe->tcp_offset =
-		(u8)(swqe->ip_end + 1 + offsetof(struct udphdr, check));
-
-	swqe->tcp_end = (u16)skb->len - 1;
-}
-
-
 static void write_swqe2_TSO(struct sk_buff *skb,
 			    struct ehea_swqe *swqe, u32 lkey)
 {
@@ -2109,41 +2078,46 @@ static int ehea_change_mtu(struct net_de
 	return 0;
 }
 
-static void ehea_xmit2(struct sk_buff *skb, struct net_device *dev,
-		       struct ehea_swqe *swqe, u32 lkey)
+static void xmit_common(struct sk_buff *skb, struct ehea_swqe *swqe)
 {
-	if (skb->protocol == htons(ETH_P_IP)) {
-		const struct iphdr *iph = ip_hdr(skb);
+	swqe->tx_control |= EHEA_SWQE_IMM_DATA_PRESENT | EHEA_SWQE_CRC;
 
-		/* IPv4 */
-		swqe->tx_control |= EHEA_SWQE_CRC
-				 | EHEA_SWQE_IP_CHECKSUM
-				 | EHEA_SWQE_TCP_CHECKSUM
-				 | EHEA_SWQE_IMM_DATA_PRESENT
-				 | EHEA_SWQE_DESCRIPTORS_PRESENT;
-
-		write_ip_start_end(swqe, skb);
-
-		if (iph->protocol == IPPROTO_UDP) {
-			if ((iph->frag_off & IP_MF) ||
-			    (iph->frag_off & IP_OFFSET))
-				/* IP fragment, so don't change cs */
-				swqe->tx_control &= ~EHEA_SWQE_TCP_CHECKSUM;
-			else
-				write_udp_offset_end(swqe, skb);
-		} else if (iph->protocol == IPPROTO_TCP) {
-			write_tcp_offset_end(swqe, skb);
-		}
+	if (skb->protocol != htons(ETH_P_IP))
+		return;
 
-		/* icmp (big data) and ip segmentation packets (all other ip
-		   packets) do not require any special handling */
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		swqe->tx_control |= EHEA_SWQE_IP_CHECKSUM;
 
-	} else {
-		/* Other Ethernet Protocol */
-		swqe->tx_control |= EHEA_SWQE_CRC
-				 | EHEA_SWQE_IMM_DATA_PRESENT
-				 | EHEA_SWQE_DESCRIPTORS_PRESENT;
+	swqe->ip_start = skb_network_offset(skb);
+	swqe->ip_end = swqe->ip_start + ip_hdrlen(skb) - 1;
+
+	switch (ip_hdr(skb)->protocol) {
+	case IPPROTO_UDP:
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			swqe->tx_control |= EHEA_SWQE_TCP_CHECKSUM;
+
+		swqe->tcp_offset = swqe->ip_end + 1 +
+				   offsetof(struct udphdr, check);
+		swqe->tcp_end = skb->len - 1;
+		break;
+
+	case IPPROTO_TCP:
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			swqe->tx_control |= EHEA_SWQE_TCP_CHECKSUM;
+
+		swqe->tcp_offset = swqe->ip_end + 1 +
+				   offsetof(struct tcphdr, check);
+		swqe->tcp_end = skb->len - 1;
+		break;
 	}
+}
+
+static void ehea_xmit2(struct sk_buff *skb, struct net_device *dev,
+		       struct ehea_swqe *swqe, u32 lkey)
+{
+	swqe->tx_control |= EHEA_SWQE_DESCRIPTORS_PRESENT;
+
+	xmit_common(skb, swqe);
 
 	write_swqe2_data(skb, dev, swqe, lkey);
 }
@@ -2156,51 +2130,11 @@ static void ehea_xmit3(struct sk_buff *s
 	skb_frag_t *frag;
 	int i;
 
-	if (skb->protocol == htons(ETH_P_IP)) {
-		const struct iphdr *iph = ip_hdr(skb);
-
-		/* IPv4 */
-		write_ip_start_end(swqe, skb);
+	xmit_common(skb, swqe);
 
-		if (iph->protocol == IPPROTO_TCP) {
-			swqe->tx_control |= EHEA_SWQE_CRC
-					 | EHEA_SWQE_IP_CHECKSUM
-					 | EHEA_SWQE_TCP_CHECKSUM
-					 | EHEA_SWQE_IMM_DATA_PRESENT;
-
-			write_tcp_offset_end(swqe, skb);
-
-		} else if (iph->protocol == IPPROTO_UDP) {
-			if ((iph->frag_off & IP_MF) ||
-			    (iph->frag_off & IP_OFFSET))
-				/* IP fragment, so don't change cs */
-				swqe->tx_control |= EHEA_SWQE_CRC
-						 | EHEA_SWQE_IMM_DATA_PRESENT;
-			else {
-				swqe->tx_control |= EHEA_SWQE_CRC
-						 | EHEA_SWQE_IP_CHECKSUM
-						 | EHEA_SWQE_TCP_CHECKSUM
-						 | EHEA_SWQE_IMM_DATA_PRESENT;
-
-				write_udp_offset_end(swqe, skb);
-			}
-		} else {
-			/* icmp (big data) and
-			   ip segmentation packets (all other ip packets) */
-			swqe->tx_control |= EHEA_SWQE_CRC
-					 | EHEA_SWQE_IP_CHECKSUM
-					 | EHEA_SWQE_IMM_DATA_PRESENT;
-		}
-	} else {
-		/* Other Ethernet Protocol */
-		swqe->tx_control |= EHEA_SWQE_CRC | EHEA_SWQE_IMM_DATA_PRESENT;
-	}
-	/* copy (immediate) data */
 	if (nfrags == 0) {
-		/* data is in a single piece */
 		skb_copy_from_linear_data(skb, imm_data, skb->len);
 	} else {
-		/* first copy data from the skb->data buffer ... */
 		skb_copy_from_linear_data(skb, imm_data,
 					  skb_headlen(skb));
 		imm_data += skb_headlen(skb);
@@ -2214,6 +2148,7 @@ static void ehea_xmit3(struct sk_buff *s
 			imm_data += frag->size;
 		}
 	}
+
 	swqe->immediate_data_length = skb->len;
 	dev_kfree_skb(skb);
 }
@@ -3217,7 +3152,7 @@ struct ehea_port *ehea_setup_single_port
 	dev->netdev_ops = &ehea_netdev_ops;
 	ehea_set_ethtool_ops(dev);
 
-	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
+	dev->hw_features = NETIF_F_SG | NETIF_F_TSO
 		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX | NETIF_F_LRO;
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX


