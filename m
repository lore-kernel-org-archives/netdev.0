From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Wed, 16 Apr 2008 16:40:42 +0200
Message-ID: <200804161640.42693.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org,
 netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch converts the MII bitband driver to use GPIO lib for GPIO access.
The driver can now handle MDC and MDIO on different GPIO banks.

The patch depends on Anton Vorontsov GPIO lib support scheduled for 2.6.26.
It is by no means complete, I just would like to get some feedback on the
approach. I'll resubmit it when the CPM2 GPIO support patches will be
available in the powerpc git tree.

---
 Documentation/powerpc/booting-without-of.txt |   10 +-
 arch/powerpc/boot/dts/mpc8272ads.dts         |   16 ++-
 arch/powerpc/boot/dts/pq2fads.dts            |   16 ++-
 drivers/net/fs_enet/fs_enet-main.c           |   10 +-
 drivers/net/fs_enet/mii-bitbang.c            |  177 ++++++++++++++------------
 5 files changed, 127 insertions(+), 102 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index 012f231..6f16c2d 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -2030,21 +2030,19 @@ platforms are moved over to use the flattened-device-tree model.
    fsl,cpm2-mdio-bitbang (reg is port C registers)
 
    Properties for fsl,cpm2-mdio-bitbang:
-   fsl,mdio-pin : pin of port C controlling mdio data
-   fsl,mdc-pin : pin of port C controlling mdio clock
+   gpios : GPIOs controlling mdio clock and mdio data (in that order).
 
    Example:
 
-	mdio@10d40 {
+	mdio {
 		device_type = "mdio";
 		compatible = "fsl,mpc8272ads-mdio-bitbang",
 		             "fsl,mpc8272-mdio-bitbang",
 		             "fsl,cpm2-mdio-bitbang";
-		reg = <10d40 14>;
 		#address-cells = <1>;
 		#size-cells = <0>;
-		fsl,mdio-pin = <12>;
-		fsl,mdc-pin = <13>;
+		gpios = <&cpm_pio_c 13 0
+			 &cpm_pio_c 12 0>;
 	};
 
    v) Baud Rate Generators
diff --git a/arch/powerpc/boot/dts/mpc8272ads.dts b/arch/powerpc/boot/dts/mpc8272ads.dts
index 7285ca1..bfe359f 100644
--- a/arch/powerpc/boot/dts/mpc8272ads.dts
+++ b/arch/powerpc/boot/dts/mpc8272ads.dts
@@ -164,16 +164,24 @@
 				fsl,cpm-command = <0ce00000>;
 			};
 
