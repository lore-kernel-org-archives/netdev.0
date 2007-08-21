From: Greg KH <gregkh@suse.de>
Subject: [patch 05/20] sky2: check for more work before leaving NAPI
Date: Mon, 20 Aug 2007 23:54:15 -0700
Message-ID: <20070821065415.GF5275@kroah.com>
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
Received: from canuck.infradead.org ([209.217.80.40]:44152 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760012AbXHUGwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 02:52:45 -0400
Content-Disposition: inline; filename="sky2-napi-fill.patch"
In-Reply-To: <20070821065210.GA5275@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@linux-foundation.org>

Backport of commit 5c11ce700f77fada15b6264417d72462da4bbb1c

This patch avoids generating another IRQ if more packets
arrive while in the NAPI poll routine. Before marking device as
finished, it rechecks that the status ring is empty.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |   35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2428,8 +2428,7 @@ static void sky2_err_intr(struct sky2_hw
 static int sky2_poll(struct net_device *dev0, int *budget)
 {
 	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
-	int work_limit = min(dev0->quota, *budget);
-	int work_done = 0;
+	int work_done;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
 	if (unlikely(status & Y2_IS_ERROR))
@@ -2441,25 +2440,25 @@ static int sky2_poll(struct net_device *
 	if (status & Y2_IS_IRQ_PHY2)
 		sky2_phy_intr(hw, 1);
 
-	work_done = sky2_status_intr(hw, work_limit);
-	if (work_done < work_limit) {
-		/* Bug/Errata workaround?
-		 * Need to kick the TX irq moderation timer.
-		 */
-		if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
-			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
-		}
-		netif_rx_complete(dev0);
+	work_done = sky2_status_intr(hw, min(dev0->quota, *budget));
+	*budget -= work_done;
+	dev0->quota -= work_done;
 
-		/* end of interrupt, re-enables also acts as I/O synchronization */
-		sky2_read32(hw, B0_Y2_SP_LISR);
-		return 0;
-	} else {
-		*budget -= work_done;
-		dev0->quota -= work_done;
+	/* More work? */
+ 	if (hw->st_idx != sky2_read16(hw, STAT_PUT_IDX))
 		return 1;
+
+	/* Bug/Errata workaround?
+	 * Need to kick the TX irq moderation timer.
+	 */
+	if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
 	}
+	netif_rx_complete(dev0);
+
+	sky2_read32(hw, B0_Y2_SP_LISR);
+	return 0;
 }
 
 static irqreturn_t sky2_intr(int irq, void *dev_id)

-- 
