From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/8] pcnet32: convert to set_phys_id
Date: Mon, 04 Apr 2011 14:06:41 -0700
Message-ID: <20110404210805.901815681@linuxplumber.net>
References: <20110404210634.840793593@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Don Fry <pcnet32@frontier.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43897 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755795Ab1DDWSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:18:21 -0400
Content-Disposition: inline; filename=pcnet32-set_phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcnet32.c	2011-04-04 13:33:41.144686505 -0700
+++ b/drivers/net/pcnet32.c	2011-04-04 13:41:13.545491008 -0700
@@ -295,12 +295,14 @@ struct pcnet32_private {
 	struct net_device	*next;
 	struct mii_if_info	mii_if;
 	struct timer_list	watchdog_timer;
-	struct timer_list	blink_timer;
 	u32			msg_enable;	/* debug message level */
 
 	/* each bit indicates an available PHY */
 	u32			phymask;
 	unsigned short		chip_version;	/* which variant this is */
+
+	/* saved registers during ethtool blink */
+	u16 			save_regs[4];
 };
 
 static int pcnet32_probe_pci(struct pci_dev *, const struct pci_device_id *);
@@ -324,8 +326,6 @@ static void pcnet32_restart(struct net_d
 static void pcnet32_ethtool_test(struct net_device *dev,
 				 struct ethtool_test *eth_test, u64 * data);
 static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1);
-static int pcnet32_phys_id(struct net_device *dev, u32 data);
-static void pcnet32_led_blink_callback(struct net_device *dev);
 static int pcnet32_get_regs_len(struct net_device *dev);
 static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *ptr);
@@ -1022,7 +1022,8 @@ clean_up:
 	return rc;
 }				/* end pcnet32_loopback_test  */
 
-static void pcnet32_led_blink_callback(struct net_device *dev)
+static int pcnet32_set_phys_id(struct net_device *dev,
+			       enum ethtool_phys_id_state state)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
@@ -1030,50 +1031,31 @@ static void pcnet32_led_blink_callback(s
 	unsigned long flags;
 	int i;
 
-	spin_lock_irqsave(&lp->lock, flags);
-	for (i = 4; i < 8; i++)
-		a->write_bcr(ioaddr, i, a->read_bcr(ioaddr, i) ^ 0x4000);
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	mod_timer(&lp->blink_timer, PCNET32_BLINK_TIMEOUT);
-}
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		/* Save the current value of the bcrs */
+		spin_lock_irqsave(&lp->lock, flags);
+		for (i = 4; i < 8; i++)
+			lp->save_regs[i - 4] = a->read_bcr(ioaddr, i);
+		spin_unlock_irqrestore(&lp->lock, flags);
+		return -EINVAL;
 
-static int pcnet32_phys_id(struct net_device *dev, u32 data)
-{
-	struct pcnet32_private *lp = netdev_priv(dev);
-	struct pcnet32_access *a = &lp->a;
-	ulong ioaddr = dev->base_addr;
-	unsigned long flags;
-	int i, regs[4];
+	case ETHTOOL_ID_ON:
+	case ETHTOOL_ID_OFF:
+		/* Blink the led */
+		spin_lock_irqsave(&lp->lock, flags);
+		for (i = 4; i < 8; i++)
+			a->write_bcr(ioaddr, i, a->read_bcr(ioaddr, i) ^ 0x4000);
+		spin_unlock_irqrestore(&lp->lock, flags);
+		break;
 
-	if (!lp->blink_timer.function) {
-		init_timer(&lp->blink_timer);
-		lp->blink_timer.function = (void *)pcnet32_led_blink_callback;
-		lp->blink_timer.data = (unsigned long)dev;
+	case ETHTOOL_ID_INACTIVE:
+		/* Restore the original value of the bcrs */
+		spin_lock_irqsave(&lp->lock, flags);
+		for (i = 4; i < 8; i++)
+			a->write_bcr(ioaddr, i, lp->save_regs[i - 4]);
+		spin_unlock_irqrestore(&lp->lock, flags);
 	}
-
-	/* Save the current value of the bcrs */
-	spin_lock_irqsave(&lp->lock, flags);
-	for (i = 4; i < 8; i++)
-		regs[i - 4] = a->read_bcr(ioaddr, i);
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	mod_timer(&lp->blink_timer, jiffies);
-	set_current_state(TASK_INTERRUPTIBLE);
-
-	/* AV: the limit here makes no sense whatsoever */
-	if ((!data) || (data > (u32) (MAX_SCHEDULE_TIMEOUT / HZ)))
-		data = (u32) (MAX_SCHEDULE_TIMEOUT / HZ);
-
-	msleep_interruptible(data * 1000);
-	del_timer_sync(&lp->blink_timer);
-
-	/* Restore the original value of the bcrs */
-	spin_lock_irqsave(&lp->lock, flags);
-	for (i = 4; i < 8; i++)
-		a->write_bcr(ioaddr, i, regs[i - 4]);
-	spin_unlock_irqrestore(&lp->lock, flags);
-
 	return 0;
 }
 
@@ -1450,7 +1432,7 @@ static const struct ethtool_ops pcnet32_
 	.set_ringparam		= pcnet32_set_ringparam,
 	.get_strings		= pcnet32_get_strings,
 	.self_test		= pcnet32_ethtool_test,
-	.phys_id		= pcnet32_phys_id,
+	.set_phys_id		= pcnet32_set_phys_id,
 	.get_regs_len		= pcnet32_get_regs_len,
 	.get_regs		= pcnet32_get_regs,
 	.get_sset_count		= pcnet32_get_sset_count,


