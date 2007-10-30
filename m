From: Sergej Stepanov <Sergej.Stepanov@ids.de>
Subject: [PATCH v2] using mii-bitbang on different processor ports
Date: Tue, 30 Oct 2007 19:10:12 +0100
Message-ID: <1193767812.6244.46.camel@p60635-ste.ids.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

The patch makes possible to have mdio and mdc pins on different physical ports
also for CONFIG_PPC_CPM_NEW_BINDING.
To setup it in the device tree:
reg = <10d40 14 10d60 14>; // mdc: 0x10d40, mdio: 0x10d60
or
reg = <10d40 14>; // mdc and mdio have the same offset 10d40
The approach was taken from older version.

Signed-off-by: Sergej Stepanov <Sergej.Stepanov@ids.de>
--

diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index b8e4a73..eea5feb 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -29,12 +29,16 @@
 
 #include "fs_enet.h"
 
-struct bb_info {
-	struct mdiobb_ctrl ctrl;
+struct bb_port {
 	__be32 __iomem *dir;
 	__be32 __iomem *dat;
-	u32 mdio_msk;
-	u32 mdc_msk;
+	u32 msk;
+};
+
+struct bb_info {
+	struct mdiobb_ctrl ctrl;
+	struct bb_port mdc;
+	struct bb_port mdio;
 };
 
 /* FIXME: If any other users of GPIO crop up, then these will have to
@@ -62,18 +66,18 @@ static inline void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
 
 	if (dir)
-		bb_set(bitbang->dir, bitbang->mdio_msk);
+		bb_set(bitbang->mdio.dir, bitbang->mdio.msk);
 	else
-		bb_clr(bitbang->dir, bitbang->mdio_msk);
+		bb_clr(bitbang->mdio.dir, bitbang->mdio.msk);
 
 	/* Read back to flush the write. */
-	in_be32(bitbang->dir);
+	in_be32(bitbang->mdio.dir);
 }
 
 static inline int mdio_read(struct mdiobb_ctrl *ctrl)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
-	return bb_read(bitbang->dat, bitbang->mdio_msk);
+	return bb_read(bitbang->mdio.dat, bitbang->mdio.msk);
 }
 
 static inline void mdio(struct mdiobb_ctrl *ctrl, int what)
@@ -81,12 +85,12 @@ static inline void mdio(struct mdiobb_ctrl *ctrl, int what)
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
 
 	if (what)
-		bb_set(bitbang->dat, bitbang->mdio_msk);
+		bb_set(bitbang->mdio.dat, bitbang->mdio.msk);
 	else
-		bb_clr(bitbang->dat, bitbang->mdio_msk);
+		bb_clr(bitbang->mdio.dat, bitbang->mdio.msk);
 
 	/* Read back to flush the write. */
-	in_be32(bitbang->dat);
+	in_be32(bitbang->mdio.dat);
 }
 
 static inline void mdc(struct mdiobb_ctrl *ctrl, int what)
@@ -94,12 +98,12 @@ static inline void mdc(struct mdiobb_ctrl *ctrl, int what)
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
 
 	if (what)
-		bb_set(bitbang->dat, bitbang->mdc_msk);
+		bb_set(bitbang->mdc.dat, bitbang->mdc.msk);
 	else
-		bb_clr(bitbang->dat, bitbang->mdc_msk);
+		bb_clr(bitbang->mdc.dat, bitbang->mdc.msk);
 
 	/* Read back to flush the write. */
-	in_be32(bitbang->dat);
+	in_be32(bitbang->mdc.dat);
 }
 
 static struct mdiobb_ops bb_ops = {
@@ -114,23 +118,23 @@ static struct mdiobb_ops bb_ops = {
 static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
                                          struct device_node *np)
 {
-	struct resource res;
+	struct resource res[2];
 	const u32 *data;
 	int mdio_pin, mdc_pin, len;
 	struct bb_info *bitbang = bus->priv;
 
-	int ret = of_address_to_resource(np, 0, &res);
+	int ret = of_address_to_resource(np, 0, &res[0]);
 	if (ret)
 		return ret;
 
-	if (res.end - res.start < 13)
+	if (res[0].end - res[0].start < 13)
 		return -ENODEV;
 
 	/* This should really encode the pin number as well, but all
 	 * we get is an int, and the odds of multiple bitbang mdio buses
 	 * is low enough that it's not worth going too crazy.
 	 */
-	bus->id = res.start;
+	bus->id = res[0].start;
 
 	data = of_get_property(np, "fsl,mdio-pin", &len);
 	if (!data || len != 4)
@@ -142,15 +146,32 @@ static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
 		return -ENODEV;
 	mdc_pin = *data;
 
-	bitbang->dir = ioremap(res.start, res.end - res.start + 1);
-	if (!bitbang->dir)
+	bitbang->mdc.dir = ioremap(res[0].start, res[0].end - res[0].start + 1);
+	if (!bitbang->mdc.dir)
 		return -ENOMEM;
 
-	bitbang->dat = bitbang->dir + 4;
-	bitbang->mdio_msk = 1 << (31 - mdio_pin);
-	bitbang->mdc_msk = 1 << (31 - mdc_pin);
+	bitbang->mdc.dat = bitbang->mdc.dir + 4;
+	if( !of_address_to_resource(np, 1, &res[1])) {
+		if (res[1].end - res[1].start < 13)
+			goto bad_resource;
+		bitbang->mdio.dir = ioremap(res[1].start, res[1].end - res[1].start + 1);
+		if (!bitbang->mdio.dir)
+			goto unmap_and_exit;
+		bitbang->mdio.dat = bitbang->mdio.dir + 4;
+	} else {
+		bitbang->mdio.dir = bitbang->mdc.dir;
+		bitbang->mdio.dat = bitbang->mdc.dat;
+	}
+	bitbang->mdio.msk = 1 << (31 - mdio_pin);
+	bitbang->mdc.msk = 1 << (31 - mdc_pin);
 
 	return 0;
+bad_resource:
+	iounmap(bitbang->mdc.dir);
+	return -ENODEV;
+unmap_and_exit:
+	iounmap(bitbang->mdc.dir);
+	return -ENOMEM;
 }
 
 static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
@@ -220,7 +241,9 @@ out_free_irqs:
 	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(new_bus->irq);
 out_unmap_regs:
-	iounmap(bitbang->dir);
+	if (bitbang->mdio.dir != bitbang->mdc.dir)
+		iounmap(bitbang->mdio.dir);
+	iounmap(bitbang->mdc.dir);
 out_free_bus:
 	kfree(new_bus);
 out_free_priv:
@@ -238,7 +261,9 @@ static int fs_enet_mdio_remove(struct of_device *ofdev)
 	free_mdio_bitbang(bus);
 	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(bus->irq);
-	iounmap(bitbang->dir);
+	if ( bitbang->mdio.dir != bitbang->mdc.dir)
+		iounmap(bitbang->mdio.dir);
+	iounmap(bitbang->mdc.dir);
 	kfree(bitbang);
 	kfree(bus);
