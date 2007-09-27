From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: sky2 FE+ receive status workaround
Date: Wed, 26 Sep 2007 17:58:47 -0700
Message-ID: <20070926175847.706025d0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48917 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751320AbXI0A6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 20:58:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Yukon FE+ chip appears to have a hardware glitch that causes bogus
receive status values to be posted. The data in the packet is good, but
the status value is random garbage.  As a temporary workaround until the
problem is better understood, implement the workaround the vendor driver
used of ignoring the status value on this chip.

Since this means trusting dodgy hardware values; add additional checking
of the receive packet length.

Patch against 2.6.23-rc8, please apply before 2.6.23 release (or it will
need to go to stable).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-26 14:34:34.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-26 16:57:31.000000000 -0700
@@ -2148,6 +2148,18 @@ static struct sk_buff *sky2_receive(stru
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
 
+	if (length < ETH_ZLEN || length > sky2->rx_data_size)
+		goto len_error;
+
+	/* This chip has hardware problems that generates bogus status.
+	 * So do only marginal checking and expect higher level protocols
+	 * to handle crap frames.
+	 */
+	if (sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	    sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0 &&
+	    length != count)
+		goto okay;
+
 	if (status & GMR_FS_ANY_ERR)
 		goto error;
 
@@ -2156,8 +2168,9 @@ static struct sk_buff *sky2_receive(stru
 
 	/* if length reported by DMA does not match PHY, packet was truncated */
 	if (length != count)
-		goto len_mismatch;
+		goto len_error;
 
+okay:
 	if (length < copybreak)
 		skb = receive_copy(sky2, re, length);
 	else
@@ -2167,13 +2180,13 @@ resubmit:
 
 	return skb;
 
-len_mismatch:
+len_error:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
 	++sky2->net_stats.rx_length_errors;
 	if (netif_msg_rx_err(sky2) && net_ratelimit())
-		pr_info(PFX "%s: rx length mismatch: length %d status %#x\n",
-			dev->name, length, status);
+		pr_info(PFX "%s: rx length error: status %#x length %d\n",
+			dev->name, status, length);
 	goto resubmit;
 
 error:
@@ -3934,13 +3947,6 @@ static __devinit struct net_device *sky2
 	sky2->hw = hw;
 	sky2->msg_enable = netif_msg_init(debug, default_msg);
 
-	/* This chip has hardware problems that generates
-	 * bogus PHY receive status so by default shut up the message.
-	 */
-	if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
-	    hw->chip_rev == CHIP_REV_YU_FE2_A0)
-		sky2->msg_enable &= ~NETIF_MSG_RX_ERR;
-
 	/* Auto speed and flow control */
 	sky2->autoneg = AUTONEG_ENABLE;
 	sky2->flow_mode = FC_BOTH;
