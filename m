From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 5/7] drivers: net: xgene: Add workaround for errata 10GE_1
Date: Wed, 15 Mar 2017 13:27:19 -0700
Message-ID: <1489609641-31557-6-git-send-email-isubramanian@apm.com>
References: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, qnguyen@apm.com, Toan Le <toanle@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33313 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbdCOU0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:26:11 -0400
Received: by mail-pf0-f178.google.com with SMTP id w189so13702105pfb.0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:26:10 -0700 (PDT)
In-Reply-To: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch implements workaround for errata 10GE_1:
10Gb Ethernet port FIFO threshold default values are incorrect.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Toan Le <toanle@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 7 +++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h | 5 +++++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index ece19e6..423240c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -341,8 +341,15 @@ static void xgene_xgmac_init(struct xgene_enet_pdata *pdata)
 
 	xgene_enet_rd_csr(pdata, XG_RSIF_CONFIG_REG_ADDR, &data);
 	data |= CFG_RSIF_FPBUFF_TIMEOUT_EN;
+	/* Errata 10GE_1 - FIFO threshold default value incorrect */
+	RSIF_CLE_BUFF_THRESH_SET(&data, XG_RSIF_CLE_BUFF_THRESH);
 	xgene_enet_wr_csr(pdata, XG_RSIF_CONFIG_REG_ADDR, data);
 
+	/* Errata 10GE_1 - FIFO threshold default value incorrect */
+	xgene_enet_rd_csr(pdata, XG_RSIF_CONFIG1_REG_ADDR, &data);
+	RSIF_PLC_CLE_BUFF_THRESH_SET(&data, XG_RSIF_PLC_CLE_BUFF_THRESH);
+	xgene_enet_wr_csr(pdata, XG_RSIF_CONFIG1_REG_ADDR, data);
+
 	xgene_enet_rd_csr(pdata, XG_ENET_SPARE_CFG_REG_ADDR, &data);
 	data |= BIT(12);
 	xgene_enet_wr_csr(pdata, XG_ENET_SPARE_CFG_REG_ADDR, data);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
index 03b847a..e644a42 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
@@ -65,6 +65,11 @@
 #define XG_DEF_PAUSE_THRES		0x390
 #define XG_DEF_PAUSE_OFF_THRES		0x2c0
 #define XG_RSIF_CONFIG_REG_ADDR		0x00a0
+#define XG_RSIF_CLE_BUFF_THRESH                0x3
+#define RSIF_CLE_BUFF_THRESH_SET(dst, val)     xgene_set_bits(dst, val, 0, 3)
+#define XG_RSIF_CONFIG1_REG_ADDR       0x00b8
+#define XG_RSIF_PLC_CLE_BUFF_THRESH    0x1
+#define RSIF_PLC_CLE_BUFF_THRESH_SET(dst, val) xgene_set_bits(dst, val, 0, 2)
 #define XCLE_BYPASS_REG0_ADDR           0x0160
 #define XCLE_BYPASS_REG1_ADDR           0x0164
 #define XG_CFG_BYPASS_ADDR		0x0204
-- 
1.9.1
