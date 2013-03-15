From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 1/5] net: Add davicom wemac ethernet driver found on Allwinner A10 SoC's
Date: Fri, 15 Mar 2013 21:50:00 +0100
Message-ID: <1363380605-6577-2-git-send-email-maxime.ripard@free-electrons.com>
References: <1363380605-6577-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, netdev@vger.kernel.org,
	Stefan Roese <sr@denx.de>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1363380605-6577-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Roese <sr@denx.de>

The Allwinner A10 has an ethernet controller that is advertised as
coming from Davicom.

The exact feature set of this controller is unknown, since there is no
public documentation for this IP, and this driver is mostly the one
published by Allwinner that has been heavily cleaned up.

Signed-off-by: Stefan Roese <sr@denx.de>
Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 .../devicetree/bindings/net/davicom-wemac.txt      |   20 +
 drivers/net/ethernet/Makefile                      |    2 +-
 drivers/net/ethernet/davicom/Kconfig               |   31 +
 drivers/net/ethernet/davicom/Makefile              |    1 +
 drivers/net/ethernet/davicom/wemac.c               | 1033 ++++++++++++++++++++
 drivers/net/ethernet/davicom/wemac.h               |  130 +++
 6 files changed, 1216 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/davicom-wemac.txt
 create mode 100644 drivers/net/ethernet/davicom/wemac.c
 create mode 100644 drivers/net/ethernet/davicom/wemac.h

diff --git a/Documentation/devicetree/bindings/net/davicom-wemac.txt b/Documentation/devicetree/bindings/net/davicom-wemac.txt
new file mode 100644
index 0000000..516cf31
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/davicom-wemac.txt
@@ -0,0 +1,20 @@
+* Marvell Armada 370 / Armada XP Ethernet Controller (NETA)
+
+Required properties:
+- compatible: should be "marvell,armada-370-neta".
+- reg: address and length of the register set for the device.
+- interrupts: interrupt for the device
+
+Optional properties:
+- allwinner,power-gpios: gpio pointer if the phy needs to be
+  enabled through a GPIO.
+- (local-)mac-address: mac address to be used by this driver
+
+Example:
+
+wemac: ethernet@01c0b000 {
+       compatible = "davicom,wemac";
+       reg = <0x01c0b000 0x1000>;
+       interrupts = <55>;
+       allwinner,power-gpios = <&pio 7 19 0>;
+};
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 8268d85..5871143 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -18,7 +18,7 @@ obj-$(CONFIG_NET_CALXEDA_XGMAC) += calxeda/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CIRRUS) += cirrus/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
-obj-$(CONFIG_DM9000) += davicom/
+obj-$(CONFIG_NET_VENDOR_DAVICOM) += davicom/
 obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_NET_VENDOR_DEC) += dec/
 obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/davicom/Kconfig
index 9745fe5..0185e62 100644
--- a/drivers/net/ethernet/davicom/Kconfig
+++ b/drivers/net/ethernet/davicom/Kconfig
@@ -2,6 +2,23 @@
 # Davicom device configuration
 #
 
+config NET_VENDOR_DAVICOM
+	bool "Davicom devices"
+	default y
+	depends on ARM || BLACKFIN || MIPS || COLDFIRE
+	---help---
+	  If you have a network (Ethernet) card belonging to this
+	  class, say Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly
+	  affect the kernel: saying N will just cause the configurator
+	  to skip all the questions about Davicom cards. If you say Y,
+	  you will be asked for your specific card in the following
+	  questions.
+
+if NET_VENDOR_DAVICOM
+
 config DM9000
 	tristate "DM9000 support"
 	depends on ARM || BLACKFIN || MIPS || COLDFIRE
@@ -22,3 +39,17 @@ config DM9000_FORCE_SIMPLE_PHY_POLL
 	  bit to determine if the link is up or down instead of the more
 	  costly MII PHY reads. Note, this will not work if the chip is
 	  operating with an external PHY.
