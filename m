From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 3/5] drivers: net: xgene: fix ununiform latency across queues
Date: Fri, 13 May 2016 16:52:59 -0700
Message-ID: <1463183581-30475-4-git-send-email-isubramanian@apm.com>
References: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36230 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbcEMXwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:52:10 -0400
Received: by mail-pf0-f176.google.com with SMTP id c189so48691506pfb.3
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:52:09 -0700 (PDT)
In-Reply-To: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses ununiform latency across queues by adding
more queues to match with, upto number of CPU cores.

Also, number of interrupts are increased and the channel numbers
are reordered.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 30 ++++++++++++++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  8 +++----
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index ed90664..e75d1a9 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1247,6 +1247,13 @@ static int xgene_enet_get_irqs(struct xgene_enet_pdata *pdata)
 	for (i = 0; i < max_irqs; i++) {
 		ret = platform_get_irq(pdev, i);
 		if (ret <= 0) {
+			if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+				max_irqs = i;
+				pdata->rxq_cnt = max_irqs / 2;
+				pdata->txq_cnt = max_irqs / 2;
+				pdata->cq_cnt = max_irqs / 2;
+				break;
+			}
 			dev_err(dev, "Unable to get ENET IRQ\n");
 			ret = ret ? : -ENXIO;
 			return ret;
@@ -1450,19 +1457,28 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 		pdata->port_ops = &xgene_xgport_ops;
 		pdata->cle_ops = &xgene_cle3in_ops;
 		pdata->rm = RM0;
-		pdata->rxq_cnt = XGENE_NUM_RX_RING;
-		pdata->txq_cnt = XGENE_NUM_TX_RING;
-		pdata->cq_cnt = XGENE_NUM_TXC_RING;
+		if (!pdata->rxq_cnt) {
+			pdata->rxq_cnt = XGENE_NUM_RX_RING;
+			pdata->txq_cnt = XGENE_NUM_TX_RING;
+			pdata->cq_cnt = XGENE_NUM_TXC_RING;
+		}
 		break;
 	}
 
 	if (pdata->enet_id == XGENE_ENET1) {
 		switch (pdata->port_id) {
 		case 0:
-			pdata->cpu_bufnum = START_CPU_BUFNUM_0;
-			pdata->eth_bufnum = START_ETH_BUFNUM_0;
-			pdata->bp_bufnum = START_BP_BUFNUM_0;
-			pdata->ring_num = START_RING_NUM_0;
+			if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+				pdata->cpu_bufnum = X2_START_CPU_BUFNUM_0;
+				pdata->eth_bufnum = X2_START_ETH_BUFNUM_0;
+				pdata->bp_bufnum = X2_START_BP_BUFNUM_0;
+				pdata->ring_num = START_RING_NUM_0;
+			} else {
+				pdata->cpu_bufnum = START_CPU_BUFNUM_0;
+				pdata->eth_bufnum = START_ETH_BUFNUM_0;
+				pdata->bp_bufnum = START_BP_BUFNUM_0;
+				pdata->ring_num = START_RING_NUM_0;
+			}
 			break;
 		case 1:
 			if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 0a2887b..cc40c30 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -49,10 +49,10 @@
 #define XGENE_ENET_MSS	1448
 #define XGENE_MIN_ENET_FRAME_SIZE	60
 
-#define XGENE_MAX_ENET_IRQ	8
-#define XGENE_NUM_RX_RING	4
-#define XGENE_NUM_TX_RING	4
-#define XGENE_NUM_TXC_RING	4
+#define XGENE_MAX_ENET_IRQ	16
+#define XGENE_NUM_RX_RING	8
+#define XGENE_NUM_TX_RING	8
+#define XGENE_NUM_TXC_RING	8
 
 #define START_CPU_BUFNUM_0	0
 #define START_ETH_BUFNUM_0	2
-- 
1.9.1
