From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH v1 net-next] net: dwc-xlgmac: Initial driver for DesignWare Enterprise Ethernet
Date: Wed, 1 Mar 2017 12:00:25 +0800
Message-ID: <9c5935b28ca61ec4ceb20bac0cc830e2e57028b9.1488331400.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:43974 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751763AbdCAEBD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 23:01:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Synopsys provides a new DesignWare Core Enterprise Ethernet MAC
IP (DWC-XLGMAC) for Ethernet designs. It is compliant with the
IEEE 802.3-2012 specifications, including IEEE 802.3ba and
consortium specifications.

This patch provides the initial 25G/40G/50G/100G Ethernet driver
for Synopsys XLGMAC IP Prototyping Kit.

Signed-off-by: Jie Deng <jiedeng@synopsys.com>
---
v1:
	- Initial dwc-xlgmac driver with a PCI glue
	- Configuration and build support
	- Maintainer information

 MAINTAINERS                                       |    6 +
 drivers/net/ethernet/Kconfig                      |    1 +
 drivers/net/ethernet/Makefile                     |    1 +
 drivers/net/ethernet/synopsys/Kconfig             |   41 +
 drivers/net/ethernet/synopsys/Makefile            |    9 +
 drivers/net/ethernet/synopsys/dwc-xlgmac-common.c |  740 +++++
 drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c   |  648 +++++
 drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c     | 3144 +++++++++++++++++++++
 drivers/net/ethernet/synopsys/dwc-xlgmac-net.c    | 1325 +++++++++
 drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c    |   80 +
 drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h    |  746 +++++
 drivers/net/ethernet/synopsys/dwc-xlgmac.h        |  651 +++++
 12 files changed, 7392 insertions(+)
 create mode 100644 drivers/net/ethernet/synopsys/Kconfig
 create mode 100644 drivers/net/ethernet/synopsys/Makefile
 create mode 100644 drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c
 create mode 100644 drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h
 create mode 100644 drivers/net/ethernet/synopsys/dwc-xlgmac.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 4b03c47..6f4a59a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11044,6 +11044,12 @@ F:	include/linux/dma/dw.h
 F:	include/linux/platform_data/dma-dw.h
 F:	drivers/dma/dw/
 
+SYNOPSYS DESIGNWARE ENTERPRISE ETHERNET DRIVER
+M:	Jie Deng <jiedeng@synopsys.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/synopsys/
+
 SYNOPSYS DESIGNWARE I2C DRIVER
 M:	Jarkko Nikula <jarkko.nikula@linux.intel.com>
 R:	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 8c08f9d..edae15ac 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -180,5 +180,6 @@ source "drivers/net/ethernet/via/Kconfig"
 source "drivers/net/ethernet/wiznet/Kconfig"
 source "drivers/net/ethernet/xilinx/Kconfig"
 source "drivers/net/ethernet/xircom/Kconfig"
+source "drivers/net/ethernet/synopsys/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 26dce5b..bf7f450 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -91,3 +91,4 @@ obj-$(CONFIG_NET_VENDOR_VIA) += via/
 obj-$(CONFIG_NET_VENDOR_WIZNET) += wiznet/
 obj-$(CONFIG_NET_VENDOR_XILINX) += xilinx/
 obj-$(CONFIG_NET_VENDOR_XIRCOM) += xircom/
