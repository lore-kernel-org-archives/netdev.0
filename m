From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.34-rc5] smc91c92_cs: spin_unlock_irqrestore
 before calling smc_interrupt()
Date: Sun, 25 Apr 2010 05:37:09 +0900
Message-ID: <20100425053709.ec182f63.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
	<20100404061434.eb98ef3e.ken_kawasaki@spring.nifty.jp>
	<20100411075014.d3e80847.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg508.nifty.com ([202.248.238.88]:8754 "EHLO
	userg508.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347Ab0DXUhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 16:37:34 -0400
Received: from localhost.localdomain (eaoska104120.adsl.ppp.infoweb.ne.jp [218.226.19.120])by userg508.nifty.com with SMTP id o3OKbIBu008408
	for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 05:37:18 +0900
In-Reply-To: <20100411075014.d3e80847.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


smc91c92_cs:
  * spin_unlock_irqrestore before calling smc_interrupt() in media_check()
     to avoid lockup.
  * use spin_lock_irqsave for ethtool function.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.34-rc5/drivers/net/pcmcia/smc91c92_cs.c.orig	2010-04-24 07:33:50.000000000 +0900
+++ linux-2.6.34-rc5/drivers/net/pcmcia/smc91c92_cs.c	2010-04-24 07:42:44.000000000 +0900
@@ -1804,23 +1804,30 @@ static void media_check(u_long arg)
     SMC_SELECT_BANK(1);
     media |= (inw(ioaddr + CONFIG) & CFG_AUI_SELECT) ? 2 : 1;
 
+    SMC_SELECT_BANK(saved_bank);
+    spin_unlock_irqrestore(&smc->lock, flags);
+
     /* Check for pending interrupt with watchdog flag set: with
        this, we can limp along even if the interrupt is blocked */
     if (smc->watchdog++ && ((i>>8) & i)) {
 	if (!smc->fast_poll)
 	    printk(KERN_INFO "%s: interrupt(s) dropped!\n", dev->name);
+	local_irq_save(flags);
 	smc_interrupt(dev->irq, dev);
+	local_irq_restore(flags);
 	smc->fast_poll = HZ;
     }
     if (smc->fast_poll) {
 	smc->fast_poll--;
 	smc->media.expires = jiffies + HZ/100;
 	add_timer(&smc->media);
-	SMC_SELECT_BANK(saved_bank);
-	spin_unlock_irqrestore(&smc->lock, flags);
 	return;
     }
 
+    spin_lock_irqsave(&smc->lock, flags);
+
+    saved_bank = inw(ioaddr + BANK_SELECT);
+
     if (smc->cfg & CFG_MII_SELECT) {
 	if (smc->mii_if.phy_id < 0)
 	    goto reschedule;
@@ -1978,15 +1985,16 @@ static int smc_get_settings(struct net_d
 	unsigned int ioaddr = dev->base_addr;
 	u16 saved_bank = inw(ioaddr + BANK_SELECT);
 	int ret;
+	unsigned long flags;
 
-	spin_lock_irq(&smc->lock);
+	spin_lock_irqsave(&smc->lock, flags);
 	SMC_SELECT_BANK(3);
 	if (smc->cfg & CFG_MII_SELECT)
 		ret = mii_ethtool_gset(&smc->mii_if, ecmd);
 	else
 		ret = smc_netdev_get_ecmd(dev, ecmd);
 	SMC_SELECT_BANK(saved_bank);
-	spin_unlock_irq(&smc->lock);
+	spin_unlock_irqrestore(&smc->lock, flags);
 	return ret;
 }
 
@@ -1996,15 +2004,16 @@ static int smc_set_settings(struct net_d
 	unsigned int ioaddr = dev->base_addr;
 	u16 saved_bank = inw(ioaddr + BANK_SELECT);
 	int ret;
+	unsigned long flags;
 
-	spin_lock_irq(&smc->lock);
+	spin_lock_irqsave(&smc->lock, flags);
 	SMC_SELECT_BANK(3);
 	if (smc->cfg & CFG_MII_SELECT)
 		ret = mii_ethtool_sset(&smc->mii_if, ecmd);
 	else
 		ret = smc_netdev_set_ecmd(dev, ecmd);
 	SMC_SELECT_BANK(saved_bank);
-	spin_unlock_irq(&smc->lock);
+	spin_unlock_irqrestore(&smc->lock, flags);
 	return ret;
 }
 
@@ -2014,12 +2023,13 @@ static u32 smc_get_link(struct net_devic
 	unsigned int ioaddr = dev->base_addr;
 	u16 saved_bank = inw(ioaddr + BANK_SELECT);
 	u32 ret;
+	unsigned long flags;
 
-	spin_lock_irq(&smc->lock);
+	spin_lock_irqsave(&smc->lock, flags);
 	SMC_SELECT_BANK(3);
 	ret = smc_link_ok(dev);
 	SMC_SELECT_BANK(saved_bank);
-	spin_unlock_irq(&smc->lock);
+	spin_unlock_irqrestore(&smc->lock, flags);
 	return ret;
 }
 
@@ -2056,16 +2066,17 @@ static int smc_ioctl (struct net_device 
 	int rc = 0;
 	u16 saved_bank;
 	unsigned int ioaddr = dev->base_addr;
+	unsigned long flags;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	spin_lock_irq(&smc->lock);
+	spin_lock_irqsave(&smc->lock, flags);
 	saved_bank = inw(ioaddr + BANK_SELECT);
 	SMC_SELECT_BANK(3);
 	rc = generic_mii_ioctl(&smc->mii_if, mii, cmd, NULL);
 	SMC_SELECT_BANK(saved_bank);
-	spin_unlock_irq(&smc->lock);
+	spin_unlock_irqrestore(&smc->lock, flags);
 	return rc;
 }
 
