From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: turn off Rx checksum on bad hardware
Date: Thu, 8 Mar 2007 12:42:30 -0800
Message-ID: <20070308124230.208b7c9a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35368 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933190AbXCHUpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:45:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Yukon FE, occasional hardware receive checksum errors are seen.
An early indication of the problem is single bit differences in the two
checksum engines.  Use this as a detection mechanism to turn off Rx
checksumming.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

--- sky2-dev.orig/drivers/net/sky2.c	2007-03-05 16:49:31.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-03-05 16:49:45.000000000 -0800
@@ -2165,9 +2165,27 @@
 			/* fall through */
 #endif
 		case OP_RXCHKS:
-			skb = sky2->rx_ring[sky2->rx_next].skb;
-			skb->ip_summed = CHECKSUM_COMPLETE;
-			skb->csum = status & 0xffff;
+			if (!sky2->rx_csum)
+				break;
+
+			/* Both checksum counters are programmed to start at
+			 * the same offset, so unless there is a problem they
+			 * should match. This failure is an early indication that
+			 * hardware receive checksumming won't work.
+			 */
+			if (likely(status >> 16 == (status & 0xffff))) {
+				skb = sky2->rx_ring[sky2->rx_next].skb;
+				skb->ip_summed = CHECKSUM_COMPLETE;
+				skb->csum = status & 0xffff;
+			} else {
+				printk(KERN_NOTICE PFX "%s: hardware receive "
+				       "checksum problem (status = %#x)\n",
+				       dev->name, status);
+				sky2->rx_csum = 0;
+				sky2_write32(sky2->hw,
+					     Q_ADDR(rxqaddr[le->link], Q_CSR),
+					     BMU_DIS_RX_CHKSUM);
+			}
 			break;
 
 		case OP_TXINDEXLE:
