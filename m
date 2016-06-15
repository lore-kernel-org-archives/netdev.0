From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: ax88796: use phydev from struct net_device
Date: Thu, 16 Jun 2016 00:12:48 +0200
Message-ID: <1466028769-27866-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: andrew@lunn.ch, davem@davemloft.net, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/8390/ax88796.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index c89b9ae..b446977 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -84,7 +84,6 @@ static u32 ax_msg_enable;
 struct ax_device {
 	struct mii_bus *mii_bus;
 	struct mdiobb_ctrl bb_ctrl;
-	struct phy_device *phy_dev;
 	void __iomem *addr_memr;
 	u8 reg_memr;
 	int link;
@@ -320,7 +319,7 @@ static void ax_block_output(struct net_device *dev, int count,
 static void ax_handle_link_change(struct net_device *dev)
 {
 	struct ax_device  *ax = to_ax_dev(dev);
-	struct phy_device *phy_dev = ax->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 	int status_change = 0;
 
 	if (phy_dev->link && ((ax->speed != phy_dev->speed) ||
@@ -369,8 +368,6 @@ static int ax_mii_probe(struct net_device *dev)
 	phy_dev->supported &= PHY_BASIC_FEATURES;
 	phy_dev->advertising = phy_dev->supported;
 
-	ax->phy_dev = phy_dev;
-
 	netdev_info(dev, "PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
 		    phy_dev->drv->name, phydev_name(phy_dev), phy_dev->irq);
 
@@ -410,7 +407,7 @@ static int ax_open(struct net_device *dev)
 	ret = ax_mii_probe(dev);
 	if (ret)
 		goto failed_mii_probe;
-	phy_start(ax->phy_dev);
+	phy_start(dev->phydev);
 
 	ret = ax_ei_open(dev);
 	if (ret)
@@ -421,7 +418,7 @@ static int ax_open(struct net_device *dev)
 	return 0;
 
  failed_ax_ei_open:
-	phy_disconnect(ax->phy_dev);
+	phy_disconnect(dev->phydev);
  failed_mii_probe:
 	ax_phy_switch(dev, 0);
 	free_irq(dev->irq, dev);
@@ -442,7 +439,7 @@ static int ax_close(struct net_device *dev)
 
 	/* turn the phy off */
 	ax_phy_switch(dev, 0);
-	phy_disconnect(ax->phy_dev);
+	phy_disconnect(dev->phydev);
 
 	free_irq(dev->irq, dev);
 	return 0;
@@ -450,8 +447,7 @@ static int ax_close(struct net_device *dev)
 
 static int ax_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	struct ax_device *ax = to_ax_dev(dev);
-	struct phy_device *phy_dev = ax->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -476,8 +472,7 @@ static void ax_get_drvinfo(struct net_device *dev,
 
 static int ax_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct ax_device *ax = to_ax_dev(dev);
-	struct phy_device *phy_dev = ax->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 
 	if (!phy_dev)
 		return -ENODEV;
@@ -487,8 +482,7 @@ static int ax_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int ax_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct ax_device *ax = to_ax_dev(dev);
-	struct phy_device *phy_dev = ax->phy_dev;
+	struct phy_device *phy_dev = dev->phydev;
 
 	if (!phy_dev)
 		return -ENODEV;
-- 
1.7.4.4
