From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] sky2: receive checksum refactoring
Date: Sun, 7 Feb 2010 08:28:36 -0800
Message-ID: <20100207082836.22a7b296@nehalam>
References: <20100207082353.2d0c6a93@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60449 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756184Ab0BGQ3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2010 11:29:17 -0500
In-Reply-To: <20100207082353.2d0c6a93@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Break the largish case for handling receive checksum into a separate
function, and if there is a problem use dev_XXX routines to
show which hardware is the problem.

Turn one corner case into a BUG().  This only happens if the driver
is expecting one behavior but the chip does the old behavior;
only ever saw this when bringing up a new chip type and driver
was buggy.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-02-03 09:24:19.203992300 -0800
+++ b/drivers/net/sky2.c	2010-02-03 09:24:19.933679365 -0800
@@ -2484,6 +2484,32 @@ static inline void sky2_rx_done(struct s
 	}
 }
 
+static void sky2_rx_checksum(struct sky2_port *sky2, u32 status)
+{
+	/* If this happens then driver assuming wrong format for chip type */
+	BUG_ON(sky2->hw->flags & SKY2_HW_NEW_LE);
+
+	/* Both checksum counters are programmed to start at
+	 * the same offset, so unless there is a problem they
+	 * should match. This failure is an early indication that
+	 * hardware receive checksumming won't work.
+	 */
+	if (likely((u16)(status >> 16) == (u16)status)) {
+		struct sk_buff *skb = sky2->rx_ring[sky2->rx_next].skb;
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		skb->csum = le16_to_cpu(status);
+	} else {
+		dev_notice(&sky2->hw->pdev->dev,
+			   "%s: receive checksum problem (status = %#x)\n",
+			   sky2->netdev->name, status);
+
+		/* Disable checksum offload */
+		sky2->flags &= ~SKY2_FLAG_RX_CHECKSUM;
+		sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
+			     BMU_DIS_RX_CHKSUM);
+	}
+}
+
 /* Process status response ring */
 static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 {
@@ -2552,37 +2578,8 @@ static int sky2_status_intr(struct sky2_
 			/* fall through */
 #endif
 		case OP_RXCHKS:
-			if (!(sky2->flags & SKY2_FLAG_RX_CHECKSUM))
-				break;
-
-			/* If this happens then driver assuming wrong format */
-			if (unlikely(hw->flags & SKY2_HW_NEW_LE)) {
-				if (net_ratelimit())
-					printk(KERN_NOTICE "%s: unexpected"
-					       " checksum status\n",
-					       dev->name);
-				break;
-			}
-
-			/* Both checksum counters are programmed to start at
-			 * the same offset, so unless there is a problem they
-			 * should match. This failure is an early indication that
-			 * hardware receive checksumming won't work.
-			 */
-			if (likely(status >> 16 == (status & 0xffff))) {
-				skb = sky2->rx_ring[sky2->rx_next].skb;
-				skb->ip_summed = CHECKSUM_COMPLETE;
-				skb->csum = le16_to_cpu(status);
-			} else {
-				printk(KERN_NOTICE PFX "%s: hardware receive "
-				       "checksum problem (status = %#x)\n",
-				       dev->name, status);
-				sky2->flags &= ~SKY2_FLAG_RX_CHECKSUM;
-
-				sky2_write32(sky2->hw,
-					     Q_ADDR(rxqaddr[port], Q_CSR),
-					     BMU_DIS_RX_CHKSUM);
-			}
+			if (likely(sky2->flags & SKY2_FLAG_RX_CHECKSUM))
+				sky2_rx_checksum(sky2, status);
 			break;
 
 		case OP_TXINDEXLE:
