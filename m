From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 01/12] sky2: restore workarounds for lost interrupts
Date: Mon, 09 Jul 2007 15:33:33 -0700
Message-ID: <20070709223453.040349359@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41294 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755561AbXGIWgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:36:55 -0400
Content-Disposition: inline; filename=sky2-tx-kick.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch restores a couple of workarounds from 2.6.16:
 * restart transmit moderation timer in case it expires during IRQ routine
 * default to having 10 HZ watchdog timer.
At this point it more important not to hang than to worry about the
power cost.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-07-09 15:30:04.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:08.000000000 -0700
@@ -96,7 +96,7 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 0;
+static int idle_timeout = 100;
 module_param(idle_timeout, int, 0);
 MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
 
@@ -2490,6 +2490,13 @@ static int sky2_poll(struct net_device *
 
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
Stephen Hemminger <shemminger@linux-foundation.org>

