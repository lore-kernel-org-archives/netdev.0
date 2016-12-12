From: Bartosz Folta <bfolta@cadence.com>
Subject: [PATCH v2] net: macb: Added PCI wrapper for Platform Driver.
Date: Mon, 12 Dec 2016 10:29:28 +0000
Message-ID: <SN1PR0701MB1951E07687DBD871E4F1BF31CC980@SN1PR0701MB1951.namprd07.prod.outlook.com>
References: <1481537461-9587-1-git-send-email-bfolta@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Bartosz Folta <bfolta@cadence.com>,
        Rafal Ozieblo <rafalo@cadence.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Niklas Cassel <niklas.cassel@axis.com>,
        "Alexandre Torgue" <alexandre.torgue@st.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Simon Horman <simon.horman@netronome.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481537461-9587-1-git-send-email-bfolta@cadence.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are hardware PCI implementations of Cadence GEM network
controller. This patch will allow to use such hardware with reuse of
existing Platform Driver.

Signed-off-by: Bartosz Folta <bfolta@cadence.com>
---
Changed in v2:
Respin to net-next. Changed patch formatting.
---
 drivers/net/ethernet/cadence/Kconfig    |   9 ++
 drivers/net/ethernet/cadence/Makefile   |   1 +
 drivers/net/ethernet/cadence/macb.c     |  31 +++++--
 drivers/net/ethernet/cadence/macb_pci.c | 152 ++++++++++++++++++++++++++++=
++++
 include/linux/platform_data/macb.h      |   6 ++
 5 files changed, 194 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/cadence/macb_pci.c

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/ca=
dence/Kconfig
index f0bcb15..00d833e 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -31,4 +31,13 @@ config MACB
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
=20
+config MACB_PCI
+	tristate "Cadence PCI MACB/GEM support"
+	depends on MACB
+	---help---
+	  This is PCI wrapper for MACB driver.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called macb_pci.
+
 endif # NET_CADENCE
diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/c=
adence/Makefile
index 91f79b1..4ba7559 100644
--- a/drivers/net/ethernet/cadence/Makefile
+++ b/drivers/net/ethernet/cadence/Makefile
@@ -3,3 +3,4 @@
 #
=20
 obj-$(CONFIG_MACB) +=3D macb.o
+obj-$(CONFIG_MACB_PCI) +=3D macb_pci.o
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cad=
ence/macb.c
index 538544a..c0fb80a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -404,6 +404,8 @@ static int macb_mii_probe(struct net_device *dev)
 			phy_irq =3D gpio_to_irq(pdata->phy_irq_pin);
 			phydev->irq =3D (phy_irq < 0) ? PHY_POLL : phy_irq;
 		}
+	} else {
+		phydev->irq =3D PHY_POLL;
 	}
=20
 	/* attach the mac to the phy */