+
+config WEMAC
+        tristate "WEMAC support"
+	depends on OF
+	select CRC32
+	select NET_CORE
+	select MII
+        ---help---
+          Support for Davicom WEMAC ethernet driver.
+
+          To compile this driver as a module, choose M here.  The module
+          will be called wemac.
+
+endif # NET_VENDOR_DAVICOM
diff --git a/drivers/net/ethernet/davicom/Makefile b/drivers/net/ethernet/davicom/Makefile
index 74b31f0..803297e 100644
--- a/drivers/net/ethernet/davicom/Makefile
+++ b/drivers/net/ethernet/davicom/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_DM9000) += dm9000.o
+obj-$(CONFIG_WEMAC) += wemac.o
diff --git a/drivers/net/ethernet/davicom/wemac.c b/drivers/net/ethernet/davicom/wemac.c
new file mode 100644
index 0000000..8468baf
--- /dev/null
+++ b/drivers/net/ethernet/davicom/wemac.c
@@ -0,0 +1,1033 @@
+/*
+ * Allwinner WEMAC Fast Ethernet driver for Linux.
+ *
+ * Copyright 2012 Stefan Roese <sr@denx.de>
+ * Copyright 2013 Maxime Ripard <maxime.ripard@free-electrons.com>
+ *
+ * Based on the Linux driver provided by Allwinner:
+ * Copyright (C) 1997  Sten Wang
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/clk.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/gpio.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/of_address.h>
+#include <linux/of_gpio.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
+#include <linux/of_platform.h>
+#include <linux/platform_device.h>
+
+#include "wemac.h"
+
+#define DRV_NAME		"wemac"
+#define DRV_VERSION		"1.01"
+
+#define WEMAC_MAX_FRAME_LEN	0x0600
+#define WEMAC_PHY		0x100	/* PHY address 0x01 */
+
+/* Transmit timeout, default 5 seconds. */
+static int watchdog = 5000;
+module_param(watchdog, int, 0400);
+MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
+
+/* WEMAC register address locking.
+ *
+ * The WEMAC uses an address register to control where data written
+ * to the data register goes. This means that the address register
+ * must be preserved over interrupts or similar calls.
+ *
+ * During interrupt and other critical calls, a spinlock is used to
+ * protect the system, but the calls themselves save the address
+ * in the address register in case they are interrupting another
+ * access to the device.
+ *
+ * For general accesses a lock is provided so that calls which are
+ * allowed to sleep are serialised so that the address register does
+ * not need to be saved. This lock also serves to serialise access
+ * to the EEPROM and PHY access registers which are shared between
+ * these two devices.
+ */
+
+/* The driver supports the original WEMACE, and now the two newer
+ * devices, WEMACA and WEMACB.
+ */
+
+struct wemac_board_info {
+	struct clk		*clk;
+	struct device		*dev;
+	spinlock_t		lock;
+	void __iomem		*membase;
+	struct mii_if_info	mii;
+	u32			msg_enable;
+	struct net_device	*ndev;
+	struct mutex		phy_lock;
+	struct delayed_work	phy_poll;
+	unsigned		power_gpio;
+	struct sk_buff		*skb_last;
+	u16			tx_fifo_stat;
+};
+
+static inline struct wemac_board_info *to_wemac_board(struct net_device *dev)
+{
+	return netdev_priv(dev);
+}
+
+static int wemac_phy_read(struct net_device *dev, int phyaddr, int reg)
+{
+	struct wemac_board_info *db = netdev_priv(dev);
+	unsigned long flags;
+	int ret;
+
+	mutex_lock(&db->phy_lock);
+
+	spin_lock_irqsave(&db->lock, flags);
+	/* issue the phy address and reg */
+	writel(phyaddr | reg, db->membase + EMAC_MAC_MADR_REG);
+	/* pull up the phy io line */
+	writel(0x1, db->membase + EMAC_MAC_MCMD_REG);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	/* Wait read complete */
+	mdelay(1);
+
+	/* push down the phy io line and read data */
+	spin_lock_irqsave(&db->lock, flags);
+	/* push down the phy io line */
+	writel(0x0, db->membase + EMAC_MAC_MCMD_REG);
+	/* and read data */
+	ret = readl(db->membase + EMAC_MAC_MRDD_REG);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	mutex_unlock(&db->phy_lock);
+
+	return ret;
+}
+
+/* Write a word to phyxcer */
+static void wemac_phy_write(struct net_device *dev,
+			    int phyaddr, int reg, int value)
+{
+	struct wemac_board_info *db = netdev_priv(dev);
+	unsigned long flags;
+
+	mutex_lock(&db->phy_lock);
+
+	spin_lock_irqsave(&db->lock, flags);
+	/* issue the phy address and reg */
+	writel(phyaddr | reg, db->membase + EMAC_MAC_MADR_REG);
+	/* pull up the phy io line */
+	writel(0x1, db->membase + EMAC_MAC_MCMD_REG);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	/* Wait write complete */
+	mdelay(1);
+
+	spin_lock_irqsave(&db->lock, flags);
+	/* push down the phy io line */
+	writel(0x0, db->membase + EMAC_MAC_MCMD_REG);
+	/* and write data */
+	writel(value, db->membase + EMAC_MAC_MWTD_REG);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	mutex_unlock(&db->phy_lock);
+}
+
+static int emacrx_completed_flag = 1;
+
+static void wemac_reset(struct wemac_board_info *db)
+{
+	dev_dbg(db->dev, "resetting device\n");
+
+	/* RESET device */
+	writel(0, db->membase + EMAC_CTL_REG);
+	udelay(200);
+	writel(EMAC_CTL_RESET, db->membase + EMAC_CTL_REG);
+	udelay(200);
+}
+
+static void wemac_outblk_32bit(void __iomem *reg, void *data, int count)
+{
+	writesl(reg, data, round_up(count, 4) / 4);
+}
+
+static void wemac_inblk_32bit(void __iomem *reg, void *data, int count)
+{
+	readsl(reg, data, round_up(count, 4) / 4);
+}
+
+static void wemac_dumpblk_32bit(void __iomem *reg, int count)
+{
+	int i;
+	int tmp;
+
+	for (i = 0; i < (round_up(count, 4) / 4); i++)
+		tmp = readl(reg);
+}
+
+static void wemac_schedule_poll(struct wemac_board_info *db)
+{
+	schedule_delayed_work(&db->phy_poll, HZ * 2);
+}
+
+static int wemac_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	struct wemac_board_info *dm = to_wemac_board(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
+}
+
+/* ethtool ops */
+static void wemac_get_drvinfo(struct net_device *dev,
+			      struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+}
+
+static u32 wemac_get_msglevel(struct net_device *dev)
+{
+	struct wemac_board_info *dm = to_wemac_board(dev);
+
+	return dm->msg_enable;
+}
+
+static void wemac_set_msglevel(struct net_device *dev, u32 value)
+{
+	struct wemac_board_info *dm = to_wemac_board(dev);
+
+	dm->msg_enable = value;
+}
+
+static int wemac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct wemac_board_info *dm = to_wemac_board(dev);
+
+	mii_ethtool_gset(&dm->mii, cmd);
+
+	return 0;
+}
+
+static int wemac_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct wemac_board_info *dm = to_wemac_board(dev);
+
+	return mii_ethtool_sset(&dm->mii, cmd);
+}
+
+static int wemac_nway_reset(struct net_device *dev)
+{
+	struct wemac_board_info *dm = to_wemac_board(dev);
+
+	return mii_nway_restart(&dm->mii);
+}
+
+static u32 wemac_get_link(struct net_device *dev)
+{
+	return wemac_phy_read(dev, WEMAC_PHY, 1) & 0x04 ? 1 : 0;
+}
+
+static const struct ethtool_ops wemac_ethtool_ops = {
+	.get_drvinfo	= wemac_get_drvinfo,
+	.get_settings	= wemac_get_settings,
+	.set_settings	= wemac_set_settings,
+	.get_msglevel	= wemac_get_msglevel,
+	.set_msglevel	= wemac_set_msglevel,
+	.nway_reset	= wemac_nway_reset,
+	.get_link	= wemac_get_link,
+};
+
+unsigned int phy_link_check(struct net_device *dev)
+{
+	unsigned int reg_val;
+
+	reg_val = wemac_phy_read(dev, WEMAC_PHY, 1);
+
+	if (reg_val & 0x4) {
+		netdev_info(dev, "EMAC PHY Linked...\n");
+		return 1;
+	} else {
+		netdev_info(dev, "EMAC PHY Link waiting......\n");
+		return 0;
+	}
+}
+
+unsigned int emac_setup(struct net_device *ndev)
+{
+	unsigned int reg_val;
+	unsigned int phy_val;
+	unsigned int duplex_flag;
+	struct wemac_board_info *db = netdev_priv(ndev);
+
+	/* set up TX */
+	reg_val = readl(db->membase + EMAC_TX_MODE_REG);
+
+	writel(reg_val | EMAC_TX_MODE_ABORTED_FRAME_EN,
+		db->membase + EMAC_TX_MODE_REG);
+
+	/* set up RX */
+	reg_val = readl(db->membase + EMAC_RX_CTL_REG);
+
+	writel(reg_val | EMAC_RX_CTL_PASS_LEN_OOR_EN |
+		EMAC_RX_CTL_ACCEPT_UNICAST_EN | EMAC_RX_CTL_DA_FILTER_EN |
+		EMAC_RX_CTL_ACCEPT_MULTICAST_EN |
+		EMAC_RX_CTL_ACCEPT_BROADCAST_EN,
+		db->membase + EMAC_RX_CTL_REG);
+
+	/* set MAC */
+	/* set MAC CTL0 */
+	reg_val = readl(db->membase + EMAC_MAC_CTL0_REG);
+	writel(reg_val | EMAC_MAC_CTL0_RX_FLOW_CTL_EN |
+		EMAC_MAC_CTL0_TX_FLOW_CTL_EN,
+		db->membase + EMAC_MAC_CTL0_REG);
+
+	/* set MAC CTL1 */
+	reg_val = readl(db->membase + EMAC_MAC_CTL1_REG);
+	phy_val = wemac_phy_read(ndev, WEMAC_PHY, 0);
+	dev_dbg(db->dev, "PHY SETUP, reg 0 value: %x\n", phy_val);
+	duplex_flag = !!(phy_val & EMAC_PHY_DUPLEX);
+
+	if (duplex_flag)
+		reg_val |= EMAC_MAC_CTL1_DUPLEX_EN;
+
+	reg_val |= EMAC_MAC_CTL1_LEN_CHECK_EN;
+	reg_val |= EMAC_MAC_CTL1_CRC_EN;
+	reg_val |= EMAC_MAC_CTL1_PAD_EN;
+	writel(reg_val, db->membase + EMAC_MAC_CTL1_REG);
+
+	/* set up IPGT */
+	writel(EMAC_MAC_IPGT_FULL_DUPLEX, db->membase + EMAC_MAC_IPGT_REG);
+
+	/* set up IPGR */
+	writel((EMAC_MAC_IPGR_IPG1 << 8) | EMAC_MAC_IPGR_IPG2,
+		db->membase + EMAC_MAC_IPGR_REG);
+
+	/* set up Collison window */
+	writel((EMAC_MAC_CLRT_COLLISION_WINDOW << 8) | EMAC_MAC_CLRT_RM,
+		db->membase + EMAC_MAC_CLRT_REG);
+
+	/* set up Max Frame Length */
+	writel(WEMAC_MAX_FRAME_LEN,
+		db->membase + EMAC_MAC_MAXF_REG);
+
+	return 0;
+}
+
+unsigned int wemac_powerup(struct net_device *ndev)
+{
+	struct wemac_board_info *db = netdev_priv(ndev);
+	unsigned int reg_val;
+
+	/* initial EMAC */
+	/* flush RX FIFO */
+	reg_val = readl(db->membase + EMAC_RX_CTL_REG);
+	reg_val |= 0x8;
+	writel(reg_val, db->membase + EMAC_RX_CTL_REG);
+	udelay(1);
+
+	/* initial MAC */
+	/* soft reset MAC */
+	reg_val = readl(db->membase + EMAC_MAC_CTL0_REG);
+	reg_val &= ~EMAC_MAC_CTL0_SOFT_RESET;
+	writel(reg_val, db->membase + EMAC_MAC_CTL0_REG);
+
+	/* set MII clock */
+	reg_val = readl(db->membase + EMAC_MAC_MCFG_REG);
+	reg_val &= (~(0xf << 2));
+	reg_val |= (0xD << 2);
+	writel(reg_val, db->membase + EMAC_MAC_MCFG_REG);
+
+	/* clear RX counter */
+	writel(0x0, db->membase + EMAC_RX_FBC_REG);
+
+	/* disable all interrupt and clear interrupt status */
+	writel(0, db->membase + EMAC_INT_CTL_REG);
+	reg_val = readl(db->membase + EMAC_INT_STA_REG);
+	writel(reg_val, db->membase + EMAC_INT_STA_REG);
+
+	udelay(1);
+
+	/* set up EMAC */
+	emac_setup(ndev);
+
+	/* set mac_address to chip */
+	writel(ndev->dev_addr[0] << 16 | ndev->dev_addr[1] << 8 | ndev->
+	       dev_addr[2], db->membase + EMAC_MAC_A1_REG);
+	writel(ndev->dev_addr[3] << 16 | ndev->dev_addr[4] << 8 | ndev->
+	       dev_addr[5], db->membase + EMAC_MAC_A0_REG);
+
+	mdelay(1);
+
+	return 1;
+}
+
+static void wemac_poll_work(struct work_struct *w)
+{
+	struct delayed_work *dw = container_of(w, struct delayed_work, work);
+	struct wemac_board_info *db = container_of(dw,
+						struct wemac_board_info,
+						phy_poll);
+	struct net_device *ndev = db->ndev;
+
+	mii_check_media(&db->mii, netif_msg_link(db), 0);
+
+	if (netif_running(ndev))
+		wemac_schedule_poll(db);
+}
+
+static int wemac_set_mac_address(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct wemac_board_info *db = netdev_priv(dev);
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+
+	writel(dev->dev_addr[0] << 16 | dev->dev_addr[1] << 8 | dev->
+	       dev_addr[2], db->membase + EMAC_MAC_A1_REG);
+	writel(dev->dev_addr[3] << 16 | dev->dev_addr[4] << 8 | dev->
+	       dev_addr[5], db->membase + EMAC_MAC_A0_REG);
+
+	return 0;
+}
+
+/* Initialize wemac board */
+static void wemac_init_wemac(struct net_device *dev)
+{
+	struct wemac_board_info *db = netdev_priv(dev);
+	unsigned int phy_reg;
+	unsigned int reg_val;
+
+	if (gpio_is_valid(db->power_gpio))
+		gpio_set_value(db->power_gpio, 1);
+
+	/* PHY POWER UP */
+	phy_reg = wemac_phy_read(dev, WEMAC_PHY, 0);
+	wemac_phy_write(dev, WEMAC_PHY, 0, phy_reg & (~(1 << 11)));
+	mdelay(1);
+
+	phy_reg = wemac_phy_read(dev, WEMAC_PHY, 0);
+
+	/* set EMAC SPEED, depend on PHY  */
+	reg_val = readl(db->membase + EMAC_MAC_SUPP_REG);
+	reg_val &= (~(0x1 << 8));
+	reg_val |= (((phy_reg & (1 << 13)) >> 13) << 8);
+	writel(reg_val, db->membase + EMAC_MAC_SUPP_REG);
+
+	/* set duplex depend on phy */
+	reg_val = readl(db->membase + EMAC_MAC_CTL1_REG);
+	reg_val &= (~(0x1 << 0));
+	reg_val |= (((phy_reg & (1 << 8)) >> 8) << 0);
+	writel(reg_val, db->membase + EMAC_MAC_CTL1_REG);
+
+	/* enable RX/TX */
+	reg_val = readl(db->membase + EMAC_CTL_REG);
+	writel(reg_val | EMAC_CTL_RESET | EMAC_CTL_TX_EN | EMAC_CTL_RX_EN,
+		db->membase + EMAC_CTL_REG);
+
+	/* enable RX/TX0/RX Hlevel interrup */
+	reg_val = readl(db->membase + EMAC_INT_CTL_REG);
+	reg_val |= (0xf << 0) | (0x01 << 8);
+	writel(reg_val, db->membase + EMAC_INT_CTL_REG);
+
+	/* Init Driver variable */
+	db->tx_fifo_stat = 0;
+	dev->trans_start = 0;
+}
+
+/* Our watchdog timed out. Called by the networking layer */
+static void wemac_timeout(struct net_device *dev)
+{
+	struct wemac_board_info *db = netdev_priv(dev);
+	unsigned long flags;
+
+	if (netif_msg_timer(db))
+		dev_err(db->dev, "tx time out.\n");
+
+	/* Save previous register address */
+	spin_lock_irqsave(&db->lock, flags);
+
+	netif_stop_queue(dev);
+	wemac_reset(db);
+	wemac_init_wemac(dev);
+	/* We can accept TX packets again */
+	dev->trans_start = jiffies;
+	netif_wake_queue(dev);
+
+	/* Restore previous register address */
+	spin_unlock_irqrestore(&db->lock, flags);
+}
+
+/* Hardware start transmission.
+ * Send a packet to media from the upper layer.
+ */
+static int wemac_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct wemac_board_info *db = netdev_priv(dev);
+	unsigned long channel;
+	unsigned long flags;
+
+	channel = db->tx_fifo_stat & 3;
+	if (channel == 3)
+		return 1;
+
+	channel = (channel == 1 ? 1 : 0);
+
+	spin_lock_irqsave(&db->lock, flags);
+
+	writel(channel, db->membase + EMAC_TX_INS_REG);
+
+	wemac_outblk_32bit(db->membase + EMAC_TX_IO_DATA_REG,
+			skb->data, skb->len);
+	dev->stats.tx_bytes += skb->len;
+
+	db->tx_fifo_stat |= 1 << channel;
+	/* TX control: First packet immediately send, second packet queue */
+	if (channel == 0) {
+		/* set TX len */
+		writel(skb->len, db->membase + EMAC_TX_PL0_REG);
+		/* start translate from fifo to phy */
+		writel(readl(db->membase + EMAC_TX_CTL0_REG) | 1,
+		       db->membase + EMAC_TX_CTL0_REG);
+
+		/* save the time stamp */
+		dev->trans_start = jiffies;
+	} else if (channel == 1) {
+		/* set TX len */
+		writel(skb->len, db->membase + EMAC_TX_PL1_REG);
+		/* start translate from fifo to phy */
+		writel(readl(db->membase + EMAC_TX_CTL1_REG) | 1,
+		       db->membase + EMAC_TX_CTL1_REG);
+
+		/* save the time stamp */
+		dev->trans_start = jiffies;
+	}
+
+	if ((db->tx_fifo_stat & 3) == 3) {
+		/* Second packet */
+		netif_stop_queue(dev);
+	}
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	/* free this SKB */
+	dev_kfree_skb(skb);
+
+	return 0;
+}
+
+/* WEMAC interrupt handler
+ * receive the packet to upper layer, free the transmitted packet
+ */
+static void wemac_tx_done(struct net_device *dev, struct wemac_board_info *db,
+			  unsigned int tx_status)
+{
+	/* One packet sent complete */
+	db->tx_fifo_stat &= ~(tx_status & 3);
+	if (3 == (tx_status & 3))
+		dev->stats.tx_packets += 2;
+	else
+		dev->stats.tx_packets++;
+
+	if (netif_msg_tx_done(db))
+		dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);
+
+	netif_wake_queue(dev);
+}
+
+/* Received a packet and pass to upper layer
+ */
+static void wemac_rx(struct net_device *dev)
+{
+	struct wemac_board_info *db = netdev_priv(dev);
+	struct sk_buff *skb;
+	u8 *rdptr;
+	bool good_packet;
+	static int rxlen_last;
+	unsigned int reg_val;
+	u32 rxhdr, rxstatus, rxcount, rxlen;
+
+	/* Check packet ready or not */
+	while (1) {
+		/* race warning: the first packet might arrive with
+		 * the interrupts disabled, but the second will fix
+		 * it
+		 */
+		rxcount = readl(db->membase + EMAC_RX_FBC_REG);
+
+		if (netif_msg_rx_status(db))
+			dev_dbg(db->dev, "RXCount: %x\n", rxcount);
+
+		if ((db->skb_last != NULL) && (rxlen_last > 0)) {
+			dev->stats.rx_bytes += rxlen_last;
+
+			/* Pass to upper layer */
+			db->skb_last->protocol = eth_type_trans(db->skb_last,
+								dev);
+			netif_rx(db->skb_last);
+			dev->stats.rx_packets++;
+			db->skb_last = NULL;
+			rxlen_last = 0;
+
+			reg_val = readl(db->membase + EMAC_RX_CTL_REG);
+			reg_val &= ~EMAC_RX_CTL_DMA_EN;
+			writel(reg_val, db->membase + EMAC_RX_CTL_REG);
+		}
+
+		if (!rxcount) {
+			emacrx_completed_flag = 1;
+			reg_val = readl(db->membase + EMAC_INT_CTL_REG);
+			reg_val |= (0xf << 0) | (0x01 << 8);
+			writel(reg_val, db->membase + EMAC_INT_CTL_REG);
+
+			/* had one stuck? */
+			rxcount = readl(db->membase + EMAC_RX_FBC_REG);
+			if (!rxcount)
+				return;
+		}
+
+		reg_val = readl(db->membase + EMAC_RX_IO_DATA_REG);
+		if (netif_msg_rx_status(db))
+			dev_dbg(db->dev, "receive header: %x\n", reg_val);
+		if (reg_val != 0x0143414d) {
+			/* disable RX */
+			reg_val = readl(db->membase + EMAC_CTL_REG);
+			writel(reg_val & ~EMAC_CTL_RX_EN,
+			       db->membase + EMAC_CTL_REG);
+
+			/* Flush RX FIFO */
+			reg_val = readl(db->membase + EMAC_RX_CTL_REG);
+			writel(reg_val | (1 << 3),
+			       db->membase + EMAC_RX_CTL_REG);
+
+			do {
+				reg_val = readl(db->membase + EMAC_RX_CTL_REG);
+			} while (reg_val & (1 << 3));
+
+			/* enable RX */
+			reg_val = readl(db->membase + EMAC_CTL_REG);
+			writel(reg_val | EMAC_CTL_RX_EN,
+			       db->membase + EMAC_CTL_REG);
+			reg_val = readl(db->membase + EMAC_INT_CTL_REG);
+			reg_val |= (0xf << 0) | (0x01 << 8);
+			writel(reg_val, db->membase + EMAC_INT_CTL_REG);
+
+			emacrx_completed_flag = 1;
+
+			return;
+		}
+
+		/* A packet ready now  & Get status/length */
+		good_packet = true;
+
+		wemac_inblk_32bit(db->membase + EMAC_RX_IO_DATA_REG,
+				&rxhdr, sizeof(rxhdr));
+
+		if (netif_msg_rx_status(db))
+			dev_dbg(db->dev, "rxhdr: %x\n", *((int *)(&rxhdr)));
+
+		rxlen = EMAC_RX_IO_DATA_LEN(rxhdr);
+		rxstatus = EMAC_RX_IO_DATA_STATUS(rxhdr);
+
+		if (netif_msg_rx_status(db))
+			dev_dbg(db->dev, "RX: status %02x, length %04x\n",
+				rxstatus, rxlen);
+
+		/* Packet Status check */
+		if (rxlen < 0x40) {
+			good_packet = false;
+			if (netif_msg_rx_err(db))
+				dev_dbg(db->dev, "RX: Bad Packet (runt)\n");
+		}
+
+		if (unlikely(!(rxstatus & EMAC_RX_IO_DATA_STATUS_OK))) {
+			good_packet = false;
+
+			if (rxstatus & EMAC_RX_IO_DATA_STATUS_CRC_ERR) {
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "crc error\n");
+				dev->stats.rx_crc_errors++;
+			}
+
+			if (rxstatus & EMAC_RX_IO_DATA_STATUS_LEN_ERR) {
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "length error\n");
+				dev->stats.rx_length_errors++;
+			}
+		}
+
+		/* Move data from WEMAC */
+		skb = dev_alloc_skb(rxlen + 4);
+		if (good_packet && skb) {
+			skb_reserve(skb, 2);
+			rdptr = (u8 *) skb_put(skb, rxlen - 4);
+
+			/* Read received packet from RX SRAM */
+			if (netif_msg_rx_status(db))
+				dev_dbg(db->dev, "RxLen %x\n", rxlen);
+
+			wemac_inblk_32bit(db->membase + EMAC_RX_IO_DATA_REG,
+					rdptr, rxlen);
+			dev->stats.rx_bytes += rxlen;
+
+			/* Pass to upper layer */
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
+			dev->stats.rx_packets++;
+		} else {
+			/* need to dump the packet's data */
+			wemac_dumpblk_32bit(db->membase + EMAC_RX_IO_DATA_REG,
+				       rxlen);
+		}
+	}
+}
+
+static irqreturn_t wemac_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct wemac_board_info *db = netdev_priv(dev);
+	int int_status;
+	unsigned long flags;
+	unsigned int reg_val;
+
+	/* A real interrupt coming */
+
+	/* holders of db->lock must always block IRQs */
+	spin_lock_irqsave(&db->lock, flags);
+
+	/* Disable all interrupts */
+	writel(0, db->membase + EMAC_INT_CTL_REG);
+
+	/* Got WEMAC interrupt status */
+	/* Got ISR */
+	int_status = readl(db->membase + EMAC_INT_STA_REG);
+	/* Clear ISR status */
+	writel(int_status, db->membase + EMAC_INT_STA_REG);
+
+	if (netif_msg_intr(db))
+		dev_dbg(db->dev, "emac interrupt %02x\n", int_status);
+
+	/* Received the coming packet */
+	if ((int_status & 0x100) && (emacrx_completed_flag == 1)) {
+		/* carrier lost */
+		emacrx_completed_flag = 0;
+		wemac_rx(dev);
+	}
+
+	/* Transmit Interrupt check */
+	if (int_status & (0x01 | 0x02))
+		wemac_tx_done(dev, db, int_status);
+
+	if (int_status & (0x04 | 0x08))
+		netdev_info(dev, " ab : %x\n", int_status);
+
+	/* Re-enable interrupt mask */
+	if (emacrx_completed_flag == 1) {
+		reg_val = readl(db->membase + EMAC_INT_CTL_REG);
+		reg_val |= (0xf << 0) | (0x01 << 8);
+		writel(reg_val, db->membase + EMAC_INT_CTL_REG);
+	}
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	return IRQ_HANDLED;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Used by netconsole
+ */
+static void wemac_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	wemac_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
+/*  Open the interface.
+ *  The interface is opened whenever "ifconfig" actives it.
+ */
+static int wemac_open(struct net_device *dev)
+{
+	struct wemac_board_info *db = netdev_priv(dev);
+
+	if (netif_msg_ifup(db))
+		dev_dbg(db->dev, "enabling %s\n", dev->name);
+
+	if (devm_request_irq(db->dev, dev->irq, &wemac_interrupt,
+			     0, dev->name, dev))
+		return -EAGAIN;
+
+	/* Initialize WEMAC board */
+	wemac_reset(db);
+	wemac_init_wemac(dev);
+
+	mii_check_media(&db->mii, netif_msg_link(db), 1);
+	netif_start_queue(dev);
+
+	wemac_schedule_poll(db);
+
+	return 0;
+}
+
+static void wemac_shutdown(struct net_device *dev)
+{
+	unsigned int reg_val;
+	struct wemac_board_info *db = netdev_priv(dev);
+
+	/* RESET device */
+	reg_val = wemac_phy_read(dev, WEMAC_PHY, 0);
+
+	/* PHY RESET */
+	wemac_phy_write(dev, WEMAC_PHY, 0, reg_val | (1 << 15));
+	udelay(10);
+	reg_val = wemac_phy_read(dev, WEMAC_PHY, 0);
+	if (reg_val & (1 << 15))
+		dev_warn(db->dev, "phy_reset not complete. value of reg0: %x\n",
+			 reg_val);
+	/* PHY POWER DOWN */
+	wemac_phy_write(dev, WEMAC_PHY, 0, reg_val | (1 << 11));
+
+	/* Disable all interrupt */
+	writel(0, db->membase + EMAC_INT_CTL_REG);
+
+	/* clear interupt status */
+	reg_val = readl(db->membase + EMAC_INT_STA_REG);
+	writel(reg_val, db->membase + EMAC_INT_STA_REG);
+
+	/* Disable RX/TX */
+	reg_val = readl(db->membase + EMAC_CTL_REG);
+	reg_val &= ~(EMAC_CTL_TX_EN | EMAC_CTL_RX_EN | EMAC_CTL_RESET);
+	writel(reg_val, db->membase + EMAC_CTL_REG);
+}
+
+/* Stop the interface.
+ * The interface is stopped when it is brought.
+ */
+static int wemac_stop(struct net_device *ndev)
+{
+	struct wemac_board_info *db = netdev_priv(ndev);
+
+	if (netif_msg_ifdown(db))
+		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
+
+	cancel_delayed_work_sync(&db->phy_poll);
+
+	netif_stop_queue(ndev);
+	netif_carrier_off(ndev);
+
+	wemac_shutdown(ndev);
+
+	return 0;
+}
+
+static const struct net_device_ops wemac_netdev_ops = {
+	.ndo_open		= wemac_open,
+	.ndo_stop		= wemac_stop,
+	.ndo_start_xmit		= wemac_start_xmit,
+	.ndo_tx_timeout		= wemac_timeout,
+	.ndo_do_ioctl		= wemac_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= wemac_set_mac_address,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= wemac_poll_controller,
+#endif
+};
+
+/* Search WEMAC board, allocate space and register it
+ */
+static int wemac_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct wemac_board_info *db;
+	struct net_device *ndev;
+	int ret = 0;
+	const char *mac_addr;
+
+	ndev = alloc_etherdev(sizeof(struct wemac_board_info));
+	if (!ndev) {
+		dev_err(&pdev->dev, "could not allocate device.\n");
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	db = netdev_priv(ndev);
+	memset(db, 0, sizeof(*db));
+
+	db->dev = &pdev->dev;
+	db->ndev = ndev;
+
+	spin_lock_init(&db->lock);
+	mutex_init(&db->phy_lock);
+
+	INIT_DELAYED_WORK(&db->phy_poll, wemac_poll_work);
+
+	db->membase = of_iomap(np, 0);
+	if (!db->membase) {
+		dev_err(&pdev->dev, "failed to remap registers\n");
+		return -ENOMEM;
+		goto out;
+	}
+
+	/* fill in parameters for net-dev structure */
+	ndev->base_addr = (unsigned long)db->membase;
+	ndev->irq = irq_of_parse_and_map(np, 0);
+	if (ndev->irq == -ENXIO) {
+		netdev_err(ndev, "No irq resource\n");
+		ret = ndev->irq;
+		goto out;
+	}
+
+	/* Read MAC-address from DT */
+	mac_addr = of_get_mac_address(np);
+	if (mac_addr)
+		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
+
+	/* Check if the MAC address is valid, if not get a random one */
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		eth_hw_addr_random(ndev);
+		dev_warn(&ndev->dev, "using random MAC address %pM\n",
+			 ndev->dev_addr);
+	}
+
+	db->power_gpio = of_get_named_gpio(np, "allwinner,power-gpios", 0);
+	if (gpio_is_valid(db->power_gpio)) {
+		ret = devm_gpio_request_one(&pdev->dev, db->power_gpio,
+					GPIOF_OUT_INIT_LOW, "wemac_power");
+		if (ret)
+			goto out;
+	} else {
+		if (db->power_gpio == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+	}
+
+	wemac_powerup(ndev);
+	wemac_reset(db);
+
+	ether_setup(ndev);
+
+	ndev->netdev_ops = &wemac_netdev_ops;
+	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
+	ndev->ethtool_ops = &wemac_ethtool_ops;
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	ndev->poll_controller = &wemac_poll_controller;
+#endif
+
+	db->msg_enable =
+		0xffffffff & (~NETIF_MSG_TX_DONE) & (~NETIF_MSG_INTR) &
+		(~NETIF_MSG_RX_STATUS);
+	db->mii.phy_id = WEMAC_PHY;
+	db->mii.phy_id_mask = 0x1f;
+	db->mii.reg_num_mask = 0x1f;
+	/* change force_media value to 0 to force check link status */
+	db->mii.force_media = 0;
+	/* change full_duplex value to 0 to set initial duplex as half */
+	db->mii.full_duplex = 0;
+	db->mii.dev = ndev;
+	db->mii.mdio_read = wemac_phy_read;
+	db->mii.mdio_write = wemac_phy_write;
+
+	platform_set_drvdata(pdev, ndev);
+	ret = register_netdev(ndev);
+	if (ret) {
+		dev_err(&pdev->dev, "Registering netdev failed!\n");
+		ret = -ENODEV;
+		goto out;
+	}
+
+	dev_info(&pdev->dev, "%s: at %p, IRQ %d MAC: %pM\n",
+		 ndev->name, db->membase, ndev->irq, ndev->dev_addr);
+
+	return 0;
+
+out:
+	dev_err(db->dev, "not found (%d).\n", ret);
+
+	free_netdev(ndev);
+
+	return ret;
+}
+
+static int wemac_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+
+	platform_set_drvdata(pdev, NULL);
+
+	unregister_netdev(ndev);
+	free_netdev(ndev);
+
+	dev_dbg(&pdev->dev, "released and freed device\n");
+	return 0;
+}
+
+static int wemac_suspend(struct platform_device *dev, pm_message_t state)
+{
+	struct net_device *ndev = platform_get_drvdata(dev);
+	struct wemac_board_info *db = netdev_priv(ndev);
+
+	if (mii_link_ok(&db->mii))
+		netif_carrier_off(ndev);
+	netif_device_detach(ndev);
+	wemac_shutdown(ndev);
+
+	return 0;
+}
+
+static int wemac_resume(struct platform_device *dev)
+{
+	struct net_device *ndev = platform_get_drvdata(dev);
+	struct wemac_board_info *db = netdev_priv(ndev);
+
+	wemac_reset(db);
+	wemac_init_wemac(ndev);
+	netif_device_attach(ndev);
+	if (mii_link_ok(&db->mii))
+		netif_carrier_on(ndev);
+
+	return 0;
+}
+
+static const struct of_device_id wemac_of_match[] = {
+	{.compatible = "davicom,wemac",},
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, wemac_of_match);
+
+static struct platform_driver wemac_driver = {
+	.driver = {
+		.name = "davicom-wemac",
+		.of_match_table = wemac_of_match,
+	},
+	.probe = wemac_probe,
+	.remove = wemac_remove,
+	.suspend = wemac_suspend,
+	.resume = wemac_resume,
+};
+
+module_platform_driver(wemac_driver);
+
+MODULE_AUTHOR("Stefan Roese <sr@denx.de>");
+MODULE_AUTHOR("Maxime Ripard <maxime.ripard@free-electrons.com>");
+MODULE_DESCRIPTION("Allwinner sunxi wemac network driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/davicom/wemac.h b/drivers/net/ethernet/davicom/wemac.h
new file mode 100644
index 0000000..5758c7d
--- /dev/null
+++ b/drivers/net/ethernet/davicom/wemac.h
@@ -0,0 +1,130 @@
+/*
+ * drivers/net/sun4i/sun4i_wemac.h
+ *
+ * (C) Copyright 2007-2012
+ * Allwinner Technology Co., Ltd. <www.allwinnertech.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
+ * MA 02111-1307 USA
+ */
+
+#ifndef _WEMAC_H_
+#define _WEMAC_H_
+
+#define EMAC_CTL_REG		(0x00)
+#define EMAC_CTL_RESET			(1 << 0)
+#define EMAC_CTL_TX_EN			(1 << 1)
+#define EMAC_CTL_RX_EN			(1 << 2)
+#define EMAC_TX_MODE_REG	(0x04)
+#define EMAC_TX_MODE_ABORTED_FRAME_EN	(1 << 0)
+#define EMAC_TX_MODE_DMA_EN		(1 << 1)
+#define EMAC_TX_FLOW_REG	(0x08)
+#define EMAC_TX_CTL0_REG	(0x0c)
+#define EMAC_TX_CTL1_REG	(0x10)
+#define EMAC_TX_INS_REG		(0x14)
+#define EMAC_TX_PL0_REG		(0x18)
+#define EMAC_TX_PL1_REG		(0x1c)
+#define EMAC_TX_STA_REG		(0x20)
+#define EMAC_TX_IO_DATA_REG	(0x24)
+#define EMAC_TX_IO_DATA1_REG	(0x28)
+#define EMAC_TX_TSVL0_REG	(0x2c)
+#define EMAC_TX_TSVH0_REG	(0x30)
+#define EMAC_TX_TSVL1_REG	(0x34)
+#define EMAC_TX_TSVH1_REG	(0x38)
+#define EMAC_RX_CTL_REG		(0x3c)
+#define EMAC_RX_CTL_AUTO_DRQ_EN		(1 << 1)
+#define EMAC_RX_CTL_DMA_EN		(1 << 2)
+#define EMAC_RX_CTL_PASS_ALL_EN		(1 << 4)
+#define EMAC_RX_CTL_PASS_CTL_EN		(1 << 5)
+#define EMAC_RX_CTL_PASS_CRC_ERR_EN	(1 << 6)
+#define EMAC_RX_CTL_PASS_LEN_ERR_EN	(1 << 7)
+#define EMAC_RX_CTL_PASS_LEN_OOR_EN	(1 << 8)
+#define EMAC_RX_CTL_ACCEPT_UNICAST_EN	(1 << 16)
+#define EMAC_RX_CTL_DA_FILTER_EN	(1 << 17)
+#define EMAC_RX_CTL_ACCEPT_MULTICAST_EN	(1 << 20)
+#define EMAC_RX_CTL_HASH_FILTER_EN	(1 << 21)
+#define EMAC_RX_CTL_ACCEPT_BROADCAST_EN	(1 << 22)
+#define EMAC_RX_CTL_SA_FILTER_EN	(1 << 24)
+#define EMAC_RX_CTL_SA_FILTER_INVERT_EN	(1 << 25)
+#define EMAC_RX_HASH0_REG	(0x40)
+#define EMAC_RX_HASH1_REG	(0x44)
+#define EMAC_RX_STA_REG		(0x48)
+#define EMAC_RX_IO_DATA_REG	(0x4c)
+#define EMAC_RX_IO_DATA_LEN(x)		(x & 0xffff)
+#define EMAC_RX_IO_DATA_STATUS(x)	((x >> 16) & 0xffff)
+#define EMAC_RX_IO_DATA_STATUS_CRC_ERR	(1 << 4)
+#define EMAC_RX_IO_DATA_STATUS_LEN_ERR	(3 << 5)
+#define EMAC_RX_IO_DATA_STATUS_OK	(1 << 7)
+#define EMAC_RX_FBC_REG		(0x50)
+#define EMAC_INT_CTL_REG	(0x54)
+#define EMAC_INT_STA_REG	(0x58)
+#define EMAC_MAC_CTL0_REG	(0x5c)
+#define EMAC_MAC_CTL0_RX_FLOW_CTL_EN	(1 << 2)
+#define EMAC_MAC_CTL0_TX_FLOW_CTL_EN	(1 << 3)
+#define EMAC_MAC_CTL0_SOFT_RESET	(1 << 15)
+#define EMAC_MAC_CTL1_REG	(0x60)
+#define EMAC_MAC_CTL1_DUPLEX_EN		(1 << 0)
+#define EMAC_MAC_CTL1_LEN_CHECK_EN	(1 << 1)
+#define EMAC_MAC_CTL1_HUGE_FRAME_EN	(1 << 2)
+#define EMAC_MAC_CTL1_DELAYED_CRC_EN	(1 << 3)
+#define EMAC_MAC_CTL1_CRC_EN		(1 << 4)
+#define EMAC_MAC_CTL1_PAD_EN		(1 << 5)
+#define EMAC_MAC_CTL1_PAD_CRC_EN	(1 << 6)
+#define EMAC_MAC_CTL1_AD_SHORT_FRAME_EN	(1 << 7)
+#define EMAC_MAC_CTL1_BACKOFF_DIS	(1 << 12)
+#define EMAC_MAC_IPGT_REG	(0x64)
+#define EMAC_MAC_IPGT_HALF_DUPLEX	(0x12)
+#define EMAC_MAC_IPGT_FULL_DUPLEX	(0x15)
+#define EMAC_MAC_IPGR_REG	(0x68)
+#define EMAC_MAC_IPGR_IPG1		(0x0c)
+#define EMAC_MAC_IPGR_IPG2		(0x12)
+#define EMAC_MAC_CLRT_REG	(0x6c)
+#define EMAC_MAC_CLRT_COLLISION_WINDOW	(0x37)
+#define EMAC_MAC_CLRT_RM		(0x0f)
+#define EMAC_MAC_MAXF_REG	(0x70)
+#define EMAC_MAC_SUPP_REG	(0x74)
+#define EMAC_MAC_TEST_REG	(0x78)
+#define EMAC_MAC_MCFG_REG	(0x7c)
+#define EMAC_MAC_MCMD_REG	(0x80)
+#define EMAC_MAC_MADR_REG	(0x84)
+#define EMAC_MAC_MWTD_REG	(0x88)
+#define EMAC_MAC_MRDD_REG	(0x8c)
+#define EMAC_MAC_MIND_REG	(0x90)
+#define EMAC_MAC_SSRR_REG	(0x94)
+#define EMAC_MAC_A0_REG		(0x98)
+#define EMAC_MAC_A1_REG		(0x9c)
+#define EMAC_MAC_A2_REG		(0xa0)
+#define EMAC_SAFX_L_REG0	(0xa4)
+#define EMAC_SAFX_H_REG0	(0xa8)
+#define EMAC_SAFX_L_REG1	(0xac)
+#define EMAC_SAFX_H_REG1	(0xb0)
+#define EMAC_SAFX_L_REG2	(0xb4)
+#define EMAC_SAFX_H_REG2	(0xb8)
+#define EMAC_SAFX_L_REG3	(0xbc)
+#define EMAC_SAFX_H_REG3	(0xc0)
+
+#define EMAC_PHY_DUPLEX		(1 << 8)
+
+#define WEMAC_PLATF_8BITONLY	(1 << 0)
+#define WEMAC_PLATF_16BITONLY	(1 << 1)
+#define WEMAC_PLATF_32BITONLY	(1 << 2)
+#define WEMAC_PLATF_EXT_PHY	(1 << 3)
+#define WEMAC_PLATF_NO_EEPROM	(1 << 4)
+/* Use NSR to find LinkStatus */
+#define WEMAC_PLATF_SIMPLE_PHY	(1 << 5)
+
+#define EMAC_EEPROM_MAGIC	(0x444D394B)
+
+#endif /* _WEMAC_H_ */
-- 
1.7.10.4

