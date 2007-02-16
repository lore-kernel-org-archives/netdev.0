From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] skge: race with workq and RTNL
Date: Fri, 16 Feb 2007 15:37:39 -0800
Message-ID: <20070216153739.387d0b97@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41417 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946305AbXBPXk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 18:40:59 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a workqueue function that needs RTNL is running when skge_down
is called then a deadlock is possible. Fix by only clearing the timer,
and handling the flush_scheduled_work on removal. This work queue is only
ever used for the old fiber based boards.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- skge.orig/drivers/net/skge.c
+++ skge/drivers/net/skge.c
@@ -1419,7 +1419,8 @@ static void xm_link_timer(struct work_st
 	mutex_unlock(&hw->phy_mutex);
 
 nochange:
-	schedule_delayed_work(&skge->link_thread, LINK_HZ);
+	if (netif_running(dev))
+		schedule_delayed_work(&skge->link_thread, LINK_HZ);
 }
 
 static void genesis_mac_init(struct skge_hw *hw, int port)
@@ -2530,7 +2531,7 @@ static int skge_down(struct net_device *
 
 	netif_stop_queue(dev);
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
-		cancel_rearming_delayed_work(&skge->link_thread);
+		cancel_delayed_work(&skge->link_thread);
 
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
 	if (hw->chip_id == CHIP_ID_GENESIS)
@@ -3690,6 +3691,8 @@ static void __devexit skge_remove(struct
 	if (!hw)
 		return;
 
+	flush_scheduled_work();
+
 	if ((dev1 = hw->dev[1]))
 		unregister_netdev(dev1);
 	dev0 = hw->dev[0];
@@ -3704,8 +3707,6 @@ static void __devexit skge_remove(struct
 	skge_write16(hw, B0_LED, LED_STAT_OFF);
 	skge_write8(hw, B0_CTST, CS_RST_SET);
 
-	flush_scheduled_work();
-
 	free_irq(pdev->irq, hw);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
