From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 2/4] net: ethernet: ti: cpsw: fix device and of_node leaks
Date: Tue,  1 Nov 2016 12:03:35 +0100
Message-ID: <1477998217-30143-3-git-send-email-johan@kernel.org>
References: <1477998217-30143-1-git-send-email-johan@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34531 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168811AbcKALEC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 07:04:02 -0400
In-Reply-To: <1477998217-30143-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure to drop the references taken by of_get_child_by_name() and
bus_find_device() before returning from cpsw_phy_sel().

Note that there is no guarantee that the devres-managed struct
cpsw_phy_sel_priv will continue to be valid until this function returns
regardless of this change.

Fixes: 5892cd135e16 ("drivers: net: cpsw-phy-sel: Add new driver...")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw-phy-sel.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index 054a8dd23dae..589beb843f56 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -176,8 +176,11 @@ void cpsw_phy_sel(struct device *dev, phy_interface_t phy_mode, int slave)
 	}
 
 	dev = bus_find_device(&platform_bus_type, NULL, node, match);
+	of_node_put(node);
 	priv = dev_get_drvdata(dev);
 
+	put_device(dev);
+
 	priv->cpsw_phy_sel(priv, phy_mode, slave);
 }
 EXPORT_SYMBOL_GPL(cpsw_phy_sel);
-- 
2.7.3
