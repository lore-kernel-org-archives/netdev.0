From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/10] bnxt_en: Add bnxt_get_num_stats() to centrally get the number of ethtool stats.
Date: Mon, 24 Jul 2017 12:34:23 -0400
Message-ID: <1500914069-15724-5-git-send-email-michael.chan@broadcom.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33353 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753820AbdGXQet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:34:49 -0400
Received: by mail-qk0-f182.google.com with SMTP id k2so16221047qkf.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:34:49 -0700 (PDT)
In-Reply-To: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of duplicating the logic multiple times.  Also, it is unnecessary
to zero the buffer in .get_ethtool_stats() because it is already zeroed
by the caller.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 25 ++++++++++++-----------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index be6acad..4661b11 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -198,19 +198,23 @@ static int bnxt_set_coalesce(struct net_device *dev,
 
 #define BNXT_NUM_PORT_STATS ARRAY_SIZE(bnxt_port_stats_arr)
 
+static int bnxt_get_num_stats(struct bnxt *bp)
+{
+	int num_stats = BNXT_NUM_STATS * bp->cp_nr_rings;
+
+	if (bp->flags & BNXT_FLAG_PORT_STATS)
+		num_stats += BNXT_NUM_PORT_STATS;
+
+	return num_stats;
+}
+
 static int bnxt_get_sset_count(struct net_device *dev, int sset)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
 	switch (sset) {
-	case ETH_SS_STATS: {
-		int num_stats = BNXT_NUM_STATS * bp->cp_nr_rings;
-
-		if (bp->flags & BNXT_FLAG_PORT_STATS)
-			num_stats += BNXT_NUM_PORT_STATS;
-
-		return num_stats;
-	}
+	case ETH_SS_STATS:
+		return bnxt_get_num_stats(bp);
 	case ETH_SS_TEST:
 		if (!bp->num_tests)
 			return -EOPNOTSUPP;
@@ -225,11 +229,8 @@ static void bnxt_get_ethtool_stats(struct net_device *dev,
 {
 	u32 i, j = 0;
 	struct bnxt *bp = netdev_priv(dev);
-	u32 buf_size = sizeof(struct ctx_hw_stats) * bp->cp_nr_rings;
 	u32 stat_fields = sizeof(struct ctx_hw_stats) / 8;
 
-	memset(buf, 0, buf_size);
-
 	if (!bp->bnapi)
 		return;
 
@@ -835,7 +836,7 @@ static void bnxt_get_drvinfo(struct net_device *dev,
 		strlcpy(info->fw_version, bp->fw_ver_str,
 			sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(bp->pdev), sizeof(info->bus_info));
-	info->n_stats = BNXT_NUM_STATS * bp->cp_nr_rings;
+	info->n_stats = bnxt_get_num_stats(bp);
 	info->testinfo_len = bp->num_tests;
 	/* TODO CHIMP_FW: eeprom dump details */
 	info->eedump_len = 0;
-- 
1.8.3.1
