From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 02/12] net-next: mediatek: add the drivers core files
Date: Fri, 26 Feb 2016 15:21:34 +0100
Message-ID: <1456496504-50429-3-git-send-email-blogic@openwrt.org>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
 <Fred.Chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 =?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
 <steven.liu-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
 <Carlos.Huang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1456496504-50429-1-git-send-email-blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the main chunk of the driver. The ethernet core is used in
all of the Mediatek/Ralink Wireless SoCs. Over the years we have seen
various changes to
* the register layout
* the type of ports (single/dual gbit, internal FE/Gbit switch)
* dma engine (PDMA/QDMA)

and new offloading features were added, such as
* checksum
* VLAN TX/RX
* TSO
* LRO

The core functionality has however remained the same allowing us to use
the same code for all SoCs.

The abstraction for the various SoCs uses the typical ops struct pattern
which allows us to extend or override the core functionality depending on
which SoC we are on. The code to bring up the switches and external ports
has also been split into separate files.

There are 2 types of DMA engine, PDMA and the newer QDMA. PDMA uses a
typical ring buffer while QDMA uses a linked list. Unfortunatley we have
the MT7621 which has a few silicon issues. Due to these issues we need to
PDMA for RX and QDMA for TX. All SoCs newer than the MT7621 can can run on
QDMA exclusively.

Most of the SoCs have a switch frontend. Older silicon has a so called ESW
(Ethernet Switch) while newer cores have a GSW (Gigabit switch).
Additionally there is a MDIO bus that can be used to talk to PHYs. In these
cases one switch port get changed into a normal MAC port.

Some SoCs have a dual MAC, we currently only support this on MT7623.

Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Signed-off-by: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Signed-off-by: Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/ethtool.c     |  223 +++
 drivers/net/ethernet/mediatek/ethtool.h     |   22 +
 drivers/net/ethernet/mediatek/mdio.c        |  265 ++++
 drivers/net/ethernet/mediatek/mdio.h        |   27 +
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2170 +++++++++++++++++++++++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  720 +++++++++
 6 files changed, 3427 insertions(+)
 create mode 100644 drivers/net/ethernet/mediatek/ethtool.c
 create mode 100644 drivers/net/ethernet/mediatek/ethtool.h
 create mode 100644 drivers/net/ethernet/mediatek/mdio.c
 create mode 100644 drivers/net/ethernet/mediatek/mdio.h
 create mode 100644 drivers/net/ethernet/mediatek/mtk_eth_soc.c
 create mode 100644 drivers/net/ethernet/mediatek/mtk_eth_soc.h

