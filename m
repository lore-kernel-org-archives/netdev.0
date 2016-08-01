From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 14/15] ethernet: stmicro: stmmac: add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:42 +0800
Message-ID: <1470034963-30506-15-git-send-email-peter.chen@nxp.com>
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
Received: from mail-co1nam03on0059.outbound.protection.outlook.com ([104.47.40.59]:30880
	"EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752025AbcHAHMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:12:45 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

This commit fixes both local (in stmmac_axi_setup) and global
(plat->phy_node) device_node for this issue, and using the
correct device node when tries to put node at stmmac_probe_config_dt
for error path.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 7 +++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c23ccab..4c8c60a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3397,6 +3397,7 @@ int stmmac_dvr_remove(struct device *dev)
 	stmmac_set_mac(priv->ioaddr, false);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
+	of_node_put(priv->plat->phy_node);
 	if (priv->stmmac_rst)
 		reset_control_assert(priv->stmmac_rst);
 	clk_disable_unprepare(priv->pclk);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index f7dfc0a..756bb54 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -113,8 +113,10 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
 		return NULL;
 
 	axi = kzalloc(sizeof(*axi), GFP_KERNEL);
-	if (!axi)
+	if (!axi) {
+		of_node_put(np);
 		return ERR_PTR(-ENOMEM);
+	}
 
 	axi->axi_lpi_en = of_property_read_bool(np, "snps,lpi_en");
 	axi->axi_xit_frm = of_property_read_bool(np, "snps,xit_frm");
@@ -127,6 +129,7 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
 	of_property_read_u32(np, "snps,wr_osr_lmt", &axi->axi_wr_osr_lmt);
 	of_property_read_u32(np, "snps,rd_osr_lmt", &axi->axi_rd_osr_lmt);
 	of_property_read_u32_array(np, "snps,blen", axi->axi_blen, AXI_BLEN);
+	of_node_put(np);
 
 	return axi;
 }
@@ -302,7 +305,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg),
 				       GFP_KERNEL);
 		if (!dma_cfg) {
-			of_node_put(np);
+			of_node_put(plat->phy_node);
 			return ERR_PTR(-ENOMEM);
 		}
 		plat->dma_cfg = dma_cfg;
-- 
1.9.1
