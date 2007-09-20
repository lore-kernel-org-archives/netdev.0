From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/6] sky2: receive FIFO checking
Date: Wed, 19 Sep 2007 22:06:04 -0700
Message-ID: <20070920050700.547057779@linux-foundation.org>
References: <20070920050559.763089637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzk <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42776 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752171AbXITFH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 01:07:57 -0400
Content-Disposition: inline; filename=sky2-rx-watch.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A driver writer from another operating system hinted that
the versions of Yukon 2 chip with rambuffer (EC and XL) have
a hardware bug that if the FIFO ever gets completely full it
will hang. Sounds like a classic ring full vs ring empty wrap around
bug.

As a workaround, use the existing watchdog timer to check for
ring full lockup.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-19 21:58:08.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-19 21:58:09.000000000 -0700
@@ -1652,9 +1652,6 @@ static int sky2_down(struct net_device *
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
-	if (netif_carrier_ok(dev) && --hw->active == 0)
-		del_timer(&hw->watchdog_timer);
-
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
@@ -1781,9 +1778,7 @@ static void sky2_link_up(struct sky2_por
 
 	netif_carrier_on(sky2->netdev);
 
-	if (hw->active++ == 0)
-		mod_timer(&hw->watchdog_timer, jiffies + 1);
-
+	mod_timer(&hw->watchdog_timer, jiffies + 1);
 
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
@@ -1834,11 +1829,6 @@ static void sky2_link_down(struct sky2_p
 
 	netif_carrier_off(sky2->netdev);
 
-	/* Stop watchdog if both ports are not active */
-	if (--hw->active == 0)
-		del_timer(&hw->watchdog_timer);
-
-
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
 
@@ -2484,16 +2474,70 @@ static void sky2_le_error(struct sky2_hw
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
-/* Check for lost IRQ once a second */
+static int sky2_rx_hung(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	unsigned rxq = rxqaddr[port];
+	u32 mac_rp = sky2_read32(hw, SK_REG(port, RX_GMF_RP));
+	u8 mac_lev = sky2_read8(hw, SK_REG(port, RX_GMF_RLEV));
+	u8 fifo_rp = sky2_read8(hw, Q_ADDR(rxq, Q_RP));
+	u8 fifo_lev = sky2_read8(hw, Q_ADDR(rxq, Q_RL));
+
+	/* If idle and MAC or PCI is stuck */
+	if (sky2->check.last == dev->last_rx &&
+	    ((mac_rp == sky2->check.mac_rp &&
+	      mac_lev != 0 && mac_lev >= sky2->check.mac_lev) ||
+	     /* Check if the PCI RX hang */
+	     (fifo_rp == sky2->check.fifo_rp &&
+	      fifo_lev != 0 && fifo_lev >= sky2->check.fifo_lev))) {
+		printk(KERN_DEBUG PFX "%s: hung mac %d:%d fifo %d (%d:%d)\n",
+		       dev->name, mac_lev, mac_rp, fifo_lev, fifo_rp,
+		       sky2_read8(hw, Q_ADDR(rxq, Q_WP)));
+		return 1;
+	} else {
+		sky2->check.last = dev->last_rx;
+		sky2->check.mac_rp = mac_rp;
+		sky2->check.mac_lev = mac_lev;
+		sky2->check.fifo_rp = fifo_rp;
+		sky2->check.fifo_lev = fifo_lev;
+		return 0;
+	}
+}
+
 static void sky2_watchdog(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
+	struct net_device *dev;
 
+	/* Check for lost IRQ */
 	if (sky2_read32(hw, B0_ISRC))
 		napi_schedule(&hw->napi);
+	else {
+		int i, active = 0;
+
+		for (i = 0; i < hw->ports; i++) {
+			dev = hw->dev[i];
+			if (!netif_running(dev))
+				continue;
+			++active;
+
+			/* For chips with Rx FIFO, check if stuck */
+			if ((hw->flags & SKY2_HW_RAMBUFFER) &&
+			     sky2_rx_hung(dev)) {
+				pr_info(PFX "%s: receiver hang detected\n",
+					dev->name);
+				schedule_work(&hw->restart_work);
+				return;
+			}
+		}
+
+		if (active == 0)
+			return;
+	}
 
-	if (hw->active > 0)
-		mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
+	mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
 }
 
 /* Hardware/software error handling */
--- a/drivers/net/sky2.h	2007-09-19 21:58:08.000000000 -0700
+++ b/drivers/net/sky2.h	2007-09-19 21:58:09.000000000 -0700
@@ -2008,6 +2008,14 @@ struct sky2_port {
 	u16		     rx_tag;
 	struct vlan_group    *vlgrp;
 #endif
+	struct {
+		unsigned long last;
+		u32	mac_rp;
+		u8	mac_lev;
+		u8	fifo_rp;
+		u8	fifo_lev;
+	} check;
+
 
 	dma_addr_t	     rx_le_map;
 	dma_addr_t	     tx_le_map;
@@ -2046,7 +2054,6 @@ struct sky2_hw {
 	u8		     chip_rev;
 	u8		     pmd_type;
 	u8		     ports;
-	u8		     active;
 
 	struct sky2_status_le *st_le;
 	u32		     st_idx;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

