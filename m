From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/8] tg3: Add mdio bus registration
Date: Thu, 22 May 2008 19:57:03 -0700
Message-ID: <1211511423.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3676 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760368AbYEWCxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 22:53:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces code to register and unregister the tg3 mdio bus
with the system.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5382325..f5cb1c0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -32,6 +32,7 @@
 #include <linux/skbuff.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/phy.h>
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
@@ -835,6 +836,115 @@ static int tg3_bmcr_reset(struct tg3 *tp)
 	return 0;
 }
 
+static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
+{
+	struct tg3 *tp = (struct tg3 *)bp->priv;
+	u32 val;
+
+	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_PAUSED)
+		return -EAGAIN;
+
+	if (tg3_readphy(tp, reg, &val))
+		return -EIO;
+
+	return val;
+}
+
+static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int reg, u16 val)
+{
+	struct tg3 *tp = (struct tg3 *)bp->priv;
+
+	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_PAUSED)
+		return -EAGAIN;
+
+	if (tg3_writephy(tp, reg, val))
+		return -EIO;
+
+	return 0;
+}
+
+static int tg3_mdio_reset(struct mii_bus *bp)
+{
+	return 0;
+}
+
+static void tg3_mdio_start(struct tg3 *tp)
+{
+	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
+		mutex_lock(&tp->mdio_bus.mdio_lock);
+		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_PAUSED;
+		mutex_unlock(&tp->mdio_bus.mdio_lock);
+	}
+
+	tp->mi_mode &= ~MAC_MI_MODE_AUTO_POLL;
+	tw32_f(MAC_MI_MODE, tp->mi_mode);
+	udelay(80);
+}
+
+static void tg3_mdio_stop(struct tg3 *tp)
+{
+	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
+		mutex_lock(&tp->mdio_bus.mdio_lock);
+		tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_PAUSED;
+		mutex_unlock(&tp->mdio_bus.mdio_lock);
+	}
+}
+
+static int tg3_mdio_init(struct tg3 *tp)
+{
+	int i;
+	u32 reg;
+	struct mii_bus *mdio_bus = &tp->mdio_bus;
+
+	tg3_mdio_start(tp);
+
+	if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) ||
+	    (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED))
+		return 0;
+
+	memset(mdio_bus, 0, sizeof(*mdio_bus));
+
+	mdio_bus->name     = "tg3 mdio bus";
+	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%x",
+		 (tp->pdev->bus->number << 8) | tp->pdev->devfn);
+	mdio_bus->priv     = tp;
+	mdio_bus->dev      = &tp->pdev->dev;
+	mdio_bus->read     = &tg3_mdio_read;
+	mdio_bus->write    = &tg3_mdio_write;
+	mdio_bus->reset    = &tg3_mdio_reset;
+	mdio_bus->phy_mask = ~(1 << PHY_ADDR);
+	mdio_bus->irq      = &tp->mdio_irq[0];
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		mdio_bus->irq[i] = PHY_POLL;
+
+	/* The bus registration will look for all the PHYs on the mdio bus.
+	 * Unfortunately, it does not ensure the PHY is powered up before
+	 * accessing the PHY ID registers.  A chip reset is the
+	 * quickest way to bring the device back to an operational state..
+	 */
+	if (tg3_readphy(tp, MII_BMCR, &reg) || (reg & BMCR_PDOWN))
+		tg3_bmcr_reset(tp);
+
+	i = mdiobus_register(mdio_bus);
+	if (!i)
+		tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_INITED;
+	else
+		printk(KERN_WARNING "%s: mdiobus_reg failed (0x%x)\n",
+			tp->dev->name, i);
+
+	return i;
+}
+
+static void tg3_mdio_fini(struct tg3 *tp)
+{
+	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
+		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_INITED;
+		mdiobus_unregister(&tp->mdio_bus);
+		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_PAUSED;
+	}
+}
+
 /* tp->lock is held. */
 static void tg3_wait_for_event_ack(struct tg3 *tp)
 {
@@ -5386,6 +5496,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	tg3_nvram_lock(tp);
 
+	tg3_mdio_stop(tp);
+
 	/* No matching tg3_nvram_unlock() after this because
 	 * chip reset below will undo the nvram lock.
 	 */
@@ -5537,6 +5649,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tw32_f(MAC_MODE, 0);
 	udelay(40);
 
+	tg3_mdio_start(tp);
+
 	err = tg3_poll_fw(tp);
 	if (err)
 		return err;
@@ -7168,10 +7282,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(MAC_RX_MODE, tp->rx_mode);
 	udelay(10);
 
-	tp->mi_mode &= ~MAC_MI_MODE_AUTO_POLL;
-	tw32_f(MAC_MI_MODE, tp->mi_mode);
-	udelay(80);
-
 	tw32(MAC_LED_CTRL, tp->led_ctrl);
 
 	tw32(MAC_MI_STAT, MAC_MI_STAT_LNKSTAT_ATTN_ENAB);
@@ -11850,9 +11960,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_BX)
 		tp->coalesce_mode |= HOSTCC_MODE_32BYTE;
 
-	/* Initialize MAC MI mode, polling disabled. */
-	tw32_f(MAC_MI_MODE, tp->mi_mode);
-	udelay(80);
+	err = tg3_mdio_init(tp);
+	if (err)
+		return err;
 
 	/* Initialize data/descriptor byte/word swapping. */
 	val = tr32(GRC_MODE);
@@ -13052,6 +13162,10 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 		struct tg3 *tp = netdev_priv(dev);
 
 		flush_scheduled_work();
+
+		if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)
+			tg3_mdio_fini(tp);
+
 		unregister_netdev(dev);
 		if (tp->aperegs) {
 			iounmap(tp->aperegs);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a3598ed..e0914fd 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2481,6 +2481,8 @@ struct tg3 {
 #define TG3_FLG3_5761_5784_AX_FIXES	0x00000004
 #define TG3_FLG3_5701_DMA_BUG		0x00000008
 #define TG3_FLG3_USE_PHYLIB		0x00000010
+#define TG3_FLG3_MDIOBUS_INITED		0x00000020
+#define TG3_FLG3_MDIOBUS_PAUSED		0x00000040
 
 	struct timer_list		timer;
 	u16				timer_counter;
@@ -2521,6 +2523,9 @@ struct tg3 {
 	int				msi_cap;
 	int				pcix_cap;
 
+	struct mii_bus			mdio_bus;
+	int				mdio_irq[PHY_MAX_ADDR];
+
 	/* PHY info */
 	u32				phy_id;
 #define PHY_ID_MASK			0xfffffff0


