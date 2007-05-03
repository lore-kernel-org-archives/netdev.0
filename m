From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 8/16][BNX2]: Add ipv6 TSO and checksum for 5709.
Date: Thu, 03 May 2007 00:29:53 -0700
Message-ID: <1178177393.4909.71.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1385 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161161AbXECGmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:42:45 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add ipv6 TSO and checksum for 5709.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 89681b3..01977de 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4537,35 +4537,49 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		u32 tcp_opt_len, ip_tcp_len;
 		struct iphdr *iph;
 
-		if (skb_header_cloned(skb) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			return NETDEV_TX_OK;
-		}
-
 		vlan_tag_flags |= TX_BD_FLAGS_SW_LSO;
 
-		tcp_opt_len = 0;
-		if (tcp_hdr(skb)->doff > 5)
-			tcp_opt_len = tcp_optlen(skb);
+		tcp_opt_len = tcp_optlen(skb);
+
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
+			u32 tcp_off = skb_transport_offset(skb) -
+				      sizeof(struct ipv6hdr) - ETH_HLEN;
 
-		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
+			vlan_tag_flags |= ((tcp_opt_len >> 2) << 8) |
+					  TX_BD_FLAGS_SW_FLAGS;
+			if (likely(tcp_off == 0))
+				vlan_tag_flags &= ~TX_BD_FLAGS_TCP6_OFF0_MSK;
+			else {
+				tcp_off >>= 3;
+				vlan_tag_flags |= ((tcp_off & 0x3) <<
+						   TX_BD_FLAGS_TCP6_OFF0_SHL) |
+						  ((tcp_off & 0x10) <<
+						   TX_BD_FLAGS_TCP6_OFF4_SHL);
+				mss |= (tcp_off & 0xc) << TX_BD_TCP6_OFF2_SHL;
+			}
+		} else {
+			if (skb_header_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
+				dev_kfree_skb(skb);
+				return NETDEV_TX_OK;
+			}
 
-		iph = ip_hdr(skb);
-		iph->check = 0;
-		iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-							 iph->daddr, 0,
-							 IPPROTO_TCP, 0);
-		if (tcp_opt_len || (iph->ihl > 5)) {
-			vlan_tag_flags |= ((iph->ihl - 5) +
-					   (tcp_opt_len >> 2)) << 8;
+			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
+
+			iph = ip_hdr(skb);
+			iph->check = 0;
+			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
+			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
+								 iph->daddr, 0,
+								 IPPROTO_TCP,
+								 0);
+			if (tcp_opt_len || (iph->ihl > 5)) {
+				vlan_tag_flags |= ((iph->ihl - 5) +
+						   (tcp_opt_len >> 2)) << 8;
+			}
 		}
-	}
-	else
-	{
+	} else
 		mss = 0;
-	}
 
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
@@ -5233,10 +5247,15 @@ bnx2_set_rx_csum(struct net_device *dev, u32 data)
 static int
 bnx2_set_tso(struct net_device *dev, u32 data)
 {
-	if (data)
+	struct bnx2 *bp = netdev_priv(dev);
+
+	if (data) {
 		dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
-	else
-		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
+		if (CHIP_NUM(bp) == CHIP_NUM_5709)
+			dev->features |= NETIF_F_TSO6;
+	} else
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
+				   NETIF_F_TSO_ECN);
 	return 0;
 }
 
@@ -5534,6 +5553,17 @@ bnx2_phys_id(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int
+bnx2_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		return (ethtool_op_set_tx_hw_csum(dev, data));
+	else
+		return (ethtool_op_set_tx_csum(dev, data));
+}
+
 static const struct ethtool_ops bnx2_ethtool_ops = {
 	.get_settings		= bnx2_get_settings,
 	.set_settings		= bnx2_set_settings,
@@ -5556,7 +5586,7 @@ static const struct ethtool_ops bnx2_ethtool_ops = {
 	.get_rx_csum		= bnx2_get_rx_csum,
 	.set_rx_csum		= bnx2_set_rx_csum,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.set_tx_csum		= ethtool_op_set_tx_csum,
+	.set_tx_csum		= bnx2_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
 	.get_tso		= ethtool_op_get_tso,
@@ -6094,11 +6124,16 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
 	bp->name = board_info[ent->driver_data].name;
 
-	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
+	else
+		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 #ifdef BCM_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
 	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		dev->features |= NETIF_F_TSO6;
 
 	if ((rc = register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 8e7b29a..70fb639 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -24,8 +24,11 @@ struct tx_bd {
 	u32 tx_bd_haddr_hi;
 	u32 tx_bd_haddr_lo;
 	u32 tx_bd_mss_nbytes;
+		#define TX_BD_TCP6_OFF2_SHL		(14)
 	u32 tx_bd_vlan_tag_flags;
 		#define TX_BD_FLAGS_CONN_FAULT		(1<<0)
+		#define TX_BD_FLAGS_TCP6_OFF0_MSK	(3<<1)
+		#define TX_BD_FLAGS_TCP6_OFF0_SHL	(1)
 		#define TX_BD_FLAGS_TCP_UDP_CKSUM	(1<<1)
 		#define TX_BD_FLAGS_IP_CKSUM		(1<<2)
 		#define TX_BD_FLAGS_VLAN_TAG		(1<<3)
@@ -34,6 +37,7 @@ struct tx_bd {
 		#define TX_BD_FLAGS_END			(1<<6)
 		#define TX_BD_FLAGS_START		(1<<7)
 		#define TX_BD_FLAGS_SW_OPTION_WORD	(0x1f<<8)
+		#define TX_BD_FLAGS_TCP6_OFF4_SHL	(12)
 		#define TX_BD_FLAGS_SW_FLAGS		(1<<13)
 		#define TX_BD_FLAGS_SW_SNAP		(1<<14)
 		#define TX_BD_FLAGS_SW_LSO		(1<<15)


