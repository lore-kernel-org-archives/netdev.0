From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: sky2: restore workarounds for lost interrupts
Date: Fri, 6 Jul 2007 15:53:21 -0700
Message-ID: <20070706155321.55edc032@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55749 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751033AbXGFWx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 18:53:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sky2 will hang under load due to lost IRQ. It is reproducible fastest on
Yukon EC chips, but others may have same problem.

This patch restores a couple of workarounds from 2.6.16 that reduce
the likely hood of failure. It is not possible to prove this is sufficient
to stop hangs.
 * restart transmit moderation timer in case it expires during IRQ routine
 * default to having 10 HZ watchdog timer.
At this point it more important not to hang than to worry about the
power cost. If possible please put in 2.6.22.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-07-05 22:41:48.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-05 22:42:46.000000000 -0700
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
