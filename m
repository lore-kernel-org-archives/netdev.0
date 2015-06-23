From: Suman Tripathi <stripathi@apm.com>
Subject: [PATCH net-next v0 2/4] drivers: net: xgene: Implement the backward compatibility with the old and new firmware w.r.t Tx completion IRQ interrupt.
Date: Tue, 23 Jun 2015 14:47:15 +0530
Message-ID: <1435051037-21753-3-git-send-email-stripathi@apm.com>
References: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, isubramanian@apm.com,
	Suman Tripathi <stripathi@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from denmail01-v4020.amcc.com ([192.195.68.30]:45520 "EHLO
	denmail01.amcc.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932139AbbFWJS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 05:18:29 -0400
In-Reply-To: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the backward compatibility with the old firmware where
the Tx completion IRQ interrupt was absent whereas incase of new firmware
the Tx completion IRQ interrupt is present.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Suman Tripathi <stripathi@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index c8f97a7..946ebde 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1024,11 +1024,13 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	if (pdata->phy_mode != PHY_INTERFACE_MODE_RGMII) {
 		ret = platform_get_irq(pdev, 1);
 		if (ret <= 0) {
-			dev_err(dev, "Unable to get ENET Tx completion IRQ\n");
-			ret = ret ? : -ENXIO;
-			return ret;
-		}
-		pdata->txc_irq = ret;
+			pdata->cq_cnt = 0;
+			dev_info(dev, "Unable to get Tx completion IRQ,"
+				 "using Rx IRQ instead\n");
+		} else {
+			pdata->cq_cnt = XGENE_MAX_TXC_RINGS;
+			pdata->txc_irq = ret;
+		}
 	}

 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
@@ -1105,13 +1107,11 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 		pdata->mac_ops = &xgene_sgmac_ops;
 		pdata->port_ops = &xgene_sgport_ops;
 		pdata->rm = RM1;
-		pdata->cq_cnt = XGENE_MAX_TXC_RINGS;
 		break;
 	default:
 		pdata->mac_ops = &xgene_xgmac_ops;
 		pdata->port_ops = &xgene_xgport_ops;
 		pdata->rm = RM0;
-		pdata->cq_cnt = XGENE_MAX_TXC_RINGS;
 		break;
 	}

--
1.8.2.1
