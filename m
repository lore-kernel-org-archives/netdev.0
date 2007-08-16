From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] sky2: restore workarounds for lost interrupts
Date: Thu, 16 Aug 2007 09:12:45 -0400
Message-ID: <20070816131348.019025298@linux-foundation.org>
References: <20070816131244.726293914@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48286 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756932AbXHPNOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 09:14:39 -0400
Content-Disposition: inline; filename=sky2-lost-irq.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Backport of commit c59697e06058fc2361da8cefcfa3de85ac107582

This patch restores a couple of workarounds from 2.6.16:
 * restart transmit moderation timer in case it expires during IRQ routine
 * default to having 10 HZ watchdog timer.
At this point it more important not to hang than to worry about the
power cost.
    
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-08-08 21:50:10.000000000 +0100
+++ b/drivers/net/sky2.c	2007-08-08 22:01:00.000000000 +0100
@@ -96,7 +96,7 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 0;
+static int idle_timeout = 100;
 module_param(idle_timeout, int, 0);
 MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
 
@@ -2442,6 +2442,13 @@ static int sky2_poll(struct net_device *
 
 	work_done = sky2_status_intr(hw, work_limit);
 	if (work_done < work_limit) {
+		/* Bug/Errata workaround?
+		 * Need to kick the TX irq moderation timer.
+		 */
+		if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
+			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
+			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
+		}
 		netif_rx_complete(dev0);
 
 		/* end of interrupt, re-enables also acts as I/O synchronization */

-- 