+obj-$(CONFIG_NET_VENDOR_SYNOPSYS) += synopsys/
diff --git a/drivers/net/ethernet/synopsys/Kconfig b/drivers/net/ethernet/synopsys/Kconfig
new file mode 100644
index 0000000..a950388
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/Kconfig
@@ -0,0 +1,41 @@
+#
+# Synopsys network device configuration
+#
+
+config NET_VENDOR_SYNOPSYS
+	bool "Synopsys devices"
+	default y
+	---help---
+	  If you have a network (Ethernet) device belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Synopsys devices. If you say Y, you will be asked
+	  for your specific device in the following questions.
+
+if NET_VENDOR_SYNOPSYS
+
+config DWC_XLGMAC
+	tristate "Synopsys DWC Enterprise Ethernet (XLGMAC) driver support"
+	depends on HAS_IOMEM && HAS_DMA
+	select BITREVERSE
+	select CRC32
+	---help---
+	  This driver supports the Synopsys DesignWare Cores Enterprise
+	  Ethernet (dwc-xlgmac).
+
+if DWC_XLGMAC
+
+config DWC_XLGMAC_PCI
+	tristate "XLGMAC PCI bus support"
+	depends on DWC_XLGMAC && PCI
+	---help---
+	  This selects the pci bus support for the dwc-xlgmac driver.
+	  This driver was tested on Synopsys XLGMAC IP Prototyping Kit.
+
+	  If you have a controller with this interface, say Y or M here.
+	  If unsure, say N.
+
+endif # DWC_XLGMAC
+
+endif # NET_VENDOR_SYNOPSYS
diff --git a/drivers/net/ethernet/synopsys/Makefile b/drivers/net/ethernet/synopsys/Makefile
new file mode 100644
index 0000000..c06e2eb
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for the Synopsys network device drivers.
+#
+
+obj-$(CONFIG_DWC_XLGMAC) += dwc-xlgmac.o
+dwc-xlgmac-objs := dwc-xlgmac-net.o dwc-xlgmac-desc.o \
+		   dwc-xlgmac-hw.o dwc-xlgmac-common.o
+
+dwc-xlgmac-$(CONFIG_DWC_XLGMAC_PCI) += dwc-xlgmac-pci.o
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
new file mode 100644
index 0000000..559efea3
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
@@ -0,0 +1,740 @@
+/* Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This Synopsys DWC XLGMAC software driver and associated documentation
+ * (hereinafter the "Software") is an unsupported proprietary work of
+ * Synopsys, Inc. unless otherwise expressly agreed to in writing between
+ * Synopsys and you. The Software IS NOT an item of Licensed Software or a
+ * Licensed Product under any End User Software License Agreement or
+ * Agreement for Licensed Products with Synopsys or any supplement thereto.
+ * Synopsys is a registered trademark of Synopsys, Inc. Other names included
+ * in the SOFTWARE may be the trademarks of their respective owners.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+#include "dwc-xlgmac.h"
+#include "dwc-xlgmac-reg.h"
+
+static int debug = -1;
+module_param(debug, int, 0644);
+MODULE_PARM_DESC(debug, "DWC ethernet debug level (0=none,...,16=all)");
+static const u32 default_msg_level = (NETIF_MSG_LINK | NETIF_MSG_IFDOWN |
+				      NETIF_MSG_IFUP);
+
+static unsigned char dev_addr[6] = {0, 0x55, 0x7b, 0xb5, 0x7d, 0xf7};
+
+static void xlgmac_read_mac_addr(struct xlgmac_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+
+	/* Currently it uses a static mac address for test */
+	memcpy(pdata->mac_addr, dev_addr, netdev->addr_len);
+}
+
+static void xlgmac_default_config(struct xlgmac_pdata *pdata)
+{
+	pdata->tx_osp_mode = DMA_OSP_ENABLE;
+	pdata->tx_sf_mode = MTL_TSF_ENABLE;
+	pdata->rx_sf_mode = MTL_RSF_DISABLE;
+	pdata->pblx8 = DMA_PBL_X8_ENABLE;
+	pdata->tx_pbl = DMA_PBL_32;
+	pdata->rx_pbl = DMA_PBL_32;
+	pdata->tx_threshold = MTL_TX_THRESHOLD_128;
+	pdata->rx_threshold = MTL_RX_THRESHOLD_128;
+	pdata->tx_pause = 1;
+	pdata->rx_pause = 1;
+	pdata->phy_speed = SPEED_25000;
+	pdata->sysclk_rate = XLGMAC_SYSCLOCK;
+
+	strlcpy(pdata->drv_name, XLGMAC_DRV_NAME, sizeof(pdata->drv_name));
+	strlcpy(pdata->drv_ver, XLGMAC_DRV_VERSION, sizeof(pdata->drv_ver));
+}
+
+static void xlgmac_init_all_ops(struct xlgmac_pdata *pdata)
+{
+	xlgmac_init_desc_ops(&pdata->desc_ops);
+	xlgmac_init_hw_ops(&pdata->hw_ops);
+}
+
+static int xlgmac_init(struct xlgmac_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	unsigned int i;
+	int ret;
+
+	/* Set default configuration data */
+	xlgmac_default_config(pdata);
+
+	/* Set irq, base_addr, MAC address, */
+	netdev->irq = pdata->dev_irq;
+	netdev->base_addr = (unsigned long)pdata->mac_regs;
+	xlgmac_read_mac_addr(pdata);
+	memcpy(netdev->dev_addr, pdata->mac_addr, netdev->addr_len);
+
+	/* Set all the function pointers */
+	xlgmac_init_all_ops(pdata);
+
+	/* Issue software reset to device */
+	hw_ops->exit(pdata);
+
+	/* Populate the hardware features */
+	xlgmac_get_all_hw_features(pdata);
+	xlgmac_print_all_hw_features(pdata);
+
+	/* TODO: Set the PHY mode to XLGMII */
+
+	/* Set the DMA mask */
+	ret = dma_set_mask_and_coherent(pdata->dev,
+					DMA_BIT_MASK(pdata->hw_feat.dma_width));
+	if (ret) {
+		dev_err(pdata->dev, "dma_set_mask_and_coherent failed\n");
+		goto err_out;
+	}
+
+	/* Channel and ring params initializtion
+	 *  pdata->channel_count;
+	 *  pdata->tx_ring_count;
+	 *  pdata->rx_ring_count;
+	 *  pdata->tx_desc_count;
+	 *  pdata->rx_desc_count;
+	 */
+	BUILD_BUG_ON_NOT_POWER_OF_2(XLGMAC_TX_DESC_CNT);
+	pdata->tx_desc_count = XLGMAC_TX_DESC_CNT;
+	if (pdata->tx_desc_count & (pdata->tx_desc_count - 1)) {
+		dev_err(pdata->dev, "tx descriptor count (%d) is not valid\n",
+			pdata->tx_desc_count);
+		ret = -EINVAL;
+		goto err_out;
+	}
+	BUILD_BUG_ON_NOT_POWER_OF_2(XLGMAC_RX_DESC_CNT);
+	pdata->rx_desc_count = XLGMAC_RX_DESC_CNT;
+	if (pdata->rx_desc_count & (pdata->rx_desc_count - 1)) {
+		dev_err(pdata->dev, "rx descriptor count (%d) is not valid\n",
+			pdata->rx_desc_count);
+		ret = -EINVAL;
+		goto err_out;
+	}
+
+	pdata->tx_ring_count = min_t(unsigned int, num_online_cpus(),
+				     pdata->hw_feat.tx_ch_cnt);
+	pdata->tx_ring_count = min_t(unsigned int, pdata->tx_ring_count,
+				     pdata->hw_feat.tx_q_cnt);
+	pdata->tx_q_count = pdata->tx_ring_count;
+	ret = netif_set_real_num_tx_queues(netdev, pdata->tx_q_count);
+	if (ret) {
+		dev_err(pdata->dev, "error setting real tx queue count\n");
+		goto err_out;
+	}
+
+	pdata->rx_ring_count = min_t(unsigned int,
+				     netif_get_num_default_rss_queues(),
+				     pdata->hw_feat.rx_ch_cnt);
+	pdata->rx_ring_count = min_t(unsigned int, pdata->rx_ring_count,
+				     pdata->hw_feat.rx_q_cnt);
+	pdata->rx_q_count = pdata->rx_ring_count;
+	ret = netif_set_real_num_rx_queues(netdev, pdata->rx_q_count);
+	if (ret) {
+		dev_err(pdata->dev, "error setting real rx queue count\n");
+		goto err_out;
+	}
+
+	pdata->channel_count =
+		max_t(unsigned int, pdata->tx_ring_count, pdata->rx_ring_count);
+
+	/* Initialize RSS hash key and lookup table */
+	netdev_rss_key_fill(pdata->rss_key, sizeof(pdata->rss_key));
+
+	for (i = 0; i < XLGMAC_RSS_MAX_TABLE_SIZE; i++)
+		pdata->rss_table[i] = XLGMAC_SET_REG_BITS(
+					pdata->rss_table[i],
+					MAC_RSSDR_DMCH_POS,
+					MAC_RSSDR_DMCH_LEN,
+					i % pdata->rx_ring_count);
+
+	pdata->rss_options = XLGMAC_SET_REG_BITS(
+				pdata->rss_options,
+				MAC_RSSCR_IP2TE_POS,
+				MAC_RSSCR_IP2TE_LEN, 1);
+	pdata->rss_options = XLGMAC_SET_REG_BITS(
+				pdata->rss_options,
+				MAC_RSSCR_TCP4TE_POS,
+				MAC_RSSCR_TCP4TE_LEN, 1);
+	pdata->rss_options = XLGMAC_SET_REG_BITS(
+				pdata->rss_options,
+				MAC_RSSCR_UDP4TE_POS,
+				MAC_RSSCR_UDP4TE_LEN, 1);
+
+	/* Set device operations */
+	netdev->netdev_ops = xlgmac_get_netdev_ops();
+
+	/* Set device features */
+	if (pdata->hw_feat.tso) {
+		netdev->hw_features = NETIF_F_TSO;
+		netdev->hw_features |= NETIF_F_TSO6;
+		netdev->hw_features |= NETIF_F_SG;
+		netdev->hw_features |= NETIF_F_IP_CSUM;
+		netdev->hw_features |= NETIF_F_IPV6_CSUM;
+	} else if (pdata->hw_feat.tx_coe) {
+		netdev->hw_features = NETIF_F_IP_CSUM;
+		netdev->hw_features |= NETIF_F_IPV6_CSUM;
+	}
+
+	if (pdata->hw_feat.rx_coe) {
+		netdev->hw_features |= NETIF_F_RXCSUM;
+		netdev->hw_features |= NETIF_F_GRO;
+	}
+
+	if (pdata->hw_feat.rss)
+		netdev->hw_features |= NETIF_F_RXHASH;
+
+	netdev->vlan_features |= netdev->hw_features;
+
+	netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX;
+	if (pdata->hw_feat.sa_vlan_ins)
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX;
+	if (pdata->hw_feat.vlhash)
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	netdev->features |= netdev->hw_features;
+	pdata->netdev_features = netdev->features;
+
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
+	/* Use default watchdog timeout */
+	netdev->watchdog_timeo = 0;
+
+	/* Tx coalesce parameters initialization */
+	pdata->tx_usecs = XLGMAC_INIT_DMA_TX_USECS;
+	pdata->tx_frames = XLGMAC_INIT_DMA_TX_FRAMES;
+
+	/* Rx coalesce parameters initialization */
+	pdata->rx_riwt = hw_ops->usec_to_riwt(pdata, XLGMAC_INIT_DMA_RX_USECS);
+	pdata->rx_usecs = XLGMAC_INIT_DMA_RX_USECS;
+	pdata->rx_frames = XLGMAC_INIT_DMA_RX_FRAMES;
+
+	return 0;
+
+err_out:
+	return ret;
+}
+
+int xlgmac_drv_probe(struct device *dev, struct xlgmac_resources *res)
+{
+	struct xlgmac_pdata *pdata;
+	struct net_device *netdev;
+	int ret;
+
+	netdev = alloc_etherdev_mq(sizeof(struct xlgmac_pdata),
+				   XLGMAC_MAX_DMA_CHANNELS);
+
+	if (!netdev) {
+		dev_err(dev, "alloc_etherdev failed\n");
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(netdev, dev);
+	dev_set_drvdata(dev, netdev);
+	pdata = netdev_priv(netdev);
+	pdata->dev = dev;
+	pdata->netdev = netdev;
+
+	pdata->dev_irq = res->irq;
+	pdata->mac_regs = res->addr;
+
+	mutex_init(&pdata->rss_mutex);
+	pdata->msg_enable = netif_msg_init(debug, default_msg_level);
+
+	ret = xlgmac_init(pdata);
+	if (ret) {
+		dev_err(dev, "xlgmac init failed\n");
+		goto err_init;
+	}
+
+	ret = register_netdev(netdev);
+	if (ret) {
+		dev_err(dev, "net device registration failed\n");
+		goto err_netdev_register;
+	}
+
+	return 0;
+
+err_netdev_register:
+err_init:
+	free_netdev(netdev);
+
+	return ret;
+}
+
+int xlgmac_drv_remove(struct device *dev)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+
+	unregister_netdev(netdev);
+	free_netdev(netdev);
+
+	return 0;
+}
+
+void xlgmac_dump_tx_desc(struct xlgmac_pdata *pdata,
+			 struct xlgmac_ring *ring,
+			 unsigned int idx,
+			 unsigned int count,
+			 unsigned int flag)
+{
+	struct xlgmac_desc_data *desc_data;
+	struct xlgmac_dma_desc *dma_desc;
+
+	while (count--) {
+		desc_data = XLGMAC_GET_DESC_DATA(ring, idx);
+		dma_desc = desc_data->dma_desc;
+
+		netdev_dbg(pdata->netdev, "TX: dma_desc=%p, dma_desc_addr=%pad\n",
+			   desc_data->dma_desc, &desc_data->dma_desc_addr);
+		netdev_dbg(pdata->netdev,
+			   "TX_NORMAL_DESC[%d %s] = %08x:%08x:%08x:%08x\n", idx,
+			   (flag == 1) ? "QUEUED FOR TX" : "TX BY DEVICE",
+			   le32_to_cpu(dma_desc->desc0),
+			   le32_to_cpu(dma_desc->desc1),
+			   le32_to_cpu(dma_desc->desc2),
+			   le32_to_cpu(dma_desc->desc3));
+
+		idx++;
+	}
+}
+
+void xlgmac_dump_rx_desc(struct xlgmac_pdata *pdata,
+			 struct xlgmac_ring *ring,
+			 unsigned int idx)
+{
+	struct xlgmac_desc_data *desc_data;
+	struct xlgmac_dma_desc *dma_desc;
+
+	desc_data = XLGMAC_GET_DESC_DATA(ring, idx);
+	dma_desc = desc_data->dma_desc;
+
+	netdev_dbg(pdata->netdev, "RX: dma_desc=%p, dma_desc_addr=%pad\n",
+		   desc_data->dma_desc, &desc_data->dma_desc_addr);
+	netdev_dbg(pdata->netdev,
+		   "RX_NORMAL_DESC[%d RX BY DEVICE] = %08x:%08x:%08x:%08x\n",
+		   idx,
+		   le32_to_cpu(dma_desc->desc0),
+		   le32_to_cpu(dma_desc->desc1),
+		   le32_to_cpu(dma_desc->desc2),
+		   le32_to_cpu(dma_desc->desc3));
+}
+
+void xlgmac_print_pkt(struct net_device *netdev,
+		      struct sk_buff *skb, bool tx_rx)
+{
+	struct ethhdr *eth = (struct ethhdr *)skb->data;
+	unsigned char *buf = skb->data;
+	unsigned char buffer[128];
+	unsigned int i, j;
+
+	netdev_dbg(netdev, "\n************** SKB dump ****************\n");
+
+	netdev_dbg(netdev, "%s packet of %d bytes\n",
+		   (tx_rx ? "TX" : "RX"), skb->len);
+
+	netdev_dbg(netdev, "Dst MAC addr: %pM\n", eth->h_dest);
+	netdev_dbg(netdev, "Src MAC addr: %pM\n", eth->h_source);
+	netdev_dbg(netdev, "Protocol: %#06hx\n", ntohs(eth->h_proto));
+
+	for (i = 0, j = 0; i < skb->len;) {
+		j += snprintf(buffer + j, sizeof(buffer) - j, "%02hhx",
+			      buf[i++]);
+
+		if ((i % 32) == 0) {
+			netdev_dbg(netdev, "  %#06x: %s\n", i - 32, buffer);
+			j = 0;
+		} else if ((i % 16) == 0) {
+			buffer[j++] = ' ';
+			buffer[j++] = ' ';
+		} else if ((i % 4) == 0) {
+			buffer[j++] = ' ';
+		}
+	}
+	if (i % 32)
+		netdev_dbg(netdev, "  %#06x: %s\n", i - (i % 32), buffer);
+
+	netdev_dbg(netdev, "\n************** SKB dump ****************\n");
+}
+
+void xlgmac_get_all_hw_features(struct xlgmac_pdata *pdata)
+{
+	unsigned int mac_hfr0, mac_hfr1, mac_hfr2;
+	struct xlgmac_hw_features *hw_feat = &pdata->hw_feat;
+
+	mac_hfr0 = readl(pdata->mac_regs + MAC_HWF0R);
+	mac_hfr1 = readl(pdata->mac_regs + MAC_HWF1R);
+	mac_hfr2 = readl(pdata->mac_regs + MAC_HWF2R);
+
+	memset(hw_feat, 0, sizeof(*hw_feat));
+
+	hw_feat->version = readl(pdata->mac_regs + MAC_VR);
+
+	/* Hardware feature register 0 */
+	hw_feat->phyifsel    = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_PHYIFSEL_POS,
+						MAC_HWF0R_PHYIFSEL_LEN);
+	hw_feat->vlhash      = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_VLHASH_POS,
+						MAC_HWF0R_VLHASH_LEN);
+	hw_feat->sma         = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_SMASEL_POS,
+						MAC_HWF0R_SMASEL_LEN);
+	hw_feat->rwk         = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_RWKSEL_POS,
+						MAC_HWF0R_RWKSEL_LEN);
+	hw_feat->mgk         = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_MGKSEL_POS,
+						MAC_HWF0R_MGKSEL_LEN);
+	hw_feat->mmc         = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_MMCSEL_POS,
+						MAC_HWF0R_MMCSEL_LEN);
+	hw_feat->aoe         = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_ARPOFFSEL_POS,
+						MAC_HWF0R_ARPOFFSEL_LEN);
+	hw_feat->ts          = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_TSSEL_POS,
+						MAC_HWF0R_TSSEL_LEN);
+	hw_feat->eee         = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_EEESEL_POS,
+						MAC_HWF0R_EEESEL_LEN);
+	hw_feat->tx_coe      = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_TXCOESEL_POS,
+						MAC_HWF0R_TXCOESEL_LEN);
+	hw_feat->rx_coe      = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_RXCOESEL_POS,
+						MAC_HWF0R_RXCOESEL_LEN);
+	hw_feat->addn_mac    = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_ADDMACADRSEL_POS,
+						MAC_HWF0R_ADDMACADRSEL_LEN);
+	hw_feat->ts_src      = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_TSSTSSEL_POS,
+						MAC_HWF0R_TSSTSSEL_LEN);
+	hw_feat->sa_vlan_ins = XLGMAC_GET_REG_BITS(mac_hfr0,
+						MAC_HWF0R_SAVLANINS_POS,
+						MAC_HWF0R_SAVLANINS_LEN);
+
+	/* Hardware feature register 1 */
+	hw_feat->rx_fifo_size  = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_RXFIFOSIZE_POS,
+						MAC_HWF1R_RXFIFOSIZE_LEN);
+	hw_feat->tx_fifo_size  = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_TXFIFOSIZE_POS,
+						MAC_HWF1R_TXFIFOSIZE_LEN);
+	hw_feat->adv_ts_hi     = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_ADVTHWORD_POS,
+						MAC_HWF1R_ADVTHWORD_LEN);
+	hw_feat->dma_width     = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_ADDR64_POS,
+						MAC_HWF1R_ADDR64_LEN);
+	hw_feat->dcb           = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_DCBEN_POS,
+						MAC_HWF1R_DCBEN_LEN);
+	hw_feat->sph           = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_SPHEN_POS,
+						MAC_HWF1R_SPHEN_LEN);
+	hw_feat->tso           = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_TSOEN_POS,
+						MAC_HWF1R_TSOEN_LEN);
+	hw_feat->dma_debug     = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_DBGMEMA_POS,
+						MAC_HWF1R_DBGMEMA_LEN);
+	hw_feat->rss           = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_RSSEN_POS,
+						MAC_HWF1R_RSSEN_LEN);
+	hw_feat->tc_cnt	       = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_NUMTC_POS,
+						MAC_HWF1R_NUMTC_LEN);
+	hw_feat->hash_table_size = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_HASHTBLSZ_POS,
+						MAC_HWF1R_HASHTBLSZ_LEN);
+	hw_feat->l3l4_filter_num = XLGMAC_GET_REG_BITS(mac_hfr1,
+						MAC_HWF1R_L3L4FNUM_POS,
+						MAC_HWF1R_L3L4FNUM_LEN);
+
+	/* Hardware feature register 2 */
+	hw_feat->rx_q_cnt     = XLGMAC_GET_REG_BITS(mac_hfr2,
+						MAC_HWF2R_RXQCNT_POS,
+						MAC_HWF2R_RXQCNT_LEN);
+	hw_feat->tx_q_cnt     = XLGMAC_GET_REG_BITS(mac_hfr2,
+						MAC_HWF2R_TXQCNT_POS,
+						MAC_HWF2R_TXQCNT_LEN);
+	hw_feat->rx_ch_cnt    = XLGMAC_GET_REG_BITS(mac_hfr2,
+						MAC_HWF2R_RXCHCNT_POS,
+						MAC_HWF2R_RXCHCNT_LEN);
+	hw_feat->tx_ch_cnt    = XLGMAC_GET_REG_BITS(mac_hfr2,
+						MAC_HWF2R_TXCHCNT_POS,
+						MAC_HWF2R_TXCHCNT_LEN);
+	hw_feat->pps_out_num  = XLGMAC_GET_REG_BITS(mac_hfr2,
+						MAC_HWF2R_PPSOUTNUM_POS,
+						MAC_HWF2R_PPSOUTNUM_LEN);
+	hw_feat->aux_snap_num = XLGMAC_GET_REG_BITS(mac_hfr2,
+						MAC_HWF2R_AUXSNAPNUM_POS,
+						MAC_HWF2R_AUXSNAPNUM_LEN);
+
+	/* Translate the Hash Table size into actual number */
+	switch (hw_feat->hash_table_size) {
+	case 0:
+		break;
+	case 1:
+		hw_feat->hash_table_size = 64;
+		break;
+	case 2:
+		hw_feat->hash_table_size = 128;
+		break;
+	case 3:
+		hw_feat->hash_table_size = 256;
+		break;
+	}
+
+	/* Translate the address width setting into actual number */
+	switch (hw_feat->dma_width) {
+	case 0:
+		hw_feat->dma_width = 32;
+		break;
+	case 1:
+		hw_feat->dma_width = 40;
+		break;
+	case 2:
+		hw_feat->dma_width = 48;
+		break;
+	default:
+		hw_feat->dma_width = 32;
+	}
+
+	/* The Queue, Channel and TC counts are zero based so increment them
+	 * to get the actual number
+	 */
+	hw_feat->rx_q_cnt++;
+	hw_feat->tx_q_cnt++;
+	hw_feat->rx_ch_cnt++;
+	hw_feat->tx_ch_cnt++;
+	hw_feat->tc_cnt++;
+}
+
+void xlgmac_print_all_hw_features(struct xlgmac_pdata *pdata)
+{
+	char *str = NULL;
+
+	XLGMAC_PR("\n");
+	XLGMAC_PR("=====================================================\n");
+	XLGMAC_PR("\n");
+	XLGMAC_PR("HW support following features\n");
+	XLGMAC_PR("\n");
+	/* HW Feature Register0 */
+	XLGMAC_PR("VLAN Hash Filter Selected                   : %s\n",
+		  pdata->hw_feat.vlhash ? "YES" : "NO");
+	XLGMAC_PR("SMA (MDIO) Interface                        : %s\n",
+		  pdata->hw_feat.sma ? "YES" : "NO");
+	XLGMAC_PR("PMT Remote Wake-up Packet Enable            : %s\n",
+		  pdata->hw_feat.rwk ? "YES" : "NO");
+	XLGMAC_PR("PMT Magic Packet Enable                     : %s\n",
+		  pdata->hw_feat.mgk ? "YES" : "NO");
+	XLGMAC_PR("RMON/MMC Module Enable                      : %s\n",
+		  pdata->hw_feat.mmc ? "YES" : "NO");
+	XLGMAC_PR("ARP Offload Enabled                         : %s\n",
+		  pdata->hw_feat.aoe ? "YES" : "NO");
+	XLGMAC_PR("IEEE 1588-2008 Timestamp Enabled            : %s\n",
+		  pdata->hw_feat.ts ? "YES" : "NO");
+	XLGMAC_PR("Energy Efficient Ethernet Enabled           : %s\n",
+		  pdata->hw_feat.eee ? "YES" : "NO");
+	XLGMAC_PR("Transmit Checksum Offload Enabled           : %s\n",
+		  pdata->hw_feat.tx_coe ? "YES" : "NO");
+	XLGMAC_PR("Receive Checksum Offload Enabled            : %s\n",
+		  pdata->hw_feat.rx_coe ? "YES" : "NO");
+	XLGMAC_PR("Additional MAC Addresses 1-31 Selected      : %s\n",
+		  pdata->hw_feat.addn_mac ? "YES" : "NO");
+
+	switch (pdata->hw_feat.ts_src) {
+	case 0:
+		str = "RESERVED";
+		break;
+	case 1:
+		str = "INTERNAL";
+		break;
+	case 2:
+		str = "EXTERNAL";
+		break;
+	case 3:
+		str = "BOTH";
+		break;
+	}
+	XLGMAC_PR("Timestamp System Time Source                : %s\n", str);
+
+	XLGMAC_PR("Source Address or VLAN Insertion Enable     : %s\n",
+		  pdata->hw_feat.sa_vlan_ins ? "YES" : "NO");
+
+	/* HW Feature Register1 */
+	switch (pdata->hw_feat.rx_fifo_size) {
+	case 0:
+		str = "128 bytes";
+		break;
+	case 1:
+		str = "256 bytes";
+		break;
+	case 2:
+		str = "512 bytes";
+		break;
+	case 3:
+		str = "1 KBytes";
+		break;
+	case 4:
+		str = "2 KBytes";
+		break;
+	case 5:
+		str = "4 KBytes";
+		break;
+	case 6:
+		str = "8 KBytes";
+		break;
+	case 7:
+		str = "16 KBytes";
+		break;
+	case 8:
+		str = "32 kBytes";
+		break;
+	case 9:
+		str = "64 KBytes";
+		break;
+	case 10:
+		str = "128 KBytes";
+		break;
+	case 11:
+		str = "256 KBytes";
+		break;
+	default:
+		str = "RESERVED";
+	}
+	XLGMAC_PR("MTL Receive FIFO Size                       : %s\n", str);
+
+	switch (pdata->hw_feat.tx_fifo_size) {
+	case 0:
+		str = "128 bytes";
+		break;
+	case 1:
+		str = "256 bytes";
+		break;
+	case 2:
+		str = "512 bytes";
+		break;
+	case 3:
+		str = "1 KBytes";
+		break;
+	case 4:
+		str = "2 KBytes";
+		break;
+	case 5:
+		str = "4 KBytes";
+		break;
+	case 6:
+		str = "8 KBytes";
+		break;
+	case 7:
+		str = "16 KBytes";
+		break;
+	case 8:
+		str = "32 kBytes";
+		break;
+	case 9:
+		str = "64 KBytes";
+		break;
+	case 10:
+		str = "128 KBytes";
+		break;
+	case 11:
+		str = "256 KBytes";
+		break;
+	default:
+		str = "RESERVED";
+	}
+	XLGMAC_PR("MTL Transmit FIFO Size                      : %s\n", str);
+
+	XLGMAC_PR("IEEE 1588 High Word Register Enable         : %s\n",
+		  pdata->hw_feat.adv_ts_hi ? "YES" : "NO");
+	XLGMAC_PR("Address width                               : %u\n",
+		  pdata->hw_feat.dma_width);
+	XLGMAC_PR("DCB Feature Enable                          : %s\n",
+		  pdata->hw_feat.dcb ? "YES" : "NO");
+	XLGMAC_PR("Split Header Feature Enable                 : %s\n",
+		  pdata->hw_feat.sph ? "YES" : "NO");
+	XLGMAC_PR("TCP Segmentation Offload Enable             : %s\n",
+		  pdata->hw_feat.tso ? "YES" : "NO");
+	XLGMAC_PR("DMA Debug Registers Enabled                 : %s\n",
+		  pdata->hw_feat.dma_debug ? "YES" : "NO");
+	XLGMAC_PR("RSS Feature Enabled                         : %s\n",
+		  pdata->hw_feat.rss ? "YES" : "NO");
+	XLGMAC_PR("Number of Traffic classes                   : %u\n",
+		  (pdata->hw_feat.tc_cnt));
+	XLGMAC_PR("Hash Table Size                             : %u\n",
+		  pdata->hw_feat.hash_table_size);
+	XLGMAC_PR("Total number of L3 or L4 Filters            : %u\n",
+		  pdata->hw_feat.l3l4_filter_num);
+
+	/* HW Feature Register2 */
+	XLGMAC_PR("Number of MTL Receive Queues                : %u\n",
+		  pdata->hw_feat.rx_q_cnt);
+	XLGMAC_PR("Number of MTL Transmit Queues               : %u\n",
+		  pdata->hw_feat.tx_q_cnt);
+	XLGMAC_PR("Number of DMA Receive Channels              : %u\n",
+		  pdata->hw_feat.rx_ch_cnt);
+	XLGMAC_PR("Number of DMA Transmit Channels             : %u\n",
+		  pdata->hw_feat.tx_ch_cnt);
+
+	switch (pdata->hw_feat.pps_out_num) {
+	case 0:
+		str = "No PPS output";
+		break;
+	case 1:
+		str = "1 PPS output";
+		break;
+	case 2:
+		str = "2 PPS output";
+		break;
+	case 3:
+		str = "3 PPS output";
+		break;
+	case 4:
+		str = "4 PPS output";
+		break;
+	default:
+		str = "RESERVED";
+	}
+	XLGMAC_PR("Number of PPS Outputs                       : %s\n", str);
+
+	switch (pdata->hw_feat.aux_snap_num) {
+	case 0:
+		str = "No auxiliary input";
+		break;
+	case 1:
+		str = "1 auxiliary input";
+		break;
+	case 2:
+		str = "2 auxiliary input";
+		break;
+	case 3:
+		str = "3 auxiliary input";
+		break;
+	case 4:
+		str = "4 auxiliary input";
+		break;
+	default:
+		str = "RESERVED";
+	}
+	XLGMAC_PR("Number of Auxiliary Snapshot Inputs         : %s", str);
+
+	XLGMAC_PR("\n");
+	XLGMAC_PR("=====================================================\n");
+	XLGMAC_PR("\n");
+}
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
new file mode 100644
index 0000000..caa8fc4
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
@@ -0,0 +1,648 @@
+/* Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This Synopsys DWC XLGMAC software driver and associated documentation
+ * (hereinafter the "Software") is an unsupported proprietary work of
+ * Synopsys, Inc. unless otherwise expressly agreed to in writing between
+ * Synopsys and you. The Software IS NOT an item of Licensed Software or a
+ * Licensed Product under any End User Software License Agreement or
+ * Agreement for Licensed Products with Synopsys or any supplement thereto.
+ * Synopsys is a registered trademark of Synopsys, Inc. Other names included
+ * in the SOFTWARE may be the trademarks of their respective owners.
+ */
+
+#include "dwc-xlgmac.h"
+#include "dwc-xlgmac-reg.h"
+
+static void xlgmac_unmap_desc_data(struct xlgmac_pdata *pdata,
+				   struct xlgmac_desc_data *desc_data)
+{
+	if (desc_data->skb_dma) {
+		if (desc_data->mapped_as_page) {
+			dma_unmap_page(pdata->dev, desc_data->skb_dma,
+				       desc_data->skb_dma_len, DMA_TO_DEVICE);
+		} else {
+			dma_unmap_single(pdata->dev, desc_data->skb_dma,
+					 desc_data->skb_dma_len, DMA_TO_DEVICE);
+		}
+		desc_data->skb_dma = 0;
+		desc_data->skb_dma_len = 0;
+	}
+
+	if (desc_data->skb) {
+		dev_kfree_skb_any(desc_data->skb);
+		desc_data->skb = NULL;
+	}
+
+	if (desc_data->rx.hdr.pa.pages)
+		put_page(desc_data->rx.hdr.pa.pages);
+
+	if (desc_data->rx.hdr.pa_unmap.pages) {
+		dma_unmap_page(pdata->dev, desc_data->rx.hdr.pa_unmap.pages_dma,
+			       desc_data->rx.hdr.pa_unmap.pages_len,
+			       DMA_FROM_DEVICE);
+		put_page(desc_data->rx.hdr.pa_unmap.pages);
+	}
+
+	if (desc_data->rx.buf.pa.pages)
+		put_page(desc_data->rx.buf.pa.pages);
+
+	if (desc_data->rx.buf.pa_unmap.pages) {
+		dma_unmap_page(pdata->dev, desc_data->rx.buf.pa_unmap.pages_dma,
+			       desc_data->rx.buf.pa_unmap.pages_len,
+			       DMA_FROM_DEVICE);
+		put_page(desc_data->rx.buf.pa_unmap.pages);
+	}
+
+	memset(&desc_data->tx, 0, sizeof(desc_data->tx));
+	memset(&desc_data->rx, 0, sizeof(desc_data->rx));
+
+	desc_data->mapped_as_page = 0;
+
+	if (desc_data->state_saved) {
+		desc_data->state_saved = 0;
+		desc_data->state.skb = NULL;
+		desc_data->state.len = 0;
+		desc_data->state.error = 0;
+	}
+}
+
+static void xlgmac_free_ring(struct xlgmac_pdata *pdata,
+			     struct xlgmac_ring *ring)
+{
+	struct xlgmac_desc_data *desc_data;
+	unsigned int i;
+
+	if (!ring)
+		return;
+
+	if (ring->desc_data_head) {
+		for (i = 0; i < ring->dma_desc_count; i++) {
+			desc_data = XLGMAC_GET_DESC_DATA(ring, i);
+			xlgmac_unmap_desc_data(pdata, desc_data);
+		}
+
+		kfree(ring->desc_data_head);
+		ring->desc_data_head = NULL;
+	}
+
+	if (ring->rx_hdr_pa.pages) {
+		dma_unmap_page(pdata->dev, ring->rx_hdr_pa.pages_dma,
+			       ring->rx_hdr_pa.pages_len, DMA_FROM_DEVICE);
+		put_page(ring->rx_hdr_pa.pages);
+
+		ring->rx_hdr_pa.pages = NULL;
+		ring->rx_hdr_pa.pages_len = 0;
+		ring->rx_hdr_pa.pages_offset = 0;
+		ring->rx_hdr_pa.pages_dma = 0;
+	}
+
+	if (ring->rx_buf_pa.pages) {
+		dma_unmap_page(pdata->dev, ring->rx_buf_pa.pages_dma,
+			       ring->rx_buf_pa.pages_len, DMA_FROM_DEVICE);
+		put_page(ring->rx_buf_pa.pages);
+
+		ring->rx_buf_pa.pages = NULL;
+		ring->rx_buf_pa.pages_len = 0;
+		ring->rx_buf_pa.pages_offset = 0;
+		ring->rx_buf_pa.pages_dma = 0;
+	}
+
+	if (ring->dma_desc_head) {
+		dma_free_coherent(pdata->dev,
+				  (sizeof(struct xlgmac_dma_desc) *
+				  ring->dma_desc_count),
+				  ring->dma_desc_head,
+				  ring->dma_desc_head_addr);
+		ring->dma_desc_head = NULL;
+	}
+}
+
+static int xlgmac_init_ring(struct xlgmac_pdata *pdata,
+			    struct xlgmac_ring *ring,
+			    unsigned int dma_desc_count)
+{
+	if (!ring)
+		return 0;
+
+	/* Descriptors */
+	ring->dma_desc_count = dma_desc_count;
+	ring->dma_desc_head = dma_alloc_coherent(pdata->dev,
+					(sizeof(struct xlgmac_dma_desc) *
+					 dma_desc_count),
+					&ring->dma_desc_head_addr,
+					GFP_KERNEL);
+	if (!ring->dma_desc_head)
+		return -ENOMEM;
+
+	/* Array of descriptor data */
+	ring->desc_data_head = kcalloc(dma_desc_count,
+					sizeof(struct xlgmac_desc_data),
+					GFP_KERNEL);
+	if (!ring->desc_data_head)
+		return -ENOMEM;
+
+	netif_dbg(pdata, drv, pdata->netdev,
+		  "dma_desc_head=%p, dma_desc_head_addr=%pad, desc_data_head=%p\n",
+		ring->dma_desc_head,
+		&ring->dma_desc_head_addr,
+		ring->desc_data_head);
+
+	return 0;
+}
+
+static void xlgmac_free_rings(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+
+	if (!pdata->channel_head)
+		return;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		xlgmac_free_ring(pdata, channel->tx_ring);
+		xlgmac_free_ring(pdata, channel->rx_ring);
+	}
+}
+
+static int xlgmac_alloc_rings(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	int ret;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		netif_dbg(pdata, drv, pdata->netdev, "%s - Tx ring:\n",
+			  channel->name);
+
+		ret = xlgmac_init_ring(pdata, channel->tx_ring,
+				       pdata->tx_desc_count);
+
+		if (ret) {
+			netdev_alert(pdata->netdev,
+				     "error initializing Tx ring");
+			goto err_ring;
+		}
+
+		netif_dbg(pdata, drv, pdata->netdev, "%s - Rx ring:\n",
+			  channel->name);
+
+		ret = xlgmac_init_ring(pdata, channel->rx_ring,
+				       pdata->rx_desc_count);
+		if (ret) {
+			netdev_alert(pdata->netdev,
+				     "error initializing Rx ring\n");
+			goto err_ring;
+		}
+	}
+
+	return 0;
+
+err_ring:
+	xlgmac_free_rings(pdata);
+
+	return ret;
+}
+
+static void xlgmac_free_channels(struct xlgmac_pdata *pdata)
+{
+	if (!pdata->channel_head)
+		return;
+
+	kfree(pdata->channel_head->tx_ring);
+	pdata->channel_head->tx_ring = NULL;
+
+	kfree(pdata->channel_head->rx_ring);
+	pdata->channel_head->rx_ring = NULL;
+
+	kfree(pdata->channel_head);
+
+	pdata->channel_head = NULL;
+	pdata->channel_count = 0;
+}
+
+static int xlgmac_alloc_channels(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel_head, *channel;
+	struct xlgmac_ring *tx_ring, *rx_ring;
+	unsigned int i;
+	int ret = -ENOMEM;
+
+	channel_head = kcalloc(pdata->channel_count,
+			       sizeof(struct xlgmac_channel), GFP_KERNEL);
+	if (!channel_head)
+		goto err_channel;
+
+	netif_dbg(pdata, drv, pdata->netdev,
+		  "channel_head=%p\n", channel_head);
+
+	tx_ring = kcalloc(pdata->tx_ring_count, sizeof(struct xlgmac_ring),
+			  GFP_KERNEL);
+	if (!tx_ring)
+		goto err_tx_ring;
+
+	rx_ring = kcalloc(pdata->rx_ring_count, sizeof(struct xlgmac_ring),
+			  GFP_KERNEL);
+	if (!rx_ring)
+		goto err_rx_ring;
+
+	for (i = 0, channel = channel_head; i < pdata->channel_count;
+		i++, channel++) {
+		snprintf(channel->name, sizeof(channel->name), "channel-%u", i);
+		channel->pdata = pdata;
+		channel->queue_index = i;
+		channel->dma_regs = pdata->mac_regs + DMA_CH_BASE +
+				    (DMA_CH_INC * i);
+
+		if (pdata->per_channel_irq) {
+			/* Get the per DMA interrupt */
+			ret = pdata->channel_irq[i];
+			if (ret < 0) {
+				netdev_err(pdata->netdev,
+					   "get_irq %u failed\n",
+					   i + 1);
+				goto err_irq;
+			}
+			channel->dma_irq = ret;
+		}
+
+		if (i < pdata->tx_ring_count)
+			channel->tx_ring = tx_ring++;
+
+		if (i < pdata->rx_ring_count)
+			channel->rx_ring = rx_ring++;
+
+		netif_dbg(pdata, drv, pdata->netdev,
+			  "%s: dma_regs=%p, tx_ring=%p, rx_ring=%p\n",
+			  channel->name, channel->dma_regs,
+			  channel->tx_ring, channel->rx_ring);
+	}
+
+	pdata->channel_head = channel_head;
+
+	return 0;
+
+err_irq:
+	kfree(rx_ring);
+
+err_rx_ring:
+	kfree(tx_ring);
+
+err_tx_ring:
+	kfree(channel_head);
+
+err_channel:
+	return ret;
+}
+
+static void xlgmac_free_channels_and_rings(struct xlgmac_pdata *pdata)
+{
+	xlgmac_free_rings(pdata);
+
+	xlgmac_free_channels(pdata);
+}
+
+static int xlgmac_alloc_channels_and_rings(struct xlgmac_pdata *pdata)
+{
+	int ret;
+
+	ret = xlgmac_alloc_channels(pdata);
+	if (ret)
+		goto err_alloc;
+
+	ret = xlgmac_alloc_rings(pdata);
+	if (ret)
+		goto err_alloc;
+
+	return 0;
+
+err_alloc:
+	xlgmac_free_channels_and_rings(pdata);
+
+	return ret;
+}
+
+static int xlgmac_alloc_pages(struct xlgmac_pdata *pdata,
+			      struct xlgmac_page_alloc *pa,
+			      gfp_t gfp, int order)
+{
+	struct page *pages = NULL;
+	dma_addr_t pages_dma;
+	int ret;
+
+	/* Try to obtain pages, decreasing order if necessary */
+	gfp |= __GFP_COLD | __GFP_COMP | __GFP_NOWARN;
+	while (order >= 0) {
+		pages = alloc_pages(gfp, order);
+		if (pages)
+			break;
+
+		order--;
+	}
+	if (!pages)
+		return -ENOMEM;
+
+	/* Map the pages */
+	pages_dma = dma_map_page(pdata->dev, pages, 0,
+				 PAGE_SIZE << order, DMA_FROM_DEVICE);
+	ret = dma_mapping_error(pdata->dev, pages_dma);
+	if (ret) {
+		put_page(pages);
+		return ret;
+	}
+
+	pa->pages = pages;
+	pa->pages_len = PAGE_SIZE << order;
+	pa->pages_offset = 0;
+	pa->pages_dma = pages_dma;
+
+	return 0;
+}
+
+static void xlgmac_set_buffer_data(struct xlgmac_buffer_data *bd,
+				   struct xlgmac_page_alloc *pa,
+				   unsigned int len)
+{
+	get_page(pa->pages);
+	bd->pa = *pa;
+
+	bd->dma_base = pa->pages_dma;
+	bd->dma_off = pa->pages_offset;
+	bd->dma_len = len;
+
+	pa->pages_offset += len;
+	if ((pa->pages_offset + len) > pa->pages_len) {
+		/* This data descriptor is responsible for unmapping page(s) */
+		bd->pa_unmap = *pa;
+
+		/* Get a new allocation next time */
+		pa->pages = NULL;
+		pa->pages_len = 0;
+		pa->pages_offset = 0;
+		pa->pages_dma = 0;
+	}
+}
+
+static int xlgmac_map_rx_buffer(struct xlgmac_pdata *pdata,
+				struct xlgmac_ring *ring,
+				struct xlgmac_desc_data *desc_data)
+{
+	int order, ret;
+
+	if (!ring->rx_hdr_pa.pages) {
+		ret = xlgmac_alloc_pages(pdata, &ring->rx_hdr_pa,
+					 GFP_ATOMIC, 0);
+		if (ret)
+			return ret;
+	}
+
+	if (!ring->rx_buf_pa.pages) {
+		order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
+		ret = xlgmac_alloc_pages(pdata, &ring->rx_buf_pa,
+					 GFP_ATOMIC, order);
+		if (ret)
+			return ret;
+	}
+
+	/* Set up the header page info */
+	xlgmac_set_buffer_data(&desc_data->rx.hdr, &ring->rx_hdr_pa,
+			       XLGMAC_SKB_ALLOC_SIZE);
+
+	/* Set up the buffer page info */
+	xlgmac_set_buffer_data(&desc_data->rx.buf, &ring->rx_buf_pa,
+			       pdata->rx_buf_size);
+
+	return 0;
+}
+
+static void xlgmac_tx_desc_init(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_channel *channel;
+	struct xlgmac_ring *ring;
+	struct xlgmac_dma_desc *dma_desc;
+	struct xlgmac_desc_data *desc_data;
+	dma_addr_t dma_desc_addr;
+	unsigned int i, j;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->tx_ring;
+		if (!ring)
+			break;
+
+		dma_desc = ring->dma_desc_head;
+		dma_desc_addr = ring->dma_desc_head_addr;
+
+		for (j = 0; j < ring->dma_desc_count; j++) {
+			desc_data = XLGMAC_GET_DESC_DATA(ring, j);
+
+			desc_data->dma_desc = dma_desc;
+			desc_data->dma_desc_addr = dma_desc_addr;
+
+			dma_desc++;
+			dma_desc_addr += sizeof(struct xlgmac_dma_desc);
+		}
+
+		ring->cur = 0;
+		ring->dirty = 0;
+		memset(&ring->tx, 0, sizeof(ring->tx));
+
+		hw_ops->tx_desc_init(channel);
+	}
+}
+
+static void xlgmac_rx_desc_init(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_channel *channel;
+	struct xlgmac_ring *ring;
+	struct xlgmac_dma_desc *dma_desc;
+	struct xlgmac_desc_data *desc_data;
+	dma_addr_t dma_desc_addr;
+	unsigned int i, j;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->rx_ring;
+		if (!ring)
+			break;
+
+		dma_desc = ring->dma_desc_head;
+		dma_desc_addr = ring->dma_desc_head_addr;
+
+		for (j = 0; j < ring->dma_desc_count; j++) {
+			desc_data = XLGMAC_GET_DESC_DATA(ring, j);
+
+			desc_data->dma_desc = dma_desc;
+			desc_data->dma_desc_addr = dma_desc_addr;
+
+			if (xlgmac_map_rx_buffer(pdata, ring, desc_data))
+				break;
+
+			dma_desc++;
+			dma_desc_addr += sizeof(struct xlgmac_dma_desc);
+		}
+
+		ring->cur = 0;
+		ring->dirty = 0;
+
+		hw_ops->rx_desc_init(channel);
+	}
+}
+
+static int xlgmac_map_tx_skb(struct xlgmac_channel *channel,
+			     struct sk_buff *skb)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct xlgmac_ring *ring = channel->tx_ring;
+	struct xlgmac_desc_data *desc_data;
+	struct xlgmac_pkt_info *pkt_info;
+	struct skb_frag_struct *frag;
+	dma_addr_t skb_dma;
+	unsigned int start_index, cur_index;
+	unsigned int offset, tso, vlan, datalen, len;
+	unsigned int i;
+
+	offset = 0;
+	start_index = ring->cur;
+	cur_index = ring->cur;
+
+	pkt_info = &ring->pkt_info;
+	pkt_info->desc_count = 0;
+	pkt_info->length = 0;
+
+	tso = XLGMAC_GET_REG_BITS(pkt_info->attributes,
+				  TX_PACKET_ATTRIBUTES_TSO_ENABLE_POS,
+				  TX_PACKET_ATTRIBUTES_TSO_ENABLE_LEN);
+	vlan = XLGMAC_GET_REG_BITS(pkt_info->attributes,
+				   TX_PACKET_ATTRIBUTES_VLAN_CTAG_POS,
+				   TX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN);
+
+	/* Save space for a context descriptor if needed */
+	if ((tso && (pkt_info->mss != ring->tx.cur_mss)) ||
+	    (vlan && (pkt_info->vlan_ctag != ring->tx.cur_vlan_ctag)))
+		cur_index++;
+	desc_data = XLGMAC_GET_DESC_DATA(ring, cur_index);
+
+	if (tso) {
+		/* Map the TSO header */
+		skb_dma = dma_map_single(pdata->dev, skb->data,
+					 pkt_info->header_len, DMA_TO_DEVICE);
+		if (dma_mapping_error(pdata->dev, skb_dma)) {
+			netdev_alert(pdata->netdev, "dma_map_single failed\n");
+			goto err_out;
+		}
+		desc_data->skb_dma = skb_dma;
+		desc_data->skb_dma_len = pkt_info->header_len;
+		netif_dbg(pdata, tx_queued, pdata->netdev,
+			  "skb header: index=%u, dma=%pad, len=%u\n",
+			  cur_index, &skb_dma, pkt_info->header_len);
+
+		offset = pkt_info->header_len;
+
+		pkt_info->length += pkt_info->header_len;
+
+		cur_index++;
+		desc_data = XLGMAC_GET_DESC_DATA(ring, cur_index);
+	}
+
+	/* Map the (remainder of the) packet */
+	for (datalen = skb_headlen(skb) - offset; datalen; ) {
+		len = min_t(unsigned int, datalen, XLGMAC_TX_MAX_BUF_SIZE);
+
+		skb_dma = dma_map_single(pdata->dev, skb->data + offset, len,
+					 DMA_TO_DEVICE);
+		if (dma_mapping_error(pdata->dev, skb_dma)) {
+			netdev_alert(pdata->netdev, "dma_map_single failed\n");
+			goto err_out;
+		}
+		desc_data->skb_dma = skb_dma;
+		desc_data->skb_dma_len = len;
+		netif_dbg(pdata, tx_queued, pdata->netdev,
+			  "skb data: index=%u, dma=%pad, len=%u\n",
+			  cur_index, &skb_dma, len);
+
+		datalen -= len;
+		offset += len;
+
+		pkt_info->length += len;
+
+		cur_index++;
+		desc_data = XLGMAC_GET_DESC_DATA(ring, cur_index);
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		netif_dbg(pdata, tx_queued, pdata->netdev,
+			  "mapping frag %u\n", i);
+
+		frag = &skb_shinfo(skb)->frags[i];
+		offset = 0;
+
+		for (datalen = skb_frag_size(frag); datalen; ) {
+			len = min_t(unsigned int, datalen,
+				    XLGMAC_TX_MAX_BUF_SIZE);
+
+			skb_dma = skb_frag_dma_map(pdata->dev, frag, offset,
+						   len, DMA_TO_DEVICE);
+			if (dma_mapping_error(pdata->dev, skb_dma)) {
+				netdev_alert(pdata->netdev,
+					     "skb_frag_dma_map failed\n");
+				goto err_out;
+			}
+			desc_data->skb_dma = skb_dma;
+			desc_data->skb_dma_len = len;
+			desc_data->mapped_as_page = 1;
+			netif_dbg(pdata, tx_queued, pdata->netdev,
+				  "skb frag: index=%u, dma=%pad, len=%u\n",
+				  cur_index, &skb_dma, len);
+
+			datalen -= len;
+			offset += len;
+
+			pkt_info->length += len;
+
+			cur_index++;
+			desc_data = XLGMAC_GET_DESC_DATA(ring, cur_index);
+		}
+	}
+
+	/* Save the skb address in the last entry. We always have some data
+	 * that has been mapped so desc_data is always advanced past the last
+	 * piece of mapped data - use the entry pointed to by cur_index - 1.
+	 */
+	desc_data = XLGMAC_GET_DESC_DATA(ring, cur_index - 1);
+	desc_data->skb = skb;
+
+	/* Save the number of descriptor entries used */
+	pkt_info->desc_count = cur_index - start_index;
+
+	return pkt_info->desc_count;
+
+err_out:
+	while (start_index < cur_index) {
+		desc_data = XLGMAC_GET_DESC_DATA(ring, start_index++);
+		xlgmac_unmap_desc_data(pdata, desc_data);
+	}
+
+	return 0;
+}
+
+void xlgmac_init_desc_ops(struct xlgmac_desc_ops *desc_ops)
+{
+	desc_ops->alloc_channles_and_rings = xlgmac_alloc_channels_and_rings;
+	desc_ops->free_channels_and_rings = xlgmac_free_channels_and_rings;
+	desc_ops->map_tx_skb = xlgmac_map_tx_skb;
+	desc_ops->map_rx_buffer = xlgmac_map_rx_buffer;
+	desc_ops->unmap_desc_data = xlgmac_unmap_desc_data;
+	desc_ops->tx_desc_init = xlgmac_tx_desc_init;
+	desc_ops->rx_desc_init = xlgmac_rx_desc_init;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
new file mode 100644
index 0000000..1aa490c
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
@@ -0,0 +1,3144 @@
+/* Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This Synopsys DWC XLGMAC software driver and associated documentation
+ * (hereinafter the "Software") is an unsupported proprietary work of
+ * Synopsys, Inc. unless otherwise expressly agreed to in writing between
+ * Synopsys and you. The Software IS NOT an item of Licensed Software or a
+ * Licensed Product under any End User Software License Agreement or
+ * Agreement for Licensed Products with Synopsys or any supplement thereto.
+ * Synopsys is a registered trademark of Synopsys, Inc. Other names included
+ * in the SOFTWARE may be the trademarks of their respective owners.
+ */
+
+#include <linux/phy.h>
+#include <linux/mdio.h>
+#include <linux/clk.h>
+#include <linux/bitrev.h>
+#include <linux/crc32.h>
+
+#include "dwc-xlgmac.h"
+#include "dwc-xlgmac-reg.h"
+
+static int xlgmac_tx_complete(struct xlgmac_dma_desc *dma_desc)
+{
+	return !XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				TX_NORMAL_DESC3_OWN_POS,
+				TX_NORMAL_DESC3_OWN_LEN);
+}
+
+static int xlgmac_disable_rx_csum(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_RCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_IPC_POS,
+				     MAC_RCR_IPC_LEN, 0);
+	writel(regval, pdata->mac_regs + MAC_RCR);
+
+	return 0;
+}
+
+static int xlgmac_enable_rx_csum(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_RCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_IPC_POS,
+				     MAC_RCR_IPC_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_RCR);
+
+	return 0;
+}
+
+static int xlgmac_set_mac_address(struct xlgmac_pdata *pdata, u8 *addr)
+{
+	unsigned int mac_addr_hi, mac_addr_lo;
+
+	mac_addr_hi = (addr[5] <<  8) | (addr[4] <<  0);
+	mac_addr_lo = (addr[3] << 24) | (addr[2] << 16) |
+		      (addr[1] <<  8) | (addr[0] <<  0);
+
+	writel(mac_addr_hi, pdata->mac_regs + MAC_MACA0HR);
+	writel(mac_addr_lo, pdata->mac_regs + MAC_MACA0LR);
+
+	return 0;
+}
+
+static void xlgmac_set_mac_reg(struct xlgmac_pdata *pdata,
+			       struct netdev_hw_addr *ha,
+			       unsigned int *mac_reg)
+{
+	unsigned int mac_addr_hi, mac_addr_lo;
+	u8 *mac_addr;
+
+	mac_addr_lo = 0;
+	mac_addr_hi = 0;
+
+	if (ha) {
+		mac_addr = (u8 *)&mac_addr_lo;
+		mac_addr[0] = ha->addr[0];
+		mac_addr[1] = ha->addr[1];
+		mac_addr[2] = ha->addr[2];
+		mac_addr[3] = ha->addr[3];
+		mac_addr = (u8 *)&mac_addr_hi;
+		mac_addr[0] = ha->addr[4];
+		mac_addr[1] = ha->addr[5];
+
+		netif_dbg(pdata, drv, pdata->netdev,
+			  "adding mac address %pM at %#x\n",
+			  ha->addr, *mac_reg);
+
+		mac_addr_hi = XLGMAC_SET_REG_BITS(mac_addr_hi,
+						  MAC_MACA1HR_AE_POS,
+						MAC_MACA1HR_AE_LEN,
+						1);
+	}
+
+	writel(mac_addr_hi, pdata->mac_regs + *mac_reg);
+	*mac_reg += MAC_MACA_INC;
+	writel(mac_addr_lo, pdata->mac_regs + *mac_reg);
+	*mac_reg += MAC_MACA_INC;
+}
+
+static int xlgmac_enable_rx_vlan_stripping(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_VLANTR);
+	/* Put the VLAN tag in the Rx descriptor */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_EVLRXS_POS,
+				     MAC_VLANTR_EVLRXS_LEN, 1);
+	/* Don't check the VLAN type */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_DOVLTC_POS,
+				     MAC_VLANTR_DOVLTC_LEN, 1);
+	/* Check only C-TAG (0x8100) packets */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_ERSVLM_POS,
+				     MAC_VLANTR_ERSVLM_LEN, 0);
+	/* Don't consider an S-TAG (0x88A8) packet as a VLAN packet */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_ESVL_POS,
+				     MAC_VLANTR_ESVL_LEN, 0);
+	/* Enable VLAN tag stripping */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_EVLS_POS,
+				     MAC_VLANTR_EVLS_LEN, 0x3);
+	writel(regval, pdata->mac_regs + MAC_VLANTR);
+
+	return 0;
+}
+
+static int xlgmac_disable_rx_vlan_stripping(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_VLANTR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_EVLS_POS,
+				     MAC_VLANTR_EVLS_LEN, 0);
+	writel(regval, pdata->mac_regs + MAC_VLANTR);
+
+	return 0;
+}
+
+static int xlgmac_enable_rx_vlan_filtering(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_PFR);
+	/* Enable VLAN filtering */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_PFR_VTFE_POS,
+				     MAC_PFR_VTFE_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_PFR);
+
+	regval = readl(pdata->mac_regs + MAC_VLANTR);
+	/* Enable VLAN Hash Table filtering */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_VTHM_POS,
+				     MAC_VLANTR_VTHM_LEN, 1);
+	/* Disable VLAN tag inverse matching */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_VTIM_POS,
+				     MAC_VLANTR_VTIM_LEN, 0);
+	/* Only filter on the lower 12-bits of the VLAN tag */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_ETV_POS,
+				     MAC_VLANTR_ETV_LEN, 1);
+	/* In order for the VLAN Hash Table filtering to be effective,
+	 * the VLAN tag identifier in the VLAN Tag Register must not
+	 * be zero.  Set the VLAN tag identifier to "1" to enable the
+	 * VLAN Hash Table filtering.  This implies that a VLAN tag of
+	 * 1 will always pass filtering.
+	 */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANTR_VL_POS,
+				     MAC_VLANTR_VL_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_VLANTR);
+
+	return 0;
+}
+
+static int xlgmac_disable_rx_vlan_filtering(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_PFR);
+	/* Disable VLAN filtering */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_PFR_VTFE_POS,
+				     MAC_PFR_VTFE_LEN, 0);
+	writel(regval, pdata->mac_regs + MAC_PFR);
+
+	return 0;
+}
+
+static u32 xlgmac_vid_crc32_le(__le16 vid_le)
+{
+	u32 poly = 0xedb88320;	/* CRCPOLY_LE */
+	u32 crc = ~0;
+	u32 temp = 0;
+	unsigned char *data = (unsigned char *)&vid_le;
+	unsigned char data_byte = 0;
+	int i, bits;
+
+	bits = get_bitmask_order(VLAN_VID_MASK);
+	for (i = 0; i < bits; i++) {
+		if ((i % 8) == 0)
+			data_byte = data[i / 8];
+
+		temp = ((crc & 1) ^ data_byte) & 1;
+		crc >>= 1;
+		data_byte >>= 1;
+
+		if (temp)
+			crc ^= poly;
+	}
+
+	return crc;
+}
+
+static int xlgmac_update_vlan_hash_table(struct xlgmac_pdata *pdata)
+{
+	u32 crc;
+	u16 vid;
+	__le16 vid_le;
+	u16 vlan_hash_table = 0;
+	u32 regval;
+
+	/* Generate the VLAN Hash Table value */
+	for_each_set_bit(vid, pdata->active_vlans, VLAN_N_VID) {
+		/* Get the CRC32 value of the VLAN ID */
+		vid_le = cpu_to_le16(vid);
+		crc = bitrev32(~xlgmac_vid_crc32_le(vid_le)) >> 28;
+
+		vlan_hash_table |= (1 << crc);
+	}
+
+	regval = readl(pdata->mac_regs + MAC_VLANHTR);
+	/* Set the VLAN Hash Table filtering register */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANHTR_VLHT_POS,
+				     MAC_VLANHTR_VLHT_LEN, vlan_hash_table);
+	writel(regval, pdata->mac_regs + MAC_VLANHTR);
+
+	return 0;
+}
+
+static int xlgmac_set_promiscuous_mode(struct xlgmac_pdata *pdata,
+				       unsigned int enable)
+{
+	unsigned int val = enable ? 1 : 0;
+	u32 regval;
+
+	regval = XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + MAC_PFR),
+				     MAC_PFR_PR_POS, MAC_PFR_PR_LEN);
+	if (regval == val)
+		return 0;
+
+	netif_dbg(pdata, drv, pdata->netdev, "%s promiscuous mode\n",
+		  enable ? "entering" : "leaving");
+
+	regval = readl(pdata->mac_regs + MAC_PFR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_PFR_PR_POS,
+				     MAC_PFR_PR_LEN, val);
+	writel(regval, pdata->mac_regs + MAC_PFR);
+
+	/* Hardware will still perform VLAN filtering in promiscuous mode */
+	if (enable) {
+		xlgmac_disable_rx_vlan_filtering(pdata);
+	} else {
+		if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
+			xlgmac_enable_rx_vlan_filtering(pdata);
+	}
+
+	return 0;
+}
+
+static int xlgmac_set_all_multicast_mode(struct xlgmac_pdata *pdata,
+					 unsigned int enable)
+{
+	unsigned int val = enable ? 1 : 0;
+	u32 regval;
+
+	regval = XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + MAC_PFR),
+				     MAC_PFR_PM_POS, MAC_PFR_PM_LEN);
+	if (regval == val)
+		return 0;
+
+	netif_dbg(pdata, drv, pdata->netdev, "%s allmulti mode\n",
+		  enable ? "entering" : "leaving");
+
+	regval = readl(pdata->mac_regs + MAC_PFR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_PFR_PM_POS,
+				     MAC_PFR_PM_LEN, val);
+	writel(regval, pdata->mac_regs + MAC_PFR);
+
+	return 0;
+}
+
+static void xlgmac_set_mac_addn_addrs(struct xlgmac_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_hw_addr *ha;
+	unsigned int mac_reg;
+	unsigned int addn_macs;
+
+	mac_reg = MAC_MACA1HR;
+	addn_macs = pdata->hw_feat.addn_mac;
+
+	if (netdev_uc_count(netdev) > addn_macs) {
+		xlgmac_set_promiscuous_mode(pdata, 1);
+	} else {
+		netdev_for_each_uc_addr(ha, netdev) {
+			xlgmac_set_mac_reg(pdata, ha, &mac_reg);
+			addn_macs--;
+		}
+
+		if (netdev_mc_count(netdev) > addn_macs) {
+			xlgmac_set_all_multicast_mode(pdata, 1);
+		} else {
+			netdev_for_each_mc_addr(ha, netdev) {
+				xlgmac_set_mac_reg(pdata, ha, &mac_reg);
+				addn_macs--;
+			}
+		}
+	}
+
+	/* Clear remaining additional MAC address entries */
+	while (addn_macs--)
+		xlgmac_set_mac_reg(pdata, NULL, &mac_reg);
+}
+
+static void xlgmac_set_mac_hash_table(struct xlgmac_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_hw_addr *ha;
+	unsigned int hash_reg;
+	unsigned int hash_table_shift, hash_table_count;
+	u32 hash_table[XLGMAC_MAC_HASH_TABLE_SIZE];
+	u32 crc;
+	unsigned int i;
+
+	hash_table_shift = 26 - (pdata->hw_feat.hash_table_size >> 7);
+	hash_table_count = pdata->hw_feat.hash_table_size / 32;
+	memset(hash_table, 0, sizeof(hash_table));
+
+	/* Build the MAC Hash Table register values */
+	netdev_for_each_uc_addr(ha, netdev) {
+		crc = bitrev32(~crc32_le(~0, ha->addr, ETH_ALEN));
+		crc >>= hash_table_shift;
+		hash_table[crc >> 5] |= (1 << (crc & 0x1f));
+	}
+
+	netdev_for_each_mc_addr(ha, netdev) {
+		crc = bitrev32(~crc32_le(~0, ha->addr, ETH_ALEN));
+		crc >>= hash_table_shift;
+		hash_table[crc >> 5] |= (1 << (crc & 0x1f));
+	}
+
+	/* Set the MAC Hash Table registers */
+	hash_reg = MAC_HTR0;
+	for (i = 0; i < hash_table_count; i++) {
+		writel(hash_table[i], pdata->mac_regs + hash_reg);
+		hash_reg += MAC_HTR_INC;
+	}
+}
+
+static int xlgmac_add_mac_addresses(struct xlgmac_pdata *pdata)
+{
+	if (pdata->hw_feat.hash_table_size)
+		xlgmac_set_mac_hash_table(pdata);
+	else
+		xlgmac_set_mac_addn_addrs(pdata);
+
+	return 0;
+}
+
+static void xlgmac_config_mac_address(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	xlgmac_set_mac_address(pdata, pdata->netdev->dev_addr);
+
+	/* Filtering is done using perfect filtering and hash filtering */
+	if (pdata->hw_feat.hash_table_size) {
+		regval = readl(pdata->mac_regs + MAC_PFR);
+		regval = XLGMAC_SET_REG_BITS(regval, MAC_PFR_HPF_POS,
+					     MAC_PFR_HPF_LEN, 1);
+		regval = XLGMAC_SET_REG_BITS(regval, MAC_PFR_HUC_POS,
+					     MAC_PFR_HUC_LEN, 1);
+		regval = XLGMAC_SET_REG_BITS(regval, MAC_PFR_HMC_POS,
+					     MAC_PFR_HMC_LEN, 1);
+		writel(regval, pdata->mac_regs + MAC_PFR);
+	}
+}
+
+static void xlgmac_config_jumbo_enable(struct xlgmac_pdata *pdata)
+{
+	unsigned int val;
+	u32 regval;
+
+	val = (pdata->netdev->mtu > XLGMAC_STD_PACKET_MTU) ? 1 : 0;
+
+	regval = readl(pdata->mac_regs + MAC_RCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_JE_POS,
+				     MAC_RCR_JE_LEN, val);
+	writel(regval, pdata->mac_regs + MAC_RCR);
+}
+
+static void xlgmac_config_checksum_offload(struct xlgmac_pdata *pdata)
+{
+	if (pdata->netdev->features & NETIF_F_RXCSUM)
+		xlgmac_enable_rx_csum(pdata);
+	else
+		xlgmac_disable_rx_csum(pdata);
+}
+
+static void xlgmac_config_vlan_support(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_VLANIR);
+	/* Indicate that VLAN Tx CTAGs come from context descriptors */
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANIR_CSVL_POS,
+				     MAC_VLANIR_CSVL_LEN, 0);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_VLANIR_VLTI_POS,
+				     MAC_VLANIR_VLTI_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_VLANIR);
+
+	/* Set the current VLAN Hash Table register value */
+	xlgmac_update_vlan_hash_table(pdata);
+
+	if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
+		xlgmac_enable_rx_vlan_filtering(pdata);
+	else
+		xlgmac_disable_rx_vlan_filtering(pdata);
+
+	if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		xlgmac_enable_rx_vlan_stripping(pdata);
+	else
+		xlgmac_disable_rx_vlan_stripping(pdata);
+}
+
+static int xlgmac_config_rx_mode(struct xlgmac_pdata *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	unsigned int pr_mode, am_mode;
+
+	pr_mode = ((netdev->flags & IFF_PROMISC) != 0);
+	am_mode = ((netdev->flags & IFF_ALLMULTI) != 0);
+
+	xlgmac_set_promiscuous_mode(pdata, pr_mode);
+	xlgmac_set_all_multicast_mode(pdata, am_mode);
+
+	xlgmac_add_mac_addresses(pdata);
+
+	return 0;
+}
+
+static void xlgmac_prepare_tx_stop(struct xlgmac_pdata *pdata,
+				   struct xlgmac_channel *channel)
+{
+	unsigned int tx_dsr, tx_pos, tx_qidx;
+	unsigned int tx_status;
+	unsigned long tx_timeout;
+
+	/* Calculate the status register to read and the position within */
+	if (channel->queue_index < DMA_DSRX_FIRST_QUEUE) {
+		tx_dsr = DMA_DSR0;
+		tx_pos = (channel->queue_index * DMA_DSR_Q_LEN) +
+			 DMA_DSR0_TPS_START;
+	} else {
+		tx_qidx = channel->queue_index - DMA_DSRX_FIRST_QUEUE;
+
+		tx_dsr = DMA_DSR1 + ((tx_qidx / DMA_DSRX_QPR) * DMA_DSRX_INC);
+		tx_pos = ((tx_qidx % DMA_DSRX_QPR) * DMA_DSR_Q_LEN) +
+			 DMA_DSRX_TPS_START;
+	}
+
+	/* The Tx engine cannot be stopped if it is actively processing
+	 * descriptors. Wait for the Tx engine to enter the stopped or
+	 * suspended state.  Don't wait forever though...
+	 */
+	tx_timeout = jiffies + (XLGMAC_DMA_STOP_TIMEOUT * HZ);
+	while (time_before(jiffies, tx_timeout)) {
+		tx_status = readl(pdata->mac_regs + tx_dsr);
+		tx_status = XLGMAC_GET_REG_BITS(tx_status, tx_pos,
+						DMA_DSR_TPS_LEN);
+		if ((tx_status == DMA_TPS_STOPPED) ||
+		    (tx_status == DMA_TPS_SUSPENDED))
+			break;
+
+		usleep_range(500, 1000);
+	}
+
+	if (!time_before(jiffies, tx_timeout))
+		netdev_info(pdata->netdev,
+			    "timed out waiting for Tx DMA channel %u to stop\n",
+			    channel->queue_index);
+}
+
+static void xlgmac_enable_tx(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	/* Enable each Tx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_TCR_ST_POS,
+					     DMA_CH_TCR_ST_LEN, 1);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+	}
+
+	/* Enable each Tx queue */
+	for (i = 0; i < pdata->tx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_TQOMR_TXQEN_POS,
+					     MTL_Q_TQOMR_TXQEN_LEN,
+					MTL_Q_ENABLED);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+	}
+
+	/* Enable MAC Tx */
+	regval = readl(pdata->mac_regs + MAC_TCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_TCR_TE_POS,
+				     MAC_TCR_TE_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_TCR);
+}
+
+static void xlgmac_disable_tx(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	/* Prepare for Tx DMA channel stop */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		xlgmac_prepare_tx_stop(pdata, channel);
+	}
+
+	/* Disable MAC Tx */
+	regval = readl(pdata->mac_regs + MAC_TCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_TCR_TE_POS,
+				     MAC_TCR_TE_LEN, 0);
+	writel(regval, pdata->mac_regs + MAC_TCR);
+
+	/* Disable each Tx queue */
+	for (i = 0; i < pdata->tx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_TQOMR_TXQEN_POS,
+					     MTL_Q_TQOMR_TXQEN_LEN, 0);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+	}
+
+	/* Disable each Tx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_TCR_ST_POS,
+					     DMA_CH_TCR_ST_LEN, 0);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+	}
+}
+
+static void xlgmac_prepare_rx_stop(struct xlgmac_pdata *pdata,
+				   unsigned int queue)
+{
+	unsigned int rx_status, prxq, rxqsts;
+	unsigned long rx_timeout;
+
+	/* The Rx engine cannot be stopped if it is actively processing
+	 * packets. Wait for the Rx queue to empty the Rx fifo.  Don't
+	 * wait forever though...
+	 */
+	rx_timeout = jiffies + (XLGMAC_DMA_STOP_TIMEOUT * HZ);
+	while (time_before(jiffies, rx_timeout)) {
+		rx_status = readl(XLGMAC_MTL_REG(pdata, queue, MTL_Q_RQDR));
+		prxq = XLGMAC_GET_REG_BITS(rx_status, MTL_Q_RQDR_PRXQ_POS,
+					   MTL_Q_RQDR_PRXQ_LEN);
+		rxqsts = XLGMAC_GET_REG_BITS(rx_status, MTL_Q_RQDR_RXQSTS_POS,
+					     MTL_Q_RQDR_RXQSTS_LEN);
+		if ((prxq == 0) && (rxqsts == 0))
+			break;
+
+		usleep_range(500, 1000);
+	}
+
+	if (!time_before(jiffies, rx_timeout))
+		netdev_info(pdata->netdev,
+			    "timed out waiting for Rx queue %u to empty\n",
+			    queue);
+}
+
+static void xlgmac_enable_rx(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int regval, i;
+
+	/* Enable each Rx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_RCR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_RCR_SR_POS,
+					     DMA_CH_RCR_SR_LEN, 1);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_RCR));
+	}
+
+	/* Enable each Rx queue */
+	regval = 0;
+	for (i = 0; i < pdata->rx_q_count; i++)
+		regval |= (0x02 << (i << 1));
+	writel(regval, pdata->mac_regs + MAC_RQC0R);
+
+	/* Enable MAC Rx */
+	regval = readl(pdata->mac_regs + MAC_RCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_DCRCC_POS,
+				     MAC_RCR_DCRCC_LEN, 1);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_CST_POS,
+				     MAC_RCR_CST_LEN, 1);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_ACS_POS,
+				     MAC_RCR_ACS_LEN, 1);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_RE_POS,
+				     MAC_RCR_RE_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_RCR);
+}
+
+static void xlgmac_disable_rx(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	/* Disable MAC Rx */
+	regval = readl(pdata->mac_regs + MAC_RCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_DCRCC_POS,
+				     MAC_RCR_DCRCC_LEN, 0);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_CST_POS,
+				     MAC_RCR_CST_LEN, 0);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_ACS_POS,
+				     MAC_RCR_ACS_LEN, 0);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_RE_POS,
+				     MAC_RCR_RE_LEN, 0);
+	writel(regval, pdata->mac_regs + MAC_RCR);
+
+	/* Prepare for Rx DMA channel stop */
+	for (i = 0; i < pdata->rx_q_count; i++)
+		xlgmac_prepare_rx_stop(pdata, i);
+
+	/* Disable each Rx queue */
+	writel(0, pdata->mac_regs + MAC_RQC0R);
+
+	/* Disable each Rx DMA channel */
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_RCR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_RCR_SR_POS,
+					     DMA_CH_RCR_SR_LEN, 0);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_RCR));
+	}
+}
+
+static void xlgmac_tx_start_xmit(struct xlgmac_channel *channel,
+				 struct xlgmac_ring *ring)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct xlgmac_desc_data *desc_data;
+
+	/* Make sure everything is written before the register write */
+	wmb();
+
+	/* Issue a poll command to Tx DMA by writing address
+	 * of next immediate free descriptor
+	 */
+	desc_data = XLGMAC_GET_DESC_DATA(ring, ring->cur);
+	writel(lower_32_bits(desc_data->dma_desc_addr),
+	       XLGMAC_DMA_REG(channel, DMA_CH_TDTR_LO));
+
+	/* Start the Tx timer */
+	if (pdata->tx_usecs && !channel->tx_timer_active) {
+		channel->tx_timer_active = 1;
+		mod_timer(&channel->tx_timer,
+			  jiffies + usecs_to_jiffies(pdata->tx_usecs));
+	}
+
+	ring->tx.xmit_more = 0;
+}
+
+static void xlgmac_dev_xmit(struct xlgmac_channel *channel)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct xlgmac_ring *ring = channel->tx_ring;
+	struct xlgmac_desc_data *desc_data;
+	struct xlgmac_dma_desc *dma_desc;
+	struct xlgmac_pkt_info *pkt_info = &ring->pkt_info;
+	unsigned int csum, tso, vlan;
+	unsigned int tso_context, vlan_context;
+	unsigned int tx_set_ic;
+	int start_index = ring->cur;
+	int cur_index = ring->cur;
+	int i;
+
+	csum = XLGMAC_GET_REG_BITS(pkt_info->attributes,
+				   TX_PACKET_ATTRIBUTES_CSUM_ENABLE_POS,
+				TX_PACKET_ATTRIBUTES_CSUM_ENABLE_LEN);
+	tso = XLGMAC_GET_REG_BITS(pkt_info->attributes,
+				  TX_PACKET_ATTRIBUTES_TSO_ENABLE_POS,
+				TX_PACKET_ATTRIBUTES_TSO_ENABLE_LEN);
+	vlan = XLGMAC_GET_REG_BITS(pkt_info->attributes,
+				   TX_PACKET_ATTRIBUTES_VLAN_CTAG_POS,
+				TX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN);
+
+	if (tso && (pkt_info->mss != ring->tx.cur_mss))
+		tso_context = 1;
+	else
+		tso_context = 0;
+
+	if (vlan && (pkt_info->vlan_ctag != ring->tx.cur_vlan_ctag))
+		vlan_context = 1;
+	else
+		vlan_context = 0;
+
+	/* Determine if an interrupt should be generated for this Tx:
+	 *   Interrupt:
+	 *     - Tx frame count exceeds the frame count setting
+	 *     - Addition of Tx frame count to the frame count since the
+	 *       last interrupt was set exceeds the frame count setting
+	 *   No interrupt:
+	 *     - No frame count setting specified (ethtool -C ethX tx-frames 0)
+	 *     - Addition of Tx frame count to the frame count since the
+	 *       last interrupt was set does not exceed the frame count setting
+	 */
+	ring->coalesce_count += pkt_info->tx_packets;
+	if (!pdata->tx_frames)
+		tx_set_ic = 0;
+	else if (pkt_info->tx_packets > pdata->tx_frames)
+		tx_set_ic = 1;
+	else if ((ring->coalesce_count % pdata->tx_frames) <
+		 pkt_info->tx_packets)
+		tx_set_ic = 1;
+	else
+		tx_set_ic = 0;
+
+	desc_data = XLGMAC_GET_DESC_DATA(ring, cur_index);
+	dma_desc = desc_data->dma_desc;
+
+	/* Create a context descriptor if this is a TSO pkt_info */
+	if (tso_context || vlan_context) {
+		if (tso_context) {
+			netif_dbg(pdata, tx_queued, pdata->netdev,
+				  "TSO context descriptor, mss=%u\n",
+				  pkt_info->mss);
+
+			/* Set the MSS size */
+			dma_desc->desc2 = XLGMAC_SET_REG_BITS_LE(
+						dma_desc->desc2,
+						TX_CONTEXT_DESC2_MSS_POS,
+						TX_CONTEXT_DESC2_MSS_LEN,
+						pkt_info->mss);
+
+			/* Mark it as a CONTEXT descriptor */
+			dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+						dma_desc->desc3,
+						TX_CONTEXT_DESC3_CTXT_POS,
+						TX_CONTEXT_DESC3_CTXT_LEN,
+						1);
+
+			/* Indicate this descriptor contains the MSS */
+			dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+						dma_desc->desc3,
+						TX_CONTEXT_DESC3_TCMSSV_POS,
+						TX_CONTEXT_DESC3_TCMSSV_LEN,
+						1);
+
+			ring->tx.cur_mss = pkt_info->mss;
+		}
+
+		if (vlan_context) {
+			netif_dbg(pdata, tx_queued, pdata->netdev,
+				  "VLAN context descriptor, ctag=%u\n",
+				  pkt_info->vlan_ctag);
+
+			/* Mark it as a CONTEXT descriptor */
+			dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+						dma_desc->desc3,
+						TX_CONTEXT_DESC3_CTXT_POS,
+						TX_CONTEXT_DESC3_CTXT_LEN,
+						1);
+
+			/* Set the VLAN tag */
+			dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+						dma_desc->desc3,
+						TX_CONTEXT_DESC3_VT_POS,
+						TX_CONTEXT_DESC3_VT_LEN,
+						pkt_info->vlan_ctag);
+
+			/* Indicate this descriptor contains the VLAN tag */
+			dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+						dma_desc->desc3,
+						TX_CONTEXT_DESC3_VLTV_POS,
+						TX_CONTEXT_DESC3_VLTV_LEN,
+						1);
+
+			ring->tx.cur_vlan_ctag = pkt_info->vlan_ctag;
+		}
+
+		cur_index++;
+		desc_data = XLGMAC_GET_DESC_DATA(ring, cur_index);
+		dma_desc = desc_data->dma_desc;
+	}
+
+	/* Update buffer address (for TSO this is the header) */
+	dma_desc->desc0 =  cpu_to_le32(lower_32_bits(desc_data->skb_dma));
+	dma_desc->desc1 =  cpu_to_le32(upper_32_bits(desc_data->skb_dma));
+
+	/* Update the buffer length */
+	dma_desc->desc2 = XLGMAC_SET_REG_BITS_LE(
+				dma_desc->desc2,
+				TX_NORMAL_DESC2_HL_B1L_POS,
+				TX_NORMAL_DESC2_HL_B1L_LEN,
+				desc_data->skb_dma_len);
+
+	/* VLAN tag insertion check */
+	if (vlan)
+		dma_desc->desc2 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc2,
+					TX_NORMAL_DESC2_VTIR_POS,
+					TX_NORMAL_DESC2_VTIR_LEN,
+					TX_NORMAL_DESC2_VLAN_INSERT);
+
+	/* Timestamp enablement check */
+	if (XLGMAC_GET_REG_BITS(pkt_info->attributes,
+				TX_PACKET_ATTRIBUTES_PTP_POS,
+				TX_PACKET_ATTRIBUTES_PTP_LEN))
+		dma_desc->desc2 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc2,
+					TX_NORMAL_DESC2_TTSE_POS,
+					TX_NORMAL_DESC2_TTSE_LEN,
+					1);
+
+	/* Mark it as First Descriptor */
+	dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+				dma_desc->desc3,
+				TX_NORMAL_DESC3_FD_POS,
+				TX_NORMAL_DESC3_FD_LEN,
+				1);
+
+	/* Mark it as a NORMAL descriptor */
+	dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+				dma_desc->desc3,
+				TX_NORMAL_DESC3_CTXT_POS,
+				TX_NORMAL_DESC3_CTXT_LEN,
+				0);
+
+	/* Set OWN bit if not the first descriptor */
+	if (cur_index != start_index)
+		dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc3,
+					TX_NORMAL_DESC3_OWN_POS,
+					TX_NORMAL_DESC3_OWN_LEN,
+					1);
+
+	if (tso) {
+		/* Enable TSO */
+		dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc3,
+					TX_NORMAL_DESC3_TSE_POS,
+					TX_NORMAL_DESC3_TSE_LEN, 1);
+		dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc3,
+					TX_NORMAL_DESC3_TCPPL_POS,
+					TX_NORMAL_DESC3_TCPPL_LEN,
+					pkt_info->tcp_payload_len);
+		dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc3,
+					TX_NORMAL_DESC3_TCPHDRLEN_POS,
+					TX_NORMAL_DESC3_TCPHDRLEN_LEN,
+					pkt_info->tcp_header_len / 4);
+
+		pdata->stats.tx_tso_packets++;
+	} else {
+		/* Enable CRC and Pad Insertion */
+		dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc3,
+					TX_NORMAL_DESC3_CPC_POS,
+					TX_NORMAL_DESC3_CPC_LEN, 0);
+
+		/* Enable HW CSUM */
+		if (csum)
+			dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+						dma_desc->desc3,
+						TX_NORMAL_DESC3_CIC_POS,
+						TX_NORMAL_DESC3_CIC_LEN,
+						0x3);
+
+		/* Set the total length to be transmitted */
+		dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc3,
+					TX_NORMAL_DESC3_FL_POS,
+					TX_NORMAL_DESC3_FL_LEN,
+					pkt_info->length);
+	}
+
+	for (i = cur_index - start_index + 1; i < pkt_info->desc_count; i++) {
+		cur_index++;
+		desc_data = XLGMAC_GET_DESC_DATA(ring, cur_index);
+		dma_desc = desc_data->dma_desc;
+
+		/* Update buffer address */
+		dma_desc->desc0 =
+			cpu_to_le32(lower_32_bits(desc_data->skb_dma));
+		dma_desc->desc1 =
+			cpu_to_le32(upper_32_bits(desc_data->skb_dma));
+
+		/* Update the buffer length */
+		dma_desc->desc2 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc2,
+					TX_NORMAL_DESC2_HL_B1L_POS,
+					TX_NORMAL_DESC2_HL_B1L_LEN,
+					desc_data->skb_dma_len);
+
+		/* Set OWN bit */
+		dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc3,
+					TX_NORMAL_DESC3_OWN_POS,
+					TX_NORMAL_DESC3_OWN_LEN, 1);
+
+		/* Mark it as NORMAL descriptor */
+		dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc3,
+					TX_NORMAL_DESC3_CTXT_POS,
+					TX_NORMAL_DESC3_CTXT_LEN, 0);
+
+		/* Enable HW CSUM */
+		if (csum)
+			dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+						dma_desc->desc3,
+						TX_NORMAL_DESC3_CIC_POS,
+						TX_NORMAL_DESC3_CIC_LEN,
+						0x3);
+	}
+
+	/* Set LAST bit for the last descriptor */
+	dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+				dma_desc->desc3,
+				TX_NORMAL_DESC3_LD_POS,
+				TX_NORMAL_DESC3_LD_LEN, 1);
+
+	/* Set IC bit based on Tx coalescing settings */
+	if (tx_set_ic)
+		dma_desc->desc2 = XLGMAC_SET_REG_BITS_LE(
+					dma_desc->desc2,
+					TX_NORMAL_DESC2_IC_POS,
+					TX_NORMAL_DESC2_IC_LEN, 1);
+
+	/* Save the Tx info to report back during cleanup */
+	desc_data->tx.packets = pkt_info->tx_packets;
+	desc_data->tx.bytes = pkt_info->tx_bytes;
+
+	/* In case the Tx DMA engine is running, make sure everything
+	 * is written to the descriptor(s) before setting the OWN bit
+	 * for the first descriptor
+	 */
+	dma_wmb();
+
+	/* Set OWN bit for the first descriptor */
+	desc_data = XLGMAC_GET_DESC_DATA(ring, start_index);
+	dma_desc = desc_data->dma_desc;
+	dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+				dma_desc->desc3,
+				TX_NORMAL_DESC3_OWN_POS,
+				TX_NORMAL_DESC3_OWN_LEN, 1);
+
+	if (netif_msg_tx_queued(pdata))
+		xlgmac_dump_tx_desc(pdata, ring, start_index,
+				    pkt_info->desc_count, 1);
+
+	/* Make sure ownership is written to the descriptor */
+	smp_wmb();
+
+	ring->cur = cur_index + 1;
+	if (!pkt_info->skb->xmit_more ||
+	    netif_xmit_stopped(netdev_get_tx_queue(pdata->netdev,
+						   channel->queue_index)))
+		xlgmac_tx_start_xmit(channel, ring);
+	else
+		ring->tx.xmit_more = 1;
+
+	XLGMAC_PR("%s: descriptors %u to %u written\n",
+		  channel->name, start_index & (ring->dma_desc_count - 1),
+		  (ring->cur - 1) & (ring->dma_desc_count - 1));
+}
+
+static void xlgmac_get_rx_tstamp(struct xlgmac_pkt_info *pkt_info,
+				 struct xlgmac_dma_desc *dma_desc)
+{
+	u64 nsec;
+	u32 tsa, tsd;
+
+	tsa = XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				     RX_CONTEXT_DESC3_TSA_POS,
+				RX_CONTEXT_DESC3_TSA_LEN);
+	tsd = XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				     RX_CONTEXT_DESC3_TSD_POS,
+				RX_CONTEXT_DESC3_TSD_LEN);
+	if (tsa && !tsd) {
+		nsec = le32_to_cpu(dma_desc->desc1);
+		nsec <<= 32;
+		nsec |= le32_to_cpu(dma_desc->desc0);
+		if (nsec != 0xffffffffffffffffULL) {
+			pkt_info->rx_tstamp = nsec;
+			pkt_info->attributes = XLGMAC_SET_REG_BITS(
+					pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_RX_TSTAMP_POS,
+					RX_PACKET_ATTRIBUTES_RX_TSTAMP_LEN,
+					1);
+		}
+	}
+}
+
+static void xlgmac_tx_desc_reset(struct xlgmac_desc_data *desc_data)
+{
+	struct xlgmac_dma_desc *dma_desc = desc_data->dma_desc;
+
+	/* Reset the Tx descriptor
+	 *   Set buffer 1 (lo) address to zero
+	 *   Set buffer 1 (hi) address to zero
+	 *   Reset all other control bits (IC, TTSE, B2L & B1L)
+	 *   Reset all other control bits (OWN, CTXT, FD, LD, CPC, CIC, etc)
+	 */
+	dma_desc->desc0 = 0;
+	dma_desc->desc1 = 0;
+	dma_desc->desc2 = 0;
+	dma_desc->desc3 = 0;
+
+	/* Make sure ownership is written to the descriptor */
+	dma_wmb();
+}
+
+static void xlgmac_tx_desc_init(struct xlgmac_channel *channel)
+{
+	struct xlgmac_ring *ring = channel->tx_ring;
+	struct xlgmac_desc_data *desc_data;
+	int i;
+	int start_index = ring->cur;
+
+	/* Initialze all descriptors */
+	for (i = 0; i < ring->dma_desc_count; i++) {
+		desc_data = XLGMAC_GET_DESC_DATA(ring, i);
+
+		/* Initialize Tx descriptor */
+		xlgmac_tx_desc_reset(desc_data);
+	}
+
+	/* Update the total number of Tx descriptors */
+	writel(ring->dma_desc_count - 1, XLGMAC_DMA_REG(channel, DMA_CH_TDRLR));
+
+	/* Update the starting address of descriptor ring */
+	desc_data = XLGMAC_GET_DESC_DATA(ring, start_index);
+	writel(upper_32_bits(desc_data->dma_desc_addr),
+	       XLGMAC_DMA_REG(channel, DMA_CH_TDLR_HI));
+	writel(lower_32_bits(desc_data->dma_desc_addr),
+	       XLGMAC_DMA_REG(channel, DMA_CH_TDLR_LO));
+}
+
+static void xlgmac_rx_desc_reset(struct xlgmac_pdata *pdata,
+				 struct xlgmac_desc_data *desc_data,
+				 unsigned int index)
+{
+	struct xlgmac_dma_desc *dma_desc = desc_data->dma_desc;
+	unsigned int rx_usecs = pdata->rx_usecs;
+	unsigned int rx_frames = pdata->rx_frames;
+	unsigned int inte;
+	dma_addr_t hdr_dma, buf_dma;
+
+	if (!rx_usecs && !rx_frames) {
+		/* No coalescing, interrupt for every descriptor */
+		inte = 1;
+	} else {
+		/* Set interrupt based on Rx frame coalescing setting */
+		if (rx_frames && !((index + 1) % rx_frames))
+			inte = 1;
+		else
+			inte = 0;
+	}
+
+	/* Reset the Rx descriptor
+	 *   Set buffer 1 (lo) address to header dma address (lo)
+	 *   Set buffer 1 (hi) address to header dma address (hi)
+	 *   Set buffer 2 (lo) address to buffer dma address (lo)
+	 *   Set buffer 2 (hi) address to buffer dma address (hi) and
+	 *     set control bits OWN and INTE
+	 */
+	hdr_dma = desc_data->rx.hdr.dma_base + desc_data->rx.hdr.dma_off;
+	buf_dma = desc_data->rx.buf.dma_base + desc_data->rx.buf.dma_off;
+	dma_desc->desc0 = cpu_to_le32(lower_32_bits(hdr_dma));
+	dma_desc->desc1 = cpu_to_le32(upper_32_bits(hdr_dma));
+	dma_desc->desc2 = cpu_to_le32(lower_32_bits(buf_dma));
+	dma_desc->desc3 = cpu_to_le32(upper_32_bits(buf_dma));
+
+	dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+				dma_desc->desc3,
+				RX_NORMAL_DESC3_INTE_POS,
+				RX_NORMAL_DESC3_INTE_LEN,
+				inte);
+
+	/* Since the Rx DMA engine is likely running, make sure everything
+	 * is written to the descriptor(s) before setting the OWN bit
+	 * for the descriptor
+	 */
+	dma_wmb();
+
+	dma_desc->desc3 = XLGMAC_SET_REG_BITS_LE(
+				dma_desc->desc3,
+				RX_NORMAL_DESC3_OWN_POS,
+				RX_NORMAL_DESC3_OWN_LEN,
+				1);
+
+	/* Make sure ownership is written to the descriptor */
+	dma_wmb();
+}
+
+static void xlgmac_rx_desc_init(struct xlgmac_channel *channel)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct xlgmac_ring *ring = channel->rx_ring;
+	struct xlgmac_desc_data *desc_data;
+	unsigned int start_index = ring->cur;
+	unsigned int i;
+
+	/* Initialize all descriptors */
+	for (i = 0; i < ring->dma_desc_count; i++) {
+		desc_data = XLGMAC_GET_DESC_DATA(ring, i);
+
+		/* Initialize Rx descriptor */
+		xlgmac_rx_desc_reset(pdata, desc_data, i);
+	}
+
+	/* Update the total number of Rx descriptors */
+	writel(ring->dma_desc_count - 1, XLGMAC_DMA_REG(channel, DMA_CH_RDRLR));
+
+	/* Update the starting address of descriptor ring */
+	desc_data = XLGMAC_GET_DESC_DATA(ring, start_index);
+	writel(upper_32_bits(desc_data->dma_desc_addr),
+	       XLGMAC_DMA_REG(channel, DMA_CH_RDLR_HI));
+	writel(lower_32_bits(desc_data->dma_desc_addr),
+	       XLGMAC_DMA_REG(channel, DMA_CH_RDLR_LO));
+
+	/* Update the Rx Descriptor Tail Pointer */
+	desc_data = XLGMAC_GET_DESC_DATA(ring, start_index +
+					  ring->dma_desc_count - 1);
+	writel(lower_32_bits(desc_data->dma_desc_addr),
+	       XLGMAC_DMA_REG(channel, DMA_CH_RDTR_LO));
+}
+
+static int xlgmac_is_context_desc(struct xlgmac_dma_desc *dma_desc)
+{
+	/* Rx and Tx share CTXT bit, so check TDES3.CTXT bit */
+	return XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				TX_NORMAL_DESC3_CTXT_POS,
+				TX_NORMAL_DESC3_CTXT_LEN);
+}
+
+static int xlgmac_is_last_desc(struct xlgmac_dma_desc *dma_desc)
+{
+	/* Rx and Tx share LD bit, so check TDES3.LD bit */
+	return XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				TX_NORMAL_DESC3_LD_POS,
+				TX_NORMAL_DESC3_LD_LEN);
+}
+
+static int xlgmac_disable_tx_flow_control(struct xlgmac_pdata *pdata)
+{
+	unsigned int max_q_count, q_count;
+	unsigned int reg, regval;
+	unsigned int i;
+
+	/* Clear MTL flow control */
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQOMR_EHFC_POS,
+					     MTL_Q_RQOMR_EHFC_LEN, 0);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+	}
+
+	/* Clear MAC flow control */
+	max_q_count = XLGMAC_MAX_FLOW_CONTROL_QUEUES;
+	q_count = min_t(unsigned int, pdata->tx_q_count, max_q_count);
+	reg = MAC_Q0TFCR;
+	for (i = 0; i < q_count; i++) {
+		regval = readl(pdata->mac_regs + reg);
+		regval = XLGMAC_SET_REG_BITS(regval,
+					     MAC_Q0TFCR_TFE_POS,
+					MAC_Q0TFCR_TFE_LEN,
+					0);
+		writel(regval, pdata->mac_regs + reg);
+
+		reg += MAC_QTFCR_INC;
+	}
+
+	return 0;
+}
+
+static int xlgmac_enable_tx_flow_control(struct xlgmac_pdata *pdata)
+{
+	unsigned int max_q_count, q_count;
+	unsigned int reg, regval;
+	unsigned int i;
+
+	/* Set MTL flow control */
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQOMR_EHFC_POS,
+					     MTL_Q_RQOMR_EHFC_LEN, 1);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+	}
+
+	/* Set MAC flow control */
+	max_q_count = XLGMAC_MAX_FLOW_CONTROL_QUEUES;
+	q_count = min_t(unsigned int, pdata->tx_q_count, max_q_count);
+	reg = MAC_Q0TFCR;
+	for (i = 0; i < q_count; i++) {
+		regval = readl(pdata->mac_regs + reg);
+
+		/* Enable transmit flow control */
+		regval = XLGMAC_SET_REG_BITS(regval, MAC_Q0TFCR_TFE_POS,
+					     MAC_Q0TFCR_TFE_LEN, 1);
+		/* Set pause time */
+		regval = XLGMAC_SET_REG_BITS(regval, MAC_Q0TFCR_PT_POS,
+					     MAC_Q0TFCR_PT_LEN, 0xffff);
+
+		writel(regval, pdata->mac_regs + reg);
+
+		reg += MAC_QTFCR_INC;
+	}
+
+	return 0;
+}
+
+static int xlgmac_disable_rx_flow_control(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_RFCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RFCR_RFE_POS,
+				     MAC_RFCR_RFE_LEN, 0);
+	writel(regval, pdata->mac_regs + MAC_RFCR);
+
+	return 0;
+}
+
+static int xlgmac_enable_rx_flow_control(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MAC_RFCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RFCR_RFE_POS,
+				     MAC_RFCR_RFE_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_RFCR);
+
+	return 0;
+}
+
+static int xlgmac_config_tx_flow_control(struct xlgmac_pdata *pdata)
+{
+	if (pdata->tx_pause)
+		xlgmac_enable_tx_flow_control(pdata);
+	else
+		xlgmac_disable_tx_flow_control(pdata);
+
+	return 0;
+}
+
+static int xlgmac_config_rx_flow_control(struct xlgmac_pdata *pdata)
+{
+	if (pdata->rx_pause)
+		xlgmac_enable_rx_flow_control(pdata);
+	else
+		xlgmac_disable_rx_flow_control(pdata);
+
+	return 0;
+}
+
+static int xlgmac_config_rx_coalesce(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_RIWT));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_RIWT_RWT_POS,
+					     DMA_CH_RIWT_RWT_LEN,
+					     pdata->rx_riwt);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_RIWT));
+	}
+
+	return 0;
+}
+
+static void xlgmac_config_flow_control(struct xlgmac_pdata *pdata)
+{
+	xlgmac_config_tx_flow_control(pdata);
+	xlgmac_config_rx_flow_control(pdata);
+}
+
+static void xlgmac_config_rx_fep_enable(struct xlgmac_pdata *pdata)
+{
+	unsigned int i;
+	u32 regval;
+
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQOMR_FEP_POS,
+					     MTL_Q_RQOMR_FEP_LEN, 1);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+	}
+}
+
+static void xlgmac_config_rx_fup_enable(struct xlgmac_pdata *pdata)
+{
+	unsigned int i;
+	u32 regval;
+
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQOMR_FUP_POS,
+					     MTL_Q_RQOMR_FUP_LEN, 1);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+	}
+}
+
+static int xlgmac_config_tx_coalesce(struct xlgmac_pdata *pdata)
+{
+	return 0;
+}
+
+static void xlgmac_config_rx_buffer_size(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_RCR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_RCR_RBSZ_POS,
+					     DMA_CH_RCR_RBSZ_LEN,
+					pdata->rx_buf_size);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_RCR));
+	}
+}
+
+static void xlgmac_config_tso_mode(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		if (pdata->hw_feat.tso) {
+			regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+			regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_TCR_TSE_POS,
+						     DMA_CH_TCR_TSE_LEN, 1);
+			writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+		}
+	}
+}
+
+static void xlgmac_config_sph_mode(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_CR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_CR_SPH_POS,
+					     DMA_CH_CR_SPH_LEN, 1);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_CR));
+	}
+
+	regval = readl(pdata->mac_regs + MAC_RCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RCR_HDSMS_POS,
+				     MAC_RCR_HDSMS_LEN,
+				XLGMAC_SPH_HDSMS_SIZE);
+	writel(regval, pdata->mac_regs + MAC_RCR);
+}
+
+static unsigned int xlgmac_usec_to_riwt(struct xlgmac_pdata *pdata,
+					unsigned int usec)
+{
+	unsigned long rate;
+	unsigned int ret;
+
+	rate = pdata->sysclk_rate;
+
+	/* Convert the input usec value to the watchdog timer value. Each
+	 * watchdog timer value is equivalent to 256 clock cycles.
+	 * Calculate the required value as:
+	 *   ( usec * ( system_clock_mhz / 10^6 ) / 256
+	 */
+	ret = (usec * (rate / 1000000)) / 256;
+
+	return ret;
+}
+
+static unsigned int xlgmac_riwt_to_usec(struct xlgmac_pdata *pdata,
+					unsigned int riwt)
+{
+	unsigned long rate;
+	unsigned int ret;
+
+	rate = pdata->sysclk_rate;
+
+	/* Convert the input watchdog timer value to the usec value. Each
+	 * watchdog timer value is equivalent to 256 clock cycles.
+	 * Calculate the required value as:
+	 *   ( riwt * 256 ) / ( system_clock_mhz / 10^6 )
+	 */
+	ret = (riwt * 256) / (rate / 1000000);
+
+	return ret;
+}
+
+static int xlgmac_config_rx_threshold(struct xlgmac_pdata *pdata,
+				      unsigned int val)
+{
+	unsigned int i;
+	u32 regval;
+
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQOMR_RTC_POS,
+					     MTL_Q_RQOMR_RTC_LEN, val);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+	}
+
+	return 0;
+}
+
+static void xlgmac_config_mtl_mode(struct xlgmac_pdata *pdata)
+{
+	unsigned int i;
+	u32 regval;
+
+	/* Set Tx to weighted round robin scheduling algorithm */
+	regval = readl(pdata->mac_regs + MTL_OMR);
+	regval = XLGMAC_SET_REG_BITS(regval, MTL_OMR_ETSALG_POS,
+				     MTL_OMR_ETSALG_LEN, MTL_ETSALG_WRR);
+	writel(regval, pdata->mac_regs + MTL_OMR);
+
+	/* Set Tx traffic classes to use WRR algorithm with equal weights */
+	for (i = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_TC_ETSCR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_TC_ETSCR_TSA_POS,
+					     MTL_TC_ETSCR_TSA_LEN, MTL_TSA_ETS);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_TC_ETSCR));
+
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_TC_QWR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_TC_QWR_QW_POS,
+					     MTL_TC_QWR_QW_LEN, 1);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_TC_QWR));
+	}
+
+	/* Set Rx to strict priority algorithm */
+	regval = readl(pdata->mac_regs + MTL_OMR);
+	regval = XLGMAC_SET_REG_BITS(regval, MTL_OMR_RAA_POS,
+				     MTL_OMR_RAA_LEN, MTL_RAA_SP);
+	writel(regval, pdata->mac_regs + MTL_OMR);
+}
+
+static void xlgmac_config_queue_mapping(struct xlgmac_pdata *pdata)
+{
+	unsigned int qptc, qptc_extra, queue;
+	unsigned int prio_queues;
+	unsigned int ppq, ppq_extra, prio;
+	unsigned int mask;
+	unsigned int i, j, reg, regval;
+
+	/* Map the MTL Tx Queues to Traffic Classes
+	 *   Note: Tx Queues >= Traffic Classes
+	 */
+	qptc = pdata->tx_q_count / pdata->hw_feat.tc_cnt;
+	qptc_extra = pdata->tx_q_count % pdata->hw_feat.tc_cnt;
+
+	for (i = 0, queue = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		for (j = 0; j < qptc; j++) {
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "TXq%u mapped to TC%u\n", queue, i);
+			regval = readl(XLGMAC_MTL_REG(pdata, queue,
+						      MTL_Q_TQOMR));
+			regval = XLGMAC_SET_REG_BITS(regval,
+						     MTL_Q_TQOMR_Q2TCMAP_POS,
+						     MTL_Q_TQOMR_Q2TCMAP_LEN,
+						     i);
+			writel(regval, XLGMAC_MTL_REG(pdata, queue,
+						      MTL_Q_TQOMR));
+			queue++;
+		}
+
+		if (i < qptc_extra) {
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "TXq%u mapped to TC%u\n", queue, i);
+			regval = readl(XLGMAC_MTL_REG(pdata, queue,
+						      MTL_Q_TQOMR));
+			regval = XLGMAC_SET_REG_BITS(regval,
+						     MTL_Q_TQOMR_Q2TCMAP_POS,
+						     MTL_Q_TQOMR_Q2TCMAP_LEN,
+						     i);
+			writel(regval, XLGMAC_MTL_REG(pdata, queue,
+						      MTL_Q_TQOMR));
+			queue++;
+		}
+	}
+
+	/* Map the 8 VLAN priority values to available MTL Rx queues */
+	prio_queues = min_t(unsigned int, IEEE_8021QAZ_MAX_TCS,
+			    pdata->rx_q_count);
+	ppq = IEEE_8021QAZ_MAX_TCS / prio_queues;
+	ppq_extra = IEEE_8021QAZ_MAX_TCS % prio_queues;
+
+	reg = MAC_RQC2R;
+	regval = 0;
+	for (i = 0, prio = 0; i < prio_queues;) {
+		mask = 0;
+		for (j = 0; j < ppq; j++) {
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "PRIO%u mapped to RXq%u\n", prio, i);
+			mask |= (1 << prio);
+			prio++;
+		}
+
+		if (i < ppq_extra) {
+			netif_dbg(pdata, drv, pdata->netdev,
+				  "PRIO%u mapped to RXq%u\n", prio, i);
+			mask |= (1 << prio);
+			prio++;
+		}
+
+		regval |= (mask << ((i++ % MAC_RQC2_Q_PER_REG) << 3));
+
+		if ((i % MAC_RQC2_Q_PER_REG) && (i != prio_queues))
+			continue;
+
+		writel(regval, pdata->mac_regs + reg);
+		reg += MAC_RQC2_INC;
+		regval = 0;
+	}
+
+	/* Configure one to one, MTL Rx queue to DMA Rx channel mapping
+	 *  ie Q0 <--> CH0, Q1 <--> CH1 ... Q11 <--> CH11
+	 */
+	reg = MTL_RQDCM0R;
+	regval = readl(pdata->mac_regs + reg);
+	regval |= (MTL_RQDCM0R_Q0MDMACH | MTL_RQDCM0R_Q1MDMACH |
+		    MTL_RQDCM0R_Q2MDMACH | MTL_RQDCM0R_Q3MDMACH);
+	writel(regval, pdata->mac_regs + reg);
+
+	reg += MTL_RQDCM_INC;
+	regval = readl(pdata->mac_regs + reg);
+	regval |= (MTL_RQDCM1R_Q4MDMACH | MTL_RQDCM1R_Q5MDMACH |
+		    MTL_RQDCM1R_Q6MDMACH | MTL_RQDCM1R_Q7MDMACH);
+	writel(regval, pdata->mac_regs + reg);
+
+	reg += MTL_RQDCM_INC;
+	regval = readl(pdata->mac_regs + reg);
+	regval |= (MTL_RQDCM2R_Q8MDMACH | MTL_RQDCM2R_Q9MDMACH |
+		    MTL_RQDCM2R_Q10MDMACH | MTL_RQDCM2R_Q11MDMACH);
+	writel(regval, pdata->mac_regs + reg);
+}
+
+static unsigned int xlgmac_calculate_per_queue_fifo(
+					unsigned int fifo_size,
+					unsigned int queue_count)
+{
+	unsigned int q_fifo_size;
+	unsigned int p_fifo;
+
+	/* Calculate the configured fifo size */
+	q_fifo_size = 1 << (fifo_size + 7);
+
+	/* The configured value may not be the actual amount of fifo RAM */
+	q_fifo_size = min_t(unsigned int, XLGMAC_MAX_FIFO, q_fifo_size);
+
+	q_fifo_size = q_fifo_size / queue_count;
+
+	/* Each increment in the queue fifo size represents 256 bytes of
+	 * fifo, with 0 representing 256 bytes. Distribute the fifo equally
+	 * between the queues.
+	 */
+	p_fifo = q_fifo_size / 256;
+	if (p_fifo)
+		p_fifo--;
+
+	return p_fifo;
+}
+
+static void xlgmac_config_tx_fifo_size(struct xlgmac_pdata *pdata)
+{
+	unsigned int fifo_size;
+	unsigned int i;
+	u32 regval;
+
+	fifo_size = xlgmac_calculate_per_queue_fifo(
+				pdata->hw_feat.tx_fifo_size,
+				pdata->tx_q_count);
+
+	for (i = 0; i < pdata->tx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_TQOMR_TQS_POS,
+					     MTL_Q_TQOMR_TQS_LEN, fifo_size);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+	}
+
+	netif_info(pdata, drv, pdata->netdev,
+		   "%d Tx hardware queues, %d byte fifo per queue\n",
+		   pdata->tx_q_count, ((fifo_size + 1) * 256));
+}
+
+static void xlgmac_config_rx_fifo_size(struct xlgmac_pdata *pdata)
+{
+	unsigned int fifo_size;
+	unsigned int i;
+	u32 regval;
+
+	fifo_size = xlgmac_calculate_per_queue_fifo(
+					pdata->hw_feat.rx_fifo_size,
+					pdata->rx_q_count);
+
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQOMR_RQS_POS,
+					     MTL_Q_RQOMR_RQS_LEN, fifo_size);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+	}
+
+	netif_info(pdata, drv, pdata->netdev,
+		   "%d Rx hardware queues, %d byte fifo per queue\n",
+		   pdata->rx_q_count, ((fifo_size + 1) * 256));
+}
+
+static void xlgmac_config_flow_control_threshold(struct xlgmac_pdata *pdata)
+{
+	unsigned int i;
+	u32 regval;
+
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_RQFCR));
+		/* Activate flow control when less than 4k left in fifo */
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQFCR_RFA_POS,
+					     MTL_Q_RQFCR_RFA_LEN, 2);
+		/* De-activate flow control when more than 6k left in fifo */
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQFCR_RFD_POS,
+					     MTL_Q_RQFCR_RFD_LEN, 4);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_RQFCR));
+	}
+}
+
+static int xlgmac_config_tx_threshold(struct xlgmac_pdata *pdata,
+				      unsigned int val)
+{
+	unsigned int i;
+	u32 regval;
+
+	for (i = 0; i < pdata->tx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_TQOMR_TTC_POS,
+					     MTL_Q_TQOMR_TTC_LEN, val);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+	}
+
+	return 0;
+}
+
+static int xlgmac_config_rsf_mode(struct xlgmac_pdata *pdata,
+				  unsigned int val)
+{
+	unsigned int i;
+	u32 regval;
+
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_RQOMR_RSF_POS,
+					     MTL_Q_RQOMR_RSF_LEN, val);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_RQOMR));
+	}
+
+	return 0;
+}
+
+static int xlgmac_config_tsf_mode(struct xlgmac_pdata *pdata,
+				  unsigned int val)
+{
+	unsigned int i;
+	u32 regval;
+
+	for (i = 0; i < pdata->tx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_TQOMR_TSF_POS,
+					     MTL_Q_TQOMR_TSF_LEN, val);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+	}
+
+	return 0;
+}
+
+static int xlgmac_config_osp_mode(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_TCR_OSP_POS,
+					     DMA_CH_TCR_OSP_LEN,
+					pdata->tx_osp_mode);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+	}
+
+	return 0;
+}
+
+static int xlgmac_config_pblx8(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_CR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_CR_PBLX8_POS,
+					     DMA_CH_CR_PBLX8_LEN,
+					pdata->pblx8);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_CR));
+	}
+
+	return 0;
+}
+
+static int xlgmac_get_tx_pbl_val(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(XLGMAC_DMA_REG(pdata->channel_head, DMA_CH_TCR));
+	regval = XLGMAC_GET_REG_BITS(regval, DMA_CH_TCR_PBL_POS,
+				     DMA_CH_TCR_PBL_LEN);
+	return regval;
+}
+
+static int xlgmac_config_tx_pbl_val(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_TCR_PBL_POS,
+					     DMA_CH_TCR_PBL_LEN,
+					pdata->tx_pbl);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_TCR));
+	}
+
+	return 0;
+}
+
+static int xlgmac_get_rx_pbl_val(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(XLGMAC_DMA_REG(pdata->channel_head, DMA_CH_RCR));
+	regval = XLGMAC_GET_REG_BITS(regval, DMA_CH_RCR_PBL_POS,
+				     DMA_CH_RCR_PBL_LEN);
+	return regval;
+}
+
+static int xlgmac_config_rx_pbl_val(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+	u32 regval;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		regval = readl(XLGMAC_DMA_REG(channel, DMA_CH_RCR));
+		regval = XLGMAC_SET_REG_BITS(regval, DMA_CH_RCR_PBL_POS,
+					     DMA_CH_RCR_PBL_LEN,
+					pdata->rx_pbl);
+		writel(regval, XLGMAC_DMA_REG(channel, DMA_CH_RCR));
+	}
+
+	return 0;
+}
+
+static u64 xlgmac_mmc_read(struct xlgmac_pdata *pdata, unsigned int reg_lo)
+{
+	bool read_hi;
+	u64 val;
+
+	switch (reg_lo) {
+	/* These registers are always 64 bit */
+	case MMC_TXOCTETCOUNT_GB_LO:
+	case MMC_TXOCTETCOUNT_G_LO:
+	case MMC_RXOCTETCOUNT_GB_LO:
+	case MMC_RXOCTETCOUNT_G_LO:
+		read_hi = true;
+		break;
+
+	default:
+		read_hi = false;
+	}
+
+	val = (u64)readl(pdata->mac_regs + reg_lo);
+
+	if (read_hi)
+		val |= ((u64)readl(pdata->mac_regs + reg_lo + 4) << 32);
+
+	return val;
+}
+
+static void xlgmac_tx_mmc_int(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_stats *stats = &pdata->stats;
+	unsigned int mmc_isr = readl(pdata->mac_regs + MMC_TISR);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXOCTETCOUNT_GB_POS,
+				MMC_TISR_TXOCTETCOUNT_GB_LEN))
+		stats->txoctetcount_gb +=
+			xlgmac_mmc_read(pdata, MMC_TXOCTETCOUNT_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXFRAMECOUNT_GB_POS,
+				MMC_TISR_TXFRAMECOUNT_GB_LEN))
+		stats->txframecount_gb +=
+			xlgmac_mmc_read(pdata, MMC_TXFRAMECOUNT_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXBROADCASTFRAMES_G_POS,
+				MMC_TISR_TXBROADCASTFRAMES_G_LEN))
+		stats->txbroadcastframes_g +=
+			xlgmac_mmc_read(pdata, MMC_TXBROADCASTFRAMES_G_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXMULTICASTFRAMES_G_POS,
+				MMC_TISR_TXMULTICASTFRAMES_G_LEN))
+		stats->txmulticastframes_g +=
+			xlgmac_mmc_read(pdata, MMC_TXMULTICASTFRAMES_G_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TX64OCTETS_GB_POS,
+				MMC_TISR_TX64OCTETS_GB_LEN))
+		stats->tx64octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_TX64OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TX65TO127OCTETS_GB_POS,
+				MMC_TISR_TX65TO127OCTETS_GB_LEN))
+		stats->tx65to127octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_TX65TO127OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TX128TO255OCTETS_GB_POS,
+				MMC_TISR_TX128TO255OCTETS_GB_LEN))
+		stats->tx128to255octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_TX128TO255OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TX256TO511OCTETS_GB_POS,
+				MMC_TISR_TX256TO511OCTETS_GB_LEN))
+		stats->tx256to511octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_TX256TO511OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TX512TO1023OCTETS_GB_POS,
+				MMC_TISR_TX512TO1023OCTETS_GB_LEN))
+		stats->tx512to1023octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_TX512TO1023OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TX1024TOMAXOCTETS_GB_POS,
+				MMC_TISR_TX1024TOMAXOCTETS_GB_LEN))
+		stats->tx1024tomaxoctets_gb +=
+			xlgmac_mmc_read(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXUNICASTFRAMES_GB_POS,
+				MMC_TISR_TXUNICASTFRAMES_GB_LEN))
+		stats->txunicastframes_gb +=
+			xlgmac_mmc_read(pdata, MMC_TXUNICASTFRAMES_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXMULTICASTFRAMES_GB_POS,
+				MMC_TISR_TXMULTICASTFRAMES_GB_LEN))
+		stats->txmulticastframes_gb +=
+			xlgmac_mmc_read(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXBROADCASTFRAMES_GB_POS,
+				MMC_TISR_TXBROADCASTFRAMES_GB_LEN))
+		stats->txbroadcastframes_g +=
+			xlgmac_mmc_read(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXUNDERFLOWERROR_POS,
+				MMC_TISR_TXUNDERFLOWERROR_LEN))
+		stats->txunderflowerror +=
+			xlgmac_mmc_read(pdata, MMC_TXUNDERFLOWERROR_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXOCTETCOUNT_G_POS,
+				MMC_TISR_TXOCTETCOUNT_G_LEN))
+		stats->txoctetcount_g +=
+			xlgmac_mmc_read(pdata, MMC_TXOCTETCOUNT_G_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXFRAMECOUNT_G_POS,
+				MMC_TISR_TXFRAMECOUNT_G_LEN))
+		stats->txframecount_g +=
+			xlgmac_mmc_read(pdata, MMC_TXFRAMECOUNT_G_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXPAUSEFRAMES_POS,
+				MMC_TISR_TXPAUSEFRAMES_LEN))
+		stats->txpauseframes +=
+			xlgmac_mmc_read(pdata, MMC_TXPAUSEFRAMES_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_TISR_TXVLANFRAMES_G_POS,
+				MMC_TISR_TXVLANFRAMES_G_LEN))
+		stats->txvlanframes_g +=
+			xlgmac_mmc_read(pdata, MMC_TXVLANFRAMES_G_LO);
+}
+
+static void xlgmac_rx_mmc_int(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_stats *stats = &pdata->stats;
+	unsigned int mmc_isr = readl(pdata->mac_regs + MMC_RISR);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXFRAMECOUNT_GB_POS,
+				MMC_RISR_RXFRAMECOUNT_GB_LEN))
+		stats->rxframecount_gb +=
+			xlgmac_mmc_read(pdata, MMC_RXFRAMECOUNT_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXOCTETCOUNT_GB_POS,
+				MMC_RISR_RXOCTETCOUNT_GB_LEN))
+		stats->rxoctetcount_gb +=
+			xlgmac_mmc_read(pdata, MMC_RXOCTETCOUNT_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXOCTETCOUNT_G_POS,
+				MMC_RISR_RXOCTETCOUNT_G_LEN))
+		stats->rxoctetcount_g +=
+			xlgmac_mmc_read(pdata, MMC_RXOCTETCOUNT_G_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXBROADCASTFRAMES_G_POS,
+				MMC_RISR_RXBROADCASTFRAMES_G_LEN))
+		stats->rxbroadcastframes_g +=
+			xlgmac_mmc_read(pdata, MMC_RXBROADCASTFRAMES_G_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXMULTICASTFRAMES_G_POS,
+				MMC_RISR_RXMULTICASTFRAMES_G_LEN))
+		stats->rxmulticastframes_g +=
+			xlgmac_mmc_read(pdata, MMC_RXMULTICASTFRAMES_G_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXCRCERROR_POS,
+				MMC_RISR_RXCRCERROR_LEN))
+		stats->rxcrcerror +=
+			xlgmac_mmc_read(pdata, MMC_RXCRCERROR_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXRUNTERROR_POS,
+				MMC_RISR_RXRUNTERROR_LEN))
+		stats->rxrunterror +=
+			xlgmac_mmc_read(pdata, MMC_RXRUNTERROR);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXJABBERERROR_POS,
+				MMC_RISR_RXJABBERERROR_LEN))
+		stats->rxjabbererror +=
+			xlgmac_mmc_read(pdata, MMC_RXJABBERERROR);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXUNDERSIZE_G_POS,
+				MMC_RISR_RXUNDERSIZE_G_LEN))
+		stats->rxundersize_g +=
+			xlgmac_mmc_read(pdata, MMC_RXUNDERSIZE_G);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXOVERSIZE_G_POS,
+				MMC_RISR_RXOVERSIZE_G_LEN))
+		stats->rxoversize_g +=
+			xlgmac_mmc_read(pdata, MMC_RXOVERSIZE_G);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RX64OCTETS_GB_POS,
+				MMC_RISR_RX64OCTETS_GB_LEN))
+		stats->rx64octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_RX64OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RX65TO127OCTETS_GB_POS,
+				MMC_RISR_RX65TO127OCTETS_GB_LEN))
+		stats->rx65to127octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_RX65TO127OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RX128TO255OCTETS_GB_POS,
+				MMC_RISR_RX128TO255OCTETS_GB_LEN))
+		stats->rx128to255octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_RX128TO255OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RX256TO511OCTETS_GB_POS,
+				MMC_RISR_RX256TO511OCTETS_GB_LEN))
+		stats->rx256to511octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_RX256TO511OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RX512TO1023OCTETS_GB_POS,
+				MMC_RISR_RX512TO1023OCTETS_GB_LEN))
+		stats->rx512to1023octets_gb +=
+			xlgmac_mmc_read(pdata, MMC_RX512TO1023OCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RX1024TOMAXOCTETS_GB_POS,
+				MMC_RISR_RX1024TOMAXOCTETS_GB_LEN))
+		stats->rx1024tomaxoctets_gb +=
+			xlgmac_mmc_read(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXUNICASTFRAMES_G_POS,
+				MMC_RISR_RXUNICASTFRAMES_G_LEN))
+		stats->rxunicastframes_g +=
+			xlgmac_mmc_read(pdata, MMC_RXUNICASTFRAMES_G_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXLENGTHERROR_POS,
+				MMC_RISR_RXLENGTHERROR_LEN))
+		stats->rxlengtherror +=
+			xlgmac_mmc_read(pdata, MMC_RXLENGTHERROR_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXOUTOFRANGETYPE_POS,
+				MMC_RISR_RXOUTOFRANGETYPE_LEN))
+		stats->rxoutofrangetype +=
+			xlgmac_mmc_read(pdata, MMC_RXOUTOFRANGETYPE_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXPAUSEFRAMES_POS,
+				MMC_RISR_RXPAUSEFRAMES_LEN))
+		stats->rxpauseframes +=
+			xlgmac_mmc_read(pdata, MMC_RXPAUSEFRAMES_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXFIFOOVERFLOW_POS,
+				MMC_RISR_RXFIFOOVERFLOW_LEN))
+		stats->rxfifooverflow +=
+			xlgmac_mmc_read(pdata, MMC_RXFIFOOVERFLOW_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXVLANFRAMES_GB_POS,
+				MMC_RISR_RXVLANFRAMES_GB_LEN))
+		stats->rxvlanframes_gb +=
+			xlgmac_mmc_read(pdata, MMC_RXVLANFRAMES_GB_LO);
+
+	if (XLGMAC_GET_REG_BITS(mmc_isr,
+				MMC_RISR_RXWATCHDOGERROR_POS,
+				MMC_RISR_RXWATCHDOGERROR_LEN))
+		stats->rxwatchdogerror +=
+			xlgmac_mmc_read(pdata, MMC_RXWATCHDOGERROR);
+}
+
+static void xlgmac_read_mmc_stats(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_stats *stats = &pdata->stats;
+	u32 regval;
+
+	/* Freeze counters */
+	regval = readl(pdata->mac_regs + MMC_CR);
+	regval = XLGMAC_SET_REG_BITS(regval, MMC_CR_MCF_POS,
+				     MMC_CR_MCF_LEN, 1);
+	writel(regval, pdata->mac_regs + MMC_CR);
+
+	stats->txoctetcount_gb +=
+		xlgmac_mmc_read(pdata, MMC_TXOCTETCOUNT_GB_LO);
+
+	stats->txframecount_gb +=
+		xlgmac_mmc_read(pdata, MMC_TXFRAMECOUNT_GB_LO);
+
+	stats->txbroadcastframes_g +=
+		xlgmac_mmc_read(pdata, MMC_TXBROADCASTFRAMES_G_LO);
+
+	stats->txmulticastframes_g +=
+		xlgmac_mmc_read(pdata, MMC_TXMULTICASTFRAMES_G_LO);
+
+	stats->tx64octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_TX64OCTETS_GB_LO);
+
+	stats->tx65to127octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_TX65TO127OCTETS_GB_LO);
+
+	stats->tx128to255octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_TX128TO255OCTETS_GB_LO);
+
+	stats->tx256to511octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_TX256TO511OCTETS_GB_LO);
+
+	stats->tx512to1023octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_TX512TO1023OCTETS_GB_LO);
+
+	stats->tx1024tomaxoctets_gb +=
+		xlgmac_mmc_read(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
+
+	stats->txunicastframes_gb +=
+		xlgmac_mmc_read(pdata, MMC_TXUNICASTFRAMES_GB_LO);
+
+	stats->txmulticastframes_gb +=
+		xlgmac_mmc_read(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
+
+	stats->txbroadcastframes_g +=
+		xlgmac_mmc_read(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
+
+	stats->txunderflowerror +=
+		xlgmac_mmc_read(pdata, MMC_TXUNDERFLOWERROR_LO);
+
+	stats->txoctetcount_g +=
+		xlgmac_mmc_read(pdata, MMC_TXOCTETCOUNT_G_LO);
+
+	stats->txframecount_g +=
+		xlgmac_mmc_read(pdata, MMC_TXFRAMECOUNT_G_LO);
+
+	stats->txpauseframes +=
+		xlgmac_mmc_read(pdata, MMC_TXPAUSEFRAMES_LO);
+
+	stats->txvlanframes_g +=
+		xlgmac_mmc_read(pdata, MMC_TXVLANFRAMES_G_LO);
+
+	stats->rxframecount_gb +=
+		xlgmac_mmc_read(pdata, MMC_RXFRAMECOUNT_GB_LO);
+
+	stats->rxoctetcount_gb +=
+		xlgmac_mmc_read(pdata, MMC_RXOCTETCOUNT_GB_LO);
+
+	stats->rxoctetcount_g +=
+		xlgmac_mmc_read(pdata, MMC_RXOCTETCOUNT_G_LO);
+
+	stats->rxbroadcastframes_g +=
+		xlgmac_mmc_read(pdata, MMC_RXBROADCASTFRAMES_G_LO);
+
+	stats->rxmulticastframes_g +=
+		xlgmac_mmc_read(pdata, MMC_RXMULTICASTFRAMES_G_LO);
+
+	stats->rxcrcerror +=
+		xlgmac_mmc_read(pdata, MMC_RXCRCERROR_LO);
+
+	stats->rxrunterror +=
+		xlgmac_mmc_read(pdata, MMC_RXRUNTERROR);
+
+	stats->rxjabbererror +=
+		xlgmac_mmc_read(pdata, MMC_RXJABBERERROR);
+
+	stats->rxundersize_g +=
+		xlgmac_mmc_read(pdata, MMC_RXUNDERSIZE_G);
+
+	stats->rxoversize_g +=
+		xlgmac_mmc_read(pdata, MMC_RXOVERSIZE_G);
+
+	stats->rx64octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_RX64OCTETS_GB_LO);
+
+	stats->rx65to127octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_RX65TO127OCTETS_GB_LO);
+
+	stats->rx128to255octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_RX128TO255OCTETS_GB_LO);
+
+	stats->rx256to511octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_RX256TO511OCTETS_GB_LO);
+
+	stats->rx512to1023octets_gb +=
+		xlgmac_mmc_read(pdata, MMC_RX512TO1023OCTETS_GB_LO);
+
+	stats->rx1024tomaxoctets_gb +=
+		xlgmac_mmc_read(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
+
+	stats->rxunicastframes_g +=
+		xlgmac_mmc_read(pdata, MMC_RXUNICASTFRAMES_G_LO);
+
+	stats->rxlengtherror +=
+		xlgmac_mmc_read(pdata, MMC_RXLENGTHERROR_LO);
+
+	stats->rxoutofrangetype +=
+		xlgmac_mmc_read(pdata, MMC_RXOUTOFRANGETYPE_LO);
+
+	stats->rxpauseframes +=
+		xlgmac_mmc_read(pdata, MMC_RXPAUSEFRAMES_LO);
+
+	stats->rxfifooverflow +=
+		xlgmac_mmc_read(pdata, MMC_RXFIFOOVERFLOW_LO);
+
+	stats->rxvlanframes_gb +=
+		xlgmac_mmc_read(pdata, MMC_RXVLANFRAMES_GB_LO);
+
+	stats->rxwatchdogerror +=
+		xlgmac_mmc_read(pdata, MMC_RXWATCHDOGERROR);
+
+	/* Un-freeze counters */
+	regval = readl(pdata->mac_regs + MMC_CR);
+	regval = XLGMAC_SET_REG_BITS(regval, MMC_CR_MCF_POS,
+				     MMC_CR_MCF_LEN, 0);
+	writel(regval, pdata->mac_regs + MMC_CR);
+}
+
+static void xlgmac_config_mmc(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + MMC_CR);
+	/* Set counters to reset on read */
+	regval = XLGMAC_SET_REG_BITS(regval, MMC_CR_ROR_POS,
+				     MMC_CR_ROR_LEN, 1);
+	/* Reset the counters */
+	regval = XLGMAC_SET_REG_BITS(regval, MMC_CR_CR_POS,
+				     MMC_CR_CR_LEN, 1);
+	writel(regval, pdata->mac_regs + MMC_CR);
+}
+
+static int xlgmac_write_rss_reg(struct xlgmac_pdata *pdata, unsigned int type,
+				unsigned int index, unsigned int val)
+{
+	unsigned int wait;
+	int ret = 0;
+	u32 regval;
+
+	mutex_lock(&pdata->rss_mutex);
+
+	regval = XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + MAC_RSSAR),
+				     MAC_RSSAR_OB_POS, MAC_RSSAR_OB_LEN);
+	if (regval) {
+		ret = -EBUSY;
+		goto unlock;
+	}
+
+	writel(val, pdata->mac_regs + MAC_RSSDR);
+
+	regval = readl(pdata->mac_regs + MAC_RSSAR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RSSAR_RSSIA_POS,
+				     MAC_RSSAR_RSSIA_LEN, index);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RSSAR_ADDRT_POS,
+				     MAC_RSSAR_ADDRT_LEN, type);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RSSAR_CT_POS,
+				     MAC_RSSAR_CT_LEN, 0);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RSSAR_OB_POS,
+				     MAC_RSSAR_OB_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_RSSAR);
+
+	wait = 1000;
+	while (wait--) {
+		regval = XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + MAC_RSSAR),
+					     MAC_RSSAR_OB_POS,
+					     MAC_RSSAR_OB_LEN);
+		if (!regval)
+			goto unlock;
+
+		usleep_range(1000, 1500);
+	}
+
+	ret = -EBUSY;
+
+unlock:
+	mutex_unlock(&pdata->rss_mutex);
+
+	return ret;
+}
+
+static int xlgmac_write_rss_hash_key(struct xlgmac_pdata *pdata)
+{
+	unsigned int key_regs = sizeof(pdata->rss_key) / sizeof(u32);
+	unsigned int *key = (unsigned int *)&pdata->rss_key;
+	int ret;
+
+	while (key_regs--) {
+		ret = xlgmac_write_rss_reg(pdata, XLGMAC_RSS_HASH_KEY_TYPE,
+					   key_regs, *key++);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int xlgmac_write_rss_lookup_table(struct xlgmac_pdata *pdata)
+{
+	unsigned int i;
+	int ret;
+
+	for (i = 0; i < ARRAY_SIZE(pdata->rss_table); i++) {
+		ret = xlgmac_write_rss_reg(pdata,
+					   XLGMAC_RSS_LOOKUP_TABLE_TYPE, i,
+					   pdata->rss_table[i]);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int xlgmac_set_rss_hash_key(struct xlgmac_pdata *pdata, const u8 *key)
+{
+	memcpy(pdata->rss_key, key, sizeof(pdata->rss_key));
+
+	return xlgmac_write_rss_hash_key(pdata);
+}
+
+static int xlgmac_set_rss_lookup_table(struct xlgmac_pdata *pdata,
+				       const u32 *table)
+{
+	unsigned int i;
+	u32 tval;
+
+	for (i = 0; i < ARRAY_SIZE(pdata->rss_table); i++) {
+		tval = table[i];
+		pdata->rss_table[i] = XLGMAC_SET_REG_BITS(
+						pdata->rss_table[i],
+						MAC_RSSDR_DMCH_POS,
+						MAC_RSSDR_DMCH_LEN,
+						tval);
+	}
+
+	return xlgmac_write_rss_lookup_table(pdata);
+}
+
+static int xlgmac_enable_rss(struct xlgmac_pdata *pdata)
+{
+	int ret;
+	u32 regval;
+
+	if (!pdata->hw_feat.rss)
+		return -EOPNOTSUPP;
+
+	/* Program the hash key */
+	ret = xlgmac_write_rss_hash_key(pdata);
+	if (ret)
+		return ret;
+
+	/* Program the lookup table */
+	ret = xlgmac_write_rss_lookup_table(pdata);
+	if (ret)
+		return ret;
+
+	/* Set the RSS options */
+	writel(pdata->rss_options, pdata->mac_regs + MAC_RSSCR);
+
+	/* Enable RSS */
+	regval = readl(pdata->mac_regs + MAC_RSSCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RSSCR_RSSE_POS,
+				     MAC_RSSCR_RSSE_LEN, 1);
+	writel(regval, pdata->mac_regs + MAC_RSSCR);
+
+	return 0;
+}
+
+static int xlgmac_disable_rss(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	if (!pdata->hw_feat.rss)
+		return -EOPNOTSUPP;
+
+	regval = readl(pdata->mac_regs + MAC_RSSCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_RSSCR_RSSE_POS,
+				     MAC_RSSCR_RSSE_LEN, 0);
+	writel(regval, pdata->mac_regs + MAC_RSSCR);
+
+	return 0;
+}
+
+static void xlgmac_config_rss(struct xlgmac_pdata *pdata)
+{
+	int ret;
+
+	if (!pdata->hw_feat.rss)
+		return;
+
+	if (pdata->netdev->features & NETIF_F_RXHASH)
+		ret = xlgmac_enable_rss(pdata);
+	else
+		ret = xlgmac_disable_rss(pdata);
+
+	if (ret)
+		netdev_err(pdata->netdev,
+			   "error configuring RSS, RSS disabled\n");
+}
+
+static void xlgmac_enable_dma_interrupts(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int dma_ch_isr, dma_ch_ier;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		/* Clear all the interrupts which are set */
+		dma_ch_isr = readl(XLGMAC_DMA_REG(channel, DMA_CH_SR));
+		writel(dma_ch_isr, XLGMAC_DMA_REG(channel, DMA_CH_SR));
+
+		/* Clear all interrupt enable bits */
+		dma_ch_ier = 0;
+
+		/* Enable following interrupts
+		 *   NIE  - Normal Interrupt Summary Enable
+		 *   AIE  - Abnormal Interrupt Summary Enable
+		 *   FBEE - Fatal Bus Error Enable
+		 */
+		dma_ch_ier = XLGMAC_SET_REG_BITS(dma_ch_ier,
+						 DMA_CH_IER_NIE_POS,
+					DMA_CH_IER_NIE_LEN, 1);
+		dma_ch_ier = XLGMAC_SET_REG_BITS(dma_ch_ier,
+						 DMA_CH_IER_AIE_POS,
+					DMA_CH_IER_AIE_LEN, 1);
+		dma_ch_ier = XLGMAC_SET_REG_BITS(dma_ch_ier,
+						 DMA_CH_IER_FBEE_POS,
+					DMA_CH_IER_FBEE_LEN, 1);
+
+		if (channel->tx_ring) {
+			/* Enable the following Tx interrupts
+			 *   TIE  - Transmit Interrupt Enable (unless using
+			 *          per channel interrupts)
+			 */
+			if (!pdata->per_channel_irq)
+				dma_ch_ier = XLGMAC_SET_REG_BITS(
+						dma_ch_ier,
+						DMA_CH_IER_TIE_POS,
+						DMA_CH_IER_TIE_LEN,
+						1);
+		}
+		if (channel->rx_ring) {
+			/* Enable following Rx interrupts
+			 *   RBUE - Receive Buffer Unavailable Enable
+			 *   RIE  - Receive Interrupt Enable (unless using
+			 *          per channel interrupts)
+			 */
+			dma_ch_ier = XLGMAC_SET_REG_BITS(
+					dma_ch_ier,
+					DMA_CH_IER_RBUE_POS,
+					DMA_CH_IER_RBUE_LEN,
+					1);
+			if (!pdata->per_channel_irq)
+				dma_ch_ier = XLGMAC_SET_REG_BITS(
+						dma_ch_ier,
+						DMA_CH_IER_RIE_POS,
+						DMA_CH_IER_RIE_LEN,
+						1);
+		}
+
+		writel(dma_ch_isr, XLGMAC_DMA_REG(channel, DMA_CH_IER));
+	}
+}
+
+static void xlgmac_enable_mtl_interrupts(struct xlgmac_pdata *pdata)
+{
+	unsigned int mtl_q_isr;
+	unsigned int q_count, i;
+
+	q_count = max(pdata->hw_feat.tx_q_cnt, pdata->hw_feat.rx_q_cnt);
+	for (i = 0; i < q_count; i++) {
+		/* Clear all the interrupts which are set */
+		mtl_q_isr = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_ISR));
+		writel(mtl_q_isr, XLGMAC_MTL_REG(pdata, i, MTL_Q_ISR));
+
+		/* No MTL interrupts to be enabled */
+		writel(0, XLGMAC_MTL_REG(pdata, i, MTL_Q_IER));
+	}
+}
+
+static void xlgmac_enable_mac_interrupts(struct xlgmac_pdata *pdata)
+{
+	unsigned int mac_ier = 0;
+	u32 regval;
+
+	/* Enable Timestamp interrupt */
+	mac_ier = XLGMAC_SET_REG_BITS(mac_ier, MAC_IER_TSIE_POS,
+				      MAC_IER_TSIE_LEN, 1);
+
+	writel(mac_ier, pdata->mac_regs + MAC_IER);
+
+	/* Enable all counter interrupts */
+	regval = readl(pdata->mac_regs + MMC_RIER);
+	regval = XLGMAC_SET_REG_BITS(regval, MMC_RIER_ALL_INTERRUPTS_POS,
+				     MMC_RIER_ALL_INTERRUPTS_LEN, 0xffffffff);
+	writel(regval, pdata->mac_regs + MMC_RIER);
+	regval = readl(pdata->mac_regs + MMC_TIER);
+	regval = XLGMAC_SET_REG_BITS(regval, MMC_TIER_ALL_INTERRUPTS_POS,
+				     MMC_TIER_ALL_INTERRUPTS_LEN, 0xffffffff);
+	writel(regval, pdata->mac_regs + MMC_TIER);
+}
+
+static int xlgmac_set_xlgmii_25000_speed(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + MAC_TCR),
+				     MAC_TCR_SS_POS, MAC_TCR_SS_LEN);
+	if (regval == 0x1)
+		return 0;
+
+	regval = readl(pdata->mac_regs + MAC_TCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_TCR_SS_POS,
+				     MAC_TCR_SS_LEN, 0x1);
+	writel(regval, pdata->mac_regs + MAC_TCR);
+
+	return 0;
+}
+
+static int xlgmac_set_xlgmii_40000_speed(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + MAC_TCR),
+				     MAC_TCR_SS_POS, MAC_TCR_SS_LEN);
+	if (regval == 0)
+		return 0;
+
+	regval = readl(pdata->mac_regs + MAC_TCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_TCR_SS_POS,
+				     MAC_TCR_SS_LEN, 0);
+	writel(regval, pdata->mac_regs + MAC_TCR);
+
+	return 0;
+}
+
+static int xlgmac_set_xlgmii_50000_speed(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + MAC_TCR),
+				     MAC_TCR_SS_POS, MAC_TCR_SS_LEN);
+	if (regval == 0x2)
+		return 0;
+
+	regval = readl(pdata->mac_regs + MAC_TCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_TCR_SS_POS,
+				     MAC_TCR_SS_LEN, 0x2);
+	writel(regval, pdata->mac_regs + MAC_TCR);
+
+	return 0;
+}
+
+static int xlgmac_set_xlgmii_100000_speed(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + MAC_TCR),
+				     MAC_TCR_SS_POS, MAC_TCR_SS_LEN);
+	if (regval == 0x3)
+		return 0;
+
+	regval = readl(pdata->mac_regs + MAC_TCR);
+	regval = XLGMAC_SET_REG_BITS(regval, MAC_TCR_SS_POS,
+				     MAC_TCR_SS_LEN, 0x3);
+	writel(regval, pdata->mac_regs + MAC_TCR);
+
+	return 0;
+}
+
+static void xlgmac_config_mac_speed(struct xlgmac_pdata *pdata)
+{
+	switch (pdata->phy_speed) {
+	case SPEED_100000:
+		xlgmac_set_xlgmii_100000_speed(pdata);
+		break;
+
+	case SPEED_50000:
+		xlgmac_set_xlgmii_50000_speed(pdata);
+		break;
+
+	case SPEED_40000:
+		xlgmac_set_xlgmii_40000_speed(pdata);
+		break;
+
+	case SPEED_25000:
+		xlgmac_set_xlgmii_25000_speed(pdata);
+		break;
+	}
+}
+
+static int xlgmac_dev_read(struct xlgmac_channel *channel)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct xlgmac_ring *ring = channel->rx_ring;
+	struct xlgmac_desc_data *desc_data;
+	struct xlgmac_dma_desc *dma_desc;
+	struct xlgmac_pkt_info *pkt_info = &ring->pkt_info;
+	struct net_device *netdev = pdata->netdev;
+	unsigned int err, etlt, l34t;
+
+	desc_data = XLGMAC_GET_DESC_DATA(ring, ring->cur);
+	dma_desc = desc_data->dma_desc;
+
+	/* Check for data availability */
+	if (XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				   RX_NORMAL_DESC3_OWN_POS,
+				   RX_NORMAL_DESC3_OWN_LEN))
+		return 1;
+
+	/* Make sure descriptor fields are read after reading the OWN bit */
+	dma_rmb();
+
+	if (netif_msg_rx_status(pdata))
+		xlgmac_dump_rx_desc(pdata, ring, ring->cur);
+
+	if (XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				   RX_NORMAL_DESC3_CTXT_POS,
+				   RX_NORMAL_DESC3_CTXT_LEN)) {
+		/* Timestamp Context Descriptor */
+		xlgmac_get_rx_tstamp(pkt_info, dma_desc);
+
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+					pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_CONTEXT_POS,
+					RX_PACKET_ATTRIBUTES_CONTEXT_LEN,
+					1);
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+				pkt_info->attributes,
+				RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_POS,
+				RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_LEN,
+				0);
+		return 0;
+	}
+
+	/* Normal Descriptor, be sure Context Descriptor bit is off */
+	pkt_info->attributes = XLGMAC_SET_REG_BITS(
+				pkt_info->attributes,
+				RX_PACKET_ATTRIBUTES_CONTEXT_POS,
+				RX_PACKET_ATTRIBUTES_CONTEXT_LEN,
+				0);
+
+	/* Indicate if a Context Descriptor is next */
+	if (XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				   RX_NORMAL_DESC3_CDA_POS,
+				   RX_NORMAL_DESC3_CDA_LEN))
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+				pkt_info->attributes,
+				RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_POS,
+				RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_LEN,
+				1);
+
+	/* Get the header length */
+	if (XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				   RX_NORMAL_DESC3_FD_POS,
+				   RX_NORMAL_DESC3_FD_LEN)) {
+		desc_data->rx.hdr_len = XLGMAC_GET_REG_BITS_LE(dma_desc->desc2,
+							RX_NORMAL_DESC2_HL_POS,
+							RX_NORMAL_DESC2_HL_LEN);
+		if (desc_data->rx.hdr_len)
+			pdata->stats.rx_split_header_packets++;
+	}
+
+	/* Get the RSS hash */
+	if (XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				   RX_NORMAL_DESC3_RSV_POS,
+				   RX_NORMAL_DESC3_RSV_LEN)) {
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+				pkt_info->attributes,
+				RX_PACKET_ATTRIBUTES_RSS_HASH_POS,
+				RX_PACKET_ATTRIBUTES_RSS_HASH_LEN,
+				1);
+
+		pkt_info->rss_hash = le32_to_cpu(dma_desc->desc1);
+
+		l34t = XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+					      RX_NORMAL_DESC3_L34T_POS,
+					  RX_NORMAL_DESC3_L34T_LEN);
+		switch (l34t) {
+		case RX_DESC3_L34T_IPV4_TCP:
+		case RX_DESC3_L34T_IPV4_UDP:
+		case RX_DESC3_L34T_IPV6_TCP:
+		case RX_DESC3_L34T_IPV6_UDP:
+			pkt_info->rss_hash_type = PKT_HASH_TYPE_L4;
+			break;
+		default:
+			pkt_info->rss_hash_type = PKT_HASH_TYPE_L3;
+		}
+	}
+
+	/* Get the pkt_info length */
+	desc_data->rx.len = XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+					RX_NORMAL_DESC3_PL_POS,
+					RX_NORMAL_DESC3_PL_LEN);
+
+	if (!XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				    RX_NORMAL_DESC3_LD_POS,
+				    RX_NORMAL_DESC3_LD_LEN)) {
+		/* Not all the data has been transferred for this pkt_info */
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+				pkt_info->attributes,
+				RX_PACKET_ATTRIBUTES_INCOMPLETE_POS,
+				RX_PACKET_ATTRIBUTES_INCOMPLETE_LEN,
+				1);
+		return 0;
+	}
+
+	/* This is the last of the data for this pkt_info */
+	pkt_info->attributes = XLGMAC_SET_REG_BITS(
+			pkt_info->attributes,
+			RX_PACKET_ATTRIBUTES_INCOMPLETE_POS,
+			RX_PACKET_ATTRIBUTES_INCOMPLETE_LEN,
+			0);
+
+	/* Set checksum done indicator as appropriate */
+	if (netdev->features & NETIF_F_RXCSUM)
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+				pkt_info->attributes,
+				RX_PACKET_ATTRIBUTES_CSUM_DONE_POS,
+				RX_PACKET_ATTRIBUTES_CSUM_DONE_LEN,
+				1);
+
+	/* Check for errors (only valid in last descriptor) */
+	err = XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				     RX_NORMAL_DESC3_ES_POS,
+				     RX_NORMAL_DESC3_ES_LEN);
+	etlt = XLGMAC_GET_REG_BITS_LE(dma_desc->desc3,
+				      RX_NORMAL_DESC3_ETLT_POS,
+				      RX_NORMAL_DESC3_ETLT_LEN);
+	netif_dbg(pdata, rx_status, netdev, "err=%u, etlt=%#x\n", err, etlt);
+
+	if (!err || !etlt) {
+		/* No error if err is 0 or etlt is 0 */
+		if ((etlt == 0x09) &&
+		    (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
+			pkt_info->attributes = XLGMAC_SET_REG_BITS(
+					pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_VLAN_CTAG_POS,
+					RX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN,
+					1);
+			pkt_info->vlan_ctag =
+				XLGMAC_GET_REG_BITS_LE(dma_desc->desc0,
+						       RX_NORMAL_DESC0_OVT_POS,
+						   RX_NORMAL_DESC0_OVT_LEN);
+			netif_dbg(pdata, rx_status, netdev, "vlan-ctag=%#06x\n",
+				  pkt_info->vlan_ctag);
+		}
+	} else {
+		if ((etlt == 0x05) || (etlt == 0x06))
+			pkt_info->attributes = XLGMAC_SET_REG_BITS(
+					pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_CSUM_DONE_POS,
+					RX_PACKET_ATTRIBUTES_CSUM_DONE_LEN,
+					0);
+		else
+			pkt_info->errors = XLGMAC_SET_REG_BITS(
+					pkt_info->errors,
+					RX_PACKET_ERRORS_FRAME_POS,
+					RX_PACKET_ERRORS_FRAME_LEN,
+					1);
+	}
+
+	XLGMAC_PR("%s - descriptor=%u (cur=%d)\n", channel->name,
+		  ring->cur & (ring->dma_desc_count - 1), ring->cur);
+
+	return 0;
+}
+
+static int xlgmac_enable_int(struct xlgmac_channel *channel,
+			     enum xlgmac_int int_id)
+{
+	unsigned int dma_ch_ier;
+
+	dma_ch_ier = readl(XLGMAC_DMA_REG(channel, DMA_CH_IER));
+
+	switch (int_id) {
+	case XLGMAC_INT_DMA_CH_SR_TI:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_TIE_POS,
+				DMA_CH_IER_TIE_LEN, 1);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_TPS:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_TXSE_POS,
+				DMA_CH_IER_TXSE_LEN, 1);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_TBU:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_TBUE_POS,
+				DMA_CH_IER_TBUE_LEN, 1);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_RI:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_RIE_POS,
+				DMA_CH_IER_RIE_LEN, 1);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_RBU:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_RBUE_POS,
+				DMA_CH_IER_RBUE_LEN, 1);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_RPS:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_RSE_POS,
+				DMA_CH_IER_RSE_LEN, 1);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_TI_RI:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_TIE_POS,
+				DMA_CH_IER_TIE_LEN, 1);
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_RIE_POS,
+				DMA_CH_IER_RIE_LEN, 1);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_FBE:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_FBEE_POS,
+				DMA_CH_IER_FBEE_LEN, 1);
+		break;
+	case XLGMAC_INT_DMA_ALL:
+		dma_ch_ier |= channel->saved_ier;
+		break;
+	default:
+		return -1;
+	}
+
+	writel(dma_ch_ier, XLGMAC_DMA_REG(channel, DMA_CH_IER));
+
+	return 0;
+}
+
+static int xlgmac_disable_int(struct xlgmac_channel *channel,
+			      enum xlgmac_int int_id)
+{
+	unsigned int dma_ch_ier;
+
+	dma_ch_ier = readl(XLGMAC_DMA_REG(channel, DMA_CH_IER));
+
+	switch (int_id) {
+	case XLGMAC_INT_DMA_CH_SR_TI:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_TIE_POS,
+				DMA_CH_IER_TIE_LEN, 0);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_TPS:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_TXSE_POS,
+				DMA_CH_IER_TXSE_LEN, 0);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_TBU:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_TBUE_POS,
+				DMA_CH_IER_TBUE_LEN, 0);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_RI:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_RIE_POS,
+				DMA_CH_IER_RIE_LEN, 0);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_RBU:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_RBUE_POS,
+				DMA_CH_IER_RBUE_LEN, 0);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_RPS:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_RSE_POS,
+				DMA_CH_IER_RSE_LEN, 0);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_TI_RI:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_TIE_POS,
+				DMA_CH_IER_TIE_LEN, 0);
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_RIE_POS,
+				DMA_CH_IER_RIE_LEN, 0);
+		break;
+	case XLGMAC_INT_DMA_CH_SR_FBE:
+		dma_ch_ier = XLGMAC_SET_REG_BITS(
+				dma_ch_ier, DMA_CH_IER_FBEE_POS,
+				DMA_CH_IER_FBEE_LEN, 0);
+		break;
+	case XLGMAC_INT_DMA_ALL:
+		channel->saved_ier = dma_ch_ier & XLGMAC_DMA_INTERRUPT_MASK;
+		dma_ch_ier &= ~XLGMAC_DMA_INTERRUPT_MASK;
+		break;
+	default:
+		return -1;
+	}
+
+	writel(dma_ch_ier, XLGMAC_DMA_REG(channel, DMA_CH_IER));
+
+	return 0;
+}
+
+static int xlgmac_flush_tx_queues(struct xlgmac_pdata *pdata)
+{
+	unsigned int i, count;
+	u32 regval;
+
+	for (i = 0; i < pdata->tx_q_count; i++) {
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+		regval = XLGMAC_SET_REG_BITS(regval, MTL_Q_TQOMR_FTQ_POS,
+					     MTL_Q_TQOMR_FTQ_LEN, 1);
+		writel(regval, XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+	}
+
+	/* Poll Until Poll Condition */
+	for (i = 0; i < pdata->tx_q_count; i++) {
+		count = 2000;
+		regval = readl(XLGMAC_MTL_REG(pdata, i, MTL_Q_TQOMR));
+		regval = XLGMAC_GET_REG_BITS(regval, MTL_Q_TQOMR_FTQ_POS,
+					     MTL_Q_TQOMR_FTQ_LEN);
+		while (--count && regval)
+			usleep_range(500, 600);
+
+		if (!count)
+			return -EBUSY;
+	}
+
+	return 0;
+}
+
+static void xlgmac_config_dma_bus(struct xlgmac_pdata *pdata)
+{
+	u32 regval;
+
+	regval = readl(pdata->mac_regs + DMA_SBMR);
+	/* Set enhanced addressing mode */
+	regval = XLGMAC_SET_REG_BITS(regval, DMA_SBMR_EAME_POS,
+				     DMA_SBMR_EAME_LEN, 1);
+	/* Set the System Bus mode */
+	regval = XLGMAC_SET_REG_BITS(regval, DMA_SBMR_UNDEF_POS,
+				     DMA_SBMR_UNDEF_LEN, 1);
+	regval = XLGMAC_SET_REG_BITS(regval, DMA_SBMR_BLEN_256_POS,
+				     DMA_SBMR_BLEN_256_LEN, 1);
+	writel(regval, pdata->mac_regs + DMA_SBMR);
+}
+
+static int xlgmac_hw_init(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_desc_ops *desc_ops = &pdata->desc_ops;
+	int ret;
+
+	/* Flush Tx queues */
+	ret = xlgmac_flush_tx_queues(pdata);
+	if (ret)
+		return ret;
+
+	/* Initialize DMA related features */
+	xlgmac_config_dma_bus(pdata);
+	xlgmac_config_osp_mode(pdata);
+	xlgmac_config_pblx8(pdata);
+	xlgmac_config_tx_pbl_val(pdata);
+	xlgmac_config_rx_pbl_val(pdata);
+	xlgmac_config_rx_coalesce(pdata);
+	xlgmac_config_tx_coalesce(pdata);
+	xlgmac_config_rx_buffer_size(pdata);
+	xlgmac_config_tso_mode(pdata);
+	xlgmac_config_sph_mode(pdata);
+	xlgmac_config_rss(pdata);
+	desc_ops->tx_desc_init(pdata);
+	desc_ops->rx_desc_init(pdata);
+	xlgmac_enable_dma_interrupts(pdata);
+
+	/* Initialize MTL related features */
+	xlgmac_config_mtl_mode(pdata);
+	xlgmac_config_queue_mapping(pdata);
+	xlgmac_config_tsf_mode(pdata, pdata->tx_sf_mode);
+	xlgmac_config_rsf_mode(pdata, pdata->rx_sf_mode);
+	xlgmac_config_tx_threshold(pdata, pdata->tx_threshold);
+	xlgmac_config_rx_threshold(pdata, pdata->rx_threshold);
+	xlgmac_config_tx_fifo_size(pdata);
+	xlgmac_config_rx_fifo_size(pdata);
+	xlgmac_config_flow_control_threshold(pdata);
+	xlgmac_config_rx_fep_enable(pdata);
+	xlgmac_config_rx_fup_enable(pdata);
+	xlgmac_enable_mtl_interrupts(pdata);
+
+	/* Initialize MAC related features */
+	xlgmac_config_mac_address(pdata);
+	xlgmac_config_rx_mode(pdata);
+	xlgmac_config_jumbo_enable(pdata);
+	xlgmac_config_flow_control(pdata);
+	xlgmac_config_mac_speed(pdata);
+	xlgmac_config_checksum_offload(pdata);
+	xlgmac_config_vlan_support(pdata);
+	xlgmac_config_mmc(pdata);
+	xlgmac_enable_mac_interrupts(pdata);
+
+	return 0;
+}
+
+static int xlgmac_hw_exit(struct xlgmac_pdata *pdata)
+{
+	unsigned int count = 2000;
+	u32 regval;
+
+	/* Issue a software reset */
+	regval = readl(pdata->mac_regs + DMA_MR);
+	regval = XLGMAC_SET_REG_BITS(regval, DMA_MR_SWR_POS,
+				     DMA_MR_SWR_LEN, 1);
+	writel(regval, pdata->mac_regs + DMA_MR);
+	usleep_range(10, 15);
+
+	/* Poll Until Poll Condition */
+	while (--count &&
+	       XLGMAC_GET_REG_BITS(readl(pdata->mac_regs + DMA_MR),
+				   DMA_MR_SWR_POS, DMA_MR_SWR_LEN))
+		usleep_range(500, 600);
+
+	if (!count)
+		return -EBUSY;
+
+	return 0;
+}
+
+void xlgmac_init_hw_ops(struct xlgmac_hw_ops *hw_ops)
+{
+	hw_ops->init = xlgmac_hw_init;
+	hw_ops->exit = xlgmac_hw_exit;
+
+	hw_ops->tx_complete = xlgmac_tx_complete;
+
+	hw_ops->enable_tx = xlgmac_enable_tx;
+	hw_ops->disable_tx = xlgmac_disable_tx;
+	hw_ops->enable_rx = xlgmac_enable_rx;
+	hw_ops->disable_rx = xlgmac_disable_rx;
+
+	hw_ops->dev_xmit = xlgmac_dev_xmit;
+	hw_ops->dev_read = xlgmac_dev_read;
+	hw_ops->enable_int = xlgmac_enable_int;
+	hw_ops->disable_int = xlgmac_disable_int;
+
+	hw_ops->set_mac_address = xlgmac_set_mac_address;
+	hw_ops->config_rx_mode = xlgmac_config_rx_mode;
+	hw_ops->enable_rx_csum = xlgmac_enable_rx_csum;
+	hw_ops->disable_rx_csum = xlgmac_disable_rx_csum;
+
+	/* For MII speed configuration */
+	hw_ops->set_xlgmii_25000_speed = xlgmac_set_xlgmii_25000_speed;
+	hw_ops->set_xlgmii_40000_speed = xlgmac_set_xlgmii_40000_speed;
+	hw_ops->set_xlgmii_50000_speed = xlgmac_set_xlgmii_50000_speed;
+	hw_ops->set_xlgmii_100000_speed = xlgmac_set_xlgmii_100000_speed;
+
+	/* For descriptor related operation */
+	hw_ops->tx_desc_init = xlgmac_tx_desc_init;
+	hw_ops->rx_desc_init = xlgmac_rx_desc_init;
+	hw_ops->tx_desc_reset = xlgmac_tx_desc_reset;
+	hw_ops->rx_desc_reset = xlgmac_rx_desc_reset;
+	hw_ops->is_last_desc = xlgmac_is_last_desc;
+	hw_ops->is_context_desc = xlgmac_is_context_desc;
+	hw_ops->tx_start_xmit = xlgmac_tx_start_xmit;
+
+	/* For Flow Control */
+	hw_ops->config_tx_flow_control = xlgmac_config_tx_flow_control;
+	hw_ops->config_rx_flow_control = xlgmac_config_rx_flow_control;
+
+	/* For Vlan related config */
+	hw_ops->enable_rx_vlan_stripping = xlgmac_enable_rx_vlan_stripping;
+	hw_ops->disable_rx_vlan_stripping = xlgmac_disable_rx_vlan_stripping;
+	hw_ops->enable_rx_vlan_filtering = xlgmac_enable_rx_vlan_filtering;
+	hw_ops->disable_rx_vlan_filtering = xlgmac_disable_rx_vlan_filtering;
+	hw_ops->update_vlan_hash_table = xlgmac_update_vlan_hash_table;
+
+	/* For RX coalescing */
+	hw_ops->config_rx_coalesce = xlgmac_config_rx_coalesce;
+	hw_ops->config_tx_coalesce = xlgmac_config_tx_coalesce;
+	hw_ops->usec_to_riwt = xlgmac_usec_to_riwt;
+	hw_ops->riwt_to_usec = xlgmac_riwt_to_usec;
+
+	/* For RX and TX threshold config */
+	hw_ops->config_rx_threshold = xlgmac_config_rx_threshold;
+	hw_ops->config_tx_threshold = xlgmac_config_tx_threshold;
+
+	/* For RX and TX Store and Forward Mode config */
+	hw_ops->config_rsf_mode = xlgmac_config_rsf_mode;
+	hw_ops->config_tsf_mode = xlgmac_config_tsf_mode;
+
+	/* For TX DMA Operating on Second Frame config */
+	hw_ops->config_osp_mode = xlgmac_config_osp_mode;
+
+	/* For RX and TX PBL config */
+	hw_ops->config_rx_pbl_val = xlgmac_config_rx_pbl_val;
+	hw_ops->get_rx_pbl_val = xlgmac_get_rx_pbl_val;
+	hw_ops->config_tx_pbl_val = xlgmac_config_tx_pbl_val;
+	hw_ops->get_tx_pbl_val = xlgmac_get_tx_pbl_val;
+	hw_ops->config_pblx8 = xlgmac_config_pblx8;
+
+	/* For MMC statistics support */
+	hw_ops->tx_mmc_int = xlgmac_tx_mmc_int;
+	hw_ops->rx_mmc_int = xlgmac_rx_mmc_int;
+	hw_ops->read_mmc_stats = xlgmac_read_mmc_stats;
+
+	/* For Receive Side Scaling */
+	hw_ops->enable_rss = xlgmac_enable_rss;
+	hw_ops->disable_rss = xlgmac_disable_rss;
+	hw_ops->set_rss_hash_key = xlgmac_set_rss_hash_key;
+	hw_ops->set_rss_lookup_table = xlgmac_set_rss_lookup_table;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
new file mode 100644
index 0000000..7f13eb0
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
@@ -0,0 +1,1325 @@
+/* Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This Synopsys DWC XLGMAC software driver and associated documentation
+ * (hereinafter the "Software") is an unsupported proprietary work of
+ * Synopsys, Inc. unless otherwise expressly agreed to in writing between
+ * Synopsys and you. The Software IS NOT an item of Licensed Software or a
+ * Licensed Product under any End User Software License Agreement or
+ * Agreement for Licensed Products with Synopsys or any supplement thereto.
+ * Synopsys is a registered trademark of Synopsys, Inc. Other names included
+ * in the SOFTWARE may be the trademarks of their respective owners.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/tcp.h>
+
+#include "dwc-xlgmac.h"
+#include "dwc-xlgmac-reg.h"
+
+static int xlgmac_one_poll(struct napi_struct *, int);
+static int xlgmac_all_poll(struct napi_struct *, int);
+
+static inline unsigned int xlgmac_tx_avail_desc(struct xlgmac_ring *ring)
+{
+	return (ring->dma_desc_count - (ring->cur - ring->dirty));
+}
+
+static inline unsigned int xlgmac_rx_dirty_desc(struct xlgmac_ring *ring)
+{
+	return (ring->cur - ring->dirty);
+}
+
+static int xlgmac_maybe_stop_tx_queue(
+			struct xlgmac_channel *channel,
+			struct xlgmac_ring *ring,
+			unsigned int count)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+
+	if (count > xlgmac_tx_avail_desc(ring)) {
+		netif_info(pdata, drv, pdata->netdev,
+			   "Tx queue stopped, not enough descriptors available\n");
+		netif_stop_subqueue(pdata->netdev, channel->queue_index);
+		ring->tx.queue_stopped = 1;
+
+		/* If we haven't notified the hardware because of xmit_more
+		 * support, tell it now
+		 */
+		if (ring->tx.xmit_more)
+			pdata->hw_ops.tx_start_xmit(channel, ring);
+
+		return NETDEV_TX_BUSY;
+	}
+
+	return 0;
+}
+
+static void xlgmac_prep_vlan(struct sk_buff *skb,
+			     struct xlgmac_pkt_info *pkt_info)
+{
+	if (skb_vlan_tag_present(skb))
+		pkt_info->vlan_ctag = skb_vlan_tag_get(skb);
+}
+
+static int xlgmac_prep_tso(struct sk_buff *skb,
+			   struct xlgmac_pkt_info *pkt_info)
+{
+	int ret;
+
+	if (!XLGMAC_GET_REG_BITS(pkt_info->attributes,
+				 TX_PACKET_ATTRIBUTES_TSO_ENABLE_POS,
+				 TX_PACKET_ATTRIBUTES_TSO_ENABLE_LEN))
+		return 0;
+
+	ret = skb_cow_head(skb, 0);
+	if (ret)
+		return ret;
+
+	pkt_info->header_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	pkt_info->tcp_header_len = tcp_hdrlen(skb);
+	pkt_info->tcp_payload_len = skb->len - pkt_info->header_len;
+	pkt_info->mss = skb_shinfo(skb)->gso_size;
+
+	XLGMAC_PR("header_len=%u\n", pkt_info->header_len);
+	XLGMAC_PR("tcp_header_len=%u, tcp_payload_len=%u\n",
+		  pkt_info->tcp_header_len, pkt_info->tcp_payload_len);
+	XLGMAC_PR("mss=%u\n", pkt_info->mss);
+
+	/* Update the number of packets that will ultimately be transmitted
+	 * along with the extra bytes for each extra packet
+	 */
+	pkt_info->tx_packets = skb_shinfo(skb)->gso_segs;
+	pkt_info->tx_bytes += (pkt_info->tx_packets - 1) * pkt_info->header_len;
+
+	return 0;
+}
+
+static int xlgmac_is_tso(struct sk_buff *skb)
+{
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
+	if (!skb_is_gso(skb))
+		return 0;
+
+	return 1;
+}
+
+static void xlgmac_prep_tx_pkt(struct xlgmac_pdata *pdata,
+			       struct xlgmac_ring *ring,
+			       struct sk_buff *skb,
+			       struct xlgmac_pkt_info *pkt_info)
+{
+	struct skb_frag_struct *frag;
+	unsigned int context_desc;
+	unsigned int len;
+	unsigned int i;
+
+	pkt_info->skb = skb;
+
+	context_desc = 0;
+	pkt_info->desc_count = 0;
+
+	pkt_info->tx_packets = 1;
+	pkt_info->tx_bytes = skb->len;
+
+	if (xlgmac_is_tso(skb)) {
+		/* TSO requires an extra descriptor if mss is different */
+		if (skb_shinfo(skb)->gso_size != ring->tx.cur_mss) {
+			context_desc = 1;
+			pkt_info->desc_count++;
+		}
+
+		/* TSO requires an extra descriptor for TSO header */
+		pkt_info->desc_count++;
+
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+					pkt_info->attributes,
+					TX_PACKET_ATTRIBUTES_TSO_ENABLE_POS,
+					TX_PACKET_ATTRIBUTES_TSO_ENABLE_LEN,
+					1);
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+					pkt_info->attributes,
+					TX_PACKET_ATTRIBUTES_CSUM_ENABLE_POS,
+					TX_PACKET_ATTRIBUTES_CSUM_ENABLE_LEN,
+					1);
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL)
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+					pkt_info->attributes,
+					TX_PACKET_ATTRIBUTES_CSUM_ENABLE_POS,
+					TX_PACKET_ATTRIBUTES_CSUM_ENABLE_LEN,
+					1);
+
+	if (skb_vlan_tag_present(skb)) {
+		/* VLAN requires an extra descriptor if tag is different */
+		if (skb_vlan_tag_get(skb) != ring->tx.cur_vlan_ctag)
+			/* We can share with the TSO context descriptor */
+			if (!context_desc) {
+				context_desc = 1;
+				pkt_info->desc_count++;
+			}
+
+		pkt_info->attributes = XLGMAC_SET_REG_BITS(
+					pkt_info->attributes,
+					TX_PACKET_ATTRIBUTES_VLAN_CTAG_POS,
+					TX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN,
+					1);
+	}
+
+	for (len = skb_headlen(skb); len;) {
+		pkt_info->desc_count++;
+		len -= min_t(unsigned int, len, XLGMAC_TX_MAX_BUF_SIZE);
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		for (len = skb_frag_size(frag); len; ) {
+			pkt_info->desc_count++;
+			len -= min_t(unsigned int, len, XLGMAC_TX_MAX_BUF_SIZE);
+		}
+	}
+}
+
+static int xlgmac_calc_rx_buf_size(struct net_device *netdev, unsigned int mtu)
+{
+	unsigned int rx_buf_size;
+
+	if (mtu > XLGMAC_JUMBO_PACKET_MTU) {
+		netdev_alert(netdev, "MTU exceeds maximum supported value\n");
+		return -EINVAL;
+	}
+
+	rx_buf_size = mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	rx_buf_size = clamp_val(rx_buf_size, XLGMAC_RX_MIN_BUF_SIZE, PAGE_SIZE);
+
+	rx_buf_size = (rx_buf_size + XLGMAC_RX_BUF_ALIGN - 1) &
+		      ~(XLGMAC_RX_BUF_ALIGN - 1);
+
+	return rx_buf_size;
+}
+
+static void xlgmac_enable_rx_tx_ints(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_channel *channel;
+	enum xlgmac_int int_id;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (channel->tx_ring && channel->rx_ring)
+			int_id = XLGMAC_INT_DMA_CH_SR_TI_RI;
+		else if (channel->tx_ring)
+			int_id = XLGMAC_INT_DMA_CH_SR_TI;
+		else if (channel->rx_ring)
+			int_id = XLGMAC_INT_DMA_CH_SR_RI;
+		else
+			continue;
+
+		hw_ops->enable_int(channel, int_id);
+	}
+}
+
+static void xlgmac_disable_rx_tx_ints(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_channel *channel;
+	enum xlgmac_int int_id;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (channel->tx_ring && channel->rx_ring)
+			int_id = XLGMAC_INT_DMA_CH_SR_TI_RI;
+		else if (channel->tx_ring)
+			int_id = XLGMAC_INT_DMA_CH_SR_TI;
+		else if (channel->rx_ring)
+			int_id = XLGMAC_INT_DMA_CH_SR_RI;
+		else
+			continue;
+
+		hw_ops->disable_int(channel, int_id);
+	}
+}
+
+static irqreturn_t xlgmac_isr(int irq, void *data)
+{
+	struct xlgmac_pdata *pdata = data;
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_channel *channel;
+	unsigned int dma_isr, dma_ch_isr, mac_isr;
+	unsigned int i, ti, ri;
+
+	/* The DMA interrupt status register also reports MAC and MTL
+	 * interrupts. So for polling mode, we just need to check for
+	 * this register to be non-zero
+	 */
+	dma_isr = readl(pdata->mac_regs + DMA_ISR);
+	if (!dma_isr)
+		goto isr_done;
+
+	netif_dbg(pdata, intr, pdata->netdev, "DMA_ISR=%#010x\n", dma_isr);
+
+	for (i = 0; i < pdata->channel_count; i++) {
+		if (!(dma_isr & (1 << i)))
+			continue;
+
+		channel = pdata->channel_head + i;
+
+		dma_ch_isr = readl(XLGMAC_DMA_REG(channel, DMA_CH_SR));
+		netif_dbg(pdata, intr, pdata->netdev, "DMA_CH%u_ISR=%#010x\n",
+			  i, dma_ch_isr);
+
+		/* The TI or RI interrupt bits may still be set even if using
+		 * per channel DMA interrupts. Check to be sure those are not
+		 * enabled before using the private data napi structure.
+		 */
+		ti = XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_TI_POS,
+					 DMA_CH_SR_TI_LEN);
+		ri = XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_RI_POS,
+					 DMA_CH_SR_RI_LEN);
+		if (!pdata->per_channel_irq && (ti || ri)) {
+			if (napi_schedule_prep(&pdata->napi)) {
+				/* Disable Tx and Rx interrupts */
+				xlgmac_disable_rx_tx_ints(pdata);
+
+				/* Turn on polling */
+				__napi_schedule_irqoff(&pdata->napi);
+			}
+		}
+
+		if (XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_RBU_POS,
+					DMA_CH_SR_RBU_LEN))
+			pdata->stats.rx_buffer_unavailable++;
+
+		/* Restart the device on a Fatal Bus Error */
+		if (XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_FBE_POS,
+					DMA_CH_SR_FBE_LEN))
+			schedule_work(&pdata->restart_work);
+
+		/* Clear all interrupt signals */
+		writel(dma_ch_isr, XLGMAC_DMA_REG(channel, DMA_CH_SR));
+	}
+
+	if (XLGMAC_GET_REG_BITS(dma_isr, DMA_ISR_MACIS_POS,
+				DMA_ISR_MACIS_LEN)) {
+		mac_isr = readl(pdata->mac_regs + MAC_ISR);
+
+		if (XLGMAC_GET_REG_BITS(mac_isr, MAC_ISR_MMCTXIS_POS,
+					MAC_ISR_MMCTXIS_LEN))
+			hw_ops->tx_mmc_int(pdata);
+
+		if (XLGMAC_GET_REG_BITS(mac_isr, MAC_ISR_MMCRXIS_POS,
+					MAC_ISR_MMCRXIS_LEN))
+			hw_ops->rx_mmc_int(pdata);
+	}
+
+isr_done:
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xlgmac_dma_isr(int irq, void *data)
+{
+	struct xlgmac_channel *channel = data;
+
+	/* Per channel DMA interrupts are enabled, so we use the per
+	 * channel napi structure and not the private data napi structure
+	 */
+	if (napi_schedule_prep(&channel->napi)) {
+		/* Disable Tx and Rx interrupts */
+		disable_irq_nosync(channel->dma_irq);
+
+		/* Turn on polling */
+		__napi_schedule_irqoff(&channel->napi);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static void xlgmac_tx_timer(unsigned long data)
+{
+	struct xlgmac_channel *channel = (struct xlgmac_channel *)data;
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct napi_struct *napi;
+
+	napi = (pdata->per_channel_irq) ? &channel->napi : &pdata->napi;
+
+	if (napi_schedule_prep(napi)) {
+		/* Disable Tx and Rx interrupts */
+		if (pdata->per_channel_irq)
+			disable_irq_nosync(channel->dma_irq);
+		else
+			xlgmac_disable_rx_tx_ints(pdata);
+
+		/* Turn on polling */
+		__napi_schedule(napi);
+	}
+
+	channel->tx_timer_active = 0;
+}
+
+static void xlgmac_init_timers(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		setup_timer(&channel->tx_timer, xlgmac_tx_timer,
+			    (unsigned long)channel);
+	}
+}
+
+static void xlgmac_stop_timers(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		del_timer_sync(&channel->tx_timer);
+	}
+}
+
+static void xlgmac_napi_enable(struct xlgmac_pdata *pdata, unsigned int add)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+
+	if (pdata->per_channel_irq) {
+		channel = pdata->channel_head;
+		for (i = 0; i < pdata->channel_count; i++, channel++) {
+			if (add)
+				netif_napi_add(pdata->netdev, &channel->napi,
+					       xlgmac_one_poll,
+					       NAPI_POLL_WEIGHT);
+
+			napi_enable(&channel->napi);
+		}
+	} else {
+		if (add)
+			netif_napi_add(pdata->netdev, &pdata->napi,
+				       xlgmac_all_poll, NAPI_POLL_WEIGHT);
+
+		napi_enable(&pdata->napi);
+	}
+}
+
+static void xlgmac_napi_disable(struct xlgmac_pdata *pdata, unsigned int del)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+
+	if (pdata->per_channel_irq) {
+		channel = pdata->channel_head;
+		for (i = 0; i < pdata->channel_count; i++, channel++) {
+			napi_disable(&channel->napi);
+
+			if (del)
+				netif_napi_del(&channel->napi);
+		}
+	} else {
+		napi_disable(&pdata->napi);
+
+		if (del)
+			netif_napi_del(&pdata->napi);
+	}
+}
+
+static int xlgmac_request_irqs(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	struct net_device *netdev = pdata->netdev;
+	unsigned int i;
+	int ret;
+
+	ret = devm_request_irq(pdata->dev, pdata->dev_irq, xlgmac_isr,
+			       IRQF_SHARED, netdev->name, pdata);
+	if (ret) {
+		netdev_alert(netdev, "error requesting irq %d\n",
+			     pdata->dev_irq);
+		return ret;
+	}
+
+	if (!pdata->per_channel_irq)
+		return 0;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		snprintf(channel->dma_irq_name,
+			 sizeof(channel->dma_irq_name) - 1,
+			 "%s-TxRx-%u", netdev_name(netdev),
+			 channel->queue_index);
+
+		ret = devm_request_irq(pdata->dev, channel->dma_irq,
+				       xlgmac_dma_isr, 0,
+				       channel->dma_irq_name, channel);
+		if (ret) {
+			netdev_alert(netdev, "error requesting irq %d\n",
+				     channel->dma_irq);
+			goto err_irq;
+		}
+	}
+
+	return 0;
+
+err_irq:
+	/* Using an unsigned int, 'i' will go to UINT_MAX and exit */
+	for (i--, channel--; i < pdata->channel_count; i--, channel--)
+		devm_free_irq(pdata->dev, channel->dma_irq, channel);
+
+	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
+
+	return ret;
+}
+
+static void xlgmac_free_irqs(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_channel *channel;
+	unsigned int i;
+
+	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
+
+	if (!pdata->per_channel_irq)
+		return;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		devm_free_irq(pdata->dev, channel->dma_irq, channel);
+}
+
+static void xlgmac_free_tx_data(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_desc_ops *desc_ops = &pdata->desc_ops;
+	struct xlgmac_channel *channel;
+	struct xlgmac_ring *ring;
+	struct xlgmac_desc_data *desc_data;
+	unsigned int i, j;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->tx_ring;
+		if (!ring)
+			break;
+
+		for (j = 0; j < ring->dma_desc_count; j++) {
+			desc_data = XLGMAC_GET_DESC_DATA(ring, j);
+			desc_ops->unmap_desc_data(pdata, desc_data);
+		}
+	}
+}
+
+static void xlgmac_free_rx_data(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_desc_ops *desc_ops = &pdata->desc_ops;
+	struct xlgmac_channel *channel;
+	struct xlgmac_ring *ring;
+	struct xlgmac_desc_data *desc_data;
+	unsigned int i, j;
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->rx_ring;
+		if (!ring)
+			break;
+
+		for (j = 0; j < ring->dma_desc_count; j++) {
+			desc_data = XLGMAC_GET_DESC_DATA(ring, j);
+			desc_ops->unmap_desc_data(pdata, desc_data);
+		}
+	}
+}
+
+static int xlgmac_start(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct net_device *netdev = pdata->netdev;
+	int ret;
+
+	hw_ops->init(pdata);
+	xlgmac_napi_enable(pdata, 1);
+
+	ret = xlgmac_request_irqs(pdata);
+	if (ret)
+		goto err_napi;
+
+	hw_ops->enable_tx(pdata);
+	hw_ops->enable_rx(pdata);
+	netif_tx_start_all_queues(netdev);
+
+	return 0;
+
+err_napi:
+	xlgmac_napi_disable(pdata, 1);
+	hw_ops->exit(pdata);
+
+	return ret;
+}
+
+static void xlgmac_stop(struct xlgmac_pdata *pdata)
+{
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_channel *channel;
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_queue *txq;
+	unsigned int i;
+
+	netif_tx_stop_all_queues(netdev);
+	xlgmac_stop_timers(pdata);
+	hw_ops->disable_tx(pdata);
+	hw_ops->disable_rx(pdata);
+	xlgmac_free_irqs(pdata);
+	xlgmac_napi_disable(pdata, 1);
+	hw_ops->exit(pdata);
+
+	channel = pdata->channel_head;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			continue;
+
+		txq = netdev_get_tx_queue(netdev, channel->queue_index);
+		netdev_tx_reset_queue(txq);
+	}
+}
+
+static void xlgmac_restart_dev(struct xlgmac_pdata *pdata)
+{
+	/* If not running, "restart" will happen on open */
+	if (!netif_running(pdata->netdev))
+		return;
+
+	xlgmac_stop(pdata);
+
+	xlgmac_free_tx_data(pdata);
+	xlgmac_free_rx_data(pdata);
+
+	xlgmac_start(pdata);
+}
+
+static void xlgmac_restart(struct work_struct *work)
+{
+	struct xlgmac_pdata *pdata = container_of(work,
+						   struct xlgmac_pdata,
+						   restart_work);
+
+	rtnl_lock();
+
+	xlgmac_restart_dev(pdata);
+
+	rtnl_unlock();
+}
+
+static int xlgmac_open(struct net_device *netdev)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_desc_ops *desc_ops = &pdata->desc_ops;
+	int ret;
+
+	/* TODO: Initialize the phy */
+
+	/* Calculate the Rx buffer size before allocating rings */
+	ret = xlgmac_calc_rx_buf_size(netdev, netdev->mtu);
+	if (ret < 0)
+		goto err_phy_init;
+	pdata->rx_buf_size = ret;
+
+	/* Allocate the channels and rings */
+	ret = desc_ops->alloc_channles_and_rings(pdata);
+	if (ret)
+		goto err_phy_init;
+
+	INIT_WORK(&pdata->restart_work, xlgmac_restart);
+	xlgmac_init_timers(pdata);
+
+	ret = xlgmac_start(pdata);
+	if (ret)
+		goto err_channels_and_rings;
+
+	return 0;
+
+err_channels_and_rings:
+	desc_ops->free_channels_and_rings(pdata);
+
+err_phy_init:
+	return ret;
+}
+
+static int xlgmac_close(struct net_device *netdev)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_desc_ops *desc_ops = &pdata->desc_ops;
+
+	/* Stop the device */
+	xlgmac_stop(pdata);
+
+	/* Free the channels and rings */
+	desc_ops->free_channels_and_rings(pdata);
+
+	return 0;
+}
+
+static void xlgmac_tx_timeout(struct net_device *netdev)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+
+	netdev_warn(netdev, "tx timeout, device restarting\n");
+	schedule_work(&pdata->restart_work);
+}
+
+static int xlgmac_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_desc_ops *desc_ops = &pdata->desc_ops;
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_channel *channel;
+	struct xlgmac_ring *ring;
+	struct xlgmac_pkt_info *tx_pkt_info;
+	struct netdev_queue *txq;
+	int ret;
+
+	XLGMAC_PR("skb->len = %d\n", skb->len);
+
+	channel = pdata->channel_head + skb->queue_mapping;
+	txq = netdev_get_tx_queue(netdev, channel->queue_index);
+	ring = channel->tx_ring;
+	tx_pkt_info = &ring->pkt_info;
+
+	ret = NETDEV_TX_OK;
+
+	if (skb->len == 0) {
+		netif_err(pdata, tx_err, netdev,
+			  "empty skb received from stack\n");
+		dev_kfree_skb_any(skb);
+		goto tx_return;
+	}
+
+	/* Prepare preliminary packet info for TX */
+	memset(tx_pkt_info, 0, sizeof(*tx_pkt_info));
+	xlgmac_prep_tx_pkt(pdata, ring, skb, tx_pkt_info);
+
+	/* Check that there are enough descriptors available */
+	ret = xlgmac_maybe_stop_tx_queue(channel, ring,
+					 tx_pkt_info->desc_count);
+	if (ret)
+		goto tx_return;
+
+	ret = xlgmac_prep_tso(skb, tx_pkt_info);
+	if (ret) {
+		netif_err(pdata, tx_err, netdev,
+			  "error processing TSO packet\n");
+		dev_kfree_skb_any(skb);
+		goto tx_return;
+	}
+	xlgmac_prep_vlan(skb, tx_pkt_info);
+
+	if (!desc_ops->map_tx_skb(channel, skb)) {
+		dev_kfree_skb_any(skb);
+		goto tx_return;
+	}
+
+	/* Report on the actual number of bytes (to be) sent */
+	netdev_tx_sent_queue(txq, tx_pkt_info->tx_bytes);
+
+	/* Configure required descriptor fields for transmission */
+	hw_ops->dev_xmit(channel);
+
+	if (netif_msg_pktdata(pdata))
+		xlgmac_print_pkt(netdev, skb, true);
+
+	/* Stop the queue in advance if there may not be enough descriptors */
+	xlgmac_maybe_stop_tx_queue(channel, ring, XLGMAC_TX_MAX_DESC_NR);
+
+	ret = NETDEV_TX_OK;
+
+tx_return:
+	return ret;
+}
+
+static void xlgmac_get_stats64(struct net_device *netdev,
+			       struct rtnl_link_stats64 *s)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_stats *pstats = &pdata->stats;
+
+	pdata->hw_ops.read_mmc_stats(pdata);
+
+	s->rx_packets = pstats->rxframecount_gb;
+	s->rx_bytes = pstats->rxoctetcount_gb;
+	s->rx_errors = pstats->rxframecount_gb -
+		       pstats->rxbroadcastframes_g -
+		       pstats->rxmulticastframes_g -
+		       pstats->rxunicastframes_g;
+	s->multicast = pstats->rxmulticastframes_g;
+	s->rx_length_errors = pstats->rxlengtherror;
+	s->rx_crc_errors = pstats->rxcrcerror;
+	s->rx_fifo_errors = pstats->rxfifooverflow;
+
+	s->tx_packets = pstats->txframecount_gb;
+	s->tx_bytes = pstats->txoctetcount_gb;
+	s->tx_errors = pstats->txframecount_gb - pstats->txframecount_g;
+	s->tx_dropped = netdev->stats.tx_dropped;
+}
+
+static int xlgmac_set_mac_address(struct net_device *netdev, void *addr)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct sockaddr *saddr = addr;
+
+	if (!is_valid_ether_addr(saddr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, saddr->sa_data, netdev->addr_len);
+
+	hw_ops->set_mac_address(pdata, netdev->dev_addr);
+
+	return 0;
+}
+
+static int xlgmac_ioctl(struct net_device *netdev,
+			struct ifreq *ifreq, int cmd)
+{
+	if (!netif_running(netdev))
+		return -ENODEV;
+
+	return 0;
+}
+
+static int xlgmac_change_mtu(struct net_device *netdev, int mtu)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	int ret;
+
+	ret = xlgmac_calc_rx_buf_size(netdev, mtu);
+	if (ret < 0)
+		return ret;
+
+	pdata->rx_buf_size = ret;
+	netdev->mtu = mtu;
+
+	xlgmac_restart_dev(pdata);
+
+	return 0;
+}
+
+static int xlgmac_vlan_rx_add_vid(struct net_device *netdev,
+				  __be16 proto,
+				  u16 vid)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+
+	set_bit(vid, pdata->active_vlans);
+	hw_ops->update_vlan_hash_table(pdata);
+
+	return 0;
+}
+
+static int xlgmac_vlan_rx_kill_vid(struct net_device *netdev,
+				   __be16 proto,
+				   u16 vid)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+
+	clear_bit(vid, pdata->active_vlans);
+	hw_ops->update_vlan_hash_table(pdata);
+
+	return 0;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void xlgmac_poll_controller(struct net_device *netdev)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_channel *channel;
+	unsigned int i;
+
+	if (pdata->per_channel_irq) {
+		channel = pdata->channel_head;
+		for (i = 0; i < pdata->channel_count; i++, channel++)
+			xlgmac_dma_isr(channel->dma_irq, channel);
+	} else {
+		disable_irq(pdata->dev_irq);
+		xlgmac_isr(pdata->dev_irq, pdata);
+		enable_irq(pdata->dev_irq);
+	}
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
+static int xlgmac_set_features(struct net_device *netdev,
+			       netdev_features_t features)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	netdev_features_t rxhash, rxcsum, rxvlan, rxvlan_filter;
+	int ret = 0;
+
+	rxhash = pdata->netdev_features & NETIF_F_RXHASH;
+	rxcsum = pdata->netdev_features & NETIF_F_RXCSUM;
+	rxvlan = pdata->netdev_features & NETIF_F_HW_VLAN_CTAG_RX;
+	rxvlan_filter = pdata->netdev_features & NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	if ((features & NETIF_F_RXHASH) && !rxhash)
+		ret = hw_ops->enable_rss(pdata);
+	else if (!(features & NETIF_F_RXHASH) && rxhash)
+		ret = hw_ops->disable_rss(pdata);
+	if (ret)
+		return ret;
+
+	if ((features & NETIF_F_RXCSUM) && !rxcsum)
+		hw_ops->enable_rx_csum(pdata);
+	else if (!(features & NETIF_F_RXCSUM) && rxcsum)
+		hw_ops->disable_rx_csum(pdata);
+
+	if ((features & NETIF_F_HW_VLAN_CTAG_RX) && !rxvlan)
+		hw_ops->enable_rx_vlan_stripping(pdata);
+	else if (!(features & NETIF_F_HW_VLAN_CTAG_RX) && rxvlan)
+		hw_ops->disable_rx_vlan_stripping(pdata);
+
+	if ((features & NETIF_F_HW_VLAN_CTAG_FILTER) && !rxvlan_filter)
+		hw_ops->enable_rx_vlan_filtering(pdata);
+	else if (!(features & NETIF_F_HW_VLAN_CTAG_FILTER) && rxvlan_filter)
+		hw_ops->disable_rx_vlan_filtering(pdata);
+
+	pdata->netdev_features = features;
+
+	return 0;
+}
+
+static void xlgmac_set_rx_mode(struct net_device *netdev)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+
+	hw_ops->config_rx_mode(pdata);
+}
+
+static const struct net_device_ops xlgmac_netdev_ops = {
+	.ndo_open		= xlgmac_open,
+	.ndo_stop		= xlgmac_close,
+	.ndo_start_xmit		= xlgmac_xmit,
+	.ndo_tx_timeout		= xlgmac_tx_timeout,
+	.ndo_get_stats64	= xlgmac_get_stats64,
+	.ndo_change_mtu		= xlgmac_change_mtu,
+	.ndo_set_mac_address	= xlgmac_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= xlgmac_ioctl,
+	.ndo_vlan_rx_add_vid	= xlgmac_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= xlgmac_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= xlgmac_poll_controller,
+#endif
+	.ndo_set_features	= xlgmac_set_features,
+	.ndo_set_rx_mode	= xlgmac_set_rx_mode,
+};
+
+const struct net_device_ops *xlgmac_get_netdev_ops(void)
+{
+	return &xlgmac_netdev_ops;
+}
+
+static void xlgmac_rx_refresh(struct xlgmac_channel *channel)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_desc_ops *desc_ops = &pdata->desc_ops;
+	struct xlgmac_ring *ring = channel->rx_ring;
+	struct xlgmac_desc_data *desc_data;
+
+	while (ring->dirty != ring->cur) {
+		desc_data = XLGMAC_GET_DESC_DATA(ring, ring->dirty);
+
+		/* Reset desc_data values */
+		desc_ops->unmap_desc_data(pdata, desc_data);
+
+		if (desc_ops->map_rx_buffer(pdata, ring, desc_data))
+			break;
+
+		hw_ops->rx_desc_reset(pdata, desc_data, ring->dirty);
+
+		ring->dirty++;
+	}
+
+	/* Make sure everything is written before the register write */
+	wmb();
+
+	/* Update the Rx Tail Pointer Register with address of
+	 * the last cleaned entry
+	 */
+	desc_data = XLGMAC_GET_DESC_DATA(ring, ring->dirty - 1);
+	writel(lower_32_bits(desc_data->dma_desc_addr),
+	       XLGMAC_DMA_REG(channel, DMA_CH_RDTR_LO));
+}
+
+static struct sk_buff *xlgmac_create_skb(struct xlgmac_pdata *pdata,
+					 struct napi_struct *napi,
+					 struct xlgmac_desc_data *desc_data,
+					 unsigned int len)
+{
+	struct sk_buff *skb;
+	u8 *packet;
+	unsigned int copy_len;
+
+	skb = napi_alloc_skb(napi, desc_data->rx.hdr.dma_len);
+	if (!skb)
+		return NULL;
+
+	/* Start with the header buffer which may contain just the header
+	 * or the header plus data
+	 */
+	dma_sync_single_range_for_cpu(pdata->dev, desc_data->rx.hdr.dma_base,
+				      desc_data->rx.hdr.dma_off,
+				      desc_data->rx.hdr.dma_len,
+				      DMA_FROM_DEVICE);
+
+	packet = page_address(desc_data->rx.hdr.pa.pages) +
+		 desc_data->rx.hdr.pa.pages_offset;
+	copy_len = (desc_data->rx.hdr_len) ? desc_data->rx.hdr_len : len;
+	copy_len = min(desc_data->rx.hdr.dma_len, copy_len);
+	skb_copy_to_linear_data(skb, packet, copy_len);
+	skb_put(skb, copy_len);
+
+	len -= copy_len;
+	if (len) {
+		/* Add the remaining data as a frag */
+		dma_sync_single_range_for_cpu(pdata->dev,
+					      desc_data->rx.buf.dma_base,
+					      desc_data->rx.buf.dma_off,
+					      desc_data->rx.buf.dma_len,
+					      DMA_FROM_DEVICE);
+
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+				desc_data->rx.buf.pa.pages,
+				desc_data->rx.buf.pa.pages_offset,
+				len, desc_data->rx.buf.dma_len);
+		desc_data->rx.buf.pa.pages = NULL;
+	}
+
+	return skb;
+}
+
+static int xlgmac_tx_poll(struct xlgmac_channel *channel)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_desc_ops *desc_ops = &pdata->desc_ops;
+	struct xlgmac_ring *ring = channel->tx_ring;
+	struct xlgmac_desc_data *desc_data;
+	struct xlgmac_dma_desc *dma_desc;
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_queue *txq;
+	int processed = 0;
+	unsigned int tx_packets = 0, tx_bytes = 0;
+	unsigned int cur;
+
+	/* Nothing to do if there isn't a Tx ring for this channel */
+	if (!ring)
+		return 0;
+
+	cur = ring->cur;
+
+	/* Be sure we get ring->cur before accessing descriptor data */
+	smp_rmb();
+
+	txq = netdev_get_tx_queue(netdev, channel->queue_index);
+
+	while ((processed < XLGMAC_TX_DESC_MAX_PROC) &&
+	       (ring->dirty != cur)) {
+		desc_data = XLGMAC_GET_DESC_DATA(ring, ring->dirty);
+		dma_desc = desc_data->dma_desc;
+
+		if (!hw_ops->tx_complete(dma_desc))
+			break;
+
+		/* Make sure descriptor fields are read after reading
+		 * the OWN bit
+		 */
+		dma_rmb();
+
+		if (netif_msg_tx_done(pdata))
+			xlgmac_dump_tx_desc(pdata, ring, ring->dirty, 1, 0);
+
+		if (hw_ops->is_last_desc(dma_desc)) {
+			tx_packets += desc_data->tx.packets;
+			tx_bytes += desc_data->tx.bytes;
+		}
+
+		/* Free the SKB and reset the descriptor for re-use */
+		desc_ops->unmap_desc_data(pdata, desc_data);
+		hw_ops->tx_desc_reset(desc_data);
+
+		processed++;
+		ring->dirty++;
+	}
+
+	if (!processed)
+		return 0;
+
+	netdev_tx_completed_queue(txq, tx_packets, tx_bytes);
+
+	if ((ring->tx.queue_stopped == 1) &&
+	    (xlgmac_tx_avail_desc(ring) > XLGMAC_TX_DESC_MIN_FREE)) {
+		ring->tx.queue_stopped = 0;
+		netif_tx_wake_queue(txq);
+	}
+
+	XLGMAC_PR("processed=%d\n", processed);
+
+	return processed;
+}
+
+static int xlgmac_rx_poll(struct xlgmac_channel *channel, int budget)
+{
+	struct xlgmac_pdata *pdata = channel->pdata;
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	struct xlgmac_ring *ring = channel->rx_ring;
+	struct xlgmac_desc_data *desc_data;
+	struct xlgmac_pkt_info *pkt_info;
+	struct net_device *netdev = pdata->netdev;
+	struct napi_struct *napi;
+	struct sk_buff *skb;
+	unsigned int incomplete, error, context_next, context;
+	unsigned int len, dma_desc_len, max_len;
+	unsigned int received = 0;
+	int packet_count = 0;
+
+	XLGMAC_PR("budget=%d\n", budget);
+
+	/* Nothing to do if there isn't a Rx ring for this channel */
+	if (!ring)
+		return 0;
+
+	incomplete = 0;
+	context_next = 0;
+
+	napi = (pdata->per_channel_irq) ? &channel->napi : &pdata->napi;
+
+	desc_data = XLGMAC_GET_DESC_DATA(ring, ring->cur);
+	pkt_info = &ring->pkt_info;
+	while (packet_count < budget) {
+		/* First time in loop see if we need to restore state */
+		if (!received && desc_data->state_saved) {
+			skb = desc_data->state.skb;
+			error = desc_data->state.error;
+			len = desc_data->state.len;
+		} else {
+			memset(pkt_info, 0, sizeof(*pkt_info));
+			skb = NULL;
+			error = 0;
+			len = 0;
+		}
+
+read_again:
+		desc_data = XLGMAC_GET_DESC_DATA(ring, ring->cur);
+
+		if (xlgmac_rx_dirty_desc(ring) > XLGMAC_RX_DESC_MAX_DIRTY)
+			xlgmac_rx_refresh(channel);
+
+		if (hw_ops->dev_read(channel))
+			break;
+
+		received++;
+		ring->cur++;
+
+		incomplete = XLGMAC_GET_REG_BITS(
+					pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_INCOMPLETE_POS,
+					RX_PACKET_ATTRIBUTES_INCOMPLETE_LEN);
+		context_next = XLGMAC_GET_REG_BITS(
+					pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_POS,
+					RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_LEN);
+		context = XLGMAC_GET_REG_BITS(
+					pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_CONTEXT_POS,
+					RX_PACKET_ATTRIBUTES_CONTEXT_LEN);
+
+		/* Earlier error, just drain the remaining data */
+		if ((incomplete || context_next) && error)
+			goto read_again;
+
+		if (error || pkt_info->errors) {
+			if (pkt_info->errors)
+				netif_err(pdata, rx_err, netdev,
+					  "error in received packet\n");
+			dev_kfree_skb(skb);
+			goto next_packet;
+		}
+
+		if (!context) {
+			/* Length is cumulative, get this descriptor's length */
+			dma_desc_len = desc_data->rx.len - len;
+			len += dma_desc_len;
+
+			if (dma_desc_len && !skb) {
+				skb = xlgmac_create_skb(pdata, napi, desc_data,
+							dma_desc_len);
+				if (!skb)
+					error = 1;
+			} else if (dma_desc_len) {
+				dma_sync_single_range_for_cpu(
+						pdata->dev,
+						desc_data->rx.buf.dma_base,
+						desc_data->rx.buf.dma_off,
+						desc_data->rx.buf.dma_len,
+						DMA_FROM_DEVICE);
+
+				skb_add_rx_frag(
+					skb, skb_shinfo(skb)->nr_frags,
+					desc_data->rx.buf.pa.pages,
+					desc_data->rx.buf.pa.pages_offset,
+					dma_desc_len,
+					desc_data->rx.buf.dma_len);
+				desc_data->rx.buf.pa.pages = NULL;
+			}
+		}
+
+		if (incomplete || context_next)
+			goto read_again;
+
+		if (!skb)
+			goto next_packet;
+
+		/* Be sure we don't exceed the configured MTU */
+		max_len = netdev->mtu + ETH_HLEN;
+		if (!(netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+		    (skb->protocol == htons(ETH_P_8021Q)))
+			max_len += VLAN_HLEN;
+
+		if (skb->len > max_len) {
+			netif_err(pdata, rx_err, netdev,
+				  "packet length exceeds configured MTU\n");
+			dev_kfree_skb(skb);
+			goto next_packet;
+		}
+
+		if (netif_msg_pktdata(pdata))
+			xlgmac_print_pkt(netdev, skb, false);
+
+		skb_checksum_none_assert(skb);
+		if (XLGMAC_GET_REG_BITS(pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_CSUM_DONE_POS,
+				    RX_PACKET_ATTRIBUTES_CSUM_DONE_LEN))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		if (XLGMAC_GET_REG_BITS(pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_VLAN_CTAG_POS,
+				    RX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN))
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       pkt_info->vlan_ctag);
+
+		if (XLGMAC_GET_REG_BITS(pkt_info->attributes,
+					RX_PACKET_ATTRIBUTES_RSS_HASH_POS,
+				    RX_PACKET_ATTRIBUTES_RSS_HASH_LEN))
+			skb_set_hash(skb, pkt_info->rss_hash,
+				     pkt_info->rss_hash_type);
+
+		skb->dev = netdev;
+		skb->protocol = eth_type_trans(skb, netdev);
+		skb_record_rx_queue(skb, channel->queue_index);
+
+		napi_gro_receive(napi, skb);
+
+next_packet:
+		packet_count++;
+	}
+
+	/* Check if we need to save state before leaving */
+	if (received && (incomplete || context_next)) {
+		desc_data = XLGMAC_GET_DESC_DATA(ring, ring->cur);
+		desc_data->state_saved = 1;
+		desc_data->state.skb = skb;
+		desc_data->state.len = len;
+		desc_data->state.error = error;
+	}
+
+	XLGMAC_PR("packet_count = %d\n", packet_count);
+
+	return packet_count;
+}
+
+static int xlgmac_one_poll(struct napi_struct *napi, int budget)
+{
+	struct xlgmac_channel *channel = container_of(napi,
+						struct xlgmac_channel,
+						napi);
+	int processed = 0;
+
+	XLGMAC_PR("budget=%d\n", budget);
+
+	/* Cleanup Tx ring first */
+	xlgmac_tx_poll(channel);
+
+	/* Process Rx ring next */
+	processed = xlgmac_rx_poll(channel, budget);
+
+	/* If we processed everything, we are done */
+	if (processed < budget) {
+		/* Turn off polling */
+		napi_complete_done(napi, processed);
+
+		/* Enable Tx and Rx interrupts */
+		enable_irq(channel->dma_irq);
+	}
+
+	XLGMAC_PR("received = %d\n", processed);
+
+	return processed;
+}
+
+static int xlgmac_all_poll(struct napi_struct *napi, int budget)
+{
+	struct xlgmac_pdata *pdata = container_of(napi,
+						   struct xlgmac_pdata,
+						   napi);
+	struct xlgmac_channel *channel;
+	int ring_budget;
+	int processed, last_processed;
+	unsigned int i;
+
+	XLGMAC_PR("budget=%d\n", budget);
+
+	processed = 0;
+	ring_budget = budget / pdata->rx_ring_count;
+	do {
+		last_processed = processed;
+
+		channel = pdata->channel_head;
+		for (i = 0; i < pdata->channel_count; i++, channel++) {
+			/* Cleanup Tx ring first */
+			xlgmac_tx_poll(channel);
+
+			/* Process Rx ring next */
+			if (ring_budget > (budget - processed))
+				ring_budget = budget - processed;
+			processed += xlgmac_rx_poll(channel, ring_budget);
+		}
+	} while ((processed < budget) && (processed != last_processed));
+
+	/* If we processed everything, we are done */
+	if (processed < budget) {
+		/* Turn off polling */
+		napi_complete_done(napi, processed);
+
+		/* Enable Tx and Rx interrupts */
+		xlgmac_enable_rx_tx_ints(pdata);
+	}
+
+	XLGMAC_PR("received = %d\n", processed);
+
+	return processed;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c
new file mode 100644
index 0000000..504e80d
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c
@@ -0,0 +1,80 @@
+/* Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This Synopsys DWC XLGMAC software driver and associated documentation
+ * (hereinafter the "Software") is an unsupported proprietary work of
+ * Synopsys, Inc. unless otherwise expressly agreed to in writing between
+ * Synopsys and you. The Software IS NOT an item of Licensed Software or a
+ * Licensed Product under any End User Software License Agreement or
+ * Agreement for Licensed Products with Synopsys or any supplement thereto.
+ * Synopsys is a registered trademark of Synopsys, Inc. Other names included
+ * in the SOFTWARE may be the trademarks of their respective owners.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+
+#include "dwc-xlgmac.h"
+#include "dwc-xlgmac-reg.h"
+
+static int xlgmac_probe(struct pci_dev *pcidev, const struct pci_device_id *id)
+{
+	struct device *dev = &pcidev->dev;
+	struct xlgmac_resources res;
+	int i, ret;
+
+	ret = pcim_enable_device(pcidev);
+	if (ret) {
+		dev_err(dev, "ERROR: failed to enable device\n");
+		return ret;
+	}
+
+	for (i = 0; i <= PCI_STD_RESOURCE_END; i++) {
+		if (pci_resource_len(pcidev, i) == 0)
+			continue;
+		ret = pcim_iomap_regions(pcidev, BIT(i), XLGMAC_DRV_NAME);
+		if (ret)
+			return ret;
+		break;
+	}
+
+	pci_set_master(pcidev);
+
+	memset(&res, 0, sizeof(res));
+	res.irq = pcidev->irq;
+	res.addr = pcim_iomap_table(pcidev)[i];
+
+	return xlgmac_drv_probe(&pcidev->dev, &res);
+}
+
+static void xlgmac_remove(struct pci_dev *pcidev)
+{
+	xlgmac_drv_remove(&pcidev->dev);
+}
+
+static const struct pci_device_id xlgmac_pci_tbl[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYNOPSYS, 0x7302) },
+	{ 0 }
+};
+MODULE_DEVICE_TABLE(pci, xlgmac_pci_tbl);
+
+static struct pci_driver xlgmac_pci_driver = {
+	.name		= XLGMAC_DRV_NAME,
+	.id_table	= xlgmac_pci_tbl,
+	.probe		= xlgmac_probe,
+	.remove		= xlgmac_remove,
+};
+
+module_pci_driver(xlgmac_pci_driver);
+
+MODULE_DESCRIPTION(XLGMAC_DRV_DESC);
+MODULE_VERSION(XLGMAC_DRV_VERSION);
+MODULE_AUTHOR("Jie Deng <jiedeng@synopsys.com>");
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h b/drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h
new file mode 100644
index 0000000..7824481
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h
@@ -0,0 +1,746 @@
+/* Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This Synopsys DWC XLGMAC software driver and associated documentation
+ * (hereinafter the "Software") is an unsupported proprietary work of
+ * Synopsys, Inc. unless otherwise expressly agreed to in writing between
+ * Synopsys and you. The Software IS NOT an item of Licensed Software or a
+ * Licensed Product under any End User Software License Agreement or
+ * Agreement for Licensed Products with Synopsys or any supplement thereto.
+ * Synopsys is a registered trademark of Synopsys, Inc. Other names included
+ * in the SOFTWARE may be the trademarks of their respective owners.
+ */
+
+#ifndef __DWC_XLGMAC_REG_H__
+#define __DWC_XLGMAC_REG_H__
+
+/* MAC register offsets */
+#define MAC_TCR				0x0000
+#define MAC_RCR				0x0004
+#define MAC_PFR				0x0008
+#define MAC_HTR0			0x0010
+#define MAC_VLANTR			0x0050
+#define MAC_VLANHTR			0x0058
+#define MAC_VLANIR			0x0060
+#define MAC_Q0TFCR			0x0070
+#define MAC_RFCR			0x0090
+#define MAC_RQC0R			0x00a0
+#define MAC_RQC1R			0x00a4
+#define MAC_RQC2R			0x00a8
+#define MAC_RQC3R			0x00ac
+#define MAC_ISR				0x00b0
+#define MAC_IER				0x00b4
+#define MAC_VR				0x0110
+#define MAC_HWF0R			0x011c
+#define MAC_HWF1R			0x0120
+#define MAC_HWF2R			0x0124
+#define MAC_MACA0HR			0x0300
+#define MAC_MACA0LR			0x0304
+#define MAC_MACA1HR			0x0308
+#define MAC_MACA1LR			0x030c
+#define MAC_RSSCR			0x0c80
+#define MAC_RSSAR			0x0c88
+#define MAC_RSSDR			0x0c8c
+
+#define MAC_QTFCR_INC			4
+#define MAC_MACA_INC			4
+#define MAC_HTR_INC			4
+#define MAC_RQC2_INC			4
+#define MAC_RQC2_Q_PER_REG		4
+
+/* MAC register entry bit positions and sizes */
+#define MAC_HWF0R_ADDMACADRSEL_POS	18
+#define MAC_HWF0R_ADDMACADRSEL_LEN	5
+#define MAC_HWF0R_ARPOFFSEL_POS		9
+#define MAC_HWF0R_ARPOFFSEL_LEN		1
+#define MAC_HWF0R_EEESEL_POS		13
+#define MAC_HWF0R_EEESEL_LEN		1
+#define MAC_HWF0R_PHYIFSEL_POS		1
+#define MAC_HWF0R_PHYIFSEL_LEN		2
+#define MAC_HWF0R_MGKSEL_POS		7
+#define MAC_HWF0R_MGKSEL_LEN		1
+#define MAC_HWF0R_MMCSEL_POS		8
+#define MAC_HWF0R_MMCSEL_LEN		1
+#define MAC_HWF0R_RWKSEL_POS		6
+#define MAC_HWF0R_RWKSEL_LEN		1
+#define MAC_HWF0R_RXCOESEL_POS		16
+#define MAC_HWF0R_RXCOESEL_LEN		1
+#define MAC_HWF0R_SAVLANINS_POS		27
+#define MAC_HWF0R_SAVLANINS_LEN		1
+#define MAC_HWF0R_SMASEL_POS		5
+#define MAC_HWF0R_SMASEL_LEN		1
+#define MAC_HWF0R_TSSEL_POS		12
+#define MAC_HWF0R_TSSEL_LEN		1
+#define MAC_HWF0R_TSSTSSEL_POS		25
+#define MAC_HWF0R_TSSTSSEL_LEN		2
+#define MAC_HWF0R_TXCOESEL_POS		14
+#define MAC_HWF0R_TXCOESEL_LEN		1
+#define MAC_HWF0R_VLHASH_POS		4
+#define MAC_HWF0R_VLHASH_LEN		1
+#define MAC_HWF1R_ADDR64_POS		14
+#define MAC_HWF1R_ADDR64_LEN		2
+#define MAC_HWF1R_ADVTHWORD_POS		13
+#define MAC_HWF1R_ADVTHWORD_LEN		1
+#define MAC_HWF1R_DBGMEMA_POS		19
+#define MAC_HWF1R_DBGMEMA_LEN		1
+#define MAC_HWF1R_DCBEN_POS		16
+#define MAC_HWF1R_DCBEN_LEN		1
+#define MAC_HWF1R_HASHTBLSZ_POS		24
+#define MAC_HWF1R_HASHTBLSZ_LEN		3
+#define MAC_HWF1R_L3L4FNUM_POS		27
+#define MAC_HWF1R_L3L4FNUM_LEN		4
+#define MAC_HWF1R_NUMTC_POS		21
+#define MAC_HWF1R_NUMTC_LEN		3
+#define MAC_HWF1R_RSSEN_POS		20
+#define MAC_HWF1R_RSSEN_LEN		1
+#define MAC_HWF1R_RXFIFOSIZE_POS	0
+#define MAC_HWF1R_RXFIFOSIZE_LEN	5
+#define MAC_HWF1R_SPHEN_POS		17
+#define MAC_HWF1R_SPHEN_LEN		1
+#define MAC_HWF1R_TSOEN_POS		18
+#define MAC_HWF1R_TSOEN_LEN		1
+#define MAC_HWF1R_TXFIFOSIZE_POS	6
+#define MAC_HWF1R_TXFIFOSIZE_LEN	5
+#define MAC_HWF2R_AUXSNAPNUM_POS	28
+#define MAC_HWF2R_AUXSNAPNUM_LEN	3
+#define MAC_HWF2R_PPSOUTNUM_POS		24
+#define MAC_HWF2R_PPSOUTNUM_LEN		3
+#define MAC_HWF2R_RXCHCNT_POS		12
+#define MAC_HWF2R_RXCHCNT_LEN		4
+#define MAC_HWF2R_RXQCNT_POS		0
+#define MAC_HWF2R_RXQCNT_LEN		4
+#define MAC_HWF2R_TXCHCNT_POS		18
+#define MAC_HWF2R_TXCHCNT_LEN		4
+#define MAC_HWF2R_TXQCNT_POS		6
+#define MAC_HWF2R_TXQCNT_LEN		4
+#define MAC_IER_TSIE_POS		12
+#define MAC_IER_TSIE_LEN		1
+#define MAC_ISR_MMCRXIS_POS		9
+#define MAC_ISR_MMCRXIS_LEN		1
+#define MAC_ISR_MMCTXIS_POS		10
+#define MAC_ISR_MMCTXIS_LEN		1
+#define MAC_ISR_PMTIS_POS		4
+#define MAC_ISR_PMTIS_LEN		1
+#define MAC_ISR_TSIS_POS		12
+#define MAC_ISR_TSIS_LEN		1
+#define MAC_MACA1HR_AE_POS		31
+#define MAC_MACA1HR_AE_LEN		1
+#define MAC_PFR_HMC_POS			2
+#define MAC_PFR_HMC_LEN			1
+#define MAC_PFR_HPF_POS			10
+#define MAC_PFR_HPF_LEN			1
+#define MAC_PFR_HUC_POS			1
+#define MAC_PFR_HUC_LEN			1
+#define MAC_PFR_PM_POS			4
+#define MAC_PFR_PM_LEN			1
+#define MAC_PFR_PR_POS			0
+#define MAC_PFR_PR_LEN			1
+#define MAC_PFR_VTFE_POS		16
+#define MAC_PFR_VTFE_LEN		1
+#define MAC_Q0TFCR_PT_POS		16
+#define MAC_Q0TFCR_PT_LEN		16
+#define MAC_Q0TFCR_TFE_POS		1
+#define MAC_Q0TFCR_TFE_LEN		1
+#define MAC_RCR_ACS_POS			1
+#define MAC_RCR_ACS_LEN			1
+#define MAC_RCR_CST_POS			2
+#define MAC_RCR_CST_LEN			1
+#define MAC_RCR_DCRCC_POS		3
+#define MAC_RCR_DCRCC_LEN		1
+#define MAC_RCR_HDSMS_POS		12
+#define MAC_RCR_HDSMS_LEN		3
+#define MAC_RCR_IPC_POS			9
+#define MAC_RCR_IPC_LEN			1
+#define MAC_RCR_JE_POS			8
+#define MAC_RCR_JE_LEN			1
+#define MAC_RCR_LM_POS			10
+#define MAC_RCR_LM_LEN			1
+#define MAC_RCR_RE_POS			0
+#define MAC_RCR_RE_LEN			1
+#define MAC_RFCR_PFCE_POS		8
+#define MAC_RFCR_PFCE_LEN		1
+#define MAC_RFCR_RFE_POS		0
+#define MAC_RFCR_RFE_LEN		1
+#define MAC_RFCR_UP_POS			1
+#define MAC_RFCR_UP_LEN			1
+#define MAC_RQC0R_RXQ0EN_POS		0
+#define MAC_RQC0R_RXQ0EN_LEN		2
+#define MAC_RSSAR_ADDRT_POS		2
+#define MAC_RSSAR_ADDRT_LEN		1
+#define MAC_RSSAR_CT_POS		1
+#define MAC_RSSAR_CT_LEN		1
+#define MAC_RSSAR_OB_POS		0
+#define MAC_RSSAR_OB_LEN		1
+#define MAC_RSSAR_RSSIA_POS		8
+#define MAC_RSSAR_RSSIA_LEN		8
+#define MAC_RSSCR_IP2TE_POS		1
+#define MAC_RSSCR_IP2TE_LEN		1
+#define MAC_RSSCR_RSSE_POS		0
+#define MAC_RSSCR_RSSE_LEN		1
+#define MAC_RSSCR_TCP4TE_POS		2
+#define MAC_RSSCR_TCP4TE_LEN		1
+#define MAC_RSSCR_UDP4TE_POS		3
+#define MAC_RSSCR_UDP4TE_LEN		1
+#define MAC_RSSDR_DMCH_POS		0
+#define MAC_RSSDR_DMCH_LEN		4
+#define MAC_TCR_SS_POS			28
+#define MAC_TCR_SS_LEN			3
+#define MAC_TCR_TE_POS			0
+#define MAC_TCR_TE_LEN			1
+#define MAC_VLANHTR_VLHT_POS		0
+#define MAC_VLANHTR_VLHT_LEN		16
+#define MAC_VLANIR_VLTI_POS		20
+#define MAC_VLANIR_VLTI_LEN		1
+#define MAC_VLANIR_CSVL_POS		19
+#define MAC_VLANIR_CSVL_LEN		1
+#define MAC_VLANTR_DOVLTC_POS		20
+#define MAC_VLANTR_DOVLTC_LEN		1
+#define MAC_VLANTR_ERSVLM_POS		19
+#define MAC_VLANTR_ERSVLM_LEN		1
+#define MAC_VLANTR_ESVL_POS		18
+#define MAC_VLANTR_ESVL_LEN		1
+#define MAC_VLANTR_ETV_POS		16
+#define MAC_VLANTR_ETV_LEN		1
+#define MAC_VLANTR_EVLS_POS		21
+#define MAC_VLANTR_EVLS_LEN		2
+#define MAC_VLANTR_EVLRXS_POS		24
+#define MAC_VLANTR_EVLRXS_LEN		1
+#define MAC_VLANTR_VL_POS		0
+#define MAC_VLANTR_VL_LEN		16
+#define MAC_VLANTR_VTHM_POS		25
+#define MAC_VLANTR_VTHM_LEN		1
+#define MAC_VLANTR_VTIM_POS		17
+#define MAC_VLANTR_VTIM_LEN		1
+#define MAC_VR_DEVID_POS		8
+#define MAC_VR_DEVID_LEN		8
+#define MAC_VR_SNPSVER_POS		0
+#define MAC_VR_SNPSVER_LEN		8
+#define MAC_VR_USERVER_POS		16
+#define MAC_VR_USERVER_LEN		8
+
+/* MMC register offsets */
+#define MMC_CR				0x0800
+#define MMC_RISR			0x0804
+#define MMC_TISR			0x0808
+#define MMC_RIER			0x080c
+#define MMC_TIER			0x0810
+#define MMC_TXOCTETCOUNT_GB_LO		0x0814
+#define MMC_TXFRAMECOUNT_GB_LO		0x081c
+#define MMC_TXBROADCASTFRAMES_G_LO	0x0824
+#define MMC_TXMULTICASTFRAMES_G_LO	0x082c
+#define MMC_TX64OCTETS_GB_LO		0x0834
+#define MMC_TX65TO127OCTETS_GB_LO	0x083c
+#define MMC_TX128TO255OCTETS_GB_LO	0x0844
+#define MMC_TX256TO511OCTETS_GB_LO	0x084c
+#define MMC_TX512TO1023OCTETS_GB_LO	0x0854
+#define MMC_TX1024TOMAXOCTETS_GB_LO	0x085c
+#define MMC_TXUNICASTFRAMES_GB_LO	0x0864
+#define MMC_TXMULTICASTFRAMES_GB_LO	0x086c
+#define MMC_TXBROADCASTFRAMES_GB_LO	0x0874
+#define MMC_TXUNDERFLOWERROR_LO		0x087c
+#define MMC_TXOCTETCOUNT_G_LO		0x0884
+#define MMC_TXFRAMECOUNT_G_LO		0x088c
+#define MMC_TXPAUSEFRAMES_LO		0x0894
+#define MMC_TXVLANFRAMES_G_LO		0x089c
+#define MMC_RXFRAMECOUNT_GB_LO		0x0900
+#define MMC_RXOCTETCOUNT_GB_LO		0x0908
+#define MMC_RXOCTETCOUNT_G_LO		0x0910
+#define MMC_RXBROADCASTFRAMES_G_LO	0x0918
+#define MMC_RXMULTICASTFRAMES_G_LO	0x0920
+#define MMC_RXCRCERROR_LO		0x0928
+#define MMC_RXRUNTERROR			0x0930
+#define MMC_RXJABBERERROR		0x0934
+#define MMC_RXUNDERSIZE_G		0x0938
+#define MMC_RXOVERSIZE_G		0x093c
+#define MMC_RX64OCTETS_GB_LO		0x0940
+#define MMC_RX65TO127OCTETS_GB_LO	0x0948
+#define MMC_RX128TO255OCTETS_GB_LO	0x0950
+#define MMC_RX256TO511OCTETS_GB_LO	0x0958
+#define MMC_RX512TO1023OCTETS_GB_LO	0x0960
+#define MMC_RX1024TOMAXOCTETS_GB_LO	0x0968
+#define MMC_RXUNICASTFRAMES_G_LO	0x0970
+#define MMC_RXLENGTHERROR_LO		0x0978
+#define MMC_RXOUTOFRANGETYPE_LO		0x0980
+#define MMC_RXPAUSEFRAMES_LO		0x0988
+#define MMC_RXFIFOOVERFLOW_LO		0x0990
+#define MMC_RXVLANFRAMES_GB_LO		0x0998
+#define MMC_RXWATCHDOGERROR		0x09a0
+
+/* MMC register entry bit positions and sizes */
+#define MMC_CR_CR_POS				0
+#define MMC_CR_CR_LEN				1
+#define MMC_CR_CSR_POS				1
+#define MMC_CR_CSR_LEN				1
+#define MMC_CR_ROR_POS				2
+#define MMC_CR_ROR_LEN				1
+#define MMC_CR_MCF_POS				3
+#define MMC_CR_MCF_LEN				1
+#define MMC_CR_MCT_POS				4
+#define MMC_CR_MCT_LEN				2
+#define MMC_RIER_ALL_INTERRUPTS_POS		0
+#define MMC_RIER_ALL_INTERRUPTS_LEN		23
+#define MMC_RISR_RXFRAMECOUNT_GB_POS		0
+#define MMC_RISR_RXFRAMECOUNT_GB_LEN		1
+#define MMC_RISR_RXOCTETCOUNT_GB_POS		1
+#define MMC_RISR_RXOCTETCOUNT_GB_LEN		1
+#define MMC_RISR_RXOCTETCOUNT_G_POS		2
+#define MMC_RISR_RXOCTETCOUNT_G_LEN		1
+#define MMC_RISR_RXBROADCASTFRAMES_G_POS	3
+#define MMC_RISR_RXBROADCASTFRAMES_G_LEN	1
+#define MMC_RISR_RXMULTICASTFRAMES_G_POS	4
+#define MMC_RISR_RXMULTICASTFRAMES_G_LEN	1
+#define MMC_RISR_RXCRCERROR_POS			5
+#define MMC_RISR_RXCRCERROR_LEN			1
+#define MMC_RISR_RXRUNTERROR_POS		6
+#define MMC_RISR_RXRUNTERROR_LEN		1
+#define MMC_RISR_RXJABBERERROR_POS		7
+#define MMC_RISR_RXJABBERERROR_LEN		1
+#define MMC_RISR_RXUNDERSIZE_G_POS		8
+#define MMC_RISR_RXUNDERSIZE_G_LEN		1
+#define MMC_RISR_RXOVERSIZE_G_POS		9
+#define MMC_RISR_RXOVERSIZE_G_LEN		1
+#define MMC_RISR_RX64OCTETS_GB_POS		10
+#define MMC_RISR_RX64OCTETS_GB_LEN		1
+#define MMC_RISR_RX65TO127OCTETS_GB_POS		11
+#define MMC_RISR_RX65TO127OCTETS_GB_LEN		1
+#define MMC_RISR_RX128TO255OCTETS_GB_POS	12
+#define MMC_RISR_RX128TO255OCTETS_GB_LEN	1
+#define MMC_RISR_RX256TO511OCTETS_GB_POS	13
+#define MMC_RISR_RX256TO511OCTETS_GB_LEN	1
+#define MMC_RISR_RX512TO1023OCTETS_GB_POS	14
+#define MMC_RISR_RX512TO1023OCTETS_GB_LEN	1
+#define MMC_RISR_RX1024TOMAXOCTETS_GB_POS	15
+#define MMC_RISR_RX1024TOMAXOCTETS_GB_LEN	1
+#define MMC_RISR_RXUNICASTFRAMES_G_POS		16
+#define MMC_RISR_RXUNICASTFRAMES_G_LEN		1
+#define MMC_RISR_RXLENGTHERROR_POS		17
+#define MMC_RISR_RXLENGTHERROR_LEN		1
+#define MMC_RISR_RXOUTOFRANGETYPE_POS		18
+#define MMC_RISR_RXOUTOFRANGETYPE_LEN		1
+#define MMC_RISR_RXPAUSEFRAMES_POS		19
+#define MMC_RISR_RXPAUSEFRAMES_LEN		1
+#define MMC_RISR_RXFIFOOVERFLOW_POS		20
+#define MMC_RISR_RXFIFOOVERFLOW_LEN		1
+#define MMC_RISR_RXVLANFRAMES_GB_POS		21
+#define MMC_RISR_RXVLANFRAMES_GB_LEN		1
+#define MMC_RISR_RXWATCHDOGERROR_POS		22
+#define MMC_RISR_RXWATCHDOGERROR_LEN		1
+#define MMC_TIER_ALL_INTERRUPTS_POS		0
+#define MMC_TIER_ALL_INTERRUPTS_LEN		18
+#define MMC_TISR_TXOCTETCOUNT_GB_POS		0
+#define MMC_TISR_TXOCTETCOUNT_GB_LEN		1
+#define MMC_TISR_TXFRAMECOUNT_GB_POS		1
+#define MMC_TISR_TXFRAMECOUNT_GB_LEN		1
+#define MMC_TISR_TXBROADCASTFRAMES_G_POS	2
+#define MMC_TISR_TXBROADCASTFRAMES_G_LEN	1
+#define MMC_TISR_TXMULTICASTFRAMES_G_POS	3
+#define MMC_TISR_TXMULTICASTFRAMES_G_LEN	1
+#define MMC_TISR_TX64OCTETS_GB_POS		4
+#define MMC_TISR_TX64OCTETS_GB_LEN		1
+#define MMC_TISR_TX65TO127OCTETS_GB_POS		5
+#define MMC_TISR_TX65TO127OCTETS_GB_LEN		1
+#define MMC_TISR_TX128TO255OCTETS_GB_POS	6
+#define MMC_TISR_TX128TO255OCTETS_GB_LEN	1
+#define MMC_TISR_TX256TO511OCTETS_GB_POS	7
+#define MMC_TISR_TX256TO511OCTETS_GB_LEN	1
+#define MMC_TISR_TX512TO1023OCTETS_GB_POS	8
+#define MMC_TISR_TX512TO1023OCTETS_GB_LEN	1
+#define MMC_TISR_TX1024TOMAXOCTETS_GB_POS	9
+#define MMC_TISR_TX1024TOMAXOCTETS_GB_LEN	1
+#define MMC_TISR_TXUNICASTFRAMES_GB_POS		10
+#define MMC_TISR_TXUNICASTFRAMES_GB_LEN		1
+#define MMC_TISR_TXMULTICASTFRAMES_GB_POS	11
+#define MMC_TISR_TXMULTICASTFRAMES_GB_LEN	1
+#define MMC_TISR_TXBROADCASTFRAMES_GB_POS	12
+#define MMC_TISR_TXBROADCASTFRAMES_GB_LEN	1
+#define MMC_TISR_TXUNDERFLOWERROR_POS		13
+#define MMC_TISR_TXUNDERFLOWERROR_LEN		1
+#define MMC_TISR_TXOCTETCOUNT_G_POS		14
+#define MMC_TISR_TXOCTETCOUNT_G_LEN		1
+#define MMC_TISR_TXFRAMECOUNT_G_POS		15
+#define MMC_TISR_TXFRAMECOUNT_G_LEN		1
+#define MMC_TISR_TXPAUSEFRAMES_POS		16
+#define MMC_TISR_TXPAUSEFRAMES_LEN		1
+#define MMC_TISR_TXVLANFRAMES_G_POS		17
+#define MMC_TISR_TXVLANFRAMES_G_LEN		1
+
+/* MTL register offsets */
+#define MTL_OMR				0x1000
+#define MTL_FDDR			0x1010
+#define MTL_RQDCM0R			0x1030
+
+#define MTL_RQDCM_INC			4
+#define MTL_RQDCM_Q_PER_REG		4
+
+/* MTL register entry bit positions and sizes */
+#define MTL_OMR_ETSALG_POS		5
+#define MTL_OMR_ETSALG_LEN		2
+#define MTL_OMR_RAA_POS			2
+#define MTL_OMR_RAA_LEN			1
+
+/* MTL queue register offsets
+ *   Multiple queues can be active.  The first queue has registers
+ *   that begin at 0x1100.  Each subsequent queue has registers that
+ *   are accessed using an offset of 0x80 from the previous queue.
+ */
+#define MTL_Q_BASE			0x1100
+#define MTL_Q_INC			0x80
+
+#define MTL_Q_TQOMR			0x00
+#define MTL_Q_RQOMR			0x40
+#define MTL_Q_RQDR			0x48
+#define MTL_Q_RQFCR			0x50
+#define MTL_Q_IER			0x70
+#define MTL_Q_ISR			0x74
+
+/* MTL queue register entry bit positions and sizes */
+#define MTL_Q_RQDR_PRXQ_POS		16
+#define MTL_Q_RQDR_PRXQ_LEN		14
+#define MTL_Q_RQDR_RXQSTS_POS		4
+#define MTL_Q_RQDR_RXQSTS_LEN		2
+#define MTL_Q_RQFCR_RFA_POS		1
+#define MTL_Q_RQFCR_RFA_LEN		6
+#define MTL_Q_RQFCR_RFD_POS		17
+#define MTL_Q_RQFCR_RFD_LEN		6
+#define MTL_Q_RQOMR_EHFC_POS		7
+#define MTL_Q_RQOMR_EHFC_LEN		1
+#define MTL_Q_RQOMR_RQS_POS		16
+#define MTL_Q_RQOMR_RQS_LEN		9
+#define MTL_Q_RQOMR_RSF_POS		5
+#define MTL_Q_RQOMR_RSF_LEN		1
+#define MTL_Q_RQOMR_FEP_POS		4
+#define MTL_Q_RQOMR_FEP_LEN		1
+#define MTL_Q_RQOMR_FUP_POS		3
+#define MTL_Q_RQOMR_FUP_LEN		1
+#define MTL_Q_RQOMR_RTC_POS		0
+#define MTL_Q_RQOMR_RTC_LEN		2
+#define MTL_Q_TQOMR_FTQ_POS		0
+#define MTL_Q_TQOMR_FTQ_LEN		1
+#define MTL_Q_TQOMR_Q2TCMAP_POS		8
+#define MTL_Q_TQOMR_Q2TCMAP_LEN		3
+#define MTL_Q_TQOMR_TQS_POS		16
+#define MTL_Q_TQOMR_TQS_LEN		10
+#define MTL_Q_TQOMR_TSF_POS		1
+#define MTL_Q_TQOMR_TSF_LEN		1
+#define MTL_Q_TQOMR_TTC_POS		4
+#define MTL_Q_TQOMR_TTC_LEN		3
+#define MTL_Q_TQOMR_TXQEN_POS		2
+#define MTL_Q_TQOMR_TXQEN_LEN		2
+
+/* MTL queue register value */
+#define MTL_RSF_DISABLE			0x00
+#define MTL_RSF_ENABLE			0x01
+#define MTL_TSF_DISABLE			0x00
+#define MTL_TSF_ENABLE			0x01
+
+#define MTL_RX_THRESHOLD_64		0x00
+#define MTL_RX_THRESHOLD_96		0x02
+#define MTL_RX_THRESHOLD_128		0x03
+#define MTL_TX_THRESHOLD_64		0x00
+#define MTL_TX_THRESHOLD_96		0x02
+#define MTL_TX_THRESHOLD_128		0x03
+#define MTL_TX_THRESHOLD_192		0x04
+#define MTL_TX_THRESHOLD_256		0x05
+#define MTL_TX_THRESHOLD_384		0x06
+#define MTL_TX_THRESHOLD_512		0x07
+
+#define MTL_ETSALG_WRR			0x00
+#define MTL_ETSALG_WFQ			0x01
+#define MTL_ETSALG_DWRR			0x02
+#define MTL_RAA_SP			0x00
+#define MTL_RAA_WSP			0x01
+
+#define MTL_Q_DISABLED			0x00
+#define MTL_Q_ENABLED			0x02
+
+#define MTL_RQDCM0R_Q0MDMACH		0x0
+#define MTL_RQDCM0R_Q1MDMACH		0x00000100
+#define MTL_RQDCM0R_Q2MDMACH		0x00020000
+#define MTL_RQDCM0R_Q3MDMACH		0x03000000
+#define MTL_RQDCM1R_Q4MDMACH		0x00000004
+#define MTL_RQDCM1R_Q5MDMACH		0x00000500
+#define MTL_RQDCM1R_Q6MDMACH		0x00060000
+#define MTL_RQDCM1R_Q7MDMACH		0x07000000
+#define MTL_RQDCM2R_Q8MDMACH		0x00000008
+#define MTL_RQDCM2R_Q9MDMACH		0x00000900
+#define MTL_RQDCM2R_Q10MDMACH		0x000A0000
+#define MTL_RQDCM2R_Q11MDMACH		0x0B000000
+
+/* MTL traffic class register offsets
+ *   Multiple traffic classes can be active.  The first class has registers
+ *   that begin at 0x1100.  Each subsequent queue has registers that
+ *   are accessed using an offset of 0x80 from the previous queue.
+ */
+#define MTL_TC_BASE			MTL_Q_BASE
+#define MTL_TC_INC			MTL_Q_INC
+
+#define MTL_TC_ETSCR			0x10
+#define MTL_TC_ETSSR			0x14
+#define MTL_TC_QWR			0x18
+
+/* MTL traffic class register entry bit positions and sizes */
+#define MTL_TC_ETSCR_TSA_POS		0
+#define MTL_TC_ETSCR_TSA_LEN		2
+#define MTL_TC_QWR_QW_POS		0
+#define MTL_TC_QWR_QW_LEN		21
+
+/* MTL traffic class register value */
+#define MTL_TSA_SP			0x00
+#define MTL_TSA_ETS			0x02
+
+/* DMA register offsets */
+#define DMA_MR				0x3000
+#define DMA_SBMR			0x3004
+#define DMA_ISR				0x3008
+#define DMA_DSR0			0x3020
+#define DMA_DSR1			0x3024
+
+/* DMA register entry bit positions and sizes */
+#define DMA_ISR_MACIS_POS		17
+#define DMA_ISR_MACIS_LEN		1
+#define DMA_ISR_MTLIS_POS		16
+#define DMA_ISR_MTLIS_LEN		1
+#define DMA_MR_SWR_POS			0
+#define DMA_MR_SWR_LEN			1
+#define DMA_SBMR_EAME_POS		11
+#define DMA_SBMR_EAME_LEN		1
+#define DMA_SBMR_BLEN_64_POS		5
+#define DMA_SBMR_BLEN_64_LEN		1
+#define DMA_SBMR_BLEN_128_POS		6
+#define DMA_SBMR_BLEN_128_LEN		1
+#define DMA_SBMR_BLEN_256_POS		7
+#define DMA_SBMR_BLEN_256_LEN		1
+#define DMA_SBMR_UNDEF_POS		0
+#define DMA_SBMR_UNDEF_LEN		1
+
+/* DMA register values */
+#define DMA_DSR_RPS_LEN			4
+#define DMA_DSR_TPS_LEN			4
+#define DMA_DSR_Q_LEN			(DMA_DSR_RPS_LEN + DMA_DSR_TPS_LEN)
+#define DMA_DSR0_TPS_START		12
+#define DMA_DSRX_FIRST_QUEUE		3
+#define DMA_DSRX_INC			4
+#define DMA_DSRX_QPR			4
+#define DMA_DSRX_TPS_START		4
+#define DMA_TPS_STOPPED			0x00
+#define DMA_TPS_SUSPENDED		0x06
+
+/* DMA channel register offsets
+ *   Multiple channels can be active.  The first channel has registers
+ *   that begin at 0x3100.  Each subsequent channel has registers that
+ *   are accessed using an offset of 0x80 from the previous channel.
+ */
+#define DMA_CH_BASE			0x3100
+#define DMA_CH_INC			0x80
+
+#define DMA_CH_CR			0x00
+#define DMA_CH_TCR			0x04
+#define DMA_CH_RCR			0x08
+#define DMA_CH_TDLR_HI			0x10
+#define DMA_CH_TDLR_LO			0x14
+#define DMA_CH_RDLR_HI			0x18
+#define DMA_CH_RDLR_LO			0x1c
+#define DMA_CH_TDTR_LO			0x24
+#define DMA_CH_RDTR_LO			0x2c
+#define DMA_CH_TDRLR			0x30
+#define DMA_CH_RDRLR			0x34
+#define DMA_CH_IER			0x38
+#define DMA_CH_RIWT			0x3c
+#define DMA_CH_SR			0x60
+
+/* DMA channel register entry bit positions and sizes */
+#define DMA_CH_CR_PBLX8_POS		16
+#define DMA_CH_CR_PBLX8_LEN		1
+#define DMA_CH_CR_SPH_POS		24
+#define DMA_CH_CR_SPH_LEN		1
+#define DMA_CH_IER_AIE_POS		15
+#define DMA_CH_IER_AIE_LEN		1
+#define DMA_CH_IER_FBEE_POS		12
+#define DMA_CH_IER_FBEE_LEN		1
+#define DMA_CH_IER_NIE_POS		16
+#define DMA_CH_IER_NIE_LEN		1
+#define DMA_CH_IER_RBUE_POS		7
+#define DMA_CH_IER_RBUE_LEN		1
+#define DMA_CH_IER_RIE_POS		6
+#define DMA_CH_IER_RIE_LEN		1
+#define DMA_CH_IER_RSE_POS		8
+#define DMA_CH_IER_RSE_LEN		1
+#define DMA_CH_IER_TBUE_POS		2
+#define DMA_CH_IER_TBUE_LEN		1
+#define DMA_CH_IER_TIE_POS		0
+#define DMA_CH_IER_TIE_LEN		1
+#define DMA_CH_IER_TXSE_POS		1
+#define DMA_CH_IER_TXSE_LEN		1
+#define DMA_CH_RCR_PBL_POS		16
+#define DMA_CH_RCR_PBL_LEN		6
+#define DMA_CH_RCR_RBSZ_POS		1
+#define DMA_CH_RCR_RBSZ_LEN		14
+#define DMA_CH_RCR_SR_POS		0
+#define DMA_CH_RCR_SR_LEN		1
+#define DMA_CH_RIWT_RWT_POS		0
+#define DMA_CH_RIWT_RWT_LEN		8
+#define DMA_CH_SR_FBE_POS		12
+#define DMA_CH_SR_FBE_LEN		1
+#define DMA_CH_SR_RBU_POS		7
+#define DMA_CH_SR_RBU_LEN		1
+#define DMA_CH_SR_RI_POS		6
+#define DMA_CH_SR_RI_LEN		1
+#define DMA_CH_SR_RPS_POS		8
+#define DMA_CH_SR_RPS_LEN		1
+#define DMA_CH_SR_TBU_POS		2
+#define DMA_CH_SR_TBU_LEN		1
+#define DMA_CH_SR_TI_POS		0
+#define DMA_CH_SR_TI_LEN		1
+#define DMA_CH_SR_TPS_POS		1
+#define DMA_CH_SR_TPS_LEN		1
+#define DMA_CH_TCR_OSP_POS		4
+#define DMA_CH_TCR_OSP_LEN		1
+#define DMA_CH_TCR_PBL_POS		16
+#define DMA_CH_TCR_PBL_LEN		6
+#define DMA_CH_TCR_ST_POS		0
+#define DMA_CH_TCR_ST_LEN		1
+#define DMA_CH_TCR_TSE_POS		12
+#define DMA_CH_TCR_TSE_LEN		1
+
+/* DMA channel register values */
+#define DMA_OSP_DISABLE			0x00
+#define DMA_OSP_ENABLE			0x01
+#define DMA_PBL_1			1
+#define DMA_PBL_2			2
+#define DMA_PBL_4			4
+#define DMA_PBL_8			8
+#define DMA_PBL_16			16
+#define DMA_PBL_32			32
+#define DMA_PBL_64			64
+#define DMA_PBL_128			128
+#define DMA_PBL_256			256
+#define DMA_PBL_X8_DISABLE		0x00
+#define DMA_PBL_X8_ENABLE		0x01
+
+/* Descriptor/Packet entry bit positions and sizes */
+#define RX_PACKET_ERRORS_CRC_POS		2
+#define RX_PACKET_ERRORS_CRC_LEN		1
+#define RX_PACKET_ERRORS_FRAME_POS		3
+#define RX_PACKET_ERRORS_FRAME_LEN		1
+#define RX_PACKET_ERRORS_LENGTH_POS		0
+#define RX_PACKET_ERRORS_LENGTH_LEN		1
+#define RX_PACKET_ERRORS_OVERRUN_POS		1
+#define RX_PACKET_ERRORS_OVERRUN_LEN		1
+
+#define RX_PACKET_ATTRIBUTES_CSUM_DONE_POS	0
+#define RX_PACKET_ATTRIBUTES_CSUM_DONE_LEN	1
+#define RX_PACKET_ATTRIBUTES_VLAN_CTAG_POS	1
+#define RX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN	1
+#define RX_PACKET_ATTRIBUTES_INCOMPLETE_POS	2
+#define RX_PACKET_ATTRIBUTES_INCOMPLETE_LEN	1
+#define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_POS	3
+#define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_LEN	1
+#define RX_PACKET_ATTRIBUTES_CONTEXT_POS	4
+#define RX_PACKET_ATTRIBUTES_CONTEXT_LEN	1
+#define RX_PACKET_ATTRIBUTES_RX_TSTAMP_POS	5
+#define RX_PACKET_ATTRIBUTES_RX_TSTAMP_LEN	1
+#define RX_PACKET_ATTRIBUTES_RSS_HASH_POS	6
+#define RX_PACKET_ATTRIBUTES_RSS_HASH_LEN	1
+
+#define RX_NORMAL_DESC0_OVT_POS			0
+#define RX_NORMAL_DESC0_OVT_LEN			16
+#define RX_NORMAL_DESC2_HL_POS			0
+#define RX_NORMAL_DESC2_HL_LEN			10
+#define RX_NORMAL_DESC3_CDA_POS			27
+#define RX_NORMAL_DESC3_CDA_LEN			1
+#define RX_NORMAL_DESC3_CTXT_POS		30
+#define RX_NORMAL_DESC3_CTXT_LEN		1
+#define RX_NORMAL_DESC3_ES_POS			15
+#define RX_NORMAL_DESC3_ES_LEN			1
+#define RX_NORMAL_DESC3_ETLT_POS		16
+#define RX_NORMAL_DESC3_ETLT_LEN		4
+#define RX_NORMAL_DESC3_FD_POS			29
+#define RX_NORMAL_DESC3_FD_LEN			1
+#define RX_NORMAL_DESC3_INTE_POS		30
+#define RX_NORMAL_DESC3_INTE_LEN		1
+#define RX_NORMAL_DESC3_L34T_POS		20
+#define RX_NORMAL_DESC3_L34T_LEN		4
+#define RX_NORMAL_DESC3_LD_POS			28
+#define RX_NORMAL_DESC3_LD_LEN			1
+#define RX_NORMAL_DESC3_OWN_POS			31
+#define RX_NORMAL_DESC3_OWN_LEN			1
+#define RX_NORMAL_DESC3_PL_POS			0
+#define RX_NORMAL_DESC3_PL_LEN			14
+#define RX_NORMAL_DESC3_RSV_POS			26
+#define RX_NORMAL_DESC3_RSV_LEN			1
+
+#define RX_DESC3_L34T_IPV4_TCP			1
+#define RX_DESC3_L34T_IPV4_UDP			2
+#define RX_DESC3_L34T_IPV4_ICMP			3
+#define RX_DESC3_L34T_IPV6_TCP			9
+#define RX_DESC3_L34T_IPV6_UDP			10
+#define RX_DESC3_L34T_IPV6_ICMP			11
+
+#define RX_CONTEXT_DESC3_TSA_POS		4
+#define RX_CONTEXT_DESC3_TSA_LEN		1
+#define RX_CONTEXT_DESC3_TSD_POS		6
+#define RX_CONTEXT_DESC3_TSD_LEN		1
+
+#define TX_PACKET_ATTRIBUTES_CSUM_ENABLE_POS	0
+#define TX_PACKET_ATTRIBUTES_CSUM_ENABLE_LEN	1
+#define TX_PACKET_ATTRIBUTES_TSO_ENABLE_POS	1
+#define TX_PACKET_ATTRIBUTES_TSO_ENABLE_LEN	1
+#define TX_PACKET_ATTRIBUTES_VLAN_CTAG_POS	2
+#define TX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN	1
+#define TX_PACKET_ATTRIBUTES_PTP_POS		3
+#define TX_PACKET_ATTRIBUTES_PTP_LEN		1
+
+#define TX_CONTEXT_DESC2_MSS_POS		0
+#define TX_CONTEXT_DESC2_MSS_LEN		15
+#define TX_CONTEXT_DESC3_CTXT_POS		30
+#define TX_CONTEXT_DESC3_CTXT_LEN		1
+#define TX_CONTEXT_DESC3_TCMSSV_POS		26
+#define TX_CONTEXT_DESC3_TCMSSV_LEN		1
+#define TX_CONTEXT_DESC3_VLTV_POS		16
+#define TX_CONTEXT_DESC3_VLTV_LEN		1
+#define TX_CONTEXT_DESC3_VT_POS			0
+#define TX_CONTEXT_DESC3_VT_LEN			16
+
+#define TX_NORMAL_DESC2_HL_B1L_POS		0
+#define TX_NORMAL_DESC2_HL_B1L_LEN		14
+#define TX_NORMAL_DESC2_IC_POS			31
+#define TX_NORMAL_DESC2_IC_LEN			1
+#define TX_NORMAL_DESC2_TTSE_POS		30
+#define TX_NORMAL_DESC2_TTSE_LEN		1
+#define TX_NORMAL_DESC2_VTIR_POS		14
+#define TX_NORMAL_DESC2_VTIR_LEN		2
+#define TX_NORMAL_DESC3_CIC_POS			16
+#define TX_NORMAL_DESC3_CIC_LEN			2
+#define TX_NORMAL_DESC3_CPC_POS			26
+#define TX_NORMAL_DESC3_CPC_LEN			2
+#define TX_NORMAL_DESC3_CTXT_POS		30
+#define TX_NORMAL_DESC3_CTXT_LEN		1
+#define TX_NORMAL_DESC3_FD_POS			29
+#define TX_NORMAL_DESC3_FD_LEN			1
+#define TX_NORMAL_DESC3_FL_POS			0
+#define TX_NORMAL_DESC3_FL_LEN			15
+#define TX_NORMAL_DESC3_LD_POS			28
+#define TX_NORMAL_DESC3_LD_LEN			1
+#define TX_NORMAL_DESC3_OWN_POS			31
+#define TX_NORMAL_DESC3_OWN_LEN			1
+#define TX_NORMAL_DESC3_TCPHDRLEN_POS		19
+#define TX_NORMAL_DESC3_TCPHDRLEN_LEN		4
+#define TX_NORMAL_DESC3_TCPPL_POS		0
+#define TX_NORMAL_DESC3_TCPPL_LEN		18
+#define TX_NORMAL_DESC3_TSE_POS			18
+#define TX_NORMAL_DESC3_TSE_LEN			1
+
+#define TX_NORMAL_DESC2_VLAN_INSERT		0x2
+
+#define XLGMAC_MTL_REG(pdata, n, reg)					\
+	((pdata)->mac_regs + MTL_Q_BASE + ((n) * MTL_Q_INC) + (reg))
+
+#define XLGMAC_DMA_REG(channel, reg)	((channel)->dma_regs + (reg))
+
+#endif /* __DWC_XLGMAC_REG_H__ */
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac.h b/drivers/net/ethernet/synopsys/dwc-xlgmac.h
new file mode 100644
index 0000000..7a4dc64
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac.h
@@ -0,0 +1,651 @@
+/* Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This Synopsys DWC XLGMAC software driver and associated documentation
+ * (hereinafter the "Software") is an unsupported proprietary work of
+ * Synopsys, Inc. unless otherwise expressly agreed to in writing between
+ * Synopsys and you. The Software IS NOT an item of Licensed Software or a
+ * Licensed Product under any End User Software License Agreement or
+ * Agreement for Licensed Products with Synopsys or any supplement thereto.
+ * Synopsys is a registered trademark of Synopsys, Inc. Other names included
+ * in the SOFTWARE may be the trademarks of their respective owners.
+ */
+
+#ifndef __DWC_XLGMAC_H__
+#define __DWC_XLGMAC_H__
+
+#include <linux/dma-mapping.h>
+#include <linux/netdevice.h>
+#include <linux/workqueue.h>
+#include <linux/phy.h>
+#include <linux/if_vlan.h>
+#include <linux/bitops.h>
+#include <linux/timecounter.h>
+
+#define XLGMAC_DRV_NAME			"dwc-xlgmac"
+#define XLGMAC_DRV_VERSION		"1.0.0"
+#define XLGMAC_DRV_DESC			"Synopsys DWC XLGMAC Driver"
+
+/* Descriptor related parameters */
+#define XLGMAC_TX_DESC_CNT		1024
+#define XLGMAC_TX_DESC_MIN_FREE		(XLGMAC_TX_DESC_CNT >> 3)
+#define XLGMAC_TX_DESC_MAX_PROC		(XLGMAC_TX_DESC_CNT >> 1)
+#define XLGMAC_RX_DESC_CNT		1024
+#define XLGMAC_RX_DESC_MAX_DIRTY	(XLGMAC_RX_DESC_CNT >> 3)
+
+/* Descriptors required for maximum contiguous TSO/GSO packet */
+#define XLGMAC_TX_MAX_SPLIT	((GSO_MAX_SIZE / XLGMAC_TX_MAX_BUF_SIZE) + 1)
+
+/* Maximum possible descriptors needed for a SKB */
+#define XLGMAC_TX_MAX_DESC_NR	(MAX_SKB_FRAGS + XLGMAC_TX_MAX_SPLIT + 2)
+
+#define XLGMAC_TX_MAX_BUF_SIZE	(0x3fff & ~(64 - 1))
+#define XLGMAC_RX_MIN_BUF_SIZE	(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
+#define XLGMAC_RX_BUF_ALIGN	64
+
+/* Maximum Size for Splitting the Header Data
+ * Keep in sync with SKB_ALLOC_SIZE
+ * 3'b000: 64 bytes, 3'b001: 128 bytes
+ * 3'b010: 256 bytes, 3'b011: 512 bytes
+ * 3'b100: 1023 bytes ,   3'b101'3'b111: Reserved
+ */
+#define XLGMAC_SPH_HDSMS_SIZE		3
+#define XLGMAC_SKB_ALLOC_SIZE		512
+
+#define XLGMAC_MAX_FIFO			81920
+
+#define XLGMAC_MAX_DMA_CHANNELS		16
+#define XLGMAC_DMA_STOP_TIMEOUT		5
+#define XLGMAC_DMA_INTERRUPT_MASK	0x31c7
+
+/* Default coalescing parameters */
+#define XLGMAC_INIT_DMA_TX_USECS	1000
+#define XLGMAC_INIT_DMA_TX_FRAMES	25
+#define XLGMAC_INIT_DMA_RX_USECS	30
+#define XLGMAC_INIT_DMA_RX_FRAMES	25
+
+/* Flow control queue count */
+#define XLGMAC_MAX_FLOW_CONTROL_QUEUES	8
+
+/* System clock is 125 MHz */
+#define XLGMAC_SYSCLOCK			125000000
+
+/* Maximum MAC address hash table size (256 bits = 8 bytes) */
+#define XLGMAC_MAC_HASH_TABLE_SIZE	8
+
+/* Receive Side Scaling */
+#define XLGMAC_RSS_HASH_KEY_SIZE	40
+#define XLGMAC_RSS_MAX_TABLE_SIZE	256
+#define XLGMAC_RSS_LOOKUP_TABLE_TYPE	0
+#define XLGMAC_RSS_HASH_KEY_TYPE	1
+
+#define XLGMAC_STD_PACKET_MTU		1500
+#define XLGMAC_JUMBO_PACKET_MTU		9000
+
+/* Helper macro for descriptor handling
+ *  Always use XLGMAC_GET_DESC_DATA to access the descriptor data
+ */
+#define XLGMAC_GET_DESC_DATA(ring, idx) ({				\
+	typeof(ring) _ring = (ring);					\
+	((_ring)->desc_data_head +					\
+	 ((idx) & ((_ring)->dma_desc_count - 1)));			\
+})
+
+#define XLGMAC_GET_REG_BITS(var, pos, len) ({				\
+	typeof(pos) _pos = (pos);					\
+	typeof(len) _len = (len);					\
+	((var) & GENMASK(_pos + _len - 1, _pos)) >> (_pos);		\
+})
+
+#define XLGMAC_GET_REG_BITS_LE(var, pos, len) ({			\
+	typeof(pos) _pos = (pos);					\
+	typeof(len) _len = (len);					\
+	typeof(var) _var = le32_to_cpu((var));				\
+	((_var) & GENMASK(_pos + _len - 1, _pos)) >> (_pos);		\
+})
+
+#define XLGMAC_SET_REG_BITS(var, pos, len, val) ({			\
+	typeof(var) _var = (var);					\
+	typeof(pos) _pos = (pos);					\
+	typeof(len) _len = (len);					\
+	typeof(val) _val = (val);					\
+	_val = (_val << _pos) & GENMASK(_pos + _len - 1, _pos);		\
+	_var = (_var & ~GENMASK(_pos + _len - 1, _pos)) | _val;		\
+})
+
+#define XLGMAC_SET_REG_BITS_LE(var, pos, len, val) ({			\
+	typeof(var) _var = (var);					\
+	typeof(pos) _pos = (pos);					\
+	typeof(len) _len = (len);					\
+	typeof(val) _val = (val);					\
+	_val = (_val << _pos) & GENMASK(_pos + _len - 1, _pos);		\
+	_var = (_var & ~GENMASK(_pos + _len - 1, _pos)) | _val;		\
+	cpu_to_le32(_var);						\
+})
+
+struct xlgmac_pdata;
+
+enum xlgmac_int {
+	XLGMAC_INT_DMA_CH_SR_TI,
+	XLGMAC_INT_DMA_CH_SR_TPS,
+	XLGMAC_INT_DMA_CH_SR_TBU,
+	XLGMAC_INT_DMA_CH_SR_RI,
+	XLGMAC_INT_DMA_CH_SR_RBU,
+	XLGMAC_INT_DMA_CH_SR_RPS,
+	XLGMAC_INT_DMA_CH_SR_TI_RI,
+	XLGMAC_INT_DMA_CH_SR_FBE,
+	XLGMAC_INT_DMA_ALL,
+};
+
+struct xlgmac_stats {
+	/* MMC TX counters */
+	u64 txoctetcount_gb;
+	u64 txframecount_gb;
+	u64 txbroadcastframes_g;
+	u64 txmulticastframes_g;
+	u64 tx64octets_gb;
+	u64 tx65to127octets_gb;
+	u64 tx128to255octets_gb;
+	u64 tx256to511octets_gb;
+	u64 tx512to1023octets_gb;
+	u64 tx1024tomaxoctets_gb;
+	u64 txunicastframes_gb;
+	u64 txmulticastframes_gb;
+	u64 txbroadcastframes_gb;
+	u64 txunderflowerror;
+	u64 txoctetcount_g;
+	u64 txframecount_g;
+	u64 txpauseframes;
+	u64 txvlanframes_g;
+
+	/* MMC RX counters */
+	u64 rxframecount_gb;
+	u64 rxoctetcount_gb;
+	u64 rxoctetcount_g;
+	u64 rxbroadcastframes_g;
+	u64 rxmulticastframes_g;
+	u64 rxcrcerror;
+	u64 rxrunterror;
+	u64 rxjabbererror;
+	u64 rxundersize_g;
+	u64 rxoversize_g;
+	u64 rx64octets_gb;
+	u64 rx65to127octets_gb;
+	u64 rx128to255octets_gb;
+	u64 rx256to511octets_gb;
+	u64 rx512to1023octets_gb;
+	u64 rx1024tomaxoctets_gb;
+	u64 rxunicastframes_g;
+	u64 rxlengtherror;
+	u64 rxoutofrangetype;
+	u64 rxpauseframes;
+	u64 rxfifooverflow;
+	u64 rxvlanframes_gb;
+	u64 rxwatchdogerror;
+
+	/* Extra counters */
+	u64 tx_tso_packets;
+	u64 rx_split_header_packets;
+	u64 rx_buffer_unavailable;
+};
+
+struct xlgmac_ring_buf {
+	struct sk_buff *skb;
+	dma_addr_t skb_dma;
+	unsigned int skb_len;
+};
+
+/* Common Tx and Rx DMA hardware descriptor */
+struct xlgmac_dma_desc {
+	__le32 desc0;
+	__le32 desc1;
+	__le32 desc2;
+	__le32 desc3;
+};
+
+/* Page allocation related values */
+struct xlgmac_page_alloc {
+	struct page *pages;
+	unsigned int pages_len;
+	unsigned int pages_offset;
+
+	dma_addr_t pages_dma;
+};
+
+/* Ring entry buffer data */
+struct xlgmac_buffer_data {
+	struct xlgmac_page_alloc pa;
+	struct xlgmac_page_alloc pa_unmap;
+
+	dma_addr_t dma_base;
+	unsigned long dma_off;
+	unsigned int dma_len;
+};
+
+/* Tx-related desc data */
+struct xlgmac_tx_desc_data {
+	unsigned int packets;		/* BQL packet count */
+	unsigned int bytes;		/* BQL byte count */
+};
+
+/* Rx-related desc data */
+struct xlgmac_rx_desc_data {
+	struct xlgmac_buffer_data hdr;	/* Header locations */
+	struct xlgmac_buffer_data buf;	/* Payload locations */
+
+	unsigned short hdr_len;		/* Length of received header */
+	unsigned short len;		/* Length of received packet */
+};
+
+struct xlgmac_pkt_info {
+	struct sk_buff *skb;
+
+	unsigned int attributes;
+
+	unsigned int errors;
+
+	/* descriptors needed for this packet */
+	unsigned int desc_count;
+	unsigned int length;
+
+	unsigned int tx_packets;
+	unsigned int tx_bytes;
+
+	unsigned int header_len;
+	unsigned int tcp_header_len;
+	unsigned int tcp_payload_len;
+	unsigned short mss;
+
+	unsigned short vlan_ctag;
+
+	u64 rx_tstamp;
+
+	u32 rss_hash;
+	enum pkt_hash_types rss_hash_type;
+};
+
+struct xlgmac_desc_data {
+	/* dma_desc: Virtual address of descriptor
+	 *  dma_desc_addr: DMA address of descriptor
+	 */
+	struct xlgmac_dma_desc *dma_desc;
+	dma_addr_t dma_desc_addr;
+
+	/* skb: Virtual address of SKB
+	 *  skb_dma: DMA address of SKB data
+	 *  skb_dma_len: Length of SKB DMA area
+	 */
+	struct sk_buff *skb;
+	dma_addr_t skb_dma;
+	unsigned int skb_dma_len;
+
+	/* Tx/Rx -related data */
+	struct xlgmac_tx_desc_data tx;
+	struct xlgmac_rx_desc_data rx;
+
+	unsigned int mapped_as_page;
+
+	/* Incomplete receive save location.  If the budget is exhausted
+	 * or the last descriptor (last normal descriptor or a following
+	 * context descriptor) has not been DMA'd yet the current state
+	 * of the receive processing needs to be saved.
+	 */
+	unsigned int state_saved;
+	struct {
+		struct sk_buff *skb;
+		unsigned int len;
+		unsigned int error;
+	} state;
+};
+
+struct xlgmac_ring {
+	/* Per packet related information */
+	struct xlgmac_pkt_info pkt_info;
+
+	/* Virtual/DMA addresses of DMA descriptor list and the total count */
+	struct xlgmac_dma_desc *dma_desc_head;
+	dma_addr_t dma_desc_head_addr;
+	unsigned int dma_desc_count;
+
+	/* Array of descriptor data corresponding the DMA descriptor
+	 * (always use the XLGMAC_GET_DESC_DATA macro to access this data)
+	 */
+	struct xlgmac_desc_data *desc_data_head;
+
+	/* Page allocation for RX buffers */
+	struct xlgmac_page_alloc rx_hdr_pa;
+	struct xlgmac_page_alloc rx_buf_pa;
+
+	/* Ring index values
+	 *  cur   - Tx: index of descriptor to be used for current transfer
+	 *          Rx: index of descriptor to check for packet availability
+	 *  dirty - Tx: index of descriptor to check for transfer complete
+	 *          Rx: index of descriptor to check for buffer reallocation
+	 */
+	unsigned int cur;
+	unsigned int dirty;
+
+	/* Coalesce frame count used for interrupt bit setting */
+	unsigned int coalesce_count;
+
+	union {
+		struct {
+			unsigned int xmit_more;
+			unsigned int queue_stopped;
+			unsigned short cur_mss;
+			unsigned short cur_vlan_ctag;
+		} tx;
+	};
+} ____cacheline_aligned;
+
+struct xlgmac_channel {
+	char name[16];
+
+	/* Address of private data area for device */
+	struct xlgmac_pdata *pdata;
+
+	/* Queue index and base address of queue's DMA registers */
+	unsigned int queue_index;
+	void __iomem *dma_regs;
+
+	/* Per channel interrupt irq number */
+	int dma_irq;
+	char dma_irq_name[IFNAMSIZ + 32];
+
+	/* Netdev related settings */
+	struct napi_struct napi;
+
+	unsigned int saved_ier;
+
+	unsigned int tx_timer_active;
+	struct timer_list tx_timer;
+
+	struct xlgmac_ring *tx_ring;
+	struct xlgmac_ring *rx_ring;
+} ____cacheline_aligned;
+
+struct xlgmac_desc_ops {
+	int (*alloc_channles_and_rings)(struct xlgmac_pdata *pdata);
+	void (*free_channels_and_rings)(struct xlgmac_pdata *pdata);
+	int (*map_tx_skb)(struct xlgmac_channel *channel,
+			  struct sk_buff *skb);
+	int (*map_rx_buffer)(struct xlgmac_pdata *pdata,
+			     struct xlgmac_ring *ring,
+			struct xlgmac_desc_data *desc_data);
+	void (*unmap_desc_data)(struct xlgmac_pdata *pdata,
+				struct xlgmac_desc_data *desc_data);
+	void (*tx_desc_init)(struct xlgmac_pdata *pdata);
+	void (*rx_desc_init)(struct xlgmac_pdata *pdata);
+};
+
+struct xlgmac_hw_ops {
+	int (*init)(struct xlgmac_pdata *pdata);
+	int (*exit)(struct xlgmac_pdata *pdata);
+
+	int (*tx_complete)(struct xlgmac_dma_desc *dma_desc);
+
+	void (*enable_tx)(struct xlgmac_pdata *pdata);
+	void (*disable_tx)(struct xlgmac_pdata *pdata);
+	void (*enable_rx)(struct xlgmac_pdata *pdata);
+	void (*disable_rx)(struct xlgmac_pdata *pdata);
+
+	int (*enable_int)(struct xlgmac_channel *channel,
+			  enum xlgmac_int int_id);
+	int (*disable_int)(struct xlgmac_channel *channel,
+			   enum xlgmac_int int_id);
+	void (*dev_xmit)(struct xlgmac_channel *channel);
+	int (*dev_read)(struct xlgmac_channel *channel);
+
+	int (*set_mac_address)(struct xlgmac_pdata *pdata, u8 *addr);
+	int (*config_rx_mode)(struct xlgmac_pdata *pdata);
+	int (*enable_rx_csum)(struct xlgmac_pdata *pdata);
+	int (*disable_rx_csum)(struct xlgmac_pdata *pdata);
+
+	/* For MII speed configuration */
+	int (*set_xlgmii_25000_speed)(struct xlgmac_pdata *pdata);
+	int (*set_xlgmii_40000_speed)(struct xlgmac_pdata *pdata);
+	int (*set_xlgmii_50000_speed)(struct xlgmac_pdata *pdata);
+	int (*set_xlgmii_100000_speed)(struct xlgmac_pdata *pdata);
+
+	/* For descriptor related operation */
+	void (*tx_desc_init)(struct xlgmac_channel *channel);
+	void (*rx_desc_init)(struct xlgmac_channel *channel);
+	void (*tx_desc_reset)(struct xlgmac_desc_data *desc_data);
+	void (*rx_desc_reset)(struct xlgmac_pdata *pdata,
+			      struct xlgmac_desc_data *desc_data,
+			unsigned int index);
+	int (*is_last_desc)(struct xlgmac_dma_desc *dma_desc);
+	int (*is_context_desc)(struct xlgmac_dma_desc *dma_desc);
+	void (*tx_start_xmit)(struct xlgmac_channel *channel,
+			      struct xlgmac_ring *ring);
+
+	/* For Flow Control */
+	int (*config_tx_flow_control)(struct xlgmac_pdata *pdata);
+	int (*config_rx_flow_control)(struct xlgmac_pdata *pdata);
+
+	/* For Vlan related config */
+	int (*enable_rx_vlan_stripping)(struct xlgmac_pdata *pdata);
+	int (*disable_rx_vlan_stripping)(struct xlgmac_pdata *pdata);
+	int (*enable_rx_vlan_filtering)(struct xlgmac_pdata *pdata);
+	int (*disable_rx_vlan_filtering)(struct xlgmac_pdata *pdata);
+	int (*update_vlan_hash_table)(struct xlgmac_pdata *pdata);
+
+	/* For RX coalescing */
+	int (*config_rx_coalesce)(struct xlgmac_pdata *pdata);
+	int (*config_tx_coalesce)(struct xlgmac_pdata *pdata);
+	unsigned int (*usec_to_riwt)(struct xlgmac_pdata *pdata,
+				     unsigned int usec);
+	unsigned int (*riwt_to_usec)(struct xlgmac_pdata *pdata,
+				     unsigned int riwt);
+
+	/* For RX and TX threshold config */
+	int (*config_rx_threshold)(struct xlgmac_pdata *pdata,
+				   unsigned int val);
+	int (*config_tx_threshold)(struct xlgmac_pdata *pdata,
+				   unsigned int val);
+
+	/* For RX and TX Store and Forward Mode config */
+	int (*config_rsf_mode)(struct xlgmac_pdata *pdata,
+			       unsigned int val);
+	int (*config_tsf_mode)(struct xlgmac_pdata *pdata,
+			       unsigned int val);
+
+	/* For TX DMA Operate on Second Frame config */
+	int (*config_osp_mode)(struct xlgmac_pdata *pdata);
+
+	/* For RX and TX PBL config */
+	int (*config_rx_pbl_val)(struct xlgmac_pdata *pdata);
+	int (*get_rx_pbl_val)(struct xlgmac_pdata *pdata);
+	int (*config_tx_pbl_val)(struct xlgmac_pdata *pdata);
+	int (*get_tx_pbl_val)(struct xlgmac_pdata *pdata);
+	int (*config_pblx8)(struct xlgmac_pdata *pdata);
+
+	/* For MMC statistics */
+	void (*rx_mmc_int)(struct xlgmac_pdata *pdata);
+	void (*tx_mmc_int)(struct xlgmac_pdata *pdata);
+	void (*read_mmc_stats)(struct xlgmac_pdata *pdata);
+
+	/* For Receive Side Scaling */
+	int (*enable_rss)(struct xlgmac_pdata *pdata);
+	int (*disable_rss)(struct xlgmac_pdata *pdata);
+	int (*set_rss_hash_key)(struct xlgmac_pdata *pdata,
+				const u8 *key);
+	int (*set_rss_lookup_table)(struct xlgmac_pdata *pdata,
+				    const u32 *table);
+};
+
+/* This structure contains flags that indicate what hardware features
+ * or configurations are present in the device.
+ */
+struct xlgmac_hw_features {
+	/* HW Version */
+	unsigned int version;
+
+	/* HW Feature Register0 */
+	unsigned int phyifsel;		/* PHY interface support */
+	unsigned int vlhash;		/* VLAN Hash Filter */
+	unsigned int sma;		/* SMA(MDIO) Interface */
+	unsigned int rwk;		/* PMT remote wake-up packet */
+	unsigned int mgk;		/* PMT magic packet */
+	unsigned int mmc;		/* RMON module */
+	unsigned int aoe;		/* ARP Offload */
+	unsigned int ts;		/* IEEE 1588-2008 Advanced Timestamp */
+	unsigned int eee;		/* Energy Efficient Ethernet */
+	unsigned int tx_coe;		/* Tx Checksum Offload */
+	unsigned int rx_coe;		/* Rx Checksum Offload */
+	unsigned int addn_mac;		/* Additional MAC Addresses */
+	unsigned int ts_src;		/* Timestamp Source */
+	unsigned int sa_vlan_ins;	/* Source Address or VLAN Insertion */
+
+	/* HW Feature Register1 */
+	unsigned int rx_fifo_size;	/* MTL Receive FIFO Size */
+	unsigned int tx_fifo_size;	/* MTL Transmit FIFO Size */
+	unsigned int adv_ts_hi;		/* Advance Timestamping High Word */
+	unsigned int dma_width;		/* DMA width */
+	unsigned int dcb;		/* DCB Feature */
+	unsigned int sph;		/* Split Header Feature */
+	unsigned int tso;		/* TCP Segmentation Offload */
+	unsigned int dma_debug;		/* DMA Debug Registers */
+	unsigned int rss;		/* Receive Side Scaling */
+	unsigned int tc_cnt;		/* Number of Traffic Classes */
+	unsigned int hash_table_size;	/* Hash Table Size */
+	unsigned int l3l4_filter_num;	/* Number of L3-L4 Filters */
+
+	/* HW Feature Register2 */
+	unsigned int rx_q_cnt;		/* Number of MTL Receive Queues */
+	unsigned int tx_q_cnt;		/* Number of MTL Transmit Queues */
+	unsigned int rx_ch_cnt;		/* Number of DMA Receive Channels */
+	unsigned int tx_ch_cnt;		/* Number of DMA Transmit Channels */
+	unsigned int pps_out_num;	/* Number of PPS outputs */
+	unsigned int aux_snap_num;	/* Number of Aux snapshot inputs */
+};
+
+struct xlgmac_resources {
+	void __iomem *addr;
+	int irq;
+};
+
+struct xlgmac_pdata {
+	struct net_device *netdev;
+	struct device *dev;
+
+	struct xlgmac_hw_ops hw_ops;
+	struct xlgmac_desc_ops desc_ops;
+
+	/* Device statistics */
+	struct xlgmac_stats stats;
+
+	u32 msg_enable;
+
+	/* MAC registers base */
+	void __iomem *mac_regs;
+
+	/* Hardware features of the device */
+	struct xlgmac_hw_features hw_feat;
+
+	struct work_struct restart_work;
+
+	/* Rings for Tx/Rx on a DMA channel */
+	struct xlgmac_channel *channel_head;
+	unsigned int channel_count;
+	unsigned int tx_ring_count;
+	unsigned int rx_ring_count;
+	unsigned int tx_desc_count;
+	unsigned int rx_desc_count;
+	unsigned int tx_q_count;
+	unsigned int rx_q_count;
+
+	/* Tx/Rx common settings */
+	unsigned int pblx8;
+
+	/* Tx settings */
+	unsigned int tx_sf_mode;
+	unsigned int tx_threshold;
+	unsigned int tx_pbl;
+	unsigned int tx_osp_mode;
+
+	/* Rx settings */
+	unsigned int rx_sf_mode;
+	unsigned int rx_threshold;
+	unsigned int rx_pbl;
+
+	/* Tx coalescing settings */
+	unsigned int tx_usecs;
+	unsigned int tx_frames;
+
+	/* Rx coalescing settings */
+	unsigned int rx_riwt;
+	unsigned int rx_usecs;
+	unsigned int rx_frames;
+
+	/* Current Rx buffer size */
+	unsigned int rx_buf_size;
+
+	/* Flow control settings */
+	unsigned int tx_pause;
+	unsigned int rx_pause;
+
+	/* Device interrupt number */
+	int dev_irq;
+	unsigned int per_channel_irq;
+	int channel_irq[XLGMAC_MAX_DMA_CHANNELS];
+
+	/* Netdev related settings */
+	unsigned char mac_addr[ETH_ALEN];
+	netdev_features_t netdev_features;
+	struct napi_struct napi;
+
+	/* Filtering support */
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+
+	/* Device clocks */
+	unsigned long sysclk_rate;
+
+	/* RSS addressing mutex */
+	struct mutex rss_mutex;
+
+	/* Receive Side Scaling settings */
+	u8 rss_key[XLGMAC_RSS_HASH_KEY_SIZE];
+	u32 rss_table[XLGMAC_RSS_MAX_TABLE_SIZE];
+	u32 rss_options;
+
+	int phy_speed;
+
+	char drv_name[32];
+	char drv_ver[32];
+};
+
+void xlgmac_init_desc_ops(struct xlgmac_desc_ops *desc_ops);
+void xlgmac_init_hw_ops(struct xlgmac_hw_ops *hw_ops);
+const struct net_device_ops *xlgmac_get_netdev_ops(void);
+void xlgmac_dump_tx_desc(struct xlgmac_pdata *pdata,
+			 struct xlgmac_ring *ring,
+			 unsigned int idx,
+			 unsigned int count,
+			 unsigned int flag);
+void xlgmac_dump_rx_desc(struct xlgmac_pdata *pdata,
+			 struct xlgmac_ring *ring,
+			 unsigned int idx);
+void xlgmac_print_pkt(struct net_device *netdev,
+		      struct sk_buff *skb, bool tx_rx);
+void xlgmac_get_all_hw_features(struct xlgmac_pdata *pdata);
+void xlgmac_print_all_hw_features(struct xlgmac_pdata *pdata);
+int xlgmac_drv_probe(struct device *dev,
+		     struct xlgmac_resources *res);
+int xlgmac_drv_remove(struct device *dev);
+
+/* For debug prints */
+#ifdef XLGMAC_DEBUG
+#define XLGMAC_PR(fmt, args...) \
+	pr_alert("[%s,%d]:" fmt, __func__, __LINE__, ## args)
+#else
+#define XLGMAC_PR(x...)		do { } while (0)
+#endif
+
+#endif /* __DWC_XLGMAC_H__ */
-- 
1.9.1
