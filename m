From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 8/9] fs_enet: Convert mii-bitbang to use the generic
	bitbang MDIO code.
Date: Thu, 20 Sep 2007 17:01:24 -0500
Message-ID: <20070920220124.GH28784@loki.buserror.net>
References: <20070920220043.GA28769@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:47843 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbXITWCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 18:02:02 -0400
Content-Disposition: inline
In-Reply-To: <20070920220043.GA28769@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/mii-bitbang.c |  270 ++++++++-----------------------------
 1 files changed, 54 insertions(+), 216 deletions(-)

diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 2b9c44c..5732890 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -15,15 +15,13 @@
 #include <linux/module.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
-#include <linux/interrupt.h>
 #include <linux/init.h>
-#include <linux/delay.h>
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
-#include <linux/ethtool.h>
-#include <linux/bitops.h>
 #include <linux/platform_device.h>
+#include <linux/mdio-bitbang.h>
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
 #include <linux/of_platform.h>
@@ -32,11 +30,11 @@
 #include "fs_enet.h"
 
 struct bb_info {
+	struct mdiobb_ctrl ctrl;
 	__be32 __iomem *dir;
 	__be32 __iomem *dat;
 	u32 mdio_msk;
 	u32 mdc_msk;
-	int delay;
 };
 
 /* FIXME: If any other users of GPIO crop up, then these will have to
@@ -59,212 +57,58 @@ static inline int bb_read(u32 __iomem *p, u32 m)
 	return (in_be32(p) & m) != 0;
 }
 
-static inline void mdio_active(struct bb_info *bitbang)
+static inline void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 {
-	bb_set(bitbang->dir, bitbang->mdio_msk);
-}
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
 
-static inline void mdio_tristate(struct bb_info *bitbang)
-{
-	bb_clr(bitbang->dir, bitbang->mdio_msk);
+	if (dir)
+		bb_set(bitbang->dir, bitbang->mdio_msk);
+	else
+		bb_clr(bitbang->dir, bitbang->mdio_msk);
+
+	/* Read back to flush the write. */
+	in_be32(bitbang->dir);
 }
 
-static inline int mdio_read(struct bb_info *bitbang)
+static inline int mdio_read(struct mdiobb_ctrl *ctrl)
 {
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
 	return bb_read(bitbang->dat, bitbang->mdio_msk);
 }
 
-static inline void mdio(struct bb_info *bitbang, int what)
+static inline void mdio(struct mdiobb_ctrl *ctrl, int what)
 {
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
 	if (what)
 		bb_set(bitbang->dat, bitbang->mdio_msk);
 	else
 		bb_clr(bitbang->dat, bitbang->mdio_msk);
+
+	/* Read back to flush the write. */
+	in_be32(bitbang->dat);
 }
 
-static inline void mdc(struct bb_info *bitbang, int what)
+static inline void mdc(struct mdiobb_ctrl *ctrl, int what)
 {
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
 	if (what)
 		bb_set(bitbang->dat, bitbang->mdc_msk);
 	else
 		bb_clr(bitbang->dat, bitbang->mdc_msk);
-}
-
-static inline void mii_delay(struct bb_info *bitbang)
-{
-	udelay(bitbang->delay);
-}
-
-/* Utility to send the preamble, address, and register (common to read and write). */
-static void bitbang_pre(struct bb_info *bitbang , int read, u8 addr, u8 reg)
-{
-	int j;
-
-	/*
-	 * Send a 32 bit preamble ('1's) with an extra '1' bit for good measure.
-	 * The IEEE spec says this is a PHY optional requirement.  The AMD
-	 * 79C874 requires one after power up and one after a MII communications
-	 * error.  This means that we are doing more preambles than we need,
-	 * but it is safer and will be much more robust.
-	 */
-
-	mdio_active(bitbang);
-	mdio(bitbang, 1);
-	for (j = 0; j < 32; j++) {
-		mdc(bitbang, 0);
-		mii_delay(bitbang);
-		mdc(bitbang, 1);
-		mii_delay(bitbang);
-	}
-
-	/* send the start bit (01) and the read opcode (10) or write (10) */
-	mdc(bitbang, 0);
-	mdio(bitbang, 0);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-	mdc(bitbang, 0);
-	mdio(bitbang, 1);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-	mdc(bitbang, 0);
-	mdio(bitbang, read);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-	mdc(bitbang, 0);
-	mdio(bitbang, !read);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-
-	/* send the PHY address */
-	for (j = 0; j < 5; j++) {
-		mdc(bitbang, 0);
-		mdio(bitbang, (addr & 0x10) != 0);
-		mii_delay(bitbang);
-		mdc(bitbang, 1);
-		mii_delay(bitbang);
-		addr <<= 1;
-	}
 
-	/* send the register address */
-	for (j = 0; j < 5; j++) {
-		mdc(bitbang, 0);
-		mdio(bitbang, (reg & 0x10) != 0);
-		mii_delay(bitbang);
-		mdc(bitbang, 1);
-		mii_delay(bitbang);
-		reg <<= 1;
-	}
+	/* Read back to flush the write. */
+	in_be32(bitbang->dat);
 }
 