diff --git a/drivers/net/ethernet/mediatek/ethtool.c b/drivers/net/ethernet/mediatek/ethtool.c
new file mode 100644
index 0000000..8c63685
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/ethtool.c
@@ -0,0 +1,223 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include "mtk_eth_soc.h"
+
+static const char mtk_gdma_str[][ETH_GSTRING_LEN] = {
+#define _FE(x...)	# x,
+MTK_STAT_REG_DECLARE
+#undef _FE
+};
+
+static int mtk_get_settings(struct net_device *dev,
+			    struct ethtool_cmd *cmd)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	int err;
+
+	if (!mac->phy_dev)
+		return -ENODEV;
+
+	if (mac->phy_flags == MTK_PHY_FLAG_ATTACH) {
+		err = phy_read_status(mac->phy_dev);
+		if (err)
+			return -ENODEV;
+	}
+
+	return phy_ethtool_gset(mac->phy_dev, cmd);
+}
+
+static int mtk_set_settings(struct net_device *dev,
+			    struct ethtool_cmd *cmd)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+
+	if (!mac->phy_dev)
+		return -ENODEV;
+
+	if (cmd->phy_address != mac->phy_dev->addr) {
+		if (mac->hw->phy->phy_node[cmd->phy_address]) {
+			mac->phy_dev = mac->hw->phy->phy[cmd->phy_address];
+			mac->phy_flags = MTK_PHY_FLAG_PORT;
+		} else if (mac->hw->mii_bus &&
+			   mac->hw->mii_bus->phy_map[cmd->phy_address]) {
+			mac->phy_dev =
+				mac->hw->mii_bus->phy_map[cmd->phy_address];
+			mac->phy_flags = MTK_PHY_FLAG_ATTACH;
+		} else {
+			return -ENODEV;
+		}
+	}
+
+	return phy_ethtool_sset(mac->phy_dev, cmd);
+}
+
+static void mtk_get_drvinfo(struct net_device *dev,
+			    struct ethtool_drvinfo *info)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_soc_data *soc = mac->hw->soc;
+
+	strlcpy(info->driver, mac->hw->dev->driver->name, sizeof(info->driver));
+	strlcpy(info->bus_info, dev_name(mac->hw->dev), sizeof(info->bus_info));
+
+	if (soc->reg_table[MTK_REG_MTK_COUNTER_BASE])
+		info->n_stats = ARRAY_SIZE(mtk_gdma_str);
+}
+
+static u32 mtk_get_msglevel(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+
+	return mac->hw->msg_enable;
+}
+
+static void mtk_set_msglevel(struct net_device *dev, u32 value)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+
+	mac->hw->msg_enable = value;
+}
+
+static int mtk_nway_reset(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+
+	if (!mac->phy_dev)
+		return -EOPNOTSUPP;
+
+	return genphy_restart_aneg(mac->phy_dev);
+}
+
+static u32 mtk_get_link(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	int err;
+
+	if (!mac->phy_dev)
+		goto out_get_link;
+
+	if (mac->phy_flags == MTK_PHY_FLAG_ATTACH) {
+		err = genphy_update_link(mac->phy_dev);
+		if (err)
+			goto out_get_link;
+	}
+
+	return mac->phy_dev->link;
+
+out_get_link:
+	return ethtool_op_get_link(dev);
+}
+
+static int mtk_set_ringparam(struct net_device *dev,
+			     struct ethtool_ringparam *ring)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+
+	if ((ring->tx_pending < 2) ||
+	    (ring->rx_pending < 2) ||
+	    (ring->rx_pending > mac->hw->soc->dma_ring_size) ||
+	    (ring->tx_pending > mac->hw->soc->dma_ring_size))
+		return -EINVAL;
+
+	dev->netdev_ops->ndo_stop(dev);
+
+	mac->hw->tx_ring.tx_ring_size = BIT(fls(ring->tx_pending) - 1);
+	mac->hw->rx_ring[0].rx_ring_size = BIT(fls(ring->rx_pending) - 1);
+
+	return dev->netdev_ops->ndo_open(dev);
+}
+
+static void mtk_get_ringparam(struct net_device *dev,
+			      struct ethtool_ringparam *ring)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+
+	ring->rx_max_pending = mac->hw->soc->dma_ring_size;
+	ring->tx_max_pending = mac->hw->soc->dma_ring_size;
+	ring->rx_pending = mac->hw->rx_ring[0].rx_ring_size;
+	ring->tx_pending = mac->hw->tx_ring.tx_ring_size;
+}
+
+static void mtk_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *mtk_gdma_str, sizeof(mtk_gdma_str));
+		break;
+	}
+}
+
+static int mtk_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(mtk_gdma_str);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void mtk_get_ethtool_stats(struct net_device *dev,
+				  struct ethtool_stats *stats, u64 *data)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_hw_stats *hwstats = mac->hw_stats;
+	u64 *data_src, *data_dst;
+	unsigned int start;
+	int i;
+
+	if (netif_running(dev) && netif_device_present(dev)) {
+		if (spin_trylock(&hwstats->stats_lock)) {
+			mtk_stats_update_mac(mac);
+			spin_unlock(&hwstats->stats_lock);
+		}
+	}
+
+	do {
+		data_src = &hwstats->tx_bytes;
+		data_dst = data;
+		start = u64_stats_fetch_begin_irq(&hwstats->syncp);
+
+		for (i = 0; i < ARRAY_SIZE(mtk_gdma_str); i++)
+			*data_dst++ = *data_src++;
+
+	} while (u64_stats_fetch_retry_irq(&hwstats->syncp, start));
+}
+
+static struct ethtool_ops mtk_ethtool_ops = {
+	.get_settings		= mtk_get_settings,
+	.set_settings		= mtk_set_settings,
+	.get_drvinfo		= mtk_get_drvinfo,
+	.get_msglevel		= mtk_get_msglevel,
+	.set_msglevel		= mtk_set_msglevel,
+	.nway_reset		= mtk_nway_reset,
+	.get_link		= mtk_get_link,
+	.set_ringparam		= mtk_set_ringparam,
+	.get_ringparam		= mtk_get_ringparam,
+};
+
+void mtk_set_ethtool_ops(struct net_device *netdev)
+{
+	struct mtk_mac *mac = netdev_priv(netdev);
+	struct mtk_soc_data *soc = mac->hw->soc;
+
+	if (soc->reg_table[MTK_REG_MTK_COUNTER_BASE]) {
+		mtk_ethtool_ops.get_strings = mtk_get_strings;
+		mtk_ethtool_ops.get_sset_count = mtk_get_sset_count;
+		mtk_ethtool_ops.get_ethtool_stats = mtk_get_ethtool_stats;
+	}
+
+	netdev->ethtool_ops = &mtk_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/mediatek/ethtool.h b/drivers/net/ethernet/mediatek/ethtool.h
new file mode 100644
index 0000000..40b4cf0
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/ethtool.h
@@ -0,0 +1,22 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef MTK_ETHTOOL_H
+#define MTK_ETHTOOL_H
+
+#include <linux/ethtool.h>
+
+void mtk_set_ethtool_ops(struct net_device *netdev);
+
+#endif /* MTK_ETHTOOL_H */
diff --git a/drivers/net/ethernet/mediatek/mdio.c b/drivers/net/ethernet/mediatek/mdio.c
new file mode 100644
index 0000000..f3f73f0
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/mdio.c
@@ -0,0 +1,265 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/phy.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+
+#include "mtk_eth_soc.h"
+#include "mdio.h"
+
+static int mtk_mdio_reset(struct mii_bus *bus)
+{
+	/* TODO */
+	return 0;
+}
+
+static void mtk_phy_link_adjust(struct net_device *dev)
+{
+	struct mtk_eth *eth = netdev_priv(dev);
+	unsigned long flags;
+	int i;
+
+	spin_lock_irqsave(&eth->phy->lock, flags);
+	for (i = 0; i < 8; i++) {
+		if (eth->phy->phy_node[i]) {
+			struct phy_device *phydev = eth->phy->phy[i];
+			int status_change = 0;
+
+			if (phydev->link)
+				if (eth->phy->duplex[i] != phydev->duplex ||
+				    eth->phy->speed[i] != phydev->speed)
+					status_change = 1;
+
+			if (phydev->link != eth->link[i])
+				status_change = 1;
+
+			switch (phydev->speed) {
+			case SPEED_1000:
+			case SPEED_100:
+			case SPEED_10:
+				eth->link[i] = phydev->link;
+				eth->phy->duplex[i] = phydev->duplex;
+				eth->phy->speed[i] = phydev->speed;
+
+				if (status_change &&
+				    eth->soc->mdio_adjust_link)
+					eth->soc->mdio_adjust_link(eth, i);
+				break;
+			}
+		}
+	}
+}
+
+int mtk_connect_phy_node(struct mtk_eth *eth, struct mtk_mac *mac,
+			 struct device_node *phy_node)
+{
+	const __be32 *_port = NULL;
+	struct phy_device *phydev;
+	int phy_mode, port;
+
+	_port = of_get_property(phy_node, "reg", NULL);
+
+	if (!_port || (be32_to_cpu(*_port) >= 0x20)) {
+		pr_err("%s: invalid port id\n", phy_node->name);
+		return -EINVAL;
+	}
+	port = be32_to_cpu(*_port);
+	phy_mode = of_get_phy_mode(phy_node);
+	if (phy_mode < 0) {
+		dev_err(eth->dev, "incorrect phy-mode %d\n", phy_mode);
+		eth->phy->phy_node[port] = NULL;
+		return -EINVAL;
+	}
+
+	phydev = of_phy_connect(eth->netdev[mac->id], phy_node,
+				mtk_phy_link_adjust, 0, phy_mode);
+	if (IS_ERR(phydev)) {
+		dev_err(eth->dev, "could not connect to PHY\n");
+		eth->phy->phy_node[port] = NULL;
+		return PTR_ERR(phydev);
+	}
+
+	phydev->supported &= PHY_GBIT_FEATURES;
+	phydev->advertising = phydev->supported;
+
+	dev_info(eth->dev,
+		 "connected port %d to PHY at %s [uid=%08x, driver=%s]\n",
+		 port, dev_name(&phydev->dev), phydev->phy_id,
+		 phydev->drv->name);
+
+	eth->phy->phy[port] = phydev;
+	eth->link[port] = 0;
+
+	return 0;
+}
+
+static void phy_init(struct mtk_eth *eth, struct mtk_mac *mac,
+		     struct phy_device *phy)
+{
+	phy_attach(eth->netdev[mac->id], dev_name(&phy->dev),
+		   PHY_INTERFACE_MODE_MII);
+
+	phy->autoneg = AUTONEG_ENABLE;
+	phy->speed = 0;
+	phy->duplex = 0;
+	phy->supported &= PHY_BASIC_FEATURES;
+	phy->advertising = phy->supported | ADVERTISED_Autoneg;
+
+	phy_start_aneg(phy);
+}
+
+static int mtk_phy_connect(struct mtk_mac *mac)
+{
+	struct mtk_eth *eth = mac->hw;
+	int i;
+
+	for (i = 0; i < 8; i++) {
+		if (eth->phy->phy_node[i]) {
+			if (!mac->phy_dev) {
+				mac->phy_dev = eth->phy->phy[i];
+				mac->phy_flags = MTK_PHY_FLAG_PORT;
+			}
+		} else if (eth->mii_bus && eth->mii_bus->phy_map[i]) {
+			phy_init(eth, mac, eth->mii_bus->phy_map[i]);
+			if (!mac->phy_dev) {
+				mac->phy_dev = eth->mii_bus->phy_map[i];
+				mac->phy_flags = MTK_PHY_FLAG_ATTACH;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static void mtk_phy_disconnect(struct mtk_mac *mac)
+{
+	struct mtk_eth *eth = mac->hw;
+	unsigned long flags;
+	int i;
+
+	for (i = 0; i < 8; i++)
+		if (eth->phy->phy_fixed[i]) {
+			spin_lock_irqsave(&eth->phy->lock, flags);
+			eth->link[i] = 0;
+			if (eth->soc->mdio_adjust_link)
+				eth->soc->mdio_adjust_link(eth, i);
+			spin_unlock_irqrestore(&eth->phy->lock, flags);
+		} else if (eth->phy->phy[i]) {
+			phy_disconnect(eth->phy->phy[i]);
+		} else if (eth->mii_bus && eth->mii_bus->phy_map[i]) {
+			phy_detach(eth->mii_bus->phy_map[i]);
+		}
+}
+
+static void mtk_phy_start(struct mtk_mac *mac)
+{
+	struct mtk_eth *eth = mac->hw;
+	unsigned long flags;
+	int i;
+
+	for (i = 0; i < 8; i++) {
+		if (eth->phy->phy_fixed[i]) {
+			spin_lock_irqsave(&eth->phy->lock, flags);
+			eth->link[i] = 1;
+			if (eth->soc->mdio_adjust_link)
+				eth->soc->mdio_adjust_link(eth, i);
+			spin_unlock_irqrestore(&eth->phy->lock, flags);
+		} else if (eth->phy->phy[i]) {
+			phy_start(eth->phy->phy[i]);
+		}
+	}
+}
+
+static void mtk_phy_stop(struct mtk_mac *mac)
+{
+	struct mtk_eth *eth = mac->hw;
+	unsigned long flags;
+	int i;
+
+	for (i = 0; i < 8; i++)
+		if (eth->phy->phy_fixed[i]) {
+			spin_lock_irqsave(&eth->phy->lock, flags);
+			eth->link[i] = 0;
+			if (eth->soc->mdio_adjust_link)
+				eth->soc->mdio_adjust_link(eth, i);
+			spin_unlock_irqrestore(&eth->phy->lock, flags);
+		} else if (eth->phy->phy[i]) {
+			phy_stop(eth->phy->phy[i]);
+		}
+}
+
+static struct mtk_phy phy_ralink = {
+	.connect = mtk_phy_connect,
+	.disconnect = mtk_phy_disconnect,
+	.start = mtk_phy_start,
+	.stop = mtk_phy_stop,
+};
+
+int mtk_mdio_init(struct mtk_eth *eth)
+{
+	struct device_node *mii_np;
+	int err;
+
+	if (!eth->soc->mdio_read || !eth->soc->mdio_write)
+		return 0;
+
+	spin_lock_init(&phy_ralink.lock);
+	eth->phy = &phy_ralink;
+
+	mii_np = of_get_child_by_name(eth->dev->of_node, "mdio-bus");
+	if (!mii_np) {
+		dev_err(eth->dev, "no %s child node found", "mdio-bus");
+		return -ENODEV;
+	}
+
+	if (!of_device_is_available(mii_np)) {
+		err = 0;
+		goto err_put_node;
+	}
+
+	eth->mii_bus = mdiobus_alloc();
+	if (!eth->mii_bus) {
+		err = -ENOMEM;
+		goto err_put_node;
+	}
+
+	eth->mii_bus->name = "mdio";
+	eth->mii_bus->read = eth->soc->mdio_read;
+	eth->mii_bus->write = eth->soc->mdio_write;
+	eth->mii_bus->reset = mtk_mdio_reset;
+	eth->mii_bus->priv = eth;
+	eth->mii_bus->parent = eth->dev;
+
+	snprintf(eth->mii_bus->id, MII_BUS_ID_SIZE, "%s", mii_np->name);
+	err = of_mdiobus_register(eth->mii_bus, mii_np);
+	if (err)
+		goto err_free_bus;
+
+	return 0;
+
+err_free_bus:
+	kfree(eth->mii_bus);
+err_put_node:
+	of_node_put(mii_np);
+	eth->mii_bus = NULL;
+	return err;
+}
+
+void mtk_mdio_cleanup(struct mtk_eth *eth)
+{
+	if (!eth->mii_bus)
+		return;
+
+	mdiobus_unregister(eth->mii_bus);
+	of_node_put(eth->mii_bus->dev.of_node);
+	kfree(eth->mii_bus);
+}
diff --git a/drivers/net/ethernet/mediatek/mdio.h b/drivers/net/ethernet/mediatek/mdio.h
new file mode 100644
index 0000000..b14e238
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/mdio.h
@@ -0,0 +1,27 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef _RALINK_MDIO_H__
+#define _RALINK_MDIO_H__
+
+#ifdef CONFIG_NET_MEDIATEK_MDIO
+int mtk_mdio_init(struct mtk_eth *eth);
+void mtk_mdio_cleanup(struct mtk_eth *eth);
+int mtk_connect_phy_node(struct mtk_eth *eth, struct mtk_mac *mac,
+			 struct device_node *phy_node);
+#else
+static inline int mtk_mdio_init(struct mtk_eth *eth) { return 0; }
+static inline void mtk_mdio_cleanup(struct mtk_eth *eth) {}
+#endif
+#endif
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
new file mode 100644
index 0000000..079cf8b
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -0,0 +1,2170 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/dma-mapping.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/platform_device.h>
+#include <linux/of_device.h>
+#include <linux/mfd/syscon.h>
+#include <linux/clk.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/if_vlan.h>
+#include <linux/reset.h>
+#include <linux/tcp.h>
+#include <linux/io.h>
+#include <linux/bug.h>
+#include <linux/regmap.h>
+
+#include "mtk_eth_soc.h"
+#include "mdio.h"
+#include "ethtool.h"
+
+#define	MAX_RX_LENGTH		1536
+#define MTK_RX_ETH_HLEN		(VLAN_ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN)
+#define MTK_RX_HLEN		(NET_SKB_PAD + MTK_RX_ETH_HLEN + NET_IP_ALIGN)
+#define DMA_DUMMY_DESC		0xffffffff
+#define MTK_DEFAULT_MSG_ENABLE \
+		(NETIF_MSG_DRV | \
+		NETIF_MSG_PROBE | \
+		NETIF_MSG_LINK | \
+		NETIF_MSG_TIMER | \
+		NETIF_MSG_IFDOWN | \
+		NETIF_MSG_IFUP | \
+		NETIF_MSG_RX_ERR | \
+		NETIF_MSG_TX_ERR)
+
+#define TX_DMA_DESP2_DEF	(TX_DMA_LS0 | TX_DMA_DONE)
+#define NEXT_TX_DESP_IDX(X)	(((X) + 1) & (ring->tx_ring_size - 1))
+#define NEXT_RX_DESP_IDX(X)	(((X) + 1) & (ring->rx_ring_size - 1))
+
+#define SYSC_REG_RSTCTRL	0x34
+
+static int mtk_msg_level = -1;
+module_param_named(msg_level, mtk_msg_level, int, 0);
+MODULE_PARM_DESC(msg_level, "Message level (-1=defaults,0=none,...,16=all)");
+
+static const u16 mtk_reg_table_default[MTK_REG_COUNT] = {
+	[MTK_REG_PDMA_GLO_CFG] = MTK_PDMA_GLO_CFG,
+	[MTK_REG_PDMA_RST_CFG] = MTK_PDMA_RST_CFG,
+	[MTK_REG_DLY_INT_CFG] = MTK_DLY_INT_CFG,
+	[MTK_REG_TX_BASE_PTR0] = MTK_TX_BASE_PTR0,
+	[MTK_REG_TX_MAX_CNT0] = MTK_TX_MAX_CNT0,
+	[MTK_REG_TX_CTX_IDX0] = MTK_TX_CTX_IDX0,
+	[MTK_REG_TX_DTX_IDX0] = MTK_TX_DTX_IDX0,
+	[MTK_REG_RX_BASE_PTR0] = MTK_RX_BASE_PTR0,
+	[MTK_REG_RX_MAX_CNT0] = MTK_RX_MAX_CNT0,
+	[MTK_REG_RX_CALC_IDX0] = MTK_RX_CALC_IDX0,
+	[MTK_REG_RX_DRX_IDX0] = MTK_RX_DRX_IDX0,
+	[MTK_REG_MTK_INT_ENABLE] = MTK_INT_ENABLE,
+	[MTK_REG_MTK_INT_STATUS] = MTK_INT_STATUS,
+	[MTK_REG_MTK_DMA_VID_BASE] = MTK_DMA_VID0,
+	[MTK_REG_MTK_COUNTER_BASE] = MTK_GDMA1_TX_GBCNT,
+	[MTK_REG_MTK_RST_GL] = MTK_RST_GL,
+};
+
+static const u16 *mtk_reg_table = mtk_reg_table_default;
+
+void mtk_w32(struct mtk_eth *eth, u32 val, unsigned reg)
+{
+	__raw_writel(val, eth->base + reg);
+}
+
+u32 mtk_r32(struct mtk_eth *eth, unsigned reg)
+{
+	return __raw_readl(eth->base + reg);
+}
+
+static void mtk_reg_w32(struct mtk_eth *eth, u32 val, enum mtk_reg reg)
+{
+	mtk_w32(eth, val, mtk_reg_table[reg]);
+}
+
+static u32 mtk_reg_r32(struct mtk_eth *eth, enum mtk_reg reg)
+{
+	return mtk_r32(eth, mtk_reg_table[reg]);
+}
+
+/* these bits are also exposed via the reset-controller API. however the switch
+ * and FE need to be brought out of reset in the exakt same moemtn and the
+ * reset-controller api does not provide this feature yet. Do the reset manually
+ * until we fixed the reset-controller api to be able to do this
+ */
+void mtk_reset(struct mtk_eth *eth, u32 reset_bits)
+{
+	u32 val;
+
+	regmap_read(eth->ethsys, SYSC_REG_RSTCTRL, &val);
+	val |= reset_bits;
+	regmap_write(eth->ethsys, SYSC_REG_RSTCTRL, val);
+	usleep_range(10, 20);
+	val &= ~reset_bits;
+	regmap_write(eth->ethsys, SYSC_REG_RSTCTRL, val);
+	usleep_range(10, 20);
+}
+
+static inline void mtk_irq_ack(struct mtk_eth *eth, u32 mask)
+{
+	if (eth->soc->dma_type & MTK_PDMA)
+		mtk_reg_w32(eth, mask, MTK_REG_MTK_INT_STATUS);
+	if (eth->soc->dma_type & MTK_QDMA)
+		mtk_w32(eth, mask, MTK_QMTK_INT_STATUS);
+}
+
+static inline u32 mtk_irq_pending(struct mtk_eth *eth)
+{
+	u32 status = 0;
+
+	if (eth->soc->dma_type & MTK_PDMA)
+		status |= mtk_reg_r32(eth, MTK_REG_MTK_INT_STATUS);
+	if (eth->soc->dma_type & MTK_QDMA)
+		status |= mtk_r32(eth, MTK_QMTK_INT_STATUS);
+
+	return status;
+}
+
+static void mtk_irq_ack_status(struct mtk_eth *eth, u32 mask)
+{
+	u32 status_reg = MTK_REG_MTK_INT_STATUS;
+
+	if (mtk_reg_table[MTK_REG_MTK_INT_STATUS2])
+		status_reg = MTK_REG_MTK_INT_STATUS2;
+
+	mtk_reg_w32(eth, mask, status_reg);
+}
+
+static u32 mtk_irq_pending_status(struct mtk_eth *eth)
+{
+	u32 status_reg = MTK_REG_MTK_INT_STATUS;
+
+	if (mtk_reg_table[MTK_REG_MTK_INT_STATUS2])
+		status_reg = MTK_REG_MTK_INT_STATUS2;
+
+	return mtk_reg_r32(eth, status_reg);
+}
+
+static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
+{
+	u32 val;
+
+	if (eth->soc->dma_type & MTK_PDMA) {
+		val = mtk_reg_r32(eth, MTK_REG_MTK_INT_ENABLE);
+		mtk_reg_w32(eth, val & ~mask, MTK_REG_MTK_INT_ENABLE);
+		/* flush write */
+		mtk_reg_r32(eth, MTK_REG_MTK_INT_ENABLE);
+	}
+	if (eth->soc->dma_type & MTK_QDMA) {
+		val = mtk_r32(eth, MTK_QMTK_INT_ENABLE);
+		mtk_w32(eth, val & ~mask, MTK_QMTK_INT_ENABLE);
+		/* flush write */
+		mtk_r32(eth, MTK_QMTK_INT_ENABLE);
+	}
+}
+
+static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
+{
+	u32 val;
+
+	if (eth->soc->dma_type & MTK_PDMA) {
+		val = mtk_reg_r32(eth, MTK_REG_MTK_INT_ENABLE);
+		mtk_reg_w32(eth, val | mask, MTK_REG_MTK_INT_ENABLE);
+		/* flush write */
+		mtk_reg_r32(eth, MTK_REG_MTK_INT_ENABLE);
+	}
+	if (eth->soc->dma_type & MTK_QDMA) {
+		val = mtk_r32(eth, MTK_QMTK_INT_ENABLE);
+		mtk_w32(eth, val | mask, MTK_QMTK_INT_ENABLE);
+		/* flush write */
+		mtk_r32(eth, MTK_QMTK_INT_ENABLE);
+	}
+}
+
+static inline u32 mtk_irq_enabled(struct mtk_eth *eth)
+{
+	u32 enabled = 0;
+
+	if (eth->soc->dma_type & MTK_PDMA)
+		enabled |= mtk_reg_r32(eth, MTK_REG_MTK_INT_ENABLE);
+	if (eth->soc->dma_type & MTK_QDMA)
+		enabled |= mtk_r32(eth, MTK_QMTK_INT_ENABLE);
+
+	return enabled;
+}
+
+static inline void mtk_hw_set_macaddr(struct mtk_mac *mac,
+				      unsigned char *macaddr)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mac->hw->page_lock, flags);
+	mtk_w32(mac->hw, (macaddr[0] << 8) | macaddr[1], MTK_GDMA1_MAC_ADRH);
+	mtk_w32(mac->hw, (macaddr[2] << 24) | (macaddr[3] << 16) |
+		(macaddr[4] << 8) | macaddr[5],
+		MTK_GDMA1_MAC_ADRL);
+	spin_unlock_irqrestore(&mac->hw->page_lock, flags);
+}
+
+static int mtk_set_mac_address(struct net_device *dev, void *p)
+{
+	int ret = eth_mac_addr(dev, p);
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+
+	if (ret)
+		return ret;
+
+	if (eth->soc->set_mac)
+		eth->soc->set_mac(mac, dev->dev_addr);
+	else
+		mtk_hw_set_macaddr(mac, p);
+
+	return 0;
+}
+
+static inline int mtk_max_frag_size(int mtu)
+{
+	/* make sure buf_size will be at least MAX_RX_LENGTH */
+	if (mtu + MTK_RX_ETH_HLEN < MAX_RX_LENGTH)
+		mtu = MAX_RX_LENGTH - MTK_RX_ETH_HLEN;
+
+	return SKB_DATA_ALIGN(MTK_RX_HLEN + mtu) +
+		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+}
+
+static inline int mtk_max_buf_size(int frag_size)
+{
+	int buf_size = frag_size - NET_SKB_PAD - NET_IP_ALIGN -
+		       SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+	WARN_ON(buf_size < MAX_RX_LENGTH);
+
+	return buf_size;
+}
+
+static inline void mtk_get_rxd(struct mtk_rx_dma *rxd,
+			       struct mtk_rx_dma *dma_rxd)
+{
+	rxd->rxd1 = READ_ONCE(dma_rxd->rxd1);
+	rxd->rxd2 = READ_ONCE(dma_rxd->rxd2);
+	rxd->rxd3 = READ_ONCE(dma_rxd->rxd3);
+	rxd->rxd4 = READ_ONCE(dma_rxd->rxd4);
+}
+
+static inline void mtk_set_txd_pdma(struct mtk_tx_dma *txd,
+				    struct mtk_tx_dma *dma_txd)
+{
+	WRITE_ONCE(dma_txd->txd1, txd->txd1);
+	WRITE_ONCE(dma_txd->txd3, txd->txd3);
+	WRITE_ONCE(dma_txd->txd4, txd->txd4);
+	/* clean dma done flag last */
+	WRITE_ONCE(dma_txd->txd2, txd->txd2);
+}
+
+static void mtk_clean_rx(struct mtk_eth *eth, struct mtk_rx_ring *ring)
+{
+	int i;
+
+	if (ring->rx_data && ring->rx_dma) {
+		for (i = 0; i < ring->rx_ring_size; i++) {
+			if (!ring->rx_data[i])
+				continue;
+			if (!ring->rx_dma[i].rxd1)
+				continue;
+			dma_unmap_single(eth->dev,
+					 ring->rx_dma[i].rxd1,
+					 ring->rx_buf_size,
+					 DMA_FROM_DEVICE);
+			skb_free_frag(ring->rx_data[i]);
+		}
+		kfree(ring->rx_data);
+		ring->rx_data = NULL;
+	}
+
+	if (ring->rx_dma) {
+		dma_free_coherent(eth->dev,
+				  ring->rx_ring_size * sizeof(*ring->rx_dma),
+				  ring->rx_dma,
+				  ring->rx_phys);
+		ring->rx_dma = NULL;
+	}
+}
+
+static int mtk_dma_rx_alloc(struct mtk_eth *eth, struct mtk_rx_ring *ring)
+{
+	int i, pad = 0;
+
+	ring->frag_size = mtk_max_frag_size(ETH_DATA_LEN);
+	ring->rx_buf_size = mtk_max_buf_size(ring->frag_size);
+	ring->rx_ring_size = eth->soc->dma_ring_size;
+	ring->rx_data = kcalloc(ring->rx_ring_size, sizeof(*ring->rx_data),
+			GFP_KERNEL);
+	if (!ring->rx_data)
+		goto no_rx_mem;
+
+	for (i = 0; i < ring->rx_ring_size; i++) {
+		ring->rx_data[i] = netdev_alloc_frag(ring->frag_size);
+		if (!ring->rx_data[i])
+			goto no_rx_mem;
+	}
+
+	ring->rx_dma = dma_alloc_coherent(eth->dev,
+			ring->rx_ring_size * sizeof(*ring->rx_dma),
+			&ring->rx_phys,
+			GFP_ATOMIC | __GFP_ZERO);
+	if (!ring->rx_dma)
+		goto no_rx_mem;
+
+	if (!eth->soc->rx_2b_offset)
+		pad = NET_IP_ALIGN;
+
+	for (i = 0; i < ring->rx_ring_size; i++) {
+		dma_addr_t dma_addr = dma_map_single(eth->dev,
+				ring->rx_data[i] + NET_SKB_PAD + pad,
+				ring->rx_buf_size,
+				DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(eth->dev, dma_addr)))
+			goto no_rx_mem;
+		ring->rx_dma[i].rxd1 = (unsigned int)dma_addr;
+
+		if (eth->soc->rx_sg_dma)
+			ring->rx_dma[i].rxd2 = RX_DMA_PLEN0(ring->rx_buf_size);
+		else
+			ring->rx_dma[i].rxd2 = RX_DMA_LSO;
+	}
+	ring->rx_calc_idx = ring->rx_ring_size - 1;
+	/* make sure that all changes to the dma ring are flushed before we
+	 * continue
+	 */
+	wmb();
+
+	return 0;
+
+no_rx_mem:
+	return -ENOMEM;
+}
+
+static void mtk_txd_unmap(struct device *dev, struct mtk_tx_buf *tx_buf)
+{
+	if (tx_buf->flags & MTK_TX_FLAGS_SINGLE0) {
+		dma_unmap_single(dev,
+				 dma_unmap_addr(tx_buf, dma_addr0),
+				 dma_unmap_len(tx_buf, dma_len0),
+				 DMA_TO_DEVICE);
+	} else if (tx_buf->flags & MTK_TX_FLAGS_PAGE0) {
+		dma_unmap_page(dev,
+			       dma_unmap_addr(tx_buf, dma_addr0),
+			       dma_unmap_len(tx_buf, dma_len0),
+			       DMA_TO_DEVICE);
+	}
+	if (tx_buf->flags & MTK_TX_FLAGS_PAGE1)
+		dma_unmap_page(dev,
+			       dma_unmap_addr(tx_buf, dma_addr1),
+			       dma_unmap_len(tx_buf, dma_len1),
+			       DMA_TO_DEVICE);
+
+	tx_buf->flags = 0;
+	if (tx_buf->skb && (tx_buf->skb != (struct sk_buff *)DMA_DUMMY_DESC))
+		dev_kfree_skb_any(tx_buf->skb);
+	tx_buf->skb = NULL;
+}
+
+static void mtk_pdma_tx_clean(struct mtk_eth *eth)
+{
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+	int i;
+
+	if (ring->tx_buf) {
+		for (i = 0; i < ring->tx_ring_size; i++)
+			mtk_txd_unmap(eth->dev, &ring->tx_buf[i]);
+		kfree(ring->tx_buf);
+		ring->tx_buf = NULL;
+	}
+
+	if (ring->tx_dma) {
+		dma_free_coherent(eth->dev,
+				  ring->tx_ring_size * sizeof(*ring->tx_dma),
+				  ring->tx_dma,
+				  ring->tx_phys);
+		ring->tx_dma = NULL;
+	}
+}
+
+static void mtk_qdma_tx_clean(struct mtk_eth *eth)
+{
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+	int i;
+
+	if (ring->tx_buf) {
+		for (i = 0; i < ring->tx_ring_size; i++)
+			mtk_txd_unmap(eth->dev, &ring->tx_buf[i]);
+		kfree(ring->tx_buf);
+		ring->tx_buf = NULL;
+	}
+
+	if (ring->tx_dma) {
+		dma_free_coherent(eth->dev,
+				  ring->tx_ring_size * sizeof(*ring->tx_dma),
+				  ring->tx_dma,
+				  ring->tx_phys);
+		ring->tx_dma = NULL;
+	}
+}
+
+void mtk_stats_update_mac(struct mtk_mac *mac)
+{
+	struct mtk_hw_stats *hw_stats = mac->hw_stats;
+	unsigned int base = mtk_reg_table[MTK_REG_MTK_COUNTER_BASE];
+	u64 stats;
+
+	base += hw_stats->reg_offset;
+
+	u64_stats_update_begin(&hw_stats->syncp);
+
+	if (mac->hw->soc->new_stats) {
+		hw_stats->rx_bytes += mtk_r32(mac->hw, base);
+		stats =  mtk_r32(mac->hw, base + 0x04);
+		if (stats)
+			hw_stats->rx_bytes += (stats << 32);
+		hw_stats->rx_packets += mtk_r32(mac->hw, base + 0x08);
+		hw_stats->rx_overflow += mtk_r32(mac->hw, base + 0x10);
+		hw_stats->rx_fcs_errors += mtk_r32(mac->hw, base + 0x14);
+		hw_stats->rx_short_errors += mtk_r32(mac->hw, base + 0x18);
+		hw_stats->rx_long_errors += mtk_r32(mac->hw, base + 0x1c);
+		hw_stats->rx_checksum_errors += mtk_r32(mac->hw, base + 0x20);
+		hw_stats->rx_flow_control_packets +=
+						mtk_r32(mac->hw, base + 0x24);
+		hw_stats->tx_skip += mtk_r32(mac->hw, base + 0x28);
+		hw_stats->tx_collisions += mtk_r32(mac->hw, base + 0x2c);
+		hw_stats->tx_bytes += mtk_r32(mac->hw, base + 0x30);
+		stats =  mtk_r32(mac->hw, base + 0x34);
+		if (stats)
+			hw_stats->tx_bytes += (stats << 32);
+		hw_stats->tx_packets += mtk_r32(mac->hw, base + 0x38);
+	} else {
+		hw_stats->tx_bytes += mtk_r32(mac->hw, base);
+		hw_stats->tx_packets += mtk_r32(mac->hw, base + 0x04);
+		hw_stats->tx_skip += mtk_r32(mac->hw, base + 0x08);
+		hw_stats->tx_collisions += mtk_r32(mac->hw, base + 0x0c);
+		hw_stats->rx_bytes += mtk_r32(mac->hw, base + 0x20);
+		hw_stats->rx_packets += mtk_r32(mac->hw, base + 0x24);
+		hw_stats->rx_overflow += mtk_r32(mac->hw, base + 0x28);
+		hw_stats->rx_fcs_errors += mtk_r32(mac->hw, base + 0x2c);
+		hw_stats->rx_short_errors += mtk_r32(mac->hw, base + 0x30);
+		hw_stats->rx_long_errors += mtk_r32(mac->hw, base + 0x34);
+		hw_stats->rx_checksum_errors += mtk_r32(mac->hw, base + 0x38);
+		hw_stats->rx_flow_control_packets +=
+						mtk_r32(mac->hw, base + 0x3c);
+	}
+
+	u64_stats_update_end(&hw_stats->syncp);
+}
+
+static struct rtnl_link_stats64 *mtk_get_stats64(struct net_device *dev,
+					struct rtnl_link_stats64 *storage)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_hw_stats *hw_stats = mac->hw_stats;
+	unsigned int base = mtk_reg_table[MTK_REG_MTK_COUNTER_BASE];
+	unsigned int start;
+
+	if (!base) {
+		netdev_stats_to_stats64(storage, &dev->stats);
+		return storage;
+	}
+
+	if (netif_running(dev) && netif_device_present(dev)) {
+		if (spin_trylock(&hw_stats->stats_lock)) {
+			mtk_stats_update_mac(mac);
+			spin_unlock(&hw_stats->stats_lock);
+		}
+	}
+
+	do {
+		start = u64_stats_fetch_begin_irq(&hw_stats->syncp);
+		storage->rx_packets = hw_stats->rx_packets;
+		storage->tx_packets = hw_stats->tx_packets;
+		storage->rx_bytes = hw_stats->rx_bytes;
+		storage->tx_bytes = hw_stats->tx_bytes;
+		storage->collisions = hw_stats->tx_collisions;
+		storage->rx_length_errors = hw_stats->rx_short_errors +
+			hw_stats->rx_long_errors;
+		storage->rx_over_errors = hw_stats->rx_overflow;
+		storage->rx_crc_errors = hw_stats->rx_fcs_errors;
+		storage->rx_errors = hw_stats->rx_checksum_errors;
+		storage->tx_aborted_errors = hw_stats->tx_skip;
+	} while (u64_stats_fetch_retry_irq(&hw_stats->syncp, start));
+
+	storage->tx_errors = dev->stats.tx_errors;
+	storage->rx_dropped = dev->stats.rx_dropped;
+	storage->tx_dropped = dev->stats.tx_dropped;
+
+	return storage;
+}
+
+static int mtk_vlan_rx_add_vid(struct net_device *dev,
+			       __be16 proto, u16 vid)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	u32 idx = (vid & 0xf);
+	u32 vlan_cfg;
+
+	if (!((mtk_reg_table[MTK_REG_MTK_DMA_VID_BASE]) &&
+	      (dev->features & NETIF_F_HW_VLAN_CTAG_TX)))
+		return 0;
+
+	if (test_bit(idx, &eth->vlan_map)) {
+		netdev_warn(dev, "disable tx vlan offload\n");
+		dev->wanted_features &= ~NETIF_F_HW_VLAN_CTAG_TX;
+		netdev_update_features(dev);
+	} else {
+		vlan_cfg = mtk_r32(eth,
+				   mtk_reg_table[MTK_REG_MTK_DMA_VID_BASE] +
+				   ((idx >> 1) << 2));
+		if (idx & 0x1) {
+			vlan_cfg &= 0xffff;
+			vlan_cfg |= (vid << 16);
+		} else {
+			vlan_cfg &= 0xffff0000;
+			vlan_cfg |= vid;
+		}
+		mtk_w32(eth,
+			vlan_cfg, mtk_reg_table[MTK_REG_MTK_DMA_VID_BASE] +
+			((idx >> 1) << 2));
+		set_bit(idx, &eth->vlan_map);
+	}
+
+	return 0;
+}
+
+static int mtk_vlan_rx_kill_vid(struct net_device *dev,
+				__be16 proto, u16 vid)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	u32 idx = (vid & 0xf);
+
+	if (!((mtk_reg_table[MTK_REG_MTK_DMA_VID_BASE]) &&
+	      (dev->features & NETIF_F_HW_VLAN_CTAG_TX)))
+		return 0;
+
+	clear_bit(idx, &eth->vlan_map);
+
+	return 0;
+}
+
+static inline u32 mtk_pdma_empty_txd(struct mtk_tx_ring *ring)
+{
+	barrier();
+	return (u32)(ring->tx_ring_size -
+		     ((ring->tx_next_idx - ring->tx_free_idx) &
+		      (ring->tx_ring_size - 1)));
+}
+
+static int mtk_skb_padto(struct sk_buff *skb, struct mtk_eth *eth)
+{
+	unsigned int len;
+	int ret;
+
+	if (unlikely(skb->len >= VLAN_ETH_ZLEN))
+		return 0;
+
+	if (eth->soc->padding_64b && !eth->soc->padding_bug)
+		return 0;
+
+	if (skb_vlan_tag_present(skb))
+		len = ETH_ZLEN;
+	else if (skb->protocol == cpu_to_be16(ETH_P_8021Q))
+		len = VLAN_ETH_ZLEN;
+	else if (!eth->soc->padding_64b)
+		len = ETH_ZLEN;
+	else
+		return 0;
+
+	if (skb->len >= len)
+		return 0;
+
+	ret = skb_pad(skb, len - skb->len);
+	if (ret < 0)
+		return ret;
+	skb->len = len;
+	skb_set_tail_pointer(skb, len);
+
+	return ret;
+}
+
+static int mtk_pdma_tx_map(struct sk_buff *skb, struct net_device *dev,
+			   int tx_num, struct mtk_tx_ring *ring, bool gso)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	struct skb_frag_struct *frag;
+	struct mtk_tx_dma txd, *ptxd;
+	struct mtk_tx_buf *tx_buf;
+	int i, j, k, frag_size, frag_map_size, offset;
+	dma_addr_t mapped_addr;
+	unsigned int nr_frags;
+	u32 def_txd4;
+
+	if (mtk_skb_padto(skb, eth)) {
+		netif_warn(eth, tx_err, dev, "tx padding failed!\n");
+		return -1;
+	}
+
+	tx_buf = &ring->tx_buf[ring->tx_next_idx];
+	memset(tx_buf, 0, sizeof(*tx_buf));
+	memset(&txd, 0, sizeof(txd));
+	nr_frags = skb_shinfo(skb)->nr_frags;
+
+	/* init tx descriptor */
+	def_txd4 = eth->soc->txd4;
+	txd.txd4 = def_txd4;
+
+	/* TX Checksum offload */
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		txd.txd4 |= TX_DMA_CHKSUM;
+
+	/* VLAN header offload */
+	if (skb_vlan_tag_present(skb)) {
+		u16 tag = skb_vlan_tag_get(skb);
+
+		txd.txd4 |= TX_DMA_INS_VLAN |
+			    ((tag >> VLAN_PRIO_SHIFT) << 4) |
+			    (tag & 0xF);
+	}
+
+	mapped_addr = dma_map_single(&dev->dev, skb->data,
+				     skb_headlen(skb), DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(&dev->dev, mapped_addr)))
+		return -1;
+
+	txd.txd1 = mapped_addr;
+	txd.txd2 = TX_DMA_PLEN0(skb_headlen(skb));
+
+	tx_buf->flags |= MTK_TX_FLAGS_SINGLE0;
+	dma_unmap_addr_set(tx_buf, dma_addr0, mapped_addr);
+	dma_unmap_len_set(tx_buf, dma_len0, skb_headlen(skb));
+
+	/* TX SG offload */
+	j = ring->tx_next_idx;
+	k = 0;
+	for (i = 0; i < nr_frags; i++) {
+		offset = 0;
+		frag = &skb_shinfo(skb)->frags[i];
+		frag_size = skb_frag_size(frag);
+
+		while (frag_size > 0) {
+			frag_map_size = min(frag_size, TX_DMA_BUF_LEN);
+			mapped_addr = skb_frag_dma_map(&dev->dev, frag, offset,
+						       frag_map_size,
+						       DMA_TO_DEVICE);
+			if (unlikely(dma_mapping_error(&dev->dev, mapped_addr)))
+				goto err_dma;
+
+			if (k & 0x1) {
+				j = NEXT_TX_DESP_IDX(j);
+				txd.txd1 = mapped_addr;
+				txd.txd2 = TX_DMA_PLEN0(frag_map_size);
+				txd.txd4 = def_txd4;
+
+				tx_buf = &ring->tx_buf[j];
+				memset(tx_buf, 0, sizeof(*tx_buf));
+
+				tx_buf->flags |= MTK_TX_FLAGS_PAGE0;
+				dma_unmap_addr_set(tx_buf, dma_addr0,
+						   mapped_addr);
+				dma_unmap_len_set(tx_buf, dma_len0,
+						  frag_map_size);
+			} else {
+				txd.txd3 = mapped_addr;
+				txd.txd2 |= TX_DMA_PLEN1(frag_map_size);
+
+				tx_buf->skb = (struct sk_buff *)DMA_DUMMY_DESC;
+				tx_buf->flags |= MTK_TX_FLAGS_PAGE1;
+				dma_unmap_addr_set(tx_buf, dma_addr1,
+						   mapped_addr);
+				dma_unmap_len_set(tx_buf, dma_len1,
+						  frag_map_size);
+
+				if (!((i == (nr_frags - 1)) &&
+				      (frag_map_size == frag_size))) {
+					mtk_set_txd_pdma(&txd,
+							 &ring->tx_dma[j]);
+					memset(&txd, 0, sizeof(txd));
+				}
+			}
+			frag_size -= frag_map_size;
+			offset += frag_map_size;
+			k++;
+		}
+	}
+
+	/* set last segment */
+	if (k & 0x1)
+		txd.txd2 |= TX_DMA_LS1;
+	else
+		txd.txd2 |= TX_DMA_LS0;
+	mtk_set_txd_pdma(&txd, &ring->tx_dma[j]);
+
+	/* store skb to cleanup */
+	tx_buf->skb = skb;
+
+	netdev_sent_queue(dev, skb->len);
+	skb_tx_timestamp(skb);
+
+	ring->tx_next_idx = NEXT_TX_DESP_IDX(j);
+	/* make sure that all changes to the dma ring are flushed before we
+	 * continue
+	 */
+	wmb();
+	atomic_set(&ring->tx_free_count, mtk_pdma_empty_txd(ring));
+
+	if (netif_xmit_stopped(netdev_get_tx_queue(dev, 0)) || !skb->xmit_more)
+		mtk_reg_w32(eth, ring->tx_next_idx, MTK_REG_TX_CTX_IDX0);
+
+	return 0;
+
+err_dma:
+	j = ring->tx_next_idx;
+	for (i = 0; i < tx_num; i++) {
+		ptxd = &ring->tx_dma[j];
+		tx_buf = &ring->tx_buf[j];
+
+		/* unmap dma */
+		mtk_txd_unmap(&dev->dev, tx_buf);
+
+		ptxd->txd2 = TX_DMA_DESP2_DEF;
+		j = NEXT_TX_DESP_IDX(j);
+	}
+	/* make sure that all changes to the dma ring are flushed before we
+	 * continue
+	 */
+	wmb();
+	return -1;
+}
+
+/* the qdma core needs scratch memory to be setup */
+static int mtk_init_fq_dma(struct mtk_eth *eth)
+{
+	unsigned int phy_ring_head, phy_ring_tail;
+	int cnt = eth->soc->dma_ring_size;
+	dma_addr_t dma_addr;
+	int i;
+
+	eth->scratch_ring = dma_alloc_coherent(eth->dev,
+					       cnt * sizeof(struct mtk_tx_dma),
+					       &phy_ring_head,
+					       GFP_ATOMIC | __GFP_ZERO);
+	if (unlikely(!eth->scratch_ring))
+		return -ENOMEM;
+
+	eth->scratch_head = kcalloc(cnt, QDMA_PAGE_SIZE,
+				    GFP_KERNEL);
+	dma_addr = dma_map_single(eth->dev,
+				  eth->scratch_head, cnt * QDMA_PAGE_SIZE,
+				  DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(eth->dev, dma_addr)))
+		return -ENOMEM;
+
+	memset(eth->scratch_ring, 0x0, sizeof(struct mtk_tx_dma) * cnt);
+	phy_ring_tail = phy_ring_head + (sizeof(struct mtk_tx_dma) * (cnt - 1));
+
+	for (i = 0; i < cnt; i++) {
+		eth->scratch_ring[i].txd1 = (dma_addr + (i * QDMA_PAGE_SIZE));
+		if (i < cnt - 1)
+			eth->scratch_ring[i].txd2 = (phy_ring_head +
+				((i + 1) * sizeof(struct mtk_tx_dma)));
+		eth->scratch_ring[i].txd3 = TX_QDMA_SDL(QDMA_PAGE_SIZE);
+	}
+
+	mtk_w32(eth, phy_ring_head, MTK_QDMA_FQ_HEAD);
+	mtk_w32(eth, phy_ring_tail, MTK_QDMA_FQ_TAIL);
+	mtk_w32(eth, (cnt << 16) | cnt, MTK_QDMA_FQ_CNT);
+	mtk_w32(eth, QDMA_PAGE_SIZE << 16, MTK_QDMA_FQ_BLEN);
+
+	return 0;
+}
+
+static void *mtk_qdma_phys_to_virt(struct mtk_tx_ring *ring, u32 desc)
+{
+	void *ret = ring->tx_dma;
+
+	return ret + (desc - ring->tx_phys);
+}
+
+static struct mtk_tx_dma *mtk_tx_next_qdma(struct mtk_tx_ring *ring,
+					   struct mtk_tx_dma *txd)
+{
+	return mtk_qdma_phys_to_virt(ring, txd->txd2);
+}
+
+static struct mtk_tx_buf *mtk_desc_to_tx_buf(struct mtk_tx_ring *ring,
+					     struct mtk_tx_dma *txd)
+{
+	int idx = txd - ring->tx_dma;
+
+	return &ring->tx_buf[idx];
+}
+
+static int mtk_qdma_tx_map(struct sk_buff *skb, struct net_device *dev,
+			   int tx_num, struct mtk_tx_ring *ring, bool gso)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	struct mtk_tx_dma *itxd, *txd;
+	struct mtk_tx_buf *tx_buf;
+	dma_addr_t mapped_addr;
+	unsigned int nr_frags;
+	int i, n_desc = 1;
+	u32 txd4 = eth->soc->txd4;
+
+	itxd = ring->tx_next_free;
+	if (itxd == ring->tx_last_free)
+		return -ENOMEM;
+
+	if (eth->soc->mac_count > 1)
+		txd4 |= (mac->id + 1) << TX_DMA_FPORT_SHIFT;
+
+	tx_buf = mtk_desc_to_tx_buf(ring, itxd);
+	memset(tx_buf, 0, sizeof(*tx_buf));
+
+	if (gso)
+		txd4 |= TX_DMA_TSO;
+
+	/* TX Checksum offload */
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		txd4 |= TX_DMA_CHKSUM;
+
+	/* VLAN header offload */
+	if (skb_vlan_tag_present(skb))
+		txd4 |= TX_DMA_INS_VLAN_MT7621 | skb_vlan_tag_get(skb);
+
+	mapped_addr = dma_map_single(&dev->dev, skb->data,
+				     skb_headlen(skb), DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(&dev->dev, mapped_addr)))
+		return -ENOMEM;
+
+	WRITE_ONCE(itxd->txd1, mapped_addr);
+	tx_buf->flags |= MTK_TX_FLAGS_SINGLE0;
+	dma_unmap_addr_set(tx_buf, dma_addr0, mapped_addr);
+	dma_unmap_len_set(tx_buf, dma_len0, skb_headlen(skb));
+
+	/* TX SG offload */
+	txd = itxd;
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	for (i = 0; i < nr_frags; i++) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
+		unsigned int offset = 0;
+		int frag_size = skb_frag_size(frag);
+
+		while (frag_size) {
+			bool last_frag = false;
+			unsigned int frag_map_size;
+
+			txd = mtk_tx_next_qdma(ring, txd);
+			if (txd == ring->tx_last_free)
+				goto err_dma;
+
+			n_desc++;
+			frag_map_size = min(frag_size, TX_DMA_BUF_LEN);
+			mapped_addr = skb_frag_dma_map(&dev->dev, frag, offset,
+						       frag_map_size,
+						       DMA_TO_DEVICE);
+			if (unlikely(dma_mapping_error(&dev->dev, mapped_addr)))
+				goto err_dma;
+
+			if (i == nr_frags - 1 &&
+			    (frag_size - frag_map_size) == 0)
+				last_frag = true;
+
+			WRITE_ONCE(txd->txd1, mapped_addr);
+			WRITE_ONCE(txd->txd3, (QDMA_TX_SWC |
+					       TX_DMA_PLEN0(frag_map_size) |
+					       last_frag * TX_DMA_LS0) |
+					       mac->id);
+			WRITE_ONCE(txd->txd4, 0);
+
+			tx_buf->skb = (struct sk_buff *)DMA_DUMMY_DESC;
+			tx_buf = mtk_desc_to_tx_buf(ring, txd);
+			memset(tx_buf, 0, sizeof(*tx_buf));
+
+			tx_buf->flags |= MTK_TX_FLAGS_PAGE0;
+			dma_unmap_addr_set(tx_buf, dma_addr0, mapped_addr);
+			dma_unmap_len_set(tx_buf, dma_len0, frag_map_size);
+			frag_size -= frag_map_size;
+			offset += frag_map_size;
+		}
+	}
+
+	/* store skb to cleanup */
+	tx_buf->skb = skb;
+
+	WRITE_ONCE(itxd->txd4, txd4);
+	WRITE_ONCE(itxd->txd3, (QDMA_TX_SWC | TX_DMA_PLEN0(skb_headlen(skb)) |
+				(!nr_frags * TX_DMA_LS0)));
+
+	netdev_sent_queue(dev, skb->len);
+	skb_tx_timestamp(skb);
+
+	ring->tx_next_free = mtk_tx_next_qdma(ring, txd);
+	atomic_sub(n_desc, &ring->tx_free_count);
+
+	/* make sure that all changes to the dma ring are flushed before we
+	 * continue
+	 */
+	wmb();
+
+	if (netif_xmit_stopped(netdev_get_tx_queue(dev, 0)) || !skb->xmit_more)
+		mtk_w32(eth, txd->txd2, MTK_QTX_CTX_PTR);
+
+	return 0;
+
+err_dma:
+	do {
+		tx_buf = mtk_desc_to_tx_buf(ring, txd);
+
+		/* unmap dma */
+		mtk_txd_unmap(&dev->dev, tx_buf);
+
+		itxd->txd3 = TX_DMA_DESP2_DEF;
+		itxd = mtk_tx_next_qdma(ring, itxd);
+	} while (itxd != txd);
+
+	return -ENOMEM;
+}
+
+static inline int mtk_cal_txd_req(struct sk_buff *skb)
+{
+	int i, nfrags;
+	struct skb_frag_struct *frag;
+
+	nfrags = 1;
+	if (skb_is_gso(skb)) {
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			frag = &skb_shinfo(skb)->frags[i];
+			nfrags += DIV_ROUND_UP(frag->size, TX_DMA_BUF_LEN);
+		}
+	} else {
+		nfrags += skb_shinfo(skb)->nr_frags;
+	}
+
+	return DIV_ROUND_UP(nfrags, 2);
+}
+
+static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+	struct net_device_stats *stats = &dev->stats;
+	int tx_num;
+	int len = skb->len;
+	bool gso = false;
+
+	tx_num = mtk_cal_txd_req(skb);
+	if (unlikely(atomic_read(&ring->tx_free_count) <= tx_num)) {
+		netif_stop_queue(dev);
+		netif_err(eth, tx_queued, dev,
+			  "Tx Ring full when queue awake!\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	/* TSO: fill MSS info in tcp checksum field */
+	if (skb_is_gso(skb)) {
+		if (skb_cow_head(skb, 0)) {
+			netif_warn(eth, tx_err, dev,
+				   "GSO expand head fail.\n");
+			goto drop;
+		}
+
+		if (skb_shinfo(skb)->gso_type &
+				(SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
+			gso = true;
+			tcp_hdr(skb)->check = htons(skb_shinfo(skb)->gso_size);
+		}
+	}
+
+	if (ring->tx_map(skb, dev, tx_num, ring, gso) < 0)
+		goto drop;
+
+	stats->tx_packets++;
+	stats->tx_bytes += len;
+
+	if (unlikely(atomic_read(&ring->tx_free_count) <= ring->tx_thresh)) {
+		netif_stop_queue(dev);
+		smp_mb();
+		if (unlikely(atomic_read(&ring->tx_free_count) >
+			     ring->tx_thresh))
+			netif_wake_queue(dev);
+	}
+
+	return NETDEV_TX_OK;
+
+drop:
+	stats->tx_dropped++;
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static int mtk_poll_rx(struct napi_struct *napi, int budget,
+		       struct mtk_eth *eth, u32 rx_intr)
+{
+	struct mtk_soc_data *soc = eth->soc;
+	struct mtk_rx_ring *ring = &eth->rx_ring[0];
+	int idx = ring->rx_calc_idx;
+	u32 checksum_bit;
+	struct sk_buff *skb;
+	u8 *data, *new_data;
+	struct mtk_rx_dma *rxd, trxd;
+	int done = 0, pad;
+
+	if (eth->soc->hw_features & NETIF_F_RXCSUM)
+		checksum_bit = soc->checksum_bit;
+	else
+		checksum_bit = 0;
+
+	if (eth->soc->rx_2b_offset)
+		pad = 0;
+	else
+		pad = NET_IP_ALIGN;
+
+	while (done < budget) {
+		struct net_device *netdev;
+		unsigned int pktlen;
+		dma_addr_t dma_addr;
+		int mac = 0;
+
+		idx = NEXT_RX_DESP_IDX(idx);
+		rxd = &ring->rx_dma[idx];
+		data = ring->rx_data[idx];
+
+		mtk_get_rxd(&trxd, rxd);
+		if (!(trxd.rxd2 & RX_DMA_DONE))
+			break;
+
+		/* find out which mac the packet come from. values start at 1 */
+		if (eth->soc->mac_count > 1) {
+			mac = (trxd.rxd4 >> RX_DMA_FPORT_SHIFT) &
+			      RX_DMA_FPORT_MASK;
+			mac--;
+		}
+
+		netdev = eth->netdev[mac];
+
+		/* alloc new buffer */
+		new_data = napi_alloc_frag(ring->frag_size);
+		if (unlikely(!new_data)) {
+			netdev->stats.rx_dropped++;
+			goto release_desc;
+		}
+		dma_addr = dma_map_single(&eth->netdev[mac]->dev,
+					  new_data + NET_SKB_PAD + pad,
+					  ring->rx_buf_size,
+					  DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(&netdev->dev, dma_addr))) {
+			skb_free_frag(new_data);
+			goto release_desc;
+		}
+
+		/* receive data */
+		skb = build_skb(data, ring->frag_size);
+		if (unlikely(!skb)) {
+			put_page(virt_to_head_page(new_data));
+			goto release_desc;
+		}
+		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+
+		dma_unmap_single(&netdev->dev, trxd.rxd1,
+				 ring->rx_buf_size, DMA_FROM_DEVICE);
+		pktlen = RX_DMA_GET_PLEN0(trxd.rxd2);
+		skb->dev = netdev;
+		skb_put(skb, pktlen);
+		if (trxd.rxd4 & checksum_bit)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb_checksum_none_assert(skb);
+		skb->protocol = eth_type_trans(skb, netdev);
+
+		netdev->stats.rx_packets++;
+		netdev->stats.rx_bytes += pktlen;
+
+		if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX &&
+		    RX_DMA_VID(trxd.rxd3))
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       RX_DMA_VID(trxd.rxd3));
+		napi_gro_receive(napi, skb);
+
+		ring->rx_data[idx] = new_data;
+		rxd->rxd1 = (unsigned int)dma_addr;
+
+release_desc:
+		if (eth->soc->rx_sg_dma)
+			rxd->rxd2 = RX_DMA_PLEN0(ring->rx_buf_size);
+		else
+			rxd->rxd2 = RX_DMA_LSO;
+
+		ring->rx_calc_idx = idx;
+		/* make sure that all changes to the dma ring are flushed before
+		 * we continue
+		 */
+		wmb();
+		if (eth->soc->dma_type == MTK_QDMA)
+			mtk_w32(eth, ring->rx_calc_idx, MTK_QRX_CRX_IDX0);
+		else
+			mtk_reg_w32(eth, ring->rx_calc_idx,
+				    MTK_REG_RX_CALC_IDX0);
+		done++;
+	}
+
+	if (done < budget)
+		mtk_irq_ack(eth, rx_intr);
+
+	return done;
+}
+
+static int mtk_pdma_tx_poll(struct mtk_eth *eth, int budget, bool *tx_again)
+{
+	struct sk_buff *skb;
+	struct mtk_tx_buf *tx_buf;
+	int done = 0;
+	u32 idx, hwidx;
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+	unsigned int bytes = 0;
+
+	idx = ring->tx_free_idx;
+	hwidx = mtk_reg_r32(eth, MTK_REG_TX_DTX_IDX0);
+
+	while ((idx != hwidx) && budget) {
+		tx_buf = &ring->tx_buf[idx];
+		skb = tx_buf->skb;
+
+		if (!skb)
+			break;
+
+		if (skb != (struct sk_buff *)DMA_DUMMY_DESC) {
+			bytes += skb->len;
+			done++;
+			budget--;
+		}
+		mtk_txd_unmap(eth->dev, tx_buf);
+		idx = NEXT_TX_DESP_IDX(idx);
+	}
+	ring->tx_free_idx = idx;
+	atomic_set(&ring->tx_free_count, mtk_pdma_empty_txd(ring));
+
+	/* read hw index again make sure no new tx packet */
+	if (idx != hwidx || idx != mtk_reg_r32(eth, MTK_REG_TX_DTX_IDX0))
+		*tx_again = 1;
+
+	if (done)
+		netdev_completed_queue(*eth->netdev, done, bytes);
+
+	return done;
+}
+
+static int mtk_qdma_tx_poll(struct mtk_eth *eth, int budget, bool *tx_again)
+{
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+	struct mtk_tx_dma *desc;
+	struct sk_buff *skb;
+	struct mtk_tx_buf *tx_buf;
+	int total = 0, done[MTK_MAX_DEVS];
+	unsigned int bytes[MTK_MAX_DEVS];
+	u32 cpu, dma;
+	static int condition;
+	int i;
+
+	memset(done, 0, sizeof(done));
+	memset(bytes, 0, sizeof(bytes));
+
+	cpu = mtk_r32(eth, MTK_QTX_CRX_PTR);
+	dma = mtk_r32(eth, MTK_QTX_DRX_PTR);
+
+	desc = mtk_qdma_phys_to_virt(ring, cpu);
+
+	while ((cpu != dma) && budget) {
+		u32 next_cpu = desc->txd2;
+		int mac;
+
+		desc = mtk_tx_next_qdma(ring, desc);
+		if ((desc->txd3 & QDMA_TX_OWNER_CPU) == 0)
+			break;
+
+		mac = (desc->txd4 >> TX_DMA_FPORT_SHIFT) &
+		       TX_DMA_FPORT_MASK;
+		mac--;
+
+		tx_buf = mtk_desc_to_tx_buf(ring, desc);
+		skb = tx_buf->skb;
+		if (!skb) {
+			condition = 1;
+			break;
+		}
+
+		if (skb != (struct sk_buff *)DMA_DUMMY_DESC) {
+			bytes[mac] += skb->len;
+			done[mac]++;
+			budget--;
+		}
+		mtk_txd_unmap(eth->dev, tx_buf);
+
+		ring->tx_last_free->txd2 = next_cpu;
+		ring->tx_last_free = desc;
+		atomic_inc(&ring->tx_free_count);
+
+		cpu = next_cpu;
+	}
+
+	mtk_w32(eth, cpu, MTK_QTX_CRX_PTR);
+
+	/* read hw index again make sure no new tx packet */
+	if (cpu != dma || cpu != mtk_r32(eth, MTK_QTX_DRX_PTR))
+		*tx_again = true;
+
+	for (i = 0; i < eth->soc->mac_count; i++) {
+		if (!done[i])
+			continue;
+		netdev_completed_queue(eth->netdev[i], done[i], bytes[i]);
+		total += done[i];
+	}
+
+	return total;
+}
+
+static int mtk_poll_tx(struct mtk_eth *eth, int budget, u32 tx_intr,
+		       bool *tx_again)
+{
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+	struct net_device *netdev = eth->netdev[0];
+	int done;
+
+	done = eth->tx_ring.tx_poll(eth, budget, tx_again);
+	if (!*tx_again)
+		mtk_irq_ack(eth, tx_intr);
+
+	if (!done)
+		return 0;
+
+	smp_mb();
+	if (unlikely(!netif_queue_stopped(netdev)))
+		return done;
+
+	if (atomic_read(&ring->tx_free_count) > ring->tx_thresh)
+		netif_wake_queue(netdev);
+
+	return done;
+}
+
+static void mtk_stats_update(struct mtk_eth *eth)
+{
+	int i;
+
+	for (i = 0; i < eth->soc->mac_count; i++) {
+		if (!eth->mac[i] || !eth->mac[i]->hw_stats)
+			continue;
+		if (spin_trylock(&eth->mac[i]->hw_stats->stats_lock)) {
+			mtk_stats_update_mac(eth->mac[i]);
+			spin_unlock(&eth->mac[i]->hw_stats->stats_lock);
+		}
+	}
+}
+
+static int mtk_poll(struct napi_struct *napi, int budget)
+{
+	struct mtk_eth *eth = container_of(napi, struct mtk_eth, rx_napi);
+	u32 status, mtk_status, mask, tx_intr, rx_intr, status_intr;
+	int tx_done, rx_done;
+	bool tx_again = false;
+
+	status = mtk_irq_pending(eth);
+	mtk_status = mtk_irq_pending_status(eth);
+	tx_intr = eth->soc->tx_int;
+	rx_intr = eth->soc->rx_int;
+	status_intr = eth->soc->status_int;
+	tx_done = 0;
+	rx_done = 0;
+	tx_again = 0;
+
+	if (status & tx_intr)
+		tx_done = mtk_poll_tx(eth, budget, tx_intr, &tx_again);
+
+	if (status & rx_intr)
+		rx_done = mtk_poll_rx(napi, budget, eth, rx_intr);
+
+	if (unlikely(mtk_status & status_intr)) {
+		mtk_stats_update(eth);
+		mtk_irq_ack_status(eth, status_intr);
+	}
+
+	if (unlikely(netif_msg_intr(eth))) {
+		mask = mtk_irq_enabled(eth);
+		netdev_info(eth->netdev[0],
+			    "done tx %d, rx %d, intr 0x%08x/0x%x\n",
+			    tx_done, rx_done, status, mask);
+	}
+
+	if (tx_again || rx_done == budget)
+		return budget;
+
+	status = mtk_irq_pending(eth);
+	if (status & (tx_intr | rx_intr))
+		return budget;
+
+	napi_complete(napi);
+	mtk_irq_enable(eth, tx_intr | rx_intr);
+
+	return rx_done;
+}
+
+static int mtk_pdma_tx_alloc(struct mtk_eth *eth)
+{
+	int i;
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+
+	ring->tx_ring_size = eth->soc->dma_ring_size;
+	ring->tx_free_idx = 0;
+	ring->tx_next_idx = 0;
+	ring->tx_thresh = max((unsigned long)ring->tx_ring_size >> 2,
+			      MAX_SKB_FRAGS);
+
+	ring->tx_buf = kcalloc(ring->tx_ring_size, sizeof(*ring->tx_buf),
+			GFP_KERNEL);
+	if (!ring->tx_buf)
+		goto no_tx_mem;
+
+	ring->tx_dma = dma_alloc_coherent(eth->dev,
+			ring->tx_ring_size * sizeof(*ring->tx_dma),
+			&ring->tx_phys,
+			GFP_ATOMIC | __GFP_ZERO);
+	if (!ring->tx_dma)
+		goto no_tx_mem;
+
+	for (i = 0; i < ring->tx_ring_size; i++) {
+		ring->tx_dma[i].txd2 = TX_DMA_DESP2_DEF;
+		ring->tx_dma[i].txd4 = eth->soc->txd4;
+	}
+
+	atomic_set(&ring->tx_free_count, mtk_pdma_empty_txd(ring));
+	ring->tx_map = mtk_pdma_tx_map;
+	ring->tx_poll = mtk_pdma_tx_poll;
+	ring->tx_clean = mtk_pdma_tx_clean;
+
+	/* make sure that all changes to the dma ring are flushed before we
+	 * continue
+	 */
+	wmb();
+
+	mtk_reg_w32(eth, ring->tx_phys, MTK_REG_TX_BASE_PTR0);
+	mtk_reg_w32(eth, ring->tx_ring_size, MTK_REG_TX_MAX_CNT0);
+	mtk_reg_w32(eth, 0, MTK_REG_TX_CTX_IDX0);
+	mtk_reg_w32(eth, MTK_PST_DTX_IDX0, MTK_REG_PDMA_RST_CFG);
+
+	return 0;
+
+no_tx_mem:
+	return -ENOMEM;
+}
+
+static int mtk_qdma_tx_alloc_tx(struct mtk_eth *eth)
+{
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+	int i, sz = sizeof(*ring->tx_dma);
+
+	ring->tx_ring_size = eth->soc->dma_ring_size;
+	ring->tx_buf = kcalloc(ring->tx_ring_size, sizeof(*ring->tx_buf),
+			       GFP_KERNEL);
+	if (!ring->tx_buf)
+		goto no_tx_mem;
+
+	ring->tx_dma = dma_alloc_coherent(eth->dev,
+					  ring->tx_ring_size * sz,
+					  &ring->tx_phys,
+					  GFP_ATOMIC | __GFP_ZERO);
+	if (!ring->tx_dma)
+		goto no_tx_mem;
+
+	memset(ring->tx_dma, 0, ring->tx_ring_size * sz);
+	for (i = 0; i < ring->tx_ring_size; i++) {
+		int next = (i + 1) % ring->tx_ring_size;
+		u32 next_ptr = ring->tx_phys + next * sz;
+
+		ring->tx_dma[i].txd2 = next_ptr;
+		ring->tx_dma[i].txd3 = TX_DMA_DESP2_DEF;
+	}
+
+	atomic_set(&ring->tx_free_count, ring->tx_ring_size - 2);
+	ring->tx_next_free = &ring->tx_dma[0];
+	ring->tx_last_free = &ring->tx_dma[ring->tx_ring_size - 2];
+	ring->tx_thresh = max((unsigned long)ring->tx_ring_size >> 2,
+			      MAX_SKB_FRAGS);
+
+	ring->tx_map = mtk_qdma_tx_map;
+	ring->tx_poll = mtk_qdma_tx_poll;
+	ring->tx_clean = mtk_qdma_tx_clean;
+
+	/* make sure that all changes to the dma ring are flushed before we
+	 * continue
+	 */
+	wmb();
+
+	mtk_w32(eth, ring->tx_phys, MTK_QTX_CTX_PTR);
+	mtk_w32(eth, ring->tx_phys, MTK_QTX_DTX_PTR);
+	mtk_w32(eth,
+		ring->tx_phys + ((ring->tx_ring_size - 1) * sz),
+		MTK_QTX_CRX_PTR);
+	mtk_w32(eth,
+		ring->tx_phys + ((ring->tx_ring_size - 1) * sz),
+		MTK_QTX_DRX_PTR);
+
+	return 0;
+
+no_tx_mem:
+	return -ENOMEM;
+}
+
+static int mtk_qdma_init(struct mtk_eth *eth, int ring)
+{
+	int err;
+
+	err = mtk_init_fq_dma(eth);
+	if (err)
+		return err;
+
+	err = mtk_qdma_tx_alloc_tx(eth);
+	if (err)
+		return err;
+
+	err = mtk_dma_rx_alloc(eth, &eth->rx_ring[ring]);
+	if (err)
+		return err;
+
+	mtk_w32(eth, eth->rx_ring[ring].rx_phys, MTK_QRX_BASE_PTR0);
+	mtk_w32(eth, eth->rx_ring[ring].rx_ring_size, MTK_QRX_MAX_CNT0);
+	mtk_w32(eth, eth->rx_ring[ring].rx_calc_idx, MTK_QRX_CRX_IDX0);
+	mtk_w32(eth, MTK_PST_DRX_IDX0, MTK_QDMA_RST_IDX);
+	mtk_w32(eth, (QDMA_RES_THRES << 8) | QDMA_RES_THRES, MTK_QTX_CFG(0));
+
+	/* Enable random early drop and set drop threshold automatically */
+	mtk_w32(eth, 0x174444, MTK_QDMA_FC_THRES);
+	mtk_w32(eth, 0x0, MTK_QDMA_HRED2);
+
+	return 0;
+}
+
+static int mtk_pdma_qdma_init(struct mtk_eth *eth)
+{
+	int err = mtk_qdma_init(eth, 1);
+
+	if (err)
+		return err;
+
+	err = mtk_dma_rx_alloc(eth, &eth->rx_ring[0]);
+	if (err)
+		return err;
+
+	mtk_reg_w32(eth, eth->rx_ring[0].rx_phys, MTK_REG_RX_BASE_PTR0);
+	mtk_reg_w32(eth, eth->rx_ring[0].rx_ring_size, MTK_REG_RX_MAX_CNT0);
+	mtk_reg_w32(eth, eth->rx_ring[0].rx_calc_idx, MTK_REG_RX_CALC_IDX0);
+	mtk_reg_w32(eth, MTK_PST_DRX_IDX0, MTK_REG_PDMA_RST_CFG);
+
+	return 0;
+}
+
+static int mtk_pdma_init(struct mtk_eth *eth)
+{
+	struct mtk_rx_ring *ring = &eth->rx_ring[0];
+	int err;
+
+	err = mtk_pdma_tx_alloc(eth);
+	if (err)
+		return err;
+
+	err = mtk_dma_rx_alloc(eth, ring);
+	if (err)
+		return err;
+
+	mtk_reg_w32(eth, ring->rx_phys, MTK_REG_RX_BASE_PTR0);
+	mtk_reg_w32(eth, ring->rx_ring_size, MTK_REG_RX_MAX_CNT0);
+	mtk_reg_w32(eth, ring->rx_calc_idx, MTK_REG_RX_CALC_IDX0);
+	mtk_reg_w32(eth, MTK_PST_DRX_IDX0, MTK_REG_PDMA_RST_CFG);
+
+	return 0;
+}
+
+static void mtk_dma_free(struct mtk_eth *eth)
+{
+	int i;
+
+	for (i = 0; i < eth->soc->mac_count; i++)
+		if (eth->netdev[i])
+			netdev_reset_queue(eth->netdev[i]);
+	eth->tx_ring.tx_clean(eth);
+	mtk_clean_rx(eth, &eth->rx_ring[0]);
+	mtk_clean_rx(eth, &eth->rx_ring[1]);
+	kfree(eth->scratch_head);
+}
+
+static void mtk_tx_timeout(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	struct mtk_tx_ring *ring = &eth->tx_ring;
+
+	eth->netdev[mac->id]->stats.tx_errors++;
+	netif_err(eth, tx_err, dev,
+		  "transmit timed out\n");
+	if (eth->soc->dma_type & MTK_PDMA) {
+		netif_info(eth, drv, dev, "pdma_cfg:%08x\n",
+			   mtk_reg_r32(eth, MTK_REG_PDMA_GLO_CFG));
+		netif_info(eth, drv, dev, "tx_ring=%d, "
+			   "base=%08x, max=%u, ctx=%u, dtx=%u, fdx=%hu, next=%hu\n",
+			   0, mtk_reg_r32(eth, MTK_REG_TX_BASE_PTR0),
+			   mtk_reg_r32(eth, MTK_REG_TX_MAX_CNT0),
+			   mtk_reg_r32(eth, MTK_REG_TX_CTX_IDX0),
+			   mtk_reg_r32(eth, MTK_REG_TX_DTX_IDX0),
+			   ring->tx_free_idx,
+			   ring->tx_next_idx);
+	}
+	if (eth->soc->dma_type & MTK_QDMA) {
+		netif_info(eth, drv, dev, "qdma_cfg:%08x\n",
+			   mtk_r32(eth, MTK_QDMA_GLO_CFG));
+		netif_info(eth, drv, dev, "tx_ring=%d, "
+			   "ctx=%08x, dtx=%08x, crx=%08x, drx=%08x, free=%hu\n",
+			   0, mtk_r32(eth, MTK_QTX_CTX_PTR),
+			   mtk_r32(eth, MTK_QTX_DTX_PTR),
+			   mtk_r32(eth, MTK_QTX_CRX_PTR),
+			   mtk_r32(eth, MTK_QTX_DRX_PTR),
+			   atomic_read(&ring->tx_free_count));
+	}
+	netif_info(eth, drv, dev,
+		   "rx_ring=%d, base=%08x, max=%u, calc=%u, drx=%u\n",
+		   0, mtk_reg_r32(eth, MTK_REG_RX_BASE_PTR0),
+		   mtk_reg_r32(eth, MTK_REG_RX_MAX_CNT0),
+		   mtk_reg_r32(eth, MTK_REG_RX_CALC_IDX0),
+		   mtk_reg_r32(eth, MTK_REG_RX_DRX_IDX0));
+
+	schedule_work(&mac->pending_work);
+}
+
+static irqreturn_t mtk_handle_irq(int irq, void *_eth)
+{
+	struct mtk_eth *eth = _eth;
+	u32 status, int_mask;
+
+	status = mtk_irq_pending(eth);
+	if (unlikely(!status))
+		return IRQ_NONE;
+
+	int_mask = (eth->soc->rx_int | eth->soc->tx_int);
+	if (likely(status & int_mask)) {
+		if (likely(napi_schedule_prep(&eth->rx_napi)))
+			__napi_schedule(&eth->rx_napi);
+	} else {
+		mtk_irq_ack(eth, status);
+	}
+	mtk_irq_disable(eth, int_mask);
+
+	return IRQ_HANDLED;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void mtk_poll_controller(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	u32 int_mask = eth->soc->tx_int | eth->soc->rx_int;
+
+	mtk_irq_disable(eth, int_mask);
+	mtk_handle_irq(dev->irq, dev);
+	mtk_irq_enable(eth, int_mask);
+}
+#endif
+
+int mtk_set_clock_cycle(struct mtk_eth *eth)
+{
+	unsigned long sysclk = eth->sysclk;
+
+	sysclk /= MTK_US_CYC_CNT_DIVISOR;
+	sysclk <<= MTK_US_CYC_CNT_SHIFT;
+
+	mtk_w32(eth, (mtk_r32(eth, MTK_GLO_CFG) &
+			~(MTK_US_CYC_CNT_MASK << MTK_US_CYC_CNT_SHIFT)) |
+			sysclk,
+			MTK_GLO_CFG);
+	return 0;
+}
+
+void mtk_fwd_config(struct mtk_eth *eth)
+{
+	u32 fwd_cfg;
+
+	fwd_cfg = mtk_r32(eth, MTK_GDMA1_FWD_CFG);
+
+	/* disable jumbo frame */
+	if (eth->soc->jumbo_frame)
+		fwd_cfg &= ~MTK_GDM1_JMB_EN;
+
+	/* set unicast/multicast/broadcast frame to cpu */
+	fwd_cfg &= ~0xffff;
+
+	mtk_w32(eth, fwd_cfg, MTK_GDMA1_FWD_CFG);
+}
+
+void mtk_csum_config(struct mtk_eth *eth)
+{
+	if (eth->soc->hw_features & NETIF_F_RXCSUM)
+		mtk_w32(eth, mtk_r32(eth, MTK_GDMA1_FWD_CFG) |
+			(MTK_GDM1_ICS_EN | MTK_GDM1_TCS_EN | MTK_GDM1_UCS_EN),
+			MTK_GDMA1_FWD_CFG);
+	else
+		mtk_w32(eth, mtk_r32(eth, MTK_GDMA1_FWD_CFG) &
+			~(MTK_GDM1_ICS_EN | MTK_GDM1_TCS_EN | MTK_GDM1_UCS_EN),
+			MTK_GDMA1_FWD_CFG);
+	if (eth->soc->hw_features & NETIF_F_IP_CSUM)
+		mtk_w32(eth, mtk_r32(eth, MTK_CDMA_CSG_CFG) |
+			(MTK_ICS_GEN_EN | MTK_TCS_GEN_EN | MTK_UCS_GEN_EN),
+			MTK_CDMA_CSG_CFG);
+	else
+		mtk_w32(eth, mtk_r32(eth, MTK_CDMA_CSG_CFG) &
+			~(MTK_ICS_GEN_EN | MTK_TCS_GEN_EN | MTK_UCS_GEN_EN),
+			MTK_CDMA_CSG_CFG);
+}
+
+static int mtk_start_dma(struct mtk_eth *eth)
+{
+	unsigned long flags;
+	u32 val;
+	int err;
+
+	if (eth->soc->dma_type == MTK_PDMA)
+		err = mtk_pdma_init(eth);
+	else if (eth->soc->dma_type == MTK_QDMA)
+		err = mtk_qdma_init(eth, 0);
+	else
+		err = mtk_pdma_qdma_init(eth);
+	if (err) {
+		mtk_dma_free(eth);
+		return err;
+	}
+
+	spin_lock_irqsave(&eth->page_lock, flags);
+
+	val = MTK_TX_WB_DDONE | MTK_RX_DMA_EN | MTK_TX_DMA_EN;
+	if (eth->soc->rx_2b_offset)
+		val |= MTK_RX_2B_OFFSET;
+	val |= eth->soc->pdma_glo_cfg;
+
+	if (eth->soc->dma_type & MTK_PDMA)
+		mtk_reg_w32(eth, val, MTK_REG_PDMA_GLO_CFG);
+
+	if (eth->soc->dma_type & MTK_QDMA)
+		mtk_w32(eth, val, MTK_QDMA_GLO_CFG);
+
+	spin_unlock_irqrestore(&eth->page_lock, flags);
+
+	return 0;
+}
+
+static int mtk_open(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+
+	if (!atomic_read(&eth->dma_refcnt)) {
+		int err = mtk_start_dma(eth);
+
+		if (err)
+			return err;
+
+		napi_enable(&eth->rx_napi);
+		mtk_irq_enable(eth, eth->soc->tx_int | eth->soc->rx_int);
+	}
+	atomic_inc(&eth->dma_refcnt);
+
+	if (eth->phy)
+		eth->phy->start(mac);
+
+	if (eth->soc->has_carrier && eth->soc->has_carrier(eth))
+		netif_carrier_on(dev);
+
+	netif_start_queue(dev);
+	eth->soc->fwd_config(eth);
+
+	return 0;
+}
+
+static void mtk_stop_dma(struct mtk_eth *eth, u32 glo_cfg)
+{
+	unsigned long flags;
+	u32 val;
+	int i;
+
+	/* stop the dma enfine */
+	spin_lock_irqsave(&eth->page_lock, flags);
+	val = mtk_r32(eth, glo_cfg);
+	mtk_w32(eth, val & ~(MTK_TX_WB_DDONE | MTK_RX_DMA_EN | MTK_TX_DMA_EN),
+		glo_cfg);
+	spin_unlock_irqrestore(&eth->page_lock, flags);
+
+	/* wait for dma stop */
+	for (i = 0; i < 10; i++) {
+		val = mtk_r32(eth, glo_cfg);
+		if (val & (MTK_TX_DMA_BUSY | MTK_RX_DMA_BUSY)) {
+			msleep(20);
+			continue;
+		}
+		break;
+	}
+}
+
+static int mtk_stop(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+
+	netif_tx_disable(dev);
+	if (eth->phy)
+		eth->phy->stop(mac);
+
+	if (!atomic_dec_and_test(&eth->dma_refcnt))
+		return 0;
+
+	mtk_irq_disable(eth, eth->soc->tx_int | eth->soc->rx_int);
+	napi_disable(&eth->rx_napi);
+
+	if (eth->soc->dma_type & MTK_PDMA)
+		mtk_stop_dma(eth, mtk_reg_table[MTK_REG_PDMA_GLO_CFG]);
+
+	if (eth->soc->dma_type & MTK_QDMA)
+		mtk_stop_dma(eth, MTK_QDMA_GLO_CFG);
+
+	mtk_dma_free(eth);
+
+	return 0;
+}
+
+static int __init mtk_init_hw(struct mtk_eth *eth)
+{
+	int i, err;
+
+	eth->soc->reset_fe(eth);
+
+	if (eth->soc->switch_init)
+		if (eth->soc->switch_init(eth)) {
+			dev_err(eth->dev, "failed to initialize switch core\n");
+			return -ENODEV;
+		}
+
+	err = devm_request_irq(eth->dev, eth->irq, mtk_handle_irq, 0,
+			       dev_name(eth->dev), eth);
+	if (err)
+		return err;
+
+	err = mtk_mdio_init(eth);
+	if (err)
+		return err;
+
+	/* disable delay and normal interrupt */
+	mtk_reg_w32(eth, 0, MTK_REG_DLY_INT_CFG);
+	if (eth->soc->dma_type & MTK_QDMA)
+		mtk_w32(eth, 0, MTK_QDMA_DELAY_INT);
+	mtk_irq_disable(eth, eth->soc->tx_int | eth->soc->rx_int);
+
+	/* frame engine will push VLAN tag regarding to VIDX field in Tx desc */
+	if (mtk_reg_table[MTK_REG_MTK_DMA_VID_BASE])
+		for (i = 0; i < 16; i += 2)
+			mtk_w32(eth, ((i + 1) << 16) + i,
+				mtk_reg_table[MTK_REG_MTK_DMA_VID_BASE] +
+				(i * 2));
+
+	if (eth->soc->fwd_config(eth))
+		dev_err(eth->dev, "unable to get clock\n");
+
+	if (mtk_reg_table[MTK_REG_MTK_RST_GL]) {
+		mtk_reg_w32(eth, 1, MTK_REG_MTK_RST_GL);
+		mtk_reg_w32(eth, 0, MTK_REG_MTK_RST_GL);
+	}
+
+	return 0;
+}
+
+static int __init mtk_init(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	struct device_node *port;
+	const char *mac_addr;
+	int err;
+
+	mac_addr = of_get_mac_address(mac->of_node);
+	if (mac_addr)
+		ether_addr_copy(dev->dev_addr, mac_addr);
+
+	/* If the mac address is invalid, use random mac address  */
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		random_ether_addr(dev->dev_addr);
+		dev_err(eth->dev, "generated random MAC address %pM\n",
+			dev->dev_addr);
+		dev->addr_assign_type = NET_ADDR_RANDOM;
+	}
+
+	if (eth->soc->port_init)
+		for_each_child_of_node(mac->of_node, port)
+			if (of_device_is_compatible(port,
+						    "mediatek,eth-port") &&
+			    of_device_is_available(port))
+				eth->soc->port_init(eth, mac, port);
+
+	if (eth->phy) {
+		err = eth->phy->connect(mac);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static void mtk_uninit(struct net_device *dev)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+
+	if (eth->phy)
+		eth->phy->disconnect(mac);
+	mtk_mdio_cleanup(eth);
+
+	mtk_irq_disable(eth, ~0);
+	free_irq(dev->irq, dev);
+}
+
+static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+
+	if (!mac->phy_dev)
+		return -ENODEV;
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		return phy_mii_ioctl(mac->phy_dev, ifr, cmd);
+	default:
+		break;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static int mtk_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth = mac->hw;
+	int frag_size, old_mtu;
+	u32 fwd_cfg;
+
+	if (!eth->soc->jumbo_frame)
+		return eth_change_mtu(dev, new_mtu);
+
+	frag_size = mtk_max_frag_size(new_mtu);
+	if (new_mtu < 68 || frag_size > PAGE_SIZE)
+		return -EINVAL;
+
+	old_mtu = dev->mtu;
+	dev->mtu = new_mtu;
+
+	/* return early if the buffer sizes will not change */
+	if (old_mtu <= ETH_DATA_LEN && new_mtu <= ETH_DATA_LEN)
+		return 0;
+	if (old_mtu > ETH_DATA_LEN && new_mtu > ETH_DATA_LEN)
+		return 0;
+
+	if (new_mtu <= ETH_DATA_LEN)
+		eth->rx_ring[0].frag_size = mtk_max_frag_size(ETH_DATA_LEN);
+	else
+		eth->rx_ring[0].frag_size = PAGE_SIZE;
+	eth->rx_ring[0].rx_buf_size =
+				mtk_max_buf_size(eth->rx_ring[0].frag_size);
+
+	if (!netif_running(dev))
+		return 0;
+
+	mtk_stop(dev);
+	fwd_cfg = mtk_r32(eth, MTK_GDMA1_FWD_CFG);
+	if (new_mtu <= ETH_DATA_LEN) {
+		fwd_cfg &= ~MTK_GDM1_JMB_EN;
+	} else {
+		fwd_cfg &= ~(MTK_GDM1_JMB_LEN_MASK << MTK_GDM1_JMB_LEN_SHIFT);
+		fwd_cfg |= (DIV_ROUND_UP(frag_size, 1024) <<
+				MTK_GDM1_JMB_LEN_SHIFT) | MTK_GDM1_JMB_EN;
+	}
+	mtk_w32(eth, fwd_cfg, MTK_GDMA1_FWD_CFG);
+
+	return mtk_open(dev);
+}
+
+static void mtk_pending_work(struct work_struct *work)
+{
+	struct mtk_mac *mac = container_of(work, struct mtk_mac, pending_work);
+	struct mtk_eth *eth = mac->hw;
+	struct net_device *dev = eth->netdev[mac->id];
+	int err;
+
+	rtnl_lock();
+	mtk_stop(dev);
+
+	err = mtk_open(dev);
+	if (err) {
+		netif_alert(eth, ifup, dev,
+			    "Driver up/down cycle failed, closing device.\n");
+		dev_close(dev);
+	}
+	rtnl_unlock();
+}
+
+static int mtk_cleanup(struct mtk_eth *eth)
+{
+	int i;
+
+	for (i = 0; i < eth->soc->mac_count; i++) {
+		struct mtk_mac *mac = netdev_priv(eth->netdev[i]);
+
+		if (!eth->netdev[i])
+			continue;
+
+		unregister_netdev(eth->netdev[i]);
+		free_netdev(eth->netdev[i]);
+		cancel_work_sync(&mac->pending_work);
+	}
+
+	return 0;
+}
+
+static const struct net_device_ops mtk_netdev_ops = {
+	.ndo_init		= mtk_init,
+	.ndo_uninit		= mtk_uninit,
+	.ndo_open		= mtk_open,
+	.ndo_stop		= mtk_stop,
+	.ndo_start_xmit		= mtk_start_xmit,
+	.ndo_set_mac_address	= mtk_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= mtk_do_ioctl,
+	.ndo_change_mtu		= mtk_change_mtu,
+	.ndo_tx_timeout		= mtk_tx_timeout,
+	.ndo_get_stats64        = mtk_get_stats64,
+	.ndo_vlan_rx_add_vid	= mtk_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= mtk_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= mtk_poll_controller,
+#endif
+};
+
+static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
+{
+	struct mtk_mac *mac;
+	const __be32 *_id = of_get_property(np, "reg", NULL);
+	int id, err;
+
+	if (!_id) {
+		dev_err(eth->dev, "missing mac id\n");
+		return -EINVAL;
+	}
+	id = be32_to_cpup(_id);
+	if (id >= eth->soc->mac_count || eth->netdev[id]) {
+		dev_err(eth->dev, "%d is not a valid mac id\n", id);
+		return -EINVAL;
+	}
+
+	eth->netdev[id] = alloc_etherdev(sizeof(*mac));
+	if (!eth->netdev[id]) {
+		dev_err(eth->dev, "alloc_etherdev failed\n");
+		return -ENOMEM;
+	}
+	mac = netdev_priv(eth->netdev[id]);
+	eth->mac[id] = mac;
+	mac->id = id;
+	mac->hw = eth;
+	mac->of_node = np;
+	INIT_WORK(&mac->pending_work, mtk_pending_work);
+
+	if (mtk_reg_table[MTK_REG_MTK_COUNTER_BASE]) {
+		mac->hw_stats = devm_kzalloc(eth->dev,
+					      sizeof(*mac->hw_stats),
+					      GFP_KERNEL);
+		if (!mac->hw_stats)
+			return -ENOMEM;
+		spin_lock_init(&mac->hw_stats->stats_lock);
+		mac->hw_stats->reg_offset = id * MTK_STAT_OFFSET;
+	}
+
+	SET_NETDEV_DEV(eth->netdev[id], eth->dev);
+	eth->netdev[id]->netdev_ops = &mtk_netdev_ops;
+	eth->netdev[id]->base_addr = (unsigned long)eth->base;
+
+	if (eth->soc->init_data)
+		eth->soc->init_data(eth->soc, eth->netdev[id]);
+
+	eth->netdev[id]->vlan_features = eth->soc->hw_features &
+		~(NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX);
+	eth->netdev[id]->features |= eth->soc->hw_features;
+
+	if (mtk_reg_table[MTK_REG_MTK_DMA_VID_BASE])
+		eth->netdev[id]->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	mtk_set_ethtool_ops(eth->netdev[id]);
+
+	err = register_netdev(eth->netdev[id]);
+	if (err) {
+		dev_err(eth->dev, "error bringing up device\n");
+		return err;
+	}
+	eth->netdev[id]->irq = eth->irq;
+	netif_info(eth, probe, eth->netdev[id],
+		   "mediatek frame engine at 0x%08lx, irq %d\n",
+		   eth->netdev[id]->base_addr, eth->netdev[id]->irq);
+
+	return 0;
+}
+
+static int mtk_probe(struct platform_device *pdev)
+{
+	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	const struct of_device_id *match;
+	struct device_node *mac_np;
+	struct mtk_soc_data *soc;
+	struct mtk_eth *eth;
+	struct clk *sysclk;
+	int err;
+
+	pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+	pdev->dev.dma_mask = &pdev->dev.coherent_dma_mask;
+
+	device_reset(&pdev->dev);
+
+	match = of_match_device(of_mtk_match, &pdev->dev);
+	soc = (struct mtk_soc_data *)match->data;
+
+	if (soc->reg_table)
+		mtk_reg_table = soc->reg_table;
+
+	eth = devm_kzalloc(&pdev->dev, sizeof(*eth), GFP_KERNEL);
+	if (!eth)
+		return -ENOMEM;
+
+	eth->base = devm_ioremap_resource(&pdev->dev, res);
+	if (!eth->base)
+		return -EADDRNOTAVAIL;
+
+	spin_lock_init(&eth->page_lock);
+
+	eth->ethsys = syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
+						      "mediatek,ethsys");
+	if (IS_ERR(eth->ethsys))
+		return PTR_ERR(eth->ethsys);
+
+	eth->irq = platform_get_irq(pdev, 0);
+	if (eth->irq < 0) {
+		dev_err(&pdev->dev, "no IRQ resource found\n");
+		return -ENXIO;
+	}
+
+	sysclk = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(sysclk)) {
+		dev_err(&pdev->dev,
+			"the clock is not defined in the devictree\n");
+		return -ENXIO;
+	}
+	eth->sysclk = clk_get_rate(sysclk);
+
+	eth->switch_np = of_parse_phandle(pdev->dev.of_node,
+					  "mediatek,switch", 0);
+	if (soc->has_switch && !eth->switch_np) {
+		dev_err(&pdev->dev, "failed to read switch phandle\n");
+		return -ENODEV;
+	}
+
+	eth->dev = &pdev->dev;
+	eth->soc = soc;
+	eth->msg_enable = netif_msg_init(mtk_msg_level, MTK_DEFAULT_MSG_ENABLE);
+
+	err = mtk_init_hw(eth);
+	if (err)
+		return err;
+
+	if (eth->soc->mac_count > 1) {
+		for_each_child_of_node(pdev->dev.of_node, mac_np) {
+			if (!of_device_is_compatible(mac_np,
+						     "mediatek,eth-mac"))
+				continue;
+
+			if (!of_device_is_available(mac_np))
+				continue;
+
+			err = mtk_add_mac(eth, mac_np);
+			if (err)
+				goto err_free_dev;
+		}
+
+		init_dummy_netdev(&eth->dummy_dev);
+		netif_napi_add(&eth->dummy_dev, &eth->rx_napi, mtk_poll,
+			       soc->napi_weight);
+	} else {
+		err = mtk_add_mac(eth, pdev->dev.of_node);
+		if (err)
+			goto err_free_dev;
+		netif_napi_add(eth->netdev[0], &eth->rx_napi, mtk_poll,
+			       soc->napi_weight);
+	}
+
+	platform_set_drvdata(pdev, eth);
+
+	return 0;
+
+err_free_dev:
+	mtk_cleanup(eth);
+	return err;
+}
+
+static int mtk_remove(struct platform_device *pdev)
+{
+	struct mtk_eth *eth = platform_get_drvdata(pdev);
+
+	netif_napi_del(&eth->rx_napi);
+	mtk_cleanup(eth);
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver mtk_driver = {
+	.probe = mtk_probe,
+	.remove = mtk_remove,
+	.driver = {
+		.name = "mtk_soc_eth",
+		.owner = THIS_MODULE,
+		.of_match_table = of_mtk_match,
+	},
+};
+
+module_platform_driver(mtk_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>");
+MODULE_DESCRIPTION("Ethernet driver for MediaTek SoC");
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
new file mode 100644
index 0000000..2822a2f
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -0,0 +1,720 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef MTK_ETH_H
+#define MTK_ETH_H
+
+#include <linux/mii.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/dma-mapping.h>
+#include <linux/phy.h>
+#include <linux/ethtool.h>
+#include <linux/version.h>
+#include <linux/atomic.h>
+
+/* these registers have different offsets depending on the SoC. we use a lookup
+ * table for these
+ */
+enum mtk_reg {
+	MTK_REG_PDMA_GLO_CFG = 0,
+	MTK_REG_PDMA_RST_CFG,
+	MTK_REG_DLY_INT_CFG,
+	MTK_REG_TX_BASE_PTR0,
+	MTK_REG_TX_MAX_CNT0,
+	MTK_REG_TX_CTX_IDX0,
+	MTK_REG_TX_DTX_IDX0,
+	MTK_REG_RX_BASE_PTR0,
+	MTK_REG_RX_MAX_CNT0,
+	MTK_REG_RX_CALC_IDX0,
+	MTK_REG_RX_DRX_IDX0,
+	MTK_REG_MTK_INT_ENABLE,
+	MTK_REG_MTK_INT_STATUS,
+	MTK_REG_MTK_DMA_VID_BASE,
+	MTK_REG_MTK_COUNTER_BASE,
+	MTK_REG_MTK_RST_GL,
+	MTK_REG_MTK_INT_STATUS2,
+	MTK_REG_COUNT
+};
+
+/* delayed interrupt bits */
+#define MTK_DELAY_EN_INT	0x80
+#define MTK_DELAY_MAX_INT	0x04
+#define MTK_DELAY_MAX_TOUT	0x04
+#define MTK_DELAY_TIME		20
+#define MTK_DELAY_CHAN		(((MTK_DELAY_EN_INT | MTK_DELAY_MAX_INT) << 8) \
+				 | MTK_DELAY_MAX_TOUT)
+#define MTK_DELAY_INIT		((MTK_DELAY_CHAN << 16) | MTK_DELAY_CHAN)
+#define MTK_PSE_FQFC_CFG_INIT	0x80504000
+#define MTK_PSE_FQFC_CFG_256Q	0xff908000
+
+/* interrupt bits */
+#define MTK_CNT_PPE_AF		BIT(31)
+#define MTK_CNT_GDM_AF		BIT(29)
+#define MTK_PSE_P2_FC		BIT(26)
+#define MTK_PSE_BUF_DROP	BIT(24)
+#define MTK_GDM_OTHER_DROP	BIT(23)
+#define MTK_PSE_P1_FC		BIT(22)
+#define MTK_PSE_P0_FC		BIT(21)
+#define MTK_PSE_FQ_EMPTY	BIT(20)
+#define MTK_GE1_STA_CHG		BIT(18)
+#define MTK_TX_COHERENT		BIT(17)
+#define MTK_RX_COHERENT		BIT(16)
+#define MTK_TX_DONE_INT3	BIT(11)
+#define MTK_TX_DONE_INT2	BIT(10)
+#define MTK_TX_DONE_INT1	BIT(9)
+#define MTK_TX_DONE_INT0	BIT(8)
+#define MTK_RX_DONE_INT0	BIT(2)
+#define MTK_TX_DLY_INT		BIT(1)
+#define MTK_RX_DLY_INT		BIT(0)
+
+#define MTK_RX_DONE_INT		MTK_RX_DONE_INT0
+#define MTK_TX_DONE_INT		(MTK_TX_DONE_INT0 | MTK_TX_DONE_INT1 | \
+				 MTK_TX_DONE_INT2 | MTK_TX_DONE_INT3)
+
+#define RT5350_RX_DLY_INT	BIT(30)
+#define RT5350_TX_DLY_INT	BIT(28)
+#define RT5350_RX_DONE_INT1	BIT(17)
+#define RT5350_RX_DONE_INT0	BIT(16)
+#define RT5350_TX_DONE_INT3	BIT(3)
+#define RT5350_TX_DONE_INT2	BIT(2)
+#define RT5350_TX_DONE_INT1	BIT(1)
+#define RT5350_TX_DONE_INT0	BIT(0)
+
+#define RT5350_RX_DONE_INT	(RT5350_RX_DONE_INT0 | RT5350_RX_DONE_INT1)
+#define RT5350_TX_DONE_INT	(RT5350_TX_DONE_INT0 | RT5350_TX_DONE_INT1 | \
+				 RT5350_TX_DONE_INT2 | RT5350_TX_DONE_INT3)
+
+/* registers */
+#define MTK_GDMA_OFFSET		0x0020
+#define MTK_PSE_OFFSET		0x0040
+#define MTK_GDMA2_OFFSET	0x0060
+#define MTK_CDMA_OFFSET		0x0080
+#define MTK_DMA_VID0		0x00a8
+#define MTK_PDMA_OFFSET		0x0100
+#define MTK_PPE_OFFSET		0x0200
+#define MTK_CMTABLE_OFFSET	0x0400
+#define MTK_POLICYTABLE_OFFSET	0x1000
+
+#define MT7621_GDMA_OFFSET	0x0500
+#define MT7620_GDMA_OFFSET	0x0600
+
+#define RT5350_PDMA_OFFSET	0x0800
+#define RT5350_SDM_OFFSET	0x0c00
+
+#define MTK_MDIO_ACCESS		0x00
+#define MTK_MDIO_CFG		0x04
+#define MTK_GLO_CFG		0x08
+#define MTK_RST_GL		0x0C
+#define MTK_INT_STATUS		0x10
+#define MTK_INT_ENABLE		0x14
+#define MTK_MDIO_CFG2		0x18
+#define MTK_FOC_TS_T		0x1C
+
+#define	MTK_GDMA1_FWD_CFG	(MTK_GDMA_OFFSET + 0x00)
+#define MTK_GDMA1_SCH_CFG	(MTK_GDMA_OFFSET + 0x04)
+#define MTK_GDMA1_SHPR_CFG	(MTK_GDMA_OFFSET + 0x08)
+#define MTK_GDMA1_MAC_ADRL	(MTK_GDMA_OFFSET + 0x0C)
+#define MTK_GDMA1_MAC_ADRH	(MTK_GDMA_OFFSET + 0x10)
+
+#define	MTK_GDMA2_FWD_CFG	(MTK_GDMA2_OFFSET + 0x00)
+#define MTK_GDMA2_SCH_CFG	(MTK_GDMA2_OFFSET + 0x04)
+#define MTK_GDMA2_SHPR_CFG	(MTK_GDMA2_OFFSET + 0x08)
+#define MTK_GDMA2_MAC_ADRL	(MTK_GDMA2_OFFSET + 0x0C)
+#define MTK_GDMA2_MAC_ADRH	(MTK_GDMA2_OFFSET + 0x10)
+
+#define MTK_PSE_FQ_CFG		(MTK_PSE_OFFSET + 0x00)
+#define MTK_CDMA_FC_CFG		(MTK_PSE_OFFSET + 0x04)
+#define MTK_GDMA1_FC_CFG	(MTK_PSE_OFFSET + 0x08)
+#define MTK_GDMA2_FC_CFG	(MTK_PSE_OFFSET + 0x0C)
+
+#define MTK_CDMA_CSG_CFG	(MTK_CDMA_OFFSET + 0x00)
+#define MTK_CDMA_SCH_CFG	(MTK_CDMA_OFFSET + 0x04)
+
+#define	MT7621_GDMA_FWD_CFG(x)	(MT7621_GDMA_OFFSET + (x * 0x1000))
+
+#define	MT7620_GDMA1_FWD_CFG	(MT7620_GDMA_OFFSET + 0x00)
+
+#define RT5350_TX_BASE_PTR0	(RT5350_PDMA_OFFSET + 0x00)
+#define RT5350_TX_MAX_CNT0	(RT5350_PDMA_OFFSET + 0x04)
+#define RT5350_TX_CTX_IDX0	(RT5350_PDMA_OFFSET + 0x08)
+#define RT5350_TX_DTX_IDX0	(RT5350_PDMA_OFFSET + 0x0C)
+#define RT5350_TX_BASE_PTR1	(RT5350_PDMA_OFFSET + 0x10)
+#define RT5350_TX_MAX_CNT1	(RT5350_PDMA_OFFSET + 0x14)
+#define RT5350_TX_CTX_IDX1	(RT5350_PDMA_OFFSET + 0x18)
+#define RT5350_TX_DTX_IDX1	(RT5350_PDMA_OFFSET + 0x1C)
+#define RT5350_TX_BASE_PTR2	(RT5350_PDMA_OFFSET + 0x20)
+#define RT5350_TX_MAX_CNT2	(RT5350_PDMA_OFFSET + 0x24)
+#define RT5350_TX_CTX_IDX2	(RT5350_PDMA_OFFSET + 0x28)
+#define RT5350_TX_DTX_IDX2	(RT5350_PDMA_OFFSET + 0x2C)
+#define RT5350_TX_BASE_PTR3	(RT5350_PDMA_OFFSET + 0x30)
+#define RT5350_TX_MAX_CNT3	(RT5350_PDMA_OFFSET + 0x34)
+#define RT5350_TX_CTX_IDX3	(RT5350_PDMA_OFFSET + 0x38)
+#define RT5350_TX_DTX_IDX3	(RT5350_PDMA_OFFSET + 0x3C)
+#define RT5350_RX_BASE_PTR0	(RT5350_PDMA_OFFSET + 0x100)
+#define RT5350_RX_MAX_CNT0	(RT5350_PDMA_OFFSET + 0x104)
+#define RT5350_RX_CALC_IDX0	(RT5350_PDMA_OFFSET + 0x108)
+#define RT5350_RX_DRX_IDX0	(RT5350_PDMA_OFFSET + 0x10C)
+#define RT5350_RX_BASE_PTR1	(RT5350_PDMA_OFFSET + 0x110)
+#define RT5350_RX_MAX_CNT1	(RT5350_PDMA_OFFSET + 0x114)
+#define RT5350_RX_CALC_IDX1	(RT5350_PDMA_OFFSET + 0x118)
+#define RT5350_RX_DRX_IDX1	(RT5350_PDMA_OFFSET + 0x11C)
+#define RT5350_PDMA_GLO_CFG	(RT5350_PDMA_OFFSET + 0x204)
+#define RT5350_PDMA_RST_CFG	(RT5350_PDMA_OFFSET + 0x208)
+#define RT5350_DLY_INT_CFG	(RT5350_PDMA_OFFSET + 0x20c)
+#define RT5350_MTK_INT_STATUS	(RT5350_PDMA_OFFSET + 0x220)
+#define RT5350_MTK_INT_ENABLE	(RT5350_PDMA_OFFSET + 0x228)
+#define RT5350_PDMA_SCH_CFG	(RT5350_PDMA_OFFSET + 0x280)
+
+#define MTK_PDMA_GLO_CFG	(MTK_PDMA_OFFSET + 0x00)
+#define MTK_PDMA_RST_CFG	(MTK_PDMA_OFFSET + 0x04)
+#define MTK_PDMA_SCH_CFG	(MTK_PDMA_OFFSET + 0x08)
+#define MTK_DLY_INT_CFG		(MTK_PDMA_OFFSET + 0x0C)
+#define MTK_TX_BASE_PTR0	(MTK_PDMA_OFFSET + 0x10)
+#define MTK_TX_MAX_CNT0		(MTK_PDMA_OFFSET + 0x14)
+#define MTK_TX_CTX_IDX0		(MTK_PDMA_OFFSET + 0x18)
+#define MTK_TX_DTX_IDX0		(MTK_PDMA_OFFSET + 0x1C)
+#define MTK_TX_BASE_PTR1	(MTK_PDMA_OFFSET + 0x20)
+#define MTK_TX_MAX_CNT1		(MTK_PDMA_OFFSET + 0x24)
+#define MTK_TX_CTX_IDX1		(MTK_PDMA_OFFSET + 0x28)
+#define MTK_TX_DTX_IDX1		(MTK_PDMA_OFFSET + 0x2C)
+#define MTK_RX_BASE_PTR0	(MTK_PDMA_OFFSET + 0x30)
+#define MTK_RX_MAX_CNT0		(MTK_PDMA_OFFSET + 0x34)
+#define MTK_RX_CALC_IDX0	(MTK_PDMA_OFFSET + 0x38)
+#define MTK_RX_DRX_IDX0		(MTK_PDMA_OFFSET + 0x3C)
+#define MTK_TX_BASE_PTR2	(MTK_PDMA_OFFSET + 0x40)
+#define MTK_TX_MAX_CNT2		(MTK_PDMA_OFFSET + 0x44)
+#define MTK_TX_CTX_IDX2		(MTK_PDMA_OFFSET + 0x48)
+#define MTK_TX_DTX_IDX2		(MTK_PDMA_OFFSET + 0x4C)
+#define MTK_TX_BASE_PTR3	(MTK_PDMA_OFFSET + 0x50)
+#define MTK_TX_MAX_CNT3		(MTK_PDMA_OFFSET + 0x54)
+#define MTK_TX_CTX_IDX3		(MTK_PDMA_OFFSET + 0x58)
+#define MTK_TX_DTX_IDX3		(MTK_PDMA_OFFSET + 0x5C)
+#define MTK_RX_BASE_PTR1	(MTK_PDMA_OFFSET + 0x60)
+#define MTK_RX_MAX_CNT1		(MTK_PDMA_OFFSET + 0x64)
+#define MTK_RX_CALC_IDX1	(MTK_PDMA_OFFSET + 0x68)
+#define MTK_RX_DRX_IDX1		(MTK_PDMA_OFFSET + 0x6C)
+
+/* Switch DMA configuration */
+#define RT5350_SDM_CFG		(RT5350_SDM_OFFSET + 0x00)
+#define RT5350_SDM_RRING	(RT5350_SDM_OFFSET + 0x04)
+#define RT5350_SDM_TRING	(RT5350_SDM_OFFSET + 0x08)
+#define RT5350_SDM_MAC_ADRL	(RT5350_SDM_OFFSET + 0x0C)
+#define RT5350_SDM_MAC_ADRH	(RT5350_SDM_OFFSET + 0x10)
+#define RT5350_SDM_TPCNT	(RT5350_SDM_OFFSET + 0x100)
+#define RT5350_SDM_TBCNT	(RT5350_SDM_OFFSET + 0x104)
+#define RT5350_SDM_RPCNT	(RT5350_SDM_OFFSET + 0x108)
+#define RT5350_SDM_RBCNT	(RT5350_SDM_OFFSET + 0x10C)
+#define RT5350_SDM_CS_ERR	(RT5350_SDM_OFFSET + 0x110)
+
+#define RT5350_SDM_ICS_EN	BIT(16)
+#define RT5350_SDM_TCS_EN	BIT(17)
+#define RT5350_SDM_UCS_EN	BIT(18)
+
+/* QDMA registers */
+#define MTK_QTX_CFG(x)		(0x1800 + (x * 0x10))
+#define MTK_QTX_SCH(x)		(0x1804 + (x * 0x10))
+#define MTK_QRX_BASE_PTR0	0x1900
+#define MTK_QRX_MAX_CNT0	0x1904
+#define MTK_QRX_CRX_IDX0	0x1908
+#define MTK_QRX_DRX_IDX0	0x190C
+#define MTK_QDMA_GLO_CFG	0x1A04
+#define MTK_QDMA_RST_IDX	0x1A08
+#define MTK_QDMA_DELAY_INT	0x1A0C
+#define MTK_QDMA_FC_THRES	0x1A10
+#define MTK_QMTK_INT_STATUS	0x1A18
+#define MTK_QMTK_INT_ENABLE	0x1A1C
+#define MTK_QDMA_HRED2		0x1A44
+
+#define MTK_QTX_CTX_PTR		0x1B00
+#define MTK_QTX_DTX_PTR		0x1B04
+
+#define MTK_QTX_CRX_PTR		0x1B10
+#define MTK_QTX_DRX_PTR		0x1B14
+
+#define MTK_QDMA_FQ_HEAD	0x1B20
+#define MTK_QDMA_FQ_TAIL	0x1B24
+#define MTK_QDMA_FQ_CNT		0x1B28
+#define MTK_QDMA_FQ_BLEN	0x1B2C
+
+#define QDMA_PAGE_SIZE		2048
+#define QDMA_TX_OWNER_CPU	BIT(31)
+#define QDMA_TX_SWC		BIT(14)
+#define TX_QDMA_SDL(_x)		(((_x) & 0x3fff) << 16)
+#define QDMA_RES_THRES		4
+
+/* MDIO_CFG register bits */
+#define MTK_MDIO_CFG_AUTO_POLL_EN	BIT(29)
+#define MTK_MDIO_CFG_GP1_BP_EN		BIT(16)
+#define MTK_MDIO_CFG_GP1_FRC_EN		BIT(15)
+#define MTK_MDIO_CFG_GP1_SPEED_10	(0 << 13)
+#define MTK_MDIO_CFG_GP1_SPEED_100	(1 << 13)
+#define MTK_MDIO_CFG_GP1_SPEED_1000	(2 << 13)
+#define MTK_MDIO_CFG_GP1_DUPLEX		BIT(12)
+#define MTK_MDIO_CFG_GP1_FC_TX		BIT(11)
+#define MTK_MDIO_CFG_GP1_FC_RX		BIT(10)
+#define MTK_MDIO_CFG_GP1_LNK_DWN	BIT(9)
+#define MTK_MDIO_CFG_GP1_AN_FAIL	BIT(8)
+#define MTK_MDIO_CFG_MDC_CLK_DIV_1	(0 << 6)
+#define MTK_MDIO_CFG_MDC_CLK_DIV_2	(1 << 6)
+#define MTK_MDIO_CFG_MDC_CLK_DIV_4	(2 << 6)
+#define MTK_MDIO_CFG_MDC_CLK_DIV_8	(3 << 6)
+#define MTK_MDIO_CFG_TURBO_MII_FREQ	BIT(5)
+#define MTK_MDIO_CFG_TURBO_MII_MODE	BIT(4)
+#define MTK_MDIO_CFG_RX_CLK_SKEW_0	(0 << 2)
+#define MTK_MDIO_CFG_RX_CLK_SKEW_200	(1 << 2)
+#define MTK_MDIO_CFG_RX_CLK_SKEW_400	(2 << 2)
+#define MTK_MDIO_CFG_RX_CLK_SKEW_INV	(3 << 2)
+#define MTK_MDIO_CFG_TX_CLK_SKEW_0	0
+#define MTK_MDIO_CFG_TX_CLK_SKEW_200	1
+#define MTK_MDIO_CFG_TX_CLK_SKEW_400	2
+#define MTK_MDIO_CFG_TX_CLK_SKEW_INV	3
+
+/* uni-cast port */
+#define MTK_GDM1_JMB_LEN_MASK	0xf
+#define MTK_GDM1_JMB_LEN_SHIFT	28
+#define MTK_GDM1_ICS_EN		BIT(22)
+#define MTK_GDM1_TCS_EN		BIT(21)
+#define MTK_GDM1_UCS_EN		BIT(20)
+#define MTK_GDM1_JMB_EN		BIT(19)
+#define MTK_GDM1_STRPCRC	BIT(16)
+#define MTK_GDM1_UFRC_P_CPU	(0 << 12)
+#define MTK_GDM1_UFRC_P_GDMA1	(1 << 12)
+#define MTK_GDM1_UFRC_P_PPE	(6 << 12)
+
+/* checksums */
+#define MTK_ICS_GEN_EN		BIT(2)
+#define MTK_UCS_GEN_EN		BIT(1)
+#define MTK_TCS_GEN_EN		BIT(0)
+
+/* dma mode */
+#define MTK_PDMA		BIT(0)
+#define MTK_QDMA		BIT(1)
+#define MTK_PDMA_RX_QDMA_TX	(MTK_PDMA | MTK_QDMA)
+
+/* dma ring */
+#define MTK_PST_DRX_IDX0	BIT(16)
+#define MTK_PST_DTX_IDX3	BIT(3)
+#define MTK_PST_DTX_IDX2	BIT(2)
+#define MTK_PST_DTX_IDX1	BIT(1)
+#define MTK_PST_DTX_IDX0	BIT(0)
+
+#define MTK_RX_2B_OFFSET	BIT(31)
+#define MTK_TX_WB_DDONE		BIT(6)
+#define MTK_RX_DMA_BUSY		BIT(3)
+#define MTK_TX_DMA_BUSY		BIT(1)
+#define MTK_RX_DMA_EN		BIT(2)
+#define MTK_TX_DMA_EN		BIT(0)
+
+#define MTK_PDMA_SIZE_4DWORDS	(0 << 4)
+#define MTK_PDMA_SIZE_8DWORDS	(1 << 4)
+#define MTK_PDMA_SIZE_16DWORDS	(2 << 4)
+
+#define MTK_US_CYC_CNT_MASK	0xff
+#define MTK_US_CYC_CNT_SHIFT	0x8
+#define MTK_US_CYC_CNT_DIVISOR	1000000
+
+/* PDMA descriptor rxd2 */
+#define RX_DMA_DONE		BIT(31)
+#define RX_DMA_LSO		BIT(30)
+#define RX_DMA_PLEN0(_x)	(((_x) & 0x3fff) << 16)
+#define RX_DMA_GET_PLEN0(_x)	(((_x) >> 16) & 0x3fff)
+#define RX_DMA_TAG		BIT(15)
+
+/* PDMA descriptor rxd3 */
+#define RX_DMA_TPID(_x)		(((_x) >> 16) & 0xffff)
+#define RX_DMA_VID(_x)		((_x) & 0xfff)
+
+/* PDMA descriptor rxd4 */
+#define RX_DMA_L4VALID		BIT(30)
+#define RX_DMA_FPORT_SHIFT	19
+#define RX_DMA_FPORT_MASK	0x7
+
+struct mtk_rx_dma {
+	unsigned int rxd1;
+	unsigned int rxd2;
+	unsigned int rxd3;
+	unsigned int rxd4;
+} __packed __aligned(4);
+
+/* PDMA tx descriptor bits */
+#define TX_DMA_BUF_LEN		0x3fff
+#define TX_DMA_PLEN0_MASK	(TX_DMA_BUF_LEN << 16)
+#define TX_DMA_PLEN0(_x)	(((_x) & TX_DMA_BUF_LEN) << 16)
+#define TX_DMA_PLEN1(_x)	((_x) & TX_DMA_BUF_LEN)
+#define TX_DMA_GET_PLEN0(_x)    (((_x) >> 16) & TX_DMA_BUF_LEN)
+#define TX_DMA_GET_PLEN1(_x)    ((_x) & TX_DMA_BUF_LEN)
+#define TX_DMA_LS1		BIT(14)
+#define TX_DMA_LS0		BIT(30)
+#define TX_DMA_DONE		BIT(31)
+#define TX_DMA_FPORT_SHIFT	25
+#define TX_DMA_FPORT_MASK	0x7
+#define TX_DMA_INS_VLAN_MT7621	BIT(16)
+#define TX_DMA_INS_VLAN		BIT(7)
+#define TX_DMA_INS_PPPOE	BIT(12)
+#define TX_DMA_TAG		BIT(15)
+#define TX_DMA_TAG_MASK		BIT(15)
+#define TX_DMA_QN(_x)		((_x) << 16)
+#define TX_DMA_PN(_x)		((_x) << 24)
+#define TX_DMA_QN_MASK		TX_DMA_QN(0x7)
+#define TX_DMA_PN_MASK		TX_DMA_PN(0x7)
+#define TX_DMA_UDF		BIT(20)
+#define TX_DMA_CHKSUM		(0x7 << 29)
+#define TX_DMA_TSO		BIT(28)
+#define TX_DMA_DESP4_DEF	(TX_DMA_QN(3) | TX_DMA_PN(1))
+
+/* frame engine counters */
+#define MTK_PPE_AC_BCNT0	(MTK_CMTABLE_OFFSET + 0x00)
+#define MTK_GDMA1_TX_GBCNT	(MTK_CMTABLE_OFFSET + 0x300)
+#define MTK_GDMA2_TX_GBCNT	(MTK_GDMA1_TX_GBCNT + 0x40)
+
+/* phy device flags */
+#define MTK_PHY_FLAG_PORT	BIT(0)
+#define MTK_PHY_FLAG_ATTACH	BIT(1)
+
+struct mtk_tx_dma {
+	unsigned int txd1;
+	unsigned int txd2;
+	unsigned int txd3;
+	unsigned int txd4;
+} __packed __aligned(4);
+
+struct mtk_eth;
+struct mtk_mac;
+
+/* manage the attached phys */
+struct mtk_phy {
+	spinlock_t		lock;
+
+	struct phy_device	*phy[8];
+	struct device_node	*phy_node[8];
+	const __be32		*phy_fixed[8];
+	int			duplex[8];
+	int			speed[8];
+	int			tx_fc[8];
+	int			rx_fc[8];
+	int (*connect)(struct mtk_mac *mac);
+	void (*disconnect)(struct mtk_mac *mac);
+	void (*start)(struct mtk_mac *mac);
+	void (*stop)(struct mtk_mac *mac);
+};
+
+/* struct mtk_soc_data - the structure that holds the SoC specific data
+ * @reg_table:		Some of the legacy registers changed their location
+ *			over time. Their offsets are stored in this table
+ *
+ * @init_data:		Some features depend on the silicon revision. This
+ *			callback allows runtime modification of the content of
+ *			this struct
+ * @reset_fe:		This callback is used to trigger the reset of the frame
+ *			engine
+ * @set_mac:		This callback is used to set the unicast mac address
+ *			filter
+ * @fwd_config:		This callback is used to setup the forward config
+ *			register of the MAC
+ * @switch_init:	This callback is used to bring up the switch core
+ * @port_init:		Some SoCs have ports that can be router to a switch port
+ *			or an external PHY. This callback is used to setup these
+ *			ports.
+ * @has_carrier:	This callback allows driver to check if there is a cable
+ *			attached.
+ * @mdio_init:		This callbck is used to setup the MDIO bus if one is
+ *			present
+ * @mdio_cleanup:	This callback is used to cleanup the MDIO state.
+ * @mdio_write:		This callback is used to write data to the MDIO bus.
+ * @mdio_read:		This callback is used to write data to the MDIO bus.
+ * @mdio_adjust_link:	This callback is used to apply the PHY settings.
+ * @piac_offset:	the PIAC register has a different different base offset
+ * @hw_features:	feature set depends on the SoC type
+ * @dma_ring_size:	allow GBit SoCs to set bigger rings than FE SoCs
+ * @napi_weight:	allow GBit SoCs to set bigger napi weight than FE SoCs
+ * @dma_type:		SoCs is PDMA, QDMA or a mix of the 2
+ * @pdma_glo_cfg:	the default DMA configuration
+ * @rx_int:		the TX interrupt bits used by the SoC
+ * @tx_int:		the TX interrupt bits used by the SoC
+ * @status_int:		the Status interrupt bits used by the SoC
+ * @checksum_bit:	the bits used to turn on HW checksumming
+ * @txd4:		default value of the TXD4 descriptor
+ * @mac_count:		the number of MACs that the SoC has
+ * @new_stats:		there is a old and new way to read hardware stats
+ *			registers
+ * @jumbo_frame:	does the SoC support jumbo frames ?
+ * @rx_2b_offset:	tell the rx dma to offset the data by 2 bytes
+ * @rx_sg_dma:		scatter gather support
+ * @padding_64b		enable 64 bit padding
+ * @padding_bug:	rt2880 has a padding bug
+ * @has_switch:		does the SoC have a built-in switch
+ *
+ * Although all of the supported SoCs share the same basic functionality, there
+ * are several SoC specific functions and features that we need to support. This
+ * struct holds the SoC specific data so that the common core can figure out
+ * how to setup and use these differences.
+ */
+struct mtk_soc_data {
+	const u16 *reg_table;
+
+	void (*init_data)(struct mtk_soc_data *data, struct net_device *netdev);
+	void (*reset_fe)(struct mtk_eth *eth);
+	void (*set_mac)(struct mtk_mac *mac, unsigned char *macaddr);
+	int (*fwd_config)(struct mtk_eth *eth);
+	int (*switch_init)(struct mtk_eth *eth);
+	void (*port_init)(struct mtk_eth *eth, struct mtk_mac *mac,
+			  struct device_node *port);
+	int (*has_carrier)(struct mtk_eth *eth);
+	int (*mdio_init)(struct mtk_eth *eth);
+	void (*mdio_cleanup)(struct mtk_eth *eth);
+	int (*mdio_write)(struct mii_bus *bus, int phy_addr, int phy_reg,
+			  u16 val);
+	int (*mdio_read)(struct mii_bus *bus, int phy_addr, int phy_reg);
+	void (*mdio_adjust_link)(struct mtk_eth *eth, int port);
+	u32 piac_offset;
+	netdev_features_t hw_features;
+	u32 dma_ring_size;
+	u32 napi_weight;
+	u32 dma_type;
+	u32 pdma_glo_cfg;
+	u32 rx_int;
+	u32 tx_int;
+	u32 status_int;
+	u32 checksum_bit;
+	u32 txd4;
+	u32 mac_count;
+
+	u32 new_stats:1;
+	u32 jumbo_frame:1;
+	u32 rx_2b_offset:1;
+	u32 rx_sg_dma:1;
+	u32 padding_64b:1;
+	u32 padding_bug:1;
+	u32 has_switch:1;
+};
+
+/* ugly macro hack to make sure hw_stats and ethtool strings are consistent */
+#define MTK_STAT_OFFSET			0x40
+#define MTK_STAT_REG_DECLARE		\
+	_FE(tx_bytes)			\
+	_FE(tx_packets)			\
+	_FE(tx_skip)			\
+	_FE(tx_collisions)		\
+	_FE(rx_bytes)			\
+	_FE(rx_packets)			\
+	_FE(rx_overflow)		\
+	_FE(rx_fcs_errors)		\
+	_FE(rx_short_errors)		\
+	_FE(rx_long_errors)		\
+	_FE(rx_checksum_errors)		\
+	_FE(rx_flow_control_packets)
+
+/* struct mtk_hw_stats - the structure that holds the traffic statistics.
+ * @stats_lock:		make sure that stats operations are atomic
+ * @reg_offset:		the status register offset of the SoC
+ * @syncp:		the refcount
+ *
+ * All of the supported SoCs have hardware counters for traffic statstics.
+ * Whenever the status IRQ triggers we can read the latest stats from these
+ * counters and store them in this struct.
+ */
+struct mtk_hw_stats {
+	spinlock_t stats_lock;
+	u32 reg_offset;
+	struct u64_stats_sync syncp;
+
+#define _FE(x) u64 x;
+	MTK_STAT_REG_DECLARE
+#undef _FE
+};
+
+/* PDMA descriptor can point at 1-2 segments. This enum allows us to track how
+ * memory was allocated so that it can be freed properly
+ */
+enum mtk_tx_flags {
+	MTK_TX_FLAGS_SINGLE0	= 0x01,
+	MTK_TX_FLAGS_PAGE0	= 0x02,
+	MTK_TX_FLAGS_PAGE1	= 0x04,
+};
+
+/* struct mtk_tx_buf -	This struct holds the pointers to the memory pointed at
+ *			by the TX descriptor	s
+ * @skb:		The SKB pointer of the packet being sent
+ * @dma_addr0:		The base addr of the first segment
+ * @dma_len0:		The length of the first segment
+ * @dma_addr1:		The base addr of the second segment
+ * @dma_len1:		The length of the second segment
+ */
+struct mtk_tx_buf {
+	struct sk_buff *skb;
+	u32 flags;
+	DEFINE_DMA_UNMAP_ADDR(dma_addr0);
+	DEFINE_DMA_UNMAP_LEN(dma_len0);
+	DEFINE_DMA_UNMAP_ADDR(dma_addr1);
+	DEFINE_DMA_UNMAP_LEN(dma_len1);
+};
+
+/* struct mtk_tx_ring -	This struct holds info describing a TX ring
+ * @tx_dma:		The descriptor ring
+ * @tx_buf:		The memory pointed at by the ring
+ * @tx_phys:		The physical addr of tx_buf
+ * @tx_next_free:	Pointer to the next free descriptor
+ * @tx_last_free:	Pointer to the last free descriptor
+ * @tx_thresh:		The threshold of minimum amount of free descriptors
+ * @tx_map:		Callback to map a new packet into the ring
+ * @tx_poll:		Callback for the housekeeping function
+ * @tx_clean:		Callback for the cleanup function
+ * @tx_ring_size:	How many descriptors are in the ring
+ * @tx_free_idx:	The index of th next free descriptor
+ * @tx_next_idx:	QDMA uses a linked list. This element points to the next
+ *			free descriptor in the list
+ * @tx_free_count:	QDMA uses a linked list. Track how many free descriptors
+ *			are present
+ */
+struct mtk_tx_ring {
+	struct mtk_tx_dma *tx_dma;
+	struct mtk_tx_buf *tx_buf;
+	dma_addr_t tx_phys;
+	struct mtk_tx_dma *tx_next_free;
+	struct mtk_tx_dma *tx_last_free;
+	u16 tx_thresh;
+	int (*tx_map)(struct sk_buff *skb, struct net_device *dev, int tx_num,
+		      struct mtk_tx_ring *ring, bool gso);
+	int (*tx_poll)(struct mtk_eth *eth, int budget, bool *tx_again);
+	void (*tx_clean)(struct mtk_eth *eth);
+
+	/* PDMA only */
+	u16 tx_ring_size;
+	u16 tx_free_idx;
+
+	/* QDMA only */
+	u16 tx_next_idx;
+	atomic_t tx_free_count;
+};
+
+/* struct mtk_rx_ring -	This struct holds info describing a RX ring
+ * @rx_dma:		The descriptor ring
+ * @rx_data:		The memory pointed at by the ring
+ * @trx_phys:		The physical addr of rx_buf
+ * @rx_ring_size:	How many descriptors are in the ring
+ * @rx_buf_size:	The size of each packet buffer
+ * @rx_calc_idx:	The current head of ring
+ */
+struct mtk_rx_ring {
+	struct mtk_rx_dma *rx_dma;
+	u8 **rx_data;
+	dma_addr_t rx_phys;
+	u16 rx_ring_size;
+	u16 frag_size;
+	u16 rx_buf_size;
+	u16 rx_calc_idx;
+};
+
+/* currently no SoC has more than 2 macs */
+#define MTK_MAX_DEVS			2
+
+/* struct mtk_eth -	This is the main datasructure for holding the state
+ *			of the driver
+ * @dev:		The device pointer
+ * @base:		The mapped register i/o base
+ * @page_lock:		Make sure that register operations are atomic
+ * @soc:		pointer to our SoC specific data
+ * @dummy_dev:		we run 2 netdevs on 1 physical DMA ring and need a
+ *			dummy for NAPI to work
+ * @netdev:		The netdev instances
+ * @mac:		Each netdev is linked to a physical MAC
+ * @switch_np:		The phandle for the switch
+ * @irq:		The IRQ that we are using
+ * @msg_enable:		Ethtool msg level
+ * @ysclk:		The sysclk rate - neeed for calibration
+ * @ethsys:		The register map pointing at the range used to setup
+ *			MII modes
+ * @dma_refcnt:		track how many netdevs are using the DMA engine
+ * @tx_ring:		Pointer to the memore holding info about the TX ring
+ * @rx_ring:		Pointer to the memore holding info about the RX ring
+ * @rx_napi:		The NAPI struct
+ * @scratch_ring:	Newer SoCs need memory for a second HW managed TX ring
+ * @scratch_head:	The scratch memory that scratch_ring points to.
+ * @phy:		Info about the attached PHYs
+ * @mii_bus:		If there is a bus we need to create an instance for it
+ * @link:		Track if the ports have a physical link
+ * @sw_priv:		Pointer to the switches private data
+ * @vlan_map:		RX VID tracking
+ */
+
+struct mtk_eth {
+	struct device			*dev;
+	void __iomem			*base;
+	spinlock_t			page_lock;
+	struct mtk_soc_data		*soc;
+	struct net_device		dummy_dev;
+	struct net_device		*netdev[MTK_MAX_DEVS];
+	struct mtk_mac			*mac[MTK_MAX_DEVS];
+	struct device_node		*switch_np;
+	int				irq;
+	u32				msg_enable;
+	unsigned long			sysclk;
+	struct regmap			*ethsys;
+	atomic_t			dma_refcnt;
+	struct mtk_tx_ring		tx_ring;
+	struct mtk_rx_ring		rx_ring[2];
+	struct napi_struct		rx_napi;
+	struct mtk_tx_dma		*scratch_ring;
+	void				*scratch_head;
+	struct mtk_phy			*phy;
+	struct mii_bus			*mii_bus;
+	int				link[8];
+	void				*sw_priv;
+	unsigned long			vlan_map;
+};
+
+/* struct mtk_mac -	the structure that holds the info about the MACs of the
+ *			SoC
+ * @id:			The number of the MAC
+ * @of_node:		Our devicetree node
+ * @hw:			Backpointer to our main datastruture
+ * @hw_stats:		Packet statistics counter
+ * @phy_dev:		The attached PHY if available
+ * @phy_flags:		The PHYs flags
+ * @pending_work:	The workqueue used to reset the dma ring
+ */
+struct mtk_mac {
+	int				id;
+	struct device_node		*of_node;
+	struct mtk_eth			*hw;
+	struct mtk_hw_stats		*hw_stats;
+	struct phy_device		*phy_dev;
+	u32				phy_flags;
+	struct work_struct		pending_work;
+};
+
+/* the struct describing the SoC. these are declared in the soc_xyz.c files */
+extern const struct of_device_id of_mtk_match[];
+
+/* read the hardware status register */
+void mtk_stats_update_mac(struct mtk_mac *mac);
+
+/* default checksum setup handler */
+void mtk_reset(struct mtk_eth *eth, u32 reset_bits);
+
+/* register i/o wrappers */
+void mtk_w32(struct mtk_eth *eth, u32 val, unsigned reg);
+u32 mtk_r32(struct mtk_eth *eth, unsigned reg);
+
+/* default clock calibration handler */
+int mtk_set_clock_cycle(struct mtk_eth *eth);
+
+/* default checksum setup handler */
+void mtk_csum_config(struct mtk_eth *eth);
+
+/* default forward config handler */
+void mtk_fwd_config(struct mtk_eth *eth);
+
+#endif /* MTK_ETH_H */
-- 
1.7.10.4
