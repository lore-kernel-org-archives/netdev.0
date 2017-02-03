From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 4/8] net: ethernet: add the Alpine Ethernet driver
Date: Fri,  3 Feb 2017 19:12:12 +0100
Message-ID: <20170203181216.30214-5-antoine.tenart@free-electrons.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        tsahee@annapurnalabs.com, rshitrit@annapurnalabs.com,
        saeed@annapurnalabs.com, barak@annapurnalabs.com,
        talz@annapurnalabs.com, thomas.petazzoni@free-electrons.com,
        arnd@arndb.de
To: netdev@vger.kernel.org, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36517 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdBCSPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:15:22 -0500
In-Reply-To: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a driver for the so called Annapurna Labs unified
Ethernet adapter. These Ethernet adapters are exposed as integrated
PCIe endpoints.

The Ethernet unit is connected to the I/O Fabric and thus iofic and UDMA
blocks are exposed in PCIe BARs. This driver makes use of the Alpine
iofic and UDMA helpers.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/annapurna/Kconfig             |   29 +
 drivers/net/ethernet/annapurna/Makefile            |    6 +
 drivers/net/ethernet/annapurna/al_eth.c            | 3062 ++++++++++++++++++++
 drivers/net/ethernet/annapurna/al_eth.h            |  282 ++
 drivers/net/ethernet/annapurna/al_hw_eth.h         | 1264 ++++++++
 drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h | 1088 +++++++
 .../net/ethernet/annapurna/al_hw_eth_mac_regs.h    |  727 +++++
 drivers/net/ethernet/annapurna/al_hw_eth_main.c    | 3050 +++++++++++++++++++
 .../ethernet/annapurna/al_hw_unit_adapter_regs.h   |   24 +
 11 files changed, 9534 insertions(+)
 create mode 100644 drivers/net/ethernet/annapurna/Kconfig
 create mode 100644 drivers/net/ethernet/annapurna/Makefile
 create mode 100644 drivers/net/ethernet/annapurna/al_eth.c
 create mode 100644 drivers/net/ethernet/annapurna/al_eth.h
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_eth.h
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_eth_main.c
 create mode 100644 drivers/net/ethernet/annapurna/al_hw_unit_adapter_regs.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 8c08f9deef92..0b43efaf1638 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -27,6 +27,7 @@ source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/altera/Kconfig"
 source "drivers/net/ethernet/amazon/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
+source "drivers/net/ethernet/annapurna/Kconfig"
 source "drivers/net/ethernet/apm/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/aquantia/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 26dce5bf2c18..46cfeccdd3d8 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -13,6 +13,7 @@ obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_ALTERA_TSE) += altera/
 obj-$(CONFIG_NET_VENDOR_AMAZON) += amazon/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
+obj-$(CONFIG_NET_VENDOR_ALPINE) += annapurna/
 obj-$(CONFIG_NET_XGENE) += apm/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_AQUANTIA) += aquantia/
diff --git a/drivers/net/ethernet/annapurna/Kconfig b/drivers/net/ethernet/annapurna/Kconfig
new file mode 100644
index 000000000000..408e850024b2
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/Kconfig
@@ -0,0 +1,29 @@
+#
+# Annapurna Labs driver configuration
+#
+
+config NET_VENDOR_ALPINE
+	bool "Annapurna Labs devices"
+
+if NET_VENDOR_ALPINE
+
+config NET_AL_ETH
+	tristate "Annapurna Labs unified 1G/10G Ethernet driver"
+	depends on PCI && INET
+	depends on ALPINE_UDMA
+	select PHYLIB
+	help
+	  This is the driver supports both standard and advanced Annapurna Labs
+	  1G and 10G Ethernet controllers.
+
+if NET_AL_ETH
+
+config NET_AL_ETH_NO_MSIX
+	bool "Disable MSI-X"
+	help
+	  Do not use the MSI-X feature in the Annapurna Labs unified
+	  1G/10G Ethernet driver.
+
+endif
+
+endif
diff --git a/drivers/net/ethernet/annapurna/Makefile b/drivers/net/ethernet/annapurna/Makefile
new file mode 100644
index 000000000000..fa361ecb2734
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Annapurna network device drivers.
+#
+
+obj-$(CONFIG_NET_AL_ETH)	+= al_eth_drv.o
+al_eth_drv-objs			+= al_eth.o al_hw_eth_main.o
diff --git a/drivers/net/ethernet/annapurna/al_eth.c b/drivers/net/ethernet/annapurna/al_eth.c
new file mode 100644
index 000000000000..779a885de014
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/al_eth.c
@@ -0,0 +1,3062 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+
+#include <linux/stringify.h>
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/timer.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/init.h>
+#include <linux/mdio.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/dma-mapping.h>
+#include <linux/delay.h>
+#include <linux/time.h>
+#include <linux/ethtool.h>
+#include <linux/if.h>
+#include <linux/if_vlan.h>
+#include <linux/cpu_rmap.h>
+#include <net/ip.h>
+#include <net/tcp.h>
+#include <net/checksum.h>
+#include <linux/prefetch.h>
+#include <linux/cache.h>
+#include <linux/i2c.h>
+#include <linux/soc/alpine/iofic.h>
+#include <linux/soc/alpine/al_hw_udma_iofic.h>
+#include <linux/soc/alpine/al_hw_udma_config.h>
+
+#include "al_hw_eth.h"
+#include "al_eth.h"
+
+#define DRV_MODULE_NAME		"al_eth"
+
+MODULE_AUTHOR("Saeed Bishara <saeed@annapurnaLabs.com>");
+MODULE_DESCRIPTION("AnnapurnaLabs unified 1GbE and 10GbE Ethernet driver");
+MODULE_LICENSE("GPL");
+
+/* Time in jiffies before concluding the transmitter is hung. */
+#define TX_TIMEOUT  (5 * HZ)
+
+/* Time in mSec to keep trying to read / write from MDIO in case of error */
+#define MDIO_TIMEOUT_MSEC	100
+
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
+
+/* indexed by board_t */
+static struct {
+	char *name;
+	unsigned int bar; /* needed for NIC mode */
+} board_info[] = {
+	{
+		.name = "AnnapurnaLabs unified 1Gbe/10Gbe",
+	},
+	{
+		.name = "AnnapurnaLabs unified 1Gbe/10Gbe pcie NIC",
+		.bar = 5,
+	},
+};
+
+#define PCI_DEVICE_ID_AL_ETH		0x1
+#define PCI_DEVICE_ID_AL_ETH_ADVANCED	0x2
+#define PCI_DEVICE_ID_AL_ETH_NIC	0x3
+
+static const struct pci_device_id al_eth_pci_tbl[] = {
+	{ PCI_VENDOR_ID_ANNAPURNA_LABS, PCI_DEVICE_ID_AL_ETH,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, ALPINE_INTEGRATED },
+	{ PCI_VENDOR_ID_ANNAPURNA_LABS, PCI_DEVICE_ID_AL_ETH_ADVANCED,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, ALPINE_INTEGRATED },
+	{ PCI_VENDOR_ID_ANNAPURNA_LABS, PCI_DEVICE_ID_AL_ETH_NIC,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, ALPINE_NIC },
+	{ }
+};
+MODULE_DEVICE_TABLE(pci, al_eth_pci_tbl);
+
+/* MDIO */
+#define AL_ETH_MDIO_C45_DEV_MASK	0x1f0000
+#define AL_ETH_MDIO_C45_DEV_SHIFT	16
+#define AL_ETH_MDIO_C45_REG_MASK	0xffff
+
+static int al_mdio_read(struct mii_bus *bp, int mii_id, int reg)
+{
+	struct al_eth_adapter *adapter = bp->priv;
+	u16 value = 0;
+	int rc;
+	int timeout = MDIO_TIMEOUT_MSEC;
+
+	while (timeout > 0) {
+		if (reg & MII_ADDR_C45) {
+			netdev_dbg(adapter->netdev, "[c45]: dev %x reg %x val %x\n",
+				   ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH_MDIO_C45_DEV_SHIFT),
+				   (reg & AL_ETH_MDIO_C45_REG_MASK), value);
+			rc = al_eth_mdio_read(&adapter->hw_adapter, adapter->phy_addr,
+				((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH_MDIO_C45_DEV_SHIFT),
+				(reg & AL_ETH_MDIO_C45_REG_MASK), &value);
+		} else {
+			rc = al_eth_mdio_read(&adapter->hw_adapter, adapter->phy_addr,
+					      MDIO_DEVAD_NONE, reg, &value);
+		}
+
+		if (rc == 0)
+			return value;
+
+		netdev_dbg(adapter->netdev,
+			   "mdio read failed. try again in 10 msec\n");
+
+		timeout -= 10;
+		msleep(10);
+	}
+
+	if (rc)
+		netdev_err(adapter->netdev, "MDIO read failed on timeout\n");
+
+	return value;
+}
+
+static int al_mdio_write(struct mii_bus *bp, int mii_id, int reg, u16 val)
+{
+	struct al_eth_adapter *adapter = bp->priv;
+	int rc;
+	int timeout = MDIO_TIMEOUT_MSEC;
+
+	while (timeout > 0) {
+		if (reg & MII_ADDR_C45) {
+			netdev_dbg(adapter->netdev, "[c45]: device %x reg %x val %x\n",
+				   ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH_MDIO_C45_DEV_SHIFT),
+				   (reg & AL_ETH_MDIO_C45_REG_MASK), val);
+			rc = al_eth_mdio_write(&adapter->hw_adapter,
+					       adapter->phy_addr,
+					       ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH_MDIO_C45_DEV_SHIFT),
+					       (reg & AL_ETH_MDIO_C45_REG_MASK),
+					       val);
+		} else {
+			rc = al_eth_mdio_write(&adapter->hw_adapter,
+					       adapter->phy_addr,
+					       MDIO_DEVAD_NONE, reg, val);
+		}
+
+		if (rc == 0)
+			return 0;
+
+		netdev_err(adapter->netdev,
+			   "mdio write failed. try again in 10 msec\n");
+
+		timeout -= 10;
+		msleep(10);
+	}
+
+	if (rc)
+		netdev_err(adapter->netdev, "MDIO write failed on timeout\n");
+
+	return rc;
+}
+
+static int al_eth_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct mii_ioctl_data *mdio = if_mii(ifr);
+	struct phy_device *phydev;
+
+	netdev_info(adapter->netdev, "ioctl: phy id 0x%x, reg 0x%x, val_in 0x%x\n",
+		    mdio->phy_id, mdio->reg_num, mdio->val_in);
+
+	if (adapter->mdio_bus) {
+		phydev = mdiobus_get_phy(adapter->mdio_bus, adapter->phy_addr);
+		if (phydev)
+			return phy_mii_ioctl(phydev, ifr, cmd);
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static int al_eth_flow_ctrl_config(struct al_eth_adapter *adapter);
+static u8 al_eth_flow_ctrl_mutual_cap_get(struct al_eth_adapter *adapter);
+static void al_eth_down(struct al_eth_adapter *adapter);
+static int al_eth_up(struct al_eth_adapter *adapter);
+
+static void al_eth_adjust_link(struct net_device *dev)
+{
+	struct al_eth_adapter *adapter = netdev_priv(dev);
+	struct al_eth_link_config *link_config = &adapter->link_config;
+	struct phy_device *phydev = adapter->phydev;
+	enum al_eth_mac_mode mac_mode_needed = AL_ETH_MAC_MODE_RGMII;
+	int new_state = 0;
+	bool force_1000_base_x = false;
+
+	if (phydev->link) {
+		if (phydev->duplex != link_config->active_duplex) {
+			new_state = 1;
+			link_config->active_duplex = phydev->duplex;
+		}
+
+		if (phydev->speed != link_config->active_speed) {
+			new_state = 1;
+			switch (phydev->speed) {
+			case SPEED_1000:
+			case SPEED_100:
+			case SPEED_10:
+				mac_mode_needed = (adapter->mac_mode == AL_ETH_MAC_MODE_RGMII) ?
+					AL_ETH_MAC_MODE_RGMII : AL_ETH_MAC_MODE_SGMII;
+				break;
+			case SPEED_10000:
+			case SPEED_2500:
+				mac_mode_needed = AL_ETH_MAC_MODE_10GbE_Serial;
+				break;
+			default:
+				if (netif_msg_link(adapter))
+					netdev_warn(adapter->netdev,
+						    "Ack!  Speed (%d) is not 10/100/1000!",
+						    phydev->speed);
+				break;
+			}
+			link_config->active_speed = phydev->speed;
+		}
+
+		if (!link_config->old_link) {
+			new_state = 1;
+			link_config->old_link = 1;
+		}
+
+		if (new_state) {
+			int rc;
+
+			if (adapter->mac_mode != mac_mode_needed) {
+				al_eth_down(adapter);
+				adapter->mac_mode = mac_mode_needed;
+				if (link_config->active_speed <= 1000)
+					force_1000_base_x = true;
+				al_eth_up(adapter);
+			}
+
+			if (adapter->mac_mode != AL_ETH_MAC_MODE_10GbE_Serial) {
+				/* change the MAC link configuration */
+				rc = al_eth_mac_link_config(&adapter->hw_adapter,
+							    force_1000_base_x,
+							    link_config->autoneg,
+							    link_config->active_speed,
+							    link_config->active_duplex
+							    ? true : false);
+				if (rc)
+					netdev_warn(adapter->netdev,
+						    "Failed to config the mac with the new link settings!");
+			}
+		}
+
+		if (link_config->flow_ctrl_supported & AL_ETH_FLOW_CTRL_AUTONEG) {
+			u8 new_flow_ctrl =
+				al_eth_flow_ctrl_mutual_cap_get(adapter);
+
+			if (new_flow_ctrl != link_config->flow_ctrl_active) {
+				link_config->flow_ctrl_active = new_flow_ctrl;
+				al_eth_flow_ctrl_config(adapter);
+			}
+		}
+	} else if (adapter->link_config.old_link) {
+		new_state = 1;
+		link_config->old_link = 0;
+		link_config->active_duplex = DUPLEX_UNKNOWN;
+		link_config->active_speed = SPEED_UNKNOWN;
+	}
+
+	if (new_state && netif_msg_link(adapter))
+		phy_print_status(phydev);
+}
+
+static int al_eth_phy_init(struct al_eth_adapter *adapter)
+{
+	struct phy_device *phydev = mdiobus_get_phy(adapter->mdio_bus, adapter->phy_addr);
+
+	adapter->link_config.old_link = 0;
+	adapter->link_config.active_duplex = DUPLEX_UNKNOWN;
+	adapter->link_config.active_speed = SPEED_UNKNOWN;
+
+	/* Attach the MAC to the PHY. */
+	phydev = phy_connect(adapter->netdev, dev_name(&phydev->mdio.dev), al_eth_adjust_link,
+			     PHY_INTERFACE_MODE_RGMII);
+	if (IS_ERR(phydev)) {
+		netdev_err(adapter->netdev, "Could not attach to PHY\n");
+		return PTR_ERR(phydev);
+	}
+
+	netdev_info(adapter->netdev, "phy[%d]: device %s, driver %s\n",
+		    phydev->mdio.addr, dev_name(&phydev->mdio.dev),
+		    phydev->drv ? phydev->drv->name : "unknown");
+
+	/* Mask with MAC supported features. */
+	phydev->supported &= (PHY_GBIT_FEATURES |
+				SUPPORTED_Pause |
+				SUPPORTED_Asym_Pause);
+
+	phydev->advertising = phydev->supported;
+
+	netdev_info(adapter->netdev, "phy[%d]:supported %x adv %x\n",
+		    phydev->mdio.addr, phydev->supported, phydev->advertising);
+
+	adapter->phydev = phydev;
+	/* Bring the PHY up */
+	phy_start(adapter->phydev);
+
+	return 0;
+}
+
+/* al_eth_mdiobus_setup - initialize mdiobus and register to kernel */
+static int al_eth_mdiobus_setup(struct al_eth_adapter *adapter)
+{
+	struct phy_device *phydev;
+	int i;
+	int ret = 0;
+
+	adapter->mdio_bus = mdiobus_alloc();
+	if (!adapter->mdio_bus)
+		return -ENOMEM;
+
+	adapter->mdio_bus->name     = "al mdio bus";
+	snprintf(adapter->mdio_bus->id, MII_BUS_ID_SIZE, "%x",
+		 (adapter->pdev->bus->number << 8) | adapter->pdev->devfn);
+	adapter->mdio_bus->priv     = adapter;
+	adapter->mdio_bus->parent   = &adapter->pdev->dev;
+	adapter->mdio_bus->read     = &al_mdio_read;
+	adapter->mdio_bus->write    = &al_mdio_write;
+	adapter->mdio_bus->phy_mask = ~BIT(adapter->phy_addr);
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		adapter->mdio_bus->irq[i] = PHY_POLL;
+
+	if (adapter->phy_if != AL_ETH_BOARD_PHY_IF_XMDIO) {
+		i = mdiobus_register(adapter->mdio_bus);
+		if (i) {
+			netdev_warn(adapter->netdev,
+				    "mdiobus_reg failed (0x%x)\n", i);
+			mdiobus_free(adapter->mdio_bus);
+			return i;
+		}
+
+		phydev = mdiobus_get_phy(adapter->mdio_bus, adapter->phy_addr);
+	} else {
+		adapter->mdio_bus->phy_mask = 0xffffffff;
+		i = mdiobus_register(adapter->mdio_bus);
+		if (i) {
+			netdev_warn(adapter->netdev,
+				    "mdiobus_reg failed (0x%x)\n", i);
+			mdiobus_free(adapter->mdio_bus);
+			return i;
+		}
+
+		phydev = get_phy_device(adapter->mdio_bus, adapter->phy_addr,
+					true);
+		if (!phydev) {
+			netdev_err(adapter->netdev, "phy device get failed\n");
+			goto error;
+		}
+
+		ret = phy_device_register(phydev);
+		if (ret) {
+			netdev_err(adapter->netdev,
+				   "phy device register failed\n");
+			goto error;
+		}
+	}
+
+	if (!phydev || !phydev->drv)
+		goto error;
+
+	return 0;
+
+error:
+	netdev_warn(adapter->netdev, "No PHY devices\n");
+	mdiobus_unregister(adapter->mdio_bus);
+	mdiobus_free(adapter->mdio_bus);
+	return -ENODEV;
+}
+
+/* al_eth_mdiobus_teardown - mdiobus unregister */
+static void al_eth_mdiobus_teardown(struct al_eth_adapter *adapter)
+{
+	if (!adapter->mdio_bus)
+		return;
+
+	mdiobus_unregister(adapter->mdio_bus);
+	mdiobus_free(adapter->mdio_bus);
+	phy_device_free(adapter->phydev);
+}
+
+static void al_eth_tx_timeout(struct net_device *dev)
+{
+	struct al_eth_adapter *adapter = netdev_priv(dev);
+
+	if (netif_msg_tx_err(adapter))
+		netdev_err(dev, "transmit timed out!!!!\n");
+}
+
+static int al_eth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct al_eth_adapter *adapter = netdev_priv(dev);
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+
+	if ((new_mtu < AL_ETH_MIN_FRAME_LEN) || (new_mtu > AL_ETH_MAX_MTU) ||
+	    (max_frame > AL_ETH_MAX_FRAME_LEN)) {
+		netdev_err(dev, "Invalid MTU setting\n");
+		return -EINVAL;
+	}
+
+	netdev_dbg(adapter->netdev, "set MTU to %d\n", new_mtu);
+	al_eth_rx_pkt_limit_config(&adapter->hw_adapter,
+				   AL_ETH_MIN_FRAME_LEN, max_frame);
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+int al_eth_read_pci_config(void *handle, int where, u32 *val)
+{
+	/* handle is a pointer to the pci_dev */
+	pci_read_config_dword((struct pci_dev *)handle, where, val);
+	return 0;
+}
+
+int al_eth_write_pci_config(void *handle, int where, u32 val)
+{
+	/* handle is a pointer to the pci_dev */
+	pci_write_config_dword((struct pci_dev *)handle, where, val);
+	return 0;
+}
+
+static int al_eth_function_reset(struct al_eth_adapter *adapter)
+{
+	struct al_eth_board_params params;
+	int rc;
+
+	/* save board params so we restore it after reset */
+	al_eth_board_params_get(adapter->mac_base, &params);
+	al_eth_mac_addr_read(adapter->ec_base, 0, adapter->mac_addr);
+	rc = al_eth_flr_rmn(&al_eth_read_pci_config,
+			    &al_eth_write_pci_config,
+			    adapter->pdev, adapter->mac_base);
+
+	/* restore params */
+	al_eth_board_params_set(adapter->mac_base, &params);
+	al_eth_mac_addr_store(adapter->ec_base, 0, adapter->mac_addr);
+	return rc;
+}
+
+static void al_eth_setup_int_mode(struct al_eth_adapter *adapter, int dis_msi);
+static int al_eth_board_params_init(struct al_eth_adapter *adapter)
+{
+		struct al_eth_board_params params;
+		int rc;
+
+		rc = al_eth_board_params_get(adapter->mac_base, &params);
+		if (rc) {
+			dev_err(&adapter->pdev->dev, "board info not available\n");
+			return -1;
+		}
+
+		adapter->phy_exist = !!params.phy_exist;
+		adapter->phy_addr = params.phy_mdio_addr;
+		adapter->an_en = params.autoneg_enable;
+		adapter->lt_en = params.kr_lt_enable;
+		adapter->sfp_detection_needed = params.sfp_plus_module_exist;
+		adapter->i2c_adapter_id = params.i2c_adapter_id;
+		adapter->ref_clk_freq = params.ref_clk_freq;
+		adapter->link_config.active_duplex = !params.half_duplex;
+		adapter->link_config.autoneg = (adapter->phy_exist) ?
+						(params.an_mode == AL_ETH_BOARD_AUTONEG_IN_BAND) :
+						(!params.an_disable);
+		adapter->link_config.force_1000_base_x = params.force_1000_base_x;
+		adapter->retimer.exist = params.retimer_exist;
+		adapter->retimer.type = params.retimer_type;
+		adapter->retimer.bus_id = params.retimer_bus_id;
+		adapter->retimer.i2c_addr = params.retimer_i2c_addr;
+		adapter->retimer.channel = params.retimer_channel;
+		adapter->retimer.tx_channel = params.retimer_tx_channel;
+		adapter->phy_if = params.phy_if;
+
+		switch (params.speed) {
+		default:
+			dev_warn(&adapter->pdev->dev,
+				 "invalid speed (%d)\n", params.speed);
+		case AL_ETH_BOARD_1G_SPEED_1000M:
+			adapter->link_config.active_speed = 1000;
+			break;
+		case AL_ETH_BOARD_1G_SPEED_100M:
+			adapter->link_config.active_speed = 100;
+			break;
+		case AL_ETH_BOARD_1G_SPEED_10M:
+			adapter->link_config.active_speed = 10;
+			break;
+		}
+
+		switch (params.mdio_freq) {
+		default:
+			dev_warn(&adapter->pdev->dev,
+				 "invalid mdio freq (%d)\n", params.mdio_freq);
+		case AL_ETH_BOARD_MDIO_FREQ_2_5_MHZ:
+			adapter->mdio_freq = 2500;
+			break;
+		case AL_ETH_BOARD_MDIO_FREQ_1_MHZ:
+			adapter->mdio_freq = 1000;
+			break;
+		}
+
+		switch (params.media_type) {
+		case AL_ETH_BOARD_MEDIA_TYPE_RGMII:
+			if (params.sfp_plus_module_exist)
+				/* Backward compatibility */
+				adapter->mac_mode = AL_ETH_MAC_MODE_SGMII;
+			else
+				adapter->mac_mode = AL_ETH_MAC_MODE_RGMII;
+
+			break;
+		case AL_ETH_BOARD_MEDIA_TYPE_SGMII:
+			adapter->mac_mode = AL_ETH_MAC_MODE_SGMII;
+			break;
+		case AL_ETH_BOARD_MEDIA_TYPE_SGMII_2_5G:
+			adapter->mac_mode = AL_ETH_MAC_MODE_SGMII_2_5G;
+			break;
+		case AL_ETH_BOARD_MEDIA_TYPE_10GBASE_SR:
+			adapter->mac_mode = AL_ETH_MAC_MODE_10GbE_Serial;
+			break;
+		case AL_ETH_BOARD_MEDIA_TYPE_AUTO_DETECT:
+			adapter->sfp_detection_needed = true;
+			break;
+		case AL_ETH_BOARD_MEDIA_TYPE_AUTO_DETECT_AUTO_SPEED:
+			adapter->sfp_detection_needed = true;
+			break;
+		case AL_ETH_BOARD_MEDIA_TYPE_NBASE_T:
+			adapter->mac_mode = AL_ETH_MAC_MODE_10GbE_Serial;
+			break;
+		case AL_ETH_BOARD_MEDIA_TYPE_25G:
+			adapter->sfp_detection_needed = true;
+			break;
+		default:
+			dev_err(&adapter->pdev->dev,
+				"unsupported media type %d\n",
+				params.media_type);
+			return -1;
+		}
+		dev_info(&adapter->pdev->dev,
+			 "Board info: phy exist %s. phy addr %d. mdio freq %u Khz. SFP connected %s. media %d\n",
+			params.phy_exist ? "Yes" : "No",
+			params.phy_mdio_addr,
+			adapter->mdio_freq,
+			params.sfp_plus_module_exist ? "Yes" : "No",
+			params.media_type);
+
+	al_eth_mac_addr_read(adapter->ec_base, 0, adapter->mac_addr);
+
+	return 0;
+}
+
+static inline void al_eth_flow_ctrl_init(struct al_eth_adapter *adapter)
+{
+	u8 default_flow_ctrl;
+
+	default_flow_ctrl = AL_ETH_FLOW_CTRL_TX_PAUSE;
+	default_flow_ctrl |= AL_ETH_FLOW_CTRL_RX_PAUSE;
+
+	adapter->link_config.flow_ctrl_supported = default_flow_ctrl;
+}
+
+static u8 al_eth_flow_ctrl_mutual_cap_get(struct al_eth_adapter *adapter)
+{
+	struct phy_device *phydev = mdiobus_get_phy(adapter->mdio_bus, adapter->phy_addr);
+	struct al_eth_link_config *link_config = &adapter->link_config;
+	u8 peer_flow_ctrl = AL_ETH_FLOW_CTRL_AUTONEG;
+	u8 new_flow_ctrl = AL_ETH_FLOW_CTRL_AUTONEG;
+
+	if (phydev->pause)
+		peer_flow_ctrl |= (AL_ETH_FLOW_CTRL_TX_PAUSE |
+				  AL_ETH_FLOW_CTRL_RX_PAUSE);
+	if (phydev->asym_pause)
+		peer_flow_ctrl ^= (AL_ETH_FLOW_CTRL_RX_PAUSE);
+
+	/*
+	 * in autoneg mode, supported flow ctrl is also
+	 * the current advertising
+	 */
+	if ((peer_flow_ctrl & AL_ETH_FLOW_CTRL_TX_PAUSE) ==
+	    (link_config->flow_ctrl_supported & AL_ETH_FLOW_CTRL_TX_PAUSE))
+		new_flow_ctrl |= AL_ETH_FLOW_CTRL_TX_PAUSE;
+	if ((peer_flow_ctrl & AL_ETH_FLOW_CTRL_RX_PAUSE) ==
+	    (link_config->flow_ctrl_supported & AL_ETH_FLOW_CTRL_RX_PAUSE))
+		new_flow_ctrl |= AL_ETH_FLOW_CTRL_RX_PAUSE;
+
+	return new_flow_ctrl;
+}
+
+static int al_eth_flow_ctrl_config(struct al_eth_adapter *adapter)
+{
+	struct al_eth_flow_control_params *flow_ctrl_params;
+	u8 active = adapter->link_config.flow_ctrl_active;
+	int i;
+
+	flow_ctrl_params = &adapter->flow_ctrl_params;
+
+	flow_ctrl_params->type = AL_ETH_FLOW_CONTROL_TYPE_LINK_PAUSE;
+	flow_ctrl_params->obay_enable =
+		((active & AL_ETH_FLOW_CTRL_RX_PAUSE) != 0);
+	flow_ctrl_params->gen_enable =
+		((active & AL_ETH_FLOW_CTRL_TX_PAUSE) != 0);
+
+	flow_ctrl_params->rx_fifo_th_high = AL_ETH_FLOW_CTRL_RX_FIFO_TH_HIGH;
+	flow_ctrl_params->rx_fifo_th_low = AL_ETH_FLOW_CTRL_RX_FIFO_TH_LOW;
+	flow_ctrl_params->quanta = AL_ETH_FLOW_CTRL_QUANTA;
+	flow_ctrl_params->quanta_th = AL_ETH_FLOW_CTRL_QUANTA_TH;
+
+	/* map priority to queue index, queue id = priority/2 */
+	for (i = 0; i < AL_ETH_FWD_PRIO_TABLE_NUM; i++)
+		flow_ctrl_params->prio_q_map[0][i] =  BIT((i >> 1));
+
+	al_eth_flow_control_config(&adapter->hw_adapter, flow_ctrl_params);
+
+	return 0;
+}
+
+static void al_eth_flow_ctrl_enable(struct al_eth_adapter *adapter)
+{
+	/*
+	 * change the active configuration to the default / force by ethtool
+	 * and call to configure
+	 */
+	adapter->link_config.flow_ctrl_active =
+				adapter->link_config.flow_ctrl_supported;
+
+	al_eth_flow_ctrl_config(adapter);
+}
+
+static void al_eth_flow_ctrl_disable(struct al_eth_adapter *adapter)
+{
+	adapter->link_config.flow_ctrl_active = 0;
+	al_eth_flow_ctrl_config(adapter);
+}
+
+static int al_eth_hw_init_adapter(struct al_eth_adapter *adapter)
+{
+	struct al_eth_adapter_params *params = &adapter->eth_hw_params;
+	int rc;
+
+	params->rev_id = adapter->rev_id;
+	params->udma_id = 0;
+	params->enable_rx_parser = 1; /* enable rx epe parser*/
+	params->udma_regs_base = adapter->udma_base; /* UDMA register base address */
+	params->ec_regs_base = adapter->ec_base; /* Ethernet controller registers base address */
+	params->mac_regs_base = adapter->mac_base; /* Ethernet MAC registers base address */
+	params->name = adapter->name;
+	params->netdev = adapter->netdev;
+
+	rc = al_eth_adapter_init(&adapter->hw_adapter, params);
+	if (rc)
+		dev_err(&adapter->pdev->dev, "Adapter init failed\n");
+
+	return rc;
+}
+
+static int al_eth_hw_init(struct al_eth_adapter *adapter)
+{
+	int rc;
+
+	rc = al_eth_hw_init_adapter(adapter);
+	if (rc)
+		return rc;
+
+	rc = al_eth_mac_config(&adapter->hw_adapter, adapter->mac_mode);
+	if (rc < 0) {
+		dev_err(&adapter->pdev->dev, "Failed to configure mac!\n");
+		return rc;
+	}
+
+	if ((adapter->mac_mode == AL_ETH_MAC_MODE_SGMII) ||
+	    (adapter->mac_mode == AL_ETH_MAC_MODE_RGMII && adapter->phy_exist == false)) {
+		rc = al_eth_mac_link_config(&adapter->hw_adapter,
+					    adapter->link_config.force_1000_base_x,
+					    adapter->link_config.autoneg,
+					    adapter->link_config.active_speed,
+					    adapter->link_config.active_duplex);
+		if (rc) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to configure link parameters!\n");
+			return rc;
+		}
+	}
+
+	rc = al_eth_mdio_config(&adapter->hw_adapter,
+				(adapter->phy_if == AL_ETH_BOARD_PHY_IF_XMDIO) ?
+				AL_ETH_MDIO_TYPE_CLAUSE_45 : AL_ETH_MDIO_TYPE_CLAUSE_22,
+				true,
+				adapter->ref_clk_freq, adapter->mdio_freq);
+	if (rc) {
+		dev_err(&adapter->pdev->dev, "failed at mdio config!\n");
+		return rc;
+	}
+
+	al_eth_flow_ctrl_init(adapter);
+
+	return rc;
+}
+
+static int al_eth_hw_stop(struct al_eth_adapter *adapter)
+{
+	al_eth_mac_stop(&adapter->hw_adapter);
+
+	/*
+	 * wait till pending rx packets written and UDMA becomes idle,
+	 * the MAC has ~10KB fifo, 10us should be enought time for the
+	 * UDMA to write to the memory
+	 */
+	udelay(10);
+
+	al_eth_adapter_stop(&adapter->hw_adapter);
+
+	adapter->flags |= AL_ETH_FLAG_RESET_REQUESTED;
+
+	/* disable flow ctrl to avoid pause packets*/
+	al_eth_flow_ctrl_disable(adapter);
+
+	return 0;
+}
+
+static int al_eth_udma_queue_enable(struct al_eth_adapter *adapter,
+				    enum al_udma_type type, int qid)
+{
+	int rc = 0;
+	char *name = (type == UDMA_TX) ? "Tx" : "Rx";
+	struct al_udma_q_params *q_params;
+
+	if (type == UDMA_TX)
+		q_params = &adapter->tx_ring[qid].q_params;
+	else
+		q_params = &adapter->rx_ring[qid].q_params;
+
+	rc = al_eth_queue_config(&adapter->hw_adapter, type, qid, q_params);
+	if (rc < 0) {
+		netdev_err(adapter->netdev, "config %s queue %u failed\n", name,
+			   qid);
+		return rc;
+	}
+
+	return rc;
+}
+
+static int al_eth_udma_queues_enable_all(struct al_eth_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		al_eth_udma_queue_enable(adapter, UDMA_TX, i);
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		al_eth_udma_queue_enable(adapter, UDMA_RX, i);
+	return 0;
+}
+
+static void al_eth_init_rings(struct al_eth_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct al_eth_ring *ring = &adapter->tx_ring[i];
+
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
+		al_udma_q_handle_get(&adapter->hw_adapter.tx_udma, i, &ring->dma_q);
+		ring->sw_count = adapter->tx_ring_count;
+		ring->hw_count = adapter->tx_descs_count;
+		ring->unmask_reg_offset = al_udma_iofic_unmask_offset_get(
+						(struct unit_regs *)adapter->udma_base,
+						AL_UDMA_IOFIC_LEVEL_PRIMARY,
+						AL_INT_GROUP_C);
+		ring->unmask_val = ~BIT(i);
+	}
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct al_eth_ring *ring = &adapter->rx_ring[i];
+
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
+		ring->napi = &adapter->al_napi[AL_ETH_RXQ_NAPI_IDX(adapter, i)].napi;
+		al_udma_q_handle_get(&adapter->hw_adapter.rx_udma, i, &ring->dma_q);
+		ring->sw_count = adapter->rx_ring_count;
+		ring->hw_count = adapter->rx_descs_count;
+		ring->unmask_reg_offset = al_udma_iofic_unmask_offset_get(
+						(struct unit_regs *)adapter->udma_base,
+						AL_UDMA_IOFIC_LEVEL_PRIMARY,
+						AL_INT_GROUP_B);
+		ring->unmask_val = ~BIT(i);
+	}
+}
+
+/*
+ * al_eth_setup_tx_resources - allocate Tx resources (Descriptors)
+ * @adapter: network interface device structure
+ * @qid: queue index
+ *
+ * Return 0 on success, negative on failure
+ */
+static int al_eth_setup_tx_resources(struct al_eth_adapter *adapter, int qid)
+{
+	struct al_eth_ring *tx_ring = &adapter->tx_ring[qid];
+	struct device *dev = tx_ring->dev;
+	struct al_udma_q_params *q_params = &tx_ring->q_params;
+	int size;
+
+	size = sizeof(struct al_eth_tx_buffer) * tx_ring->sw_count;
+
+	tx_ring->tx_buffer_info = kzalloc(size, GFP_KERNEL);
+	if (!tx_ring->tx_buffer_info)
+		return -ENOMEM;
+
+	tx_ring->descs_size = tx_ring->hw_count * sizeof(union al_udma_desc);
+	q_params->size = tx_ring->hw_count;
+
+	q_params->desc_base = dma_alloc_coherent(dev,
+					tx_ring->descs_size,
+					&q_params->desc_phy_base,
+					GFP_KERNEL);
+
+	if (!q_params->desc_base)
+		return -ENOMEM;
+
+	q_params->cdesc_base = NULL; /* completion queue not used for tx */
+	tx_ring->next_to_use = 0;
+	tx_ring->next_to_clean = 0;
+	return 0;
+}
+
+/*
+ * al_eth_free_tx_resources - Free Tx Resources per Queue
+ * @adapter: network interface device structure
+ * @qid: queue index
+ *
+ * Free all transmit software resources
+ */
+static void al_eth_free_tx_resources(struct al_eth_adapter *adapter, int qid)
+{
+	struct al_eth_ring *tx_ring = &adapter->tx_ring[qid];
+	struct al_udma_q_params *q_params = &tx_ring->q_params;
+
+	kfree(tx_ring->tx_buffer_info);
+	tx_ring->tx_buffer_info = NULL;
+
+	/* if not set, then don't free */
+	if (!q_params->desc_base)
+		return;
+
+	dma_free_coherent(tx_ring->dev, tx_ring->descs_size,
+			  q_params->desc_base,
+			  q_params->desc_phy_base);
+
+	q_params->desc_base = NULL;
+}
+
+/*
+ * al_eth_setup_all_tx_resources - allocate all queues Tx resources
+ * @adapter: private structure
+ *
+ * Return 0 on success, negative on failure
+ */
+static int al_eth_setup_all_tx_resources(struct al_eth_adapter *adapter)
+{
+	int i, rc = 0;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		rc = al_eth_setup_tx_resources(adapter, i);
+		if (!rc)
+			continue;
+
+		netdev_err(adapter->netdev, "Allocation for Tx Queue %u failed\n", i);
+		goto err_setup_tx;
+	}
+
+	return 0;
+err_setup_tx:
+	/* rewind the index freeing the rings as we go */
+	while (i--)
+		al_eth_free_tx_resources(adapter, i);
+	return rc;
+}
+
+/*
+ * al_eth_free_all_tx_resources - Free Tx Resources for All Queues
+ * @adapter: board private structure
+ *
+ * Free all transmit software resources
+ */
+static void al_eth_free_all_tx_resources(struct al_eth_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		if (adapter->tx_ring[i].q_params.desc_base)
+			al_eth_free_tx_resources(adapter, i);
+}
+
+/*
+ * al_eth_setup_rx_resources - allocate Rx resources (Descriptors)
+ * @adapter: network interface device structure
+ * @qid: queue index
+ *
+ * Returns 0 on success, negative on failure
+ */
+static int al_eth_setup_rx_resources(struct al_eth_adapter *adapter,
+				     unsigned int qid)
+{
+	struct al_eth_ring *rx_ring = &adapter->rx_ring[qid];
+	struct device *dev = rx_ring->dev;
+	struct al_udma_q_params *q_params = &rx_ring->q_params;
+	int size;
+
+	size = sizeof(struct al_eth_rx_buffer) * rx_ring->sw_count;
+
+	/* alloc extra element so in rx path we can always prefetch rx_info + 1*/
+	size += 1;
+
+	rx_ring->rx_buffer_info = kzalloc(size, GFP_KERNEL);
+	if (!rx_ring->rx_buffer_info)
+		return -ENOMEM;
+
+	rx_ring->descs_size = rx_ring->hw_count * sizeof(union al_udma_desc);
+	q_params->size = rx_ring->hw_count;
+
+	q_params->desc_base = dma_alloc_coherent(dev, rx_ring->descs_size,
+					&q_params->desc_phy_base,
+					GFP_KERNEL);
+	if (!q_params->desc_base)
+		return -ENOMEM;
+
+	rx_ring->cdescs_size = rx_ring->hw_count * AL_ETH_UDMA_RX_CDESC_SZ;
+	q_params->cdesc_base = dma_alloc_coherent(dev, rx_ring->cdescs_size,
+						  &q_params->cdesc_phy_base,
+						  GFP_KERNEL);
+	if (!q_params->cdesc_base)
+		return -ENOMEM;
+
+	/* Zero out the descriptor ring */
+	memset(q_params->cdesc_base, 0, rx_ring->cdescs_size);
+
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
+
+	return 0;
+}
+
+/*
+ * al_eth_free_rx_resources - Free Rx Resources
+ * @adapter: network interface device structure
+ * @qid: queue index
+ *
+ * Free all receive software resources
+ */
+static void al_eth_free_rx_resources(struct al_eth_adapter *adapter,
+				     unsigned int qid)
+{
+	struct al_eth_ring *rx_ring = &adapter->rx_ring[qid];
+	struct al_udma_q_params *q_params = &rx_ring->q_params;
+
+	kfree(rx_ring->rx_buffer_info);
+	rx_ring->rx_buffer_info = NULL;
+
+	/* if not set, then don't free */
+	if (!q_params->desc_base)
+		return;
+
+	dma_free_coherent(rx_ring->dev, rx_ring->descs_size,
+			  q_params->desc_base,
+			  q_params->desc_phy_base);
+
+	q_params->desc_base = NULL;
+
+	/* if not set, then don't free */
+	if (!q_params->cdesc_base)
+		return;
+
+	dma_free_coherent(rx_ring->dev, rx_ring->cdescs_size,
+			  q_params->cdesc_base,
+			  q_params->cdesc_phy_base);
+
+	q_params->cdesc_phy_base = 0;
+}
+
+/*
+ * al_eth_setup_all_rx_resources - allocate all queues Rx resources
+ * @adapter: board private structure
+ *
+ * Return 0 on success, negative on failure
+ */
+static int al_eth_setup_all_rx_resources(struct al_eth_adapter *adapter)
+{
+	int i, rc;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		rc = al_eth_setup_rx_resources(adapter, i);
+		if (!rc)
+			continue;
+
+		netdev_err(adapter->netdev, "Allocation for Rx Queue %u failed\n", i);
+		goto err_setup_rx;
+	}
+
+	return 0;
+
+err_setup_rx:
+	/* rewind the index freeing the rings as we go */
+	while (i--)
+		al_eth_free_rx_resources(adapter, i);
+	return rc;
+}
+
+/*
+ * al_eth_free_all_rx_resources - Free Rx Resources for All Queues
+ * @adapter: board private structure
+ *
+ * Free all receive software resources
+ */
+static void al_eth_free_all_rx_resources(struct al_eth_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		if (adapter->rx_ring[i].q_params.desc_base)
+			al_eth_free_rx_resources(adapter, i);
+}
+
+static inline int al_eth_alloc_rx_frag(struct al_eth_adapter *adapter,
+				       struct al_eth_ring *rx_ring,
+				       struct al_eth_rx_buffer *rx_info)
+{
+	struct al_buf *al_buf;
+	dma_addr_t dma;
+	u8 *data;
+
+	/* if previous allocated frag is not used */
+	if (rx_info->data)
+		return 0;
+
+	rx_info->data_size = min_t(unsigned int,
+				  (rx_ring->netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN),
+				   adapter->max_rx_buff_alloc_size);
+
+	rx_info->data_size = max_t(unsigned int,
+				   rx_info->data_size,
+				   AL_ETH_DEFAULT_MIN_RX_BUFF_ALLOC_SIZE);
+
+	rx_info->frag_size = SKB_DATA_ALIGN(rx_info->data_size + AL_ETH_RX_OFFSET) +
+			     SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	data = netdev_alloc_frag(rx_info->frag_size);
+
+	if (!data)
+		return -ENOMEM;
+
+	dma = dma_map_single(rx_ring->dev, data + AL_ETH_RX_OFFSET,
+			     rx_info->data_size, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(rx_ring->dev, dma))) {
+		put_page(virt_to_head_page(data));
+		return -EIO;
+	}
+	netdev_dbg(rx_ring->netdev, "alloc frag %p, rx_info %p len %x skb size %x\n",
+		   data, rx_info, rx_info->data_size, rx_info->frag_size);
+
+	rx_info->data = data;
+
+	WARN_ON(!virt_addr_valid(rx_info->data));
+	rx_info->page = virt_to_head_page(rx_info->data);
+	rx_info->page_offset = (unsigned long)rx_info->data -
+			       (unsigned long)page_address(rx_info->page);
+	al_buf = &rx_info->al_buf;
+	dma_unmap_addr_set(al_buf, addr, dma);
+	dma_unmap_addr_set(rx_info, dma, dma);
+	dma_unmap_len_set(al_buf, len, rx_info->data_size);
+	return 0;
+}
+
+static void al_eth_free_rx_frag(struct al_eth_adapter *adapter,
+				struct al_eth_rx_buffer *rx_info)
+{
+	u8 *data = rx_info->data;
+	struct al_buf *al_buf = &rx_info->al_buf;
+
+	if (!data)
+		return;
+
+	dma_unmap_single(&adapter->pdev->dev, dma_unmap_addr(al_buf, addr),
+			 rx_info->data_size, DMA_FROM_DEVICE);
+
+	put_page(virt_to_head_page(data));
+	rx_info->data = NULL;
+}
+
+static int al_eth_refill_rx_bufs(struct al_eth_adapter *adapter,
+				 unsigned int qid, unsigned int num)
+{
+	struct al_eth_ring *rx_ring = &adapter->rx_ring[qid];
+	u16 next_to_use;
+	unsigned int i;
+
+	next_to_use = rx_ring->next_to_use;
+
+	for (i = 0; i < num; i++) {
+		int rc;
+		struct al_eth_rx_buffer *rx_info = &rx_ring->rx_buffer_info[next_to_use];
+
+		if (unlikely(al_eth_alloc_rx_frag(adapter, rx_ring, rx_info) < 0)) {
+			netdev_warn(adapter->netdev,
+				    "failed to alloc buffer for rx queue %d\n",
+				    qid);
+			break;
+		}
+		rc = al_eth_rx_buffer_add(&adapter->hw_adapter, rx_ring->dma_q,
+					  &rx_info->al_buf, AL_ETH_RX_FLAGS_INT,
+					  NULL);
+		if (unlikely(rc)) {
+			netdev_warn(adapter->netdev,
+				    "failed to add buffer for rx queue %d\n",
+				    qid);
+			break;
+		}
+		next_to_use = AL_ETH_RX_RING_IDX_NEXT(rx_ring, next_to_use);
+	}
+
+	if (unlikely(i < num)) {
+		netdev_warn(adapter->netdev,
+			    "refilled rx queue %d with %d pages only - available %d\n",
+			    qid, i, al_udma_available_get(rx_ring->dma_q));
+	}
+
+	if (likely(i))
+		al_eth_rx_buffer_action(&adapter->hw_adapter, rx_ring->dma_q,
+					i);
+
+	rx_ring->next_to_use = next_to_use;
+
+	return i;
+}
+
+static void al_eth_free_rx_bufs(struct al_eth_adapter *adapter, unsigned int qid)
+{
+	struct al_eth_ring *rx_ring = &adapter->rx_ring[qid];
+	unsigned int i;
+
+	for (i = 0; i < AL_ETH_DEFAULT_RX_DESCS; i++) {
+		struct al_eth_rx_buffer *rx_info = &rx_ring->rx_buffer_info[i];
+
+		if (rx_info->data)
+			al_eth_free_rx_frag(adapter, rx_info);
+	}
+}
+
+/*
+ * al_eth_refill_all_rx_bufs - allocate all queues Rx buffers
+ * @adapter: board private structure
+ */
+static void al_eth_refill_all_rx_bufs(struct al_eth_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		al_eth_refill_rx_bufs(adapter, i, AL_ETH_DEFAULT_RX_DESCS - 1);
+}
+
+static void al_eth_free_all_rx_bufs(struct al_eth_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		al_eth_free_rx_bufs(adapter, i);
+}
+
+/*
+ * al_eth_free_tx_bufs - Free Tx Buffers per Queue
+ * @adapter: network interface device structure
+ * @qid: queue index
+ */
+static void al_eth_free_tx_bufs(struct al_eth_adapter *adapter,
+				unsigned int qid)
+{
+	struct al_eth_ring *tx_ring = &adapter->tx_ring[qid];
+	unsigned int i;
+
+	for (i = 0; i < AL_ETH_DEFAULT_TX_SW_DESCS; i++) {
+		struct al_eth_tx_buffer *tx_info = &tx_ring->tx_buffer_info[i];
+		struct al_buf *al_buf;
+		int nr_frags;
+		int j;
+
+		if (!tx_info->skb)
+			continue;
+
+		netdev_warn(adapter->netdev,
+			    "free uncompleted tx skb qid %d idx 0x%x\n",
+			    qid, i);
+
+		al_buf = tx_info->hw_pkt.bufs;
+		dma_unmap_single(&adapter->pdev->dev,
+				 dma_unmap_addr(al_buf, addr),
+				 dma_unmap_len(al_buf, len), DMA_TO_DEVICE);
+
+		/* unmap remaining mapped pages */
+		nr_frags = tx_info->hw_pkt.num_of_bufs - 1;
+		for (j = 0; j < nr_frags; j++) {
+			al_buf++;
+			dma_unmap_page(&adapter->pdev->dev,
+				       dma_unmap_addr(al_buf, addr),
+				       dma_unmap_len(al_buf, len),
+				       DMA_TO_DEVICE);
+		}
+
+		dev_kfree_skb_any(tx_info->skb);
+	}
+	netdev_tx_reset_queue(netdev_get_tx_queue(adapter->netdev, qid));
+}
+
+static void al_eth_free_all_tx_bufs(struct al_eth_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		al_eth_free_tx_bufs(adapter, i);
+}
+
+/*
+ * al_eth_tx_poll - NAPI Tx polling callback
+ * @napi: structure for representing this polling device
+ * @budget: how many packets driver is allowed to clean
+ *
+ * This function is used for legacy and MSI, NAPI mode
+ */
+static int al_eth_tx_poll(struct napi_struct *napi, int budget)
+{
+	struct al_eth_napi *al_napi = container_of(napi, struct al_eth_napi, napi);
+	struct al_eth_adapter *adapter = al_napi->adapter;
+	unsigned int qid = al_napi->qid;
+	struct al_eth_ring *tx_ring = &adapter->tx_ring[qid];
+	struct netdev_queue *txq;
+	unsigned int tx_bytes = 0;
+	unsigned int total_done;
+	u16 next_to_clean;
+	int tx_pkt = 0;
+
+	total_done = al_eth_comp_tx_get(&adapter->hw_adapter, tx_ring->dma_q);
+	dev_dbg(&adapter->pdev->dev, "tx_poll: q %d total completed descs %x\n",
+		qid, total_done);
+	next_to_clean = tx_ring->next_to_clean;
+	txq = netdev_get_tx_queue(adapter->netdev, qid);
+
+	while (total_done) {
+		struct al_eth_tx_buffer *tx_info;
+		struct sk_buff *skb;
+		struct al_buf *al_buf;
+		int i, nr_frags;
+
+		tx_info = &tx_ring->tx_buffer_info[next_to_clean];
+		/* stop if not all descriptors of the packet are completed */
+		if (tx_info->tx_descs > total_done)
+			break;
+
+		skb = tx_info->skb;
+
+		/* prefetch skb_end_pointer() to speedup skb_shinfo(skb) */
+		prefetch(&skb->end);
+
+		tx_info->skb = NULL;
+		al_buf = tx_info->hw_pkt.bufs;
+		dma_unmap_single(tx_ring->dev, dma_unmap_addr(al_buf, addr),
+				 dma_unmap_len(al_buf, len), DMA_TO_DEVICE);
+
+		/* unmap remaining mapped pages */
+		nr_frags = tx_info->hw_pkt.num_of_bufs - 1;
+		for (i = 0; i < nr_frags; i++) {
+			al_buf++;
+			dma_unmap_page(tx_ring->dev, dma_unmap_addr(al_buf, addr),
+				       dma_unmap_len(al_buf, len), DMA_TO_DEVICE);
+		}
+
+		tx_bytes += skb->len;
+		dev_dbg(&adapter->pdev->dev, "tx_poll: q %d skb %p completed\n",
+			qid, skb);
+		dev_kfree_skb(skb);
+		tx_pkt++;
+		total_done -= tx_info->tx_descs;
+		next_to_clean = AL_ETH_TX_RING_IDX_NEXT(tx_ring, next_to_clean);
+	}
+
+	netdev_tx_completed_queue(txq, tx_pkt, tx_bytes);
+
+	tx_ring->next_to_clean = next_to_clean;
+
+	dev_dbg(&adapter->pdev->dev, "tx_poll: q %d done next to clean %x\n",
+		qid, next_to_clean);
+
+	/*
+	 * We need to make the rings circular update visible to
+	 * al_eth_start_xmit() before checking for netif_queue_stopped().
+	 */
+	smp_mb();
+
+	if (unlikely(netif_tx_queue_stopped(txq) &&
+		     (al_udma_available_get(tx_ring->dma_q) > AL_ETH_TX_WAKEUP_THRESH))) {
+		__netif_tx_lock(txq, smp_processor_id());
+		if (netif_tx_queue_stopped(txq) &&
+		    (al_udma_available_get(tx_ring->dma_q) > AL_ETH_TX_WAKEUP_THRESH))
+			netif_tx_wake_queue(txq);
+		__netif_tx_unlock(txq);
+	}
+
+	/* all work done, exit the polling mode */
+	napi_complete(napi);
+	writel_relaxed(tx_ring->unmask_val, tx_ring->unmask_reg_offset);
+	return 0;
+}
+
+static struct sk_buff *al_eth_rx_skb(struct al_eth_adapter *adapter,
+				     struct al_eth_ring *rx_ring,
+				     struct al_eth_pkt *hw_pkt,
+				     unsigned int descs, u16 *next_to_clean)
+{
+	struct sk_buff *skb = NULL;
+	struct al_eth_rx_buffer *rx_info =
+		&rx_ring->rx_buffer_info[*next_to_clean];
+	unsigned int len;
+	unsigned int buf = 0;
+
+	len = hw_pkt->bufs[0].len;
+	netdev_dbg(adapter->netdev, "rx_info %p data %p\n", rx_info,
+		   rx_info->data);
+
+	prefetch(rx_info->data + AL_ETH_RX_OFFSET);
+
+	if (len <= adapter->rx_copybreak) {
+		netdev_dbg(adapter->netdev, "rx small packet. len %d\n", len);
+
+		skb = netdev_alloc_skb_ip_align(adapter->netdev,
+						adapter->rx_copybreak);
+		if (unlikely(!skb))
+			return NULL;
+
+		pci_dma_sync_single_for_cpu(adapter->pdev, rx_info->dma,
+					    len, DMA_FROM_DEVICE);
+		skb_copy_to_linear_data(skb, rx_info->data + AL_ETH_RX_OFFSET,
+					len);
+		pci_dma_sync_single_for_device(adapter->pdev, rx_info->dma, len,
+					       DMA_FROM_DEVICE);
+		skb_put(skb, len);
+		skb->protocol = eth_type_trans(skb, adapter->netdev);
+		*next_to_clean = AL_ETH_RX_RING_IDX_NEXT(rx_ring,
+							 *next_to_clean);
+		return skb;
+	}
+
+	skb = napi_get_frags(rx_ring->napi);
+	if (unlikely(!skb))
+		return NULL;
+
+	skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
+			   rx_info->page,
+			   rx_info->page_offset + AL_ETH_RX_OFFSET, len);
+
+	skb->len += len;
+	skb->data_len += len;
+	skb->truesize += len;
+
+	netdev_dbg(adapter->netdev, "rx skb updated. len %d. data_len %d\n",
+		   skb->len, skb->data_len);
+
+	rx_info->data = NULL;
+	*next_to_clean = AL_ETH_RX_RING_IDX_NEXT(rx_ring, *next_to_clean);
+
+	while (--descs) {
+		rx_info = &rx_ring->rx_buffer_info[*next_to_clean];
+		len = hw_pkt->bufs[++buf].len;
+
+		dma_unmap_single(rx_ring->dev, dma_unmap_addr(rx_info, dma),
+				 rx_info->data_size, DMA_FROM_DEVICE);
+
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+				rx_info->page,
+				rx_info->page_offset + AL_ETH_RX_OFFSET,
+				len, rx_info->data_size);
+
+		netdev_dbg(adapter->netdev, "rx skb updated. len %d. "
+			   "data_len %d\n", skb->len, skb->data_len);
+
+		rx_info->data = NULL;
+
+		*next_to_clean = AL_ETH_RX_RING_IDX_NEXT(rx_ring, *next_to_clean);
+	}
+
+	return skb;
+}
+
+/*
+ * al_eth_rx_checksum - indicate in skb if hw indicated a good cksum
+ * @adapter: structure containing adapter specific data
+ * @hw_pkt: HAL structure for the packet
+ * @skb: skb currently being received and modified
+ */
+static inline void al_eth_rx_checksum(struct al_eth_adapter *adapter,
+				      struct al_eth_pkt *hw_pkt,
+				      struct sk_buff *skb)
+{
+	skb_checksum_none_assert(skb);
+
+	/* Rx csum disabled */
+	if (unlikely(!(adapter->netdev->features & NETIF_F_RXCSUM))) {
+		netdev_dbg(adapter->netdev, "hw checksum offloading disabled\n");
+		return;
+	}
+
+	/* if IP and error */
+	if (unlikely((hw_pkt->l3_proto_idx == AL_ETH_PROTO_ID_IPv4) &&
+		     (hw_pkt->flags & AL_ETH_RX_FLAGS_L3_CSUM_ERR))) {
+		/* ipv4 checksum error */
+		netdev_dbg(adapter->netdev, "rx ipv4 header checksum error\n");
+		return;
+	}
+
+	/* if TCP/UDP */
+	if (likely((hw_pkt->l4_proto_idx == AL_ETH_PROTO_ID_TCP) ||
+		   (hw_pkt->l4_proto_idx == AL_ETH_PROTO_ID_UDP))) {
+		if (unlikely(hw_pkt->flags & AL_ETH_RX_FLAGS_L4_CSUM_ERR)) {
+			/* TCP/UDP checksum error */
+			netdev_dbg(adapter->netdev, "rx L4 checksum error\n");
+			return;
+		}
+
+		netdev_dbg(adapter->netdev, "rx checksum correct\n");
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+}
+
+/*
+ * al_eth_rx_poll - NAPI Rx polling callback
+ * @napi: structure for representing this polling device
+ * @budget: how many packets driver is allowed to clean
+ *
+ * This function is used for legacy and MSI, NAPI mode
+ */
+static int al_eth_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct al_eth_napi *al_napi = container_of(napi, struct al_eth_napi, napi);
+	struct al_eth_adapter *adapter = al_napi->adapter;
+	unsigned int qid = al_napi->qid;
+	struct al_eth_ring *rx_ring = &adapter->rx_ring[qid];
+	struct al_eth_pkt *hw_pkt = &rx_ring->hw_pkt;
+	int work_done = 0;
+	u16 next_to_clean = rx_ring->next_to_clean;
+	int refill_required;
+	int refill_actual;
+
+	do {
+		struct sk_buff *skb;
+		unsigned int descs;
+
+		descs = al_eth_pkt_rx(&adapter->hw_adapter, rx_ring->dma_q,
+				      hw_pkt);
+		if (unlikely(descs == 0))
+			break;
+
+		netdev_dbg(adapter->netdev, "rx_poll: q %d flags %x. l3 proto %d l4 proto %d\n",
+			   qid, hw_pkt->flags, hw_pkt->l3_proto_idx,
+			   hw_pkt->l4_proto_idx);
+
+		/* ignore if detected dma or eth controller errors */
+		if (hw_pkt->flags & (AL_ETH_RX_ERROR | AL_UDMA_CDESC_ERROR)) {
+			netdev_dbg(adapter->netdev, "receive packet with error. flags = 0x%x\n", hw_pkt->flags);
+			next_to_clean = AL_ETH_RX_RING_IDX_ADD(rx_ring, next_to_clean, descs);
+			goto next;
+		}
+
+		/* allocate skb and fill it */
+		skb = al_eth_rx_skb(adapter, rx_ring, hw_pkt, descs,
+				    &next_to_clean);
+
+		/* exit if we failed to retrieve a buffer */
+		if (unlikely(!skb)) {
+			next_to_clean = AL_ETH_RX_RING_IDX_ADD(rx_ring,
+							       next_to_clean,
+							       descs);
+			break;
+		}
+
+		al_eth_rx_checksum(adapter, hw_pkt, skb);
+		if (likely(adapter->netdev->features & NETIF_F_RXHASH)) {
+			enum pkt_hash_types type = PKT_HASH_TYPE_L3;
+
+			if (likely((hw_pkt->l4_proto_idx == AL_ETH_PROTO_ID_TCP) ||
+				   (hw_pkt->l4_proto_idx == AL_ETH_PROTO_ID_UDP)))
+				type = PKT_HASH_TYPE_L4;
+			skb_set_hash(skb, hw_pkt->rxhash, type);
+		}
+
+		skb_record_rx_queue(skb, qid);
+
+		if (hw_pkt->bufs[0].len <= adapter->rx_copybreak)
+			napi_gro_receive(napi, skb);
+		else
+			napi_gro_frags(napi);
+
+next:
+		budget--;
+		work_done++;
+	} while (likely(budget));
+
+	rx_ring->next_to_clean = next_to_clean;
+
+	refill_required = al_udma_available_get(rx_ring->dma_q);
+	refill_actual = al_eth_refill_rx_bufs(adapter, qid, refill_required);
+
+	if (unlikely(refill_actual < refill_required)) {
+		netdev_warn(adapter->netdev, "Rescheduling rx queue %d\n", qid);
+		napi_reschedule(napi);
+	} else if (budget > 0) {
+		dev_dbg(&adapter->pdev->dev, "rx_poll: q %d done next to clean %x\n",
+			qid, next_to_clean);
+		napi_complete(napi);
+		writel_relaxed(rx_ring->unmask_val,
+			       rx_ring->unmask_reg_offset);
+	}
+
+	return work_done;
+}
+
+/*
+ * al_eth_intr_intx_all - Legacy Interrupt Handler for all interrupts
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ */
+static irqreturn_t al_eth_intr_intx_all(int irq, void *data)
+{
+	struct al_eth_adapter *adapter = data;
+	struct unit_regs __iomem *udma_base = (struct unit_regs __iomem *)adapter->udma_base;
+	void __iomem *regs_base = udma_base;
+	u32 reg;
+
+	reg = al_udma_iofic_read_cause(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+				       AL_INT_GROUP_A);
+	if (reg & AL_INT_GROUP_A_GROUP_B_SUM) {
+		u32 cause_b = al_udma_iofic_read_cause(regs_base,
+							    AL_UDMA_IOFIC_LEVEL_PRIMARY,
+							    AL_INT_GROUP_B);
+		int qid;
+
+		for (qid = 0; qid < adapter->num_rx_queues; qid++) {
+			if (cause_b & BIT(qid)) {
+				/* mask */
+				al_udma_iofic_mask(
+					(struct unit_regs __iomem *)adapter->udma_base,
+					AL_UDMA_IOFIC_LEVEL_PRIMARY,
+					AL_INT_GROUP_B, BIT(qid));
+
+				napi_schedule(&adapter->al_napi[AL_ETH_RXQ_NAPI_IDX(adapter, qid)].napi);
+			}
+		}
+	}
+	if (reg & AL_INT_GROUP_A_GROUP_C_SUM) {
+		u32 cause_c = al_udma_iofic_read_cause(regs_base,
+						       AL_UDMA_IOFIC_LEVEL_PRIMARY,
+						       AL_INT_GROUP_C);
+		int qid;
+
+		for (qid = 0; qid < adapter->num_tx_queues; qid++) {
+			if (cause_c & BIT(qid)) {
+				/* mask */
+				al_udma_iofic_mask(
+					(struct unit_regs __iomem *)adapter->udma_base,
+					AL_UDMA_IOFIC_LEVEL_PRIMARY,
+					AL_INT_GROUP_C, BIT(qid));
+
+				napi_schedule(&adapter->al_napi[AL_ETH_TXQ_NAPI_IDX(adapter, qid)].napi);
+			}
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+/*
+ * al_eth_intr_msix_mgmt - MSIX Interrupt Handler for Management interrupts
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ */
+static irqreturn_t al_eth_intr_msix_mgmt(int irq, void *data)
+{
+	/* TODO: check for dma errors */
+	return IRQ_HANDLED;
+}
+
+/*
+ * al_eth_intr_msix_tx - MSIX Interrupt Handler for Tx
+ * @irq: interrupt number
+ * @data: pointer to a network interface private napi device structure
+ */
+static irqreturn_t al_eth_intr_msix_tx(int irq, void *data)
+{
+	struct al_eth_napi *al_napi = data;
+
+	napi_schedule(&al_napi->napi);
+	return IRQ_HANDLED;
+}
+
+/*
+ * al_eth_intr_msix_rx - MSIX Interrupt Handler for Rx
+ * @irq: interrupt number
+ * @data: pointer to a network interface private napi device structure
+ */
+static irqreturn_t al_eth_intr_msix_rx(int irq, void *data)
+{
+	struct al_eth_napi *al_napi = data;
+
+	napi_schedule(&al_napi->napi);
+	return IRQ_HANDLED;
+}
+
+static void al_eth_enable_msix(struct al_eth_adapter *adapter)
+{
+	int i, msix_vecs, rc;
+
+	msix_vecs = 1 + adapter->num_rx_queues + adapter->num_tx_queues;
+
+	dev_dbg(&adapter->pdev->dev, "Try to enable MSIX, vectors %d\n",
+		msix_vecs);
+
+	adapter->msix_entries = kcalloc(msix_vecs,
+					sizeof(struct msix_entry), GFP_KERNEL);
+
+	if (!adapter->msix_entries) {
+		dev_err(&adapter->pdev->dev,
+			"failed to allocate msix_entries, vectors %d\n",
+			msix_vecs);
+		return;
+	}
+
+	/* management vector (GROUP_A) */
+	adapter->msix_entries[AL_ETH_MGMT_IRQ_IDX].entry = 2;
+	adapter->msix_entries[AL_ETH_MGMT_IRQ_IDX].vector = 0;
+
+	/* rx queues start */
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		int	irq_idx = AL_ETH_RXQ_IRQ_IDX(adapter, i);
+
+		adapter->msix_entries[irq_idx].entry = 3 + i;
+		adapter->msix_entries[irq_idx].vector = 0;
+	}
+	/* tx queues start */
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		int	irq_idx = AL_ETH_TXQ_IRQ_IDX(adapter, i);
+
+		adapter->msix_entries[irq_idx].entry = 3 + AL_ETH_MAX_HW_QUEUES + i;
+		adapter->msix_entries[irq_idx].vector = 0;
+	}
+
+	rc = pci_enable_msix(adapter->pdev, adapter->msix_entries,
+			     msix_vecs);
+	if (rc) {
+		dev_dbg(&adapter->pdev->dev, "failed to enable MSIX, vectors %d\n",
+			msix_vecs);
+		adapter->msix_vecs = 0;
+		kfree(adapter->msix_entries);
+		adapter->msix_entries = NULL;
+		return;
+	}
+	dev_dbg(&adapter->pdev->dev, "enable MSIX, vectors %d\n", msix_vecs);
+
+	adapter->msix_vecs = msix_vecs;
+	adapter->flags |= AL_ETH_FLAG_MSIX_ENABLED;
+}
+
+static void al_eth_setup_int_mode(struct al_eth_adapter *adapter, int dis_msi)
+{
+	int i;
+	unsigned int cpu;
+
+	if (!dis_msi)
+		al_eth_enable_msix(adapter);
+
+	if (adapter->msix_vecs == 1) {
+		netdev_err(adapter->netdev, "single MSI-X mode unsupported\n");
+		return;
+	}
+
+	adapter->irq_vecs = max(1, adapter->msix_vecs);
+
+	/* single INTX mode */
+	if (adapter->msix_vecs == 0) {
+		snprintf(adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].name,
+			 AL_ETH_IRQNAME_SIZE, "al-eth-intx-all@pci:%s",
+			 pci_name(adapter->pdev));
+		adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].handler = al_eth_intr_intx_all;
+		adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].vector = adapter->pdev->irq;
+		adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].data = adapter;
+
+		cpu = cpumask_first(cpu_online_mask);
+		cpumask_set_cpu(cpu, &adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].affinity_hint_mask);
+
+		return;
+	}
+
+	/* MSI-X per queue */
+	snprintf(adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].name, AL_ETH_IRQNAME_SIZE,
+		"al-eth-msix-mgmt@pci:%s", pci_name(adapter->pdev));
+	adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].handler = al_eth_intr_msix_mgmt;
+
+	adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].data = adapter;
+	adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].vector = adapter->msix_entries[AL_ETH_MGMT_IRQ_IDX].vector;
+	cpu = cpumask_first(cpu_online_mask);
+	cpumask_set_cpu(cpu, &adapter->irq_tbl[AL_ETH_MGMT_IRQ_IDX].affinity_hint_mask);
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		int irq_idx = AL_ETH_RXQ_IRQ_IDX(adapter, i);
+		int napi_idx = AL_ETH_RXQ_NAPI_IDX(adapter, i);
+
+		snprintf(adapter->irq_tbl[irq_idx].name, AL_ETH_IRQNAME_SIZE,
+			 "al-eth-rx-comp-%d@pci:%s", i,
+			 pci_name(adapter->pdev));
+		adapter->irq_tbl[irq_idx].handler = al_eth_intr_msix_rx;
+		adapter->irq_tbl[irq_idx].data = &adapter->al_napi[napi_idx];
+		adapter->irq_tbl[irq_idx].vector = adapter->msix_entries[irq_idx].vector;
+
+		cpu = cpumask_next((i % num_online_cpus() - 1), cpu_online_mask);
+		cpumask_set_cpu(cpu, &adapter->irq_tbl[irq_idx].affinity_hint_mask);
+	}
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		int irq_idx = AL_ETH_TXQ_IRQ_IDX(adapter, i);
+		int napi_idx = AL_ETH_TXQ_NAPI_IDX(adapter, i);
+
+		snprintf(adapter->irq_tbl[irq_idx].name,
+			 AL_ETH_IRQNAME_SIZE, "al-eth-tx-comp-%d@pci:%s", i,
+			 pci_name(adapter->pdev));
+		adapter->irq_tbl[irq_idx].handler = al_eth_intr_msix_tx;
+		adapter->irq_tbl[irq_idx].data = &adapter->al_napi[napi_idx];
+		adapter->irq_tbl[irq_idx].vector = adapter->msix_entries[irq_idx].vector;
+
+		cpu = cpumask_next((i % num_online_cpus() - 1), cpu_online_mask);
+		cpumask_set_cpu(cpu, &adapter->irq_tbl[irq_idx].affinity_hint_mask);
+	}
+}
+
+static int al_eth_configure_int_mode(struct al_eth_adapter *adapter)
+{
+	enum al_iofic_mode int_mode;
+	u32 m2s_errors_disable = 0x480;
+	u32 m2s_aborts_disable = 0x480;
+	u32 s2m_errors_disable = 0x1e0;
+	u32 s2m_aborts_disable = 0x1e0;
+
+	/* single INTX mode */
+	if (adapter->msix_vecs == 0) {
+		int_mode = AL_IOFIC_MODE_LEGACY;
+	} else if (adapter->msix_vecs > 1) {
+		int_mode = AL_IOFIC_MODE_MSIX_PER_Q;
+	} else {
+		netdev_err(adapter->netdev,
+			   "udma doesn't support single MSI-X mode.\n");
+		return -EIO;
+	}
+
+	m2s_errors_disable |= 0x3f << 25;
+	s2m_aborts_disable |= 0x3f << 25;
+
+	if (al_udma_iofic_config((struct unit_regs __iomem *)adapter->udma_base,
+				 int_mode, m2s_errors_disable,
+				 m2s_aborts_disable, s2m_errors_disable,
+				 s2m_aborts_disable)) {
+		netdev_err(adapter->netdev, "al_udma_unit_int_config failed!.\n");
+		return -EIO;
+	}
+	adapter->int_mode = int_mode;
+	netdev_info(adapter->netdev, "using %s interrupt mode",
+		    int_mode == AL_IOFIC_MODE_LEGACY ? "INTx" :
+		    int_mode == AL_IOFIC_MODE_MSIX_PER_Q ?
+		    "MSI-X per Queue" : "Unknown");
+	/* set interrupt moderation resolution to 15us */
+	al_iofic_moder_res_config(&((struct unit_regs *)(adapter->udma_base))->gen.interrupt_regs.main_iofic,
+				  AL_INT_GROUP_B, 15);
+	al_iofic_moder_res_config(&((struct unit_regs *)(adapter->udma_base))->gen.interrupt_regs.main_iofic,
+				  AL_INT_GROUP_C, 15);
+
+	return 0;
+}
+
+static int al_eth_request_irq(struct al_eth_adapter *adapter)
+{
+	unsigned long flags;
+	struct al_eth_irq *irq;
+	int rc = 0, i;
+
+	if (adapter->flags & AL_ETH_FLAG_MSIX_ENABLED)
+		flags = 0;
+	else
+		flags = IRQF_SHARED;
+
+	for (i = 0; i < adapter->irq_vecs; i++) {
+		irq = &adapter->irq_tbl[i];
+		rc = request_irq(irq->vector, irq->handler, flags, irq->name,
+				 irq->data);
+		if (rc) {
+			netdev_err(adapter->netdev,
+				   "failed to request irq. index %d rc %d\n",
+				   i, rc);
+			break;
+		}
+		irq->requested = 1;
+
+		netdev_dbg(adapter->netdev,
+			   "set affinity hint of irq. index %d to 0x%lx (irq vector: %d)\n",
+			   i, irq->affinity_hint_mask.bits[0], irq->vector);
+
+		irq_set_affinity_hint(irq->vector, &irq->affinity_hint_mask);
+	}
+	return rc;
+}
+
+static void __al_eth_free_irq(struct al_eth_adapter *adapter)
+{
+	struct al_eth_irq *irq;
+	int i;
+
+	for (i = 0; i < adapter->irq_vecs; i++) {
+		irq = &adapter->irq_tbl[i];
+		if (irq->requested) {
+			irq_set_affinity_hint(irq->vector, NULL);
+			free_irq(irq->vector, irq->data);
+		}
+		irq->requested = 0;
+	}
+}
+
+static void al_eth_free_irq(struct al_eth_adapter *adapter)
+{
+	__al_eth_free_irq(adapter);
+	if (adapter->flags & AL_ETH_FLAG_MSIX_ENABLED)
+		pci_disable_msix(adapter->pdev);
+
+	adapter->flags &= ~AL_ETH_FLAG_MSIX_ENABLED;
+
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
+}
+
+static void al_eth_interrupts_mask(struct al_eth_adapter *adapter);
+
+static void al_eth_disable_int_sync(struct al_eth_adapter *adapter)
+{
+	int i;
+
+	if (!netif_running(adapter->netdev))
+		return;
+
+	/* mask hw interrupts */
+	al_eth_interrupts_mask(adapter);
+
+	for (i = 0; i < adapter->irq_vecs; i++)
+		synchronize_irq(adapter->irq_tbl[i].vector);
+}
+
+static void al_eth_interrupts_unmask(struct al_eth_adapter *adapter)
+{
+	u32 group_a_mask = AL_INT_GROUP_A_GROUP_D_SUM; /* enable group D summery */
+	u32 group_b_mask = BIT(adapter->num_rx_queues) - 1;/* bit per Rx q*/
+	u32 group_c_mask = BIT(adapter->num_tx_queues) - 1;/* bit per Tx q*/
+	u32 group_d_mask = 3 << 8;
+	struct unit_regs __iomem *regs_base = (struct unit_regs __iomem *)adapter->udma_base;
+
+	if (adapter->int_mode == AL_IOFIC_MODE_LEGACY)
+		group_a_mask |= AL_INT_GROUP_A_GROUP_B_SUM |
+				AL_INT_GROUP_A_GROUP_C_SUM |
+				AL_INT_GROUP_A_GROUP_D_SUM;
+
+	al_udma_iofic_unmask(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+			     AL_INT_GROUP_A, group_a_mask);
+	al_udma_iofic_unmask(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+			     AL_INT_GROUP_B, group_b_mask);
+	al_udma_iofic_unmask(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+			     AL_INT_GROUP_C, group_c_mask);
+	al_udma_iofic_unmask(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+			     AL_INT_GROUP_D, group_d_mask);
+}
+
+static void al_eth_interrupts_mask(struct al_eth_adapter *adapter)
+{
+	struct unit_regs __iomem *regs_base = (struct unit_regs __iomem *)adapter->udma_base;
+
+	/* mask all interrupts */
+	al_udma_iofic_mask(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+			   AL_INT_GROUP_A, 0x7);
+	al_udma_iofic_mask(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+			   AL_INT_GROUP_B, 0xF);
+	al_udma_iofic_mask(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+			   AL_INT_GROUP_C, 0xF);
+	al_udma_iofic_mask(regs_base, AL_UDMA_IOFIC_LEVEL_PRIMARY,
+			   AL_INT_GROUP_D, 0xFFFFFFFF);
+}
+
+static void al_eth_del_napi(struct al_eth_adapter *adapter)
+{
+	int i;
+	int napi_num = adapter->num_rx_queues + adapter->num_tx_queues;
+
+	for (i = 0; i < napi_num; i++)
+		netif_napi_del(&adapter->al_napi[i].napi);
+}
+
+static void al_eth_init_napi(struct al_eth_adapter *adapter)
+{
+	int i;
+	int napi_num = adapter->num_rx_queues + adapter->num_tx_queues;
+
+	for (i = 0; i < napi_num; i++) {
+		struct al_eth_napi *napi = &adapter->al_napi[i];
+		int (*poll)(struct napi_struct *, int);
+
+		if (i < adapter->num_rx_queues) {
+			poll = al_eth_rx_poll;
+			napi->qid = i;
+		} else {
+			poll = al_eth_tx_poll;
+			napi->qid = i - adapter->num_rx_queues;
+		}
+		netif_napi_add(adapter->netdev, &adapter->al_napi[i].napi,
+			       poll, 64);
+		napi->adapter = adapter;
+	}
+}
+
+static void al_eth_napi_disable_all(struct al_eth_adapter *adapter)
+{
+	int i;
+	int napi_num = adapter->num_rx_queues + adapter->num_tx_queues;
+
+	for (i = 0; i < napi_num; i++)
+		napi_disable(&adapter->al_napi[i].napi);
+}
+
+static void al_eth_napi_enable_all(struct al_eth_adapter *adapter)
+
+{
+	int i;
+	int napi_num = adapter->num_rx_queues + adapter->num_tx_queues;
+
+	for (i = 0; i < napi_num; i++)
+		napi_enable(&adapter->al_napi[i].napi);
+}
+
+/*
+ * init FSM, no tunneling supported yet, if packet is tcp/udp over ipv4/ipv6,
+ * use 4 tuple hash
+ */
+static void al_eth_fsm_table_init(struct al_eth_adapter *adapter)
+{
+	u32 val;
+	int i;
+
+	for (i = 0; i < AL_ETH_RX_FSM_TABLE_SIZE; i++) {
+		switch (AL_ETH_FSM_ENTRY_OUTER(i)) {
+		case AL_ETH_FSM_ENTRY_IPV4_TCP:
+		case AL_ETH_FSM_ENTRY_IPV4_UDP:
+		case AL_ETH_FSM_ENTRY_IPV6_TCP:
+		case AL_ETH_FSM_ENTRY_IPV6_UDP:
+			val = AL_ETH_FSM_DATA_OUTER_4_TUPLE | AL_ETH_FSM_DATA_HASH_SEL;
+			break;
+		case AL_ETH_FSM_ENTRY_IPV6_NO_UDP_TCP:
+		case AL_ETH_FSM_ENTRY_IPV4_NO_UDP_TCP:
+			val = AL_ETH_FSM_DATA_OUTER_2_TUPLE | AL_ETH_FSM_DATA_HASH_SEL;
+			break;
+		default:
+			val = (0 << AL_ETH_FSM_DATA_DEFAULT_Q_SHIFT |
+			      (BIT(0) << AL_ETH_FSM_DATA_DEFAULT_UDMA_SHIFT));
+		}
+		al_eth_fsm_table_set(&adapter->hw_adapter, i, val);
+	}
+}
+
+#define AL_ETH_MAC_TABLE_UNICAST_IDX_BASE	0
+#define AL_ETH_MAC_TABLE_UNICAST_MAX_COUNT	4
+#define AL_ETH_MAC_TABLE_ALL_MULTICAST_IDX	(AL_ETH_MAC_TABLE_UNICAST_IDX_BASE + \
+						 AL_ETH_MAC_TABLE_UNICAST_MAX_COUNT)
+
+#define AL_ETH_MAC_TABLE_DROP_IDX		(AL_ETH_FWD_MAC_NUM - 1)
+#define AL_ETH_MAC_TABLE_BROADCAST_IDX		(AL_ETH_MAC_TABLE_DROP_IDX - 1)
+
+#define MAC_ADDR_STR "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_ADDR(addr) addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]
+
+static void al_eth_mac_table_unicast_add(struct al_eth_adapter *adapter, u8 idx,
+					 u8 *addr, u8 udma_mask)
+{
+	struct al_eth_fwd_mac_table_entry entry = { { 0 } };
+
+	memcpy(entry.addr, adapter->mac_addr, sizeof(adapter->mac_addr));
+
+	memset(entry.mask, 0xff, sizeof(entry.mask));
+	entry.rx_valid = true;
+	entry.tx_valid = false;
+	entry.udma_mask = udma_mask;
+	entry.filter = false;
+
+	netdev_dbg(adapter->netdev, "[%d]: addr "MAC_ADDR_STR" mask "MAC_ADDR_STR"\n",
+		   idx, MAC_ADDR(entry.addr), MAC_ADDR(entry.mask));
+
+	al_eth_fwd_mac_table_set(&adapter->hw_adapter, idx, &entry);
+}
+
+static void al_eth_mac_table_all_multicast_add(struct al_eth_adapter *adapter,
+					       u8 idx, u8 udma_mask)
+{
+	struct al_eth_fwd_mac_table_entry entry = { { 0 } };
+
+	memset(entry.addr, 0x00, sizeof(entry.addr));
+	memset(entry.mask, 0x00, sizeof(entry.mask));
+	entry.mask[0] |= BIT(0);
+	entry.addr[0] |= BIT(0);
+
+	entry.rx_valid = true;
+	entry.tx_valid = false;
+	entry.udma_mask = udma_mask;
+	entry.filter = false;
+
+	netdev_dbg(adapter->netdev, "[%d]: addr "MAC_ADDR_STR" mask "MAC_ADDR_STR"\n",
+		   idx, MAC_ADDR(entry.addr), MAC_ADDR(entry.mask));
+
+	al_eth_fwd_mac_table_set(&adapter->hw_adapter, idx, &entry);
+}
+
+static void al_eth_mac_table_broadcast_add(struct al_eth_adapter *adapter,
+					   u8 idx, u8 udma_mask)
+{
+	struct al_eth_fwd_mac_table_entry entry = { { 0 } };
+
+	memset(entry.addr, 0xff, sizeof(entry.addr));
+	memset(entry.mask, 0xff, sizeof(entry.mask));
+
+	entry.rx_valid = true;
+	entry.tx_valid = false;
+	entry.udma_mask = udma_mask;
+	entry.filter = false;
+
+	netdev_dbg(adapter->netdev, "[%d]: addr "MAC_ADDR_STR" mask "MAC_ADDR_STR"\n",
+		   idx, MAC_ADDR(entry.addr), MAC_ADDR(entry.mask));
+
+	al_eth_fwd_mac_table_set(&adapter->hw_adapter, idx, &entry);
+}
+
+static void al_eth_mac_table_promiscuous_set(struct al_eth_adapter *adapter,
+					     bool promiscuous)
+{
+	struct al_eth_fwd_mac_table_entry entry = { { 0 } };
+
+	memset(entry.addr, 0x00, sizeof(entry.addr));
+	memset(entry.mask, 0x00, sizeof(entry.mask));
+
+	entry.rx_valid = true;
+	entry.tx_valid = false;
+	entry.udma_mask = (promiscuous) ? 1 : 0;
+	entry.filter = (promiscuous) ? false : true;
+
+	netdev_dbg(adapter->netdev, "%s promiscuous mode\n",
+		   (promiscuous) ? "enter" : "exit");
+
+	al_eth_fwd_mac_table_set(&adapter->hw_adapter,
+				 AL_ETH_MAC_TABLE_DROP_IDX,
+				 &entry);
+}
+
+static void al_eth_mac_table_entry_clear(struct al_eth_adapter *adapter, u8 idx)
+{
+	struct al_eth_fwd_mac_table_entry entry = { { 0 } };
+
+	al_eth_fwd_mac_table_set(&adapter->hw_adapter, idx, &entry);
+}
+
+/*
+ * Configure the RX forwarding (UDMA/QUEUE.. selection).
+ * Currently we don't use the full control table, we use only the default
+ * configuration.
+ */
+
+static void al_eth_config_rx_fwd(struct al_eth_adapter *adapter)
+{
+	struct al_eth_fwd_ctrl_table_entry entry;
+	int i;
+
+	/* let priority be equal to pbits */
+	for (i = 0; i < AL_ETH_FWD_PBITS_TABLE_NUM; i++)
+		al_eth_fwd_pbits_table_set(&adapter->hw_adapter, i, i);
+
+	/* map priority to queue index, queue id = priority/2 */
+	for (i = 0; i < AL_ETH_FWD_PRIO_TABLE_NUM; i++)
+		al_eth_fwd_priority_table_set(&adapter->hw_adapter, i, i >> 1);
+
+	entry.prio_sel = AL_ETH_CTRL_TABLE_PRIO_SEL_VAL_0;
+	entry.queue_sel_1 = AL_ETH_CTRL_TABLE_QUEUE_SEL_1_THASH_TABLE;
+	entry.queue_sel_2 = AL_ETH_CTRL_TABLE_QUEUE_SEL_2_NO_PRIO;
+	entry.udma_sel = AL_ETH_CTRL_TABLE_UDMA_SEL_MAC_TABLE;
+	entry.filter = false;
+
+	al_eth_ctrl_table_def_set(&adapter->hw_adapter, false, &entry);
+
+	/*
+	 * By default set the mac table to forward all unicast packets to our
+	 * MAC address and all broadcast. all the rest will be dropped.
+	 */
+	al_eth_mac_table_unicast_add(adapter, AL_ETH_MAC_TABLE_UNICAST_IDX_BASE,
+				     adapter->mac_addr, 1);
+	al_eth_mac_table_broadcast_add(adapter, AL_ETH_MAC_TABLE_BROADCAST_IDX, 1);
+	al_eth_mac_table_promiscuous_set(adapter, false);
+
+	/* set toeplitz hash keys */
+	get_random_bytes(adapter->toeplitz_hash_key,
+			 sizeof(adapter->toeplitz_hash_key));
+
+	for (i = 0; i < AL_ETH_RX_HASH_KEY_NUM; i++)
+		al_eth_hash_key_set(&adapter->hw_adapter, i,
+				    htonl(adapter->toeplitz_hash_key[i]));
+
+	for (i = 0; i < AL_ETH_RX_RSS_TABLE_SIZE; i++)
+		al_eth_thash_table_set(&adapter->hw_adapter, i, 0,
+				       adapter->rss_ind_tbl[i]);
+
+	al_eth_fsm_table_init(adapter);
+}
+
+static void al_eth_restore_ethtool_params(struct al_eth_adapter *adapter)
+{
+	int i;
+	unsigned int tx_usecs = adapter->tx_usecs;
+	unsigned int rx_usecs = adapter->rx_usecs;
+
+	adapter->tx_usecs = 0;
+	adapter->rx_usecs = 0;
+
+	for (i = 0; i < AL_ETH_RX_RSS_TABLE_SIZE; i++)
+		al_eth_thash_table_set(&adapter->hw_adapter, i, 0,
+				       adapter->rss_ind_tbl[i]);
+}
+
+static void al_eth_up_complete(struct al_eth_adapter *adapter)
+{
+	al_eth_configure_int_mode(adapter);
+
+	/* config rx fwd */
+	al_eth_config_rx_fwd(adapter);
+
+	al_eth_init_napi(adapter);
+	al_eth_napi_enable_all(adapter);
+
+	al_eth_change_mtu(adapter->netdev, adapter->netdev->mtu);
+	/* enable hw queues */
+	al_eth_udma_queues_enable_all(adapter);
+
+	al_eth_refill_all_rx_bufs(adapter);
+
+	al_eth_interrupts_unmask(adapter);
+
+	/* enable transmits */
+	netif_tx_start_all_queues(adapter->netdev);
+
+	/* enable flow control */
+	al_eth_flow_ctrl_enable(adapter);
+
+	al_eth_restore_ethtool_params(adapter);
+
+	/* enable the mac tx and rx paths */
+	al_eth_mac_start(&adapter->hw_adapter);
+}
+
+static int al_eth_up(struct al_eth_adapter *adapter)
+{
+	int rc;
+
+	if (adapter->flags & AL_ETH_FLAG_RESET_REQUESTED) {
+		al_eth_function_reset(adapter);
+		adapter->flags &= ~AL_ETH_FLAG_RESET_REQUESTED;
+	}
+
+	rc = al_eth_hw_init(adapter);
+	if (rc)
+		goto err_hw_init_open;
+
+	al_eth_setup_int_mode(adapter, IS_ENABLED(CONFIG_NET_AL_ETH_NO_MSIX));
+
+	/* allocate transmit descriptors */
+	rc = al_eth_setup_all_tx_resources(adapter);
+	if (rc)
+		goto err_setup_tx;
+
+	/* allocate receive descriptors */
+	rc = al_eth_setup_all_rx_resources(adapter);
+	if (rc)
+		goto err_setup_rx;
+
+	rc = al_eth_request_irq(adapter);
+	if (rc)
+		goto err_req_irq;
+
+	al_eth_up_complete(adapter);
+
+	adapter->up = true;
+
+	return rc;
+
+err_req_irq:
+	al_eth_free_all_rx_resources(adapter);
+err_setup_rx:
+	al_eth_free_all_tx_resources(adapter);
+err_setup_tx:
+	al_eth_free_irq(adapter);
+	al_eth_hw_stop(adapter);
+err_hw_init_open:
+	al_eth_function_reset(adapter);
+
+	return rc;
+}
+
+static void al_eth_down(struct al_eth_adapter *adapter)
+{
+	adapter->up = false;
+
+	netif_carrier_off(adapter->netdev);
+	al_eth_disable_int_sync(adapter);
+	al_eth_napi_disable_all(adapter);
+	netif_tx_disable(adapter->netdev);
+	al_eth_free_irq(adapter);
+	al_eth_hw_stop(adapter);
+	al_eth_del_napi(adapter);
+
+	al_eth_free_all_tx_bufs(adapter);
+	al_eth_free_all_rx_bufs(adapter);
+	al_eth_free_all_tx_resources(adapter);
+	al_eth_free_all_rx_resources(adapter);
+}
+
+/*
+ * al_eth_open - Called when a network interface is made active
+ * @netdev: network interface device structure
+ *
+ * Returns 0 on success, negative value on failure
+ *
+ * The open entry point is called when a network interface is made
+ * active by the system (IFF_UP).  At this point all resources needed
+ * for transmit and receive operations are allocated, the interrupt
+ * handler is registered with the OS, the watchdog timer is started,
+ * and the stack is notified that the interface is ready.
+ */
+static int al_eth_open(struct net_device *netdev)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	int rc;
+
+	netif_carrier_off(netdev);
+
+	/* Notify the stack of the actual queue counts. */
+	rc = netif_set_real_num_tx_queues(netdev, adapter->num_tx_queues);
+	if (rc)
+		return rc;
+
+	rc = netif_set_real_num_rx_queues(netdev, adapter->num_rx_queues);
+	if (rc)
+		return rc;
+
+	adapter->last_establish_failed = false;
+
+	rc = al_eth_up(adapter);
+	if (rc)
+		return rc;
+
+	if (adapter->phy_exist) {
+		rc = al_eth_mdiobus_setup(adapter);
+		if (rc) {
+			netdev_err(netdev, "failed at mdiobus setup!\n");
+			goto err_mdiobus_setup;
+		}
+	}
+
+	if (adapter->mdio_bus)
+		rc = al_eth_phy_init(adapter);
+	else
+		netif_carrier_on(adapter->netdev);
+
+	return rc;
+
+err_mdiobus_setup:
+	al_eth_down(adapter);
+
+	return rc;
+}
+
+/*
+ * al_eth_close - Disables a network interface
+ * @netdev: network interface device structure
+ *
+ * Returns 0, this is not allowed to fail
+ *
+ * The close entry point is called when an interface is de-activated
+ * by the OS.  The hardware is still under the drivers control, but
+ * needs to be disabled.  A global MAC reset is issued to stop the
+ * hardware, and all transmit and receive resources are freed.
+ */
+static int al_eth_close(struct net_device *netdev)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+
+	cancel_delayed_work_sync(&adapter->link_status_task);
+
+	if (adapter->phydev) {
+		phy_stop(adapter->phydev);
+		phy_disconnect(adapter->phydev);
+		al_eth_mdiobus_teardown(adapter);
+	}
+
+	if (adapter->up)
+		al_eth_down(adapter);
+
+	return 0;
+}
+
+static int al_eth_get_settings(struct net_device *netdev,
+			       struct ethtool_cmd *ecmd)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct phy_device *phydev = adapter->phydev;
+
+	if (phydev)
+		return phy_ethtool_gset(phydev, ecmd);
+
+	ecmd->speed = adapter->link_config.active_speed;
+	ecmd->duplex = adapter->link_config.active_duplex;
+	ecmd->autoneg = adapter->link_config.autoneg;
+
+	return 0;
+}
+
+static int al_eth_set_settings(struct net_device *netdev,
+			       struct ethtool_cmd *ecmd)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct phy_device *phydev = adapter->phydev;
+	int rc = 0;
+
+	if (phydev)
+		return phy_ethtool_sset(phydev, ecmd);
+
+	/* in case no phy exist set only mac parameters */
+	adapter->link_config.active_speed = ecmd->speed;
+	adapter->link_config.active_duplex = ecmd->duplex;
+	adapter->link_config.autoneg = ecmd->autoneg;
+
+	if (adapter->up)
+		dev_warn(&adapter->pdev->dev,
+			 "this action will take place in the next activation (up)\n");
+
+	return rc;
+}
+
+static int al_eth_nway_reset(struct net_device *netdev)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct phy_device *phydev = adapter->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_start_aneg(phydev);
+}
+
+static u32 al_eth_get_msglevel(struct net_device *netdev)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	return adapter->msg_enable;
+}
+
+static void al_eth_set_msglevel(struct net_device *netdev, u32 value)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+
+	adapter->msg_enable = value;
+}
+
+static void al_eth_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	struct al_eth_adapter *adapter = netdev_priv(dev);
+
+	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->bus_info, pci_name(adapter->pdev), sizeof(info->bus_info));
+}
+
+static void al_eth_get_pauseparam(struct net_device *netdev,
+				  struct ethtool_pauseparam *pause)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct al_eth_link_config *link_config = &adapter->link_config;
+
+	pause->autoneg = ((link_config->flow_ctrl_active &
+					AL_ETH_FLOW_CTRL_AUTONEG) != 0);
+	pause->rx_pause = ((link_config->flow_ctrl_active &
+					AL_ETH_FLOW_CTRL_RX_PAUSE) != 0);
+	pause->tx_pause = ((link_config->flow_ctrl_active &
+					AL_ETH_FLOW_CTRL_TX_PAUSE) != 0);
+}
+
+static int al_eth_set_pauseparam(struct net_device *netdev,
+				 struct ethtool_pauseparam *pause)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct al_eth_link_config *link_config = &adapter->link_config;
+	u32 newadv;
+
+	/* auto negotiation and receive pause are currently not supported */
+	if (pause->autoneg == AUTONEG_ENABLE)
+		return -EINVAL;
+
+	link_config->flow_ctrl_supported = 0;
+
+	if (pause->rx_pause) {
+		link_config->flow_ctrl_supported |= AL_ETH_FLOW_CTRL_RX_PAUSE;
+
+		if (pause->tx_pause) {
+			link_config->flow_ctrl_supported |= AL_ETH_FLOW_CTRL_TX_PAUSE;
+			newadv = ADVERTISED_Pause;
+		} else
+			newadv = ADVERTISED_Pause |
+				 ADVERTISED_Asym_Pause;
+	} else if (pause->tx_pause) {
+		link_config->flow_ctrl_supported |= AL_ETH_FLOW_CTRL_TX_PAUSE;
+		newadv = ADVERTISED_Asym_Pause;
+	} else {
+		newadv = 0;
+	}
+
+	if (pause->autoneg) {
+		struct phy_device *phydev;
+		u32 oldadv;
+
+		phydev = mdiobus_get_phy(adapter->mdio_bus, adapter->phy_addr);
+		oldadv = phydev->advertising &
+				     (ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+		link_config->flow_ctrl_supported |= AL_ETH_FLOW_CTRL_AUTONEG;
+
+		if (oldadv != newadv) {
+			phydev->advertising &= ~(ADVERTISED_Pause |
+							ADVERTISED_Asym_Pause);
+			phydev->advertising |= newadv;
+
+			if (phydev->autoneg)
+				return phy_start_aneg(phydev);
+		}
+	} else {
+		link_config->flow_ctrl_active = link_config->flow_ctrl_supported;
+		al_eth_flow_ctrl_config(adapter);
+	}
+
+	return 0;
+}
+
+static int al_eth_get_rxnfc(struct net_device *netdev,
+			    struct ethtool_rxnfc *info,
+			    u32 *rules __always_unused)
+{
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = AL_ETH_NUM_QUEUES;
+		return 0;
+	default:
+		netdev_err(netdev, "Command parameters not supported\n");
+		return -EOPNOTSUPP;
+	}
+}
+
+static u32 al_eth_get_rxfh_indir_size(struct net_device *netdev)
+{
+	return AL_ETH_RX_RSS_TABLE_SIZE;
+}
+
+static const struct ethtool_ops al_eth_ethtool_ops = {
+	.get_settings		= al_eth_get_settings,
+	.set_settings		= al_eth_set_settings,
+	.get_drvinfo		= al_eth_get_drvinfo,
+	.get_msglevel		= al_eth_get_msglevel,
+	.set_msglevel		= al_eth_set_msglevel,
+
+	.nway_reset		= al_eth_nway_reset,
+	.get_link		= ethtool_op_get_link,
+	.get_pauseparam		= al_eth_get_pauseparam,
+	.set_pauseparam		= al_eth_set_pauseparam,
+	.get_rxnfc		= al_eth_get_rxnfc,
+	.get_rxfh_indir_size    = al_eth_get_rxfh_indir_size,
+};
+
+static void al_eth_tx_csum(struct al_eth_ring *tx_ring,
+			   struct al_eth_tx_buffer *tx_info,
+			   struct al_eth_pkt *hw_pkt, struct sk_buff *skb)
+{
+	u32 mss = skb_shinfo(skb)->gso_size;
+
+	if ((skb->ip_summed == CHECKSUM_PARTIAL) || mss) {
+		struct al_eth_meta_data *meta = &tx_ring->hw_meta;
+		if (mss)
+			hw_pkt->flags |= AL_ETH_TX_FLAGS_TSO |
+					 AL_ETH_TX_FLAGS_L4_CSUM;
+		else
+			hw_pkt->flags |= AL_ETH_TX_FLAGS_L4_CSUM |
+					 AL_ETH_TX_FLAGS_L4_PARTIAL_CSUM;
+
+		switch (skb->protocol) {
+		case htons(ETH_P_IP):
+			hw_pkt->l3_proto_idx = AL_ETH_PROTO_ID_IPv4;
+			if (mss)
+				hw_pkt->flags |= AL_ETH_TX_FLAGS_IPV4_L3_CSUM;
+			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+				hw_pkt->l4_proto_idx = AL_ETH_PROTO_ID_TCP;
+			else
+				hw_pkt->l4_proto_idx = AL_ETH_PROTO_ID_UDP;
+			break;
+		case htons(ETH_P_IPV6):
+			hw_pkt->l3_proto_idx = AL_ETH_PROTO_ID_IPv6;
+			if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+				hw_pkt->l4_proto_idx = AL_ETH_PROTO_ID_TCP;
+			else
+				hw_pkt->l4_proto_idx = AL_ETH_PROTO_ID_UDP;
+			break;
+		default:
+			break;
+		}
+
+		meta->words_valid = 4;
+		meta->l3_header_len = skb_network_header_len(skb);
+		meta->l3_header_offset = skb_network_offset(skb);
+		meta->l4_header_len = tcp_hdr(skb)->doff; /* only for TSO */
+		meta->mss_idx_sel = 0;
+		meta->mss_val = skb_shinfo(skb)->gso_size;
+		hw_pkt->meta = meta;
+	} else {
+		hw_pkt->meta = NULL;
+	}
+}
+
+/* Called with netif_tx_lock. */
+static netdev_tx_t al_eth_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
+{
+	struct al_eth_adapter *adapter = netdev_priv(dev);
+	dma_addr_t dma;
+	struct al_eth_tx_buffer *tx_info;
+	struct al_eth_pkt *hw_pkt;
+	struct al_buf *al_buf;
+	u32 len, last_frag;
+	u16 next_to_use;
+	int i, qid;
+	struct al_eth_ring *tx_ring;
+	struct netdev_queue *txq;
+
+	/*  Determine which tx ring we will be placed on */
+	qid = skb_get_queue_mapping(skb);
+	tx_ring = &adapter->tx_ring[qid];
+	txq = netdev_get_tx_queue(dev, qid);
+
+	len = skb_headlen(skb);
+
+	dma = dma_map_single(tx_ring->dev, skb->data, len, DMA_TO_DEVICE);
+	if (dma_mapping_error(tx_ring->dev, dma)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	next_to_use = tx_ring->next_to_use;
+	tx_info = &tx_ring->tx_buffer_info[next_to_use];
+	tx_info->skb = skb;
+	hw_pkt = &tx_info->hw_pkt;
+
+	/* set flags and meta data */
+	hw_pkt->flags = AL_ETH_TX_FLAGS_INT;
+	al_eth_tx_csum(tx_ring, tx_info, hw_pkt, skb);
+
+	al_buf = hw_pkt->bufs;
+
+	dma_unmap_addr_set(al_buf, addr, dma);
+	dma_unmap_len_set(al_buf, len, len);
+
+	last_frag = skb_shinfo(skb)->nr_frags;
+
+	for (i = 0; i < last_frag; i++) {
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		al_buf++;
+
+		len = skb_frag_size(frag);
+		dma = skb_frag_dma_map(tx_ring->dev, frag, 0, len,
+				       DMA_TO_DEVICE);
+		if (dma_mapping_error(tx_ring->dev, dma))
+			goto dma_error;
+		dma_unmap_addr_set(al_buf, addr, dma);
+		dma_unmap_len_set(al_buf, len, len);
+	}
+
+	hw_pkt->num_of_bufs = 1 + last_frag;
+	if (unlikely(last_frag > (AL_ETH_PKT_MAX_BUFS - 2))) {
+		int i;
+
+		netdev_err(adapter->netdev,
+			   "too much descriptors. last_frag %d!\n", last_frag);
+		for (i = 0; i <= last_frag; i++)
+			netdev_err(adapter->netdev,
+				   "frag[%d]: addr:0x%llx, len 0x%x\n", i,
+				   (unsigned long long)hw_pkt->bufs[i].addr,
+				   hw_pkt->bufs[i].len);
+	}
+	netdev_tx_sent_queue(txq, skb->len);
+
+	tx_ring->next_to_use = AL_ETH_TX_RING_IDX_NEXT(tx_ring, next_to_use);
+
+	/* prepare the packet's descriptors to dma engine */
+	tx_info->tx_descs = al_eth_tx_pkt_prepare(&adapter->hw_adapter,
+						  tx_ring->dma_q, hw_pkt);
+
+	/*
+	 * stop the queue when no more space available, the packet can have up
+	 * to MAX_SKB_FRAGS + 1 buffers and a meta descriptor
+	 */
+	if (unlikely(al_udma_available_get(tx_ring->dma_q) <
+				(MAX_SKB_FRAGS + 2))) {
+		netdev_dbg(adapter->netdev, "stop queue %d\n", qid);
+		netif_tx_stop_queue(txq);
+	}
+
+	/* trigger the dma engine */
+	al_eth_tx_dma_action(tx_ring->dma_q, tx_info->tx_descs);
+
+	return NETDEV_TX_OK;
+
+dma_error:
+	/* save value of frag that failed */
+	last_frag = i;
+
+	/* start back at beginning and unmap skb */
+	tx_info->skb = NULL;
+	al_buf = hw_pkt->bufs;
+	dma_unmap_single(tx_ring->dev, dma_unmap_addr(al_buf, addr),
+			 dma_unmap_len(al_buf, len), DMA_TO_DEVICE);
+
+	/* unmap remaining mapped pages */
+	for (i = 0; i < last_frag; i++) {
+		al_buf++;
+		dma_unmap_page(tx_ring->dev, dma_unmap_addr(al_buf, addr),
+			       dma_unmap_len(al_buf, len), DMA_TO_DEVICE);
+	}
+
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+/* Return subqueue id on this core (one per core). */
+static u16 al_eth_select_queue(struct net_device *dev, struct sk_buff *skb,
+			       void *accel_priv,
+			       select_queue_fallback_t fallback)
+{
+	u16 qid = skb_rx_queue_recorded(skb);
+
+	if (!qid)
+		return fallback(dev, skb);
+
+	return qid;
+}
+
+static int al_eth_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct al_eth_adapter *adapter = netdev_priv(dev);
+	struct sockaddr *addr = p;
+	int err = 0;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	memcpy(adapter->mac_addr, addr->sa_data, dev->addr_len);
+	al_eth_mac_table_unicast_add(adapter, AL_ETH_MAC_TABLE_UNICAST_IDX_BASE,
+				     adapter->mac_addr, 1);
+
+	if (!netif_running(dev))
+		return 0;
+
+	return err;
+}
+
+/*
+ *  Unicast, Multicast and Promiscuous mode set
+ *  @netdev: network interface device structure
+ *
+ *  The set_rx_mode entry point is called whenever the unicast or multicast
+ *  address lists or the network interface flags are updated.  This routine is
+ *  responsible for configuring the hardware for proper unicast, multicast,
+ *  promiscuous mode, and all-multi behavior.
+ */
+static void al_eth_set_rx_mode(struct net_device *netdev)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+
+	if (netdev->flags & IFF_PROMISC) {
+		al_eth_mac_table_promiscuous_set(adapter, true);
+	} else {
+		if (netdev->flags & IFF_ALLMULTI) {
+			al_eth_mac_table_all_multicast_add(adapter,
+							   AL_ETH_MAC_TABLE_ALL_MULTICAST_IDX,
+							   1);
+		} else {
+			if (netdev_mc_empty(netdev))
+				al_eth_mac_table_entry_clear(adapter,
+					AL_ETH_MAC_TABLE_ALL_MULTICAST_IDX);
+			else
+				al_eth_mac_table_all_multicast_add(adapter,
+								   AL_ETH_MAC_TABLE_ALL_MULTICAST_IDX,
+								   1);
+		}
+
+		if (!netdev_uc_empty(netdev)) {
+			struct netdev_hw_addr *ha;
+			u8 i = AL_ETH_MAC_TABLE_UNICAST_IDX_BASE + 1;
+
+			if (netdev_uc_count(netdev) >
+				AL_ETH_MAC_TABLE_UNICAST_MAX_COUNT) {
+				/*
+				 * In this case there are more addresses then
+				 * entries in the mac table - set promiscuous
+				 */
+				al_eth_mac_table_promiscuous_set(adapter, true);
+				return;
+			}
+
+			/* clear the last configuration */
+			while (i < (AL_ETH_MAC_TABLE_UNICAST_IDX_BASE + 1 +
+				    AL_ETH_MAC_TABLE_UNICAST_MAX_COUNT)) {
+				al_eth_mac_table_entry_clear(adapter, i);
+				i++;
+			}
+
+			/* set new addresses */
+			i = AL_ETH_MAC_TABLE_UNICAST_IDX_BASE + 1;
+			netdev_for_each_uc_addr(ha, netdev) {
+				al_eth_mac_table_unicast_add(adapter, i,
+							     ha->addr, 1);
+				i++;
+			}
+		}
+
+		al_eth_mac_table_promiscuous_set(adapter, false);
+	}
+}
+
+static const struct net_device_ops al_eth_netdev_ops = {
+	.ndo_open		= al_eth_open,
+	.ndo_stop		= al_eth_close,
+	.ndo_start_xmit		= al_eth_start_xmit,
+	.ndo_select_queue	= al_eth_select_queue,
+	.ndo_do_ioctl		= al_eth_ioctl,
+	.ndo_tx_timeout		= al_eth_tx_timeout,
+	.ndo_change_mtu		= al_eth_change_mtu,
+	.ndo_set_mac_address	= al_eth_set_mac_addr,
+	.ndo_set_rx_mode	= al_eth_set_rx_mode,
+};
+
+/*
+ * al_eth_probe - Device Initialization Routine
+ * @pdev: PCI device information struct
+ * @ent: entry in al_eth_pci_tbl
+ *
+ * Returns 0 on success, negative on failure
+ *
+ * al_eth_probe initializes an adapter identified by a pci_dev structure.
+ * The OS initialization, configuring of the adapter private structure,
+ * and a hardware reset occur.
+ */
+static int al_eth_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	struct net_device *netdev;
+	struct al_eth_adapter *adapter;
+	void __iomem * const *iomap;
+	struct al_hw_eth_adapter *hw_adapter;
+	static int adapters_found;
+	u16 dev_id;
+	u8 rev_id;
+	int rc, i;
+
+	rc = pcim_enable_device(pdev);
+	if (rc) {
+		dev_err(&pdev->dev, "pcim_enable_device failed!\n");
+		return rc;
+	}
+
+	if (ent->driver_data == ALPINE_INTEGRATED)
+		rc = pcim_iomap_regions(pdev, BIT(0) | BIT(2) | BIT(4),
+					DRV_MODULE_NAME);
+	else
+		rc = pcim_iomap_regions(pdev,
+					BIT(board_info[ent->driver_data].bar),
+					DRV_MODULE_NAME);
+
+	if (rc) {
+		dev_err(&pdev->dev,
+			"pci_request_selected_regions failed 0x%x\n", rc);
+		return rc;
+	}
+
+	iomap = pcim_iomap_table(pdev);
+	if (!iomap) {
+		dev_err(&pdev->dev, "pcim_iomap_table failed\n");
+		return -ENOMEM;
+	}
+
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(40));
+	if (rc) {
+		dev_err(&pdev->dev, "pci_set_dma_mask failed 0x%x\n", rc);
+		return rc;
+	}
+
+	rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(40));
+	if (rc) {
+		dev_err(&pdev->dev,
+			"err_pci_set_consistent_dma_mask failed 0x%x\n", rc);
+		return rc;
+	}
+
+	pci_set_master(pdev);
+	pci_save_state(pdev);
+
+	/* dev zeroed in init_etherdev */
+	netdev = alloc_etherdev_mq(sizeof(struct al_eth_adapter),
+				   AL_ETH_NUM_QUEUES);
+	if (!netdev) {
+		dev_err(&pdev->dev, "alloc_etherdev_mq failed\n");
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	adapter = netdev_priv(netdev);
+	pci_set_drvdata(pdev, adapter);
+
+	adapter->netdev = netdev;
+	adapter->pdev = pdev;
+	hw_adapter = &adapter->hw_adapter;
+	adapter->msg_enable = netif_msg_init(-1, DEFAULT_MSG_ENABLE);
+
+	adapter->udma_base = iomap[AL_ETH_UDMA_BAR];
+	adapter->ec_base = iomap[AL_ETH_EC_BAR];
+	adapter->mac_base = iomap[AL_ETH_MAC_BAR];
+
+	pci_read_config_word(pdev, PCI_DEVICE_ID, &dev_id);
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &rev_id);
+
+	adapter->rev_id = rev_id;
+	adapter->dev_id = dev_id;
+	adapter->id_number = adapters_found;
+
+	/* set default ring sizes */
+	adapter->tx_ring_count = AL_ETH_DEFAULT_TX_SW_DESCS;
+	adapter->tx_descs_count = AL_ETH_DEFAULT_TX_HW_DESCS;
+	adapter->rx_ring_count = AL_ETH_DEFAULT_RX_DESCS;
+	adapter->rx_descs_count = AL_ETH_DEFAULT_RX_DESCS;
+
+	adapter->num_tx_queues = AL_ETH_NUM_QUEUES;
+	adapter->num_rx_queues = AL_ETH_NUM_QUEUES;
+
+	adapter->rx_copybreak = AL_ETH_DEFAULT_SMALL_PACKET_LEN;
+	adapter->link_poll_interval = AL_ETH_DEFAULT_LINK_POLL_INTERVAL;
+	adapter->max_rx_buff_alloc_size = AL_ETH_DEFAULT_MAX_RX_BUFF_ALLOC_SIZE;
+	adapter->link_config.force_1000_base_x = AL_ETH_DEFAULT_FORCE_1000_BASEX;
+
+	snprintf(adapter->name, AL_ETH_NAME_MAX_LEN, "al_eth_%d",
+		 adapter->id_number);
+	rc = al_eth_board_params_init(adapter);
+	if (rc)
+		goto err_hw_init;
+
+	al_eth_function_reset(adapter);
+
+	rc = al_eth_hw_init_adapter(adapter);
+	if (rc)
+		goto err_hw_init;
+
+	al_eth_init_rings(adapter);
+
+	netdev->netdev_ops = &al_eth_netdev_ops;
+	netdev->watchdog_timeo = TX_TIMEOUT;
+	netdev->ethtool_ops = &al_eth_ethtool_ops;
+
+	if (!is_valid_ether_addr(adapter->mac_addr)) {
+		eth_hw_addr_random(netdev);
+		memcpy(adapter->mac_addr, netdev->dev_addr, ETH_ALEN);
+	} else {
+		memcpy(netdev->dev_addr, adapter->mac_addr, ETH_ALEN);
+	}
+
+	memcpy(adapter->netdev->perm_addr, adapter->mac_addr, netdev->addr_len);
+
+	netdev->hw_features = NETIF_F_SG |
+			      NETIF_F_IP_CSUM |
+			      NETIF_F_IPV6_CSUM |
+			      NETIF_F_TSO |
+			      NETIF_F_TSO_ECN |
+			      NETIF_F_TSO6 |
+			      NETIF_F_RXCSUM |
+			      NETIF_F_NTUPLE |
+			      NETIF_F_RXHASH |
+			      NETIF_F_HIGHDMA;
+
+	netdev->features = netdev->hw_features;
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
+	for (i = 0; i < AL_ETH_RX_RSS_TABLE_SIZE; i++)
+		adapter->rss_ind_tbl[i] =
+			ethtool_rxfh_indir_default(i, AL_ETH_NUM_QUEUES);
+
+	rc = register_netdev(netdev);
+	if (rc) {
+		dev_err(&pdev->dev, "Cannot register net device\n");
+		goto err_register;
+	}
+
+	netdev_info(netdev, "%s found at mem %lx, mac addr %pM\n",
+		    board_info[ent->driver_data].name,
+		    (long)pci_resource_start(pdev, 0), netdev->dev_addr);
+
+	adapters_found++;
+	return 0;
+err_register:
+err_hw_init:
+	free_netdev(netdev);
+	return rc;
+}
+
+/*
+ * al_eth_remove - Device Removal Routine
+ * @pdev: PCI device information struct
+ *
+ * al_eth_remove is called by the PCI subsystem to alert the driver
+ * that it should release a PCI device.
+ */
+static void al_eth_remove(struct pci_dev *pdev)
+{
+	struct al_eth_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *dev = adapter->netdev;
+
+	al_eth_hw_stop(adapter);
+
+	unregister_netdev(dev);
+
+	free_netdev(dev);
+
+	pci_set_drvdata(pdev, NULL);
+	pci_disable_device(pdev);
+}
+
+#ifdef CONFIG_PM
+static int al_eth_resume(struct pci_dev *pdev)
+{
+	struct al_eth_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
+	u32 err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	/*
+	 * pci_restore_state clears dev->state_saved so call
+	 * pci_save_state to restore it.
+	 */
+	pci_save_state(pdev);
+
+	err = pci_enable_device_mem(pdev);
+	if (err) {
+		netdev_err(adapter->netdev,
+			   "Cannot enable PCI device from suspend\n");
+		return err;
+	}
+	pci_set_master(pdev);
+
+	pci_wake_from_d3(pdev, false);
+
+	al_eth_wol_disable(&adapter->hw_adapter);
+
+	netif_device_attach(netdev);
+
+	return 0;
+}
+
+static int al_eth_wol_config(struct al_eth_adapter *adapter)
+{
+	struct al_eth_wol_params wol = {0};
+
+	if (adapter->wol & WAKE_UCAST) {
+		wol.int_mask = AL_ETH_WOL_INT_UNICAST;
+		wol.forward_mask = AL_ETH_WOL_FWRD_UNICAST;
+	}
+
+	if (adapter->wol & WAKE_MCAST) {
+		wol.int_mask = AL_ETH_WOL_INT_MULTICAST;
+		wol.forward_mask = AL_ETH_WOL_FWRD_MULTICAST;
+	}
+
+	if (adapter->wol & WAKE_BCAST) {
+		wol.int_mask = AL_ETH_WOL_INT_BROADCAST;
+		wol.forward_mask = AL_ETH_WOL_FWRD_BROADCAST;
+	}
+
+	if (wol.int_mask != 0) {
+		al_eth_wol_enable(&adapter->hw_adapter, &wol);
+		return 1;
+	}
+
+	return 0;
+}
+
+static int al_eth_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct al_eth_adapter *adapter = pci_get_drvdata(pdev);
+
+	if (al_eth_wol_config(adapter)) {
+		pci_prepare_to_sleep(pdev);
+	} else {
+		pci_wake_from_d3(pdev, false);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
+
+	return 0;
+}
+#endif /* CONFIG_PM */
+
+static struct pci_driver al_eth_pci_driver = {
+	.name		= DRV_MODULE_NAME,
+	.id_table	= al_eth_pci_tbl,
+	.probe		= al_eth_probe,
+	.remove		= al_eth_remove,
+#ifdef CONFIG_PM
+	.suspend	= al_eth_suspend,
+	.resume		= al_eth_resume,
+#endif
+};
+
+static int __init al_eth_init(void)
+{
+	return pci_register_driver(&al_eth_pci_driver);
+}
+
+static void __exit al_eth_cleanup(void)
+{
+	pci_unregister_driver(&al_eth_pci_driver);
+}
+
+module_init(al_eth_init);
+module_exit(al_eth_cleanup);
diff --git a/drivers/net/ethernet/annapurna/al_eth.h b/drivers/net/ethernet/annapurna/al_eth.h
new file mode 100644
index 000000000000..8a2d8ffa3ff1
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/al_eth.h
@@ -0,0 +1,282 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef AL_ETH_H
+#define AL_ETH_H
+
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/inetdevice.h>
+
+#include "al_hw_eth.h"
+#include <linux/soc/alpine/al_hw_udma_iofic.h>
+
+enum board_t {
+	ALPINE_INTEGRATED = 0,
+	ALPINE_NIC = 1,
+};
+
+#define AL_ETH_MAX_HW_QUEUES	4
+#define AL_ETH_NUM_QUEUES	4
+#define AL_ETH_MAX_MSIX_VEC	(1 + 2 * AL_ETH_MAX_HW_QUEUES)
+
+#define AL_ETH_DEFAULT_TX_SW_DESCS	(512)
+#define AL_ETH_DEFAULT_TX_HW_DESCS	(512)
+#define AL_ETH_DEFAULT_RX_DESCS		(512)
+
+#if ((AL_ETH_DEFAULT_TX_SW_DESCS / 4) < (MAX_SKB_FRAGS + 2))
+#define AL_ETH_TX_WAKEUP_THRESH		(AL_ETH_DEFAULT_TX_SW_DESCS / 4)
+#else
+#define AL_ETH_TX_WAKEUP_THRESH		(MAX_SKB_FRAGS + 2)
+#endif
+#define AL_ETH_DEFAULT_SMALL_PACKET_LEN		(128 - NET_IP_ALIGN)
+
+#define AL_ETH_DEFAULT_MAX_RX_BUFF_ALLOC_SIZE 1536
+/*
+ * minimum the buffer size to 600 to avoid situation the mtu will be changed
+ * from too little buffer to very big one and then the number of buffer per
+ * packet could reach the maximum AL_ETH_PKT_MAX_BUFS
+ */
+#define AL_ETH_DEFAULT_MIN_RX_BUFF_ALLOC_SIZE 600
+#define AL_ETH_DEFAULT_FORCE_1000_BASEX false
+
+#define AL_ETH_DEFAULT_LINK_POLL_INTERVAL 100
+
+#define AL_ETH_NAME_MAX_LEN	20
+#define AL_ETH_IRQNAME_SIZE	40
+
+#define AL_ETH_MAX_MTU			9216
+
+struct al_eth_irq {
+	irq_handler_t	handler;
+	void		*data;
+	unsigned int	vector;
+	u8		requested;
+	cpumask_t	affinity_hint_mask;
+	char		name[AL_ETH_IRQNAME_SIZE];
+};
+
+struct al_eth_napi {
+	struct napi_struct napi ____cacheline_aligned;
+	struct al_eth_adapter *adapter;
+	unsigned int qid;
+};
+
+struct al_eth_tx_buffer {
+	struct sk_buff *skb;
+	struct al_eth_pkt hw_pkt;
+	unsigned int tx_descs;
+};
+
+struct al_eth_rx_buffer {
+	struct sk_buff *skb;
+	struct page *page;
+	unsigned int page_offset;
+	u8 *data;
+	unsigned int data_size;
+	unsigned int frag_size; /* used in rx skb allocation */
+	DEFINE_DMA_UNMAP_ADDR(dma);
+	struct al_buf	al_buf;
+};
+
+#define AL_ETH_RX_OFFSET	(NET_SKB_PAD + NET_IP_ALIGN)
+
+struct al_eth_ring {
+	struct device *dev;
+	struct napi_struct *napi;
+	struct al_eth_pkt hw_pkt;
+	struct al_udma_q *dma_q; /* udma queue handler */
+	u16 next_to_use;
+	u16 next_to_clean;
+	u32 __iomem *unmask_reg_offset; /* the offset of the interrupt unmask register */
+	/*
+	 * the value to write to the above register to unmask the interrupt
+	 * of this ring
+	 */
+	u32 unmask_val;
+	/* need to use union here */
+	struct al_eth_meta_data hw_meta;
+	struct al_eth_tx_buffer *tx_buffer_info; /* contex of tx packet */
+	struct al_eth_rx_buffer *rx_buffer_info; /* contex of rx packet */
+	int sw_count; /* number of tx/rx_buffer_info's entries */
+	int hw_count; /* number of hw descriptors */
+	size_t descs_size; /* size (in bytes) of hw descriptors */
+	/* size (in bytes) of hw completion descriptors, used for rx */
+	size_t cdescs_size;
+
+	struct net_device *netdev;
+	struct al_udma_q_params	q_params;
+};
+
+#define AL_ETH_TX_RING_IDX_NEXT(tx_ring, idx) (((idx) + 1) & (AL_ETH_DEFAULT_TX_SW_DESCS - 1))
+
+#define AL_ETH_RX_RING_IDX_NEXT(rx_ring, idx) (((idx) + 1) & (AL_ETH_DEFAULT_RX_DESCS - 1))
+#define AL_ETH_RX_RING_IDX_ADD(rx_ring, idx, n) (((idx) + (n)) & (AL_ETH_DEFAULT_RX_DESCS - 1))
+
+/* flow control configuration */
+#define AL_ETH_FLOW_CTRL_RX_FIFO_TH_HIGH	0x160
+#define AL_ETH_FLOW_CTRL_RX_FIFO_TH_LOW		0x90
+#define AL_ETH_FLOW_CTRL_QUANTA			0xffff
+#define AL_ETH_FLOW_CTRL_QUANTA_TH		0x8000
+
+#define AL_ETH_FLOW_CTRL_AUTONEG  BIT(0)
+#define AL_ETH_FLOW_CTRL_RX_PAUSE BIT(1)
+#define AL_ETH_FLOW_CTRL_TX_PAUSE BIT(2)
+
+/* link configuration for 1G port */
+struct al_eth_link_config {
+	int old_link;
+	/* Describes what we actually have. */
+	int active_duplex;
+	int active_speed;
+
+	/* current flow control status */
+	u8 flow_ctrl_active;
+	/* supported configuration (can be changed from ethtool) */
+	u8 flow_ctrl_supported;
+
+	/* the following are not relevant to RGMII */
+	bool force_1000_base_x;
+	bool autoneg;
+};
+
+/* SFP detection event */
+enum al_eth_sfp_detect_evt {
+	/* No change (no connect, disconnect, or new SFP module */
+	AL_ETH_SFP_DETECT_EVT_NO_CHANGE,
+	/* SFP module connected */
+	AL_ETH_SFP_DETECT_EVT_CONNECTED,
+	/* SFP module disconnected */
+	AL_ETH_SFP_DETECT_EVT_DISCONNECTED,
+	/* SFP module replaced */
+	AL_ETH_SFP_DETECT_EVT_CHANGED,
+};
+
+/* Retimer parameters */
+struct al_eth_retimer_params {
+	bool				exist;
+	enum al_eth_retimer_type	type;
+	u8				bus_id;
+	u8				i2c_addr;
+	enum al_eth_retimer_channel	channel;
+	enum al_eth_retimer_channel	tx_channel;
+};
+
+/* board specific private data structure */
+struct al_eth_adapter {
+	/* OS defined structs */
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+	u16 dev_id;
+	u8 rev_id;
+
+	/*
+	 * Some features need tri-state capability,
+	 * thus the additional *_CAPABLE flags.
+	 */
+	u32 flags;
+#define AL_ETH_FLAG_MSIX_ENABLED	BIT(2)
+#define AL_ETH_FLAG_RESET_REQUESTED	BIT(7)
+
+	struct al_hw_eth_adapter hw_adapter;
+
+	/*
+	 * rx packets that shorter that this len will be copied to the skb
+	 * header
+	 */
+	unsigned int rx_copybreak;
+
+	/* Maximum size for rx buffer */
+	unsigned int max_rx_buff_alloc_size;
+
+	/* Tx fast path data */
+	int num_tx_queues;
+
+	/* Rx fast path data */
+	int num_rx_queues;
+
+	/* TX */
+	struct al_eth_ring tx_ring[AL_ETH_NUM_QUEUES] ____cacheline_aligned_in_smp;
+
+	/* RX */
+	struct al_eth_ring rx_ring[AL_ETH_NUM_QUEUES];
+
+#define AL_ETH_RXQ_NAPI_IDX(adapter, q)	(q)
+#define AL_ETH_TXQ_NAPI_IDX(adapter, q)	((adapter)->num_rx_queues + (q))
+	struct al_eth_napi al_napi[2 * AL_ETH_NUM_QUEUES];
+
+	enum al_iofic_mode int_mode;
+
+#define AL_ETH_MGMT_IRQ_IDX		0
+#define AL_ETH_RXQ_IRQ_IDX(adapter, q)	(1 + (q))
+#define AL_ETH_TXQ_IRQ_IDX(adapter, q)	(1 + (adapter)->num_rx_queues + (q))
+	struct al_eth_irq irq_tbl[AL_ETH_MAX_MSIX_VEC];
+	struct msix_entry *msix_entries;
+	int msix_vecs;
+	int irq_vecs;
+
+	unsigned int tx_usecs, rx_usecs; /* interrupt coalescing */
+
+	unsigned int tx_ring_count;
+	unsigned int tx_descs_count;
+	unsigned int rx_ring_count;
+	unsigned int rx_descs_count;
+
+	/* RSS*/
+	u32 toeplitz_hash_key[AL_ETH_RX_HASH_KEY_NUM];
+#define AL_ETH_RX_RSS_TABLE_SIZE AL_ETH_RX_THASH_TABLE_SIZE
+	u8  rss_ind_tbl[AL_ETH_RX_RSS_TABLE_SIZE];
+
+	u32 msg_enable;
+	struct al_eth_mac_stats mac_stats;
+
+	enum al_eth_mac_mode mac_mode;
+	u8 mac_addr[ETH_ALEN];
+	/* mdio and phy*/
+	bool phy_exist;
+	struct mii_bus *mdio_bus;
+	struct phy_device *phydev;
+	u8 phy_addr;
+	struct al_eth_link_config link_config;
+
+	int id_number;
+	char name[AL_ETH_NAME_MAX_LEN];
+	void __iomem *internal_pcie_base; /* use for ALPINE_NIC devices */
+	void __iomem *udma_base;
+	void __iomem *ec_base;
+	void __iomem *mac_base;
+
+	struct al_eth_flow_control_params flow_ctrl_params;
+
+	struct al_eth_adapter_params eth_hw_params;
+
+	struct delayed_work link_status_task;
+	u32 link_poll_interval; /* task interval in mSec */
+
+	bool an_en;	/* run kr auto-negotiation */
+	bool lt_en;	/* run kr link-training */
+
+	bool sfp_detection_needed; /* true if need to run sfp detection */
+	u8 i2c_adapter_id; /* identifier for the i2c adapter to use to access SFP+ module */
+	enum al_eth_ref_clk_freq	ref_clk_freq; /* reference clock frequency */
+	unsigned int	mdio_freq; /* MDIO frequency [Khz] */
+	enum al_eth_board_ext_phy_if phy_if;
+
+	bool up;
+
+	bool last_link;
+	bool last_establish_failed;
+
+	u32 wol;
+
+	struct al_eth_retimer_params retimer;
+};
+
+#endif /* !(AL_ETH_H) */
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth.h b/drivers/net/ethernet/annapurna/al_hw_eth.h
new file mode 100644
index 000000000000..b2fc58793b3a
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/al_hw_eth.h
@@ -0,0 +1,1264 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_ETH_H__
+#define __AL_HW_ETH_H__
+
+#include <linux/types.h>
+#include <linux/soc/alpine/al_hw_udma.h>
+
+#ifndef AL_ETH_PKT_MAX_BUFS
+#ifndef AL_ETH_EX
+#define AL_ETH_PKT_MAX_BUFS 19
+#else
+#define AL_ETH_PKT_MAX_BUFS 30
+#endif
+#endif
+
+#define AL_ETH_UDMA_TX_QUEUES		4
+#define AL_ETH_UDMA_RX_QUEUES		4
+
+#define AL_ETH_UDMA_TX_CDESC_SZ		8
+#define AL_ETH_UDMA_RX_CDESC_SZ		16
+
+/* PCI Adapter Device/Revision ID */
+#define AL_ETH_REV_ID_1			1 /* Alpine V1 */
+#define AL_ETH_REV_ID_2			2 /* Alpine V2 basic */
+#define AL_ETH_REV_ID_3			3 /* Alpine V2 advanced */
+
+/* PCI BARs */
+#define AL_ETH_UDMA_BAR			0
+#define AL_ETH_EC_BAR			4
+#define AL_ETH_MAC_BAR			2
+
+#define AL_ETH_MAX_FRAME_LEN		10000
+#define AL_ETH_MIN_FRAME_LEN		60
+
+#define AL_ETH_TSO_MSS_MIN_VAL		1
+#define AL_ETH_TSO_MSS_MAX_VAL		(AL_ETH_MAX_FRAME_LEN - 200)
+
+enum AL_ETH_PROTO_ID {
+	AL_ETH_PROTO_ID_UNKNOWN = 0,
+	AL_ETH_PROTO_ID_IPv4	= 8,
+	AL_ETH_PROTO_ID_IPv6	= 11,
+	AL_ETH_PROTO_ID_TCP	= 12,
+	AL_ETH_PROTO_ID_UDP	= 13,
+	AL_ETH_PROTO_ID_FCOE    = 21,
+	AL_ETH_PROTO_ID_GRH     = 22, /* RoCE l3 header */
+	AL_ETH_PROTO_ID_BTH     = 23, /* RoCE l4 header */
+	AL_ETH_PROTO_ID_ANY	= 32, /* for sw usage only */
+};
+
+#define AL_ETH_PROTOCOLS_NUM	(AL_ETH_PROTO_ID_ANY)
+
+enum AL_ETH_TX_TUNNEL_MODE {
+	AL_ETH_NO_TUNNELING	= 0,
+	AL_ETH_TUNNEL_NO_UDP	= 1, /* NVGRE / IP over IP */
+	AL_ETH_TUNNEL_WITH_UDP	= 3,	/* VXLAN */
+};
+
+#define AL_ETH_RX_THASH_TABLE_SIZE	BIT(8)
+#define AL_ETH_RX_FSM_TABLE_SIZE	BIT(7)
+#define AL_ETH_RX_HASH_KEY_NUM		10
+#define AL_ETH_FWD_MAC_NUM		32
+#define AL_ETH_FWD_PBITS_TABLE_NUM	BIT(3)
+#define AL_ETH_FWD_PRIO_TABLE_NUM	BIT(3)
+
+/* MAC media mode */
+enum al_eth_mac_mode {
+	AL_ETH_MAC_MODE_RGMII,
+	AL_ETH_MAC_MODE_SGMII,
+	AL_ETH_MAC_MODE_SGMII_2_5G,
+	AL_ETH_MAC_MODE_10GbE_Serial,	/* Applies to XFI and KR modes */
+	AL_ETH_MAC_MODE_10G_SGMII,	/* SGMII using the 10G MAC, don't use*/
+	AL_ETH_MAC_MODE_XLG_LL_40G,	/* applies to 40G mode using the 40G low latency (LL) MAC */
+	AL_ETH_MAC_MODE_KR_LL_25G,	/* applies to 25G mode using the 10/25G low latency (LL) MAC */
+	AL_ETH_MAC_MODE_XLG_LL_50G,	/* applies to 50G mode using the 40/50G low latency (LL) MAC */
+	AL_ETH_MAC_MODE_XLG_LL_25G	/* applies to 25G mode using the 40/50G low latency (LL) MAC */
+};
+
+/* interface type used for MDIO */
+enum al_eth_mdio_if {
+	AL_ETH_MDIO_IF_1G_MAC = 0,
+	AL_ETH_MDIO_IF_10G_MAC = 1
+};
+
+/* MDIO protocol type */
+enum al_eth_mdio_type {
+	AL_ETH_MDIO_TYPE_CLAUSE_22 = 0,
+	AL_ETH_MDIO_TYPE_CLAUSE_45 = 1
+};
+
+/* flow control mode */
+enum al_eth_flow_control_type {
+	AL_ETH_FLOW_CONTROL_TYPE_LINK_PAUSE,
+	AL_ETH_FLOW_CONTROL_TYPE_PFC
+};
+
+/* Tx to Rx switching decision type */
+enum al_eth_tx_switch_dec_type {
+	AL_ETH_TX_SWITCH_TYPE_MAC = 0,
+	AL_ETH_TX_SWITCH_TYPE_VLAN_TABLE = 1,
+	AL_ETH_TX_SWITCH_TYPE_VLAN_TABLE_AND_MAC = 2,
+	AL_ETH_TX_SWITCH_TYPE_BITMAP = 3
+};
+
+/* Tx to Rx VLAN ID selection type */
+enum al_eth_tx_switch_vid_sel_type {
+	AL_ETH_TX_SWITCH_VID_SEL_TYPE_VLAN1 = 0,
+	AL_ETH_TX_SWITCH_VID_SEL_TYPE_VLAN2 = 1,
+	AL_ETH_TX_SWITCH_VID_SEL_TYPE_NEW_VLAN1 = 2,
+	AL_ETH_TX_SWITCH_VID_SEL_TYPE_NEW_VLAN2 = 3,
+	AL_ETH_TX_SWITCH_VID_SEL_TYPE_DEFAULT_VLAN1 = 4,
+	AL_ETH_TX_SWITCH_VID_SEL_TYPE_FINAL_VLAN1 = 5
+};
+
+/*
+ * Rx descriptor configurations
+ * Note: when selecting rx descriptor field to inner packet, then that field
+ * will be set according to inner packet when packet is tunneled, for non-tunneled
+ * packets, the field will be set according to the packets header
+ */
+
+/* selection of the LRO_context_value result in the Metadata */
+enum al_eth_rx_desc_lro_context_val_res {
+	AL_ETH_LRO_CONTEXT_VALUE = 0,	/* LRO_context_value */
+	AL_ETH_L4_OFFSET = 1,		/* L4_offset */
+};
+
+/* selection of the L4 offset in the Metadata */
+enum al_eth_rx_desc_l4_offset_sel {
+	AL_ETH_L4_OFFSET_OUTER = 0, /* set L4 offset of the outer packet */
+	AL_ETH_L4_OFFSET_INNER = 1, /* set L4 offset of the inner packet */
+};
+
+/* selection of the L4 checksum result in the Metadata */
+enum al_eth_rx_desc_l4_chk_res_sel {
+	AL_ETH_L4_INNER_CHK = 0, /* L4 checksum */
+	/* Logic AND between outer and inner L4 checksum result */
+	AL_ETH_L4_INNER_OUTER_CHK = 1,
+};
+
+/* selection of the L3 checksum result in the Metadata */
+enum al_eth_rx_desc_l3_chk_res_sel {
+	AL_ETH_L3_CHK_TYPE_0 = 0, /* L3 checksum */
+	/* L3 checksum or RoCE/FCoE CRC, based on outer header */
+	AL_ETH_L3_CHK_TYPE_1 = 1,
+	/*
+	 * If tunnel exist = 0, L3 checksum or RoCE/FCoE CRC, based on outer
+	 * header. Else, logic AND between outer L3 checksum (Ipv4) and inner
+	 * CRC (RoCE or FcoE)
+	 */
+	AL_ETH_L3_CHK_TYPE_2 = 2,
+	/*
+	 * combination of the L3 checksum result and CRC result,based on the
+	 * checksum and RoCE/FCoE CRC input selections.
+	 */
+	AL_ETH_L3_CHK_TYPE_3 = 3,
+};
+
+/* selection of the L3 protocol index in the Metadata */
+enum al_eth_rx_desc_l3_proto_idx_sel {
+	AL_ETH_L3_PROTO_IDX_OUTER = 0, /* set L3 proto index of the outer packet */
+	AL_ETH_L3_PROTO_IDX_INNER = 1, /* set L3 proto index of the inner packet */
+};
+
+/* selection of the L3 offset in the Metadata */
+enum al_eth_rx_desc_l3_offset_sel {
+	AL_ETH_L3_OFFSET_OUTER = 0, /* set L3 offset of the outer packet */
+	AL_ETH_L3_OFFSET_INNER = 1, /* set L3 offset of the inner packet */
+};
+
+/* selection of the L4 protocol index in the Metadata */
+enum al_eth_rx_desc_l4_proto_idx_sel {
+	AL_ETH_L4_PROTO_IDX_OUTER = 0, /* set L4 proto index of the outer packet */
+	AL_ETH_L4_PROTO_IDX_INNER = 1, /* set L4 proto index of the inner packet */
+};
+
+/* selection of the frag indication in the Metadata */
+enum al_eth_rx_desc_frag_sel {
+	AL_ETH_FRAG_OUTER = 0, /* set frag of the outer packet */
+	AL_ETH_FRAG_INNER = 1, /* set frag of the inner packet */
+};
+
+/* Ethernet Rx completion descriptor */
+struct al_eth_rx_cdesc {
+	u32 ctrl_meta;
+	u32 len;
+	u32 word2;
+	u32 word3;
+};
+
+/* Flow Contol parameters */
+struct al_eth_flow_control_params{
+	enum al_eth_flow_control_type type; /* flow control type */
+	bool		obay_enable; /* stop tx when pause received */
+	bool		gen_enable; /* generate pause frames */
+	u16	rx_fifo_th_high;
+	u16	rx_fifo_th_low;
+	u16	quanta;
+	u16	quanta_th;
+	/*
+	 * For each UDMA, defines the mapping between
+	 * PFC priority and queues(in bit mask).
+	 * same mapping used for obay and generation.
+	 * for example:
+	 * if prio_q_map[1][7] = 0xC, then TX queues 2
+	 * and 3 of UDMA 1 will be stopped when pause
+	 * received with priority 7, also, when RX queues
+	 * 2 and 3 of UDMA 1 become almost full, then
+	 * pause frame with priority 7 will be sent.
+	 *
+	 * note:
+	 * 1) if specific a queue is not used, the caller must
+	 * make set the prio_q_map to 0 otherwise that queue
+	 * will make the controller keep sending PAUSE packets.
+	 * 2) queues of unused UDMA must be treated as above.
+	 * 3) when working in LINK PAUSE mode, only entries at
+	 * priority 0 will be considered.
+	 */
+	u8	prio_q_map[4][8];
+};
+
+/* Packet Tx flags */
+#define AL_ETH_TX_FLAGS_TSO		BIT(7)  /* Enable TCP/UDP segmentation offloading */
+#define AL_ETH_TX_FLAGS_IPV4_L3_CSUM	BIT(13) /* Enable IPv4 header checksum calculation */
+#define AL_ETH_TX_FLAGS_L4_CSUM		BIT(14) /* Enable TCP/UDP checksum calculation */
+#define AL_ETH_TX_FLAGS_L4_PARTIAL_CSUM	BIT(17) /* L4 partial checksum calculation */
+#define AL_ETH_TX_FLAGS_L2_MACSEC_PKT	BIT(16) /* L2 Packet type 802_3 or 802_3_MACSEC, V2 */
+#define AL_ETH_TX_FLAGS_L2_DIS_FCS	BIT(15) /* Disable CRC calculation*/
+#define AL_ETH_TX_FLAGS_TS		BIT(21) /* Timestamp the packet */
+
+#define AL_ETH_TX_FLAGS_INT		AL_M2S_DESC_INT_EN
+#define AL_ETH_TX_FLAGS_NO_SNOOP	AL_M2S_DESC_NO_SNOOP_H
+
+/* this structure used for tx packet meta data */
+struct al_eth_meta_data{
+	u8 store :1; /* store the meta into the queues cache */
+	u8 words_valid :4; /* valid bit per word */
+
+	u8 vlan1_cfi_sel:2;
+	u8 vlan2_vid_sel:2;
+	u8 vlan2_cfi_sel:2;
+	u8 vlan2_pbits_sel:2;
+	u8 vlan2_ether_sel:2;
+
+	u16 vlan1_new_vid:12;
+	u8 vlan1_new_cfi :1;
+	u8 vlan1_new_pbits :3;
+	u16 vlan2_new_vid:12;
+	u8 vlan2_new_cfi :1;
+	u8 vlan2_new_pbits :3;
+
+	u8 l3_header_len; /* in bytes */
+	u8 l3_header_offset;
+	u8 l4_header_len; /* in words(32-bits) */
+
+	/* rev 0 specific */
+	u8 mss_idx_sel:3; /* for TSO, select the register that holds the MSS */
+
+	/* rev 1 specific */
+	u8 ts_index:4; /* index of regiser where to store the tx timestamp */
+	u16 mss_val :14; /* for TSO, set the mss value */
+	u8 outer_l3_offset; /* for tunneling mode. up to 64 bytes */
+	u8 outer_l3_len; /* for tunneling mode. up to 128 bytes */
+};
+
+/* Packet Rx flags when adding buffer to receive queue */
+
+/*
+ * Target-ID to be assigned to the packet descriptors
+ * Requires Target-ID in descriptor to be enabled for the specific UDMA
+ * queue.
+ */
+#define AL_ETH_RX_FLAGS_TGTID_MASK	GENMASK(15, 0)
+#define AL_ETH_RX_FLAGS_INT		AL_M2S_DESC_INT_EN
+
+/* Packet Rx flags set by HW when receiving packet */
+#define AL_ETH_RX_ERROR			BIT(16) /* layer 2 errors (FCS, bad len, etc) */
+#define AL_ETH_RX_FLAGS_L4_CSUM_ERR	BIT(14)
+#define AL_ETH_RX_FLAGS_L3_CSUM_ERR	BIT(13)
+
+/* Packet Rx flags - word 3 in Rx completion descriptor */
+
+/* packet structure. used for packet transmission and reception */
+struct al_eth_pkt {
+	u32 flags; /* see flags above, depends on context(tx or rx) */
+	enum AL_ETH_PROTO_ID l3_proto_idx;
+	enum AL_ETH_PROTO_ID l4_proto_idx;
+	u8 source_vlan_count:2;
+	u8 vlan_mod_add_count:2;
+	u8 vlan_mod_del_count:2;
+	u8 vlan_mod_v1_ether_sel:2;
+	u8 vlan_mod_v1_vid_sel:2;
+	u8 vlan_mod_v1_pbits_sel:2;
+
+	/* rev 1 specific */
+	enum AL_ETH_TX_TUNNEL_MODE tunnel_mode;
+	enum AL_ETH_PROTO_ID outer_l3_proto_idx; /* for tunneling mode */
+
+	/*
+	 * Target-ID to be assigned to the packet descriptors
+	 * Requires Target-ID in descriptor to be enabled for the specific UDMA
+	 * queue.
+	 */
+	u16 tgtid;
+
+	u32 rx_header_len; /* header buffer length of rx packet, not used */
+	struct al_eth_meta_data *meta; /* if null, then no meta added */
+	u16 rxhash;
+	u16 l3_offset;
+
+	u8 num_of_bufs;
+	struct al_buf bufs[AL_ETH_PKT_MAX_BUFS];
+};
+
+struct al_ec_regs;
+
+/* Ethernet Adapter private data structure used by this driver */
+struct al_hw_eth_adapter {
+	u8 rev_id; /* PCI adapter revision ID */
+	u8 udma_id; /* the id of the UDMA used by this adapter */
+
+	struct net_device *netdev;
+
+	struct unit_regs __iomem *unit_regs;
+	void __iomem *udma_regs_base;
+	struct al_ec_regs __iomem *ec_regs_base;
+	void __iomem *ec_ints_base;
+	struct al_eth_mac_regs __iomem *mac_regs_base;
+	struct interrupt_controller_ctrl __iomem *mac_ints_base;
+
+	char *name; /* the upper layer must keep the string area */
+
+	struct al_udma tx_udma;
+	struct al_udma rx_udma;
+
+	u8 enable_rx_parser; /* config and enable rx parsing */
+
+	enum al_eth_flow_control_type fc_type; /* flow control*/
+
+	enum al_eth_mac_mode mac_mode;
+	enum al_eth_mdio_if	mdio_if; /* which mac mdio interface to use */
+	enum al_eth_mdio_type mdio_type; /* mdio protocol type */
+	bool shared_mdio_if; /* when true, the mdio interface is shared with other controllers.*/
+	u8 curr_lt_unit;
+};
+
+/* parameters from upper layer */
+struct al_eth_adapter_params {
+	u8 rev_id; /* PCI adapter revision ID */
+	u8 udma_id; /* the id of the UDMA used by this adapter */
+	struct net_device *netdev;
+	u8 enable_rx_parser; /* when true, the rx epe parser will be enabled */
+	void __iomem *udma_regs_base; /* UDMA register base address */
+	void __iomem *ec_regs_base;
+	void __iomem *mac_regs_base;
+	char *name; /* the upper layer must keep the string area */
+};
+
+/*
+ * initialize the ethernet adapter's DMA
+ * - initialize the adapter data structure
+ * - initialize the Tx and Rx UDMA
+ * - enable the Tx and Rx UDMA, the rings will be still disabled at this point.
+ *
+ * @param adapter pointer to the private structure
+ * @param params the parameters passed from upper layer
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_adapter_init(struct al_hw_eth_adapter *adapter, struct al_eth_adapter_params *params);
+
+/*
+ * stop the DMA of the ethernet adapter
+ *
+ * @param adapter pointer to the private structure
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_adapter_stop(struct al_hw_eth_adapter *adapter);
+
+/*
+ * Configure and enable a queue ring
+ *
+ * @param adapter pointer to the private structure
+ * @param type tx or rx
+ * @param qid queue index
+ * @param q_params queue parameters
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_queue_config(struct al_hw_eth_adapter *adapter, enum al_udma_type type, u32 qid,
+			struct al_udma_q_params *q_params);
+
+/* MAC layer */
+
+/*
+ * configure the mac media type.
+ * this function only sets the mode, but not the speed as certain mac modes
+ * support multiple speeds as will be negotiated by the link layer.
+ * @param adapter pointer to the private structure.
+ * @param mode media mode
+ *
+ * @return 0 on success. negative errno on failure.
+ */
+int al_eth_mac_config(struct al_hw_eth_adapter *adapter, enum al_eth_mac_mode mode);
+
+/*
+ * stop the mac tx and rx paths.
+ * @param adapter pointer to the private structure.
+ *
+ * @return 0 on success. negative error on failure.
+ */
+int al_eth_mac_stop(struct al_hw_eth_adapter *adapter);
+
+/*
+ * start the mac tx and rx paths.
+ * @param adapter pointer to the private structure.
+ *
+ * @return 0 on success. negative error on failure.
+ */
+int al_eth_mac_start(struct al_hw_eth_adapter *adapter);
+
+/*
+ * Perform gearbox reset for tx lanes And/Or Rx lanes.
+ * applicable only when the controller is connected to srds25G.
+ * This reset should be performed after each operation that changes the clocks
+ *
+ * @param adapter pointer to the private structure.
+ * @param tx_reset assert and de-assert reset for tx lanes
+ * @param rx_reset assert and de-assert reset for rx lanes
+ */
+void al_eth_gearbox_reset(struct al_hw_eth_adapter *adapter, bool tx_reset, bool rx_reset);
+
+/*
+ * update link auto negotiation speed and duplex mode
+ * this function assumes the mac mode already set using the al_eth_mac_config()
+ * function.
+ *
+ * @param adapter pointer to the private structure
+ * @param force_1000_base_x set to true to force the mac to work on 1000baseX
+ *	  (not relevant to RGMII)
+ * @param an_enable set to true to enable auto negotiation
+ *	  (not relevant to RGMII)
+ * @param speed in mega bits, e.g 1000 stands for 1Gbps (relevant only in case
+ *	  an_enable is false)
+ * @param full_duplex set to true to enable full duplex mode (relevant only
+ *	  in case an_enable is false)
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_mac_link_config(struct al_hw_eth_adapter *adapter,
+			   bool force_1000_base_x,
+			   bool an_enable,
+			   u32 speed,
+			   bool full_duplex);
+
+/*
+ * configure minimum and maximum rx packet length
+ *
+ * @param adapter pointer to the private structure
+ * @param min_rx_len minimum rx packet length
+ * @param max_rx_len maximum rx packet length
+ * both length limits in bytes and it includes the MAC Layer header and FCS.
+ * @return 0 on success, otherwise on failure.
+ */
+int al_eth_rx_pkt_limit_config(struct al_hw_eth_adapter *adapter, u32 min_rx_len, u32 max_rx_len);
+
+/* Reference clock frequency (platform specific) */
+enum al_eth_ref_clk_freq {
+	AL_ETH_REF_FREQ_375_MHZ		= 0,
+	AL_ETH_REF_FREQ_187_5_MHZ	= 1,
+	AL_ETH_REF_FREQ_250_MHZ		= 2,
+	AL_ETH_REF_FREQ_500_MHZ		= 3,
+	AL_ETH_REF_FREQ_428_MHZ         = 4,
+};
+
+/*
+ * configure the MDIO hardware interface
+ * @param adapter pointer to the private structure
+ * @param mdio_type clause type
+ * @param shared_mdio_if set to true if multiple controllers using the same
+ * @param ref_clk_freq reference clock frequency
+ * @param mdio_clk_freq_khz the required MDC/MDIO clock frequency [Khz]
+ * MDIO pins of the chip.
+ *
+ * @return 0 on success, otherwise on failure.
+ */
+int al_eth_mdio_config(struct al_hw_eth_adapter *adapter,
+		       enum al_eth_mdio_type mdio_type,
+		       bool shared_mdio_if,
+		       enum al_eth_ref_clk_freq ref_clk_freq,
+		       unsigned int mdio_clk_freq_khz);
+
+/*
+ * read mdio register
+ * this function uses polling mode, and as the mdio is slow interface, it might
+ * block the cpu for long time (milliseconds).
+ * @param adapter pointer to the private structure
+ * @param phy_addr address of mdio phy
+ * @param device address of mdio device (used only in CLAUSE 45)
+ * @param reg index of the register
+ * @param val pointer for read value of the register
+ *
+ * @return 0 on success, negative errno on failure
+ */
+int al_eth_mdio_read(struct al_hw_eth_adapter *adapter, u32 phy_addr,
+		     u32 device, u32 reg, u16 *val);
+
+/*
+ * write mdio register
+ * this function uses polling mode, and as the mdio is slow interface, it might
+ * block the cpu for long time (milliseconds).
+ * @param adapter pointer to the private structure
+ * @param phy_addr address of mdio phy
+ * @param device address of mdio device (used only in CLAUSE 45)
+ * @param reg index of the register
+ * @param val value to write
+ *
+ * @return 0 on success, negative errno on failure
+ */
+int al_eth_mdio_write(struct al_hw_eth_adapter *adapter, u32 phy_addr,
+		      u32 device, u32 reg, u16 val);
+
+/*
+ * prepare packet descriptors in tx queue.
+ *
+ * This functions prepares the descriptors for the given packet in the tx
+ * submission ring. the caller must call al_eth_tx_pkt_action() below
+ * in order to notify the hardware about the new descriptors.
+ *
+ * @param tx_dma_q pointer to UDMA tx queue
+ * @param pkt the packet to transmit
+ *
+ * @return number of descriptors used for this packet, 0 if no free
+ * room in the descriptors ring
+ */
+int al_eth_tx_pkt_prepare(struct al_hw_eth_adapter *adapter,
+			  struct al_udma_q *tx_dma_q, struct al_eth_pkt *pkt);
+
+/*
+ * Trigger the DMA about previously added tx descriptors.
+ *
+ * @param tx_dma_q pointer to UDMA tx queue
+ * @param tx_descs number of descriptors to notify the DMA about.
+ * the tx_descs can be sum of descriptor numbers of multiple prepared packets,
+ * this way the caller can use this function to notify the DMA about multiple
+ * packets.
+ */
+void al_eth_tx_dma_action(struct al_udma_q *tx_dma_q, u32 tx_descs);
+
+/*
+ * get number of completed tx descriptors, upper layer should derive from
+ * this information which packets were completed.
+ *
+ * @param tx_dma_q pointer to UDMA tx queue
+ *
+ * @return number of completed tx descriptors.
+ */
+int al_eth_comp_tx_get(struct al_hw_eth_adapter *adapter,
+		       struct al_udma_q *tx_dma_q);
+
+/*
+ * add buffer to receive queue
+ *
+ * @param rx_dma_q pointer to UDMA rx queue
+ * @param buf pointer to data buffer
+ * @param flags bitwise of AL_ETH_RX_FLAGS
+ * @param header_buf this is not used for far and header_buf should be set to
+ * NULL.
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_rx_buffer_add(struct al_hw_eth_adapter *adapter,
+			 struct al_udma_q *rx_dma_q, struct al_buf *buf,
+			 u32 flags, struct al_buf *header_buf);
+
+/*
+ * notify the hw engine about rx descriptors that were added to the receive queue
+ *
+ * @param rx_dma_q pointer to UDMA rx queue
+ * @param descs_num number of rx descriptors
+ */
+void al_eth_rx_buffer_action(struct al_hw_eth_adapter *adapter,
+			     struct al_udma_q *rx_dma_q, u32 descs_num);
+
+/*
+ * get packet from RX completion ring
+ *
+ * @param rx_dma_q pointer to UDMA rx queue
+ * @param pkt pointer to a packet data structure, this function fills this
+ * structure with the information about the received packet. the buffers
+ * structures filled only with the length of the data written into the buffer,
+ * the address fields are not updated as the upper layer can retrieve this
+ * information by itself because the hardware uses the buffers in the same order
+ * were those buffers inserted into the ring of the receive queue.
+ * this structure should be allocated by the caller function.
+ *
+ * @return return number of descriptors or 0 if no completed packet found.
+ */
+u32 al_eth_pkt_rx(struct al_hw_eth_adapter *adapter, struct al_udma_q *rx_dma_q,
+		  struct al_eth_pkt *pkt);
+
+/* RX parser table */
+struct al_eth_epe_p_reg_entry {
+	u32 data;
+	u32 mask;
+	u32 ctrl;
+};
+
+struct al_eth_epe_control_entry {
+	u32 data[6];
+};
+
+/* Flow Steering and filtering */
+int al_eth_thash_table_set(struct al_hw_eth_adapter *adapter, u32 idx, u8 udma, u32 queue);
+
+/*
+ * FSM table has 7 bits input address:
+ *  bits[2:0] are the outer packet's type (IPv4, TCP...)
+ *  bits[5:3] are the inner packet's type
+ *  bit[6] is set when packet is tunneled.
+ *
+ * The output of each entry:
+ *  bits[1:0] - input selection: selects the input for the thash (2/4 tuple, inner/outer)
+ *  bit[2] - selects whether to use thash output, or default values for the queue and udma
+ *  bits[6:3] default UDMA mask: the UDMAs to select when bit 2 above was unset
+ *  bits[9:5] defualt queue: the queue index to select when bit 2 above was unset
+ */
+
+#define AL_ETH_FSM_ENTRY_IPV4_TCP	   0
+#define AL_ETH_FSM_ENTRY_IPV4_UDP	   1
+#define AL_ETH_FSM_ENTRY_IPV6_TCP	   2
+#define AL_ETH_FSM_ENTRY_IPV6_UDP	   3
+#define AL_ETH_FSM_ENTRY_IPV6_NO_UDP_TCP   4
+#define AL_ETH_FSM_ENTRY_IPV4_NO_UDP_TCP   5
+
+#define AL_ETH_FSM_ENTRY_OUTER(idx)	   ((idx) & 7)
+
+/* FSM DATA format */
+#define AL_ETH_FSM_DATA_OUTER_2_TUPLE	0
+#define AL_ETH_FSM_DATA_OUTER_4_TUPLE	1
+
+#define AL_ETH_FSM_DATA_HASH_SEL	BIT(2)
+
+#define AL_ETH_FSM_DATA_DEFAULT_Q_SHIFT		5
+#define AL_ETH_FSM_DATA_DEFAULT_UDMA_SHIFT	3
+
+/* set fsm table entry */
+int al_eth_fsm_table_set(struct al_hw_eth_adapter *adapter, u32 idx, u32 entry);
+
+enum AL_ETH_FWD_CTRL_IDX_VLAN_TABLE_OUT {
+	AL_ETH_FWD_CTRL_IDX_VLAN_TABLE_OUT_0 = 0,
+	AL_ETH_FWD_CTRL_IDX_VLAN_TABLE_OUT_1 = 1,
+	AL_ETH_FWD_CTRL_IDX_VLAN_TABLE_OUT_ANY = 2,
+};
+
+enum AL_ETH_FWD_CTRL_IDX_TUNNEL {
+	AL_ETH_FWD_CTRL_IDX_TUNNEL_NOT_EXIST = 0,
+	AL_ETH_FWD_CTRL_IDX_TUNNEL_EXIST = 1,
+	AL_ETH_FWD_CTRL_IDX_TUNNEL_ANY = 2,
+};
+
+enum AL_ETH_FWD_CTRL_IDX_VLAN {
+	AL_ETH_FWD_CTRL_IDX_VLAN_NOT_EXIST = 0,
+	AL_ETH_FWD_CTRL_IDX_VLAN_EXIST = 1,
+	AL_ETH_FWD_CTRL_IDX_VLAN_ANY = 2,
+};
+
+enum AL_ETH_FWD_CTRL_IDX_MAC_TABLE {
+	AL_ETH_FWD_CTRL_IDX_MAC_TABLE_NO_MATCH = 0,
+	AL_ETH_FWD_CTRL_IDX_MAC_TABLE_MATCH = 1,
+	AL_ETH_FWD_CTRL_IDX_MAC_TABLE_ANY = 2,
+};
+
+enum AL_ETH_FWD_CTRL_IDX_MAC_DA_TYPE {
+	AL_ETH_FWD_CTRL_IDX_MAC_DA_TYPE_UC = 0, /* unicast */
+	AL_ETH_FWD_CTRL_IDX_MAC_DA_TYPE_MC = 1, /* multicast */
+	AL_ETH_FWD_CTRL_IDX_MAC_DA_TYPE_BC = 2, /* broadcast */
+	AL_ETH_FWD_CTRL_IDX_MAC_DA_TYPE_ANY = 4, /* for sw usage */
+};
+
+enum AL_ETH_CTRL_TABLE_PRIO_SEL {
+	AL_ETH_CTRL_TABLE_PRIO_SEL_PBITS_TABLE	= 0,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_DSCP_TABLE	= 1,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_TC_TABLE	= 2,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_REG1		= 3,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_REG2		= 4,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_REG3		= 5,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_REG4		= 6,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_REG5		= 7,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_REG6		= 7,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_REG7		= 9,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_REG8		= 10,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_VAL_3	= 11,
+	AL_ETH_CTRL_TABLE_PRIO_SEL_VAL_0	= 12,
+};
+
+/* where to select the initial queue from */
+enum AL_ETH_CTRL_TABLE_QUEUE_SEL_1 {
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_PRIO_TABLE	= 0,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_THASH_TABLE	= 1,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_MAC_TABLE		= 2,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_MHASH_TABLE	= 3,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_REG1		= 4,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_REG2		= 5,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_REG3		= 6,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_REG4		= 7,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_VAL_3		= 12,
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_1_VAL_0		= 13,
+};
+
+/* target queue will be built up from the priority and initial queue */
+enum AL_ETH_CTRL_TABLE_QUEUE_SEL_2 {
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_2_PRIO_TABLE	= 0, /* target queue is the output of priority table */
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_2_PRIO		= 1, /* target queue is the priority */
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_2_PRIO_QUEUE	= 2, /* target queue is initial queue[0], priority[1] */
+	AL_ETH_CTRL_TABLE_QUEUE_SEL_2_NO_PRIO		= 3, /* target queue is the initial */
+};
+
+enum AL_ETH_CTRL_TABLE_UDMA_SEL {
+	AL_ETH_CTRL_TABLE_UDMA_SEL_THASH_TABLE		= 0,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_THASH_AND_VLAN	= 1,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_VLAN_TABLE		= 2,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_VLAN_AND_MAC		= 3,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_MAC_TABLE		= 4,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_MAC_AND_MHASH	= 5,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_MHASH_TABLE		= 6,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_REG1			= 7,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_REG2			= 8,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_REG3			= 9,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_REG4			= 10,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_REG5			= 11,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_REG6			= 12,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_REG7			= 13,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_REG8			= 14,
+	AL_ETH_CTRL_TABLE_UDMA_SEL_VAL_0		= 15,
+};
+
+struct al_eth_fwd_ctrl_table_entry {
+	enum AL_ETH_CTRL_TABLE_PRIO_SEL prio_sel;
+	enum AL_ETH_CTRL_TABLE_QUEUE_SEL_1 queue_sel_1; /* queue id source */
+	enum AL_ETH_CTRL_TABLE_QUEUE_SEL_2 queue_sel_2; /* mix queue id with priority */
+	enum AL_ETH_CTRL_TABLE_UDMA_SEL udma_sel;
+	bool filter; /* set to true to enable filtering */
+};
+
+/*
+ * Configure default control table entry
+ *
+ * @param adapter pointer to the private structure
+ * @param use_table set to true if control table is used, when set to false
+ * then control table will be bypassed and the entry value will be used.
+ * @param entry defines the value to be used when bypassing control table.
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+void al_eth_ctrl_table_def_set(struct al_hw_eth_adapter *adapter,
+			       bool use_table,
+			       struct al_eth_fwd_ctrl_table_entry *entry);
+
+/*
+ * Configure hash key initial registers
+ * Those registers define the initial key values, those values used for
+ * the THASH and MHASH hash functions.
+ *
+ * @param adapter pointer to the private structure
+ * @param idx the register index
+ * @param val the register value
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+void al_eth_hash_key_set(struct al_hw_eth_adapter *adapter, u32 idx, u32 val);
+
+struct al_eth_fwd_mac_table_entry {
+	u8		addr[6]; /* byte 0 is the first byte seen on the wire */
+	u8		mask[6];
+	bool		tx_valid;
+	u8		tx_target;
+	bool		rx_valid;
+	u8		udma_mask; /* target udma */
+	u8		qid; /* target queue */
+	bool		filter; /* set to true to enable filtering */
+};
+
+/*
+ * Configure mac table entry
+ * The HW traverse this table and looks for match from lowest index,
+ * when the packets MAC DA & mask == addr, and the valid bit is set, then match occurs.
+ *
+ * @param adapter pointer to the private structure
+ * @param idx the entry index within the mac table.
+ * @param entry the contents of the MAC table entry
+ */
+void al_eth_fwd_mac_table_set(struct al_hw_eth_adapter *adapter, u32 idx,
+			      struct al_eth_fwd_mac_table_entry *entry);
+
+void al_eth_mac_addr_store(void * __iomem ec_base, u32 idx, u8 *addr);
+void al_eth_mac_addr_read(void * __iomem ec_base, u32 idx, u8 *addr);
+
+/*
+ * Configure pbits table entry
+ * The HW uses this table to translate between vlan pbits field to priority.
+ * The vlan pbits is used as the index of this table.
+ *
+ * @param adapter pointer to the private structure
+ * @param idx the entry index within the table.
+ * @param prio the priority to set for this entry
+ */
+void al_eth_fwd_pbits_table_set(struct al_hw_eth_adapter *adapter, u32 idx, u8 prio);
+
+/*
+ * Configure priority table entry
+ * The HW uses this table to translate between priority to queue index.
+ * The priority is used as the index of this table.
+ *
+ * @param adapter pointer to the private structure
+ * @param prio the entry index within the table.
+ * @param qid the queue index to set for this entry (priority).
+ */
+void al_eth_fwd_priority_table_set(struct al_hw_eth_adapter *adapter, u8 prio, u8 qid);
+
+/*
+ * Configure MAC HASH table entry
+ * The HW uses 8 bits from the hash result on the MAC DA as index to this table.
+ *
+ * @param adapter pointer to the private structure
+ * @param idx the entry index within the table.
+ * @param udma_mask the target udma to set for this entry.
+ * @param qid the target queue index to set for this entry.
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_fwd_mhash_table_set(struct al_hw_eth_adapter *adapter, u32 idx, u8 udma_mask, u8 qid);
+
+/* filter undetected MAC DA */
+#define AL_ETH_RFW_FILTER_UNDET_MAC          BIT(0)
+/* filter specific MAC DA based on MAC table output */
+#define AL_ETH_RFW_FILTER_DET_MAC            BIT(1)
+/* filter all tagged */
+#define AL_ETH_RFW_FILTER_TAGGED             BIT(2)
+/* filter all untagged */
+#define AL_ETH_RFW_FILTER_UNTAGGED           BIT(3)
+/* filter all broadcast */
+#define AL_ETH_RFW_FILTER_BC                 BIT(4)
+/* filter all multicast */
+#define AL_ETH_RFW_FILTER_MC                 BIT(5)
+/* filter packet based on parser drop */
+#define AL_ETH_RFW_FILTER_PARSE              BIT(6)
+/* filter packet based on VLAN table output */
+#define AL_ETH_RFW_FILTER_VLAN_VID           BIT(7)
+/* filter packet based on control table output */
+#define AL_ETH_RFW_FILTER_CTRL_TABLE         BIT(8)
+/* filter packet based on protocol index */
+#define AL_ETH_RFW_FILTER_PROT_INDEX         BIT(9)
+/* filter packet based on WoL decision */
+#define AL_ETH_RFW_FILTER_WOL		     BIT(10)
+
+struct al_eth_filter_params {
+	bool		enable;
+	u32	filters; /* bitmask of AL_ETH_RFW_FILTER.. for filters to enable */
+	bool		filter_proto[AL_ETH_PROTOCOLS_NUM]; /* set true for protocols to filter */
+};
+
+/*
+ * Configure the receive filters
+ * this function enables/disables filtering packets and which filtering
+ * types to apply.
+ * filters that indicated in tables (MAC table, VLAN and Control tables)
+ * are not configured by this function. This functions only enables/disables
+ * respecting the filter indication from those tables.
+ *
+ * @param adapter pointer to the private structure
+ * @param params the parameters passed from upper layer
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_filter_config(struct al_hw_eth_adapter *adapter, struct al_eth_filter_params *params);
+
+int al_eth_flow_control_config(struct al_hw_eth_adapter *adapter, struct al_eth_flow_control_params *params);
+
+/* enum for methods when updating systime using triggers */
+enum al_eth_pth_update_method {
+	AL_ETH_PTH_UPDATE_METHOD_SET = 0, /* Set the time in int/ext update time */
+	AL_ETH_PTH_UPDATE_METHOD_INC = 1, /* increment */
+	AL_ETH_PTH_UPDATE_METHOD_DEC = 2, /* decrement */
+	AL_ETH_PTH_UPDATE_METHOD_ADD_TO_LAST = 3, /* Set to last time + int/ext update time.*/
+};
+
+/* systime internal update trigger types */
+enum al_eth_pth_int_trig {
+	/* use output pulse as trigger */
+	AL_ETH_PTH_INT_TRIG_OUT_PULSE_0 = 0,
+	/* use the int update register write as a trigger */
+	AL_ETH_PTH_INT_TRIG_REG_WRITE = 1,
+};
+
+/* get statistics */
+struct al_eth_mac_stats {
+	/* sum the data and padding octets (i.e. without header and FCS) received with a valid frame. */
+	u64 aOctetsReceivedOK;
+	/* sum of Payload and padding octets of frames transmitted without error*/
+	u64 aOctetsTransmittedOK;
+	/* total number of packets received. Good and bad packets */
+	u32 etherStatsPkts;
+	/* number of received unicast packets */
+	u32 ifInUcastPkts;
+	/* number of received multicast packets */
+	u32 ifInMulticastPkts;
+	/* number of received broadcast packets */
+	u32 ifInBroadcastPkts;
+	/* Number of frames received with FIFO Overflow, CRC, Payload Length, Jabber and Oversized, Alignment or PHY/PCS error indication */
+	u32 ifInErrors;
+
+	/* number of transmitted unicast packets */
+	u32 ifOutUcastPkts;
+	/* number of transmitted multicast packets */
+	u32 ifOutMulticastPkts;
+	/* number of transmitted broadcast packets */
+	u32 ifOutBroadcastPkts;
+	/* number of frames transmitted with FIFO Overflow, FIFO Underflow or Controller indicated error */
+	u32 ifOutErrors;
+
+	/* number of Frame received without error (Including Pause Frames). */
+	u32 aFramesReceivedOK;
+	/* number of Frames transmitter without error (Including Pause Frames) */
+	u32 aFramesTransmittedOK;
+	/* number of packets received with less than 64 octets */
+	u32 etherStatsUndersizePkts;
+	/* Too short frames with CRC error, available only for RGMII and 1G Serial modes */
+	u32 etherStatsFragments;
+	/* Too long frames with CRC error */
+	u32 etherStatsJabbers;
+	/* packet that exceeds the valid maximum programmed frame length */
+	u32 etherStatsOversizePkts;
+	/* number of frames received with a CRC error */
+	u32 aFrameCheckSequenceErrors;
+	/* number of frames received with alignment error */
+	u32 aAlignmentErrors;
+	/* number of dropped packets due to FIFO overflow */
+	u32 etherStatsDropEvents;
+	/* number of transmitted pause frames. */
+	u32 aPAUSEMACCtrlFramesTransmitted;
+	/* number of received pause frames. */
+	u32 aPAUSEMACCtrlFramesReceived;
+	/* frame received exceeded the maximum length programmed with register FRM_LGTH, available only for 10G modes */
+	u32 aFrameTooLongErrors;
+	/*
+	 * Received frame with bad length/type (between 46 and 0x600 or less
+	 * than 46 for packets longer than 64), available only for 10G modes
+	 */
+	u32 aInRangeLengthErrors;
+	/* Valid VLAN tagged frames transmitted */
+	u32 VLANTransmittedOK;
+	/* Valid VLAN tagged frames received */
+	u32 VLANReceivedOK;
+	/* Total number of octets received. Good and bad packets */
+	u32 etherStatsOctets;
+
+	/* packets of 64 octets length is received (good and bad frames are counted) */
+	u32 etherStatsPkts64Octets;
+	/* Frames (good and bad) with 65 to 127 octets */
+	u32 etherStatsPkts65to127Octets;
+	/* Frames (good and bad) with 128 to 255 octets */
+	u32 etherStatsPkts128to255Octets;
+	/* Frames (good and bad) with 256 to 511 octets */
+	u32 etherStatsPkts256to511Octets;
+	/* Frames (good and bad) with 512 to 1023 octets */
+	u32 etherStatsPkts512to1023Octets;
+	/* Frames (good and bad) with 1024 to 1518 octets */
+	u32 etherStatsPkts1024to1518Octets;
+	/* frames with 1519 bytes to the maximum length programmed in the register FRAME_LENGTH. */
+	u32 etherStatsPkts1519toX;
+
+	u32 eee_in;
+	u32 eee_out;
+};
+
+/*
+ * perform Function Level Reset RMN
+ *
+ * Addressing RMN: 714
+ *
+ * @param pci_read_config_u32 pointer to function that reads register from pci header
+ * @param pci_write_config_u32 pointer to function that writes register from pci header
+ * @param handle pointer passes to the above functions as first parameter
+ * @param mac_base base address of the MAC registers
+ *
+ * @return 0.
+ */
+int al_eth_flr_rmn(int (*pci_read_config_u32)(void *handle, int where, u32 *val),
+		   int (*pci_write_config_u32)(void *handle, int where, u32 val),
+		   void *handle, void __iomem	*mac_base);
+
+enum al_eth_board_media_type {
+	AL_ETH_BOARD_MEDIA_TYPE_AUTO_DETECT		= 0,
+	AL_ETH_BOARD_MEDIA_TYPE_RGMII			= 1,
+	AL_ETH_BOARD_MEDIA_TYPE_10GBASE_SR		= 2,
+	AL_ETH_BOARD_MEDIA_TYPE_SGMII			= 3,
+	AL_ETH_BOARD_MEDIA_TYPE_1000BASE_X		= 4,
+	AL_ETH_BOARD_MEDIA_TYPE_AUTO_DETECT_AUTO_SPEED	= 5,
+	AL_ETH_BOARD_MEDIA_TYPE_SGMII_2_5G		= 6,
+	AL_ETH_BOARD_MEDIA_TYPE_NBASE_T			= 7,
+	AL_ETH_BOARD_MEDIA_TYPE_25G			= 8,
+};
+
+enum al_eth_board_mdio_freq {
+	AL_ETH_BOARD_MDIO_FREQ_2_5_MHZ	= 0,
+	AL_ETH_BOARD_MDIO_FREQ_1_MHZ	= 1,
+};
+
+enum al_eth_board_ext_phy_if {
+	AL_ETH_BOARD_PHY_IF_MDIO	= 0,
+	AL_ETH_BOARD_PHY_IF_XMDIO	= 1,
+	AL_ETH_BOARD_PHY_IF_I2C		= 2,
+
+};
+
+enum al_eth_board_auto_neg_mode {
+	AL_ETH_BOARD_AUTONEG_OUT_OF_BAND	= 0,
+	AL_ETH_BOARD_AUTONEG_IN_BAND		= 1,
+
+};
+
+/* declare the 1G mac active speed when auto negotiation disabled */
+enum al_eth_board_1g_speed {
+	AL_ETH_BOARD_1G_SPEED_1000M		= 0,
+	AL_ETH_BOARD_1G_SPEED_100M		= 1,
+	AL_ETH_BOARD_1G_SPEED_10M		= 2,
+};
+
+enum al_eth_retimer_channel {
+	AL_ETH_RETIMER_CHANNEL_A		= 0,
+	AL_ETH_RETIMER_CHANNEL_B		= 1,
+	AL_ETH_RETIMER_CHANNEL_C		= 2,
+	AL_ETH_RETIMER_CHANNEL_D		= 3,
+	AL_ETH_RETIMER_CHANNEL_E		= 4,
+	AL_ETH_RETIMER_CHANNEL_F		= 5,
+	AL_ETH_RETIMER_CHANNEL_G		= 6,
+	AL_ETH_RETIMER_CHANNEL_H		= 7,
+	AL_ETH_RETIMER_CHANNEL_MAX		= 8
+};
+
+/* list of supported retimers */
+enum al_eth_retimer_type {
+	AL_ETH_RETIMER_BR_210			= 0,
+	AL_ETH_RETIMER_BR_410			= 1,
+	AL_ETH_RETIMER_DS_25			= 2,
+	AL_ETH_RETIMER_TYPE_MAX			= 4,
+};
+
+/*
+ * Structure represents the board information. this info set by boot loader
+ * and read by OS driver.
+ */
+struct al_eth_board_params {
+	enum al_eth_board_media_type	media_type;
+	bool		phy_exist; /* external phy exist */
+	u8		phy_mdio_addr; /* mdio address of external phy */
+	bool		sfp_plus_module_exist; /* SFP+ module connected */
+	bool		autoneg_enable; /* enable Auto-Negotiation */
+	bool		kr_lt_enable; /* enable KR Link-Training */
+	bool		kr_fec_enable; /* enable KR FEC */
+	enum al_eth_board_mdio_freq	mdio_freq; /* MDIO frequency */
+	u8		i2c_adapter_id; /* identifier for the i2c adapter to use to access SFP+ module */
+	enum al_eth_board_ext_phy_if	phy_if; /* phy interface */
+	enum al_eth_board_auto_neg_mode	an_mode; /* auto-negotiation mode (in-band / out-of-band) */
+	enum al_eth_ref_clk_freq	ref_clk_freq; /* reference clock frequency */
+	bool		force_1000_base_x; /* set mac to 1000 base-x mode (instead sgmii) */
+	bool		an_disable; /* disable auto negotiation */
+	enum al_eth_board_1g_speed	speed; /* port speed if AN disabled */
+	bool		half_duplex; /* force half duplex if AN disabled */
+	bool		fc_disable; /* disable flow control */
+	bool		retimer_exist; /* retimer is exist on the board */
+	u8		retimer_bus_id; /* in what i2c bus the retimer is on */
+	u8		retimer_i2c_addr; /* i2c address of the retimer */
+	enum al_eth_retimer_channel retimer_channel; /* what channel connected to this port (Rx) */
+	bool		dac; /* assume direct attached cable is connected if auto detect is off or failed */
+	u8		dac_len; /* assume this cable length if auto detect is off or failed  */
+	enum al_eth_retimer_type retimer_type; /* the type of the specific retimer */
+	enum al_eth_retimer_channel retimer_tx_channel; /* what channel connected to this port (Tx) */
+	u8		gpio_sfp_present; /* gpio number of sfp present for this port. 0 if not exist */
+};
+
+/*
+ * set board parameter of the eth port
+ * this function used to set the board parameters into scratchpad
+ * registers. those parameters can be read later by OS driver.
+ *
+ * @param mac_base the virtual address of the mac registers (PCI BAR 2)
+ * @param params pointer to structure the includes the parameters
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_board_params_set(void * __iomem mac_base, struct al_eth_board_params *params);
+
+/*
+ * get board parameter of the eth port
+ * this function used to get the board parameters from scratchpad
+ * registers.
+ *
+ * @param mac_base the virtual address of the mac registers (PCI BAR 2)
+ * @param params pointer to structure where the parameters will be stored.
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_board_params_get(void * __iomem mac_base, struct al_eth_board_params *params);
+
+/*
+ * Wake-On-Lan (WoL)
+ *
+ * The following few functions configure the Wake-On-Lan packet detection
+ * inside the Integrated Ethernet MAC.
+ *
+ * There are other alternative ways to set WoL, such using the
+ * external 1000Base-T transceiver to set WoL mode.
+ *
+ * These APIs do not set the system-wide power-state, nor responsible on the
+ * transition from Sleep to Normal power state.
+ *
+ * For system level considerations, please refer to Annapurna Labs Alpine Wiki.
+ */
+/* Interrupt enable WoL MAC DA Unicast detected  packet */
+#define AL_ETH_WOL_INT_UNICAST		BIT(0)
+/* Interrupt enable WoL L2 Multicast detected  packet */
+#define AL_ETH_WOL_INT_MULTICAST	BIT(1)
+/* Interrupt enable WoL L2 Broadcast detected  packet */
+#define AL_ETH_WOL_INT_BROADCAST	BIT(2)
+/* Interrupt enable WoL IPv4 detected  packet */
+#define AL_ETH_WOL_INT_IPV4		BIT(3)
+/* Interrupt enable WoL IPv6 detected  packet */
+#define AL_ETH_WOL_INT_IPV6		BIT(4)
+/* Interrupt enable WoL EtherType+MAC DA detected  packet */
+#define AL_ETH_WOL_INT_ETHERTYPE_DA	BIT(5)
+/* Interrupt enable WoL EtherType+L2 Broadcast detected  packet */
+#define AL_ETH_WOL_INT_ETHERTYPE_BC	BIT(6)
+/* Interrupt enable WoL parser detected  packet */
+/* Interrupt enable WoL magic detected  packet */
+#define AL_ETH_WOL_INT_MAGIC		BIT(8)
+/* Interrupt enable WoL magic+password detected  packet */
+#define AL_ETH_WOL_INT_MAGIC_PSWD	BIT(9)
+
+/* Forward enable WoL MAC DA Unicast detected  packet */
+#define AL_ETH_WOL_FWRD_UNICAST		BIT(0)
+/* Forward enable WoL L2 Multicast detected  packet */
+#define AL_ETH_WOL_FWRD_MULTICAST	BIT(1)
+/* Forward enable WoL L2 Broadcast detected  packet */
+#define AL_ETH_WOL_FWRD_BROADCAST	BIT(2)
+/* Forward enable WoL IPv4 detected  packet */
+/* Forward enable WoL IPv6 detected  packet */
+/* Forward enable WoL EtherType+MAC DA detected  packet */
+/* Forward enable WoL EtherType+L2 Broadcast detected  packet */
+/* Forward enable WoL parser detected  packet */
+
+struct al_eth_wol_params {
+	 /* 6 bytes array of destanation address for magic packet detection */
+	u8 *dest_addr;
+	u8 *pswd;	/* 6 bytes array of the password to use */
+	u8 *ipv4;
+	u8 *ipv6;
+	u16 ethr_type1; /* first ethertype to use */
+	u16 ethr_type2; /* secound ethertype to use */
+	/*
+	 * Bitmask of AL_ETH_WOL_FWRD_* of the packet types needed to be
+	 * forwarded.
+	 */
+	u16 forward_mask;
+	/*
+	 * Bitmask of AL_ETH_WOL_INT_* of the packet types that will send
+	 * interrupt to wake the system.
+	 */
+	u16 int_mask;
+};
+
+/*
+ * enable the wol mechanism
+ * set what type of packets will wake up the system and what type of packets
+ * neet to forward after the system is up
+ *
+ * beside this function wol filter also need to be set by
+ * calling al_eth_filter_config with AL_ETH_RFW_FILTER_WOL
+ *
+ * @param adapter pointer to the private structure
+ * @param wol the parameters needed to configure the wol
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_wol_enable(
+		struct al_hw_eth_adapter *adapter,
+		struct al_eth_wol_params *wol);
+
+/*
+ * Disable the WoL mechnism.
+ *
+ * @param adapter pointer to the private structure
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+int al_eth_wol_disable(
+		struct al_hw_eth_adapter *adapter);
+
+enum AL_ETH_TX_GCP_ALU_OPSEL {
+	AL_ETH_TX_GCP_ALU_L3_OFFSET			= 0,
+	AL_ETH_TX_GCP_ALU_OUTER_L3_OFFSET		= 1,
+	AL_ETH_TX_GCP_ALU_L3_LEN			= 2,
+	AL_ETH_TX_GCP_ALU_OUTER_L3_LEN			= 3,
+	AL_ETH_TX_GCP_ALU_L4_OFFSET			= 4,
+	AL_ETH_TX_GCP_ALU_L4_LEN			= 5,
+	AL_ETH_TX_GCP_ALU_TABLE_VAL			= 10
+};
+
+enum AL_ETH_RX_GCP_ALU_OPSEL {
+	AL_ETH_RX_GCP_ALU_OUTER_L3_OFFSET		= 0,
+	AL_ETH_RX_GCP_ALU_INNER_L3_OFFSET		= 1,
+	AL_ETH_RX_GCP_ALU_OUTER_L4_OFFSET		= 2,
+	AL_ETH_RX_GCP_ALU_INNER_L4_OFFSET		= 3,
+	AL_ETH_RX_GCP_ALU_OUTER_L3_HDR_LEN_LAT		= 4,
+	AL_ETH_RX_GCP_ALU_INNER_L3_HDR_LEN_LAT		= 5,
+	AL_ETH_RX_GCP_ALU_OUTER_L3_HDR_LEN_SEL		= 6,
+	AL_ETH_RX_GCP_ALU_INNER_L3_HDR_LEN_SEL		= 7,
+	AL_ETH_RX_GCP_ALU_PARSE_RESULT_VECTOR_OFFSET_1	= 8,
+	AL_ETH_RX_GCP_ALU_PARSE_RESULT_VECTOR_OFFSET_2	= 9,
+	AL_ETH_RX_GCP_ALU_TABLE_VAL			= 10
+};
+
+enum AL_ETH_ALU_OPCODE {
+	AL_ALU_FWD_A				= 0,
+	AL_ALU_ARITHMETIC_ADD			= 1,
+	AL_ALU_ARITHMETIC_SUBTRACT		= 2,
+	AL_ALU_BITWISE_AND			= 3,
+	AL_ALU_BITWISE_OR			= 4,
+	AL_ALU_SHIFT_RIGHT_A_BY_B		= 5,
+	AL_ALU_SHIFT_LEFT_A_BY_B		= 6,
+	AL_ALU_BITWISE_XOR			= 7,
+	AL_ALU_FWD_INV_A			= 16,
+	AL_ALU_ARITHMETIC_ADD_INV_A_AND_B	= 17,
+	AL_ALU_ARITHMETIC_SUBTRACT_INV_A_AND_B	= 18,
+	AL_ALU_BITWISE_AND_INV_A_AND_B		= 19,
+	AL_ALU_BITWISE_OR_INV_A_AND_B		= 20,
+	AL_ALU_SHIFT_RIGHT_INV_A_BY_B		= 21,
+	AL_ALU_SHIFT_LEFT_INV_A_BY_B		= 22,
+	AL_ALU_BITWISE_XOR_INV_A_AND_B		= 23,
+	AL_ALU_ARITHMETIC_ADD_A_AND_INV_B	= 33,
+	AL_ALU_ARITHMETIC_SUBTRACT_A_AND_INV_B	= 34,
+	AL_ALU_BITWISE_AND_A_AND_INV_B		= 35,
+	AL_ALU_BITWISE_OR_A_AND_INV_B		= 36,
+	AL_ALU_SHIFT_RIGHT_A_BY_INV_B		= 37,
+	AL_ALU_SHIFT_LEFT_A_BY_INV_B		= 38,
+	AL_ALU_BITWISE_XOR_A_AND_INV_B		= 39,
+	AL_ALU_ARITHMETIC_ADD_INV_A_AND_INV_B	= 49,
+	AL_ALU_ARITHMETIC_SUBTRACT_INV_A_AND	= 50,
+	AL_ALU_BITWISE_AND_INV_A_AND_INV_B	= 51,
+	AL_ALU_BITWISE_OR_INV_A_AND_INV_B	= 52,
+	AL_ALU_SHIFT_RIGHT_INV_A_BY_INV_B	= 53,
+	AL_ALU_SHIFT_LEFT_INV_A_BY_INV_B	= 54,
+	AL_ALU_BITWISE_XOR_INV_A_AND_INV_B	= 55,
+};
+
+#endif		/* __AL_HW_ETH_H__ */
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h b/drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h
new file mode 100644
index 000000000000..c239ac1e8b6c
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/al_hw_eth_ec_regs.h
@@ -0,0 +1,1088 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_EC_REG_H
+#define __AL_HW_EC_REG_H
+
+struct al_ec_gen {
+	/*  Ethernet controller Version */
+	u32 version;
+	/*  Enable modules operation. */
+	u32 en;
+	/*  Enable FIFO operation on the EC side. */
+	u32 fifo_en;
+	/*  General L2 configuration for the Ethernet controlle */
+	u32 l2;
+	/*  Configure protocol index values */
+	u32 cfg_i;
+	/*  Configure protocol index values (extended protocols */
+	u32 cfg_i_ext;
+	/*  Enable modules operation (extended operations). */
+	u32 en_ext;
+	u32 rsrvd[9];
+};
+
+struct al_ec_mac {
+	/*  General configuration of the MAC side of the Ethern */
+	u32 gen;
+	/*  Minimum packet size  */
+	u32 min_pkt;
+	/*  Maximum packet size  */
+	u32 max_pkt;
+	u32 rsrvd[13];
+};
+
+struct al_ec_rxf {
+	/*  Rx FIFO input controller configuration 1 */
+	u32 cfg_1;
+	/*  Rx FIFO input controller configuration 2 */
+	u32 cfg_2;
+	/*  Threshold to start reading packet from the Rx FIFO */
+	u32 rd_fifo;
+	/*  Threshold to stop writing packet to the Rx FIFO */
+	u32 wr_fifo;
+	/*  Threshold to stop writing packet to the loopback FI */
+	u32 lb_fifo;
+	/*  Rx FIFO input controller loopback FIFO configuratio */
+	u32 cfg_lb;
+	/*  Configuration for dropping packet at the FIFO outpu */
+	u32 out_drop;
+	u32 rsrvd[25];
+};
+
+struct al_ec_epe {
+	/*  Ethernet parsing engine configuration 1 */
+	u32 parse_cfg;
+	/*  Protocol index action table address */
+	u32 act_table_addr;
+	/*  Protocol index action table data */
+	u32 act_table_data_1;
+	/*  Protocol index action table data */
+	u32 act_table_data_2;
+	/*  Protocol index action table data */
+	u32 act_table_data_3;
+	/*  Protocol index action table data */
+	u32 act_table_data_4;
+	/*  Protocol index action table data */
+	u32 act_table_data_5;
+	/*  Protocol index action table data */
+	u32 act_table_data_6;
+	/*  Input result vector, default values for parser inpu */
+	u32 res_def;
+	/*  Result input vector selection */
+	u32 res_in;
+	u32 rsrvd[6];
+};
+
+struct al_ec_epe_res {
+	/*  Parser result vector pointer */
+	u32 p1;
+	/*  Parser result vector pointer */
+	u32 p2;
+	/*  Parser result vector pointer */
+	u32 p3;
+	/*  Parser result vector pointer */
+	u32 p4;
+	/*  Parser result vector pointer */
+	u32 p5;
+	/*  Parser result vector pointer */
+	u32 p6;
+	/*  Parser result vector pointer */
+	u32 p7;
+	/*  Parser result vector pointer */
+	u32 p8;
+	/*  Parser result vector pointer */
+	u32 p9;
+	/*  Parser result vector pointer */
+	u32 p10;
+	/*  Parser result vector pointer */
+	u32 p11;
+	/*  Parser result vector pointer */
+	u32 p12;
+	/*  Parser result vector pointer */
+	u32 p13;
+	/*  Parser result vector pointer */
+	u32 p14;
+	/*  Parser result vector pointer */
+	u32 p15;
+	/*  Parser result vector pointer */
+	u32 p16;
+	/*  Parser result vector pointer */
+	u32 p17;
+	/*  Parser result vector pointer */
+	u32 p18;
+	/*  Parser result vector pointer */
+	u32 p19;
+	/*  Parser result vector pointer */
+	u32 p20;
+	u32 rsrvd[12];
+};
+
+struct al_ec_epe_h {
+	/*  Header length, support for header length table for  */
+	u32 hdr_len;
+};
+
+struct al_ec_epe_p {
+	/*  Data  for comparison */
+	u32 comp_data;
+	/*  Mask for comparison */
+	u32 comp_mask;
+	/*  Compare control */
+	u32 comp_ctrl;
+	u32 rsrvd[4];
+};
+
+struct al_ec_epe_a {
+	/*  Protocol index action register */
+	u32 prot_act;
+};
+
+struct al_ec_rfw {
+	/*  Tuple (4/2) Hash configuration */
+	u32 thash_cfg_1;
+	/*  Tuple (4/2) Hash configuration */
+	u32 thash_cfg_2;
+	/*  MAC Hash configuration */
+	u32 mhash_cfg_1;
+	/*  MAC Hash configuration */
+	u32 mhash_cfg_2;
+	/*  MAC Hash configuration */
+	u32 hdr_split;
+	/*  Masking the errors described in  register rxf_drop  */
+	u32 meta_err;
+	/*  Configuration for generating the MetaData for the R */
+	u32 meta;
+	/*  Configuration for generating the MetaData for the R */
+	u32 filter;
+	/*  4 tupple hash table address */
+	u32 thash_table_addr;
+	/*  4 tupple hash table data */
+	u32 thash_table_data;
+	/*  MAC hash table address */
+	u32 mhash_table_addr;
+	/*  MAC hash table data */
+	u32 mhash_table_data;
+	/*  VLAN table address */
+	u32 vid_table_addr;
+	/*  VLAN table data */
+	u32 vid_table_data;
+	/*  VLAN p-bits table address */
+	u32 pbits_table_addr;
+	/*  VLAN p-bits table data */
+	u32 pbits_table_data;
+	/*  DSCP table address */
+	u32 dscp_table_addr;
+	/*  DSCP table data */
+	u32 dscp_table_data;
+	/*  TC table address */
+	u32 tc_table_addr;
+	/*  TC table data */
+	u32 tc_table_data;
+	/*  Control table address */
+	u32 ctrl_table_addr;
+	/*  Control table data */
+	u32 ctrl_table_data;
+	/*  Forwarding output configuration */
+	u32 out_cfg;
+	/*  Flow steering mechanism, Table address */
+	u32 fsm_table_addr;
+	/*  Flow steering mechanism, Table data */
+	u32 fsm_table_data;
+	/*  Selection of data to be used in packet forwarding0  */
+	u32 ctrl_sel;
+	/*  Default VLAN data, used for untagged packets */
+	u32 default_vlan;
+	/*  Default HASH output values */
+	u32 default_hash;
+	/*  Default override values, if a packet was filtered b */
+	u32 default_or;
+	/*  Latched information when a drop condition occurred */
+	u32 drop_latch;
+	/*  Check sum calculation configuration */
+	u32 checksum;
+	/*  LRO offload engine configuration register */
+	u32 lro_cfg_1;
+	/*  LRO offload engine Check rules configurations for I */
+	u32 lro_check_ipv4;
+	/*  LRO offload engine IPv4 values configuration */
+	u32 lro_ipv4;
+	/*  LRO offload engine Check rules configurations for I */
+	u32 lro_check_ipv6;
+	/*  LRO offload engine IPv6 values configuration */
+	u32 lro_ipv6;
+	/*  LRO offload engine Check rules configurations for T */
+	u32 lro_check_tcp;
+	/*  LRO offload engine IPv6 values configuration */
+	u32 lro_tcp;
+	/*  LRO offload engine Check rules configurations for U */
+	u32 lro_check_udp;
+	/*  LRO offload engine Check rules configurations for U */
+	u32 lro_check_l2;
+	/*  LRO offload engine Check rules configurations for U */
+	u32 lro_check_gen;
+	/*  Rules for storing packet information into the cache */
+	u32 lro_store;
+	/*  VLAN table default */
+	u32 vid_table_def;
+	/*  Control table default */
+	u32 ctrl_table_def;
+	/*  Additional configuration 0 */
+	u32 cfg_a_0;
+	/*  Tuple (4/2) Hash configuration (extended for RoCE a */
+	u32 thash_cfg_3;
+	/*  Tuple (4/2) Hash configuration , mask for the input */
+	u32 thash_mask_outer_ipv6;
+	/*  Tuple (4/2) Hash configuration , mask for the input */
+	u32 thash_mask_outer;
+	/*  Tuple (4/2) Hash configuration , mask for the input */
+	u32 thash_mask_inner_ipv6;
+	/*  Tuple (4/2) Hash configuration , mask for the input */
+	u32 thash_mask_inner;
+	u32 rsrvd[10];
+};
+
+struct al_ec_rfw_udma {
+	/*  Per UDMA default configuration */
+	u32 def_cfg;
+};
+
+struct al_ec_rfw_hash {
+	/*  key configuration (320 bits) */
+	u32 key;
+};
+
+struct al_ec_rfw_priority {
+	/*  Priority to queue mapping configuration */
+	u32 queue;
+};
+
+struct al_ec_rfw_default {
+	/*  Default forwarding configuration options */
+	u32 opt_1;
+};
+
+struct al_ec_fwd_mac {
+	/*  MAC address data [31:0] */
+	u32 data_l;
+	/*  MAC address data [15:0] */
+	u32 data_h;
+	/*  MAC address mask [31:0] */
+	u32 mask_l;
+	/*  MAC address mask [15:0] */
+	u32 mask_h;
+	/*  MAC compare control */
+	u32 ctrl;
+};
+
+struct al_ec_msw {
+	/*  Configuration for unicast packets */
+	u32 uc;
+	/*  Configuration for multicast packets */
+	u32 mc;
+	/*  Configuration for broadcast packets */
+	u32 bc;
+	u32 rsrvd[3];
+};
+
+struct al_ec_tso {
+	/*  Input configuration */
+	u32 in_cfg;
+	/*  MetaData default cache table address */
+	u32 cache_table_addr;
+	/*  MetaData default cache table data */
+	u32 cache_table_data_1;
+	/*  MetaData default cache table data */
+	u32 cache_table_data_2;
+	/*  MetaData default cache table data */
+	u32 cache_table_data_3;
+	/*  MetaData default cache table data */
+	u32 cache_table_data_4;
+	/*  TCP control bit operation for first segment */
+	u32 ctrl_first;
+	/*  TCP control bit operation for middle segments  */
+	u32 ctrl_middle;
+	/*  TCP control bit operation for last segment */
+	u32 ctrl_last;
+	/*  Additional TSO configurations */
+	u32 cfg_add_0;
+	/*  TSO configuration for tunnelled packets */
+	u32 cfg_tunnel;
+	u32 rsrvd[13];
+};
+
+struct al_ec_tso_sel {
+	/*  MSS value */
+	u32 mss;
+};
+
+struct al_ec_tpe {
+	/*  Parsing configuration */
+	u32 parse;
+	u32 rsrvd[15];
+};
+
+struct al_ec_tpm_udma {
+	/*  Default VLAN data */
+	u32 vlan_data;
+	/*  UDMA MAC SA information for spoofing */
+	u32 mac_sa_1;
+	/*  UDMA MAC SA information for spoofing */
+	u32 mac_sa_2;
+};
+
+struct al_ec_tpm_sel {
+	/*  Ethertype values for VLAN modification */
+	u32 etype;
+};
+
+struct al_ec_tfw {
+	/*  Tx FIFO Wr configuration */
+	u32 tx_wr_fifo;
+	/*  VLAN table address */
+	u32 tx_vid_table_addr;
+	/*  VLAN table data */
+	u32 tx_vid_table_data;
+	/*  Tx FIFO Rd configuration */
+	u32 tx_rd_fifo;
+	/*  Tx FIFO Rd configuration, checksum insertion */
+	u32 tx_checksum;
+	/*  Tx forwarding general configuration register */
+	u32 tx_gen;
+	/*  Tx spoofing configuration */
+	u32 tx_spf;
+	/*  TX data FIFO status */
+	u32 data_fifo;
+	/*  Tx control FIFO status */
+	u32 ctrl_fifo;
+	/*  Tx header FIFO status */
+	u32 hdr_fifo;
+	u32 rsrvd[14];
+};
+
+struct al_ec_tfw_udma {
+	/*  Default GMDA output bitmap for unicast packet */
+	u32 uc_udma;
+	/*  Default GMDA output bitmap for multicast packet */
+	u32 mc_udma;
+	/*  Default GMDA output bitmap for broadcast packet */
+	u32 bc_udma;
+	/*  Tx spoofing configuration */
+	u32 spf_cmd;
+	/*  Forwarding decision control */
+	u32 fwd_dec;
+	u32 rsrvd;
+};
+
+struct al_ec_tmi {
+	/*  Forward packets back to the Rx data path for local  */
+	u32 tx_cfg;
+	u32 rsrvd[3];
+};
+
+struct al_ec_efc {
+	/*  Mask of pause_on  [7:0] for the Ethernet controller */
+	u32 ec_pause;
+	/*  Mask of Ethernet controller Almost Full indication  */
+	u32 ec_xoff;
+	/*  Mask for generating XON indication pulse */
+	u32 xon;
+	/*  Mask for generating GPIO output XOFF indication fro */
+	u32 gpio;
+	/*  Rx FIFO threshold for generating the Almost Full in */
+	u32 rx_fifo_af;
+	/*  Rx FIFO threshold for generating the Almost Full in */
+	u32 rx_fifo_hyst;
+	/*  Rx FIFO threshold for generating the Almost Full in */
+	u32 stat;
+	/*  XOFF timer for the 1G MACSets the interval (in SB_C */
+	u32 xoff_timer_1g;
+	/*  PFC force flow control generation */
+	u32 ec_pfc;
+	u32 rsrvd[3];
+};
+
+struct al_ec_fc_udma {
+	/*  Mask of "pause_on"  [0] for all queues */
+	u32 q_pause_0;
+	/*  Mask of "pause_on"  [1] for all queues */
+	u32 q_pause_1;
+	/*  Mask of "pause_on"  [2] for all queues */
+	u32 q_pause_2;
+	/*  Mask of "pause_on"  [3] for all queues */
+	u32 q_pause_3;
+	/*  Mask of "pause_on"  [4] for all queues */
+	u32 q_pause_4;
+	/*  Mask of "pause_on"  [5] for all queues */
+	u32 q_pause_5;
+	/*  Mask of "pause_on"  [6] for all queues */
+	u32 q_pause_6;
+	/*  Mask of "pause_on"  [7] for all queues */
+	u32 q_pause_7;
+	/*  Mask of external GPIO input pause [0] for all queue */
+	u32 q_gpio_0;
+	/*  Mask of external GPIO input pause [1] for all queue */
+	u32 q_gpio_1;
+	/*  Mask of external GPIO input pause [2] for all queue */
+	u32 q_gpio_2;
+	/*  Mask of external GPIO input pause [3] for all queue */
+	u32 q_gpio_3;
+	/*  Mask of external GPIO input [4] for all queues */
+	u32 q_gpio_4;
+	/*  Mask of external GPIO input [5] for all queues */
+	u32 q_gpio_5;
+	/*  Mask of external GPIO input [6] for all queues */
+	u32 q_gpio_6;
+	/*  Mask of external GPIO input [7] for all queues */
+	u32 q_gpio_7;
+	/*  Mask of "pause_on"  [7:0] for the UDMA stream inter */
+	u32 s_pause;
+	/*  Mask of Rx Almost Full indication for generating XO */
+	u32 q_xoff_0;
+	/*  Mask of Rx Almost Full indication for generating XO */
+	u32 q_xoff_1;
+	/*  Mask of Rx Almost Full indication for generating XO */
+	u32 q_xoff_2;
+	/*  Mask of Rx Almost Full indication for generating XO */
+	u32 q_xoff_3;
+	/*  Mask of Rx Almost Full indication for generating XO */
+	u32 q_xoff_4;
+	/*  Mask of Rx Almost Full indication for generating XO */
+	u32 q_xoff_5;
+	/*  Mask of Rx Almost Full indication for generating XO */
+	u32 q_xoff_6;
+	/*  Mask of Rx Almost Full indication for generating XO */
+	u32 q_xoff_7;
+	u32 rsrvd[7];
+};
+
+struct al_ec_tpg_rpa_res {
+	/*  NOT used */
+	u32 not_used;
+	u32 rsrvd[63];
+};
+
+struct al_ec_eee {
+	/*  EEE configuration */
+	u32 cfg_e;
+	/*  Number of clocks to get into EEE mode. */
+	u32 pre_cnt;
+	/*  Number of clocks to stop MAC EEE mode after getting */
+	u32 post_cnt;
+	/*  Number of clocks to stop the Tx MAC interface after */
+	u32 stop_cnt;
+	/*  EEE status */
+	u32 stat_eee;
+	u32 rsrvd[59];
+};
+
+struct al_ec_stat {
+	/*  Rx Frequency adjust FIFO input  packets */
+	u32 faf_in_rx_pkt;
+	/*  Rx Frequency adjust FIFO input short error packets */
+	u32 faf_in_rx_short;
+	/*  Rx Frequency adjust FIFO input  long error packets */
+	u32 faf_in_rx_long;
+	/*  Rx Frequency adjust FIFO output  packets */
+	u32 faf_out_rx_pkt;
+	/*  Rx Frequency adjust FIFO output short error packets */
+	u32 faf_out_rx_short;
+	/*  Rx Frequency adjust FIFO output long error packets */
+	u32 faf_out_rx_long;
+	/*  Rx Frequency adjust FIFO output  drop packets */
+	u32 faf_out_drop;
+	/*  Number of packets written into the Rx FIFO (without */
+	u32 rxf_in_rx_pkt;
+	/*  Number of error packets written into the Rx FIFO (w */
+	u32 rxf_in_fifo_err;
+	/*  Number of packets written into the loopback FIFO (w */
+	u32 lbf_in_rx_pkt;
+	/*  Number of error packets written into the loopback F */
+	u32 lbf_in_fifo_err;
+	/*  Number of packets read from Rx FIFO 1 */
+	u32 rxf_out_rx_1_pkt;
+	/*  Number of packets read from Rx FIFO 2 (loopback FIF */
+	u32 rxf_out_rx_2_pkt;
+	/*  Rx FIFO output drop packets from FIFO 1 */
+	u32 rxf_out_drop_1_pkt;
+	/*  Rx FIFO output drop packets from FIFO 2 (loopback) */
+	u32 rxf_out_drop_2_pkt;
+	/*  Rx Parser 1, input packet counter */
+	u32 rpe_1_in_rx_pkt;
+	/*  Rx Parser 1, output packet counter */
+	u32 rpe_1_out_rx_pkt;
+	/*  Rx Parser 2, input packet counter */
+	u32 rpe_2_in_rx_pkt;
+	/*  Rx Parser 2, output packet counter */
+	u32 rpe_2_out_rx_pkt;
+	/*  Rx Parser 3 (MACsec), input packet counter */
+	u32 rpe_3_in_rx_pkt;
+	/*  Rx Parser 3 (MACsec), output packet counter */
+	u32 rpe_3_out_rx_pkt;
+	/*  Tx parser, input packet counter */
+	u32 tpe_in_tx_pkt;
+	/*  Tx parser, output packet counter */
+	u32 tpe_out_tx_pkt;
+	/*  Tx packet modification, input packet counter */
+	u32 tpm_tx_pkt;
+	/*  Tx forwarding input packet counter */
+	u32 tfw_in_tx_pkt;
+	/*  Tx forwarding input packet counter */
+	u32 tfw_out_tx_pkt;
+	/*  Rx forwarding input packet counter */
+	u32 rfw_in_rx_pkt;
+	/*  Rx Forwarding, packet with VLAN command drop indica */
+	u32 rfw_in_vlan_drop;
+	/*  Rx Forwarding, packets with parse drop indication */
+	u32 rfw_in_parse_drop;
+	/*  Rx Forwarding, multicast packets */
+	u32 rfw_in_mc;
+	/*  Rx Forwarding, broadcast packets */
+	u32 rfw_in_bc;
+	/*  Rx Forwarding, tagged packets */
+	u32 rfw_in_vlan_exist;
+	/*  Rx Forwarding, untagged packets */
+	u32 rfw_in_vlan_nexist;
+	/*  Rx Forwarding, packets with MAC address drop indica */
+	u32 rfw_in_mac_drop;
+	/*  Rx Forwarding, packets with undetected MAC address */
+	u32 rfw_in_mac_ndet_drop;
+	/*  Rx Forwarding, packets with drop indication from th */
+	u32 rfw_in_ctrl_drop;
+	/*  Rx Forwarding, packets with L3_protocol_index drop  */
+	u32 rfw_in_prot_i_drop;
+	/*  EEE, number of times the system went into EEE state */
+	u32 eee_in;
+	u32 rsrvd[90];
+};
+
+struct al_ec_stat_udma {
+	/*  Rx forwarding output packet counter */
+	u32 rfw_out_rx_pkt;
+	/*  Rx forwarding output drop packet counter */
+	u32 rfw_out_drop;
+	/*  Multi-stream write, number of Rx packets */
+	u32 msw_in_rx_pkt;
+	/*  Multi-stream write, number of dropped packets at SO */
+	u32 msw_drop_q_full;
+	/*  Multi-stream write, number of dropped packets at SO */
+	u32 msw_drop_sop;
+	/*  Multi-stream write, number of dropped packets at EO */
+	u32 msw_drop_eop;
+	/*  Multi-stream write, number of packets written to th */
+	u32 msw_wr_eop;
+	/*  Multi-stream write, number of packets read from the */
+	u32 msw_out_rx_pkt;
+	/*  Number of transmitted packets without TSO enabled */
+	u32 tso_no_tso_pkt;
+	/*  Number of transmitted packets with TSO enabled */
+	u32 tso_tso_pkt;
+	/*  Number of TSO segments that were generated */
+	u32 tso_seg_pkt;
+	/*  Number of TSO segments that required padding */
+	u32 tso_pad_pkt;
+	/*  Tx Packet modification, MAC SA spoof error  */
+	u32 tpm_tx_spoof;
+	/*  Tx MAC interface, input packet counter */
+	u32 tmi_in_tx_pkt;
+	/*  Tx MAC interface, number of packets forwarded to th */
+	u32 tmi_out_to_mac;
+	/*  Tx MAC interface, number of packets forwarded to th */
+	u32 tmi_out_to_rx;
+	/*  Tx MAC interface, number of transmitted bytes */
+	u32 tx_q0_bytes;
+	/*  Tx MAC interface, number of transmitted bytes */
+	u32 tx_q1_bytes;
+	/*  Tx MAC interface, number of transmitted bytes */
+	u32 tx_q2_bytes;
+	/*  Tx MAC interface, number of transmitted bytes */
+	u32 tx_q3_bytes;
+	/*  Tx MAC interface, number of transmitted packets */
+	u32 tx_q0_pkts;
+	/*  Tx MAC interface, number of transmitted packets */
+	u32 tx_q1_pkts;
+	/*  Tx MAC interface, number of transmitted packets */
+	u32 tx_q2_pkts;
+	/*  Tx MAC interface, number of transmitted packets */
+	u32 tx_q3_pkts;
+	u32 rsrvd[40];
+};
+
+struct al_ec_msp {
+	/*  Ethernet parsing engine configuration 1 */
+	u32 p_parse_cfg;
+	/*  Protocol index action table address */
+	u32 p_act_table_addr;
+	/*  Protocol index action table data */
+	u32 p_act_table_data_1;
+	/*  Protocol index action table data */
+	u32 p_act_table_data_2;
+	/*  Protocol index action table data */
+	u32 p_act_table_data_3;
+	/*  Protocol index action table data */
+	u32 p_act_table_data_4;
+	/*  Protocol index action table data */
+	u32 p_act_table_data_5;
+	/*  Protocol index action table data */
+	u32 p_act_table_data_6;
+	/*  Input result vector, default values for parser inpu */
+	u32 p_res_def;
+	/*  Result input vector selection */
+	u32 p_res_in;
+	u32 rsrvd[6];
+};
+
+struct al_ec_msp_p {
+	/*  Header length, support for header length table for  */
+	u32 h_hdr_len;
+};
+
+struct al_ec_msp_c {
+	/*  Data  for comparison */
+	u32 p_comp_data;
+	/*  Mask for comparison */
+	u32 p_comp_mask;
+	/*  Compare control */
+	u32 p_comp_ctrl;
+	u32 rsrvd[4];
+};
+
+struct al_ec_wol {
+	/*  WoL enable configuration,Packet forwarding and inte */
+	u32 wol_en;
+	/*  Password for magic_password packet detection - bits */
+	u32 magic_pswd_l;
+	/*  Password for magic+password packet detection -  47: */
+	u32 magic_pswd_h;
+	/*  Configured L3 Destination IP address for WoL IPv6 p */
+	u32 ipv6_dip_word0;
+	/*  Configured L3 Destination IP address for WoL IPv6 p */
+	u32 ipv6_dip_word1;
+	/*  Configured L3 Destination IP address for WoL IPv6 p */
+	u32 ipv6_dip_word2;
+	/*  Configured L3 Destination IP address for WoL IPv6 p */
+	u32 ipv6_dip_word3;
+	/*  Configured L3 Destination IP address for WoL IPv4 p */
+	u32 ipv4_dip;
+	/*  Configured EtherType for WoL EtherType_da/EtherType */
+	u32 ethertype;
+	u32 rsrvd[7];
+};
+
+struct al_ec_pth {
+	/*  System time counter (Time of Day) */
+	u32 system_time_seconds;
+	/*  System time subseconds in a second (MSBs) */
+	u32 system_time_subseconds_msb;
+	/*  System time subseconds in a second (LSBs) */
+	u32 system_time_subseconds_lsb;
+	/*  Clock period in femtoseconds (MSB) */
+	u32 clock_period_msb;
+	/*  Clock period in femtoseconds (LSB) */
+	u32 clock_period_lsb;
+	/*  Control register for internal updates to the system */
+	u32 int_update_ctrl;
+	/*  Value to update system_time_seconds with */
+	u32 int_update_seconds;
+	/*  Value to update system_time_subseconds_msb with */
+	u32 int_update_subseconds_msb;
+	/*  Value to update system_time_subseconds_lsb with */
+	u32 int_update_subseconds_lsb;
+	/*  Control register for external updates to the system */
+	u32 ext_update_ctrl;
+	/*  Value to update system_time_seconds with */
+	u32 ext_update_seconds;
+	/*  Value to update system_time_subseconds_msb with */
+	u32 ext_update_subseconds_msb;
+	/*  Value to update system_time_subseconds_lsb with */
+	u32 ext_update_subseconds_lsb;
+	/*  This value represents the APB transaction delay fro */
+	u32 read_compensation_subseconds_msb;
+	/*  This value represents the APB transaction delay fro */
+	u32 read_compensation_subseconds_lsb;
+	/*  This value is used for two purposes:1 */
+	u32 int_write_compensation_subseconds_msb;
+	/*  This value is used for two purposes:1 */
+	u32 int_write_compensation_subseconds_lsb;
+	/*  This value represents the number of cycles it for a */
+	u32 ext_write_compensation_subseconds_msb;
+	/*  This value represents the number of cycles it for a */
+	u32 ext_write_compensation_subseconds_lsb;
+	/*  Value to be added to system_time before transferrin */
+	u32 sync_compensation_subseconds_msb;
+	/*  Value to be added to system_time before transferrin */
+	u32 sync_compensation_subseconds_lsb;
+	u32 rsrvd[11];
+};
+
+struct al_ec_pth_egress {
+	/*  Control register for egress trigger #k */
+	u32 trigger_ctrl;
+	/*  threshold for next egress trigger (#k) - secondsWri */
+	u32 trigger_seconds;
+	/*  Threshold for next egress trigger (#k) - subseconds */
+	u32 trigger_subseconds_msb;
+	/*  threshold for next egress trigger (#k) - subseconds */
+	u32 trigger_subseconds_lsb;
+	/*  External output pulse width (subseconds_msb)(Atomic */
+	u32 pulse_width_subseconds_msb;
+	/*  External output pulse width (subseconds_lsb)(Atomic */
+	u32 pulse_width_subseconds_lsb;
+	u32 rsrvd[2];
+};
+
+struct al_ec_pth_db {
+	/*  timestamp[k], in resolution of 2^18 femtosec =~ 0 */
+	u32 ts;
+	/*  Timestamp entry is valid */
+	u32 qual;
+	u32 rsrvd[4];
+};
+
+struct al_ec_gen_v3 {
+	/*  Bypass enable */
+	u32 bypass;
+	/*  Rx Completion descriptor */
+	u32 rx_comp_desc;
+	/*  general configuration */
+	u32 conf;
+	u32 rsrvd[13];
+};
+
+struct al_ec_tfw_v3 {
+	/*  Generic protocol detect Cam compare table address */
+	u32 tx_gpd_cam_addr;
+	/*  Tx Generic protocol detect Cam compare data_1 (low) */
+	u32 tx_gpd_cam_data_1;
+	/*  Tx Generic protocol detect Cam compare data_2 (high */
+	u32 tx_gpd_cam_data_2;
+	/*  Tx Generic protocol detect Cam compare mask_1 (low) */
+	u32 tx_gpd_cam_mask_1;
+	/*  Tx Generic protocol detect Cam compare mask_1 (high */
+	u32 tx_gpd_cam_mask_2;
+	/*  Tx Generic protocol detect Cam compare control */
+	u32 tx_gpd_cam_ctrl;
+	/*  Tx Generic crc parameters legacy */
+	u32 tx_gcp_legacy;
+	/*  Tx Generic crc prameters table address */
+	u32 tx_gcp_table_addr;
+	/*  Tx Generic crc prameters table general */
+	u32 tx_gcp_table_gen;
+	/*  Tx Generic crc parametrs tabel mask word 1 */
+	u32 tx_gcp_table_mask_1;
+	/*  Tx Generic crc parametrs tabel mask word 2 */
+	u32 tx_gcp_table_mask_2;
+	/*  Tx Generic crc parametrs tabel mask word 3 */
+	u32 tx_gcp_table_mask_3;
+	/*  Tx Generic crc parametrs tabel mask word 4 */
+	u32 tx_gcp_table_mask_4;
+	/*  Tx Generic crc parametrs tabel mask word 5 */
+	u32 tx_gcp_table_mask_5;
+	/*  Tx Generic crc parametrs tabel mask word 6 */
+	u32 tx_gcp_table_mask_6;
+	/*  Tx Generic crc parametrs tabel crc init */
+	u32 tx_gcp_table_crc_init;
+	/*  Tx Generic crc parametrs tabel result configuration */
+	u32 tx_gcp_table_res;
+	/*  Tx Generic crc parameters table alu opcode */
+	u32 tx_gcp_table_alu_opcode;
+	/*  Tx Generic crc parameters table alu opsel */
+	u32 tx_gcp_table_alu_opsel;
+	/*  Tx Generic crc parameters table alu constant value */
+	u32 tx_gcp_table_alu_val;
+	/*  Tx CRC/Checksum replace */
+	u32 crc_csum_replace;
+	/*  CRC/Checksum replace table address */
+	u32 crc_csum_replace_table_addr;
+	/*  CRC/Checksum replace table */
+	u32 crc_csum_replace_table;
+	u32 rsrvd[9];
+};
+
+struct al_ec_rfw_v3 {
+	/*  Rx Generic protocol detect Cam compare table address */
+	u32 rx_gpd_cam_addr;
+	/*  Rx Generic protocol detect Cam compare data_1 (low) */
+	u32 rx_gpd_cam_data_1;
+	/*  Rx Generic protocol detect Cam compare data_2 (high */
+	u32 rx_gpd_cam_data_2;
+	/*  Rx Generic protocol detect Cam compare mask_1 (low) */
+	u32 rx_gpd_cam_mask_1;
+	/*  Rx Generic protocol detect Cam compare mask_1 (high */
+	u32 rx_gpd_cam_mask_2;
+	/*  Rx Generic protocol detect Cam compare control */
+	u32 rx_gpd_cam_ctrl;
+	/*  Generic protocol detect Parser result vector pointe */
+	u32 gpd_p1;
+	/*  Generic protocol detect Parser result vector pointe */
+	u32 gpd_p2;
+	/*  Generic protocol detect Parser result vector pointe */
+	u32 gpd_p3;
+	/*  Generic protocol detect Parser result vector pointe */
+	u32 gpd_p4;
+	/*  Generic protocol detect Parser result vector pointe */
+	u32 gpd_p5;
+	/*  Generic protocol detect Parser result vector pointe */
+	u32 gpd_p6;
+	/*  Generic protocol detect Parser result vector pointe */
+	u32 gpd_p7;
+	/*  Generic protocol detect Parser result vector pointe */
+	u32 gpd_p8;
+	/*  Rx Generic crc parameters legacy */
+	u32 rx_gcp_legacy;
+	/*  Rx Generic crc prameters table address */
+	u32 rx_gcp_table_addr;
+	/*  Rx Generic crc prameters table general */
+	u32 rx_gcp_table_gen;
+	/*  Rx Generic crc parametrs tabel mask word 1 */
+	u32 rx_gcp_table_mask_1;
+	/*  Rx Generic crc parametrs tabel mask word 2 */
+	u32 rx_gcp_table_mask_2;
+	/*  Rx Generic crc parametrs tabel mask word 3 */
+	u32 rx_gcp_table_mask_3;
+	/*  Rx Generic crc parametrs tabel mask word 4 */
+	u32 rx_gcp_table_mask_4;
+	/*  Rx Generic crc parametrs tabel mask word 5 */
+	u32 rx_gcp_table_mask_5;
+	/*  Rx Generic crc parametrs tabel mask word 6 */
+	u32 rx_gcp_table_mask_6;
+	/*  Rx Generic crc parametrs tabel crc init */
+	u32 rx_gcp_table_crc_init;
+	/*  Rx Generic crc parametrs tabel result configuration */
+	u32 rx_gcp_table_res;
+	/*  Rx Generic crc  parameters table alu opcode */
+	u32 rx_gcp_table_alu_opcode;
+	/*  Rx Generic crc  parameters table alu opsel */
+	u32 rx_gcp_table_alu_opsel;
+	/*  Rx Generic crc  parameters table alu constant value */
+	u32 rx_gcp_table_alu_val;
+	/*  Generic crc engin parameters alu Parser result vect */
+	u32 rx_gcp_alu_p1;
+	/*  Generic crc engine parameters alu Parser result vec */
+	u32 rx_gcp_alu_p2;
+	/*  Header split control table address */
+	u32 hs_ctrl_table_addr;
+	/*  Header split control table */
+	u32 hs_ctrl_table;
+	/*  Header split control alu opcode */
+	u32 hs_ctrl_table_alu_opcode;
+	/*  Header split control alu opsel */
+	u32 hs_ctrl_table_alu_opsel;
+	/*  Header split control alu constant value */
+	u32 hs_ctrl_table_alu_val;
+	/*  Header split control configuration */
+	u32 hs_ctrl_cfg;
+	/*  Header split control alu Parser result vector point */
+	u32 hs_ctrl_alu_p1;
+	/*  Header split control alu Parser result vector point */
+	u32 hs_ctrl_alu_p2;
+	u32 rsrvd[26];
+};
+
+struct al_ec_crypto {
+	/*  Tx inline crypto configuration */
+	u32 tx_config;
+	/*  Rx inline crypto configuration */
+	u32 rx_config;
+	/*  reserved FFU */
+	u32 tx_override;
+	/*  reserved FFU */
+	u32 rx_override;
+	/*  inline XTS alpha [31:0] */
+	u32 xts_alpha_1;
+	/*  inline XTS alpha [63:32] */
+	u32 xts_alpha_2;
+	/*  inline XTS alpha [95:64] */
+	u32 xts_alpha_3;
+	/*  inline XTS alpha [127:96] */
+	u32 xts_alpha_4;
+	/*  inline XTS sector ID increment [31:0] */
+	u32 xts_sector_id_1;
+	/*  inline XTS sector ID increment [63:32] */
+	u32 xts_sector_id_2;
+	/*  inline XTS sector ID increment [95:64] */
+	u32 xts_sector_id_3;
+	/*  inline XTS sector ID increment [127:96] */
+	u32 xts_sector_id_4;
+	/*  IV formation configuration */
+	u32 tx_enc_iv_construction;
+	/*  IV formation configuration */
+	u32 rx_enc_iv_construction;
+	/*  IV formation configuration */
+	u32 rx_enc_iv_map;
+	/*
+	 * effectively shorten shift-registers used for eop-pkt-trim, in order
+	 * to improve performance.  Each value must be built of consecutive 1's
+	 * (bypassed regs), and then consecutive 0's (non-bypassed regs)
+	 */
+	u32 tx_pkt_trim_len;
+	/*
+	 * effectively shorten shift-registers used for eop-pkt-trim, in order
+	 * to improve performance.  Each value must be built of consecutive 1's
+	 * (bypassed regs), and then consecutive 0's (non-bypassed regs)
+	 */
+	u32 rx_pkt_trim_len;
+	/*  reserved FFU */
+	u32 tx_reserved;
+	/*  reserved FFU */
+	u32 rx_reserved;
+	u32 rsrvd[13];
+};
+
+struct al_ec_crypto_perf_cntr {
+	u32 total_tx_pkts;
+	u32 total_rx_pkts;
+	u32 total_tx_secured_pkts;
+	u32 total_rx_secured_pkts;
+	u32 total_tx_secured_pkts_cipher_mode;
+	u32 total_tx_secured_pkts_cipher_mode_cmpr;
+	u32 total_rx_secured_pkts_cipher_mode;
+	u32 total_rx_secured_pkts_cipher_mode_cmpr;
+	u32 total_tx_secured_bytes_low;
+	u32 total_tx_secured_bytes_high;
+	u32 total_rx_secured_bytes_low;
+	u32 total_rx_secured_bytes_high;
+	u32 total_tx_sign_calcs;
+	u32 total_rx_sign_calcs;
+	u32 total_tx_sign_errs;
+	u32 total_rx_sign_errs;
+};
+
+struct al_ec_crypto_tx_tid {
+	/*  tid_default_entry */
+	u32 def_val;
+};
+
+struct al_ec_regs {
+	u32 rsrvd_0[32];
+	struct al_ec_gen gen;
+	struct al_ec_mac mac;
+	struct al_ec_rxf rxf;
+	struct al_ec_epe epe[2];
+	struct al_ec_epe_res epe_res;
+	struct al_ec_epe_h epe_h[32];
+	struct al_ec_epe_p epe_p[32];
+	struct al_ec_epe_a epe_a[32];
+	struct al_ec_rfw rfw;
+	struct al_ec_rfw_udma rfw_udma[4];
+	struct al_ec_rfw_hash rfw_hash[10];
+	struct al_ec_rfw_priority rfw_priority[8];
+	struct al_ec_rfw_default rfw_default[8];
+	struct al_ec_fwd_mac fwd_mac[32];
+	struct al_ec_msw msw;
+	struct al_ec_tso tso;
+	struct al_ec_tso_sel tso_sel[8];
+	struct al_ec_tpe tpe;
+	struct al_ec_tpm_udma tpm_udma[4];
+	struct al_ec_tpm_sel tpm_sel[4];
+	struct al_ec_tfw tfw;
+	struct al_ec_tfw_udma tfw_udma[4];
+	struct al_ec_tmi tmi;
+	struct al_ec_efc efc;
+	struct al_ec_fc_udma fc_udma[4];
+	struct al_ec_tpg_rpa_res tpg_rpa_res;
+	struct al_ec_eee eee;
+	struct al_ec_stat stat;
+	struct al_ec_stat_udma stat_udma[4];
+	struct al_ec_msp msp;
+	struct al_ec_msp_p msp_p[32];
+	struct al_ec_msp_c msp_c[32];
+	u32 rsrvd_1[16];
+	struct al_ec_wol wol;
+	u32 rsrvd_2[80];
+	struct al_ec_pth pth;
+	struct al_ec_pth_egress pth_egress[8];
+	struct al_ec_pth_db pth_db[16];
+	u32 rsrvd_3[416];
+	struct al_ec_gen_v3 gen_v3;
+	struct al_ec_tfw_v3 tfw_v3;
+	struct al_ec_rfw_v3 rfw_v3;
+	struct al_ec_crypto crypto;
+	struct al_ec_crypto_perf_cntr crypto_perf_cntr[2];
+	u32 rsrvd_4[48];
+	struct al_ec_crypto_tx_tid crypto_tx_tid[8];
+};
+
+/* Selection between descriptor caching options (WORD selection) */
+#define EC_GEN_EN_EXT_CACHE_WORD_SPLIT   BIT(20)
+
+/* Drop indication for the selected protocol index */
+#define EC_EPE_A_PROT_ACT_DROP           BIT(0)
+
+/* Enable SIP/DIP swap if SIP<DIP */
+#define EC_RFW_THASH_CFG_1_ENABLE_IP_SWAP BIT(16)
+/* Enable PORT swap if SPORT<DPORT */
+#define EC_RFW_THASH_CFG_1_ENABLE_PORT_SWAP BIT(17)
+
+/* Selects how to calculate the L3 header length when L3 is IpPv */
+#define EC_RFW_META_L3_LEN_CALC          BIT(4)
+
+/* Number of MetaData at the end of the packet1 - One MetaData b */
+#define EC_RFW_OUT_CFG_META_CNT_MASK     0x00000003
+/* Enable packet drop */
+#define EC_RFW_OUT_CFG_DROP_EN           BIT(2)
+
+/* Select the header that will be used for the checksum when a t */
+#define EC_RFW_CHECKSUM_HDR_SEL          BIT(1)
+
+/* Default data selection 0 - Default value 1 - Table data out */
+#define EC_RFW_CTRL_TABLE_DEF_SEL        BIT(20)
+
+/* Drop indication */
+#define EC_FWD_MAC_CTRL_RX_VAL_DROP		BIT(0)
+
+/* UDMA selection */
+#define EC_FWD_MAC_CTRL_RX_VAL_UDMA_MASK	0x000000078
+#define EC_FWD_MAC_CTRL_RX_VAL_UDMA_SHIFT	3
+
+/* queue number */
+#define EC_FWD_MAC_CTRL_RX_VAL_QID_MASK		0x00000180
+#define EC_FWD_MAC_CTRL_RX_VAL_QID_SHIFT	7
+
+/* Entry is valid for Rx forwarding engine. */
+#define EC_FWD_MAC_CTRL_RX_VALID         BIT(15)
+/* Control value for Tx forwarding engine */
+#define EC_FWD_MAC_CTRL_TX_VAL_MASK      0x001F0000
+#define EC_FWD_MAC_CTRL_TX_VAL_SHIFT     16
+/* Entry is valid for Tx forwarding engine. */
+#define EC_FWD_MAC_CTRL_TX_VALID         BIT(31)
+
+/* MSS selection option:0 - MSS value is selected using MSS_sel  */
+#define EC_TSO_CFG_ADD_0_MSS_SEL         BIT(0)
+
+/* Enable TSO with tunnelling */
+#define EC_TSO_CFG_TUNNEL_EN_TUNNEL_TSO  BIT(0)
+/* Enable outer UDP checksum update */
+#define EC_TSO_CFG_TUNNEL_EN_UDP_CHKSUM  BIT(8)
+/* Enable outer UDP length update */
+#define EC_TSO_CFG_TUNNEL_EN_UDP_LEN     BIT(9)
+/* Enable outer Ip6  length update */
+#define EC_TSO_CFG_TUNNEL_EN_IPV6_PLEN   BIT(10)
+/* Enable outer IPv4 checksum update */
+#define EC_TSO_CFG_TUNNEL_EN_IPV4_CHKSUM BIT(11)
+/* Enable outer IPv4 Identification update */
+#define EC_TSO_CFG_TUNNEL_EN_IPV4_IDEN   BIT(12)
+/* Enable outer IPv4 length update */
+#define EC_TSO_CFG_TUNNEL_EN_IPV4_TLEN   BIT(13)
+
+/* Swap output byte order */
+#define EC_TMI_TX_CFG_SWAP_BYTES         BIT(0)
+/* Enable forwarding to the Rx data path. */
+#define EC_TMI_TX_CFG_EN_FWD_TO_RX       BIT(1)
+/* Mask 2 for XOFF [7:0] Mask 2 for sampled Almost Full indicati */
+#define EC_EFC_EC_XOFF_MASK_2_SHIFT      8
+
+/* Mask 1 for generating XON pulse, masking XOFF [0] */
+#define EC_EFC_XON_MASK_1                BIT(0)
+/* Mask 2 for generating XON pulse, masking Almost Full indicati */
+#define EC_EFC_XON_MASK_2                BIT(1)
+
+/* Threshold high */
+#define EC_EFC_RX_FIFO_HYST_TH_HIGH_SHIFT 16
+
+#endif /* __AL_HW_EC_REG_H */
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h b/drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h
new file mode 100644
index 000000000000..b2b956b7e28f
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/al_hw_eth_mac_regs.h
@@ -0,0 +1,727 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_ETH_MAC_REGS_H__
+#define __AL_HW_ETH_MAC_REGS_H__
+
+/*
+* Unit Registers
+*/
+
+struct al_eth_mac_1g_stats {
+	u32 reserved1[2];
+	u32 aFramesTransmittedOK;
+	u32 aFramesReceivedOK;
+	u32 aFrameCheckSequenceErrors;
+	u32 aAlignmentErrors;
+	u32 aOctetsTransmittedOK;
+	u32 aOctetsReceivedOK;
+	u32 aPAUSEMACCtrlFramesTransmitted;
+	u32 aPAUSEMACCtrlFramesReceived;
+	u32 ifInErrors;
+	u32 ifOutErrors;
+	u32 ifInUcastPkts;
+	u32 ifInMulticastPkts;
+	u32 ifInBroadcastPkts;
+	u32 reserved2;
+	u32 ifOutUcastPkts;
+	u32 ifOutMulticastPkts;
+	u32 ifOutBroadcastPkts;
+	u32 etherStatsDropEvents;
+	u32 etherStatsOctets;
+	u32 etherStatsPkts;
+	u32 etherStatsUndersizePkts;
+	u32 etherStatsOversizePkts;
+	u32 etherStatsPkts64Octets;
+	u32 etherStatsPkts65to127Octets;
+	u32 etherStatsPkts128to255Octets;
+	u32 etherStatsPkts256to511Octets;
+	u32 etherStatsPkts512to1023Octets;
+	u32 etherStatsPkts1024to1518Octets;
+	u32 etherStatsPkts1519toX;
+	u32 etherStatsJabbers;
+	u32 etherStatsFragments;
+	u32 reserved3[71];
+};
+
+struct al_eth_mac_1g {
+	u32 rev;
+	u32 scratch;
+	u32 cmd_cfg;
+	u32 mac_0;
+
+	u32 mac_1;
+	u32 frm_len;
+	u32 pause_quant;
+	u32 rx_section_empty;
+
+	u32 rx_section_full;
+	u32 tx_section_empty;
+	u32 tx_section_full;
+	u32 rx_almost_empty;
+
+	u32 rx_almost_full;
+	u32 tx_almost_empty;
+	u32 tx_almost_full;
+	u32 mdio_addr0;
+
+	u32 mdio_addr1;
+	u32 Reserved[5];
+
+	u32 reg_stat;
+	u32 tx_ipg_len;
+
+	struct al_eth_mac_1g_stats stats;
+
+	u32 phy_regs_base;
+	u32 Reserved2[127];
+};
+
+struct al_eth_mac_10g_stats_v2 {
+	u32 aFramesTransmittedOK;
+	u32 reserved1;
+	u32 aFramesReceivedOK;
+	u32 reserved2;
+	u32 aFrameCheckSequenceErrors;
+	u32 reserved3;
+	u32 aAlignmentErrors;
+	u32 reserved4;
+	u32 aPAUSEMACCtrlFramesTransmitted;
+	u32 reserved5;
+	u32 aPAUSEMACCtrlFramesReceived;
+	u32 reserved6;
+	u32 aFrameTooLongErrors;
+	u32 reserved7;
+	u32 aInRangeLengthErrors;
+	u32 reserved8;
+	u32 VLANTransmittedOK;
+	u32 reserved9;
+	u32 VLANReceivedOK;
+	u32 reserved10;
+	u32 ifOutOctetsL;
+	u32 ifOutOctetsH;
+	u32 ifInOctetsL;
+	u32 ifInOctetsH;
+	u32 ifInUcastPkts;
+	u32 reserved11;
+	u32 ifInMulticastPkts;
+	u32 reserved12;
+	u32 ifInBroadcastPkts;
+	u32 reserved13;
+	u32 ifOutErrors;
+	u32 reserved14[3];
+	u32 ifOutUcastPkts;
+	u32 reserved15;
+	u32 ifOutMulticastPkts;
+	u32 reserved16;
+	u32 ifOutBroadcastPkts;
+	u32 reserved17;
+	u32 etherStatsDropEvents;
+	u32 reserved18;
+	u32 etherStatsOctets;
+	u32 reserved19;
+	u32 etherStatsPkts;
+	u32 reserved20;
+	u32 etherStatsUndersizePkts;
+	u32 reserved21;
+	u32 etherStatsPkts64Octets;
+	u32 reserved22;
+	u32 etherStatsPkts65to127Octets;
+	u32 reserved23;
+	u32 etherStatsPkts128to255Octets;
+	u32 reserved24;
+	u32 etherStatsPkts256to511Octets;
+	u32 reserved25;
+	u32 etherStatsPkts512to1023Octets;
+	u32 reserved26;
+	u32 etherStatsPkts1024to1518Octets;
+	u32 reserved27;
+	u32 etherStatsPkts1519toX;
+	u32 reserved28;
+	u32 etherStatsOversizePkts;
+	u32 reserved29;
+	u32 etherStatsJabbers;
+	u32 reserved30;
+	u32 etherStatsFragments;
+	u32 reserved31;
+	u32 ifInErrors;
+	u32 reserved32[91];
+};
+
+struct al_eth_mac_10g_stats_v3_rx {
+	u32 etherStatsOctets;
+	u32 reserved2;
+	u32 ifOctetsL;
+	u32 ifOctetsH;
+	u32 aAlignmentErrors;
+	u32 reserved4;
+	u32 aPAUSEMACCtrlFrames;
+	u32 reserved5;
+	u32 FramesOK;
+	u32 reserved6;
+	u32 CRCErrors;
+	u32 reserved7;
+	u32 VLANOK;
+	u32 reserved8;
+	u32 ifInErrors;
+	u32 reserved9;
+	u32 ifInUcastPkts;
+	u32 reserved10;
+	u32 ifInMulticastPkts;
+	u32 reserved11;
+	u32 ifInBroadcastPkts;
+	u32 reserved12;
+	u32 etherStatsDropEvents;
+	u32 reserved13;
+	u32 etherStatsPkts;
+	u32 reserved14;
+	u32 etherStatsUndersizePkts;
+	u32 reserved15;
+	u32 etherStatsPkts64Octets;
+	u32 reserved16;
+	u32 etherStatsPkts65to127Octets;
+	u32 reserved17;
+	u32 etherStatsPkts128to255Octets;
+	u32 reserved18;
+	u32 etherStatsPkts256to511Octets;
+	u32 reserved19;
+	u32 etherStatsPkts512to1023Octets;
+	u32 reserved20;
+	u32 etherStatsPkts1024to1518Octets;
+	u32 reserved21;
+	u32 etherStatsPkts1519toMax;
+	u32 reserved22;
+	u32 etherStatsOversizePkts;
+	u32 reserved23;
+	u32 etherStatsJabbers;
+	u32 reserved24;
+	u32 etherStatsFragments;
+	u32 reserved25;
+	u32 aMACControlFramesReceived;
+	u32 reserved26;
+	u32 aFrameTooLong;
+	u32 reserved27;
+	u32 aInRangeLengthErrors;
+	u32 reserved28;
+	u32 reserved29[10];
+};
+
+struct al_eth_mac_10g_stats_v3_tx {
+	u32 etherStatsOctets;
+	u32 reserved30;
+	u32 ifOctetsL;
+	u32 ifOctetsH;
+	u32 aAlignmentErrors;
+	u32 reserved32;
+	u32 aPAUSEMACCtrlFrames;
+	u32 reserved33;
+	u32 FramesOK;
+	u32 reserved34;
+	u32 CRCErrors;
+	u32 reserved35;
+	u32 VLANOK;
+	u32 reserved36;
+	u32 ifOutErrors;
+	u32 reserved37;
+	u32 ifUcastPkts;
+	u32 reserved38;
+	u32 ifMulticastPkts;
+	u32 reserved39;
+	u32 ifBroadcastPkts;
+	u32 reserved40;
+	u32 etherStatsDropEvents;
+	u32 reserved41;
+	u32 etherStatsPkts;
+	u32 reserved42;
+	u32 etherStatsUndersizePkts;
+	u32 reserved43;
+	u32 etherStatsPkts64Octets;
+	u32 reserved44;
+	u32 etherStatsPkts65to127Octets;
+	u32 reserved45;
+	u32 etherStatsPkts128to255Octets;
+	u32 reserved46;
+	u32 etherStatsPkts256to511Octets;
+	u32 reserved47;
+	u32 etherStatsPkts512to1023Octets;
+	u32 reserved48;
+	u32 etherStatsPkts1024to1518Octets;
+	u32 reserved49;
+	u32 etherStatsPkts1519toTX_MTU;
+	u32 reserved50;
+	u32 reserved51[4];
+	u32 aMACControlFrames;
+	u32 reserved52[15];
+};
+
+struct al_eth_mac_10g_stats_v3 {
+	u32 reserved1[32];
+
+	struct al_eth_mac_10g_stats_v3_rx rx;
+	struct al_eth_mac_10g_stats_v3_tx tx;
+};
+
+union al_eth_mac_10g_stats {
+	struct al_eth_mac_10g_stats_v2	v2;
+	struct al_eth_mac_10g_stats_v3	v3;
+};
+
+struct al_eth_mac_10g {
+	u32 rev;
+	u32 scratch;
+	u32 cmd_cfg;
+	u32 mac_0;
+
+	u32 mac_1;
+	u32 frm_len;
+	u32 Reserved;
+	u32 rx_fifo_sections;
+
+	u32 tx_fifo_sections;
+	u32 rx_fifo_almost_f_e;
+	u32 tx_fifo_almost_f_e;
+	u32 hashtable_load;
+
+	u32 mdio_cfg_status;
+	u16 mdio_cmd;
+	u16 reserved1;
+	u16 mdio_data;
+	u16 reserved2;
+	u16 mdio_regaddr;
+	u16 reserved3;
+
+	u32 status;
+	u32 tx_ipg_len;
+	u32 Reserved1[3];
+
+	u32 cl01_pause_quanta;
+	u32 cl23_pause_quanta;
+	u32 cl45_pause_quanta;
+
+	u32 cl67_pause_quanta;
+	u32 cl01_quanta_thresh;
+	u32 cl23_quanta_thresh;
+	u32 cl45_quanta_thresh;
+
+	u32 cl67_quanta_thresh;
+	u32 rx_pause_status;
+	u32 Reserved2;
+	u32 ts_timestamp;
+
+	union al_eth_mac_10g_stats stats;
+
+	u32 control;
+	u32 status_reg;
+	u32 phy_id[2];
+
+	u32 dev_ability;
+	u32 partner_ability;
+	u32 an_expansion;
+	u32 device_np;
+
+	u32 partner_np;
+	u32 Reserved4[9];
+
+	u32 link_timer_lo;
+	u32 link_timer_hi;
+
+	u32 if_mode;
+
+	u32 Reserved5[43];
+};
+
+struct al_eth_mac_gen {
+	/*  Ethernet Controller Version */
+	u32 version;
+	u32 rsrvd_0[2];
+	/* MAC selection configuration */
+	u32 cfg;
+	/* 10/100/1000 MAC external configuration */
+	u32 mac_1g_cfg;
+	/* 10/100/1000 MAC status */
+	u32 mac_1g_stat;
+	/* RGMII external configuration */
+	u32 rgmii_cfg;
+	/* RGMII status */
+	u32 rgmii_stat;
+	/* 1/2.5/10G MAC external configuration */
+	u32 mac_10g_cfg;
+	/* 1/2.5/10G MAC status */
+	u32 mac_10g_stat;
+	/* XAUI PCS configuration */
+	u32 xaui_cfg;
+	/* XAUI PCS status */
+	u32 xaui_stat;
+	/* RXAUI PCS configuration */
+	u32 rxaui_cfg;
+	/* RXAUI PCS status */
+	u32 rxaui_stat;
+	/* Signal detect configuration */
+	u32 sd_cfg;
+	/* MDIO control register for MDIO interface 1 */
+	u32 mdio_ctrl_1;
+	/* MDIO information register for MDIO interface 1 */
+	u32 mdio_1;
+	/* MDIO control register for MDIO interface 2 */
+	u32 mdio_ctrl_2;
+	/* MDIO information register for MDIO interface 2 */
+	u32 mdio_2;
+	/* XGMII 32 to 64 data FIFO control */
+	u32 xgmii_dfifo_32_64;
+	/* Reserved 1 out */
+	u32 mac_res_1_out;
+	/* XGMII 64 to 32 data FIFO control */
+	u32 xgmii_dfifo_64_32;
+	/* Reserved 1 in */
+	u32 mac_res_1_in;
+	/* SerDes TX FIFO control */
+	u32 sd_fifo_ctrl;
+	/* SerDes TX FIFO status */
+	u32 sd_fifo_stat;
+	/* SerDes in/out selection */
+	u32 mux_sel;
+	/* Clock configuration */
+	u32 clk_cfg;
+	u32 rsrvd_1;
+	/* LOS and SD selection */
+	u32 los_sel;
+	/* RGMII selection configuration */
+	u32 rgmii_sel;
+	/* Ethernet LED configuration */
+	u32 led_cfg;
+	u32 rsrvd[33];
+};
+
+struct al_eth_mac_kr {
+	/* PCS register file address */
+	u32 pcs_addr;
+	/* PCS register file data */
+	u32 pcs_data;
+	/* AN register file address */
+	u32 an_addr;
+	/* AN register file data */
+	u32 an_data;
+	/* PMA register file address */
+	u32 pma_addr;
+	/* PMA register file data */
+	u32 pma_data;
+	/* MTIP register file address */
+	u32 mtip_addr;
+	/* MTIP register file data */
+	u32 mtip_data;
+	/* KR PCS config  */
+	u32 pcs_cfg;
+	/* KR PCS status  */
+	u32 pcs_stat;
+	u32 rsrvd[54];
+};
+
+struct al_eth_mac_sgmii {
+	/* PCS register file address */
+	u32 reg_addr;
+	/* PCS register file data */
+	u32 reg_data;
+	/* PCS clock divider configuration */
+	u32 clk_div;
+	/* PCS Status */
+	u32 link_stat;
+	u32 rsrvd[60];
+};
+
+struct al_eth_mac_stat {
+	/* Receive rate matching error */
+	u32 match_fault;
+	/* EEE, number of times the MAC went into low power mode */
+	u32 eee_in;
+	/* EEE, number of times the MAC went out of low power mode */
+	u32 eee_out;
+	/*
+	 * 40G PCS,
+	 * FEC corrected error indication
+	 */
+	u32 v3_pcs_40g_ll_cerr_0;
+	/*
+	 * 40G PCS,
+	 * FEC corrected error indication
+	 */
+	u32 v3_pcs_40g_ll_cerr_1;
+	/*
+	 * 40G PCS,
+	 * FEC corrected error indication
+	 */
+	u32 v3_pcs_40g_ll_cerr_2;
+	/*
+	 * 40G PCS,
+	 * FEC corrected error indication
+	 */
+	u32 v3_pcs_40g_ll_cerr_3;
+	/*
+	 * 40G PCS,
+	 * FEC uncorrectable error indication
+	 */
+	u32 v3_pcs_40g_ll_ncerr_0;
+	/*
+	 * 40G PCS,
+	 * FEC uncorrectable error indication
+	 */
+	u32 v3_pcs_40g_ll_ncerr_1;
+	/*
+	 * 40G PCS,
+	 * FEC uncorrectable error indication
+	 */
+	u32 v3_pcs_40g_ll_ncerr_2;
+	/*
+	 * 40G PCS,
+	 * FEC uncorrectable error indication
+	 */
+	u32 v3_pcs_40g_ll_ncerr_3;
+	/*
+	 * 10G_LL PCS,
+	 * FEC corrected error indication
+	 */
+	u32 v3_pcs_10g_ll_cerr;
+	/*
+	 * 10G_LL PCS,
+	 * FEC uncorrectable error indication
+	 */
+	u32 v3_pcs_10g_ll_ncerr;
+	u32 rsrvd[51];
+};
+
+struct al_eth_mac_stat_lane {
+	/* Character error */
+	u32 char_err;
+	/* Disparity error */
+	u32 disp_err;
+	/* Comma detection */
+	u32 pat;
+	u32 rsrvd[13];
+};
+
+struct al_eth_mac_gen_v3 {
+	/* ASYNC FIFOs control */
+	u32 afifo_ctrl;
+	/* TX ASYNC FIFO configuration */
+	u32 tx_afifo_cfg_1;
+	/* TX ASYNC FIFO configuration */
+	u32 tx_afifo_cfg_2;
+	/* TX ASYNC FIFO configuration */
+	u32 tx_afifo_cfg_3;
+	/* TX ASYNC FIFO configuration */
+	u32 tx_afifo_cfg_4;
+	/* TX ASYNC FIFO configuration */
+	u32 tx_afifo_cfg_5;
+	/* RX ASYNC FIFO configuration */
+	u32 rx_afifo_cfg_1;
+	/* RX ASYNC FIFO configuration */
+	u32 rx_afifo_cfg_2;
+	/* RX ASYNC FIFO configuration */
+	u32 rx_afifo_cfg_3;
+	/* RX ASYNC FIFO configuration */
+	u32 rx_afifo_cfg_4;
+	/* RX ASYNC FIFO configuration */
+	u32 rx_afifo_cfg_5;
+	/* MAC selection configuration */
+	u32 mac_sel;
+	/* 10G LL MAC configuration */
+	u32 mac_10g_ll_cfg;
+	/* 10G LL MAC control */
+	u32 mac_10g_ll_ctrl;
+	/* 10G LL PCS configuration */
+	u32 pcs_10g_ll_cfg;
+	/* 10G LL PCS status */
+	u32 pcs_10g_ll_status;
+	/* 40G LL PCS configuration */
+	u32 pcs_40g_ll_cfg;
+	/* 40G LL PCS status */
+	u32 pcs_40g_ll_status;
+	/* PCS 40G  register file address */
+	u32 pcs_40g_ll_addr;
+	/* PCS 40G register file data */
+	u32 pcs_40g_ll_data;
+	/* 40G LL MAC configuration */
+	u32 mac_40g_ll_cfg;
+	/* 40G LL MAC status */
+	u32 mac_40g_ll_status;
+	/* Preamble configuration (high [55:32]) */
+	u32 preamble_cfg_high;
+	/* Preamble configuration (low [31:0]) */
+	u32 preamble_cfg_low;
+	/* MAC 40G register file address */
+	u32 mac_40g_ll_addr;
+	/* MAC 40G register file data */
+	u32 mac_40g_ll_data;
+	/* 40G LL MAC control */
+	u32 mac_40g_ll_ctrl;
+	/* PCS 40G  register file address */
+	u32 pcs_40g_fec_91_ll_addr;
+	/* PCS 40G register file data */
+	u32 pcs_40g_fec_91_ll_data;
+	/* 40G LL PCS EEE configuration */
+	u32 pcs_40g_ll_eee_cfg;
+	/* 40G LL PCS EEE status */
+	u32 pcs_40g_ll_eee_status;
+	/*
+	 * SERDES 32-bit interface shift configuration (when swap is
+	 * enabled)
+	 */
+	u32 serdes_32_tx_shift;
+	/*
+	 * SERDES 32-bit interface shift configuration (when swap is
+	 * enabled)
+	 */
+	u32 serdes_32_rx_shift;
+	/*
+	 * SERDES 32-bit interface bit selection
+	 */
+	u32 serdes_32_tx_sel;
+	/*
+	 * SERDES 32-bit interface bit selection
+	 */
+	u32 serdes_32_rx_sel;
+	/* AN/LT wrapper  control */
+	u32 an_lt_ctrl;
+	/* AN/LT wrapper  register file address */
+	u32 an_lt_0_addr;
+	/* AN/LT wrapper register file data */
+	u32 an_lt_0_data;
+	/* AN/LT wrapper  register file address */
+	u32 an_lt_1_addr;
+	/* AN/LT wrapper register file data */
+	u32 an_lt_1_data;
+	/* AN/LT wrapper  register file address */
+	u32 an_lt_2_addr;
+	/* AN/LT wrapper register file data */
+	u32 an_lt_2_data;
+	/* AN/LT wrapper  register file address */
+	u32 an_lt_3_addr;
+	/* AN/LT wrapper register file data */
+	u32 an_lt_3_data;
+	/* External SERDES control */
+	u32 ext_serdes_ctrl;
+	/* spare bits */
+	u32 spare;
+	u32 rsrvd[18];
+};
+
+struct al_eth_mac_regs {
+	struct al_eth_mac_1g mac_1g;
+	struct al_eth_mac_10g mac_10g;
+	u32 rsrvd_0[64];
+	struct al_eth_mac_gen gen;
+	struct al_eth_mac_kr kr;
+	struct al_eth_mac_sgmii sgmii;
+	struct al_eth_mac_stat stat;
+	struct al_eth_mac_stat_lane stat_lane[4];
+	struct al_eth_mac_gen_v3 gen_v3;
+};
+
+/* cmd_cfg */
+#define ETH_1G_MAC_CMD_CFG_TX_ENA	BIT(0)
+#define ETH_1G_MAC_CMD_CFG_RX_ENA	BIT(1)
+/* enable Half Duplex */
+#define ETH_1G_MAC_CMD_CFG_HD_EN	BIT(10)
+/* enable 1G speed */
+#define ETH_1G_MAC_CMD_CFG_1G_SPD	BIT(3)
+/* enable 10M speed */
+#define ETH_1G_MAC_CMD_CFG_10M_SPD	BIT(25)
+
+/* cmd_cfg */
+#define ETH_10G_MAC_CMD_CFG_TX_ENA				BIT(0)
+#define ETH_10G_MAC_CMD_CFG_RX_ENA				BIT(1)
+
+/* mdio_cfg_status */
+#define ETH_10G_MAC_MDIO_CFG_HOLD_TIME_MASK	0x0000001c
+#define ETH_10G_MAC_MDIO_CFG_HOLD_TIME_SHIFT	2
+
+#define ETH_10G_MAC_MDIO_CFG_HOLD_TIME_7_CLK	3
+
+/* control */
+#define ETH_10G_MAC_CONTROL_AN_EN_MASK	0x00001000
+
+/* if_mode */
+#define ETH_10G_MAC_IF_MODE_SGMII_EN_MASK	0x00000001
+#define ETH_10G_MAC_IF_MODE_SGMII_AN_MASK	0x00000002
+#define ETH_10G_MAC_IF_MODE_SGMII_SPEED_MASK	0x0000000c
+#define ETH_10G_MAC_IF_MODE_SGMII_SPEED_SHIFT	2
+#define ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_MASK	0x00000010
+#define ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_SHIFT	4
+
+#define ETH_10G_MAC_IF_MODE_SGMII_SPEED_10M	0
+#define ETH_10G_MAC_IF_MODE_SGMII_SPEED_100M	1
+#define ETH_10G_MAC_IF_MODE_SGMII_SPEED_1G	2
+
+#define ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_FULL	0
+#define ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_HALF	1
+
+/*
+ * Selection of the input for the "set_1000" input of the RGMII converter
+ * 0 - From MAC
+ * 1 - From register set_1000_def (automatic speed selection)
+ */
+#define ETH_MAC_GEN_RGMII_CFG_SET_1000_SEL BIT(0)
+/*
+ * Selection of the input for the "set_10" input of the RGMII converter:
+ * 0 - From MAC
+ * 1 - From register set_10_def (automatic speed selection)
+ */
+#define ETH_MAC_GEN_RGMII_CFG_SET_10_SEL BIT(4)
+/* Enable automatic speed selection (based on PHY in-band status information) */
+#define ETH_MAC_GEN_RGMII_CFG_ENA_AUTO   BIT(8)
+
+#define ETH_MAC_GEN_MUX_SEL_KR_IN_MASK   0x0000C000
+
+/*
+ * LED source selection:
+ * 0 – Default reg
+ * 1 – Rx activity
+ * 2 – Tx activity
+ * 3 – Rx | Tx activity
+ * 4-9 – SGMII LEDs
+ */
+#define ETH_MAC_GEN_LED_CFG_SEL_MASK     0x0000000F
+
+/* turn the led on/off based on default value field (ETH_MAC_GEN_LED_CFG_DEF) */
+#define ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG	0
+
+/* LED default value */
+#define ETH_MAC_GEN_LED_CFG_DEF          BIT(4)
+
+#define ETH_MAC_SGMII_REG_ADDR_CTRL_REG	0x0
+#define ETH_MAC_SGMII_REG_ADDR_IF_MODE_REG 0x14
+
+#define ETH_MAC_SGMII_REG_DATA_CTRL_AN_ENABLE			BIT(12)
+#define ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_EN			BIT(0)
+#define ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_AN			BIT(1)
+#define ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_SPEED_10		0x0
+#define ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_SPEED_100		0x1
+#define ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_SPEED_1000		0x2
+#define ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_DUPLEX		BIT(4)
+
+/* command config */
+#define ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_ADDR	0x00000008
+#define ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_TX_ENA	BIT(0)
+#define ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_RX_ENA	BIT(1)
+#define ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_PFC_MODE	BIT(19)
+
+/* frame length */
+#define ETH_MAC_GEN_V3_MAC_40G_FRM_LENGTH_ADDR		0x00000014
+
+#define ETH_MAC_GEN_V3_MAC_40G_CL01_PAUSE_QUANTA_ADDR	0x00000054
+#define ETH_MAC_GEN_V3_MAC_40G_CL23_PAUSE_QUANTA_ADDR	0x00000058
+#define ETH_MAC_GEN_V3_MAC_40G_CL45_PAUSE_QUANTA_ADDR	0x0000005C
+#define ETH_MAC_GEN_V3_MAC_40G_CL67_PAUSE_QUANTA_ADDR	0x00000060
+#define ETH_MAC_GEN_V3_MAC_40G_CL01_QUANTA_THRESH_ADDR	0x00000064
+#define ETH_MAC_GEN_V3_MAC_40G_CL23_QUANTA_THRESH_ADDR	0x00000068
+#define ETH_MAC_GEN_V3_MAC_40G_CL45_QUANTA_THRESH_ADDR	0x0000006C
+#define ETH_MAC_GEN_V3_MAC_40G_CL67_QUANTA_THRESH_ADDR	0x00000070
+
+/* spare */
+#define ETH_MAC_GEN_V3_SPARE_CHICKEN_DISABLE_TIMESTAMP_STRETCH BIT(0)
+
+#endif /* __AL_HW_ETH_MAC_REGS_H__ */
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth_main.c b/drivers/net/ethernet/annapurna/al_hw_eth_main.c
new file mode 100644
index 000000000000..abb9ffd09fbf
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/al_hw_eth_main.c
@@ -0,0 +1,3050 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/soc/alpine/iofic.h>
+#include <linux/soc/alpine/al_hw_udma_iofic.h>
+#include <linux/soc/alpine/al_hw_udma_config.h>
+
+#include "al_hw_eth.h"
+#include "al_hw_eth_ec_regs.h"
+#include "al_hw_eth_mac_regs.h"
+#include "al_hw_unit_adapter_regs.h"
+
+#define AL_ADDR_LOW(x)	((u32)((dma_addr_t)(x)))
+#define AL_ADDR_HIGH(x)	((u32)((((dma_addr_t)(x)) >> 16) >> 16))
+
+#define AL_ETH_TX_PKT_UDMA_FLAGS	(AL_ETH_TX_FLAGS_NO_SNOOP | \
+					 AL_ETH_TX_FLAGS_INT)
+
+#define AL_ETH_TX_PKT_META_FLAGS	(AL_ETH_TX_FLAGS_IPV4_L3_CSUM | \
+					 AL_ETH_TX_FLAGS_L4_CSUM |	\
+					 AL_ETH_TX_FLAGS_L4_PARTIAL_CSUM |	\
+					 AL_ETH_TX_FLAGS_L2_MACSEC_PKT | \
+					 AL_ETH_TX_FLAGS_L2_DIS_FCS |\
+					 AL_ETH_TX_FLAGS_TSO |\
+					 AL_ETH_TX_FLAGS_TS)
+
+#define AL_ETH_TX_SRC_VLAN_CNT_SHIFT		5
+#define AL_ETH_TX_L4_PROTO_IDX_SHIFT		8
+#define AL_ETH_TX_TUNNEL_MODE_SHIFT		18
+#define AL_ETH_TX_OUTER_L3_PROTO_SHIFT		20
+#define AL_ETH_TX_VLAN_MOD_ADD_SHIFT		22
+#define AL_ETH_TX_VLAN_MOD_DEL_SHIFT		24
+#define AL_ETH_TX_VLAN_MOD_E_SEL_SHIFT		26
+#define AL_ETH_TX_VLAN_MOD_VID_SEL_SHIFT	28
+#define AL_ETH_TX_VLAN_MOD_PBIT_SEL_SHIFT	30
+
+/* tx Meta Descriptor defines */
+#define AL_ETH_TX_META_STORE			BIT(21)
+#define AL_ETH_TX_META_L3_LEN_MASK		0xff
+#define AL_ETH_TX_META_L3_OFF_MASK		0xff
+#define AL_ETH_TX_META_L3_OFF_SHIFT		8
+#define AL_ETH_TX_META_MSS_LSB_VAL_SHIFT	22
+#define AL_ETH_TX_META_MSS_MSB_TS_VAL_SHIFT	16
+#define AL_ETH_TX_META_OUTER_L3_LEN_MASK	0x1f
+#define AL_ETH_TX_META_OUTER_L3_LEN_SHIFT	24
+#define AL_ETH_TX_META_OUTER_L3_OFF_HIGH_MASK	0x18
+#define AL_ETH_TX_META_OUTER_L3_OFF_HIGH_SHIFT	10
+#define AL_ETH_TX_META_OUTER_L3_OFF_LOW_MASK	0x07
+#define AL_ETH_TX_META_OUTER_L3_OFF_LOW_SHIFT	29
+
+/* Rx Descriptor defines */
+#define AL_ETH_RX_L3_PROTO_IDX_MASK	0x1F
+#define AL_ETH_RX_L4_PROTO_IDX_MASK	0x1F
+#define AL_ETH_RX_L4_PROTO_IDX_SHIFT	8
+
+#define AL_ETH_RX_L3_OFFSET_SHIFT	9
+#define AL_ETH_RX_L3_OFFSET_MASK	(0x7f << AL_ETH_RX_L3_OFFSET_SHIFT)
+#define AL_ETH_RX_HASH_SHIFT		16
+#define AL_ETH_RX_HASH_MASK		(0xffff		<< AL_ETH_RX_HASH_SHIFT)
+
+#define AL_ETH_MDIO_DELAY_PERIOD	1 /* micro seconds to wait when polling mdio status */
+#define AL_ETH_MDIO_DELAY_COUNT		150 /* number of times to poll */
+#define AL_ETH_S2M_UDMA_COMP_COAL_TIMEOUT	200 /* Rx descriptors coalescing timeout in SB clocks */
+
+#define AL_ETH_EPE_ENTRIES_NUM 26
+static struct al_eth_epe_p_reg_entry al_eth_epe_p_regs[AL_ETH_EPE_ENTRIES_NUM] = {
+	{ 0x0, 0x0, 0x0 },
+	{ 0x0, 0x0, 0x1 },
+	{ 0x0, 0x0, 0x2 },
+	{ 0x0, 0x0, 0x3 },
+	{ 0x18100, 0xFFFFF, 0x80000004 },
+	{ 0x188A8, 0xFFFFF, 0x80000005 },
+	{ 0x99100, 0xFFFFF, 0x80000006 },
+	{ 0x98100, 0xFFFFF, 0x80000007 },
+	{ 0x10800, 0x7FFFF, 0x80000008 },
+	{ 0x20000, 0x73FFF, 0x80000009 },
+	{ 0x20000, 0x70000, 0x8000000A },
+	{ 0x186DD, 0x7FFFF, 0x8000000B },
+	{ 0x30600, 0x7FF00, 0x8000000C },
+	{ 0x31100, 0x7FF00, 0x8000000D },
+	{ 0x32F00, 0x7FF00, 0x8000000E },
+	{ 0x32900, 0x7FF00, 0x8000000F },
+	{ 0x105DC, 0x7FFFF, 0x80010010 },
+	{ 0x188E5, 0x7FFFF, 0x80000011 },
+	{ 0x72000, 0x72000, 0x80000012 },
+	{ 0x70000, 0x72000, 0x80000013 },
+	{ 0x46558, 0x7FFFF, 0x80000001 },
+	{ 0x18906, 0x7FFFF, 0x80000015 },
+	{ 0x18915, 0x7FFFF, 0x80000016 },
+	{ 0x31B00, 0x7FF00, 0x80000017 },
+	{ 0x30400, 0x7FF00, 0x80000018 },
+	{ 0x0, 0x0, 0x8000001F }
+};
+
+static struct al_eth_epe_control_entry al_eth_epe_control_table[AL_ETH_EPE_ENTRIES_NUM] = {
+	{ { 0x2800000, 0x0, 0x0, 0x0, 0x1, 0x400000 } },
+	{ { 0x280004C, 0x746000, 0xA46030, 0xE00000, 0x2, 0x400000 } },
+	{ { 0x2800054, 0x746000, 0xA46030, 0x1600000, 0x2, 0x400000 } },
+	{ { 0x280005C, 0x746000, 0xA46030, 0x1E00000, 0x2, 0x400000 } },
+	{ { 0x2800042, 0xD42000, 0x0, 0x400000, 0x1010412, 0x400000 } },
+	{ { 0x2800042, 0xD42000, 0x0, 0x400000, 0x1010412, 0x400000 } },
+	{ { 0x2800042, 0xE42000, 0x0, 0x400000, 0x2020002, 0x400000 } },
+	{ { 0x2800042, 0xE42000, 0x0, 0x400000, 0x2020002, 0x400000 } },
+	{ { 0x280B046, 0x0, 0x6C1008, 0x0, 0x4, 0x406800 } },
+	{ { 0x2800049, 0xF44060, 0x1744080, 0x14404, 0x6, 0x400011 } },
+	{ { 0x2015049, 0xF44060, 0x1744080, 0x14404, 0x8080007, 0x400011 } },
+	{ { 0x280B046, 0xF60040, 0x6C1004, 0x2800000, 0x6, 0x406811 } },
+	{ { 0x2815042, 0x1F42000, 0x2042010, 0x1414460, 0x10100009, 0x40B800 } },
+	{ { 0x2815042, 0x1F42000, 0x2042010, 0x800000, 0x10100009, 0x40B800 } },
+	{ { 0x280B042, 0x0, 0x0, 0x430400, 0x4040009, 0x0 } },
+	{ { 0x2815580, 0x0, 0x0, 0x0, 0x4040005, 0x0 } },
+	{ { 0x280B000, 0x0, 0x0, 0x0, 0x1, 0x400000 } },
+	{ { 0x2800040, 0x174E000, 0x0, 0x0, 0xE, 0x406800 } },
+	{ { 0x280B000, 0x0, 0x0, 0x600000, 0x1, 0x406800 } },
+	{ { 0x280B000, 0x0, 0x0, 0xE00000, 0x1, 0x406800 } },
+	{ { 0x2800000, 0x0, 0x0, 0x0, 0x1, 0x400000 } },
+	{ { 0x280B046, 0x0, 0x0, 0x2800000, 0x7, 0x400000 } },
+	{ { 0x280B046, 0xF60040, 0x6C1004, 0x2800000, 0x6, 0x406811 } },
+	{ { 0x2815042, 0x1F43028, 0x2000000, 0xC00000, 0x10100009, 0x40B800 } },
+	{ { 0x2815400, 0x0, 0x0, 0x0, 0x4040005, 0x0 } },
+	{ { 0x2800000, 0x0, 0x0, 0x0, 0x1, 0x400000 } }
+};
+
+#define AL_ETH_IS_1G_MAC(mac_mode) (((mac_mode) == AL_ETH_MAC_MODE_RGMII) || ((mac_mode) == AL_ETH_MAC_MODE_SGMII))
+#define AL_ETH_IS_10G_MAC(mac_mode)	(((mac_mode) == AL_ETH_MAC_MODE_10GbE_Serial) ||	\
+					((mac_mode) == AL_ETH_MAC_MODE_10G_SGMII) ||		\
+					((mac_mode) == AL_ETH_MAC_MODE_SGMII_2_5G))
+#define AL_ETH_IS_25G_MAC(mac_mode) ((mac_mode) == AL_ETH_MAC_MODE_KR_LL_25G)
+
+static const char *al_eth_mac_mode_str(enum al_eth_mac_mode mode)
+{
+	switch (mode) {
+	case AL_ETH_MAC_MODE_RGMII:
+		return "RGMII";
+	case AL_ETH_MAC_MODE_SGMII:
+		return "SGMII";
+	case AL_ETH_MAC_MODE_SGMII_2_5G:
+		return "SGMII_2_5G";
+	case AL_ETH_MAC_MODE_10GbE_Serial:
+		return "KR";
+	case AL_ETH_MAC_MODE_KR_LL_25G:
+		return "KR_LL_25G";
+	case AL_ETH_MAC_MODE_10G_SGMII:
+		return "10G_SGMII";
+	case AL_ETH_MAC_MODE_XLG_LL_40G:
+		return "40G_LL";
+	case AL_ETH_MAC_MODE_XLG_LL_50G:
+		return "50G_LL";
+	case AL_ETH_MAC_MODE_XLG_LL_25G:
+		return "25G_LL";
+	default:
+		return "N/A";
+	}
+}
+
+/*
+ * change and wait udma state
+ *
+ * @param dma the udma to change its state
+ * @param new_state
+ *
+ * @return 0 on success. otherwise on failure.
+ */
+static int al_udma_state_set_wait(struct al_hw_eth_adapter *adapter,
+				  struct al_udma *dma,
+				  enum al_udma_state new_state)
+{
+	enum al_udma_state state;
+	enum al_udma_state expected_state = new_state;
+	int count = 1000;
+
+	al_udma_state_set(dma, new_state);
+
+	if ((new_state == UDMA_NORMAL) || (new_state == UDMA_DISABLE))
+		expected_state = UDMA_IDLE;
+
+	do {
+		state = al_udma_state_get(dma);
+		if (state == expected_state)
+			break;
+		udelay(1);
+		if (count-- == 0) {
+			netdev_warn(adapter->netdev,
+				    "[%s] warn: dma state didn't change to %s\n",
+				    dma->name, al_udma_states_name[new_state]);
+			return -ETIMEDOUT;
+		}
+	} while (1);
+	return 0;
+}
+
+static void al_eth_epe_entry_set(struct al_hw_eth_adapter *adapter, u32 idx,
+				 struct al_eth_epe_p_reg_entry *reg_entry,
+				 struct al_eth_epe_control_entry *control_entry)
+{
+	writel(reg_entry->data, &adapter->ec_regs_base->epe_p[idx].comp_data);
+	writel(reg_entry->mask, &adapter->ec_regs_base->epe_p[idx].comp_mask);
+	writel(reg_entry->ctrl, &adapter->ec_regs_base->epe_p[idx].comp_ctrl);
+
+	writel(reg_entry->data,
+	       &adapter->ec_regs_base->msp_c[idx].p_comp_data);
+	writel(reg_entry->mask,
+	       &adapter->ec_regs_base->msp_c[idx].p_comp_mask);
+	writel(reg_entry->ctrl,
+	       &adapter->ec_regs_base->msp_c[idx].p_comp_ctrl);
+
+	/*control table  0*/
+	writel(idx, &adapter->ec_regs_base->epe[0].act_table_addr);
+	writel(control_entry->data[5],
+	       &adapter->ec_regs_base->epe[0].act_table_data_6);
+	writel(control_entry->data[1],
+	       &adapter->ec_regs_base->epe[0].act_table_data_2);
+	writel(control_entry->data[2],
+	       &adapter->ec_regs_base->epe[0].act_table_data_3);
+	writel(control_entry->data[3],
+	       &adapter->ec_regs_base->epe[0].act_table_data_4);
+	writel(control_entry->data[4],
+	       &adapter->ec_regs_base->epe[0].act_table_data_5);
+	writel(control_entry->data[0],
+	       &adapter->ec_regs_base->epe[0].act_table_data_1);
+
+	/*control table 1*/
+	writel(idx, &adapter->ec_regs_base->epe[1].act_table_addr);
+	writel(control_entry->data[5],
+	       &adapter->ec_regs_base->epe[1].act_table_data_6);
+	writel(control_entry->data[1],
+	       &adapter->ec_regs_base->epe[1].act_table_data_2);
+	writel(control_entry->data[2],
+	       &adapter->ec_regs_base->epe[1].act_table_data_3);
+	writel(control_entry->data[3],
+	       &adapter->ec_regs_base->epe[1].act_table_data_4);
+	writel(control_entry->data[4],
+	       &adapter->ec_regs_base->epe[1].act_table_data_5);
+	writel(control_entry->data[0],
+	       &adapter->ec_regs_base->epe[1].act_table_data_1);
+}
+
+static void al_eth_epe_init(struct al_hw_eth_adapter *adapter)
+{
+	int idx;
+
+	if (adapter->enable_rx_parser == 0) {
+		netdev_dbg(adapter->netdev, "eth [%s]: disable rx parser\n",
+			   adapter->name);
+
+		writel(0x08000000, &adapter->ec_regs_base->epe[0].res_def);
+		writel(0x7, &adapter->ec_regs_base->epe[0].res_in);
+
+		writel(0x08000000, &adapter->ec_regs_base->epe[1].res_def);
+		writel(0x7, &adapter->ec_regs_base->epe[1].res_in);
+
+		return;
+	}
+
+	for (idx = 0; idx < AL_ETH_EPE_ENTRIES_NUM; idx++)
+		al_eth_epe_entry_set(adapter, idx, &al_eth_epe_p_regs[idx],
+				     &al_eth_epe_control_table[idx]);
+
+	writel(0x08000080, &adapter->ec_regs_base->epe[0].res_def);
+	writel(0x7, &adapter->ec_regs_base->epe[0].res_in);
+
+	writel(0x08000080, &adapter->ec_regs_base->epe[1].res_def);
+	writel(0, &adapter->ec_regs_base->epe[1].res_in);
+
+	/*
+	 * header length as function of 4 bits value, for GRE, when C bit
+	 * is set, the header len should be increase by 4
+	 */
+	writel((4 << 16) | 4, &adapter->ec_regs_base->epe_h[8].hdr_len);
+
+	/*
+	 * select the outer information when writing the rx descriptor
+	 * (l3 protocol index etc)
+	 */
+	writel(EC_RFW_META_L3_LEN_CALC, &adapter->ec_regs_base->rfw.meta);
+
+	writel(EC_RFW_CHECKSUM_HDR_SEL, &adapter->ec_regs_base->rfw.checksum);
+}
+
+/*
+ * read 40G MAC registers (indirect access)
+ *
+ * @param adapter pointer to the private structure
+ * @param reg_addr address in the an registers
+ *
+ * @return the register value
+ */
+static u32 al_eth_40g_mac_reg_read(struct al_hw_eth_adapter *adapter,
+				   u32 reg_addr)
+{
+	u32 val;
+
+	/* indirect access */
+	writel(reg_addr, &adapter->mac_regs_base->gen_v3.mac_40g_ll_addr);
+	val = readl(&adapter->mac_regs_base->gen_v3.mac_40g_ll_data);
+
+	return val;
+}
+
+/*
+ * write 40G MAC registers (indirect access)
+ *
+ * @param adapter pointer to the private structure
+ * @param reg_addr address in the an registers
+ * @param reg_data value to write to the register
+ *
+ */
+static void al_eth_40g_mac_reg_write(struct al_hw_eth_adapter *adapter,
+				     u32 reg_addr, u32 reg_data)
+{
+	/* indirect access */
+	writel(reg_addr, &adapter->mac_regs_base->gen_v3.mac_40g_ll_addr);
+	writel(reg_data, &adapter->mac_regs_base->gen_v3.mac_40g_ll_data);
+}
+
+/*
+ * write 40G PCS registers (indirect access)
+ *
+ * @param adapter pointer to the private structure
+ * @param reg_addr address in the an registers
+ * @param reg_data value to write to the register
+ *
+ */
+static void al_eth_40g_pcs_reg_write(struct al_hw_eth_adapter *adapter,
+				     u32 reg_addr, u32 reg_data)
+{
+	/* indirect access */
+	writel(reg_addr, &adapter->mac_regs_base->gen_v3.pcs_40g_ll_addr);
+	writel(reg_data, &adapter->mac_regs_base->gen_v3.pcs_40g_ll_data);
+}
+
+/*
+ * initialize the ethernet adapter's DMA
+ */
+int al_eth_adapter_init(struct al_hw_eth_adapter *adapter,
+			struct al_eth_adapter_params *params)
+{
+	struct al_udma_params udma_params;
+	struct al_udma_m2s_pkt_len_conf conf;
+	int i;
+	u32 reg;
+	int rc;
+
+	netdev_dbg(adapter->netdev,
+		   "eth [%s]: initialize controller's UDMA. id = %d\n",
+		   params->name, params->udma_id);
+	netdev_dbg(adapter->netdev, "eth [%s]: enable_rx_parser: %x\n",
+		   params->name, params->enable_rx_parser);
+
+	adapter->name = params->name;
+	adapter->rev_id = params->rev_id;
+	adapter->netdev = params->netdev;
+	adapter->udma_id = params->udma_id;
+	adapter->udma_regs_base = params->udma_regs_base;
+	adapter->ec_regs_base =
+		(struct al_ec_regs __iomem *)params->ec_regs_base;
+	adapter->mac_regs_base =
+		(struct al_eth_mac_regs __iomem *)params->mac_regs_base;
+	adapter->unit_regs = (struct unit_regs __iomem *)params->udma_regs_base;
+	adapter->enable_rx_parser = params->enable_rx_parser;
+	adapter->ec_ints_base = (u8 __iomem *)adapter->ec_regs_base + 0x1c00;
+	adapter->mac_ints_base = (struct interrupt_controller_ctrl __iomem *)
+				 ((u8 __iomem *)adapter->mac_regs_base + 0x800);
+
+	/* initialize Tx udma */
+	udma_params.dev = adapter->netdev->dev.parent;
+	udma_params.udma_regs_base = adapter->unit_regs;
+	udma_params.type = UDMA_TX;
+	udma_params.cdesc_size = AL_ETH_UDMA_TX_CDESC_SZ;
+	udma_params.num_of_queues = AL_ETH_UDMA_TX_QUEUES;
+	udma_params.name = "eth tx";
+	rc = al_udma_init(&adapter->tx_udma, &udma_params);
+
+	if (rc != 0) {
+		netdev_err(adapter->netdev,
+			   "failed to initialize %s, error %d\n",
+			   udma_params.name, rc);
+		return rc;
+	}
+	rc = al_udma_state_set_wait(adapter, &adapter->tx_udma, UDMA_NORMAL);
+	if (rc != 0) {
+		netdev_err(adapter->netdev,
+			   "[%s]: failed to change state, error %d\n",
+			   udma_params.name, rc);
+		return rc;
+	}
+	/* initialize Rx udma */
+	udma_params.dev = adapter->netdev->dev.parent;
+	udma_params.udma_regs_base = adapter->unit_regs;
+	udma_params.type = UDMA_RX;
+	udma_params.cdesc_size = AL_ETH_UDMA_RX_CDESC_SZ;
+	udma_params.num_of_queues = AL_ETH_UDMA_RX_QUEUES;
+	udma_params.name = "eth rx";
+	rc = al_udma_init(&adapter->rx_udma, &udma_params);
+
+	if (rc != 0) {
+		netdev_err(adapter->netdev,
+			   "failed to initialize %s, error %d\n",
+			   udma_params.name, rc);
+		return rc;
+	}
+
+	rc = al_udma_state_set_wait(adapter, &adapter->rx_udma, UDMA_NORMAL);
+	if (rc != 0) {
+		netdev_err(adapter->netdev,
+			   "[%s]: failed to change state, error %d\n",
+			   udma_params.name, rc);
+		return rc;
+	}
+
+	netdev_dbg(adapter->netdev,
+		   "eth [%s]: controller's UDMA successfully initialized\n",
+		   params->name);
+
+	/* set max packet size to 1M (for TSO) */
+	conf.encode_64k_as_zero = true;
+	conf.max_pkt_size = 0xfffff;
+	al_udma_m2s_packet_size_cfg_set(&adapter->tx_udma, &conf);
+
+	/*
+	 * Set m2s (tx) max descriptors to max data buffers number and one for
+	 * meta descriptor
+	 */
+	al_udma_m2s_max_descs_set(&adapter->tx_udma, AL_ETH_PKT_MAX_BUFS + 1);
+
+	/* set s2m (rx) max descriptors to max data buffers */
+	al_udma_s2m_max_descs_set(&adapter->rx_udma, AL_ETH_PKT_MAX_BUFS);
+
+	/*
+	 * set s2m burst length when writing completion descriptors to
+	 * 64 bytes
+	 */
+	al_udma_s2m_compl_desc_burst_config(&adapter->rx_udma, 64);
+
+	/* if pointer to ec regs provided, then init the tx meta cache of this udma*/
+	if (adapter->ec_regs_base) {
+		/* INIT TX CACHE TABLE: */
+		for (i = 0; i < 4; i++) {
+			writel(i + (adapter->udma_id * 4),
+			       &adapter->ec_regs_base->tso.cache_table_addr);
+			writel(0x00000000,
+			       &adapter->ec_regs_base->tso.cache_table_data_1);
+			writel(0x00000000,
+			       &adapter->ec_regs_base->tso.cache_table_data_2);
+			writel(0x00000000,
+			       &adapter->ec_regs_base->tso.cache_table_data_3);
+			writel(0x00000000,
+			       &adapter->ec_regs_base->tso.cache_table_data_4);
+		}
+	}
+	/* only udma 0 allowed to init ec */
+	if (adapter->udma_id != 0)
+		return 0;
+
+	/* enable internal machines*/
+	writel(0xffffffff, &adapter->ec_regs_base->gen.en);
+	writel(0xffffffff, &adapter->ec_regs_base->gen.fifo_en);
+
+	/* enable A0 descriptor structure */
+	writel(readl(&adapter->ec_regs_base->gen.en_ext) | EC_GEN_EN_EXT_CACHE_WORD_SPLIT,
+	       &adapter->ec_regs_base->gen.en_ext);
+
+	/* use mss value in the descriptor */
+	writel(EC_TSO_CFG_ADD_0_MSS_SEL,
+	       &adapter->ec_regs_base->tso.cfg_add_0);
+
+	/* enable tunnel TSO */
+	reg = EC_TSO_CFG_TUNNEL_EN_TUNNEL_TSO | EC_TSO_CFG_TUNNEL_EN_UDP_CHKSUM |
+		EC_TSO_CFG_TUNNEL_EN_UDP_LEN | EC_TSO_CFG_TUNNEL_EN_IPV6_PLEN |
+		EC_TSO_CFG_TUNNEL_EN_IPV4_CHKSUM | EC_TSO_CFG_TUNNEL_EN_IPV4_IDEN |
+		EC_TSO_CFG_TUNNEL_EN_IPV4_TLEN;
+	writel(reg, &adapter->ec_regs_base->tso.cfg_tunnel);
+
+	/* swap input byts from MAC RX */
+	writel(0x1, &adapter->ec_regs_base->mac.gen);
+	/* swap output bytes to MAC TX*/
+	writel(EC_TMI_TX_CFG_EN_FWD_TO_RX | EC_TMI_TX_CFG_SWAP_BYTES,
+	       &adapter->ec_regs_base->tmi.tx_cfg);
+
+	writel(0x3fb, &adapter->ec_regs_base->tfw_udma[0].fwd_dec);
+
+	/* RFW configuration: default 0 */
+	writel(0x1, &adapter->ec_regs_base->rfw_default[0].opt_1);
+
+	/* VLAN table address */
+	writel(0x0, &adapter->ec_regs_base->rfw.vid_table_addr);
+	/* VLAN table data */
+	writel(0x0, &adapter->ec_regs_base->rfw.vid_table_data);
+	/*
+	 * HASH config (select toeplitz and bits 7:0 of the thash result, enable
+	 * symmetric hash)
+	 */
+	reg = EC_RFW_THASH_CFG_1_ENABLE_IP_SWAP | EC_RFW_THASH_CFG_1_ENABLE_PORT_SWAP;
+	writel(reg, &adapter->ec_regs_base->rfw.thash_cfg_1);
+
+	al_eth_epe_init(adapter);
+
+	/* disable TSO padding and use mac padding instead */
+	reg = readl(&adapter->ec_regs_base->tso.in_cfg);
+	reg &= ~0x7F00; /*clear bits 14:8 */
+	writel(reg, &adapter->ec_regs_base->tso.in_cfg);
+
+	return 0;
+}
+
+/*
+ * stop the DMA of the ethernet adapter
+ */
+int al_eth_adapter_stop(struct al_hw_eth_adapter *adapter)
+{
+	int rc;
+
+	netdev_dbg(adapter->netdev, "eth [%s]: stop controller's UDMA\n",
+		   adapter->name);
+
+	/* disable Tx dma*/
+	rc = al_udma_state_set_wait(adapter, &adapter->tx_udma, UDMA_DISABLE);
+	if (rc != 0) {
+		netdev_warn(adapter->netdev,
+			    "[%s] warn: failed to change state, error %d\n",
+			    adapter->tx_udma.name, rc);
+		return rc;
+	}
+
+	netdev_dbg(adapter->netdev, "eth [%s]: controller's TX UDMA stopped\n",
+		   adapter->name);
+
+	/* disable Rx dma*/
+	rc = al_udma_state_set_wait(adapter, &adapter->rx_udma, UDMA_DISABLE);
+	if (rc != 0) {
+		netdev_warn(adapter->netdev,
+			    "[%s] warn: failed to change state, error %d\n",
+			    adapter->rx_udma.name, rc);
+		return rc;
+	}
+
+	netdev_dbg(adapter->netdev, "eth [%s]: controller's RX UDMA stopped\n",
+		   adapter->name);
+	return 0;
+}
+
+/* Q management */
+/*
+ * Configure and enable a queue ring
+ */
+int al_eth_queue_config(struct al_hw_eth_adapter *adapter,
+			enum al_udma_type type, u32 qid,
+			struct al_udma_q_params *q_params)
+{
+	struct al_udma *udma;
+	int rc;
+
+	netdev_dbg(adapter->netdev, "eth [%s]: config UDMA %s queue %d\n",
+		   adapter->name, type == UDMA_TX ? "Tx" : "Rx", qid);
+
+	udma = (type == UDMA_TX) ? &adapter->tx_udma : &adapter->rx_udma;
+	q_params->adapter_rev_id = adapter->rev_id;
+
+	rc = al_udma_q_init(udma, qid, q_params);
+	if (rc)
+		return rc;
+
+	if (type == UDMA_RX)
+		al_udma_s2m_q_compl_coal_config(&udma->udma_q[qid], true,
+						AL_ETH_S2M_UDMA_COMP_COAL_TIMEOUT);
+
+	return rc;
+}
+
+/* MAC layer */
+int al_eth_rx_pkt_limit_config(struct al_hw_eth_adapter *adapter,
+			       u32 min_rx_len, u32 max_rx_len)
+{
+	WARN_ON(AL_ETH_MAX_FRAME_LEN < max_rx_len);
+
+	/* EC minimum packet length [bytes] in RX */
+	writel(min_rx_len, &adapter->ec_regs_base->mac.min_pkt);
+	/* EC maximum packet length [bytes] in RX */
+	writel(max_rx_len, &adapter->ec_regs_base->mac.max_pkt);
+
+	if (adapter->rev_id > AL_ETH_REV_ID_2) {
+		writel(min_rx_len,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_1);
+		writel(max_rx_len,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_2);
+	}
+
+	/*
+	 * configure the MAC's max rx length, add 16 bytes so the packet get
+	 * trimmed by the EC/Async_fifo rather by the MAC
+	 */
+	if (AL_ETH_IS_1G_MAC(adapter->mac_mode))
+		writel(max_rx_len + 16,
+		       &adapter->mac_regs_base->mac_1g.frm_len);
+	else if (AL_ETH_IS_10G_MAC(adapter->mac_mode) ||
+		 AL_ETH_IS_25G_MAC(adapter->mac_mode))
+		/* 10G MAC control register  */
+		writel((max_rx_len + 16),
+		       &adapter->mac_regs_base->mac_10g.frm_len);
+	else
+		al_eth_40g_mac_reg_write(adapter,
+					 ETH_MAC_GEN_V3_MAC_40G_FRM_LENGTH_ADDR,
+					 (max_rx_len + 16));
+
+	return 0;
+}
+
+/* configure the mac media type. */
+int al_eth_mac_config(struct al_hw_eth_adapter *adapter, enum al_eth_mac_mode mode)
+{
+	u32 tmp;
+
+	switch (mode) {
+	case AL_ETH_MAC_MODE_RGMII:
+		writel(0x40003210, &adapter->mac_regs_base->gen.clk_cfg);
+
+		/*
+		 * 1G MAC control register
+		 *
+		 * bit[0]  - TX_ENA - zeroed by default. Should be asserted by al_eth_mac_start
+		 * bit[1]  - RX_ENA - zeroed by default. Should be asserted by al_eth_mac_start
+		 * bit[3]  - ETH_SPEED - zeroed to enable 10/100 Mbps Ethernet
+		 * bit[4]  - PROMIS_EN - asserted to enable MAC promiscuous mode
+		 * bit[23] - CNTL_FRM-ENA - asserted to enable control frames
+		 * bit[24] - NO_LGTH_CHECK - asserted to disable length checks, which is done in the controller
+		 */
+		writel(0x01800010, &adapter->mac_regs_base->mac_1g.cmd_cfg);
+
+		writel(0x00000000,
+		       &adapter->mac_regs_base->mac_1g.rx_section_empty);
+		writel(0x0000000c,
+		       &adapter->mac_regs_base->mac_1g.rx_section_full);
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.rx_almost_empty);
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.rx_almost_full);
+
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.tx_section_empty);
+		writel(0x0000000c,
+		       &adapter->mac_regs_base->mac_1g.tx_section_full);
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.tx_almost_empty);
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.tx_almost_full);
+
+		writel(0x00000000, &adapter->mac_regs_base->gen.cfg);
+
+		/*
+		 * 1G MACSET 1G
+		 * taking sel_1000/sel_10 inputs from rgmii PHY, and not from register.
+		 * disabling magic_packets detection in mac
+		 */
+		writel(0x00000002, &adapter->mac_regs_base->gen.mac_1g_cfg);
+		/* RGMII set 1G */
+		tmp = readl(&adapter->mac_regs_base->gen.mux_sel);
+		tmp &= ETH_MAC_GEN_MUX_SEL_KR_IN_MASK;
+		tmp |= 0x63910;
+		writel(tmp, &adapter->mac_regs_base->gen.mux_sel);
+		writel(0xf, &adapter->mac_regs_base->gen.rgmii_sel);
+		break;
+	case AL_ETH_MAC_MODE_SGMII:
+		if (adapter->rev_id > AL_ETH_REV_ID_2) {
+			/*
+			 * Configure and enable the ASYNC FIFO between the MACs
+			 * and the EC
+			 */
+			/* TX min packet size */
+			writel(0x00000010,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_1);
+			/* TX max packet size */
+			writel(0x00002800,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_2);
+			/* TX input bus configuration */
+			writel(0x00000080,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_3);
+			/* TX output bus configuration */
+			writel(0x00030020,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_4);
+			/* TX Valid/ready configuration */
+			writel(0x00000121,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_5);
+			/* RX input bus configuration */
+			writel(0x00030020,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_3);
+			/* RX output bus configuration */
+			writel(0x00000080,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_4);
+			/* RX Valid/ready configuration */
+			writel(0x00000212,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_5);
+			/* V3 additional MAC selection */
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_sel);
+			writel(0x00000001,
+			       &adapter->mac_regs_base->gen_v3.mac_10g_ll_cfg);
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_10g_ll_ctrl);
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.pcs_10g_ll_cfg);
+			/* ASYNC FIFO ENABLE */
+			writel(0x00003333,
+			       &adapter->mac_regs_base->gen_v3.afifo_ctrl);
+			/* Timestamp_configuration */
+			writel(ETH_MAC_GEN_V3_SPARE_CHICKEN_DISABLE_TIMESTAMP_STRETCH,
+			       &adapter->mac_regs_base->gen_v3.spare);
+		}
+
+		writel(0x40053210, &adapter->mac_regs_base->gen.clk_cfg);
+
+		/*
+		 * 1G MAC control register
+		 *
+		 * bit[0]  - TX_ENA - zeroed by default. Should be asserted by al_eth_mac_start
+		 * bit[1]  - RX_ENA - zeroed by default. Should be asserted by al_eth_mac_start
+		 * bit[3]  - ETH_SPEED - zeroed to enable 10/100 Mbps Ethernet
+		 * bit[4]  - PROMIS_EN - asserted to enable MAC promiscuous mode
+		 * bit[23] - CNTL_FRM-ENA - asserted to enable control frames
+		 * bit[24] - NO_LGTH_CHECK - asserted to disable length checks, which is done in the controller
+		 */
+		writel(0x01800010, &adapter->mac_regs_base->mac_1g.cmd_cfg);
+
+		writel(0x00000000,
+		       &adapter->mac_regs_base->mac_1g.rx_section_empty);
+		writel(0x0000000c,
+		       &adapter->mac_regs_base->mac_1g.rx_section_full); /* must be larger than almost empty */
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.rx_almost_empty);
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.rx_almost_full);
+
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.tx_section_empty); /* 8 ? */
+		writel(0x0000000c,
+		       &adapter->mac_regs_base->mac_1g.tx_section_full);
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.tx_almost_empty);
+		writel(0x00000008,
+		       &adapter->mac_regs_base->mac_1g.tx_almost_full);
+
+		/* XAUI MAC control register */
+		writel(0x000000c0, &adapter->mac_regs_base->gen.cfg);
+
+		/*
+		 * 1G MACSET 1G
+		 * taking sel_1000/sel_10 inputs from rgmii_converter, and not from register.
+		 * disabling magic_packets detection in mac
+		 */
+		writel(0x00000002, &adapter->mac_regs_base->gen.mac_1g_cfg);
+
+		/* Setting PCS i/f mode to SGMII (instead of default 1000Base-X) */
+		writel(0x00000014, &adapter->mac_regs_base->sgmii.reg_addr);
+		writel(0x0000000b, &adapter->mac_regs_base->sgmii.reg_data);
+		/* setting dev_ability to have speed of 1000Mb, [11:10] = 2'b10 */
+		writel(0x00000004, &adapter->mac_regs_base->sgmii.reg_addr);
+		writel(0x000009A0, &adapter->mac_regs_base->sgmii.reg_data);
+
+		tmp = readl(&adapter->mac_regs_base->gen.led_cfg);
+		tmp &= ~ETH_MAC_GEN_LED_CFG_SEL_MASK;
+		tmp |= ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG;
+		writel(tmp, &adapter->mac_regs_base->gen.led_cfg);
+		break;
+
+	case AL_ETH_MAC_MODE_SGMII_2_5G:
+		if (adapter->rev_id > AL_ETH_REV_ID_2) {
+			/* configure and enable the ASYNC FIFO between the MACs and the EC */
+			/* TX min packet size */
+			writel(0x00000010,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_1);
+			/* TX max packet size */
+			writel(0x00002800,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_2);
+			/* TX input bus configuration */
+			writel(0x00000080,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_3);
+			/* TX output bus configuration */
+			writel(0x00030020,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_4);
+			/* TX Valid/ready configuration */
+			writel(0x00000023,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_5);
+			/* RX input bus configuration */
+			writel(0x00030020,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_3);
+			/* RX output bus configuration */
+			writel(0x00000080,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_4);
+			/* RX Valid/ready configuration */
+			writel(0x00000012,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_5);
+			/* V3 additional MAC selection */
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_sel);
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_10g_ll_cfg);
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_10g_ll_ctrl);
+			writel(0x00000050,
+			       &adapter->mac_regs_base->gen_v3.pcs_10g_ll_cfg);
+			/* ASYNC FIFO ENABLE */
+			writel(0x00003333,
+			       &adapter->mac_regs_base->gen_v3.afifo_ctrl);
+		}
+
+		/* MAC register file */
+		writel(0x01022830, &adapter->mac_regs_base->mac_10g.cmd_cfg);
+		/* XAUI MAC control register */
+		writel(0x00000001, &adapter->mac_regs_base->gen.cfg);
+		writel(0x00000028, &adapter->mac_regs_base->mac_10g.if_mode);
+		writel(0x00001140, &adapter->mac_regs_base->mac_10g.control);
+		/* RXAUI MAC control register */
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_32_64);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_64_32);
+
+		tmp = readl(&adapter->mac_regs_base->gen.mux_sel);
+		tmp &= ETH_MAC_GEN_MUX_SEL_KR_IN_MASK;
+		tmp |= 0x00063910;
+		writel(tmp, &adapter->mac_regs_base->gen.mux_sel);
+
+		writel(0x40003210, &adapter->mac_regs_base->gen.clk_cfg);
+		writel(0x000004f0, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+		writel(0x00000401, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+
+		tmp = readl(&adapter->mac_regs_base->gen.led_cfg);
+		tmp &= ~ETH_MAC_GEN_LED_CFG_SEL_MASK;
+		tmp |= ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG;
+		writel(tmp, &adapter->mac_regs_base->gen.led_cfg);
+		break;
+
+	case AL_ETH_MAC_MODE_10GbE_Serial:
+		if (adapter->rev_id > AL_ETH_REV_ID_2) {
+			/* configure and enable the ASYNC FIFO between the MACs and the EC */
+			/* TX min packet size */
+			writel(0x00000010,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_1);
+			/* TX max packet size */
+			writel(0x00002800,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_2);
+			/* TX input bus configuration */
+			writel(0x00000080,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_3);
+			/* TX output bus configuration */
+			writel(0x00030020,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_4);
+			/* TX Valid/ready configuration */
+			writel(0x00000023,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_5);
+			/* RX input bus configuration */
+			writel(0x00030020,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_3);
+			/* RX output bus configuration */
+			writel(0x00000080,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_4);
+			/* RX Valid/ready configuration */
+			writel(0x00000012,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_5);
+			/* V3 additional MAC selection */
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_sel);
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_10g_ll_cfg);
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_10g_ll_ctrl);
+			writel(0x00000050,
+			       &adapter->mac_regs_base->gen_v3.pcs_10g_ll_cfg);
+			/* ASYNC FIFO ENABLE */
+			writel(0x00003333,
+			       &adapter->mac_regs_base->gen_v3.afifo_ctrl);
+		}
+
+		/* MAC register file */
+		writel(0x01022810, &adapter->mac_regs_base->mac_10g.cmd_cfg);
+		/* XAUI MAC control register */
+		writel(0x00000005, &adapter->mac_regs_base->gen.cfg);
+		/* RXAUI MAC control register */
+		writel(0x00000007, &adapter->mac_regs_base->gen.rxaui_cfg);
+		writel(0x000001F1, &adapter->mac_regs_base->gen.sd_cfg);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_32_64);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_64_32);
+
+		tmp = readl(&adapter->mac_regs_base->gen.mux_sel);
+		tmp &= ETH_MAC_GEN_MUX_SEL_KR_IN_MASK;
+		tmp |= 0x73910;
+		writel(tmp, &adapter->mac_regs_base->gen.mux_sel);
+
+		writel(0x10003210, &adapter->mac_regs_base->gen.clk_cfg);
+		writel(0x000004f0, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+		writel(0x00000401, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+
+		tmp = readl(&adapter->mac_regs_base->gen.led_cfg);
+		tmp &= ~ETH_MAC_GEN_LED_CFG_SEL_MASK;
+		tmp |= ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG;
+		writel(tmp, &adapter->mac_regs_base->gen.led_cfg);
+		break;
+
+	case AL_ETH_MAC_MODE_KR_LL_25G:
+		if (adapter->rev_id > AL_ETH_REV_ID_2) {
+			/* configure and enable the ASYNC FIFO between the MACs and the EC */
+			/* TX min packet size */
+			writel(0x00000010,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_1);
+			/* TX max packet size */
+			writel(0x00002800,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_2);
+			/* TX input bus configuration */
+			writel(0x00000080,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_3);
+			/* TX output bus configuration */
+			writel(0x00030020,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_4);
+			/* TX Valid/ready configuration */
+			writel(0x00000023,
+			       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_5);
+			/* RX input bus configuration */
+			writel(0x00030020,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_3);
+			/* RX output bus configuration */
+			writel(0x00000080,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_4);
+			/* RX Valid/ready configuration */
+			writel(0x00000012,
+			       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_5);
+			/* V3 additional MAC selection */
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_sel);
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_10g_ll_cfg);
+			writel(0x00000000,
+			       &adapter->mac_regs_base->gen_v3.mac_10g_ll_ctrl);
+			writel(0x000000a0,
+			       &adapter->mac_regs_base->gen_v3.pcs_10g_ll_cfg);
+			/* ASYNC FIFO ENABLE */
+			writel(0x00003333,
+			       &adapter->mac_regs_base->gen_v3.afifo_ctrl);
+		}
+
+		/* MAC register file */
+		writel(0x01022810, &adapter->mac_regs_base->mac_10g.cmd_cfg);
+		/* XAUI MAC control register */
+		writel(0x00000005, &adapter->mac_regs_base->gen.cfg);
+		/* RXAUI MAC control register */
+		writel(0x00000007, &adapter->mac_regs_base->gen.rxaui_cfg);
+		writel(0x000001F1, &adapter->mac_regs_base->gen.sd_cfg);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_32_64);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_64_32);
+
+		writel(0x000004f0, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+		writel(0x00000401, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+
+		tmp = readl(&adapter->mac_regs_base->gen.led_cfg);
+		tmp &= ETH_MAC_GEN_LED_CFG_SEL_MASK;
+		tmp |= ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG;
+		writel(tmp, &adapter->mac_regs_base->gen.led_cfg);
+
+		break;
+
+	case AL_ETH_MAC_MODE_10G_SGMII:
+		/* MAC register file */
+		writel(0x01022810, &adapter->mac_regs_base->mac_10g.cmd_cfg);
+
+		/* XAUI MAC control register */
+		writel(0x00000001, &adapter->mac_regs_base->gen.cfg);
+
+		writel(0x0000002b, &adapter->mac_regs_base->mac_10g.if_mode);
+		writel(0x00009140, &adapter->mac_regs_base->mac_10g.control);
+
+		/* RXAUI MAC control register */
+		writel(0x00000007, &adapter->mac_regs_base->gen.rxaui_cfg);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_32_64);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_64_32);
+
+		tmp = readl(&adapter->mac_regs_base->gen.mux_sel);
+		tmp &= ETH_MAC_GEN_MUX_SEL_KR_IN_MASK;
+		tmp |= 0x00063910;
+		writel(tmp, &adapter->mac_regs_base->gen.mux_sel);
+
+		writel(0x40003210, &adapter->mac_regs_base->gen.clk_cfg);
+		writel(0x00000401, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+
+		tmp = readl(&adapter->mac_regs_base->gen.led_cfg);
+		tmp &= ~ETH_MAC_GEN_LED_CFG_SEL_MASK;
+		tmp |= ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG;
+		writel(tmp, &adapter->mac_regs_base->gen.led_cfg);
+		break;
+
+	case AL_ETH_MAC_MODE_XLG_LL_40G:
+		/* configure and enable the ASYNC FIFO between the MACs and the EC */
+		/* TX min packet size */
+		writel(0x00000010,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_1);
+		/* TX max packet size */
+		writel(0x00002800,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_2);
+		/* TX input bus configuration */
+		writel(0x00000080,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_3);
+		/* TX output bus configuration */
+		writel(0x00010040,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_4);
+		/* TX Valid/ready configuration */
+		writel(0x00000023,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_5);
+		/* RX input bus configuration */
+		writel(0x00010040,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_3);
+		/* RX output bus configuration */
+		writel(0x00000080,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_4);
+		/* RX Valid/ready configuration */
+		writel(0x00000112,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_5);
+		/* V3 additional MAC selection */
+		writel(0x00000010, &adapter->mac_regs_base->gen_v3.mac_sel);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.mac_10g_ll_cfg);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.mac_10g_ll_ctrl);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.pcs_10g_ll_cfg);
+		/* ASYNC FIFO ENABLE */
+		writel(0x00003333, &adapter->mac_regs_base->gen_v3.afifo_ctrl);
+
+		/* cmd_cfg */
+		writel(0x00000008,
+		       &adapter->mac_regs_base->gen_v3.mac_40g_ll_addr);
+		writel(0x01022810,
+		       &adapter->mac_regs_base->gen_v3.mac_40g_ll_data);
+
+		/* XAUI MAC control register */
+		tmp = readl(&adapter->mac_regs_base->gen.mux_sel);
+		tmp &= ETH_MAC_GEN_MUX_SEL_KR_IN_MASK;
+		tmp |= 0x06883910;
+		writel(tmp, &adapter->mac_regs_base->gen.mux_sel);
+		writel(0x0000040f, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+
+		/* XAUI MAC control register */
+		writel(0x00000005, &adapter->mac_regs_base->gen.cfg);
+		/* RXAUI MAC control register */
+		writel(0x00000007, &adapter->mac_regs_base->gen.rxaui_cfg);
+		writel(0x000001F1, &adapter->mac_regs_base->gen.sd_cfg);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_32_64);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_64_32);
+		writel(0x10003210, &adapter->mac_regs_base->gen.clk_cfg);
+
+		tmp = readl(&adapter->mac_regs_base->gen.led_cfg);
+		tmp &= ~ETH_MAC_GEN_LED_CFG_SEL_MASK;
+		tmp |= ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG;
+		writel(tmp, &adapter->mac_regs_base->gen.led_cfg);
+		break;
+
+	case AL_ETH_MAC_MODE_XLG_LL_25G:
+		/* xgmii_mode: 0=xlgmii, 1=xgmii */
+		writel(0x0080,
+		       &adapter->mac_regs_base->gen_v3.mac_40g_ll_addr);
+		writel(0x00000001,
+		       &adapter->mac_regs_base->gen_v3.mac_40g_ll_data);
+
+		/* configure and enable the ASYNC FIFO between the MACs and the EC */
+		/* TX min packet size */
+		writel(0x00000010,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_1);
+		/* TX max packet size */
+		writel(0x00002800,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_2);
+		/* TX input bus configuration */
+		writel(0x00000080,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_3);
+		/* TX output bus configuration */
+		writel(0x00010040,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_4);
+		/* TX Valid/ready configuration */
+		writel(0x00000023,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_5);
+		/* RX input bus configuration */
+		writel(0x00010040,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_3);
+		/* RX output bus configuration */
+		writel(0x00000080,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_4);
+		/* RX Valid/ready configuration */
+		writel(0x00000112,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_5);
+		/* V3 additional MAC selection */
+		writel(0x00000010, &adapter->mac_regs_base->gen_v3.mac_sel);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.mac_10g_ll_cfg);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.mac_10g_ll_ctrl);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.pcs_10g_ll_cfg);
+		/* ASYNC FIFO ENABLE */
+		writel(0x00003333, &adapter->mac_regs_base->gen_v3.afifo_ctrl);
+
+		/* cmd_cfg */
+		writel(0x00000008,
+		       &adapter->mac_regs_base->gen_v3.mac_40g_ll_addr);
+		writel(0x01022810,
+		       &adapter->mac_regs_base->gen_v3.mac_40g_ll_data);
+		/* use VL 0-2 for RXLAUI lane 0, use VL 1-3 for RXLAUI lane 1 */
+		al_eth_40g_pcs_reg_write(adapter, 0x00010008, 0x0d80);
+		/* configure the PCS to work 32 bit interface */
+		writel(0x00440000,
+		       &adapter->mac_regs_base->gen_v3.pcs_40g_ll_cfg);
+
+		/* disable MLD and move to clause 49 PCS: */
+		writel(0xE, &adapter->mac_regs_base->gen_v3.pcs_40g_ll_addr);
+		writel(0, &adapter->mac_regs_base->gen_v3.pcs_40g_ll_data);
+
+		/* XAUI MAC control register */
+		writel(0x0000040f, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+
+		/* XAUI MAC control register */
+		writel(0x00000005, &adapter->mac_regs_base->gen.cfg);
+		/* RXAUI MAC control register */
+		writel(0x00000007, &adapter->mac_regs_base->gen.rxaui_cfg);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_32_64);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_64_32);
+
+		tmp = readl(&adapter->mac_regs_base->gen.led_cfg);
+		tmp &= ~ETH_MAC_GEN_LED_CFG_SEL_MASK;
+		tmp |= ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG;
+		writel(tmp, &adapter->mac_regs_base->gen.led_cfg);
+
+		break;
+
+	case AL_ETH_MAC_MODE_XLG_LL_50G:
+
+		/* configure and enable the ASYNC FIFO between the MACs and the EC */
+		/* TX min packet size */
+		writel(0x00000010,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_1);
+		/* TX max packet size */
+		writel(0x00002800,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_2);
+		/* TX input bus configuration */
+		writel(0x00000080,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_3);
+		/* TX output bus configuration */
+		writel(0x00010040,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_4);
+		/* TX Valid/ready configuration */
+		writel(0x00000023,
+		       &adapter->mac_regs_base->gen_v3.tx_afifo_cfg_5);
+		/* RX input bus configuration */
+		writel(0x00010040,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_3);
+		/* RX output bus configuration */
+		writel(0x00000080,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_4);
+		/* RX Valid/ready configuration */
+		writel(0x00000112,
+		       &adapter->mac_regs_base->gen_v3.rx_afifo_cfg_5);
+		/* V3 additional MAC selection */
+		writel(0x00000010, &adapter->mac_regs_base->gen_v3.mac_sel);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.mac_10g_ll_cfg);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.mac_10g_ll_ctrl);
+		writel(0x00000000,
+		       &adapter->mac_regs_base->gen_v3.pcs_10g_ll_cfg);
+		/* ASYNC FIFO ENABLE */
+		writel(0x00003333, &adapter->mac_regs_base->gen_v3.afifo_ctrl);
+
+		/* cmd_cfg */
+		writel(0x00000008,
+		       &adapter->mac_regs_base->gen_v3.mac_40g_ll_addr);
+		writel(0x01022810,
+		       &adapter->mac_regs_base->gen_v3.mac_40g_ll_data);
+
+		/* configure which two of the 4 PCS Lanes (VL) are combined to one RXLAUI lane */
+		/* use VL 0-2 for RXLAUI lane 0, use VL 1-3 for RXLAUI lane 1 */
+		al_eth_40g_pcs_reg_write(adapter, 0x00010008, 0x0d81);
+		/* configure the PCS to work 32 bit interface */
+		writel(0x00440000,
+		       &adapter->mac_regs_base->gen_v3.pcs_40g_ll_cfg);
+
+		/* XAUI MAC control register */
+		tmp = readl(&adapter->mac_regs_base->gen.mux_sel);
+		tmp &= ETH_MAC_GEN_MUX_SEL_KR_IN_MASK;
+		tmp |= 0x06883910;
+		writel(tmp, &adapter->mac_regs_base->gen.mux_sel);
+
+		writel(0x0000040f, &adapter->mac_regs_base->gen.sd_fifo_ctrl);
+
+		/* XAUI MAC control register */
+		writel(0x00000005, &adapter->mac_regs_base->gen.cfg);
+		/* RXAUI MAC control register */
+		writel(0x00000007, &adapter->mac_regs_base->gen.rxaui_cfg);
+		writel(0x000001F1, &adapter->mac_regs_base->gen.sd_cfg);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_32_64);
+		writel(0x00000401,
+		       &adapter->mac_regs_base->gen.xgmii_dfifo_64_32);
+		writel(0x10003210, &adapter->mac_regs_base->gen.clk_cfg);
+
+		tmp = readl(&adapter->mac_regs_base->gen.led_cfg);
+		tmp &= ~ETH_MAC_GEN_LED_CFG_SEL_MASK;
+		tmp |= ETH_MAC_GEN_LED_CFG_SEL_DEFAULT_REG;
+		writel(tmp, &adapter->mac_regs_base->gen.led_cfg);
+		break;
+
+	default:
+		netdev_err(adapter->netdev, "Eth: unsupported MAC mode %d",
+			   mode);
+		return -EPERM;
+	}
+	adapter->mac_mode = mode;
+	netdev_info(adapter->netdev, "configured MAC to %s mode:\n",
+		    al_eth_mac_mode_str(mode));
+
+	return 0;
+}
+
+/* start the mac */
+int al_eth_mac_start(struct al_hw_eth_adapter *adapter)
+{
+	u32 tmp;
+
+	if (AL_ETH_IS_1G_MAC(adapter->mac_mode)) {
+		/* 1G MAC control register */
+		tmp = readl(&adapter->mac_regs_base->mac_1g.cmd_cfg);
+		tmp |= ETH_1G_MAC_CMD_CFG_TX_ENA | ETH_1G_MAC_CMD_CFG_RX_ENA;
+		writel(tmp, &adapter->mac_regs_base->mac_1g.cmd_cfg);
+	} else if (AL_ETH_IS_10G_MAC(adapter->mac_mode) || AL_ETH_IS_25G_MAC(adapter->mac_mode)) {
+		/* 10G MAC control register  */
+		tmp = readl(&adapter->mac_regs_base->mac_10g.cmd_cfg);
+		tmp |= ETH_10G_MAC_CMD_CFG_TX_ENA | ETH_10G_MAC_CMD_CFG_RX_ENA;
+		writel(tmp, &adapter->mac_regs_base->mac_10g.cmd_cfg);
+	} else {
+		u32 cmd_cfg;
+
+		cmd_cfg = al_eth_40g_mac_reg_read(adapter,
+						  ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_ADDR);
+
+		cmd_cfg |= (ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_TX_ENA |
+			    ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_RX_ENA);
+
+		al_eth_40g_mac_reg_write(adapter,
+					 ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_ADDR,
+					 cmd_cfg);
+	}
+
+	return 0;
+}
+
+/* stop the mac */
+int al_eth_mac_stop(struct al_hw_eth_adapter *adapter)
+{
+	u32 tmp;
+
+	if (AL_ETH_IS_1G_MAC(adapter->mac_mode)) {
+		/* 1G MAC control register */
+		tmp = readl(&adapter->mac_regs_base->mac_1g.cmd_cfg);
+		tmp &= ~(ETH_1G_MAC_CMD_CFG_TX_ENA | ETH_1G_MAC_CMD_CFG_RX_ENA);
+		writel(tmp, &adapter->mac_regs_base->mac_1g.cmd_cfg);
+	} else if (AL_ETH_IS_10G_MAC(adapter->mac_mode) ||
+		 AL_ETH_IS_25G_MAC(adapter->mac_mode)) {
+		/* 10G MAC control register  */
+		tmp = readl(&adapter->mac_regs_base->mac_10g.cmd_cfg);
+		tmp &= ~(ETH_10G_MAC_CMD_CFG_TX_ENA | ETH_10G_MAC_CMD_CFG_RX_ENA);
+		writel(tmp, &adapter->mac_regs_base->mac_10g.cmd_cfg);
+	} else {
+		u32 cmd_cfg;
+
+		cmd_cfg = al_eth_40g_mac_reg_read(adapter,
+						  ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_ADDR);
+
+		cmd_cfg &= ~(ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_TX_ENA |
+			    ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_RX_ENA);
+
+		al_eth_40g_mac_reg_write(adapter,
+					 ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_ADDR,
+					 cmd_cfg);
+	}
+
+	return 0;
+}
+
+static void al_eth_mac_link_config_1g_mac(struct al_hw_eth_adapter *adapter,
+					  bool force_1000_base_x,
+					  bool an_enable, u32 speed,
+					  bool full_duplex)
+{
+	u32 mac_ctrl;
+	u32 sgmii_ctrl = 0;
+	u32 sgmii_if_mode = 0;
+	u32 rgmii_ctrl = 0;
+
+	mac_ctrl = readl(&adapter->mac_regs_base->mac_1g.cmd_cfg);
+
+	if (adapter->mac_mode == AL_ETH_MAC_MODE_SGMII) {
+		writel(ETH_MAC_SGMII_REG_ADDR_CTRL_REG,
+		       &adapter->mac_regs_base->sgmii.reg_addr);
+		sgmii_ctrl = readl(&adapter->mac_regs_base->sgmii.reg_data);
+		/*
+		 * in case bit 0 is off in sgmii_if_mode register all the other
+		 * bits are ignored.
+		 */
+		if (!force_1000_base_x)
+			sgmii_if_mode = ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_EN;
+
+		if (an_enable) {
+			sgmii_if_mode |= ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_AN;
+			sgmii_ctrl |= ETH_MAC_SGMII_REG_DATA_CTRL_AN_ENABLE;
+		} else {
+			sgmii_ctrl &= ~(ETH_MAC_SGMII_REG_DATA_CTRL_AN_ENABLE);
+		}
+	}
+
+	if (adapter->mac_mode == AL_ETH_MAC_MODE_RGMII) {
+		/*
+		 * Use the speed provided by the MAC instead of the PHY
+		 */
+		rgmii_ctrl = readl(&adapter->mac_regs_base->gen.rgmii_cfg);
+
+		rgmii_ctrl &= ~ETH_MAC_GEN_RGMII_CFG_ENA_AUTO;
+		rgmii_ctrl &= ~ETH_MAC_GEN_RGMII_CFG_SET_1000_SEL;
+		rgmii_ctrl &= ~ETH_MAC_GEN_RGMII_CFG_SET_10_SEL;
+
+		writel(rgmii_ctrl, &adapter->mac_regs_base->gen.rgmii_cfg);
+	}
+
+	if (full_duplex) {
+		mac_ctrl &= ~ETH_1G_MAC_CMD_CFG_HD_EN;
+	} else {
+		mac_ctrl |= ETH_1G_MAC_CMD_CFG_HD_EN;
+		sgmii_if_mode |= ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_DUPLEX;
+	}
+
+	if (speed == 1000) {
+		mac_ctrl |= ETH_1G_MAC_CMD_CFG_1G_SPD;
+		sgmii_if_mode |= ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_SPEED_1000;
+	} else {
+		mac_ctrl &= ~ETH_1G_MAC_CMD_CFG_1G_SPD;
+		if (speed == 10) {
+			mac_ctrl |= ETH_1G_MAC_CMD_CFG_10M_SPD;
+		} else {
+			sgmii_if_mode |= ETH_MAC_SGMII_REG_DATA_IF_MODE_SGMII_SPEED_100;
+			mac_ctrl &= ~ETH_1G_MAC_CMD_CFG_10M_SPD;
+		}
+	}
+
+	if (adapter->mac_mode == AL_ETH_MAC_MODE_SGMII) {
+		writel(ETH_MAC_SGMII_REG_ADDR_IF_MODE_REG,
+		       &adapter->mac_regs_base->sgmii.reg_addr);
+		writel(sgmii_if_mode, &adapter->mac_regs_base->sgmii.reg_data);
+
+		writel(ETH_MAC_SGMII_REG_ADDR_CTRL_REG,
+		       &adapter->mac_regs_base->sgmii.reg_addr);
+		writel(sgmii_ctrl, &adapter->mac_regs_base->sgmii.reg_data);
+	}
+
+	writel(mac_ctrl, &adapter->mac_regs_base->mac_1g.cmd_cfg);
+}
+
+static void al_eth_mac_link_config_10g_mac(struct al_hw_eth_adapter *adapter,
+					   bool force_1000_base_x,
+					   bool an_enable, u32 speed,
+					   bool full_duplex)
+{
+	u32 if_mode;
+	u32 val;
+
+	if_mode = readl(&adapter->mac_regs_base->mac_10g.if_mode);
+
+	if (force_1000_base_x) {
+		u32 control;
+
+		if_mode &= ~ETH_10G_MAC_IF_MODE_SGMII_EN_MASK;
+
+		control = readl(&adapter->mac_regs_base->mac_10g.control);
+
+		if (an_enable)
+			control |= ETH_10G_MAC_CONTROL_AN_EN_MASK;
+		else
+			control &= ~ETH_10G_MAC_CONTROL_AN_EN_MASK;
+
+		writel(control, &adapter->mac_regs_base->mac_10g.control);
+
+	} else {
+		if_mode |= ETH_10G_MAC_IF_MODE_SGMII_EN_MASK;
+		if (an_enable) {
+			if_mode |= ETH_10G_MAC_IF_MODE_SGMII_AN_MASK;
+		} else {
+			if_mode &= ~ETH_10G_MAC_IF_MODE_SGMII_AN_MASK;
+
+			if (speed == 1000)
+				val = ETH_10G_MAC_IF_MODE_SGMII_SPEED_1G;
+			else if (speed == 100)
+				val = ETH_10G_MAC_IF_MODE_SGMII_SPEED_100M;
+			else
+				val = ETH_10G_MAC_IF_MODE_SGMII_SPEED_10M;
+
+			if_mode &= ~ETH_10G_MAC_IF_MODE_SGMII_SPEED_MASK;
+			if_mode |= (val << ETH_10G_MAC_IF_MODE_SGMII_SPEED_SHIFT) &
+				ETH_10G_MAC_IF_MODE_SGMII_SPEED_MASK;
+
+			if_mode &= ~ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_MASK;
+			if_mode |= (((full_duplex) ? ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_FULL :
+				     ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_HALF) << ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_SHIFT) &
+				     ETH_10G_MAC_IF_MODE_SGMII_DUPLEX_MASK;
+		}
+	}
+
+	writel(if_mode, &adapter->mac_regs_base->mac_10g.if_mode);
+}
+
+/* update link speed and duplex mode */
+int al_eth_mac_link_config(struct al_hw_eth_adapter *adapter,
+			   bool force_1000_base_x, bool an_enable, u32 speed,
+			   bool full_duplex)
+{
+	if ((!AL_ETH_IS_1G_MAC(adapter->mac_mode)) &&
+	    (adapter->mac_mode != AL_ETH_MAC_MODE_SGMII_2_5G)) {
+		netdev_err(adapter->netdev,
+			   "eth [%s]: this function not supported in this mac mode.\n",
+			   adapter->name);
+		return -EINVAL;
+	}
+
+	if ((adapter->mac_mode != AL_ETH_MAC_MODE_RGMII) && (an_enable)) {
+		/*
+		 * an_enable is not relevant to RGMII mode.
+		 * in AN mode speed and duplex aren't relevant.
+		 */
+		netdev_info(adapter->netdev,
+			    "eth [%s]: set auto negotiation to enable\n",
+			    adapter->name);
+	} else {
+		netdev_info(adapter->netdev,
+			    "eth [%s]: set link speed to %dMbps. %s duplex.\n",
+			    adapter->name, speed,
+			    full_duplex ? "full" : "half");
+
+		if ((speed != 10) && (speed != 100) && (speed != 1000)) {
+			netdev_err(adapter->netdev,
+				   "eth [%s]: bad speed parameter (%d).\n",
+				   adapter->name, speed);
+			return -EINVAL;
+		}
+		if ((speed == 1000) && (full_duplex == false)) {
+			netdev_err(adapter->netdev,
+				   "eth [%s]: half duplex in 1Gbps is not supported.\n",
+				   adapter->name);
+			return -EINVAL;
+		}
+	}
+
+	if (AL_ETH_IS_1G_MAC(adapter->mac_mode))
+		al_eth_mac_link_config_1g_mac(adapter, force_1000_base_x,
+					      an_enable, speed, full_duplex);
+	else
+		al_eth_mac_link_config_10g_mac(adapter, force_1000_base_x,
+					       an_enable, speed, full_duplex);
+
+	return 0;
+}
+
+/* MDIO */
+int al_eth_mdio_config(struct al_hw_eth_adapter *adapter,
+		       enum al_eth_mdio_type mdio_type, bool shared_mdio_if,
+		       enum al_eth_ref_clk_freq ref_clk_freq,
+		       unsigned int mdio_clk_freq_khz)
+{
+	enum al_eth_mdio_if mdio_if = AL_ETH_MDIO_IF_10G_MAC;
+	const char *if_name = (mdio_if == AL_ETH_MDIO_IF_1G_MAC) ? "10/100/1G MAC" : "10G MAC";
+	const char *type_name = (mdio_type == AL_ETH_MDIO_TYPE_CLAUSE_22) ? "Clause 22" : "Clause 45";
+	const char *shared_name = shared_mdio_if ? "Yes" : "No";
+	unsigned int ref_clk_freq_khz;
+	u32 val;
+
+	netdev_dbg(adapter->netdev,
+		   "eth [%s]: mdio config: interface %s. type %s. shared: %s\n",
+		   adapter->name, if_name, type_name, shared_name);
+	adapter->shared_mdio_if = shared_mdio_if;
+
+	val = readl(&adapter->mac_regs_base->gen.cfg);
+	netdev_dbg(adapter->netdev, "eth [%s]: mdio config: 10G mac \n",
+		   adapter->name);
+
+	switch (mdio_if) {
+	case AL_ETH_MDIO_IF_1G_MAC:
+		val &= ~BIT(10);
+		break;
+	case AL_ETH_MDIO_IF_10G_MAC:
+		val |= BIT(10);
+		break;
+	}
+
+	writel(val, &adapter->mac_regs_base->gen.cfg);
+	adapter->mdio_if = mdio_if;
+
+	if (mdio_if == AL_ETH_MDIO_IF_10G_MAC) {
+		val = readl(&adapter->mac_regs_base->mac_10g.mdio_cfg_status);
+		switch (mdio_type) {
+		case AL_ETH_MDIO_TYPE_CLAUSE_22:
+			val &= ~BIT(6);
+			break;
+		case AL_ETH_MDIO_TYPE_CLAUSE_45:
+			val |= BIT(6);
+			break;
+		}
+
+		/* set clock div to get 'mdio_clk_freq_khz' */
+		switch (ref_clk_freq) {
+		default:
+			netdev_err(adapter->netdev,
+				   "%s: invalid reference clock frequency (%d)\n",
+				   adapter->name, ref_clk_freq);
+		case AL_ETH_REF_FREQ_375_MHZ:
+			ref_clk_freq_khz = 375000;
+			break;
+		case AL_ETH_REF_FREQ_187_5_MHZ:
+			ref_clk_freq_khz = 187500;
+			break;
+		case AL_ETH_REF_FREQ_250_MHZ:
+			ref_clk_freq_khz = 250000;
+			break;
+		case AL_ETH_REF_FREQ_500_MHZ:
+			ref_clk_freq_khz = 500000;
+			break;
+		case AL_ETH_REF_FREQ_428_MHZ:
+			ref_clk_freq_khz = 428000;
+			break;
+		}
+
+		val &= ~(0x1FF << 7);
+		val |= (ref_clk_freq_khz / (2 * mdio_clk_freq_khz)) << 7;
+		val &= ~ETH_10G_MAC_MDIO_CFG_HOLD_TIME_MASK;
+		val |= (ETH_10G_MAC_MDIO_CFG_HOLD_TIME_7_CLK << ETH_10G_MAC_MDIO_CFG_HOLD_TIME_SHIFT) &
+			ETH_10G_MAC_MDIO_CFG_HOLD_TIME_MASK;
+		writel(val, &adapter->mac_regs_base->mac_10g.mdio_cfg_status);
+	} else {
+		if (mdio_type != AL_ETH_MDIO_TYPE_CLAUSE_22) {
+			netdev_err(adapter->netdev,
+				   "eth [%s] mdio type not supported for this interface\n",
+				   adapter->name);
+			return -EINVAL;
+		}
+	}
+
+	adapter->mdio_type = mdio_type;
+	return 0;
+}
+
+static void al_eth_mdio_1g_mac_read(struct al_hw_eth_adapter *adapter,
+				    u32 phy_addr, u32 reg, u16 *val)
+{
+	*val = readl(&adapter->mac_regs_base->mac_1g.phy_regs_base + reg);
+}
+
+static void al_eth_mdio_1g_mac_write(struct al_hw_eth_adapter *adapter,
+				     u32 phy_addr, u32 reg, u16 val)
+{
+	writel(val, &adapter->mac_regs_base->mac_1g.phy_regs_base + reg);
+}
+
+static int al_eth_mdio_10g_mac_wait_busy(struct al_hw_eth_adapter *adapter)
+{
+	int count = 0;
+	u32 mdio_cfg_status;
+
+	do {
+		mdio_cfg_status = readl(&adapter->mac_regs_base->mac_10g.mdio_cfg_status);
+		if (mdio_cfg_status & BIT(0)) {
+			if (count > 0)
+				netdev_dbg(adapter->netdev,
+					   "eth [%s] mdio: still busy!\n",
+					   adapter->name);
+		} else {
+			return 0;
+		}
+		udelay(AL_ETH_MDIO_DELAY_PERIOD);
+	} while (count++ < AL_ETH_MDIO_DELAY_COUNT);
+
+	return -ETIMEDOUT;
+}
+
+static int al_eth_mdio_10g_mac_type22(struct al_hw_eth_adapter *adapter,
+				      int read, u32 phy_addr, u32 reg, u16 *val)
+{
+	int rc;
+	const char *op = (read == 1) ? "read" : "write";
+	u32 mdio_cfg_status;
+	u16 mdio_cmd;
+
+	/* wait if the HW is busy */
+	rc = al_eth_mdio_10g_mac_wait_busy(adapter);
+	if (rc) {
+		netdev_err(adapter->netdev,
+			   " eth [%s] mdio %s failed. HW is busy\n",
+			   adapter->name, op);
+		return rc;
+	}
+
+	mdio_cmd = (u16)(0x1F & reg);
+	mdio_cmd |= (0x1F & phy_addr) << 5;
+
+	if (read)
+		mdio_cmd |= BIT(15); /* READ command */
+
+	writew(mdio_cmd, &adapter->mac_regs_base->mac_10g.mdio_cmd);
+	if (!read)
+		writew(*val, &adapter->mac_regs_base->mac_10g.mdio_data);
+
+	/* wait for the busy to clear */
+	rc = al_eth_mdio_10g_mac_wait_busy(adapter);
+	if (rc != 0) {
+		netdev_err(adapter->netdev, " %s mdio %s failed on timeout\n",
+			   adapter->name, op);
+		return -ETIMEDOUT;
+	}
+
+	mdio_cfg_status = readl(&adapter->mac_regs_base->mac_10g.mdio_cfg_status);
+
+	if (mdio_cfg_status & BIT(1)) {
+		netdev_err(adapter->netdev,
+			   " %s mdio %s failed on error. phy_addr 0x%x reg 0x%x\n",
+			   adapter->name, op, phy_addr, reg);
+		return -EIO;
+	}
+	if (read)
+		*val = readw((u16 *)&adapter->mac_regs_base->mac_10g.mdio_data);
+	return 0;
+}
+
+static int al_eth_mdio_10g_mac_type45(struct al_hw_eth_adapter *adapter,
+				      int read, u32 port_addr, u32 device,
+				      u32 reg, u16 *val)
+{
+	int rc;
+	const char *op = (read == 1) ? "read" : "write";
+	u32 mdio_cfg_status;
+	u16 mdio_cmd;
+
+	/* wait if the HW is busy */
+	rc = al_eth_mdio_10g_mac_wait_busy(adapter);
+	if (rc) {
+		netdev_err(adapter->netdev, " %s mdio %s failed. HW is busy\n",
+			   adapter->name, op);
+		return rc;
+	}
+
+	/* set command register */
+	mdio_cmd = (u16)(0x1F & device);
+	mdio_cmd |= (0x1F & port_addr) << 5;
+	writew(mdio_cmd, &adapter->mac_regs_base->mac_10g.mdio_cmd);
+
+	/* send address frame */
+	writew(reg, &adapter->mac_regs_base->mac_10g.mdio_regaddr);
+
+	/* wait for the busy to clear */
+	rc = al_eth_mdio_10g_mac_wait_busy(adapter);
+	if (rc) {
+		netdev_err(adapter->netdev,
+			   " %s mdio %s (address frame) failed on timeout\n",
+			   adapter->name, op);
+		return rc;
+	}
+
+	/* if read, write again to the command register with READ bit set */
+	if (read) {
+		mdio_cmd |= BIT(15); /* READ command */
+		writew(mdio_cmd, (u16 *)&adapter->mac_regs_base->mac_10g.mdio_cmd);
+	} else {
+		writew(*val, (u16 *)&adapter->mac_regs_base->mac_10g.mdio_data);
+	}
+
+	/* wait for the busy to clear */
+	rc = al_eth_mdio_10g_mac_wait_busy(adapter);
+	if (rc) {
+		netdev_err(adapter->netdev, " %s mdio %s failed on timeout\n",
+			   adapter->name, op);
+		return rc;
+	}
+
+	mdio_cfg_status = readl(&adapter->mac_regs_base->mac_10g.mdio_cfg_status);
+
+	if (mdio_cfg_status & BIT(1)) {
+		netdev_err(adapter->netdev,
+			   " %s mdio %s failed on error. port 0x%x, device 0x%x reg 0x%x\n",
+			   adapter->name, op, port_addr, device, reg);
+		return -EIO;
+	}
+
+	if (read)
+		*val = readw((u16 *)&adapter->mac_regs_base->mac_10g.mdio_data);
+
+	return 0;
+}
+
+/*
+ * acquire mdio interface ownership
+ * when mdio interface shared between multiple eth controllers, this function waits until the ownership granted for this controller.
+ * this function does nothing when the mdio interface is used only by this controller.
+ *
+ * @param adapter
+ * @return 0 on success, -ETIMEDOUT  on timeout.
+ */
+static int al_eth_mdio_lock(struct al_hw_eth_adapter *adapter)
+{
+	int count = 0;
+	u32 mdio_ctrl_1;
+
+	if (!adapter->shared_mdio_if)
+		return 0; /* nothing to do when interface is not shared */
+
+	do {
+		mdio_ctrl_1 = readl(&adapter->mac_regs_base->gen.mdio_ctrl_1);
+		if (mdio_ctrl_1 & BIT(0)) {
+			if (count > 0)
+				netdev_dbg(adapter->netdev,
+					   "eth %s mdio interface still busy!\n",
+					   adapter->name);
+		} else {
+			return 0;
+		}
+		udelay(AL_ETH_MDIO_DELAY_PERIOD);
+	} while (count++ < (AL_ETH_MDIO_DELAY_COUNT * 4));
+
+	netdev_err(adapter->netdev,
+		   " %s mdio failed to take ownership. MDIO info reg: 0x%08x\n",
+		   adapter->name, readl(&adapter->mac_regs_base->gen.mdio_1));
+
+	return -ETIMEDOUT;
+}
+
+/*
+ * free mdio interface ownership
+ * when mdio interface shared between multiple eth controllers, this function releases the ownership granted for this controller.
+ * this function does nothing when the mdio interface is used only by this controller.
+ *
+ * @param adapter
+ * @return 0.
+ */
+static int al_eth_mdio_free(struct al_hw_eth_adapter *adapter)
+{
+	if (!adapter->shared_mdio_if)
+		return 0; /* nothing to do when interface is not shared */
+
+	writel(0, &adapter->mac_regs_base->gen.mdio_ctrl_1);
+
+	/*
+	 * Addressing RMN: 2917
+	 *
+	 * RMN description:
+	 * The HW spin-lock is stateless and doesn't maintain any scheduling
+	 * policy.
+	 *
+	 * Software flow:
+	 * After getting the lock wait 2 times the delay period in order to give
+	 * the other port chance to take the lock and prevent starvation.
+	 * This is not scalable to more than two ports.
+	 */
+	udelay(2 * AL_ETH_MDIO_DELAY_PERIOD);
+
+	return 0;
+}
+
+int al_eth_mdio_read(struct al_hw_eth_adapter *adapter, u32 phy_addr,
+		     u32 device, u32 reg, u16 *val)
+{
+	int rc = al_eth_mdio_lock(adapter);
+
+	if (rc)
+		return rc;
+
+	if (adapter->mdio_if == AL_ETH_MDIO_IF_1G_MAC)
+		al_eth_mdio_1g_mac_read(adapter, phy_addr, reg, val);
+	else
+		if (adapter->mdio_type == AL_ETH_MDIO_TYPE_CLAUSE_22)
+			rc = al_eth_mdio_10g_mac_type22(adapter, 1, phy_addr,
+							reg, val);
+		else
+			rc = al_eth_mdio_10g_mac_type45(adapter, 1, phy_addr,
+							device, reg, val);
+
+	al_eth_mdio_free(adapter);
+
+	netdev_dbg(adapter->netdev,
+		   "eth mdio read: phy_addr %x, device %x, reg %x val %x\n",
+		   phy_addr, device, reg, *val);
+	return rc;
+}
+
+int al_eth_mdio_write(struct al_hw_eth_adapter *adapter, u32 phy_addr,
+		      u32 device, u32 reg, u16 val)
+{
+	int rc;
+
+	netdev_dbg(adapter->netdev,
+		   "eth mdio write: phy_addr %x, device %x, reg %x, val %x\n",
+		   phy_addr, device, reg, val);
+
+	rc = al_eth_mdio_lock(adapter);
+	/* interface ownership taken */
+	if (rc)
+		return rc;
+
+	if (adapter->mdio_if == AL_ETH_MDIO_IF_1G_MAC) {
+		al_eth_mdio_1g_mac_write(adapter, phy_addr, reg, val);
+	} else {
+		if (adapter->mdio_type == AL_ETH_MDIO_TYPE_CLAUSE_22)
+			rc = al_eth_mdio_10g_mac_type22(adapter, 0, phy_addr,
+							reg, &val);
+		else
+			rc = al_eth_mdio_10g_mac_type45(adapter, 0, phy_addr,
+							device, reg, &val);
+	}
+
+	al_eth_mdio_free(adapter);
+	return rc;
+}
+
+static void al_dump_tx_desc(struct al_hw_eth_adapter *adapter,
+			    union al_udma_desc *tx_desc)
+{
+	u32 *ptr = (u32 *)tx_desc;
+
+	netdev_dbg(adapter->netdev,
+		   "eth tx desc:\n0x%08x\n0x%08x\n0x%08x\n0x%08x\n",
+		   ptr[0], ptr[1], ptr[2], ptr[3]);
+}
+
+static void al_dump_tx_pkt(struct al_hw_eth_adapter *adapter,
+			   struct al_udma_q *tx_dma_q, struct al_eth_pkt *pkt)
+{
+	const char *tso = (pkt->flags & AL_ETH_TX_FLAGS_TSO) ? "TSO" : "";
+	const char *l3_csum = (pkt->flags & AL_ETH_TX_FLAGS_IPV4_L3_CSUM) ? "L3 CSUM" : "";
+	const char *l4_csum = (pkt->flags & AL_ETH_TX_FLAGS_L4_CSUM) ?
+	  ((pkt->flags & AL_ETH_TX_FLAGS_L4_PARTIAL_CSUM) ? "L4 PARTIAL CSUM" : "L4 FULL CSUM") : "";
+	const char *fcs = (pkt->flags & AL_ETH_TX_FLAGS_L2_DIS_FCS) ? "Disable FCS" : "";
+	const char *ptp = (pkt->flags & AL_ETH_TX_FLAGS_TS) ? "TX_PTP" : "";
+	const char *l3_proto_name = "unknown";
+	const char *l4_proto_name = "unknown";
+	const char *outer_l3_proto_name = "N/A";
+	const char *tunnel_mode = ((pkt->tunnel_mode) &
+				(AL_ETH_TUNNEL_WITH_UDP == AL_ETH_TUNNEL_WITH_UDP)) ?
+				"TUNNEL_WITH_UDP" :
+				((pkt->tunnel_mode) &
+				(AL_ETH_TUNNEL_NO_UDP == AL_ETH_TUNNEL_NO_UDP)) ?
+				"TUNNEL_NO_UDP" : "";
+	u32 total_len = 0;
+	int i;
+
+	netdev_dbg(adapter->netdev, "[%s %d]: flags: %s %s %s %s %s %s\n",
+		   tx_dma_q->udma->name, tx_dma_q->qid, tso, l3_csum, l4_csum,
+		   fcs, ptp, tunnel_mode);
+
+	switch (pkt->l3_proto_idx) {
+	case AL_ETH_PROTO_ID_IPv4:
+		l3_proto_name = "IPv4";
+		break;
+	case AL_ETH_PROTO_ID_IPv6:
+		l3_proto_name = "IPv6";
+		break;
+	default:
+		l3_proto_name = "unknown";
+		break;
+	}
+
+	switch (pkt->l4_proto_idx) {
+	case AL_ETH_PROTO_ID_TCP:
+		l4_proto_name = "TCP";
+		break;
+	case AL_ETH_PROTO_ID_UDP:
+		l4_proto_name = "UDP";
+		break;
+	default:
+		l4_proto_name = "unknown";
+		break;
+	}
+
+	switch (pkt->outer_l3_proto_idx) {
+	case AL_ETH_PROTO_ID_IPv4:
+		outer_l3_proto_name = "IPv4";
+		break;
+	case AL_ETH_PROTO_ID_IPv6:
+		outer_l3_proto_name = "IPv6";
+		break;
+	default:
+		outer_l3_proto_name = "N/A";
+		break;
+	}
+
+	netdev_dbg(adapter->netdev,
+		   "[%s %d]: L3 proto: %d (%s). L4 proto: %d (%s). "
+		   "Outer_L3 proto: %d (%s). vlan source count %d. mod add %d. mod del %d\n",
+		   tx_dma_q->udma->name, tx_dma_q->qid, pkt->l3_proto_idx,
+		   l3_proto_name, pkt->l4_proto_idx, l4_proto_name,
+		   pkt->outer_l3_proto_idx, outer_l3_proto_name,
+		   pkt->source_vlan_count, pkt->vlan_mod_add_count,
+		   pkt->vlan_mod_del_count);
+
+	if (pkt->meta) {
+		const char *store = pkt->meta->store ? "Yes" : "No";
+		const char *ptp_val = (pkt->flags & AL_ETH_TX_FLAGS_TS) ? "Yes" : "No";
+
+		netdev_dbg(adapter->netdev,
+			   "[%s %d]: tx pkt with meta data. words valid %x\n",
+			   tx_dma_q->udma->name, tx_dma_q->qid,
+			   pkt->meta->words_valid);
+		netdev_dbg(adapter->netdev,
+			   "[%s %d]: meta: store to cache %s. l3 hdr len %d. l3 hdr offset %d. "
+			   "l4 hdr len %d. mss val %d ts_index %d ts_val:%s\n",
+			   tx_dma_q->udma->name, tx_dma_q->qid, store,
+			   pkt->meta->l3_header_len,
+			   pkt->meta->l3_header_offset,
+			   pkt->meta->l4_header_len, pkt->meta->mss_val,
+			   pkt->meta->ts_index, ptp_val);
+		netdev_dbg(adapter->netdev,
+			   "outer_l3_hdr_offset %d. outer_l3_len %d.\n",
+			   pkt->meta->outer_l3_offset, pkt->meta->outer_l3_len);
+	}
+
+	netdev_dbg(adapter->netdev, "[%s %d]: num of bufs: %d\n",
+		   tx_dma_q->udma->name, tx_dma_q->qid, pkt->num_of_bufs);
+	for (i = 0; i < pkt->num_of_bufs; i++) {
+		netdev_dbg(adapter->netdev,
+			   "eth [%s %d]: buf[%d]: len 0x%08x. address 0x%016llx\n",
+			   tx_dma_q->udma->name, tx_dma_q->qid,
+			   i, pkt->bufs[i].len,
+			   (unsigned long long)pkt->bufs[i].addr);
+		total_len += pkt->bufs[i].len;
+	}
+
+	netdev_dbg(adapter->netdev, "[%s %d]: total len: 0x%08x\n",
+		   tx_dma_q->udma->name, tx_dma_q->qid, total_len);
+
+}
+
+/* add packet to transmission queue */
+int al_eth_tx_pkt_prepare(struct al_hw_eth_adapter *adapter,
+			  struct al_udma_q *tx_dma_q, struct al_eth_pkt *pkt)
+{
+	union al_udma_desc *tx_desc;
+	u32 tx_descs;
+	u32 flags = AL_M2S_DESC_FIRST | AL_M2S_DESC_CONCAT |
+		    (pkt->flags & AL_ETH_TX_FLAGS_INT);
+	u64 tgtid = ((u64)pkt->tgtid) << AL_UDMA_DESC_TGTID_SHIFT;
+	u32 meta_ctrl;
+	u32 ring_id;
+	int buf_idx;
+
+	netdev_dbg(adapter->netdev, "[%s %d]: new tx pkt\n",
+		   tx_dma_q->udma->name, tx_dma_q->qid);
+
+	al_dump_tx_pkt(adapter, tx_dma_q, pkt);
+
+	tx_descs = pkt->num_of_bufs;
+	if (pkt->meta)
+		tx_descs += 1;
+
+	if (unlikely(al_udma_available_get(tx_dma_q) < tx_descs)) {
+		netdev_dbg(adapter->netdev,
+			   "[%s %d]: failed to allocate (%d) descriptors",
+			   tx_dma_q->udma->name, tx_dma_q->qid, tx_descs);
+		return 0;
+	}
+
+	if (pkt->meta) {
+		u32 meta_word_0 = 0;
+		u32 meta_word_1 = 0;
+		u32 meta_word_2 = 0;
+		u32 meta_word_3 = 0;
+
+		meta_word_0 |= flags | AL_M2S_DESC_META_DATA;
+		meta_word_0 &=  ~AL_M2S_DESC_CONCAT;
+		flags &= ~(AL_M2S_DESC_FIRST | AL_ETH_TX_FLAGS_INT);
+
+		tx_desc = al_udma_desc_get(tx_dma_q);
+		/* get ring id, and clear FIRST and Int flags */
+		ring_id = al_udma_ring_id_get(tx_dma_q) <<
+			AL_M2S_DESC_RING_ID_SHIFT;
+
+		meta_word_0 |= ring_id;
+		meta_word_0 |= pkt->meta->words_valid << 12;
+
+		if (pkt->meta->store)
+			meta_word_0 |= AL_ETH_TX_META_STORE;
+
+		if (pkt->meta->words_valid & 1) {
+			meta_word_0 |= pkt->meta->vlan1_cfi_sel;
+			meta_word_0 |= pkt->meta->vlan2_vid_sel << 2;
+			meta_word_0 |= pkt->meta->vlan2_cfi_sel << 4;
+			meta_word_0 |= pkt->meta->vlan2_pbits_sel << 6;
+			meta_word_0 |= pkt->meta->vlan2_ether_sel << 8;
+		}
+
+		if (pkt->meta->words_valid & 2) {
+			meta_word_1 = pkt->meta->vlan1_new_vid;
+			meta_word_1 |= pkt->meta->vlan1_new_cfi << 12;
+			meta_word_1 |= pkt->meta->vlan1_new_pbits << 13;
+			meta_word_1 |= pkt->meta->vlan2_new_vid << 16;
+			meta_word_1 |= pkt->meta->vlan2_new_cfi << 28;
+			meta_word_1 |= pkt->meta->vlan2_new_pbits << 29;
+		}
+
+		if (pkt->meta->words_valid & 4) {
+			u32 l3_offset;
+
+			meta_word_2 = pkt->meta->l3_header_len & AL_ETH_TX_META_L3_LEN_MASK;
+			meta_word_2 |= (pkt->meta->l3_header_offset & AL_ETH_TX_META_L3_OFF_MASK) <<
+				AL_ETH_TX_META_L3_OFF_SHIFT;
+			meta_word_2 |= (pkt->meta->l4_header_len & 0x3f) << 16;
+
+			if (unlikely(pkt->flags & AL_ETH_TX_FLAGS_TS))
+				meta_word_0 |= pkt->meta->ts_index <<
+					AL_ETH_TX_META_MSS_MSB_TS_VAL_SHIFT;
+			else
+				meta_word_0 |= (((pkt->meta->mss_val & 0x3c00) >> 10)
+						<< AL_ETH_TX_META_MSS_MSB_TS_VAL_SHIFT);
+			meta_word_2 |= ((pkt->meta->mss_val & 0x03ff)
+					<< AL_ETH_TX_META_MSS_LSB_VAL_SHIFT);
+
+			/*
+			 * move from bytes to multiplication of 2 as the HW
+			 * expect to get it
+			 */
+			l3_offset = (pkt->meta->outer_l3_offset >> 1);
+
+			meta_word_0 |=
+				(((l3_offset &
+				   AL_ETH_TX_META_OUTER_L3_OFF_HIGH_MASK) >> 3)
+				   << AL_ETH_TX_META_OUTER_L3_OFF_HIGH_SHIFT);
+
+			meta_word_3 |=
+				((l3_offset &
+				   AL_ETH_TX_META_OUTER_L3_OFF_LOW_MASK)
+				   << AL_ETH_TX_META_OUTER_L3_OFF_LOW_SHIFT);
+
+			/*
+			 * shift right 2 bits to work in multiplication of 4
+			 * as the HW expect to get it
+			 */
+			meta_word_3 |=
+				(((pkt->meta->outer_l3_len >> 2) &
+				   AL_ETH_TX_META_OUTER_L3_LEN_MASK)
+				   << AL_ETH_TX_META_OUTER_L3_LEN_SHIFT);
+		}
+
+		tx_desc->tx_meta.len_ctrl = cpu_to_le32(meta_word_0);
+		tx_desc->tx_meta.meta_ctrl = cpu_to_le32(meta_word_1);
+		tx_desc->tx_meta.meta1 = cpu_to_le32(meta_word_2);
+		tx_desc->tx_meta.meta2 = cpu_to_le32(meta_word_3);
+		al_dump_tx_desc(adapter, tx_desc);
+	}
+
+	meta_ctrl = pkt->flags & AL_ETH_TX_PKT_META_FLAGS;
+
+	meta_ctrl |= pkt->l3_proto_idx;
+	meta_ctrl |= pkt->l4_proto_idx << AL_ETH_TX_L4_PROTO_IDX_SHIFT;
+	meta_ctrl |= pkt->source_vlan_count << AL_ETH_TX_SRC_VLAN_CNT_SHIFT;
+	meta_ctrl |= pkt->vlan_mod_add_count << AL_ETH_TX_VLAN_MOD_ADD_SHIFT;
+	meta_ctrl |= pkt->vlan_mod_del_count << AL_ETH_TX_VLAN_MOD_DEL_SHIFT;
+	meta_ctrl |= pkt->vlan_mod_v1_ether_sel << AL_ETH_TX_VLAN_MOD_E_SEL_SHIFT;
+	meta_ctrl |= pkt->vlan_mod_v1_vid_sel << AL_ETH_TX_VLAN_MOD_VID_SEL_SHIFT;
+	meta_ctrl |= pkt->vlan_mod_v1_pbits_sel << AL_ETH_TX_VLAN_MOD_PBIT_SEL_SHIFT;
+
+	meta_ctrl |= pkt->tunnel_mode << AL_ETH_TX_TUNNEL_MODE_SHIFT;
+	if (pkt->outer_l3_proto_idx == AL_ETH_PROTO_ID_IPv4)
+		meta_ctrl |= BIT(AL_ETH_TX_OUTER_L3_PROTO_SHIFT);
+
+	flags |= pkt->flags & AL_ETH_TX_PKT_UDMA_FLAGS;
+	for (buf_idx = 0; buf_idx < pkt->num_of_bufs; buf_idx++) {
+		u32 flags_len = flags;
+
+		tx_desc = al_udma_desc_get(tx_dma_q);
+		/* get ring id, and clear FIRST and Int flags */
+		ring_id = al_udma_ring_id_get(tx_dma_q) <<
+			AL_M2S_DESC_RING_ID_SHIFT;
+
+		flags_len |= ring_id;
+
+		if (buf_idx == (pkt->num_of_bufs - 1))
+			flags_len |= AL_M2S_DESC_LAST;
+
+		/* clear First and Int flags */
+		flags &= AL_ETH_TX_FLAGS_NO_SNOOP;
+		flags |= AL_M2S_DESC_CONCAT;
+
+		flags_len |= pkt->bufs[buf_idx].len & AL_M2S_DESC_LEN_MASK;
+		tx_desc->tx.len_ctrl = cpu_to_le32(flags_len);
+		if (buf_idx == 0)
+			tx_desc->tx.meta_ctrl = cpu_to_le32(meta_ctrl);
+		tx_desc->tx.buf_ptr = cpu_to_le64(
+			pkt->bufs[buf_idx].addr | tgtid);
+		al_dump_tx_desc(adapter, tx_desc);
+	}
+
+	netdev_dbg(adapter->netdev,
+		   "[%s %d]: pkt descriptors written into the tx queue. descs num (%d)\n",
+		   tx_dma_q->udma->name, tx_dma_q->qid, tx_descs);
+
+	return tx_descs;
+}
+
+void al_eth_tx_dma_action(struct al_udma_q *tx_dma_q, u32 tx_descs)
+{
+	/* add tx descriptors */
+	al_udma_desc_action_add(tx_dma_q, tx_descs);
+}
+
+/* get number of completed tx descriptors, upper layer should derive from */
+int al_eth_comp_tx_get(struct al_hw_eth_adapter *adapter,
+		       struct al_udma_q *tx_dma_q)
+{
+	int rc;
+
+	rc = al_udma_cdesc_get_all(tx_dma_q, NULL);
+	if (rc != 0) {
+		al_udma_cdesc_ack(tx_dma_q, rc);
+		netdev_dbg(adapter->netdev,
+			   "[%s %d]: tx completion: descs (%d)\n",
+			   tx_dma_q->udma->name, tx_dma_q->qid, rc);
+	}
+
+	return rc;
+}
+
+/* add buffer to receive queue */
+int al_eth_rx_buffer_add(struct al_hw_eth_adapter *adapter,
+			 struct al_udma_q *rx_dma_q,
+			 struct al_buf *buf, u32 flags,
+			 struct al_buf *header_buf)
+{
+	u64 tgtid = ((u64)flags & AL_ETH_RX_FLAGS_TGTID_MASK) <<
+		AL_UDMA_DESC_TGTID_SHIFT;
+	u32 flags_len = flags & ~AL_ETH_RX_FLAGS_TGTID_MASK;
+	union al_udma_desc *rx_desc;
+
+	netdev_dbg(adapter->netdev, "[%s %d]: add rx buffer.\n",
+		   rx_dma_q->udma->name, rx_dma_q->qid);
+
+	if (unlikely(al_udma_available_get(rx_dma_q) < 1)) {
+		netdev_dbg(adapter->netdev,
+			   "[%s]: rx q (%d) has no enough free descriptor",
+			   rx_dma_q->udma->name, rx_dma_q->qid);
+		return -ENOSPC;
+	}
+
+	rx_desc = al_udma_desc_get(rx_dma_q);
+
+	flags_len |= al_udma_ring_id_get(rx_dma_q) << AL_S2M_DESC_RING_ID_SHIFT;
+	flags_len |= buf->len & AL_S2M_DESC_LEN_MASK;
+
+	if (flags & AL_S2M_DESC_DUAL_BUF) {
+		WARN_ON(!header_buf); /*header valid in dual buf */
+		WARN_ON((rx_dma_q->udma->rev_id < AL_UDMA_REV_ID_2) &&
+		       (AL_ADDR_HIGH(buf->addr) != AL_ADDR_HIGH(header_buf->addr)));
+
+		flags_len |= ((header_buf->len >> AL_S2M_DESC_LEN2_GRANULARITY_SHIFT)
+			<< AL_S2M_DESC_LEN2_SHIFT) & AL_S2M_DESC_LEN2_MASK;
+		rx_desc->rx.buf2_ptr_lo = cpu_to_le32(AL_ADDR_LOW(header_buf->addr));
+	}
+	rx_desc->rx.len_ctrl = cpu_to_le32(flags_len);
+	rx_desc->rx.buf1_ptr = cpu_to_le64(buf->addr | tgtid);
+
+	return 0;
+}
+
+/* notify the hw engine about rx descriptors that were added to the receive queue */
+void al_eth_rx_buffer_action(struct al_hw_eth_adapter *adapter,
+			     struct al_udma_q *rx_dma_q, u32 descs_num)
+{
+	netdev_dbg(adapter->netdev,
+		   "[%s]: update the rx engine tail pointer: queue %d. descs %d\n",
+		   rx_dma_q->udma->name, rx_dma_q->qid, descs_num);
+
+	/* add rx descriptor */
+	al_udma_desc_action_add(rx_dma_q, descs_num);
+}
+
+/* get packet from RX completion ring */
+u32 al_eth_pkt_rx(struct al_hw_eth_adapter *adapter, struct al_udma_q *rx_dma_q,
+		  struct al_eth_pkt *pkt)
+{
+	volatile union al_udma_cdesc *cdesc;
+	volatile struct al_eth_rx_cdesc *rx_desc;
+	u32 i, rc = al_udma_cdesc_packet_get(rx_dma_q, &cdesc);
+
+	if (rc == 0)
+		return 0;
+
+	WARN_ON(rc > AL_ETH_PKT_MAX_BUFS);
+
+	netdev_dbg(adapter->netdev, "[%s]: fetch rx packet: queue %d.\n",
+		   rx_dma_q->udma->name, rx_dma_q->qid);
+
+	pkt->rx_header_len = 0;
+	for (i = 0; i < rc; i++) {
+		u32 buf1_len, buf2_len;
+
+		/* get next descriptor */
+		rx_desc = (volatile struct al_eth_rx_cdesc *)al_cdesc_next(rx_dma_q,
+									   cdesc,
+									   i);
+
+		buf1_len = le32_to_cpu(rx_desc->len);
+
+		if ((i == 0) && (le32_to_cpu(rx_desc->word2) &
+			AL_UDMA_CDESC_BUF2_USED)) {
+			buf2_len = le32_to_cpu(rx_desc->word2);
+			pkt->rx_header_len = (buf2_len & AL_S2M_DESC_LEN2_MASK) >>
+			AL_S2M_DESC_LEN2_SHIFT;
+		}
+		pkt->bufs[i].len = buf1_len & AL_S2M_DESC_LEN_MASK;
+	}
+	/* get flags from last desc */
+	pkt->flags = le32_to_cpu(rx_desc->ctrl_meta);
+
+	/* update L3/L4 proto index */
+	pkt->l3_proto_idx = pkt->flags & AL_ETH_RX_L3_PROTO_IDX_MASK;
+	pkt->l4_proto_idx = (pkt->flags >> AL_ETH_RX_L4_PROTO_IDX_SHIFT) &
+				AL_ETH_RX_L4_PROTO_IDX_MASK;
+	pkt->rxhash = (le32_to_cpu(rx_desc->len) & AL_ETH_RX_HASH_MASK) >>
+			AL_ETH_RX_HASH_SHIFT;
+	pkt->l3_offset = (le32_to_cpu(rx_desc->word2) & AL_ETH_RX_L3_OFFSET_MASK) >>
+		AL_ETH_RX_L3_OFFSET_SHIFT;
+
+	al_udma_cdesc_ack(rx_dma_q, rc);
+	return rc;
+}
+
+#define AL_ETH_THASH_UDMA_SHIFT		0
+#define AL_ETH_THASH_UDMA_MASK		(0xF << AL_ETH_THASH_UDMA_SHIFT)
+
+#define AL_ETH_THASH_Q_SHIFT		4
+#define AL_ETH_THASH_Q_MASK		(0x3 << AL_ETH_THASH_Q_SHIFT)
+
+int al_eth_thash_table_set(struct al_hw_eth_adapter *adapter, u32 idx, u8 udma,
+			   u32 queue)
+{
+	u32 entry;
+
+	WARN_ON(idx >= AL_ETH_RX_THASH_TABLE_SIZE); /* valid THASH index */
+
+	entry = (udma << AL_ETH_THASH_UDMA_SHIFT) & AL_ETH_THASH_UDMA_MASK;
+	entry |= (queue << AL_ETH_THASH_Q_SHIFT) & AL_ETH_THASH_Q_MASK;
+
+	writel(idx, &adapter->ec_regs_base->rfw.thash_table_addr);
+	writel(entry, &adapter->ec_regs_base->rfw.thash_table_data);
+	return 0;
+}
+
+int al_eth_fsm_table_set(struct al_hw_eth_adapter *adapter, u32 idx, u32 entry)
+{
+	WARN_ON(idx >= AL_ETH_RX_FSM_TABLE_SIZE); /* valid FSM index */
+
+	writel(idx, &adapter->ec_regs_base->rfw.fsm_table_addr);
+	writel(entry, &adapter->ec_regs_base->rfw.fsm_table_data);
+	return 0;
+}
+
+static u32 al_eth_fwd_ctrl_entry_to_val(struct al_eth_fwd_ctrl_table_entry *entry)
+{
+	u32 val = 0;
+
+	val &= ~GENMASK(3, 0);
+	val |= (entry->prio_sel << 0) & GENMASK(3, 0);
+	val &= ~GENMASK(7, 4);
+	val |= (entry->queue_sel_1 << 4) & GENMASK(7, 4);
+	val &= ~GENMASK(9, 8);
+	val |= (entry->queue_sel_2 << 8) & GENMASK(9, 8);
+	val &= ~GENMASK(13, 10);
+	val |= (entry->udma_sel << 10) & GENMASK(13, 10);
+	val &= ~GENMASK(17, 15);
+	val |= (!!entry->filter << 19);
+
+	return val;
+}
+
+void al_eth_ctrl_table_def_set(struct al_hw_eth_adapter *adapter,
+			       bool use_table,
+			       struct al_eth_fwd_ctrl_table_entry *entry)
+{
+	u32 val = al_eth_fwd_ctrl_entry_to_val(entry);
+
+	if (use_table)
+		val |= EC_RFW_CTRL_TABLE_DEF_SEL;
+
+	writel(val, &adapter->ec_regs_base->rfw.ctrl_table_def);
+}
+
+void al_eth_hash_key_set(struct al_hw_eth_adapter *adapter, u32 idx, u32 val)
+{
+	writel(val, &adapter->ec_regs_base->rfw_hash[idx].key);
+}
+
+static u32 al_eth_fwd_mac_table_entry_to_val(struct al_eth_fwd_mac_table_entry *entry)
+{
+	u32 val = 0;
+
+	val |= entry->filter ? EC_FWD_MAC_CTRL_RX_VAL_DROP : 0;
+	val |= ((entry->udma_mask << EC_FWD_MAC_CTRL_RX_VAL_UDMA_SHIFT) &
+					EC_FWD_MAC_CTRL_RX_VAL_UDMA_MASK);
+
+	val |= ((entry->qid << EC_FWD_MAC_CTRL_RX_VAL_QID_SHIFT) &
+					EC_FWD_MAC_CTRL_RX_VAL_QID_MASK);
+
+	val |= entry->rx_valid ? EC_FWD_MAC_CTRL_RX_VALID : 0;
+
+	val |= ((entry->tx_target << EC_FWD_MAC_CTRL_TX_VAL_SHIFT) &
+					EC_FWD_MAC_CTRL_TX_VAL_MASK);
+
+	val |= entry->tx_valid ? EC_FWD_MAC_CTRL_TX_VALID : 0;
+
+	return val;
+}
+
+void al_eth_fwd_mac_table_set(struct al_hw_eth_adapter *adapter, u32 idx,
+			      struct al_eth_fwd_mac_table_entry *entry)
+{
+	u32 val;
+
+	WARN_ON(idx >= AL_ETH_FWD_MAC_NUM);
+
+	val = (entry->addr[2] << 24) | (entry->addr[3] << 16) |
+	      (entry->addr[4] << 8) | entry->addr[5];
+	writel(val, &adapter->ec_regs_base->fwd_mac[idx].data_l);
+	val = (entry->addr[0] << 8) | entry->addr[1];
+	writel(val, &adapter->ec_regs_base->fwd_mac[idx].data_h);
+	val = (entry->mask[2] << 24) | (entry->mask[3] << 16) |
+	      (entry->mask[4] << 8) | entry->mask[5];
+	writel(val, &adapter->ec_regs_base->fwd_mac[idx].mask_l);
+	val = (entry->mask[0] << 8) | entry->mask[1];
+	writel(val, &adapter->ec_regs_base->fwd_mac[idx].mask_h);
+
+	val = al_eth_fwd_mac_table_entry_to_val(entry);
+	writel(val, &adapter->ec_regs_base->fwd_mac[idx].ctrl);
+}
+
+void al_eth_mac_addr_store(void * __iomem ec_base, u32 idx, u8 *addr)
+{
+	struct al_ec_regs __iomem *ec_regs_base =
+		(struct al_ec_regs __iomem *)ec_base;
+	u32 val;
+
+	val = (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) | addr[5];
+	writel(val, &ec_regs_base->fwd_mac[idx].data_l);
+	val = (addr[0] << 8) | addr[1];
+	writel(val, &ec_regs_base->fwd_mac[idx].data_h);
+}
+
+void al_eth_mac_addr_read(void * __iomem ec_base, u32 idx, u8 *addr)
+{
+	struct al_ec_regs __iomem *ec_regs_base =
+		(struct al_ec_regs __iomem *)ec_base;
+	u32 addr_lo = readl(&ec_regs_base->fwd_mac[idx].data_l);
+	u16 addr_hi = readl(&ec_regs_base->fwd_mac[idx].data_h);
+
+	addr[5] = addr_lo & 0xff;
+	addr[4] = (addr_lo >> 8) & 0xff;
+	addr[3] = (addr_lo >> 16) & 0xff;
+	addr[2] = (addr_lo >> 24) & 0xff;
+	addr[1] = addr_hi & 0xff;
+	addr[0] = (addr_hi >> 8) & 0xff;
+}
+
+void al_eth_fwd_pbits_table_set(struct al_hw_eth_adapter *adapter, u32 idx, u8 prio)
+{
+	WARN_ON(idx >= AL_ETH_FWD_PBITS_TABLE_NUM); /* valid PBIT index */
+	WARN_ON(prio >= AL_ETH_FWD_PRIO_TABLE_NUM); /* valid PRIO index */
+
+	writel(idx, &adapter->ec_regs_base->rfw.pbits_table_addr);
+	writel(prio, &adapter->ec_regs_base->rfw.pbits_table_data);
+}
+
+void al_eth_fwd_priority_table_set(struct al_hw_eth_adapter *adapter, u8 prio, u8 qid)
+{
+	WARN_ON(prio >= AL_ETH_FWD_PRIO_TABLE_NUM); /* valid PRIO index */
+
+	writel(qid, &adapter->ec_regs_base->rfw_priority[prio].queue);
+}
+
+#define AL_ETH_RFW_FILTER_SUPPORTED(rev_id)	\
+	(AL_ETH_RFW_FILTER_UNDET_MAC | \
+	AL_ETH_RFW_FILTER_DET_MAC | \
+	AL_ETH_RFW_FILTER_TAGGED | \
+	AL_ETH_RFW_FILTER_UNTAGGED | \
+	AL_ETH_RFW_FILTER_BC | \
+	AL_ETH_RFW_FILTER_MC | \
+	AL_ETH_RFW_FILTER_VLAN_VID | \
+	AL_ETH_RFW_FILTER_CTRL_TABLE | \
+	AL_ETH_RFW_FILTER_PROT_INDEX | \
+	AL_ETH_RFW_FILTER_WOL | \
+	AL_ETH_RFW_FILTER_PARSE)
+
+/* Configure the receive filters */
+int al_eth_filter_config(struct al_hw_eth_adapter *adapter,
+			 struct al_eth_filter_params *params)
+{
+	u32 reg;
+
+	if (params->filters & ~(AL_ETH_RFW_FILTER_SUPPORTED(adapter->rev_id))) {
+		netdev_err(adapter->netdev,
+			   "[%s]: unsupported filter options (0x%08x)\n",
+			   adapter->name, params->filters);
+		return -EINVAL;
+	}
+
+	reg = readl(&adapter->ec_regs_base->rfw.out_cfg);
+
+	if (params->enable)
+		reg |= EC_RFW_OUT_CFG_DROP_EN;
+	else
+		reg &= ~EC_RFW_OUT_CFG_DROP_EN;
+
+	writel(reg, &adapter->ec_regs_base->rfw.out_cfg);
+
+	reg = readl(&adapter->ec_regs_base->rfw.filter);
+	reg &= ~AL_ETH_RFW_FILTER_SUPPORTED(adapter->rev_id);
+	reg |= params->filters;
+	writel(reg, &adapter->ec_regs_base->rfw.filter);
+
+	if (params->filters & AL_ETH_RFW_FILTER_PROT_INDEX) {
+		int i;
+
+		for (i = 0; i < AL_ETH_PROTOCOLS_NUM; i++) {
+			reg = readl(&adapter->ec_regs_base->epe_a[i].prot_act);
+			if (params->filter_proto[i])
+				reg |= EC_EPE_A_PROT_ACT_DROP;
+			else
+				reg &= ~EC_EPE_A_PROT_ACT_DROP;
+			writel(reg, &adapter->ec_regs_base->epe_a[i].prot_act);
+		}
+	}
+
+	return 0;
+}
+
+int al_eth_flow_control_config(struct al_hw_eth_adapter *adapter,
+			       struct al_eth_flow_control_params *params)
+{
+	u32 reg;
+	int i;
+
+	WARN_ON(!params); /* valid params pointer */
+
+	switch (params->type) {
+	case AL_ETH_FLOW_CONTROL_TYPE_LINK_PAUSE:
+		netdev_dbg(adapter->netdev,
+			   "[%s]: config flow control to link pause mode.\n",
+			   adapter->name);
+
+		/* config the mac */
+		if (AL_ETH_IS_1G_MAC(adapter->mac_mode)) {
+			/* set quanta value */
+			writel(params->quanta,
+			       &adapter->mac_regs_base->mac_1g.pause_quant);
+			writel(params->quanta_th,
+			       &adapter->ec_regs_base->efc.xoff_timer_1g);
+
+		} else if (AL_ETH_IS_10G_MAC(adapter->mac_mode) ||
+			   AL_ETH_IS_25G_MAC(adapter->mac_mode)) {
+			/* set quanta value */
+			writel(params->quanta,
+			       &adapter->mac_regs_base->mac_10g.cl01_pause_quanta);
+			/* set quanta threshold value */
+			writel(params->quanta_th,
+			       &adapter->mac_regs_base->mac_10g.cl01_quanta_thresh);
+		} else {
+			/* set quanta value */
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL01_PAUSE_QUANTA_ADDR,
+						 params->quanta);
+			/* set quanta threshold value */
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL01_QUANTA_THRESH_ADDR,
+						 params->quanta_th);
+		}
+
+		if (params->obay_enable)
+			/* Tx path FIFO, unmask pause_on from MAC when PAUSE packet received */
+			writel(1, &adapter->ec_regs_base->efc.ec_pause);
+		else
+			writel(0, &adapter->ec_regs_base->efc.ec_pause);
+
+		/* Rx path */
+		if (params->gen_enable)
+			/* enable generating xoff from ec fifo almost full indication in hysteresis mode */
+			writel(BIT(EC_EFC_EC_XOFF_MASK_2_SHIFT),
+			       &adapter->ec_regs_base->efc.ec_xoff);
+		else
+			writel(0, &adapter->ec_regs_base->efc.ec_xoff);
+
+		if (AL_ETH_IS_1G_MAC(adapter->mac_mode))
+			/* in 1G mode, enable generating xon from ec fifo in hysteresis mode*/
+			writel(EC_EFC_XON_MASK_2 | EC_EFC_XON_MASK_1,
+			       &adapter->ec_regs_base->efc.xon);
+
+		/* set hysteresis mode thresholds */
+		writel(params->rx_fifo_th_low | (params->rx_fifo_th_high << EC_EFC_RX_FIFO_HYST_TH_HIGH_SHIFT),
+		       &adapter->ec_regs_base->efc.rx_fifo_hyst);
+
+		for (i = 0; i < 4; i++) {
+			if (params->obay_enable)
+				/* Tx path UDMA, unmask pause_on for all queues */
+				writel(params->prio_q_map[i][0],
+				       &adapter->ec_regs_base->fc_udma[i].q_pause_0);
+			else
+				writel(0,
+				       &adapter->ec_regs_base->fc_udma[i].q_pause_0);
+
+			if (params->gen_enable)
+				/* Rx path UDMA, enable generating xoff from UDMA queue almost full indication */
+				writel(params->prio_q_map[i][0],
+				       &adapter->ec_regs_base->fc_udma[i].q_xoff_0);
+			else
+				writel(0,
+				       &adapter->ec_regs_base->fc_udma[i].q_xoff_0);
+		}
+	break;
+	case AL_ETH_FLOW_CONTROL_TYPE_PFC:
+		netdev_dbg(adapter->netdev,
+			   "[%s]: config flow control to PFC mode.\n",
+			   adapter->name);
+		WARN_ON(!!AL_ETH_IS_1G_MAC(adapter->mac_mode)); /* pfc not available for RGMII mode */
+
+		for (i = 0; i < 4; i++) {
+			int prio;
+
+			for (prio = 0; prio < 8; prio++) {
+				if (params->obay_enable)
+					/* Tx path UDMA, unmask pause_on for all queues */
+					writel(params->prio_q_map[i][prio],
+					       &adapter->ec_regs_base->fc_udma[i].q_pause_0 + prio);
+				else
+					writel(0,
+					       &adapter->ec_regs_base->fc_udma[i].q_pause_0 + prio);
+
+				if (params->gen_enable)
+					writel(params->prio_q_map[i][prio],
+					       &adapter->ec_regs_base->fc_udma[i].q_xoff_0 + prio);
+				else
+					writel(0,
+					       &adapter->ec_regs_base->fc_udma[i].q_xoff_0 + prio);
+			}
+		}
+
+		/* Rx path */
+		/* enable generating xoff from ec fifo almost full indication in hysteresis mode */
+		if (params->gen_enable)
+			writel(0xFF << EC_EFC_EC_XOFF_MASK_2_SHIFT,
+			       &adapter->ec_regs_base->efc.ec_xoff);
+		else
+			writel(0, &adapter->ec_regs_base->efc.ec_xoff);
+
+		/* set hysteresis mode thresholds */
+		writel(params->rx_fifo_th_low | (params->rx_fifo_th_high << EC_EFC_RX_FIFO_HYST_TH_HIGH_SHIFT),
+		       &adapter->ec_regs_base->efc.rx_fifo_hyst);
+
+		if (AL_ETH_IS_10G_MAC(adapter->mac_mode) || AL_ETH_IS_25G_MAC(adapter->mac_mode)) {
+			/* config the 10g_mac */
+			/* set quanta value (same value for all prios) */
+			reg = params->quanta | (params->quanta << 16);
+			writel(reg,
+			       &adapter->mac_regs_base->mac_10g.cl01_pause_quanta);
+			writel(reg,
+			       &adapter->mac_regs_base->mac_10g.cl23_pause_quanta);
+			writel(reg,
+			       &adapter->mac_regs_base->mac_10g.cl45_pause_quanta);
+			writel(reg,
+			       &adapter->mac_regs_base->mac_10g.cl67_pause_quanta);
+			/* set quanta threshold value (same value for all prios) */
+			reg = params->quanta_th | (params->quanta_th << 16);
+			writel(reg,
+			       &adapter->mac_regs_base->mac_10g.cl01_quanta_thresh);
+			writel(reg,
+			       &adapter->mac_regs_base->mac_10g.cl23_quanta_thresh);
+			writel(reg,
+			       &adapter->mac_regs_base->mac_10g.cl45_quanta_thresh);
+			writel(reg,
+			       &adapter->mac_regs_base->mac_10g.cl67_quanta_thresh);
+
+			/* enable PFC in the 10g_MAC */
+			reg = readl(&adapter->mac_regs_base->mac_10g.cmd_cfg);
+			reg |= BIT(19);
+			writel(reg, &adapter->mac_regs_base->mac_10g.cmd_cfg);
+		} else {
+			/* config the 40g_mac */
+			/* set quanta value (same value for all prios) */
+			reg = params->quanta | (params->quanta << 16);
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL01_PAUSE_QUANTA_ADDR, reg);
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL23_PAUSE_QUANTA_ADDR, reg);
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL45_PAUSE_QUANTA_ADDR, reg);
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL67_PAUSE_QUANTA_ADDR, reg);
+			/* set quanta threshold value (same value for all prios) */
+			reg = params->quanta_th | (params->quanta_th << 16);
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL01_QUANTA_THRESH_ADDR, reg);
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL23_QUANTA_THRESH_ADDR, reg);
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL45_QUANTA_THRESH_ADDR, reg);
+			al_eth_40g_mac_reg_write(adapter,
+						 ETH_MAC_GEN_V3_MAC_40G_CL67_QUANTA_THRESH_ADDR, reg);
+
+			/* enable PFC in the 40g_MAC */
+			reg = readl(&adapter->mac_regs_base->mac_10g.cmd_cfg);
+			reg |= BIT(19);
+			writel(reg, &adapter->mac_regs_base->mac_10g.cmd_cfg);
+			reg = al_eth_40g_mac_reg_read(adapter, ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_ADDR);
+
+			reg |= ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_PFC_MODE;
+
+			al_eth_40g_mac_reg_write(adapter, ETH_MAC_GEN_V3_MAC_40G_COMMAND_CONFIG_ADDR, reg);
+		}
+		break;
+	default:
+		netdev_err(adapter->netdev,
+			   "[%s]: unsupported flow control type %d\n",
+			   adapter->name, params->type);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* Traffic control */
+
+int al_eth_flr_rmn(int (*pci_read_config_u32)(void *handle, int where, u32 *val),
+		   int (*pci_write_config_u32)(void *handle, int where, u32 val),
+		   void *handle, void __iomem *mac_base)
+{
+	struct al_eth_mac_regs __iomem *mac_regs_base =
+		(struct	al_eth_mac_regs __iomem *)mac_base;
+	u32 cfg_reg_store[6];
+	u32 reg;
+	u32 mux_sel;
+	int i = 0;
+
+	(*pci_read_config_u32)(handle, AL_ADAPTER_GENERIC_CONTROL_0, &reg);
+
+	/* reset 1G mac */
+	reg |= AL_ADAPTER_GENERIC_CONTROL_0_ETH_RESET_1GMAC;
+	(*pci_write_config_u32)(handle, AL_ADAPTER_GENERIC_CONTROL_0, reg);
+	udelay(1000);
+	/* don't reset 1G mac */
+	reg &= ~AL_ADAPTER_GENERIC_CONTROL_0_ETH_RESET_1GMAC;
+	/* prevent 1G mac reset on FLR */
+	reg &= ~AL_ADAPTER_GENERIC_CONTROL_0_ETH_RESET_1GMAC_ON_FLR;
+	/* prevent adapter reset */
+	(*pci_write_config_u32)(handle, AL_ADAPTER_GENERIC_CONTROL_0, reg);
+
+	mux_sel = readl(&mac_regs_base->gen.mux_sel);
+
+	/* save pci register that get reset due to flr*/
+	(*pci_read_config_u32)(handle, AL_PCI_COMMAND, &cfg_reg_store[i++]);
+	(*pci_read_config_u32)(handle, 0xC, &cfg_reg_store[i++]);
+	(*pci_read_config_u32)(handle, 0x10, &cfg_reg_store[i++]);
+	(*pci_read_config_u32)(handle, 0x18, &cfg_reg_store[i++]);
+	(*pci_read_config_u32)(handle, 0x20, &cfg_reg_store[i++]);
+	(*pci_read_config_u32)(handle, 0x110, &cfg_reg_store[i++]);
+
+	/* do flr */
+	(*pci_write_config_u32)(handle, AL_PCI_EXP_CAP_BASE + AL_PCI_EXP_DEVCTL, AL_PCI_EXP_DEVCTL_BCR_FLR);
+	udelay(1000);
+	/* restore command */
+	i = 0;
+	(*pci_write_config_u32)(handle, AL_PCI_COMMAND, cfg_reg_store[i++]);
+	(*pci_write_config_u32)(handle, 0xC, cfg_reg_store[i++]);
+	(*pci_write_config_u32)(handle, 0x10, cfg_reg_store[i++]);
+	(*pci_write_config_u32)(handle, 0x18, cfg_reg_store[i++]);
+	(*pci_write_config_u32)(handle, 0x20, cfg_reg_store[i++]);
+	(*pci_write_config_u32)(handle, 0x110, cfg_reg_store[i++]);
+
+	writel((readl(&mac_regs_base->gen.mux_sel) & ~ETH_MAC_GEN_MUX_SEL_KR_IN_MASK) | mux_sel,
+	       &mac_regs_base->gen.mux_sel);
+
+	/* set SGMII clock to 125MHz */
+	writel(0x03320501, &mac_regs_base->sgmii.clk_div);
+
+	/* reset 1G mac */
+	reg |= AL_ADAPTER_GENERIC_CONTROL_0_ETH_RESET_1GMAC;
+	(*pci_write_config_u32)(handle, AL_ADAPTER_GENERIC_CONTROL_0, reg);
+
+	udelay(1000);
+
+	/* clear 1G mac reset */
+	reg &= ~AL_ADAPTER_GENERIC_CONTROL_0_ETH_RESET_1GMAC;
+	(*pci_write_config_u32)(handle, AL_ADAPTER_GENERIC_CONTROL_0, reg);
+
+	/* reset SGMII mac clock to default */
+	writel(0x00320501, &mac_regs_base->sgmii.clk_div);
+	udelay(1000);
+	/* reset async fifo */
+	reg = readl(&mac_regs_base->gen.sd_fifo_ctrl);
+	reg |= 0xF0;
+	writel(reg, &mac_regs_base->gen.sd_fifo_ctrl);
+	reg = readl(&mac_regs_base->gen.sd_fifo_ctrl);
+	reg &= ~0xF0;
+	writel(reg, &mac_regs_base->gen.sd_fifo_ctrl);
+
+	return 0;
+}
+
+/* board params register 1 */
+#define AL_HW_ETH_MEDIA_TYPE_MASK	(GENMASK(3, 0))
+#define AL_HW_ETH_MEDIA_TYPE_SHIFT	0
+#define AL_HW_ETH_EXT_PHY_SHIFT	4
+#define AL_HW_ETH_PHY_ADDR_MASK	(GENMASK(9, 5))
+#define AL_HW_ETH_PHY_ADDR_SHIFT	5
+#define AL_HW_ETH_SFP_EXIST_SHIFT	10
+#define AL_HW_ETH_AN_ENABLE_SHIFT	11
+#define AL_HW_ETH_KR_LT_ENABLE_SHIFT	12
+#define AL_HW_ETH_KR_FEC_ENABLE_SHIFT	13
+#define AL_HW_ETH_MDIO_FREQ_MASK	(GENMASK(15, 14))
+#define AL_HW_ETH_MDIO_FREQ_SHIFT	14
+#define AL_HW_ETH_I2C_ADAPTER_ID_MASK	(GENMASK(19, 16))
+#define AL_HW_ETH_I2C_ADAPTER_ID_SHIFT	16
+#define AL_HW_ETH_EXT_PHY_IF_MASK	(GENMASK(21, 20))
+#define AL_HW_ETH_EXT_PHY_IF_SHIFT	20
+#define AL_HW_ETH_AUTO_NEG_MODE_SHIFT	22
+#define AL_HW_ETH_REF_CLK_FREQ_MASK	(GENMASK(31, 29))
+#define AL_HW_ETH_REF_CLK_FREQ_SHIFT	29
+
+/* board params register 2 */
+#define AL_HW_ETH_1000_BASE_X_SHIFT		1
+#define AL_HW_ETH_1G_AN_DISABLE_SHIFT		2
+#define AL_HW_ETH_1G_SPEED_MASK		(GENMASK(4, 3))
+#define AL_HW_ETH_1G_SPEED_SHIFT		3
+#define AL_HW_ETH_1G_HALF_DUPLEX_SHIFT		5
+#define AL_HW_ETH_1G_FC_DISABLE_SHIFT		6
+#define AL_HW_ETH_RETIMER_EXIST_SHIFT		7
+#define AL_HW_ETH_RETIMER_BUS_ID_MASK		(GENMASK(11, 8))
+#define AL_HW_ETH_RETIMER_BUS_ID_SHIFT		8
+#define AL_HW_ETH_RETIMER_I2C_ADDR_MASK	(GENMASK(18, 12))
+#define AL_HW_ETH_RETIMER_I2C_ADDR_SHIFT	12
+#define AL_HW_ETH_RETIMER_CHANNEL_SHIFT	19
+#define AL_HW_ETH_DAC_LENGTH_MASK		(GENMASK(23, 20))
+#define AL_HW_ETH_DAC_LENGTH_SHIFT		20
+#define AL_HW_ETH_DAC_SHIFT			24
+#define AL_HW_ETH_RETIMER_TYPE_MASK		(GENMASK(26, 25))
+#define AL_HW_ETH_RETIMER_TYPE_SHIFT		25
+#define AL_HW_ETH_RETIMER_CHANNEL_2_MASK	(GENMASK(28, 27))
+#define AL_HW_ETH_RETIMER_CHANNEL_2_SHIFT	27
+#define AL_HW_ETH_RETIMER_TX_CHANNEL_MASK	(GENMASK(31, 29))
+#define AL_HW_ETH_RETIMER_TX_CHANNEL_SHIFT	29
+
+/* board params register 3 */
+#define AL_HW_ETH_GPIO_SFP_PRESENT_MASK	(GENMASK(5, 0))
+#define AL_HW_ETH_GPIO_SFP_PRESENT_SHIFT	0
+
+int al_eth_board_params_set(void * __iomem mac_base,
+			    struct al_eth_board_params *params)
+{
+	struct al_eth_mac_regs __iomem *mac_regs_base =
+		(struct	al_eth_mac_regs __iomem *)mac_base;
+	u32 reg = 0;
+
+	/* ************* Setting Board params register 1 **************** */
+	reg &= ~AL_HW_ETH_MEDIA_TYPE_MASK;
+	reg |= (params->media_type << AL_HW_ETH_MEDIA_TYPE_SHIFT) & AL_HW_ETH_MEDIA_TYPE_MASK;
+	reg |= !!params->phy_exist << AL_HW_ETH_EXT_PHY_SHIFT;
+	reg &= ~AL_HW_ETH_PHY_ADDR_MASK;
+	reg |= (params->phy_mdio_addr << AL_HW_ETH_PHY_ADDR_SHIFT) & AL_HW_ETH_PHY_ADDR_MASK;
+
+	reg |= !!params->sfp_plus_module_exist << AL_HW_ETH_SFP_EXIST_SHIFT;
+
+	reg |= !!params->autoneg_enable << AL_HW_ETH_AN_ENABLE_SHIFT;
+	reg |= !!params->kr_lt_enable << AL_HW_ETH_KR_LT_ENABLE_SHIFT;
+	reg |= !!params->kr_fec_enable << AL_HW_ETH_KR_FEC_ENABLE_SHIFT;
+	reg &= ~AL_HW_ETH_MDIO_FREQ_MASK;
+	reg |= (params->mdio_freq << AL_HW_ETH_MDIO_FREQ_SHIFT) & AL_HW_ETH_MDIO_FREQ_MASK;
+	reg &= ~AL_HW_ETH_I2C_ADAPTER_ID_MASK;
+	reg |= (params->i2c_adapter_id << AL_HW_ETH_I2C_ADAPTER_ID_SHIFT) & AL_HW_ETH_I2C_ADAPTER_ID_MASK;
+	reg &= ~AL_HW_ETH_EXT_PHY_IF_MASK;
+	reg |= (params->phy_if << AL_HW_ETH_EXT_PHY_IF_SHIFT) & AL_HW_ETH_EXT_PHY_IF_MASK;
+
+	reg |= (params->an_mode == AL_ETH_BOARD_AUTONEG_IN_BAND << AL_HW_ETH_AUTO_NEG_MODE_SHIFT);
+
+	reg &= ~AL_HW_ETH_REF_CLK_FREQ_MASK;
+	reg |= (params->ref_clk_freq << AL_HW_ETH_REF_CLK_FREQ_SHIFT) & AL_HW_ETH_REF_CLK_FREQ_MASK;
+
+	WARN_ON(!reg);
+
+	writel(reg, &mac_regs_base->mac_1g.scratch);
+
+	/* ************* Setting Board params register 2 **************** */
+	reg = 0;
+	reg |= !!params->force_1000_base_x << AL_HW_ETH_1000_BASE_X_SHIFT;
+
+	reg |= !!params->an_disable << AL_HW_ETH_1G_AN_DISABLE_SHIFT;
+
+	reg &= ~AL_HW_ETH_1G_SPEED_MASK;
+	reg |= (params->speed << AL_HW_ETH_1G_SPEED_SHIFT) & AL_HW_ETH_1G_SPEED_MASK;
+
+	reg |= !!params->half_duplex << AL_HW_ETH_1G_HALF_DUPLEX_SHIFT;
+
+	reg |= !!params->fc_disable << AL_HW_ETH_1G_FC_DISABLE_SHIFT;
+
+	reg |= !!params->retimer_exist << AL_HW_ETH_RETIMER_EXIST_SHIFT;
+	reg &= ~AL_HW_ETH_RETIMER_BUS_ID_MASK;
+	reg |= (params->retimer_bus_id << AL_HW_ETH_RETIMER_BUS_ID_SHIFT) & AL_HW_ETH_RETIMER_BUS_ID_MASK;
+	reg &= ~AL_HW_ETH_RETIMER_I2C_ADDR_MASK;
+	reg |= (params->retimer_i2c_addr << AL_HW_ETH_RETIMER_I2C_ADDR_SHIFT) & AL_HW_ETH_RETIMER_I2C_ADDR_MASK;
+
+	reg |= ((params->retimer_channel & BIT(0)) << AL_HW_ETH_RETIMER_CHANNEL_SHIFT);
+
+	reg &= ~AL_HW_ETH_RETIMER_CHANNEL_2_MASK;
+	reg |= ((params->retimer_channel & 0x6) >> 1 << AL_HW_ETH_RETIMER_CHANNEL_2_SHIFT) & AL_HW_ETH_RETIMER_CHANNEL_2_MASK;
+
+	reg &= ~AL_HW_ETH_DAC_LENGTH_MASK;
+	reg |= (params->dac_len << AL_HW_ETH_DAC_LENGTH_SHIFT) & AL_HW_ETH_DAC_LENGTH_MASK;
+	reg |= (params->dac << AL_HW_ETH_DAC_SHIFT);
+
+	reg &= ~AL_HW_ETH_RETIMER_TYPE_MASK;
+	reg |= (params->retimer_type << AL_HW_ETH_RETIMER_TYPE_SHIFT) & AL_HW_ETH_RETIMER_TYPE_MASK;
+
+	reg &= ~AL_HW_ETH_RETIMER_TX_CHANNEL_MASK;
+	reg |= (params->retimer_tx_channel << AL_HW_ETH_RETIMER_TX_CHANNEL_SHIFT) & AL_HW_ETH_RETIMER_TX_CHANNEL_MASK;
+
+	writel(reg, &mac_regs_base->mac_10g.scratch);
+
+	/* ************* Setting Board params register 3 **************** */
+	reg = 0;
+
+	reg &= ~AL_HW_ETH_GPIO_SFP_PRESENT_MASK;
+	reg |= (params->gpio_sfp_present << AL_HW_ETH_GPIO_SFP_PRESENT_SHIFT) & AL_HW_ETH_GPIO_SFP_PRESENT_MASK;
+
+	writel(reg, &mac_regs_base->mac_1g.mac_0);
+
+	return 0;
+}
+
+int al_eth_board_params_get(void * __iomem mac_base, struct al_eth_board_params *params)
+{
+	struct al_eth_mac_regs __iomem *mac_regs_base =
+		(struct	al_eth_mac_regs __iomem *)mac_base;
+	u32	reg = readl(&mac_regs_base->mac_1g.scratch);
+
+	/* check if the register was initialized, 0 is not a valid value */
+	if (!reg)
+		return -ENOENT;
+
+	/* ************* Getting Board params register 1 **************** */
+	params->media_type = (reg & AL_HW_ETH_MEDIA_TYPE_MASK)
+			>> AL_HW_ETH_MEDIA_TYPE_SHIFT;
+	if (((reg >> AL_HW_ETH_EXT_PHY_SHIFT) & 0x1))
+		params->phy_exist = true;
+	else
+		params->phy_exist = false;
+
+	params->phy_mdio_addr = (reg & AL_HW_ETH_PHY_ADDR_MASK) >>
+			AL_HW_ETH_PHY_ADDR_SHIFT;
+
+	if (((reg >> AL_HW_ETH_SFP_EXIST_SHIFT) & 0x1))
+		params->sfp_plus_module_exist = true;
+	else
+		params->sfp_plus_module_exist = false;
+
+	if (((reg >> AL_HW_ETH_AN_ENABLE_SHIFT) & 0x1))
+		params->autoneg_enable = true;
+	else
+		params->autoneg_enable = false;
+
+	if (((reg >> AL_HW_ETH_KR_LT_ENABLE_SHIFT) & 0x1))
+		params->kr_lt_enable = true;
+	else
+		params->kr_lt_enable = false;
+
+	if (((reg >> AL_HW_ETH_KR_FEC_ENABLE_SHIFT) & 0x1))
+		params->kr_fec_enable = true;
+	else
+		params->kr_fec_enable = false;
+
+	params->mdio_freq = (reg & AL_HW_ETH_MDIO_FREQ_MASK) >>
+			AL_HW_ETH_MDIO_FREQ_SHIFT;
+
+	params->i2c_adapter_id = (reg & AL_HW_ETH_I2C_ADAPTER_ID_MASK) >>
+			AL_HW_ETH_I2C_ADAPTER_ID_SHIFT;
+
+	params->phy_if = (reg & AL_HW_ETH_EXT_PHY_IF_MASK) >>
+			AL_HW_ETH_EXT_PHY_IF_SHIFT;
+
+	if (((reg >> AL_HW_ETH_AUTO_NEG_MODE_SHIFT) & 0x1))
+		params->an_mode = true;
+	else
+		params->an_mode = false;
+
+	params->ref_clk_freq = (reg & AL_HW_ETH_REF_CLK_FREQ_MASK) >>
+			AL_HW_ETH_REF_CLK_FREQ_SHIFT;
+
+	/* ************* Getting Board params register 2 **************** */
+	reg = readl(&mac_regs_base->mac_10g.scratch);
+
+	if (((reg >> AL_HW_ETH_1000_BASE_X_SHIFT) & 0x1))
+		params->force_1000_base_x = true;
+	else
+		params->force_1000_base_x = false;
+
+	if (((reg >> AL_HW_ETH_1G_AN_DISABLE_SHIFT) & 0x1))
+		params->an_disable = true;
+	else
+		params->an_disable = false;
+
+	params->speed = (reg & AL_HW_ETH_1G_SPEED_MASK) >>
+			AL_HW_ETH_1G_SPEED_SHIFT;
+
+	if (((reg >> AL_HW_ETH_1G_HALF_DUPLEX_SHIFT) & 0x1))
+		params->half_duplex = true;
+	else
+		params->half_duplex = false;
+
+	if (((reg >> AL_HW_ETH_1G_FC_DISABLE_SHIFT) & 0x1))
+		params->fc_disable = true;
+	else
+		params->fc_disable = false;
+
+	if (((reg >> AL_HW_ETH_RETIMER_EXIST_SHIFT) & 0x1))
+		params->retimer_exist = true;
+	else
+		params->retimer_exist = false;
+
+	params->retimer_bus_id = (reg & AL_HW_ETH_RETIMER_BUS_ID_MASK) >>
+			AL_HW_ETH_RETIMER_BUS_ID_SHIFT;
+	params->retimer_i2c_addr = (reg & AL_HW_ETH_RETIMER_I2C_ADDR_MASK) >>
+			AL_HW_ETH_RETIMER_I2C_ADDR_SHIFT;
+
+	params->retimer_channel =
+		((((reg >> AL_HW_ETH_RETIMER_CHANNEL_SHIFT) & 0x1)) |
+		 ((reg & AL_HW_ETH_RETIMER_CHANNEL_2_MASK) >>
+		  AL_HW_ETH_RETIMER_CHANNEL_2_SHIFT) << 1);
+
+	params->dac_len = (reg & AL_HW_ETH_DAC_LENGTH_MASK) >>
+			AL_HW_ETH_DAC_LENGTH_SHIFT;
+
+	if (((reg >> AL_HW_ETH_DAC_SHIFT) & 0x1))
+		params->dac = true;
+	else
+		params->dac = false;
+
+	params->retimer_type = (reg & AL_HW_ETH_RETIMER_TYPE_MASK) >>
+			AL_HW_ETH_RETIMER_TYPE_SHIFT;
+
+	params->retimer_tx_channel = (reg & AL_HW_ETH_RETIMER_TX_CHANNEL_MASK) >>
+			AL_HW_ETH_RETIMER_TX_CHANNEL_SHIFT;
+
+	/* ************* Getting Board params register 3 **************** */
+	reg = readl(&mac_regs_base->mac_1g.mac_0);
+
+	params->gpio_sfp_present = (reg & AL_HW_ETH_GPIO_SFP_PRESENT_MASK) >>
+			AL_HW_ETH_GPIO_SFP_PRESENT_SHIFT;
+
+	return 0;
+}
+
+/* Wake-On-Lan (WoL) */
+static inline void al_eth_byte_arr_to_reg(u32 *reg, u8 *arr,
+					  unsigned int num_bytes)
+{
+	u32 mask = 0xff;
+	unsigned int i;
+
+	WARN_ON(num_bytes > 4);
+
+	*reg = 0;
+
+	for (i = 0 ; i < num_bytes ; i++) {
+		*reg &= ~mask;
+		*reg |= (arr[i] << (sizeof(u8) * i)) & mask;
+		mask = mask << sizeof(u8);
+	}
+}
+
+int al_eth_wol_enable(struct al_hw_eth_adapter *adapter,
+		      struct al_eth_wol_params *wol)
+{
+	u32 reg = 0;
+
+	if (wol->int_mask & AL_ETH_WOL_INT_MAGIC_PSWD) {
+		WARN_ON(!wol->pswd);
+
+		al_eth_byte_arr_to_reg(&reg, &wol->pswd[0], 4);
+		writel(reg, &adapter->ec_regs_base->wol.magic_pswd_l);
+
+		al_eth_byte_arr_to_reg(&reg, &wol->pswd[4], 2);
+		writel(reg, &adapter->ec_regs_base->wol.magic_pswd_h);
+	}
+
+	if (wol->int_mask & AL_ETH_WOL_INT_IPV4) {
+		WARN_ON(!wol->ipv4);
+
+		al_eth_byte_arr_to_reg(&reg, &wol->ipv4[0], 4);
+		writel(reg, &adapter->ec_regs_base->wol.ipv4_dip);
+	}
+
+	if (wol->int_mask & AL_ETH_WOL_INT_IPV6) {
+		WARN_ON(!wol->ipv6);
+
+		al_eth_byte_arr_to_reg(&reg, &wol->ipv6[0], 4);
+		writel(reg, &adapter->ec_regs_base->wol.ipv6_dip_word0);
+
+		al_eth_byte_arr_to_reg(&reg, &wol->ipv6[4], 4);
+		writel(reg, &adapter->ec_regs_base->wol.ipv6_dip_word1);
+
+		al_eth_byte_arr_to_reg(&reg, &wol->ipv6[8], 4);
+		writel(reg, &adapter->ec_regs_base->wol.ipv6_dip_word2);
+
+		al_eth_byte_arr_to_reg(&reg, &wol->ipv6[12], 4);
+		writel(reg, &adapter->ec_regs_base->wol.ipv6_dip_word3);
+	}
+
+	if (wol->int_mask &
+	    (AL_ETH_WOL_INT_ETHERTYPE_BC | AL_ETH_WOL_INT_ETHERTYPE_DA)) {
+		reg = ((u32)wol->ethr_type2 << 16);
+		reg |= wol->ethr_type1;
+
+		writel(reg, &adapter->ec_regs_base->wol.ethertype);
+	}
+
+	/* make sure we dont forwarding packets without interrupt */
+	WARN_ON((wol->forward_mask | wol->int_mask) != wol->int_mask);
+
+	reg = ((u32)wol->forward_mask << 16);
+	reg |= wol->int_mask;
+	writel(reg, &adapter->ec_regs_base->wol.wol_en);
+
+	return 0;
+}
+
+int al_eth_wol_disable(struct al_hw_eth_adapter *adapter)
+{
+	writel(0, &adapter->ec_regs_base->wol.wol_en);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/annapurna/al_hw_unit_adapter_regs.h b/drivers/net/ethernet/annapurna/al_hw_unit_adapter_regs.h
new file mode 100644
index 000000000000..1ad514c4bc5a
--- /dev/null
+++ b/drivers/net/ethernet/annapurna/al_hw_unit_adapter_regs.h
@@ -0,0 +1,24 @@
+/*
+ * Copyright (C) 2017, Amazon.com, Inc. or its affiliates. All Rights Reserved.
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#ifndef __AL_HW_UNIT_ADAPTER_REGS_H__
+#define __AL_HW_UNIT_ADAPTER_REGS_H__
+
+#define AL_PCI_COMMAND		0x04	/* 16 bits */
+
+#define AL_PCI_EXP_CAP_BASE		0x40
+#define AL_PCI_EXP_DEVCTL		8       /* Device Control */
+#define  AL_PCI_EXP_DEVCTL_BCR_FLR	0x8000  /* Bridge Configuration Retry / FLR */
+
+#define AL_ADAPTER_GENERIC_CONTROL_0		0x1E0
+
+/* When set, all transactions through the PCI conf & mem BARs get timeout */
+#define AL_ADAPTER_GENERIC_CONTROL_0_ETH_RESET_1GMAC		BIT(18)
+#define AL_ADAPTER_GENERIC_CONTROL_0_ETH_RESET_1GMAC_ON_FLR	BIT(26)
+
+#endif
-- 
2.11.0
