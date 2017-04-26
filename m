From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 9/9] drivers: net: xgene: Workaround for HW errata 10GE_10/ENET_15
Date: Wed, 26 Apr 2017 16:38:55 -0700
Message-ID: <1493249935-30759-10-git-send-email-isubramanian@apm.com>
References: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35149 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032787AbdDZXgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:36:49 -0400
Received: by mail-pf0-f169.google.com with SMTP id v14so8275030pfd.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:36:43 -0700 (PDT)
In-Reply-To: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch adds workaround for HW errata 10GE_10 and ENET_15:
"HW statistic counters value are duplicated".

- RFCS duplicates RALN counter
- RFLR duplicates RUND counter
- TFCS duplicates TFRG counter
- RALN should be intepreted as 0 in 10G mode

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 30 ++++++++++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 20 ++++++++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  2 ++
 3 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 5e8660e..8d9ed2b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -71,6 +71,7 @@ struct xgene_gstrings_stats {
 	XGENE_EXTD_STAT(rx_oversize_pkt_cntr, ROVR, 16),
 	XGENE_EXTD_STAT(rx_fragments_cntr, RFRG, 16),
 	XGENE_EXTD_STAT(rx_jabber_cntr, RJBR, 16),
+	XGENE_EXTD_STAT(rx_jabber_recov_cntr, DUMP, 0),
 	XGENE_EXTD_STAT(rx_dropped_pkt_cntr, RDRP, 16),
 	XGENE_EXTD_STAT(rx_overrun_cntr, DUMP, 0),
 	XGENE_EXTD_STAT(tx_multicast_pkt_cntr, TMCA, 31),
@@ -96,9 +97,16 @@ struct xgene_gstrings_stats {
 
 #define XGENE_STATS_LEN		ARRAY_SIZE(gstrings_stats)
 #define XGENE_EXTD_STATS_LEN	ARRAY_SIZE(gstrings_extd_stats)
+#define RFCS_IDX		7
+#define RALN_IDX		13
+#define RFLR_IDX		14
 #define FALSE_RFLR_IDX		15
-#define RX_OVERRUN_IDX		23
-#define TX_UNDERRUN_IDX		42
+#define RUND_IDX		18
+#define FALSE_RJBR_IDX		22
+#define RX_OVERRUN_IDX		24
+#define TFCS_IDX		38
+#define TFRG_IDX		42
+#define TX_UNDERRUN_IDX		43
 
 static void xgene_get_drvinfo(struct net_device *ndev,
 			      struct ethtool_drvinfo *info)
@@ -217,24 +225,36 @@ static int xgene_get_sset_count(struct net_device *ndev, int sset)
 
 static void xgene_get_extd_stats(struct xgene_enet_pdata *pdata)
 {
+	u32 tmp[XGENE_EXTD_STATS_LEN];
 	u32 rx_drop, tx_drop;
-	u32 tmp;
 	int i;
 
 	for (i = 0; i < XGENE_EXTD_STATS_LEN; i++) {
 		pdata->mac_ops->read_stats(pdata,
-					   gstrings_extd_stats[i].addr, &tmp);
+				gstrings_extd_stats[i].addr, &tmp[i]);
 		if (gstrings_extd_stats[i].mask)
-			pdata->extd_stats[i] += tmp &
+			pdata->extd_stats[i] += tmp[i] &
 				GENMASK(gstrings_extd_stats[i].mask - 1, 0);
 	}
 
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+		/* Errata 10GE_10 - SW should intepret RALN as 0 */
+		pdata->extd_stats[RALN_IDX] = 0;
+	} else {
+		/* Errata ENET_15 - Fixes RFCS, RFLR, TFCS counter */
+		pdata->extd_stats[RFCS_IDX] -= tmp[RALN_IDX];
+		pdata->extd_stats[RFLR_IDX] -= tmp[RUND_IDX];
+		pdata->extd_stats[TFCS_IDX] -= tmp[TFRG_IDX];
+	}
+
 	pdata->mac_ops->get_drop_cnt(pdata, &rx_drop, &tx_drop);
 	pdata->extd_stats[RX_OVERRUN_IDX] += rx_drop;
 	pdata->extd_stats[TX_UNDERRUN_IDX] += tx_drop;
 
 	/* Errata 10GE_8 -  Update Frame recovered from Errata 10GE_8/ENET_11 */
 	pdata->extd_stats[FALSE_RFLR_IDX] = pdata->false_rflr;
+	/* Errata ENET_15 - Jabber Frame recov'ed from Errata 10GE_10/ENET_15 */
+	pdata->extd_stats[FALSE_RJBR_IDX] = pdata->vlan_rjbr;
 }
 
 int xgene_extd_stats_init(struct xgene_enet_pdata *pdata)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index c2d38da..01e389d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -656,6 +656,18 @@ static void xgene_enet_free_pagepool(struct xgene_enet_desc_ring *buf_pool,
 	buf_pool->head = head;
 }
 
+/* Errata 10GE_10 and ENET_15 - Fix duplicated HW statistic counters */
+static bool xgene_enet_errata_10GE_10(struct sk_buff *skb, u32 len, u8 status)
+{
+	if (status == INGRESS_CRC &&
+	    len >= (ETHER_STD_PACKET + 1) &&
+	    len <= (ETHER_STD_PACKET + 4) &&
+	    skb->protocol == htons(ETH_P_8021Q))
+		return true;
+
+	return false;
+}
+
 /* Errata 10GE_8 and ENET_11 - allow packet with length <=64B */
 static bool xgene_enet_errata_10GE_8(struct sk_buff *skb, u32 len, u8 status)
 {
@@ -706,14 +718,16 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 	status = (GET_VAL(ELERR, le64_to_cpu(raw_desc->m0)) << LERR_LEN) |
 		  GET_VAL(LERR, le64_to_cpu(raw_desc->m0));
 	if (unlikely(status)) {
-		if (!xgene_enet_errata_10GE_8(skb, datalen, status)) {
+		if (xgene_enet_errata_10GE_8(skb, datalen, status)) {
+			pdata->false_rflr++;
+		} else if (xgene_enet_errata_10GE_10(skb, datalen, status)) {
+			pdata->vlan_rjbr++;
+		} else {
 			dev_kfree_skb_any(skb);
 			xgene_enet_free_pagepool(page_pool, raw_desc, exp_desc);
 			xgene_enet_parse_error(rx_ring, status);
 			rx_ring->rx_dropped++;
 			goto out;
-		} else {
-			pdata->false_rflr++;
 		}
 	}
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 8afae57..911137f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -42,6 +42,7 @@
 
 #define XGENE_DRV_VERSION	"v1.0"
 #define ETHER_MIN_PACKET	64
+#define ETHER_STD_PACKET	1518
 #define XGENE_ENET_STD_MTU	1536
 #define XGENE_ENET_MAX_MTU	9600
 #define SKB_BUFFER_SIZE		(XGENE_ENET_STD_MTU - NET_IP_ALIGN)
@@ -226,6 +227,7 @@ struct xgene_enet_pdata {
 	struct xgene_enet_cle cle;
 	u64 *extd_stats;
 	u64 false_rflr;
+	u64 vlan_rjbr;
 	spinlock_t stats_lock; /* statistics lock */
 	const struct xgene_mac_ops *mac_ops;
 	spinlock_t mac_lock; /* mac lock */
-- 
1.9.1
