From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/2][RFC] mv643xx_eth: enable hardware TX checksumming with vlan tags
Date: Mon, 7 Jul 2008 22:57:08 +0200
Message-ID: <20080707205708.GC12997@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57553 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162AbYGGU5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 16:57:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although mv643xx_eth has no hardware support for inserting a vlan
tag by twiddling some bits in the TX descriptor, it does support
hardware TX checksumming on packets where the IP header starts {a
limited set of values other than 14} bytes into the packet.

This patch sets mv643xx_eth's ->vlan_features to NETIF_F_SG |
NETIF_F_IP_CSUM, which prevents the stack from checksumming vlan'ed
packets in software, and if vlan tags are present on a transmitted
packet, notifies the hardware of this fact by toggling the right
bits in the TX descriptor.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.26-rc9/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.26-rc9.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.26-rc9/drivers/net/mv643xx_eth.c
@@ -228,6 +228,8 @@ struct tx_desc {
 #define GEN_IP_V4_CHECKSUM		0x00040000
 #define GEN_TCP_UDP_CHECKSUM		0x00020000
 #define UDP_FRAME			0x00010000
+#define MAC_HDR_EXTRA_4_BYTES		0x00008000
+#define MAC_HDR_EXTRA_8_BYTES		0x00000200
 
 #define TX_IHL_SHIFT			11
 
@@ -733,12 +735,35 @@ static void txq_submit_skb(struct tx_que
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		BUG_ON(skb->protocol != htons(ETH_P_IP));
+		int mac_hdr_len;
+
+		BUG_ON(skb->protocol != htons(ETH_P_IP) &&
+		       skb->protocol != htons(ETH_P_8021Q));
 
 		cmd_sts |= GEN_TCP_UDP_CHECKSUM |
 			   GEN_IP_V4_CHECKSUM   |
 			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
 
+		mac_hdr_len = (void *)ip_hdr(skb) - (void *)skb->data;
+		switch (mac_hdr_len - 14) {
+		case 0:
+			break;
+		case 4:
+			cmd_sts |= MAC_HDR_EXTRA_4_BYTES;
+			break;
+		case 8:
+			cmd_sts |= MAC_HDR_EXTRA_8_BYTES;
+			break;
+		case 12:
+			cmd_sts |= MAC_HDR_EXTRA_4_BYTES;
+			cmd_sts |= MAC_HDR_EXTRA_8_BYTES;
+			break;
+		default:
+			dev_printk(KERN_ERR, &txq_to_mp(txq)->dev->dev,
+				   "mac header length is %d?!\n", mac_hdr_len);
+			BUG();
+		}
+
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
 			cmd_sts |= UDP_FRAME;
@@ -2486,6 +2511,7 @@ static int mv643xx_eth_probe(struct plat
 	 * have to map the buffers to ISA memory which is only 16 MB
 	 */
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM;
 #endif
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
