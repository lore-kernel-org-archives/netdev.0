From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFT] sky2: fix status length check on older chips
Date: Fri, 27 Apr 2012 13:55:14 -0700
Message-ID: <20120427135514.48b03ce8@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120427134127.6d536a96@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49740 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090Ab2D0UzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 16:55:18 -0400
In-Reply-To: <20120427134127.6d536a96@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mirko and I were working on a related issue, here is his fix.
I proposed a similar alternative, but he was unavailable to test it,
and therefore was still pending.  Does this fix your problem?

Resend with missing bits.

The cleaner alternative is to not use the boolean flag, but instead
put tag on skb directly (eliminating rx_tag and rx_vlan from
data structure).
=================

From: From: Mirko Lindner <mlindner@marvell.com>

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

Signed-off-by: Mirko Lindner <mlindner@marvell.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
--- a/drivers/net/ethernet/marvell/sky2.c	2012-04-18 23:44:40.637276647 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2012-04-27 13:52:06.154756866 -0700
@@ -2580,7 +2580,7 @@ static struct sk_buff *sky2_receive(stru
 	struct sk_buff *skb = NULL;
 	u16 count = (status & GMR_FS_LEN) >> 16;
 
-	if (status & GMR_FS_VLAN)
+	if (sky2->rx_vlan)
 		count -= VLAN_HLEN;	/* Account for vlan tag */
 
 	netif_printk(sky2, rx_status, KERN_DEBUG, dev,
@@ -2646,11 +2646,13 @@ static inline void sky2_tx_done(struct n
 	}
 }
 
-static inline void sky2_skb_rx(const struct sky2_port *sky2,
-			       u32 status, struct sk_buff *skb)
+static inline void sky2_skb_rx(struct sky2_port *sky2,
+				struct sk_buff *skb)
 {
-	if (status & GMR_FS_VLAN)
+	if (sky2->rx_vlan) {
 		__vlan_hwaccel_put_tag(skb, be16_to_cpu(sky2->rx_tag));
+		sky2->rx_vlan = 0;
+	}
 
 	if (skb->ip_summed == CHECKSUM_NONE)
 		netif_receive_skb(skb);
@@ -2772,10 +2774,12 @@ static int sky2_status_intr(struct sky2_
 			break;
 
 		case OP_RXVLAN:
+			sky2->rx_vlan = 1;
 			sky2->rx_tag = length;
 			break;
 
 		case OP_RXCHKSVLAN:
+			sky2->rx_vlan = 1;
 			sky2->rx_tag = length;
 			/* fall through */
 		case OP_RXCHKS:
--- a/drivers/net/ethernet/marvell/sky2.h	2012-02-13 09:23:53.642447236 -0800
+++ b/drivers/net/ethernet/marvell/sky2.h	2012-04-27 13:36:07.487834432 -0700
@@ -2242,6 +2242,7 @@ struct sky2_port {
 	u16		     rx_data_size;
 	u16		     rx_nfrags;
 	u16		     rx_tag;
+	u8		     rx_vlan;
 
 	struct {
 		unsigned long last;
