From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/4] drivers: net: xgene-v2: Add MDIO support
Date: Tue, 21 Mar 2017 12:24:40 -0700
Message-ID: <1490124283-10371-2-git-send-email-isubramanian@apm.com>
References: <1490124283-10371-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
        f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33581 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933290AbdCUTZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 15:25:22 -0400
Received: by mail-pg0-f53.google.com with SMTP id n190so98053910pga.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 12:23:41 -0700 (PDT)
In-Reply-To: <1490124283-10371-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added phy management support by using phy abstraction layer APIs.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene-v2/Makefile |   2 +-
 drivers/net/ethernet/apm/xgene-v2/mac.c    |   2 +-
 drivers/net/ethernet/apm/xgene-v2/mac.h    |   1 +
 drivers/net/ethernet/apm/xgene-v2/main.c   |  13 ++-
 drivers/net/ethernet/apm/xgene-v2/main.h   |   5 +
 drivers/net/ethernet/apm/xgene-v2/mdio.c   | 178 +++++++++++++++++++++++++++++
 6 files changed, 196 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mdio.c

diff --git a/drivers/net/ethernet/apm/xgene-v2/Makefile b/drivers/net/ethernet/apm/xgene-v2/Makefile
index 735309c..0fa5975 100644
--- a/drivers/net/ethernet/apm/xgene-v2/Makefile
+++ b/drivers/net/ethernet/apm/xgene-v2/Makefile
@@ -2,5 +2,5 @@
 # Makefile for APM X-Gene Ethernet v2 driver
 #
 
-xgene-enet-v2-objs := main.o mac.o enet.o ring.o
+xgene-enet-v2-objs := main.o mac.o enet.o ring.o mdio.o
 obj-$(CONFIG_NET_XGENE_V2) += xgene-enet-v2.o
diff --git a/drivers/net/ethernet/apm/xgene-v2/mac.c b/drivers/net/ethernet/apm/xgene-v2/mac.c
index c3189de..ee431e3 100644
--- a/drivers/net/ethernet/apm/xgene-v2/mac.c
+++ b/drivers/net/ethernet/apm/xgene-v2/mac.c
@@ -27,7 +27,7 @@ void xge_mac_reset(struct xge_pdata *pdata)
 	xge_wr_csr(pdata, MAC_CONFIG_1, 0);
 }
 
-static void xge_mac_set_speed(struct xge_pdata *pdata)
+void xge_mac_set_speed(struct xge_pdata *pdata)
 {
 	u32 icm0, icm2, ecm0, mc2;
 	u32 intf_ctrl, rgmii;
diff --git a/drivers/net/ethernet/apm/xgene-v2/mac.h b/drivers/net/ethernet/apm/xgene-v2/mac.h
index 0fce6ae..74397c9 100644
--- a/drivers/net/ethernet/apm/xgene-v2/mac.h
+++ b/drivers/net/ethernet/apm/xgene-v2/mac.h
@@ -101,6 +101,7 @@ static inline u32 xgene_get_reg_bits(u32 var, int pos, int len)
 struct xge_pdata;
 
 void xge_mac_reset(struct xge_pdata *pdata);
+void xge_mac_set_speed(struct xge_pdata *pdata);
 void xge_mac_enable(struct xge_pdata *pdata);
 void xge_mac_disable(struct xge_pdata *pdata);
 void xge_mac_init(struct xge_pdata *pdata);
diff --git a/drivers/net/ethernet/apm/xgene-v2/main.c b/drivers/net/ethernet/apm/xgene-v2/main.c
index ae76977..10d4aff 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.c
+++ b/drivers/net/ethernet/apm/xgene-v2/main.c
@@ -500,9 +500,10 @@ static int xge_open(struct net_device *ndev)
 
 	xge_intr_enable(pdata);
 	xge_wr_csr(pdata, DMARXCTRL, 1);
+
+	phy_start(ndev->phydev);
 	xge_mac_enable(pdata);
 	netif_start_queue(ndev);
-	netif_carrier_on(ndev);
 
 	return 0;
 }