-static int fs_enet_mii_bb_read(struct mii_bus *bus , int phy_id, int location)
-{
-	u16 rdreg;
-	int ret, j;
-	u8 addr = phy_id & 0xff;
-	u8 reg = location & 0xff;
-	struct bb_info* bitbang = bus->priv;
-
-	bitbang_pre(bitbang, 1, addr, reg);
-
-	/* tri-state our MDIO I/O pin so we can read */
-	mdc(bitbang, 0);
-	mdio_tristate(bitbang);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-
-	/* check the turnaround bit: the PHY should be driving it to zero */
-	if (mdio_read(bitbang) != 0) {
-		/* PHY didn't drive TA low */
-		for (j = 0; j < 32; j++) {
-			mdc(bitbang, 0);
-			mii_delay(bitbang);
-			mdc(bitbang, 1);
-			mii_delay(bitbang);
-		}
-		ret = -1;
-		goto out;
-	}
-
-	mdc(bitbang, 0);
-	mii_delay(bitbang);
-
-	/* read 16 bits of register data, MSB first */
-	rdreg = 0;
-	for (j = 0; j < 16; j++) {
-		mdc(bitbang, 1);
-		mii_delay(bitbang);
-		rdreg <<= 1;
-		rdreg |= mdio_read(bitbang);
-		mdc(bitbang, 0);
-		mii_delay(bitbang);
-	}
-
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-	mdc(bitbang, 0);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-
-	ret = rdreg;
-out:
-	return ret;
-}
-
-static int fs_enet_mii_bb_write(struct mii_bus *bus, int phy_id, int location, u16 val)
-{
-	int j;
-	struct bb_info* bitbang = bus->priv;
-
-	u8 addr = phy_id & 0xff;
-	u8 reg = location & 0xff;
-	u16 value = val & 0xffff;
-
-	bitbang_pre(bitbang, 0, addr, reg);
-
-	/* send the turnaround (10) */
-	mdc(bitbang, 0);
-	mdio(bitbang, 1);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-	mdc(bitbang, 0);
-	mdio(bitbang, 0);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-
-	/* write 16 bits of register data, MSB first */
-	for (j = 0; j < 16; j++) {
-		mdc(bitbang, 0);
-		mdio(bitbang, (value & 0x8000) != 0);
-		mii_delay(bitbang);
-		mdc(bitbang, 1);
-		mii_delay(bitbang);
-		value <<= 1;
-	}
-
-	/*
-	 * Tri-state the MDIO line.
-	 */
-	mdio_tristate(bitbang);
-	mdc(bitbang, 0);
-	mii_delay(bitbang);
-	mdc(bitbang, 1);
-	mii_delay(bitbang);
-	return 0;
-}
-
-static int fs_enet_mii_bb_reset(struct mii_bus *bus)
-{
-	/*nothing here - dunno how to reset it*/
-	return 0;
-}
+static struct mdiobb_ops bb_ops = {
+	.owner = THIS_MODULE,
+	.set_mdc = mdc,
+	.set_mdio_dir = mdio_dir,
+	.set_mdio_data = mdio,
+	.get_mdio_data = mdio_read,
+};
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
 static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
@@ -305,7 +149,6 @@ static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
 	bitbang->dat = bitbang->dir + 4;
 	bitbang->mdio_msk = 1 << (31 - mdio_pin);
 	bitbang->mdc_msk = 1 << (31 - mdc_pin);
-	bitbang->delay = 1; /* 1 us between operations */
 
 	return 0;
 }
