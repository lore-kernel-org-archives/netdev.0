From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 08/15] ehea: Simplify ehea_xmit2 and ehea_xmit3
Date: Fri, 14 Oct 2011 12:31:05 -0300
Message-ID: <1318606272-27647-9-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:39546 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756934Ab1JNPb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:57 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 14 Oct 2011 12:31:51 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFUIXt3027122
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:30:18 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVYdi008731
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:34 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

Based on a patch from Michael Ellerman, clean up a significant
portion of the transmit path. There was a lot of duplication here.
Even worse, we were always checksumming tx packets and ignoring the
skb->ip_summed field.

Also remove NETIF_F_FRAGLIST from dev->features, I'm not sure why
it was enabled.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |  137 ++++++++---------------------
 1 files changed, 36 insertions(+), 101 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 1321809..77aafba 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1676,37 +1676,6 @@ static int ehea_clean_portres(struct ehea_port *port, struct ehea_port_res *pr)
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
@@ -2105,41 +2074,46 @@ static int ehea_change_mtu(struct net_device *dev, int new_mtu)
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
+	if (skb->protocol != htons(ETH_P_IP))
+		return;
 
-		write_ip_start_end(swqe, skb);
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		swqe->tx_control |= EHEA_SWQE_IP_CHECKSUM;
 
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
+	swqe->ip_start = skb_network_offset(skb);
+	swqe->ip_end = swqe->ip_start + ip_hdrlen(skb) - 1;
 
-		/* icmp (big data) and ip segmentation packets (all other ip
-		   packets) do not require any special handling */
+	switch (ip_hdr(skb)->protocol) {
+	case IPPROTO_UDP:
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			swqe->tx_control |= EHEA_SWQE_TCP_CHECKSUM;
 
-	} else {
-		/* Other Ethernet Protocol */
-		swqe->tx_control |= EHEA_SWQE_CRC
-				 | EHEA_SWQE_IMM_DATA_PRESENT
-				 | EHEA_SWQE_DESCRIPTORS_PRESENT;
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
@@ -2152,51 +2126,11 @@ static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 	skb_frag_t *frag;
 	int i;
 
-	if (skb->protocol == htons(ETH_P_IP)) {
-		const struct iphdr *iph = ip_hdr(skb);
+	xmit_common(skb, swqe);
 
-		/* IPv4 */
-		write_ip_start_end(swqe, skb);
-
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
@@ -2208,6 +2142,7 @@ static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 			imm_data += frag->size;
 		}
 	}
+
 	swqe->immediate_data_length = skb->len;
 	dev_kfree_skb(skb);
 }
@@ -3184,7 +3119,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev->netdev_ops = &ehea_netdev_ops;
 	ehea_set_ethtool_ops(dev);
 
-	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
+	dev->hw_features = NETIF_F_SG | NETIF_F_TSO
 		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX | NETIF_F_LRO;
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
-- 
1.7.4.4
