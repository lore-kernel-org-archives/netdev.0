From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: status interrupt handling improvement
Date: Tue, 1 Aug 2006 11:55:23 -0700
Message-ID: <20060801115523.0ce0a690@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32957 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751785AbWHASz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 14:55:27 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More changes to prevent losing status and causing hangs.
The hardware is smarter than I gave it credit for. 
Clearing the status IRQ causes the status state machine to
toggle an IRQ if needed and post any more transmits.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   30 ++++++++++++------------------
 1 file changed, 12 insertions(+), 18 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-07-31 08:46:43.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-07-31 14:51:40.000000000 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.5"
+#define DRV_VERSION		"1.6"
 #define PFX			DRV_NAME " "
 
 /*
@@ -1932,12 +1932,6 @@
 	}
 }
 
-/* Is status ring empty or is there more to do? */
-static inline int sky2_more_work(const struct sky2_hw *hw)
-{
-	return (hw->st_idx != sky2_read16(hw, STAT_PUT_IDX));
-}
-
 /* Process status response ring */
 static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 {
@@ -2028,6 +2022,9 @@
 		}
 	}
 
+	/* Fully processed status ring so clear irq */
+	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+
 exit_loop:
 	if (buf_write[0]) {
 		sky2 = netdev_priv(hw->dev[0]);
@@ -2237,19 +2234,16 @@
 		sky2_descriptor_error(hw, 1, "transmit", Y2_IS_CHK_TXA2);
 
 	work_done = sky2_status_intr(hw, work_limit);
-	*budget -= work_done;
-	dev0->quota -= work_done;
-
-	if (status & Y2_IS_STAT_BMU)
-		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+	if (work_done < work_limit) {
+		netif_rx_complete(dev0);
 
-	if (sky2_more_work(hw))
+		sky2_read32(hw, B0_Y2_SP_LISR);
+		return 0;
+	} else {
+		*budget -= work_done;
+		dev0->quota -= work_done;
 		return 1;
-
-	netif_rx_complete(dev0);
-
-	sky2_read32(hw, B0_Y2_SP_LISR);
-	return 0;
+	}
 }
 
 static irqreturn_t sky2_intr(int irq, void *dev_id, struct pt_regs *regs)