@@ -482,6 +484,9 @@ static int macb_mii_init(struct macb *bp)
 				goto err_out_unregister_bus;
 		}
 	} else {
+		for (i =3D 0; i < PHY_MAX_ADDR; i++)
+			bp->mii_bus->irq[i] =3D PHY_POLL;
+
 		if (pdata)
 			bp->mii_bus->phy_mask =3D pdata->phy_mask;
=20
@@ -2523,16 +2528,24 @@ static int macb_clk_init(struct platform_device *pd=
ev, struct clk **pclk,
 			 struct clk **hclk, struct clk **tx_clk,
 			 struct clk **rx_clk)
 {
+	struct macb_platform_data *pdata;
 	int err;
=20
-	*pclk =3D devm_clk_get(&pdev->dev, "pclk");
+	pdata =3D dev_get_platdata(&pdev->dev);
+	if (pdata) {
+		*pclk =3D pdata->pclk;
+		*hclk =3D pdata->hclk;
+	} else {
+		*pclk =3D devm_clk_get(&pdev->dev, "pclk");
+		*hclk =3D devm_clk_get(&pdev->dev, "hclk");
+	}
+
 	if (IS_ERR(*pclk)) {
 		err =3D PTR_ERR(*pclk);
 		dev_err(&pdev->dev, "failed to get macb_clk (%u)\n", err);
 		return err;
 	}
=20
-	*hclk =3D devm_clk_get(&pdev->dev, "hclk");
 	if (IS_ERR(*hclk)) {
 		err =3D PTR_ERR(*hclk);
 		dev_err(&pdev->dev, "failed to get hclk (%u)\n", err);
@@ -3107,15 +3120,23 @@ static int at91ether_init(struct platform_device *p=
dev)
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
 #endif /* CONFIG_OF */
=20
+static const struct macb_config default_gem_config =3D {
+	.caps =3D MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
+	.dma_burst_length =3D 16,
+	.clk_init =3D macb_clk_init,
+	.init =3D macb_init,
+	.jumbo_max_len =3D 10240,
+};
+
 static int macb_probe(struct platform_device *pdev)
 {
+	const struct macb_config *macb_config =3D &default_gem_config;
 	int (*clk_init)(struct platform_device *, struct clk **,
 			struct clk **, struct clk **,  struct clk **)
-					      =3D macb_clk_init;
-	int (*init)(struct platform_device *) =3D macb_init;
+					      =3D macb_config->clk_init;
+	int (*init)(struct platform_device *) =3D macb_config->init;
 	struct device_node *np =3D pdev->dev.of_node;
 	struct device_node *phy_node;
-	const struct macb_config *macb_config =3D NULL;
 	struct clk *pclk, *hclk =3D NULL, *tx_clk =3D NULL, *rx_clk =3D NULL;
 	unsigned int queue_mask, num_queues;
 	struct macb_platform_data *pdata;
diff --git a/drivers/net/ethernet/cadence/macb_pci.c b/drivers/net/ethernet=
/cadence/macb_pci.c
new file mode 100644
index 0000000..b440960
--- /dev/null
+++ b/drivers/net/ethernet/cadence/macb_pci.c
@@ -0,0 +1,152 @@
+/**
+ * macb_pci.c - Cadence GEM PCI wrapper.
+ *
+ * Copyright (C) 2016 Cadence Design Systems - http://www.cadence.com
+ *
+ * Authors: Rafal Ozieblo <rafalo@cadence.com>
+ *	    Bartosz Folta <bfolta@cadence.com>
+ *
+ * This program is free software: you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2  of
+ * the License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/clk.h>
+#include <linux/clk-provider.h>
+#include <linux/etherdevice.h>
+#include <linux/pci.h>
+#include <linux/platform_data/macb.h>
+#include <linux/platform_device.h>
+#include "macb.h"
+
+#define PCI_DRIVER_NAME "macb_pci"
+#define PLAT_DRIVER_NAME "macb"
+
+#define CDNS_VENDOR_ID 0x17cd
+#define CDNS_DEVICE_ID 0xe007
+
+#define GEM_PCLK_RATE 50000000
+#define GEM_HCLK_RATE 50000000
+
+static int macb_probe(struct pci_dev *pdev, const struct pci_device_id *id=
)
+{
+	int err;
+	struct platform_device *plat_dev;
+	struct platform_device_info plat_info;
+	struct macb_platform_data plat_data;
+	struct resource res[2];
+
+	/* sanity check */
+	if (!id)
+		return -EINVAL;
+
+	/* enable pci device */
+	err =3D pci_enable_device(pdev);
+	if (err < 0) {
+		dev_err(&pdev->dev, "Enabling PCI device has failed: 0x%04X",
+			err);
+		return -EACCES;
+	}
+
+	pci_set_master(pdev);
+
+	/* set up resources */
+	memset(res, 0x00, sizeof(struct resource) * ARRAY_SIZE(res));
+	res[0].start =3D pdev->resource[0].start;
+	res[0].end =3D pdev->resource[0].end;
+	res[0].name =3D PCI_DRIVER_NAME;
+	res[0].flags =3D IORESOURCE_MEM;
+	res[1].start =3D pdev->irq;
+	res[1].name =3D PCI_DRIVER_NAME;
+	res[1].flags =3D IORESOURCE_IRQ;
+
+	dev_info(&pdev->dev, "EMAC physical base addr =3D 0x%p\n",
+		 (void *)(uintptr_t)pci_resource_start(pdev, 0));
+
+	/* set up macb platform data */
+	memset(&plat_data, 0, sizeof(plat_data));
+
+	/* initialize clocks */
+	plat_data.pclk =3D clk_register_fixed_rate(&pdev->dev, "pclk", NULL, 0,
+						 GEM_PCLK_RATE);
+	if (IS_ERR(plat_data.pclk)) {
+		err =3D PTR_ERR(plat_data.pclk);
+		goto err_pclk_register;
+	}
+
+	plat_data.hclk =3D clk_register_fixed_rate(&pdev->dev, "hclk", NULL, 0,
+						 GEM_HCLK_RATE);
+	if (IS_ERR(plat_data.hclk)) {
+		err =3D PTR_ERR(plat_data.hclk);
+		goto err_hclk_register;
+	}
+
+	/* set up platform device info */
+	memset(&plat_info, 0, sizeof(plat_info));
+	plat_info.parent =3D &pdev->dev;
+	plat_info.fwnode =3D pdev->dev.fwnode;
+	plat_info.name =3D PLAT_DRIVER_NAME;
+	plat_info.id =3D pdev->devfn;
+	plat_info.res =3D res;
+	plat_info.num_res =3D ARRAY_SIZE(res);
+	plat_info.data =3D &plat_data;
+	plat_info.size_data =3D sizeof(plat_data);
+	plat_info.dma_mask =3D DMA_BIT_MASK(32);
+
+	/* register platform device */
+	plat_dev =3D platform_device_register_full(&plat_info);
+	if (IS_ERR(plat_dev)) {
+		err =3D PTR_ERR(plat_dev);
+		goto err_plat_dev_register;
+	}
+
+	pci_set_drvdata(pdev, plat_dev);
+
+	return 0;
+
+err_plat_dev_register:
+	clk_unregister(plat_data.hclk);
+
+err_hclk_register:
+	clk_unregister(plat_data.pclk);
+
+err_pclk_register:
+	pci_disable_device(pdev);
+	return err;
+}
+
+void macb_remove(struct pci_dev *pdev)
+{
+	struct platform_device *plat_dev =3D pci_get_drvdata(pdev);
+	struct macb_platform_data *plat_data =3D dev_get_platdata(&plat_dev->dev)=
;
+
+	platform_device_unregister(plat_dev);
+	pci_disable_device(pdev);
+	clk_unregister(plat_data->pclk);
+	clk_unregister(plat_data->hclk);
+}
+
+static struct pci_device_id dev_id_table[] =3D {
+	{ PCI_DEVICE(CDNS_VENDOR_ID, CDNS_DEVICE_ID), },
+	{ 0, }
+};
+
+static struct pci_driver macb_pci_driver =3D {
+	.name     =3D PCI_DRIVER_NAME,
+	.id_table =3D dev_id_table,
+	.probe    =3D macb_probe,
+	.remove	  =3D macb_remove,
+};
+
+module_pci_driver(macb_pci_driver);
+MODULE_DEVICE_TABLE(pci, dev_id_table);
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Cadence NIC PCI wrapper");
diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_da=
ta/macb.h
index 21b15f6..7815d50 100644
--- a/include/linux/platform_data/macb.h
+++ b/include/linux/platform_data/macb.h
@@ -8,6 +8,8 @@
 #ifndef __MACB_PDATA_H__
 #define __MACB_PDATA_H__
=20
+#include <linux/clk.h>
+
 /**
  * struct macb_platform_data - platform data for MACB Ethernet
  * @phy_mask:		phy mask passed when register the MDIO bus
@@ -15,12 +17,16 @@
  * @phy_irq_pin:	PHY IRQ
  * @is_rmii:		using RMII interface?
  * @rev_eth_addr:	reverse Ethernet address byte order
+ * @pclk:		platform clock
+ * @hclk:		AHB clock
  */
 struct macb_platform_data {
 	u32		phy_mask;
 	int		phy_irq_pin;
 	u8		is_rmii;
 	u8		rev_eth_addr;
+	struct clk	*pclk;
+	struct clk	*hclk;
 };
=20
 #endif /* __MACB_PDATA_H__ */
--=20
1.9.1
