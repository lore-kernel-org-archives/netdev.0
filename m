From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] sky2: handle descriptor errors
Date: Wed, 11 Apr 2007 14:47:59 -0700
Message-ID: <20070411214859.750878681@linux-foundation.org>
References: <20070411214757.194710334@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34870 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161295AbXDKWar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 18:30:47 -0400
Content-Disposition: inline; filename=sky2-descriptor-errors.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There should never be descriptor error unless hardware or driver is buggy.
But if an error occurs, print useful information, clear irq, and recover.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |   67 ++++++++++++++++++++++++++++------------------------
 drivers/net/sky2.h |    3 ++
 2 files changed, 39 insertions(+), 31 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-04-11 14:07:36.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-04-11 14:10:13.000000000 -0700
@@ -2343,26 +2343,22 @@ static void sky2_mac_intr(struct sky2_hw
 	}
 }
 
-/* This should never happen it is a fatal situation */
-static void sky2_descriptor_error(struct sky2_hw *hw, unsigned port,
-				  const char *rxtx, u32 mask)
+/* This should never happen it is a bug. */
+static void sky2_le_error(struct sky2_hw *hw, unsigned port,
+			  u16 q, unsigned ring_size)
 {
 	struct net_device *dev = hw->dev[port];
 	struct sky2_port *sky2 = netdev_priv(dev);
-	u32 imask;
+	unsigned idx;
+	const u64 *le = (q == Q_R1 || q == Q_R2)
+		? (u64 *) sky2->rx_le : (u64 *) sky2->tx_le;
+
+	idx = sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_GET_IDX));
+	printk(KERN_ERR PFX "%s: descriptor error q=%#x get=%u [%llx] put=%u\n",
+	       dev->name, (unsigned) q, idx, (unsigned long long) le[idx],
+	       (unsigned) sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_PUT_IDX)));
 
-	printk(KERN_ERR PFX "%s: %s descriptor error (hardware problem)\n",
-	       dev ? dev->name : "<not registered>", rxtx);
-
-	imask = sky2_read32(hw, B0_IMSK);
-	imask &= ~mask;
-	sky2_write32(hw, B0_IMSK, imask);
-
-	if (dev) {
-		spin_lock(&sky2->phy_lock);
-		sky2_link_down(sky2);
-		spin_unlock(&sky2->phy_lock);
-	}
+	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
 /* If idle then force a fake soft NAPI poll once a second
@@ -2386,23 +2382,15 @@ static void sky2_idle(unsigned long arg)
 	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
 }
 
-
-static int sky2_poll(struct net_device *dev0, int *budget)
+/* Hardware/software error handling */
+static void sky2_err_intr(struct sky2_hw *hw, u32 status)
 {
-	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
-	int work_limit = min(dev0->quota, *budget);
-	int work_done = 0;
-	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
+	if (net_ratelimit())
+		dev_warn(&hw->pdev->dev, "error interrupt status=%#x\n", status);
 
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
 
-	if (status & Y2_IS_IRQ_PHY1)
-		sky2_phy_intr(hw, 0);
-
-	if (status & Y2_IS_IRQ_PHY2)
-		sky2_phy_intr(hw, 1);
-
 	if (status & Y2_IS_IRQ_MAC1)
 		sky2_mac_intr(hw, 0);
 
@@ -2410,16 +2398,33 @@ static int sky2_poll(struct net_device *
 		sky2_mac_intr(hw, 1);
 
 	if (status & Y2_IS_CHK_RX1)
-		sky2_descriptor_error(hw, 0, "receive", Y2_IS_CHK_RX1);
+		sky2_le_error(hw, 0, Q_R1, RX_LE_SIZE);
 
 	if (status & Y2_IS_CHK_RX2)
-		sky2_descriptor_error(hw, 1, "receive", Y2_IS_CHK_RX2);
+		sky2_le_error(hw, 1, Q_R2, RX_LE_SIZE);
 
 	if (status & Y2_IS_CHK_TXA1)
-		sky2_descriptor_error(hw, 0, "transmit", Y2_IS_CHK_TXA1);
+		sky2_le_error(hw, 0, Q_XA1, TX_RING_SIZE);
 
 	if (status & Y2_IS_CHK_TXA2)
-		sky2_descriptor_error(hw, 1, "transmit", Y2_IS_CHK_TXA2);
+		sky2_le_error(hw, 1, Q_XA2, TX_RING_SIZE);
+}
+
+static int sky2_poll(struct net_device *dev0, int *budget)
+{
+	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
+	int work_limit = min(dev0->quota, *budget);
+	int work_done = 0;
+	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
+
+	if (unlikely(status & Y2_IS_ERROR))
+		sky2_err_intr(hw, status);
+
+	if (status & Y2_IS_IRQ_PHY1)
+		sky2_phy_intr(hw, 0);
+
+	if (status & Y2_IS_IRQ_PHY2)
+		sky2_phy_intr(hw, 1);
 
 	work_done = sky2_status_intr(hw, work_limit);
 	if (work_done < work_limit) {
--- sky2-2.6.21.orig/drivers/net/sky2.h	2007-04-11 14:05:39.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.h	2007-04-11 14:10:13.000000000 -0700
@@ -288,6 +288,9 @@ enum {
 		          | Y2_IS_CHK_TXA1 | Y2_IS_CHK_RX1,
 	Y2_IS_PORT_2	= Y2_IS_IRQ_PHY2 | Y2_IS_IRQ_MAC2
 			  | Y2_IS_CHK_TXA2 | Y2_IS_CHK_RX2,
+	Y2_IS_ERROR     = Y2_IS_HW_ERR |
+			  Y2_IS_IRQ_MAC1 | Y2_IS_CHK_TXA1 | Y2_IS_CHK_RX1 |
+			  Y2_IS_IRQ_MAC2 | Y2_IS_CHK_TXA2 | Y2_IS_CHK_RX2,
 };
 
 /*	B2_IRQM_HWE_MSK	32 bit	IRQ Moderation HW Error Mask */

--
Stephen Hemminger <shemminger@linux-foundation.org>

