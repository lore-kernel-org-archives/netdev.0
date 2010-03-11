From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 02/37] of: Eliminate dev_archdata_get_node()
Date: Thu, 11 Mar 2010 11:03:58 -0700
Message-ID: <20100311180357.4824.50303.stgit__47760.367304045$1268333002$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:53396 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933473Ab0CKSEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:04:05 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device_node pointer is now stored in struct device->of_node so we
no longer need the dev_archdata_get_node() accessor.  Read the of_node
directly instead.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/microblaze/include/asm/device.h |    6 ------
 arch/powerpc/include/asm/device.h    |    6 ------
 arch/sparc/include/asm/device.h      |    6 ------
 drivers/gpio/pca953x.c               |    2 +-
 drivers/mmc/host/of_mmc_spi.c        |    4 ++--
 drivers/of/of_i2c.c                  |    2 +-
 drivers/of/of_mdio.c                 |    4 ++--
 drivers/spi/spi_mpc8xxx.c            |    6 +++---
 8 files changed, 9 insertions(+), 27 deletions(-)

diff --git a/arch/microblaze/include/asm/device.h b/arch/microblaze/include/asm/device.h
index 78a0384..2370888 100644
--- a/arch/microblaze/include/asm/device.h
+++ b/arch/microblaze/include/asm/device.h
@@ -25,12 +25,6 @@ static inline void dev_archdata_set_node(struct dev_archdata *ad,
 	ad->of_node = np;
 }
 
-static inline struct device_node *
-dev_archdata_get_node(const struct dev_archdata *ad)
-{
-	return ad->of_node;
-}
-
 #endif /* _ASM_MICROBLAZE_DEVICE_H */
 
 
diff --git a/arch/powerpc/include/asm/device.h b/arch/powerpc/include/asm/device.h
index 6d94d27..0aa81d3 100644
--- a/arch/powerpc/include/asm/device.h
+++ b/arch/powerpc/include/asm/device.h
@@ -36,12 +36,6 @@ static inline void dev_archdata_set_node(struct dev_archdata *ad,
 	ad->of_node = np;
 }
 
-static inline struct device_node *
-dev_archdata_get_node(const struct dev_archdata *ad)
-{
-	return ad->of_node;
-}
-
 struct pdev_archdata {
 };
 
diff --git a/arch/sparc/include/asm/device.h b/arch/sparc/include/asm/device.h
index f3b85b6..55dadca 100644
--- a/arch/sparc/include/asm/device.h
+++ b/arch/sparc/include/asm/device.h
@@ -26,12 +26,6 @@ static inline void dev_archdata_set_node(struct dev_archdata *ad,
 	ad->prom_node = np;
 }
 
-static inline struct device_node *
-dev_archdata_get_node(const struct dev_archdata *ad)
-{
-	return ad->prom_node;
-}
-
 struct pdev_archdata {
 };
 
diff --git a/drivers/gpio/pca953x.c b/drivers/gpio/pca953x.c
index ab5daab..abc9b8c 100644
--- a/drivers/gpio/pca953x.c
+++ b/drivers/gpio/pca953x.c
@@ -436,7 +436,7 @@ pca953x_get_alt_pdata(struct i2c_client *client)
 	struct device_node *node;
 	const uint16_t *val;
 
-	node = dev_archdata_get_node(&client->dev.archdata);
+	node = client->dev.of_node;
 	if (node == NULL)
 		return NULL;
 
diff --git a/drivers/mmc/host/of_mmc_spi.c b/drivers/mmc/host/of_mmc_spi.c
index 0c7a63c..a1ec5d0 100644
--- a/drivers/mmc/host/of_mmc_spi.c
+++ b/drivers/mmc/host/of_mmc_spi.c
@@ -63,7 +63,7 @@ static int of_mmc_spi_get_ro(struct device *dev)
 struct mmc_spi_platform_data *mmc_spi_get_pdata(struct spi_device *spi)
 {
 	struct device *dev = &spi->dev;
-	struct device_node *np = dev_archdata_get_node(&dev->archdata);
+	struct device_node *np = dev->of_node;
 	struct of_mmc_spi *oms;
 	const u32 *voltage_ranges;
 	int num_ranges;
@@ -134,7 +134,7 @@ EXPORT_SYMBOL(mmc_spi_get_pdata);
 void mmc_spi_put_pdata(struct spi_device *spi)
 {
 	struct device *dev = &spi->dev;
-	struct device_node *np = dev_archdata_get_node(&dev->archdata);
+	struct device_node *np = dev->of_node;
 	struct of_mmc_spi *oms = to_of_mmc_spi(dev);
 	int i;
 
diff --git a/drivers/of/of_i2c.c b/drivers/of/of_i2c.c
index 605bc42..43f803e 100644
--- a/drivers/of/of_i2c.c
+++ b/drivers/of/of_i2c.c
@@ -69,7 +69,7 @@ EXPORT_SYMBOL(of_register_i2c_devices);
 
 static int of_dev_node_match(struct device *dev, void *data)
 {
-        return dev_archdata_get_node(&dev->archdata) == data;
+        return dev->of_node == data;
 }
 
 /* must call put_device() when done with returned i2c_client device */
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 3bf20bf..64e08d7 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -101,7 +101,7 @@ EXPORT_SYMBOL(of_mdiobus_register);
 /* Helper function for of_phy_find_device */
 static int of_phy_match(struct device *dev, void *phy_np)
 {
-	return dev_archdata_get_node(&dev->archdata) == phy_np;
+	return dev->of_node == phy_np;
 }
 
 /**
@@ -167,7 +167,7 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 	if (!dev->dev.parent)
 		return NULL;
 
-	net_np = dev_archdata_get_node(&dev->dev.parent->archdata);
+	net_np = dev->dev.parent->of_node;
 	if (!net_np)
 		return NULL;
 
diff --git a/drivers/spi/spi_mpc8xxx.c b/drivers/spi/spi_mpc8xxx.c
index 4f0cc9d..38b9c32 100644
--- a/drivers/spi/spi_mpc8xxx.c
+++ b/drivers/spi/spi_mpc8xxx.c
@@ -796,7 +796,7 @@ static void mpc8xxx_spi_free_dummy_rx(void)
 static unsigned long mpc8xxx_spi_cpm_get_pram(struct mpc8xxx_spi *mspi)
 {
 	struct device *dev = mspi->dev;
-	struct device_node *np = dev_archdata_get_node(&dev->archdata);
+	struct device_node *np = dev->of_node;
 	const u32 *iprop;
 	int size;
 	unsigned long spi_base_ofs;
@@ -850,7 +850,7 @@ static unsigned long mpc8xxx_spi_cpm_get_pram(struct mpc8xxx_spi *mspi)
 static int mpc8xxx_spi_cpm_init(struct mpc8xxx_spi *mspi)
 {
 	struct device *dev = mspi->dev;
-	struct device_node *np = dev_archdata_get_node(&dev->archdata);
+	struct device_node *np = dev->of_node;
 	const u32 *iprop;
 	int size;
 	unsigned long pram_ofs;
@@ -1122,7 +1122,7 @@ static void mpc8xxx_spi_cs_control(struct spi_device *spi, bool on)
 
 static int of_mpc8xxx_spi_get_chipselects(struct device *dev)
 {
-	struct device_node *np = dev_archdata_get_node(&dev->archdata);
+	struct device_node *np = dev->of_node;
 	struct fsl_spi_platform_data *pdata = dev->platform_data;
 	struct mpc8xxx_spi_probe_info *pinfo = to_of_pinfo(pdata);
 	unsigned int ngpios;

