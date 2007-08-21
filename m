From: Greg KH <gregkh@suse.de>
Subject: [patch 03/20] sky2: restore workarounds for lost interrupts
Date: Mon, 20 Aug 2007 23:53:53 -0700
Message-ID: <20070821065353.GD5275@kroah.com>
References: <20070821064251.972690753@blue.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([209.217.80.40]:51475 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758013AbXHUGw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 02:52:27 -0400
Content-Disposition: inline; filename="sky2-lost-irq.patch"
In-Reply-To: <20070821065210.GA5275@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@linux-foundation.org>

Backport of commit c59697e06058fc2361da8cefcfa3de85ac107582

This patch restores a couple of workarounds from 2.6.16:
 * restart transmit moderation timer in case it expires during IRQ routine
 * default to having 10 HZ watchdog timer.
At this point it more important not to hang than to worry about the
power cost.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
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
