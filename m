From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] sky2: receive hang check
Date: Wed, 12 Sep 2007 16:19:57 +0200
Message-ID: <20070912161957.701eddff@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34702 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S968754AbXILOTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:19:10 -0400
Received: from oldman (15.telemaxx.net [213.144.15.9] (may be forged))
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l8CEJ5JU001741
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 07:19:08 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Would some of the users of 2.6.23-rc5 or later who still experience
hangs please test this.
IT IS EXPERIMENTAL AND NOT TESTED YET.

I am sending it out to see if it detects anything.

--- a/drivers/net/sky2.c	2007-09-12 14:52:18.000000000 +0200
+++ b/drivers/net/sky2.c	2007-09-12 15:53:16.000000000 +0200
@@ -1304,6 +1304,7 @@ static int sky2_up(struct net_device *de
 	/* Register is number of 4K blocks on internal RAM buffer. */
 	ramsize = sky2_read8(hw, B2_E_0) * 4;
 	printk(KERN_INFO PFX "%s: ram buffer %dK\n", dev->name, ramsize);
+	memset(&sky2->check, 0, sizeof(sky2->check));
 
 	if (ramsize > 0) {
 		u32 rxspace;
@@ -2446,11 +2447,42 @@ static void sky2_le_error(struct sky2_hw
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
-/* Check for lost IRQ once a second */
+static void sky2_rx_check(struct net_device *dev)
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
+	/* If not idle and MAC or PCI is stuck */
+	if (sky2->check.last != dev->last_rx &&
+	    ((mac_rp == sky2->check.mac_rp &&
+		     mac_lev != 0 && mac_lev >= sky2->check.mac_lev) ||
+		    /* Check if the PCI RX hang */
+		    (fifo_rp == sky2->check.fifo_rp &&
+		     fifo_lev != 0 && fifo_lev >= sky2->check.fifo_lev))) {
+
+		pr_info(PFX "%s: receiver hang detected\n", dev->name);
+		schedule_work(&hw->restart_work);
+	}
+
+	sky2->check.last = dev->last_rx;
+	sky2->check.mac_rp = mac_rp;
+	sky2->check.mac_lev = mac_lev;
+	sky2->check.fifo_rp = fifo_rp;
+	sky2->check.fifo_lev = fifo_lev;
+}
+
 static void sky2_watchdog(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
+	int i;
 
+	/* Check for lost IRQ */
 	if (sky2_read32(hw, B0_ISRC)) {
 		struct net_device *dev = hw->dev[0];
 
@@ -2458,6 +2490,13 @@ static void sky2_watchdog(unsigned long 
 			__netif_rx_schedule(dev);
 	}
 
+	/* Check for stuck receiver */
+	if (sky2_read8(hw, B2_E_0) != 0)
+		for (i = 0; i < hw->ports; i++)
+			if (netif_running(hw->dev[i]))
+			    sky2_rx_check(hw->dev[i]);
+
+
 	if (hw->active > 0)
 		mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
 }
--- a/drivers/net/sky2.h	2007-09-05 14:21:59.000000000 +0200
+++ b/drivers/net/sky2.h	2007-09-12 15:36:59.000000000 +0200
@@ -2017,6 +2017,14 @@ struct sky2_port {
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
