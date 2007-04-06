From: davef1624@aol.com
Subject: 2.6.21 linux tree?  Re: [PATCH] sky2: reliable recovery
Date: Fri, 06 Apr 2007 11:47:17 -0400
Message-ID: <8C94679FD30AF6B-244-6779@FWM-D41.sysops.aol.com>
References: <8C93279E2B7D917-1728-84ED@webmail-dd15.sysops.aol.com>	<20070312124525.2ec8fd14@dxpl.pdx.osdl.net>	<8C933095A0BFE81-1728-A925@webmail-dd15.sysops.aol.com>	<20070312152309.4f2652af@freekitty>	<8C93A5EDEA67428-E84-3CD4@WEBMAIL-RB06.sysops.aol.com>	<20070322084716.21572d71@localhost.localdomain>	<8C93AFF7F21F7F6-E84-6718@WEBMAIL-RB06.sysops.aol.com>	<20070322215016.493a6af7@localhost.localdomain>	<8C94036C4FFBA18-AD4-43A6@FWM-D41.sysops.aol.com>	<20070403173747.6be269fb@localhost.localdomain>	<8C9446D33724837-1E6C-2A00@FWM-D41.sysops.aol.com>	<20070403182137.59084935@localhost.localdomain>	<8C94470311E3A7F-1E6C-2ACF@FWM-D41.sysops.aol.com> <20070404111043.28ecce69@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
To: shemminger@linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-m25.mx.aol.com ([64.12.137.6]:63342 "EHLO
	imo-m25.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932953AbXDFPra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 11:47:30 -0400
In-Reply-To: <20070404111043.28ecce69@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Where can I download the 2.6.21 linux kernel source?

I can't seem to find it under:  www.kernel.org/pub/linux/kernel/v2.6

thanks
Dave

-----Original Message-----
From: shemminger@linux-foundation.org
To: stable@kernel.org
Cc: davef1624@aol.com
Sent: Wed, 4 Apr 2007 11:10 AM
Subject: [PATCH] sky2: reliable recovery

  This adds working recovery from transmit timeouts.  Previous code
didn't do enough to truly reset chip.

It is a backport of the 2.6.21 code.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- linux-2.6.20.y.orig/drivers/net/sky2.c  2007-03-21 
15:10:56.000000000 -0700
+++ linux-2.6.20.y/drivers/net/sky2.c   2007-03-22 11:23:19.000000000 
-0700
@@ -1802,38 +1802,22 @@
 {
    struct sky2_port *sky2 = netdev_priv(dev);
    struct sky2_hw *hw = sky2->hw;
-   unsigned txq = txqaddr[sky2->port];
-   u16 report, done;
+   unsigned port = sky2->port;

    if (netif_msg_timer(sky2))
        printk(KERN_ERR PFX "%s: tx timeout\n", dev->name);

-   report = sky2_read16(hw, sky2->port == 0 ? STAT_TXA1_RIDX : 
STAT_TXA2_RIDX);
-   done = sky2_read16(hw, Q_ADDR(txq, Q_DONE));
-
-   printk(KERN_DEBUG PFX "%s: transmit ring %u .. %u report=%u 
done=%u\n",
-          dev->name,
-          sky2->tx_cons, sky2->tx_prod, report, done);
-
-   if (report != done) {
-       printk(KERN_INFO PFX "status burst pending (irq 
moderation?)\n");
+   /* Get information for bug report :-) */
+   printk(KERN_INFO PFX "%s: transmit ring %u .. %u report=%u 
done=%u\n",
+          dev->name, sky2->tx_cons, sky2->tx_prod,
+          sky2_read16(hw, port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
+          sky2_read16(hw, Q_ADDR(txqaddr[sky2->port], Q_DONE)));

-       sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-       sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
-   } else if (report != sky2->tx_cons) {
-       printk(KERN_INFO PFX "status report lost?\n");
-       sky2_tx_complete(sky2, report);
-   } else {
-       printk(KERN_INFO PFX "hardware hung? flushing\n");
+   printk(KERN_INFO PFX "gmac control %#x status %#x\n",
+          gma_read16(hw, port, GM_GP_CTRL), gma_read16(hw, port, 
GM_GP_STAT));

-       sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_STOP);
-       sky2_write32(hw, Y2_QADDR(txq, PREF_UNIT_CTRL), 
PREF_UNIT_RST_SET);
-
-       sky2_tx_complete(sky2, sky2->tx_prod);
-
-       sky2_qset(hw, txq);
-       sky2_prefetch_init(hw, txq, sky2->tx_le_map, TX_RING_SIZE - 1);
-   }
+   /* can't restart safely under softirq */
+   schedule_work(&hw->restart_work);
 }

 static int sky2_change_mtu(struct net_device *dev, int new_mtu)
@@ -2565,6 +2549,49 @@
    return 0;
 }

+static void sky2_restart(struct work_struct *work)
+{
+   struct sky2_hw *hw = container_of(work, struct sky2_hw, 
restart_work);
+   struct net_device *dev;
+   int i, err;
+
+   dev_dbg(&hw->pdev->dev, "restarting\n");
+
+   del_timer_sync(&hw->idle_timer);
+
+   rtnl_lock();
+   sky2_write32(hw, B0_IMSK, 0);
+   sky2_read32(hw, B0_IMSK);
+
+   netif_poll_disable(hw->dev[0]);
+
+   for (i = 0; i < hw->ports; i++) {
+       dev = hw->dev[i];
+       if (netif_running(dev))
+           sky2_down(dev);
+   }
+
+   sky2_reset(hw);
+   sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+   netif_poll_enable(hw->dev[0]);
+
+   for (i = 0; i < hw->ports; i++) {
+       dev = hw->dev[i];
+       if (netif_running(dev)) {
+           err = sky2_up(dev);
+           if (err) {
+               printk(KERN_INFO PFX "%s: could not restart %d\n",
+                      dev->name, err);
+               dev_close(dev);
+           }
+       }
+   }
+
+   sky2_idle_start(hw);
+
+   rtnl_unlock();
+}
+
 static u32 sky2_supported_modes(const struct sky2_hw *hw)
 {
    if (sky2_is_copper(hw)) {
@@ -3508,6 +3535,8 @@
    }

    setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
+   INIT_WORK(&hw->restart_work, sky2_restart);
+
    sky2_idle_start(hw);

    pci_set_drvdata(pdev, hw);
--- linux-2.6.20.y.orig/drivers/net/sky2.h  2007-03-21 
15:16:54.000000000 -0700
+++ linux-2.6.20.y/drivers/net/sky2.h   2007-03-21 15:17:19.000000000 
-0700
@@ -1898,6 +1898,7 @@
    dma_addr_t           st_dma;

    struct timer_list    idle_timer;
+   struct work_struct   restart_work;
    int          msi;
    wait_queue_head_t    msi_wait;
 };


________________________________________________________________________
AOL now offers free email to everyone.  Find out more about what's free 
from AOL at AOL.com.
