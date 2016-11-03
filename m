From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 2/4] net: ethernet: ti: cpsw: fix device and of_node leaks
Date: Thu,  3 Nov 2016 18:40:20 +0100
Message-ID: <1478194822-29545-3-git-send-email-johan@kernel.org>
References: <1478194822-29545-1-git-send-email-johan@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478194822-29545-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the references taken by of_get_child_by_name() and
bus_find_device() before returning from cpsw_phy_sel().

Note that holding a reference to the cpsw-phy-sel device does not
prevent the devres-managed private data from going away.

Fixes: 5892cd135e16 ("drivers: net: cpsw-phy-sel: Add new driver...")
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: linux-omap@vger.kernel.org
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw-phy-sel.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index 054a8dd23dae..ba1e45ff6aae 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -176,9 +176,12 @@ void cpsw_phy_sel(struct device *dev, phy_interface_t phy_mode, int slave)
 	}
 
 	dev = bus_find_device(&platform_bus_type, NULL, node, match);
+	of_node_put(node);
 	priv = dev_get_drvdata(dev);
 
 	priv->cpsw_phy_sel(priv, phy_mode, slave);
+
+	put_device(dev);
 }
 EXPORT_SYMBOL_GPL(cpsw_phy_sel);
 
-- 
2.7.3
