From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 3/4] net: ethernet: ti: davinci_emac: fix device reference leak
Date: Tue,  1 Nov 2016 12:03:36 +0100
Message-ID: <1477998217-30143-4-git-send-email-johan@kernel.org>
References: <1477998217-30143-1-git-send-email-johan@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34532 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168812AbcKALEC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 07:04:02 -0400
In-Reply-To: <1477998217-30143-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure to drop the references taken by bus_find_device() before
returning from emac_dev_open().

Note that phy_connect still takes a reference to the phy device.

Fixes: 5d69e0076a72 ("net: davinci_emac: switch to new mdio")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/davinci_emac.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 2fd94a5bc1f3..84fbe5714f8b 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1410,6 +1410,7 @@ static int emac_dev_open(struct net_device *ndev)
 	int i = 0;
 	struct emac_priv *priv = netdev_priv(ndev);
 	struct phy_device *phydev = NULL;
+	struct device *phy = NULL;
 
 	ret = pm_runtime_get_sync(&priv->pdev->dev);
 	if (ret < 0) {
@@ -1488,19 +1489,20 @@ static int emac_dev_open(struct net_device *ndev)
 
 	/* use the first phy on the bus if pdata did not give us a phy id */
 	if (!phydev && !priv->phy_id) {
-		struct device *phy;
-
 		phy = bus_find_device(&mdio_bus_type, NULL, NULL,
 				      match_first_device);
-		if (phy)
+		if (phy) {
 			priv->phy_id = dev_name(phy);
+			if (!priv->phy_id || !*priv->phy_id)
+				put_device(phy);
+		}
 	}
 
 	if (!phydev && priv->phy_id && *priv->phy_id) {
 		phydev = phy_connect(ndev, priv->phy_id,
 				     &emac_adjust_link,
 				     PHY_INTERFACE_MODE_MII);
-
+		put_device(phy);	/* reference taken by bus_find_device */
 		if (IS_ERR(phydev)) {
 			dev_err(emac_dev, "could not connect to phy %s\n",
 				priv->phy_id);
-- 
2.7.3
