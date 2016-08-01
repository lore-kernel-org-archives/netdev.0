From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 03/15] ethernet: arc: emac_main: add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:31 +0800
Message-ID: <1470034963-30506-4-git-send-email-peter.chen@nxp.com>
References: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <vbridger@opensource.altera.com>,
	<isubramanian@apm.com>, <kchudgar@apm.com>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<thomas.petazzoni@free-electrons.com>,
	<sergei.shtylyov@cogentembedded.com>, <peppe.cavallaro@st.com>,
	<alexandre.torgue@st.com>, <mugunthanvnm@ti.com>,
	<tremyfr@gmail.com>, <wxt@rock-chips.com>, <arnd@arndb.de>,
	<david.daney@cavium.com>, <huangdaode@hisilicon.com>,
	<jszhang@marvell.com>, Peter Chen <peter.chen@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0059.outbound.protection.outlook.com ([104.47.38.59]:9213
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750707AbcHAH2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:28:08 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/arc/emac_main.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 586beda..4bff0f3 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -749,14 +749,16 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 	err = of_address_to_resource(dev->of_node, 0, &res_regs);
 	if (err) {
 		dev_err(dev, "failed to retrieve registers base from device tree\n");
-		return -ENODEV;
+		err = -ENODEV;
+		goto out_put_node;
 	}
 
 	/* Get IRQ from device tree */
 	irq = irq_of_parse_and_map(dev->of_node, 0);
 	if (!irq) {
 		dev_err(dev, "failed to retrieve <irq> value from device tree\n");
-		return -ENODEV;
+		err = -ENODEV;
+		goto out_put_node;
 	}
 
 	ndev->netdev_ops = &arc_emac_netdev_ops;
@@ -778,7 +780,7 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 		err = clk_prepare_enable(priv->clk);
 		if (err) {
 			dev_err(dev, "failed to enable clock\n");
-			return err;
+			goto out_put_node;
 		}
 
 		clock_frequency = clk_get_rate(priv->clk);
@@ -787,7 +789,8 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 		if (of_property_read_u32(dev->of_node, "clock-frequency",
 					 &clock_frequency)) {
 			dev_err(dev, "failed to retrieve <clock-frequency> from device tree\n");
-			return -EINVAL;
+			err = -EINVAL;
+			goto out_put_node;
 		}
 	}
 
@@ -867,6 +870,7 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 		goto out_netif_api;
 	}
 
+	of_node_put(phy_node);
 	return 0;
 
 out_netif_api:
@@ -877,6 +881,9 @@ out_mdio:
 out_clken:
 	if (priv->clk)
 		clk_disable_unprepare(priv->clk);
+out_put_node:
+	of_node_put(phy_node);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(arc_emac_probe);
-- 
1.9.1
