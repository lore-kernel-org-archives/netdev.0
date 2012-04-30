From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] [PATCH] sky2: fix receive length error in mixed
 non-VLAN/VLAN traffic
Date: Mon, 30 Apr 2012 09:47:37 -0700
Message-ID: <20120430094737.6ade1ab4@nehalam.linuxnetplumber.net>
References: <20120430154944.890709139@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	=?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>,
	Mirko Lindner <mlindner@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40730 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756233Ab2D3Qrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 12:47:46 -0400
In-Reply-To: <20120430154944.890709139@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug: The VLAN bit of the MAC RX Status Word is unreliable in several older
supported chips. Sometimes the VLAN bit is not set for valid VLAN packets
and also sometimes the VLAN bit is set for non-VLAN packets that came after
a VLAN packet. This results in a receive length error when VLAN hardware
tagging is enabled.

Fix: Variation on original fix proposed by Mirko.
The VLAN information is decoded in the status loop, and can be
applied to the received SKB there. This eliminates the need for the
separate tag field in the interface data structure. The tag has to
be copied and cleared if packet is copied. This version checked out
with vlan and normal traffic.

Note: vlan_tx_tag_present should be renamed vlan_tag_present, but that
is outside scope of this.

Reported-by: Mirko Lindner <mlindner@marvell.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/marvell/sky2.c	2012-04-30 08:21:05.395136397 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2012-04-30 08:22:27.328472831 -0700
@@ -2495,9 +2495,11 @@ static struct sk_buff *receive_copy(stru
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
 		skb->rxhash = re->skb->rxhash;
+		skb->vlan_tci = re->skb->vlan_tci;
 
 		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
 					       length, PCI_DMA_FROMDEVICE);
+		re->skb->vlan_tci = 0;
 		re->skb->rxhash = 0;
 		re->skb->ip_summed = CHECKSUM_NONE;
 		skb_put(skb, length);
@@ -2583,9 +2585,6 @@ static struct sk_buff *sky2_receive(stru
 	struct sk_buff *skb = NULL;
 	u16 count = (status & GMR_FS_LEN) >> 16;
 
-	if (status & GMR_FS_VLAN)
-		count -= VLAN_HLEN;	/* Account for vlan tag */
-
 	netif_printk(sky2, rx_status, KERN_DEBUG, dev,
 		     "rx slot %u status 0x%x len %d\n",
 		     sky2->rx_next, status, length);
@@ -2593,6 +2592,9 @@ static struct sk_buff *sky2_receive(stru
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
 
+	if (vlan_tx_tag_present(re->skb))
+		count -= VLAN_HLEN;	/* Account for vlan tag */
+
 	/* This chip has hardware problems that generates bogus status.
 	 * So do only marginal checking and expect higher level protocols
 	 * to handle crap frames.
@@ -2650,11 +2652,8 @@ static inline void sky2_tx_done(struct n
 }
 
 static inline void sky2_skb_rx(const struct sky2_port *sky2,
-			       u32 status, struct sk_buff *skb)
+			       struct sk_buff *skb)
 {
-	if (status & GMR_FS_VLAN)
-		__vlan_hwaccel_put_tag(skb, be16_to_cpu(sky2->rx_tag));
-
 	if (skb->ip_summed == CHECKSUM_NONE)
 		netif_receive_skb(skb);
 	else
@@ -2708,6 +2707,14 @@ static void sky2_rx_checksum(struct sky2
 	}
 }
 
+static void sky2_rx_tag(struct sky2_port *sky2, u16 length)
+{
+	struct sk_buff *skb;
+
+	skb = sky2->rx_ring[sky2->rx_next].skb;
+	__vlan_hwaccel_put_tag(skb, be16_to_cpu(length));
+}
+
 static void sky2_rx_hash(struct sky2_port *sky2, u32 status)
 {
 	struct sk_buff *skb;
@@ -2766,8 +2773,7 @@ static int sky2_status_intr(struct sky2_
 			}
 
 			skb->protocol = eth_type_trans(skb, dev);
-
-			sky2_skb_rx(sky2, status, skb);
+			sky2_skb_rx(sky2, skb);
 
 			/* Stop after net poll weight */
 			if (++work_done >= to_do)
@@ -2775,11 +2781,11 @@ static int sky2_status_intr(struct sky2_
 			break;
 
 		case OP_RXVLAN:
-			sky2->rx_tag = length;
+			sky2_rx_tag(sky2, length);
 			break;
 
 		case OP_RXCHKSVLAN:
-			sky2->rx_tag = length;
+			sky2_rx_tag(sky2, length);
 			/* fall through */
 		case OP_RXCHKS:
 			if (likely(dev->features & NETIF_F_RXCSUM))
--- a/drivers/net/ethernet/marvell/sky2.h	2012-04-30 08:19:56.000000000 -0700
+++ b/drivers/net/ethernet/marvell/sky2.h	2012-04-30 08:21:40.595714908 -0700
@@ -2241,7 +2241,6 @@ struct sky2_port {
 	u16		     rx_pending;
 	u16		     rx_data_size;
 	u16		     rx_nfrags;
-	u16		     rx_tag;
 
 	struct {
 		unsigned long last;
