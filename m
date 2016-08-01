From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 13/15] ethernet: stmicro: stmmac: dwmac-socfpga: add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:41 +0800
Message-ID: <1470034963-30506-14-git-send-email-peter.chen@nxp.com>
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
Received: from mail-sn1nam02on0048.outbound.protection.outlook.com ([104.47.36.48]:62144
	"EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752025AbcHAHMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:12:40 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 36 ++++++++++++++++------
 1 file changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index edd20c3..bec6963 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -135,7 +135,9 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 
 	np_splitter = of_parse_phandle(np, "altr,emac-splitter", 0);
 	if (np_splitter) {
-		if (of_address_to_resource(np_splitter, 0, &res_splitter)) {
+		ret = of_address_to_resource(np_splitter, 0, &res_splitter);
+		of_node_put(np_splitter);
+		if (ret) {
 			dev_info(dev, "Missing emac splitter address\n");
 			return -EINVAL;
 		}
@@ -159,14 +161,17 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 				dev_err(dev,
 					"%s: ERROR: missing emac splitter address\n",
 					__func__);
-				return -EINVAL;
+				ret = -EINVAL;
+				goto err_node_put;
 			}
 
 			dwmac->splitter_base =
 			    devm_ioremap_resource(dev, &res_splitter);
 
-			if (IS_ERR(dwmac->splitter_base))
-				return PTR_ERR(dwmac->splitter_base);
+			if (IS_ERR(dwmac->splitter_base)) {
+				ret = PTR_ERR(dwmac->splitter_base);
+				goto err_node_put;
+			}
 		}
 
 		index = of_property_match_string(np_sgmii_adapter, "reg-names",
@@ -178,14 +183,17 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 				dev_err(dev,
 					"%s: ERROR: failed mapping adapter\n",
 					__func__);
-				return -EINVAL;
+				ret = -EINVAL;
+				goto err_node_put;
 			}
 
 			dwmac->pcs.sgmii_adapter_base =
 			    devm_ioremap_resource(dev, &res_sgmii_adapter);
 
-			if (IS_ERR(dwmac->pcs.sgmii_adapter_base))
-				return PTR_ERR(dwmac->pcs.sgmii_adapter_base);
+			if (IS_ERR(dwmac->pcs.sgmii_adapter_base)) {
+				ret = PTR_ERR(dwmac->pcs.sgmii_adapter_base);
+				goto err_node_put;
+			}
 		}
 
 		index = of_property_match_string(np_sgmii_adapter, "reg-names",
@@ -197,22 +205,30 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 				dev_err(dev,
 					"%s: ERROR: failed mapping tse control port\n",
 					__func__);
-				return -EINVAL;
+				ret = -EINVAL;
+				goto err_node_put;
 			}
 
 			dwmac->pcs.tse_pcs_base =
 			    devm_ioremap_resource(dev, &res_tse_pcs);
 
-			if (IS_ERR(dwmac->pcs.tse_pcs_base))
-				return PTR_ERR(dwmac->pcs.tse_pcs_base);
+			if (IS_ERR(dwmac->pcs.tse_pcs_base)) {
+				ret = PTR_ERR(dwmac->pcs.tse_pcs_base);
+				goto err_node_put;
+			}
 		}
 	}
 	dwmac->reg_offset = reg_offset;
 	dwmac->reg_shift = reg_shift;
 	dwmac->sys_mgr_base_addr = sys_mgr_base_addr;
 	dwmac->dev = dev;
+	of_node_put(np_sgmii_adapter);
 
 	return 0;
+
+err_node_put:
+	of_node_put(np_sgmii_adapter);
+	return ret;
 }
 
 static int socfpga_dwmac_set_phy_mode(struct socfpga_dwmac *dwmac)
-- 
1.9.1