-			mdio@10d40 {
+			cpm_pio_c: gpio_controller@10d40 {
+				compatible = "fsl,cpm2-pario-bank-c",
+					     "fsl,cpm2-pario-bank";
+				reg = <0x10d40 0x18>;
+				#gpio-cells = <2>;
+				gpio-controller;
+			};
+
+			mdio {
 				device_type = "mdio";
 				compatible = "fsl,mpc8272ads-mdio-bitbang",
 				             "fsl,mpc8272-mdio-bitbang",
 				             "fsl,cpm2-mdio-bitbang";
-				reg = <10d40 14>;
 				#address-cells = <1>;
 				#size-cells = <0>;
-				fsl,mdio-pin = <12>;
-				fsl,mdc-pin = <13>;
+				gpios = <&cpm_pio_c 13 0	/* MDC */
+					 &cpm_pio_c 12 0	/* MDIO */
+					>;
 
 				PHY0: ethernet-phy@0 {
 					interrupt-parent = <&PIC>;
diff --git a/arch/powerpc/boot/dts/pq2fads.dts b/arch/powerpc/boot/dts/pq2fads.dts
index 2d56492..5c32d42 100644
--- a/arch/powerpc/boot/dts/pq2fads.dts
+++ b/arch/powerpc/boot/dts/pq2fads.dts
@@ -187,16 +187,24 @@
 				local-mac-address = [00 e0 0c 00 79 01];
 			};
 
-			mdio@10d40 {
+			cpm_pio_c: gpio_controller@10d40 {
+				compatible = "fsl,cpm2-pario-bank-c",
+					     "fsl,cpm2-pario-bank";
+				reg = <0x10d40 0x18>;
+				#gpio-cells = <2>;
+				gpio-controller;
+			};
+
+			mdio {
 				device_type = "mdio";
 				compatible = "fsl,pq2fads-mdio-bitbang",
 				             "fsl,mpc8280-mdio-bitbang",
 				             "fsl,cpm2-mdio-bitbang";
 				#address-cells = <1>;
 				#size-cells = <0>;
-				reg = <10d40 14>;
-				fsl,mdio-pin = <9>;
-				fsl,mdc-pin = <a>;
+				gpios = <&cpm_pio_c a 0		/* MDC */
+					 &cpm_pio_c 9 0		/* MDIO */
+					>;
 
 				PHY0: ethernet-phy@0 {
 					interrupt-parent = <&PIC>;
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 940e204..90df285 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -43,6 +43,7 @@
 #include <asm/uaccess.h>
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
+#include <linux/of_gpio.h>
 #include <asm/of_platform.h>
 #endif
 
@@ -1172,8 +1173,7 @@ static int __devinit find_phy(struct device_node *np,
                               struct fs_platform_info *fpi)
 {
 	struct device_node *phynode, *mdionode;
-	struct resource res;
-	int ret = 0, len;
+	int ret = 0, len, gpio;
 	const u32 *data;
 
 	data  = of_get_property(np, "fixed-link", NULL);
@@ -1194,15 +1194,15 @@ static int __devinit find_phy(struct device_node *np,
 	if (!mdionode)
 		goto out_put_phy;
 
-	ret = of_address_to_resource(mdionode, 0, &res);
-	if (ret)
+	gpio = of_get_gpio(mdionode, 0);
+	if (gpio < 0)
 		goto out_put_mdio;
 
 	data = of_get_property(phynode, "reg", &len);
 	if (!data || len != 4)
 		goto out_put_mdio;
 
-	snprintf(fpi->bus_id, 16, PHY_ID_FMT, res.start, *data);
+	snprintf(fpi->bus_id, 16, PHY_ID_FMT, gpio, *data);
 
 out_put_mdio:
 	of_node_put(mdionode);
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index ef351f2..9ccbbc8 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -29,78 +29,38 @@
 
 #include "fs_enet.h"
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
 struct bb_info {
 	struct mdiobb_ctrl ctrl;
-	__be32 __iomem *mdc_dat;
-	__be32 __iomem *mdio_dir;
-	__be32 __iomem *mdio_dat;
-	u32 mdio_msk;
-	u32 mdc_msk;
+	int mdc, mdio;
 };
 
-/* FIXME: If any other users of GPIO crop up, then these will have to
- * have some sort of global synchronization to avoid races with other
- * pins on the same port.  The ideal solution would probably be to
- * bind the ports to a GPIO driver, and have this be a client of it.
- */
-static inline void bb_set(u32 __iomem *p, u32 m)
-{
-	out_be32(p, in_be32(p) | m);
-}
-
-static inline void bb_clr(u32 __iomem *p, u32 m)
-{
-	out_be32(p, in_be32(p) & ~m);
-}
-
-static inline int bb_read(u32 __iomem *p, u32 m)
-{
-	return (in_be32(p) & m) != 0;
-}
-
 static inline void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
 
 	if (dir)
-		bb_set(bitbang->mdio_dir, bitbang->mdio_msk);
+		gpio_direction_output(bitbang->mdio, 1);
 	else
-		bb_clr(bitbang->mdio_dir, bitbang->mdio_msk);
-
-	/* Read back to flush the write. */
-	in_be32(bitbang->mdio_dir);
+		gpio_direction_input(bitbang->mdio);
 }
 
 static inline int mdio_read(struct mdiobb_ctrl *ctrl)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
-	return bb_read(bitbang->mdio_dat, bitbang->mdio_msk);
+	return gpio_get_value(bitbang->mdio);
 }
 
 static inline void mdio(struct mdiobb_ctrl *ctrl, int what)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
-
-	if (what)
-		bb_set(bitbang->mdio_dat, bitbang->mdio_msk);
-	else
-		bb_clr(bitbang->mdio_dat, bitbang->mdio_msk);
-
-	/* Read back to flush the write. */
-	in_be32(bitbang->mdio_dat);
+	gpio_set_value(bitbang->mdio, what);
 }
 
 static inline void mdc(struct mdiobb_ctrl *ctrl, int what)
 {
 	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
-
-	if (what)
-		bb_set(bitbang->mdc_dat, bitbang->mdc_msk);
-	else
-		bb_clr(bitbang->mdc_dat, bitbang->mdc_msk);
-
-	/* Read back to flush the write. */
-	in_be32(bitbang->mdc_dat);
+	gpio_set_value(bitbang->mdc, what);
 }
 
 static struct mdiobb_ops bb_ops = {
@@ -111,46 +71,18 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = mdio_read,
 };
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
                                          struct device_node *np)
 {
-	struct resource res;
-	const u32 *data;
-	int mdio_pin, mdc_pin, len;
 	struct bb_info *bitbang = bus->priv;
 
-	int ret = of_address_to_resource(np, 0, &res);
-	if (ret)
-		return ret;
-
-	if (res.end - res.start < 13)
-		return -ENODEV;
-
-	/* This should really encode the pin number as well, but all
-	 * we get is an int, and the odds of multiple bitbang mdio buses
-	 * is low enough that it's not worth going too crazy.
-	 */
-	bus->id = res.start;
+	bitbang->mdc = of_get_gpio(np, 0);
+	bitbang->mdio = of_get_gpio(np, 1);
 
-	data = of_get_property(np, "fsl,mdio-pin", &len);
-	if (!data || len != 4)
+	if (bitbang->mdc < 0 || bitbang->mdio < 0)
 		return -ENODEV;
-	mdio_pin = *data;
-
-	data = of_get_property(np, "fsl,mdc-pin", &len);
-	if (!data || len != 4)
-		return -ENODEV;
-	mdc_pin = *data;
-
-	bitbang->mdio_dir = ioremap(res.start, res.end - res.start + 1);
-	if (!bitbang->mdio_dir)
-		return -ENOMEM;
-
-	bitbang->mdio_dat = bitbang->mdio_dir + 4;
-	bitbang->mdio_msk = 1 << (31 - mdio_pin);
-	bitbang->mdc_msk = 1 << (31 - mdc_pin);
 
+	bus->id = bitbang->mdc;
 	return 0;
 }
 
@@ -199,7 +131,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	new_bus->phy_mask = ~0;
 	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (!new_bus->irq)
-		goto out_unmap_regs;
+		goto out_free_bus;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
 		new_bus->irq[i] = -1;
@@ -220,8 +152,6 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 out_free_irqs:
 	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(new_bus->irq);
-out_unmap_regs:
-	iounmap(bitbang->mdio_dir);
 out_free_bus:
 	kfree(new_bus);
 out_free_priv:
@@ -239,7 +169,6 @@ static int fs_enet_mdio_remove(struct of_device *ofdev)
 	free_mdio_bitbang(bus);
 	dev_set_drvdata(&ofdev->dev, NULL);
 	kfree(bus->irq);
-	iounmap(bitbang->mdio_dir);
 	kfree(bitbang);
 	kfree(bus);
 
@@ -273,6 +202,88 @@ static void fs_enet_mdio_bb_exit(void)
 module_init(fs_enet_mdio_bb_init);
 module_exit(fs_enet_mdio_bb_exit);
 #else
+struct bb_info {
+	struct mdiobb_ctrl ctrl;
+	__be32 __iomem *mdc_dat;
+	__be32 __iomem *mdio_dir;
+	__be32 __iomem *mdio_dat;
+	u32 mdio_msk;
+	u32 mdc_msk;
+};
+
+/* FIXME: If any other users of GPIO crop up, then these will have to
+ * have some sort of global synchronization to avoid races with other
+ * pins on the same port.  The ideal solution would probably be to
+ * bind the ports to a GPIO driver, and have this be a client of it.
+ */
+static inline void bb_set(u32 __iomem *p, u32 m)
+{
+	out_be32(p, in_be32(p) | m);
+}
+
+static inline void bb_clr(u32 __iomem *p, u32 m)
+{
+	out_be32(p, in_be32(p) & ~m);
+}
+
+static inline int bb_read(u32 __iomem *p, u32 m)
+{
+	return (in_be32(p) & m) != 0;
+}
+
+static inline void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (dir)
+		bb_set(bitbang->mdio_dir, bitbang->mdio_msk);
+	else
+		bb_clr(bitbang->mdio_dir, bitbang->mdio_msk);
+
+	/* Read back to flush the write. */
+	in_be32(bitbang->mdio_dir);
+}
+
+static inline int mdio_read(struct mdiobb_ctrl *ctrl)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+	return bb_read(bitbang->mdio_dat, bitbang->mdio_msk);
+}
+
+static inline void mdio(struct mdiobb_ctrl *ctrl, int what)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (what)
+		bb_set(bitbang->mdio_dat, bitbang->mdio_msk);
+	else
+		bb_clr(bitbang->mdio_dat, bitbang->mdio_msk);
+
+	/* Read back to flush the write. */
+	in_be32(bitbang->mdio_dat);
+}
+
+static inline void mdc(struct mdiobb_ctrl *ctrl, int what)
+{
+	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
+
+	if (what)
+		bb_set(bitbang->mdc_dat, bitbang->mdc_msk);
+	else
+		bb_clr(bitbang->mdc_dat, bitbang->mdc_msk);
+
+	/* Read back to flush the write. */
+	in_be32(bitbang->mdc_dat);
+}
+
+static struct mdiobb_ops bb_ops = {
+	.owner = THIS_MODULE,
+	.set_mdc = mdc,
+	.set_mdio_dir = mdio_dir,
+	.set_mdio_data = mdio,
+	.get_mdio_data = mdio_read,
+};
+
 static int __devinit fs_mii_bitbang_init(struct bb_info *bitbang,
                                          struct fs_mii_bb_platform_info *fmpi)
 {
-- 
1.5.0


-- 
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
F +32 (2) 387 42 75
