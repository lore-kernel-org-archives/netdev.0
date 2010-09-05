From: Mark Lord <kernel@teksavvy.com>
Subject: PATCH: b44 Handle RX FIFO overflow better (simplified)
Date: Sat, 04 Sep 2010 20:17:59 -0400
Message-ID: <1283645879.1672.2.camel@corey>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	James@superbug.co.uk
To: "linux-kernel-owner@vger.kernel.org"
	<linux-kernel-owner@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport2-out.teksavvy.com ([206.248.154.183]:38253 "EHLO
	ironport2-out.pppoe.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754390Ab0IEA16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 20:27:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a simplified version of the original patch from James Courtier-Dutton.

>From: James Courtier-Dutton
>Subject: [PATCH] Fix b44 RX FIFO overflow recovery.
>Date: Wednesday, June 30, 2010 - 1:11 pm
>
>This patch improves the recovery after a RX FIFO overflow on the b44
>Ethernet NIC.
>Before it would do a complete chip reset, resulting is loss of link
>for a few seconds.
>This patch improves this to do recovery in about 20ms without loss of link.
>
>Signed off by: James@superbug.co.uk

Signed-off-by: Mark Lord <mlord@pobox.com>

--- a/drivers/net/b44.c	2010-09-04 20:02:27.539248270 -0400
+++ b/drivers/net/b44.c	2010-09-04 20:07:03.749248234 -0400
@@ -851,6 +851,15 @@
 		b44_tx(bp);
 		/* spin_unlock(&bp->tx_lock); */
 	}
+	if (bp->istat & ISTAT_RFO) {	/* fast recovery, in ~20msec */
+		bp->istat &= ~ISTAT_RFO;
+		b44_disable_ints(bp);
+		ssb_device_enable(bp->sdev, 0); /* resets ISTAT_RFO */
+		b44_init_rings(bp);
+		b44_init_hw(bp, B44_FULL_RESET_SKIP_PHY);
+		netif_wake_queue(bp->dev);
+	}
+
 	spin_unlock_irqrestore(&bp->lock, flags);
 
 	work_done = 0;


