From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2:  fix receive length error in mixed non-VLAN/VLAN
 traffic
Date: Fri, 27 Apr 2012 20:03:10 -0700
Message-ID: <20120427200310.60325fb1@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120427134127.6d536a96@nehalam.linuxnetplumber.net>
	<20120427135514.48b03ce8@nehalam.linuxnetplumber.net>
	<4F9B2641.9070209@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36105 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758967Ab2D1DDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 23:03:17 -0400
In-Reply-To: <4F9B2641.9070209@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug: The VLAN bit of the MAC RX Status Word is unreliable in several older
supported chips. Sometimes the VLAN bit is not set for valid VLAN packets
and also sometimes the VLAN bit is set for non-VLAN packets that came after
a VLAN packet. This results in a receive length error when VLAN hardware
tagging is enabled.

Fix: The driver uses only VLAN information included in VLAN status list elements,
that signals that the VLAN tag field is valid. It must ignore the VLAN bit in the
MAC RX Status Word. An additional variable set when evaluating the VLAN opcodes
is used to indicate that the received packet is a VLAN packet and a packet length
correction (subtraction of VLAN header length) must be done.

This is an alternative to Mirko's patch that relies on the new method of
encoding VLAN tag, and therefore means extra code can be removed.

Testing: Tested with regular and VLAN traffic on 88E8056, but this chip
does not have the bug, just proves that the alternative method of handling
VLAN tag will work.

Reported-by: Mirko Lindner <mlindner@marvell.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This version is built and tested against net-next (3.4-rc4)

--- a/drivers/net/ethernet/marvell/sky2.c	2012-04-27 19:37:31.891137630 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2012-04-27 19:42:54.242757283 -0700
@@ -2568,6 +2568,14 @@ nobuf:
 	return NULL;
 }
 
+/* Apply vlan tag to the current Rx skb */
+static inline void sky2_rx_tag(struct sky2_port *sky2, u16 tag)
+{
+	struct rx_ring_info *re = sky2->rx_ring + sky2->rx_next;
+
+	__vlan_hwaccel_put_tag(re->skb, be16_to_cpu(tag));
+}
+
 /*
  * Receive one packet.
  * For larger packets, get new buffer.
@@ -2580,7 +2588,7 @@ static struct sk_buff *sky2_receive(stru
 	struct sk_buff *skb = NULL;
 	u16 count = (status & GMR_FS_LEN) >> 16;
 
-	if (status & GMR_FS_VLAN)
+	if (vlan_tx_tag_present(re->skb))
 		count -= VLAN_HLEN;	/* Account for vlan tag */
 
 	netif_printk(sky2, rx_status, KERN_DEBUG, dev,
@@ -2646,12 +2654,9 @@ static inline void sky2_tx_done(struct n
 	}
 }
 
-static inline void sky2_skb_rx(const struct sky2_port *sky2,
-			       u32 status, struct sk_buff *skb)
+static inline void sky2_skb_rx(struct sky2_port *sky2,
+			       struct sk_buff *skb)
 {
-	if (status & GMR_FS_VLAN)
-		__vlan_hwaccel_put_tag(skb, be16_to_cpu(sky2->rx_tag));
-
 	if (skb->ip_summed == CHECKSUM_NONE)
 		netif_receive_skb(skb);
 	else
@@ -2764,7 +2769,7 @@ static int sky2_status_intr(struct sky2_
 
 			skb->protocol = eth_type_trans(skb, dev);
 
-			sky2_skb_rx(sky2, status, skb);
+			sky2_skb_rx(sky2, skb);
 
 			/* Stop after net poll weight */
 			if (++work_done >= to_do)
@@ -2772,11 +2777,11 @@ static int sky2_status_intr(struct sky2_
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
--- a/drivers/net/ethernet/marvell/sky2.h	2012-04-27 19:37:31.891137630 -0700
+++ b/drivers/net/ethernet/marvell/sky2.h	2012-04-27 19:41:01.857495110 -0700
@@ -2241,7 +2241,6 @@ struct sky2_port {
 	u16		     rx_pending;
 	u16		     rx_data_size;
 	u16		     rx_nfrags;
-	u16		     rx_tag;
 
 	struct {
 		unsigned long last;