@@ -336,23 +179,21 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	int ret = -ENOMEM;
 	int i;
 
-	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
-	if (!new_bus)
-		goto out;
-
 	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
 	if (!bitbang)
-		goto out_free_bus;
+		goto out;
+
+	bitbang->ctrl.ops = &bb_ops;
+
+	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
+	if (!new_bus)
+		goto out_free_priv;
 
-	new_bus->priv = bitbang;
 	new_bus->name = "CPM2 Bitbanged MII",
-	new_bus->read = &fs_enet_mii_bb_read,
-	new_bus->write = &fs_enet_mii_bb_write,
-	new_bus->reset = &fs_enet_mii_bb_reset,
 
 	ret = fs_mii_bitbang_init(new_bus, ofdev->node);
 	if (ret)
-		goto out_free_bitbang;
+		goto out_free_bus;
 
 	new_bus->phy_mask = ~0;
 	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
@@ -380,10 +221,10 @@ out_free_irqs:
 	kfree(new_bus->irq);
 out_unmap_regs:
 	iounmap(bitbang->dir);
-out_free_bitbang:
-	kfree(bitbang);
 out_free_bus:
 	kfree(new_bus);
+out_free_priv:
+	free_mdio_bitbang(new_bus);
 out:
 	return ret;
 }
@@ -394,6 +235,7 @@ static int fs_enet_mdio_remove(struct of_device *ofdev)
 	struct bb_info *bitbang = bus->priv;
 
 	mdiobus_unregister(bus);
+	free_mdio_bitbang(bus);
 	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(bus->irq);
 	iounmap(bitbang->dir);
@@ -417,12 +259,12 @@ static struct of_platform_driver fs_enet_bb_mdio_driver = {
 	.remove = fs_enet_mdio_remove,
 };
 
-int fs_enet_mdio_bb_init(void)
+static int fs_enet_mdio_bb_init(void)
 {
 	return of_register_platform_driver(&fs_enet_bb_mdio_driver);
 }
 
-void fs_enet_mdio_bb_exit(void)
+static void fs_enet_mdio_bb_exit(void)
 {
 	of_unregister_platform_driver(&fs_enet_bb_mdio_driver);
 }
@@ -437,7 +279,6 @@ static int __devinit fs_mii_bitbang_init(struct bb_info *bitbang,
 	bitbang->dat = (u32 __iomem *)fmpi->mdio_dat.offset;
 	bitbang->mdio_msk = 1U << (31 - fmpi->mdio_dat.bit);
 	bitbang->mdc_msk = 1U << (31 - fmpi->mdc_dat.bit);
-	bitbang->delay = fmpi->delay;
 
 	return 0;
 }
@@ -453,20 +294,19 @@ static int __devinit fs_enet_mdio_probe(struct device *dev)
 	if (NULL == dev)
 		return -EINVAL;
 
-	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
 
-	if (NULL == new_bus)
+	if (NULL == bitbang)
 		return -ENOMEM;
 
-	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
+	bitbang->ctrl.ops = &bb_ops;
 
-	if (NULL == bitbang)
+	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
+
+	if (NULL == new_bus)
 		return -ENOMEM;
 
 	new_bus->name = "BB MII Bus",
-	new_bus->read = &fs_enet_mii_bb_read,
-	new_bus->write = &fs_enet_mii_bb_write,
-	new_bus->reset = &fs_enet_mii_bb_reset,
 	new_bus->id = pdev->id;
 
 	new_bus->phy_mask = ~0x9;
@@ -498,8 +338,8 @@ static int __devinit fs_enet_mdio_probe(struct device *dev)
 	return 0;
 
 bus_register_fail:
+	free_mdio_bitbang(new_bus);
 	kfree(bitbang);
-	kfree(new_bus);
 
 	return err;
 }
@@ -512,9 +352,7 @@ static int fs_enet_mdio_remove(struct device *dev)
 
 	dev_set_drvdata(dev, NULL);
 
-	iounmap((void *) (&bus->priv));
-	bus->priv = NULL;
-	kfree(bus);
+	free_mdio_bitbang(bus);
 
 	return 0;
 }
@@ -535,4 +373,4 @@ void fs_enet_mdio_bb_exit(void)
 {
 	driver_unregister(&fs_enet_bb_mdio_driver);
 }
-
+#endif
-- 
1.5.3.1

