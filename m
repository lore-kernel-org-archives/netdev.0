From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] sky2: fix for NAPI with dual port boards
Date: Wed, 21 Feb 2007 16:04:42 -0800
Message-ID: <20070222000621.673620000@linux-foundation.org>
References: <20070222000441.469009000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58979 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbXBVAKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 19:10:44 -0500
Content-Disposition: inline; filename=sky2-napi-dual.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver uses port 0 to handle receives on both ports. So
the netif_poll_disable call in dev_close would end up stopping the
second port on dual port cards.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- linux-2.6.16.40.orig/drivers/net/sky2.c	2007-02-21 15:57:56.000000000 -0800
+++ linux-2.6.16.40/drivers/net/sky2.c	2007-02-21 15:58:02.000000000 -0800
@@ -1402,6 +1402,13 @@
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
+ 	/*
+ 	 * Both ports share the NAPI poll on port 0, so if necessary undo the
+ 	 * the disable that is done in dev_close.
+ 	 */
+ 	if (sky2->port == 0 && hw->ports > 1)
+ 		netif_poll_enable(dev);
+
 	/* Disable port IRQ */
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask &= ~((sky2->port == 0) ? Y2_IS_IRQ_PHY1 : Y2_IS_IRQ_PHY2);

--
Stephen Hemminger <shemminger@linux-foundation.org>

