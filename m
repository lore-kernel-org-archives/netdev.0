From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 10/12] drivers: net: xgene: Add frame recovered statistics counter for errata 10GE_8/ENET_11
Date: Wed, 10 May 2017 13:45:08 -0700
Message-ID: <1494449110-23785-11-git-send-email-isubramanian@apm.com>
References: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36400 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754409AbdEJUmd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:42:33 -0400
Received: by mail-io0-f179.google.com with SMTP id o12so9458837iod.3
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:42:32 -0700 (PDT)
In-Reply-To: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch adds statistic counter for frames recovered from HW errata
10GE_8 and ENET_11:
"HW reports Length error for valid 64 byte frames with len <46 bytes".

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c | 9 +++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c    | 2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h    | 1 +
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 6b2a4b9..5c2c84a 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -64,6 +64,7 @@ struct xgene_gstrings_stats {
 	XGENE_EXTD_STAT(rx_unk_opcode_cntr, RXUO, 16),
 	XGENE_EXTD_STAT(rx_align_err_cntr, RALN, 16),
 	XGENE_EXTD_STAT(rx_frame_len_err_cntr, RFLR, 16),
+	XGENE_EXTD_STAT(rx_frame_len_err_recov_cntr, DUMP, 0),
 	XGENE_EXTD_STAT(rx_code_err_cntr, RCDE, 16),
 	XGENE_EXTD_STAT(rx_carrier_sense_err_cntr, RCSE, 16),
 	XGENE_EXTD_STAT(rx_undersize_pkt_cntr, RUND, 16),
@@ -95,8 +96,9 @@ struct xgene_gstrings_stats {
 
 #define XGENE_STATS_LEN		ARRAY_SIZE(gstrings_stats)
 #define XGENE_EXTD_STATS_LEN	ARRAY_SIZE(gstrings_extd_stats)
-#define RX_OVERRUN_IDX		22
-#define TX_UNDERRUN_IDX		41
+#define FALSE_RFLR_IDX		15
+#define RX_OVERRUN_IDX		23
+#define TX_UNDERRUN_IDX		42
 
 static void xgene_get_drvinfo(struct net_device *ndev,
 			      struct ethtool_drvinfo *info)
@@ -229,6 +231,9 @@ static void xgene_get_extd_stats(struct xgene_enet_pdata *pdata)
 	pdata->mac_ops->get_drop_cnt(pdata, &rx_drop, &tx_drop);
 	pdata->extd_stats[RX_OVERRUN_IDX] += rx_drop;
 	pdata->extd_stats[TX_UNDERRUN_IDX] += tx_drop;
+
+	/* Errata 10GE_8 -  Update Frame recovered from Errata 10GE_8/ENET_11 */
+	pdata->extd_stats[FALSE_RFLR_IDX] = pdata->false_rflr;
 }
 
 int xgene_extd_stats_init(struct xgene_enet_pdata *pdata)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index bd2486e..c2d38da 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -712,6 +712,8 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 			xgene_enet_parse_error(rx_ring, status);
 			rx_ring->rx_dropped++;
 			goto out;
+		} else {
+			pdata->false_rflr++;
 		}
 	}
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index cabe54e..0f5f0b0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -224,6 +224,7 @@ struct xgene_enet_pdata {
 	enum xgene_enet_rm rm;
 	struct xgene_enet_cle cle;
 	u64 *extd_stats;
+	u64 false_rflr;
 	spinlock_t stats_lock; /* statistics lock */
 	const struct xgene_mac_ops *mac_ops;
 	spinlock_t mac_lock; /* mac lock */
-- 
1.9.1
