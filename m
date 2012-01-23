From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 2/6] bnx2x: fixed ethtool statistics for MF modes
Date: Mon, 23 Jan 2012 12:31:52 -0500
Message-ID: <1327339916-19138-3-git-send-email-yuvalmin@broadcom.com>
References: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1724 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753225Ab2AWKhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jan 2012 05:37:48 -0500
In-Reply-To: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previosuly, in MF modes `ethtool -S' lacked some of the statistics
which appeared in non-MF modes. This has been fixed.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  106 ++++++++------------
 1 files changed, 41 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index f99c6e3..7d32e00 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2121,18 +2121,16 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 	case ETH_SS_STATS:
 		if (is_multi(bp)) {
 			num_stats = bnx2x_num_stat_queues(bp) *
-				BNX2X_NUM_Q_STATS;
-			if (!IS_MF_MODE_STAT(bp))
-				num_stats += BNX2X_NUM_STATS;
-		} else {
-			if (IS_MF_MODE_STAT(bp)) {
-				num_stats = 0;
-				for (i = 0; i < BNX2X_NUM_STATS; i++)
-					if (IS_FUNC_STAT(i))
-						num_stats++;
-			} else
-				num_stats = BNX2X_NUM_STATS;
-		}
+						BNX2X_NUM_Q_STATS;
+		} else
+			num_stats = 0;
+		if (IS_MF_MODE_STAT(bp)) {
+			for (i = 0; i < BNX2X_NUM_STATS; i++)
+				if (IS_FUNC_STAT(i))
+					num_stats++;
+		} else
+			num_stats += BNX2X_NUM_STATS;
+
 		return num_stats;
 
 	case ETH_SS_TEST:
@@ -2151,8 +2149,8 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 
 	switch (stringset) {
 	case ETH_SS_STATS:
+		k = 0;
 		if (is_multi(bp)) {
-			k = 0;
 			for_each_eth_queue(bp, i) {
 				memset(queue_name, 0, sizeof(queue_name));
 				sprintf(queue_name, "%d", i);
@@ -2163,20 +2161,17 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 						queue_name);
 				k += BNX2X_NUM_Q_STATS;
 			}
-			if (IS_MF_MODE_STAT(bp))
-				break;
-			for (j = 0; j < BNX2X_NUM_STATS; j++)
-				strcpy(buf + (k + j)*ETH_GSTRING_LEN,
-				       bnx2x_stats_arr[j].string);
-		} else {
-			for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-				if (IS_MF_MODE_STAT(bp) && IS_PORT_STAT(i))
-					continue;
-				strcpy(buf + j*ETH_GSTRING_LEN,
-				       bnx2x_stats_arr[i].string);
-				j++;
-			}
 		}
+
+
+		for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
+			if (IS_MF_MODE_STAT(bp) && IS_PORT_STAT(i))
+				continue;
+			strcpy(buf + (k + j)*ETH_GSTRING_LEN,
+				   bnx2x_stats_arr[i].string);
+			j++;
+		}
+
 		break;
 
 	case ETH_SS_TEST:
@@ -2190,10 +2185,9 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 *hw_stats, *offset;
-	int i, j, k;
+	int i, j, k = 0;
 
 	if (is_multi(bp)) {
-		k = 0;
 		for_each_eth_queue(bp, i) {
 			hw_stats = (u32 *)&bp->fp[i].eth_q_stats;
 			for (j = 0; j < BNX2X_NUM_Q_STATS; j++) {
@@ -2214,46 +2208,28 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 			}
 			k += BNX2X_NUM_Q_STATS;
 		}
-		if (IS_MF_MODE_STAT(bp))
-			return;
-		hw_stats = (u32 *)&bp->eth_stats;
-		for (j = 0; j < BNX2X_NUM_STATS; j++) {
-			if (bnx2x_stats_arr[j].size == 0) {
-				/* skip this counter */
-				buf[k + j] = 0;
-				continue;
-			}
-			offset = (hw_stats + bnx2x_stats_arr[j].offset);
-			if (bnx2x_stats_arr[j].size == 4) {
-				/* 4-byte counter */
-				buf[k + j] = (u64) *offset;
-				continue;
-			}
-			/* 8-byte counter */
-			buf[k + j] = HILO_U64(*offset, *(offset + 1));
+	}
+
+	hw_stats = (u32 *)&bp->eth_stats;
+	for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
+		if (IS_MF_MODE_STAT(bp) && IS_PORT_STAT(i))
+			continue;
+		if (bnx2x_stats_arr[i].size == 0) {
+			/* skip this counter */
+			buf[k + j] = 0;
+			j++;
+			continue;
 		}
-	} else {
-		hw_stats = (u32 *)&bp->eth_stats;
-		for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-			if (IS_MF_MODE_STAT(bp) && IS_PORT_STAT(i))
-				continue;
-			if (bnx2x_stats_arr[i].size == 0) {
-				/* skip this counter */
-				buf[j] = 0;
-				j++;
-				continue;
-			}
-			offset = (hw_stats + bnx2x_stats_arr[i].offset);
-			if (bnx2x_stats_arr[i].size == 4) {
-				/* 4-byte counter */
-				buf[j] = (u64) *offset;
-				j++;
-				continue;
-			}
-			/* 8-byte counter */
-			buf[j] = HILO_U64(*offset, *(offset + 1));
+		offset = (hw_stats + bnx2x_stats_arr[i].offset);
+		if (bnx2x_stats_arr[i].size == 4) {
+			/* 4-byte counter */
+			buf[k + j] = (u64) *offset;
 			j++;
+			continue;
 		}
+		/* 8-byte counter */
+		buf[k + j] = HILO_U64(*offset, *(offset + 1));
+		j++;
 	}
 }
 
-- 
1.7.1