@@ -511,9 +512,9 @@ static int xge_close(struct net_device *ndev)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
 
-	netif_carrier_off(ndev);
 	netif_stop_queue(ndev);
 	xge_mac_disable(pdata);
+	phy_stop(ndev->phydev);
 
 	xge_intr_disable(pdata);
 	xge_free_irq(ndev);
@@ -683,9 +684,14 @@ static int xge_probe(struct platform_device *pdev)
 	if (ret)
 		goto err;
 
+	spin_lock_init(&pdata->mdio_lock);
+
+	ret = xge_mdio_config(ndev);
+	if (ret)
+		goto err;
+
 	netif_napi_add(ndev, &pdata->napi, xge_napi, NAPI_POLL_WEIGHT);
 
-	netif_carrier_off(ndev);
 	ret = register_netdev(ndev);
 	if (ret) {
 		netdev_err(ndev, "Failed to register netdev\n");
@@ -713,6 +719,7 @@ static int xge_remove(struct platform_device *pdev)
 		dev_close(ndev);
 	rtnl_unlock();
 
+	xge_mdio_remove(ndev);
 	unregister_netdev(ndev);
 	free_netdev(ndev);
 
diff --git a/drivers/net/ethernet/apm/xgene-v2/main.h b/drivers/net/ethernet/apm/xgene-v2/main.h
index ada7b0e..3e98bb4 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.h
+++ b/drivers/net/ethernet/apm/xgene-v2/main.h
@@ -65,11 +65,16 @@ struct xge_pdata {
 	struct xge_desc_ring *rx_ring;
 	struct platform_device *pdev;
 	char irq_name[IRQ_ID_SIZE];
+	struct mii_bus *mdio_bus;
 	struct net_device *ndev;
 	struct napi_struct napi;
 	struct xge_stats stats;
+	spinlock_t mdio_lock; /* mdio lock */
 	int phy_speed;
 	u8 nbufs;
 };
 
+int xge_mdio_config(struct net_device *ndev);
+void xge_mdio_remove(struct net_device *ndev);
+
 #endif /* __XGENE_ENET_V2_MAIN_H__ */
diff --git a/drivers/net/ethernet/apm/xgene-v2/mdio.c b/drivers/net/ethernet/apm/xgene-v2/mdio.c
new file mode 100644
index 0000000..43f454d
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/mdio.c
@@ -0,0 +1,178 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *	      Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "main.h"
+
+static int xge_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 data)
+{
+	struct xge_pdata *pdata = bus->priv;
+	u32 done, val = 0;
+	u8 wait = 10;
+	int ret = 0;
+
+	spin_lock(&pdata->mdio_lock);
+
+	SET_REG_BITS(&val, PHY_ADDR, phy_id);
+	SET_REG_BITS(&val, REG_ADDR, reg);
+	xge_wr_csr(pdata, MII_MGMT_ADDRESS, val);
+
+	xge_wr_csr(pdata, MII_MGMT_CONTROL, data);
+	do {
+		usleep_range(5, 10);
+		done = xge_rd_csr(pdata, MII_MGMT_INDICATORS);
+	} while ((done & MII_MGMT_BUSY) && wait--);
+
+	if (done & MII_MGMT_BUSY) {
+		dev_err(&bus->dev, "MII_MGMT write failed\n");
+		ret = -ETIMEDOUT;
+	}
+
+	spin_unlock(&pdata->mdio_lock);
+
+	return ret;
+}
+
+static int xge_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	struct xge_pdata *pdata = bus->priv;
+	u32 data, done, val = 0;
+	u8 wait = 10;
+
+	spin_lock(&pdata->mdio_lock);
+
+	SET_REG_BITS(&val, PHY_ADDR, phy_id);
+	SET_REG_BITS(&val, REG_ADDR, reg);
+	xge_wr_csr(pdata, MII_MGMT_ADDRESS, val);
+
+	xge_wr_csr(pdata, MII_MGMT_COMMAND, MII_READ_CYCLE);
+	do {
+		usleep_range(5, 10);
+		done = xge_rd_csr(pdata, MII_MGMT_INDICATORS);
+	} while ((done & MII_MGMT_BUSY) && wait--);
+
+	if (done & MII_MGMT_BUSY) {
+		dev_err(&bus->dev, "MII_MGMT read failed\n");
+		data = -ETIMEDOUT;
+		goto out;
+	}
+
+	data = xge_rd_csr(pdata, MII_MGMT_STATUS);
+	xge_wr_csr(pdata, MII_MGMT_COMMAND, 0);
+
+out:
+	spin_unlock(&pdata->mdio_lock);
+
+	return data;
+}
+
+static void xge_adjust_link(struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct phy_device *phydev = ndev->phydev;
+
+	if (phydev->link) {
+		if (pdata->phy_speed != phydev->speed) {
+			pdata->phy_speed = phydev->speed;
+			xge_mac_set_speed(pdata);
+			xge_mac_enable(pdata);
+			phy_print_status(phydev);
+		}
+	} else {
+		if (pdata->phy_speed != SPEED_UNKNOWN) {
+			pdata->phy_speed = SPEED_UNKNOWN;
+			xge_mac_disable(pdata);
+			phy_print_status(phydev);
+		}
+	}
+}
+
+void xge_mdio_remove(struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct mii_bus *mdio_bus = pdata->mdio_bus;
+
+	if (ndev->phydev)
+		phy_disconnect(ndev->phydev);
+
+	if (mdio_bus->state == MDIOBUS_REGISTERED)
+		mdiobus_unregister(mdio_bus);
+
+	mdiobus_free(mdio_bus);
+}
+
+int xge_mdio_config(struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	struct mii_bus *mdio_bus;
+	struct phy_device *phydev;
+	int ret;
+
+	mdio_bus = mdiobus_alloc();
+	if (!mdio_bus)
+		return -ENOMEM;
+
+	mdio_bus->name = "APM X-Gene Ethernet (v2) MDIO Bus";
+	mdio_bus->read = xge_mdio_read;
+	mdio_bus->write = xge_mdio_write;
+	mdio_bus->priv = pdata;
+	mdio_bus->parent = dev;
+	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(dev));
+	pdata->mdio_bus = mdio_bus;
+
+	mdio_bus->phy_mask = 0x1;
+	ret = mdiobus_register(mdio_bus);
+	if (ret)
+		goto err;
+
+	phydev = phy_find_first(mdio_bus);
+	if (!phydev) {
+		dev_err(dev, "no PHY found\n");
+		goto err;
+	}
+	phydev = phy_connect(ndev, phydev_name(phydev),
+			     &xge_adjust_link,
+			     pdata->resources.phy_mode);
+
+	if (IS_ERR(phydev)) {
+		netdev_err(ndev, "Could not attach to PHY\n");
+		ret = PTR_ERR(phydev);
+		goto err;
+	}
+
+	phydev->supported &= ~(SUPPORTED_10baseT_Half |
+			       SUPPORTED_10baseT_Full |
+			       SUPPORTED_100baseT_Half |
+			       SUPPORTED_100baseT_Full |
+			       SUPPORTED_1000baseT_Half |
+			       SUPPORTED_AUI |
+			       SUPPORTED_MII |
+			       SUPPORTED_FIBRE |
+			       SUPPORTED_BNC);
+	phydev->advertising = phydev->supported;
+	pdata->phy_speed = SPEED_UNKNOWN;
+
+	return 0;
+err:
+	xge_mdio_remove(ndev);
+
+	return ret;
+}
-- 
1.9.1
