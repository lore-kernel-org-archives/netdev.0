From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/4] bnxt_en: Add PFC statistics.
Date: Sat, 26 Nov 2016 19:38:35 -0500
Message-ID: <1480207115-21294-5-git-send-email-michael.chan@broadcom.com>
References: <1480207115-21294-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33163 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752582AbcK0Aiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 19:38:51 -0500
Received: by mail-pg0-f47.google.com with SMTP id 3so42450187pgd.0
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 16:38:51 -0800 (PST)
In-Reply-To: <1480207115-21294-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report PFC statistics to ethtool -S and DCBNL.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  7 +++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c     | 14 +++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 23 ++++++++++++++++-------
 3 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 275e560..a72adec 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1124,6 +1124,13 @@ struct bnxt {
 	u32			lpi_tmr_hi;
 };
 
+#define BNXT_RX_STATS_OFFSET(counter)			\
+	(offsetof(struct rx_port_stats, counter) / 8)
+
+#define BNXT_TX_STATS_OFFSET(counter)			\
+	((offsetof(struct tx_port_stats, counter) +	\
+	  sizeof(struct rx_port_stats) + 512) / 8)
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 static inline void bnxt_enable_poll(struct bnxt_napi *bnapi)
 {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
index f391b47..fdf2d8c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
@@ -347,8 +347,10 @@ static int bnxt_dcbnl_ieee_setets(struct net_device *dev, struct ieee_ets *ets)
 static int bnxt_dcbnl_ieee_getpfc(struct net_device *dev, struct ieee_pfc *pfc)
 {
 	struct bnxt *bp = netdev_priv(dev);
+	__le64 *stats = (__le64 *)bp->hw_rx_port_stats;
 	struct ieee_pfc *my_pfc = bp->ieee_pfc;
-	int rc;
+	long rx_off, tx_off;
+	int i, rc;
 
 	pfc->pfc_cap = bp->max_lltc;
 
@@ -369,6 +371,16 @@ static int bnxt_dcbnl_ieee_getpfc(struct net_device *dev, struct ieee_pfc *pfc)
 	pfc->mbc = my_pfc->mbc;
 	pfc->delay = my_pfc->delay;
 
+	if (!stats)
+		return 0;
+
+	rx_off = BNXT_RX_STATS_OFFSET(rx_pfc_ena_frames_pri0);
+	tx_off = BNXT_TX_STATS_OFFSET(tx_pfc_ena_frames_pri0);
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++, rx_off++, tx_off++) {
+		pfc->requests[i] = le64_to_cpu(*(stats + tx_off));
+		pfc->indications[i] = le64_to_cpu(*(stats + rx_off));
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index fa6125e..784aa77 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -107,16 +107,9 @@ static int bnxt_set_coalesce(struct net_device *dev,
 
 #define BNXT_NUM_STATS	21
 
-#define BNXT_RX_STATS_OFFSET(counter)	\
-	(offsetof(struct rx_port_stats, counter) / 8)
-
 #define BNXT_RX_STATS_ENTRY(counter)	\
 	{ BNXT_RX_STATS_OFFSET(counter), __stringify(counter) }
 
-#define BNXT_TX_STATS_OFFSET(counter)			\
-	((offsetof(struct tx_port_stats, counter) +	\
-	  sizeof(struct rx_port_stats) + 512) / 8)
-
 #define BNXT_TX_STATS_ENTRY(counter)	\
 	{ BNXT_TX_STATS_OFFSET(counter), __stringify(counter) }
 
@@ -150,6 +143,14 @@ static int bnxt_set_coalesce(struct net_device *dev,
 	BNXT_RX_STATS_ENTRY(rx_tagged_frames),
 	BNXT_RX_STATS_ENTRY(rx_double_tagged_frames),
 	BNXT_RX_STATS_ENTRY(rx_good_frames),
+	BNXT_RX_STATS_ENTRY(rx_pfc_ena_frames_pri0),
+	BNXT_RX_STATS_ENTRY(rx_pfc_ena_frames_pri1),
+	BNXT_RX_STATS_ENTRY(rx_pfc_ena_frames_pri2),
+	BNXT_RX_STATS_ENTRY(rx_pfc_ena_frames_pri3),
+	BNXT_RX_STATS_ENTRY(rx_pfc_ena_frames_pri4),
+	BNXT_RX_STATS_ENTRY(rx_pfc_ena_frames_pri5),
+	BNXT_RX_STATS_ENTRY(rx_pfc_ena_frames_pri6),
+	BNXT_RX_STATS_ENTRY(rx_pfc_ena_frames_pri7),
 	BNXT_RX_STATS_ENTRY(rx_undrsz_frames),
 	BNXT_RX_STATS_ENTRY(rx_eee_lpi_events),
 	BNXT_RX_STATS_ENTRY(rx_eee_lpi_duration),
@@ -179,6 +180,14 @@ static int bnxt_set_coalesce(struct net_device *dev,
 	BNXT_TX_STATS_ENTRY(tx_fcs_err_frames),
 	BNXT_TX_STATS_ENTRY(tx_err),
 	BNXT_TX_STATS_ENTRY(tx_fifo_underruns),
+	BNXT_TX_STATS_ENTRY(tx_pfc_ena_frames_pri0),
+	BNXT_TX_STATS_ENTRY(tx_pfc_ena_frames_pri1),
+	BNXT_TX_STATS_ENTRY(tx_pfc_ena_frames_pri2),
+	BNXT_TX_STATS_ENTRY(tx_pfc_ena_frames_pri3),
+	BNXT_TX_STATS_ENTRY(tx_pfc_ena_frames_pri4),
+	BNXT_TX_STATS_ENTRY(tx_pfc_ena_frames_pri5),
+	BNXT_TX_STATS_ENTRY(tx_pfc_ena_frames_pri6),
+	BNXT_TX_STATS_ENTRY(tx_pfc_ena_frames_pri7),
 	BNXT_TX_STATS_ENTRY(tx_eee_lpi_events),
 	BNXT_TX_STATS_ENTRY(tx_eee_lpi_duration),
 	BNXT_TX_STATS_ENTRY(tx_total_collisions),
-- 
1.8.3.1
