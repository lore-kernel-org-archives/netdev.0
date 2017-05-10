From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 09/12] drivers: net: xgene: Workaround for HW errata 10GE_4
Date: Wed, 10 May 2017 13:45:07 -0700
Message-ID: <1494449110-23785-10-git-send-email-isubramanian@apm.com>
References: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34359 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753875AbdEJUmc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:42:32 -0400
Received: by mail-io0-f178.google.com with SMTP id k91so9467873ioi.1
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:42:31 -0700 (PDT)
In-Reply-To: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch adds workaround for HW errata 10GE_4:
"XGENET_ICM_ECM_DROP_COUNT_REG_0 reg not clear on read".

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 5 +++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 2 ++
 3 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 5278d62..3235d0c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -626,6 +626,8 @@ static void xgene_gmac_get_drop_cnt(struct xgene_enet_pdata *pdata,
 	xgene_enet_rd_mcx_csr(pdata, ICM_ECM_DROP_COUNT_REG0_ADDR, &count);
 	*rx = ICM_DROP_COUNT(count);
 	*tx = ECM_DROP_COUNT(count);
+	/* Errata: 10GE_4 - Fix ICM_ECM_DROP_COUNT not clear-on-read */
+	xgene_enet_rd_mcx_csr(pdata, ECM_CONFIG0_REG_0_ADDR, &count);
 }
 
 static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index 2919d3e..31df8f3 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -106,6 +106,11 @@ static void xgene_sgmac_get_drop_cnt(struct xgene_enet_pdata *pdata,
 	count = xgene_enet_rd_mcx_csr(pdata, addr);
 	*rx = ICM_DROP_COUNT(count);
 	*tx = ECM_DROP_COUNT(count);
+	/* Errata: 10GE_4 - ICM_ECM_DROP_COUNT not clear-on-read */
+	addr = (pdata->enet_id != XGENE_ENET1) ?
+		XG_MCX_ECM_CONFIG0_REG_0_ADDR :
+		ECM_CONFIG0_REG_0_ADDR + pdata->port_id * OFFSET_4;
+	xgene_enet_rd_mcx_csr(pdata, addr);
 }
 
 static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *p)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 56dff38..eab6f1c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -188,6 +188,8 @@ static void xgene_xgmac_get_drop_cnt(struct xgene_enet_pdata *pdata,
 	xgene_enet_rd_axg_csr(pdata, XGENET_ICM_ECM_DROP_COUNT_REG0, &count);
 	*rx = ICM_DROP_COUNT(count);
 	*tx = ECM_DROP_COUNT(count);
+	/* Errata: 10GE_4 - ICM_ECM_DROP_COUNT not clear-on-read */
+	xgene_enet_rd_axg_csr(pdata, XGENET_ECM_CONFIG0_REG_0, &count);
 }
 
 static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata)
-- 
1.9.1
