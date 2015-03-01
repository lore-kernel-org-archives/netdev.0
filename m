From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: bcmgenet: fix software maintained statistics
Date: Sat, 28 Feb 2015 18:09:16 -0800
Message-ID: <1425175757-13378-2-git-send-email-f.fainelli@gmail.com>
References: <1425175757-13378-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:44594 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbbCACJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 21:09:34 -0500
Received: by padbj1 with SMTP id bj1so7539633pad.11
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 18:09:33 -0800 (PST)
In-Reply-To: <1425175757-13378-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 44c8bc3ce39f ("net: bcmgenet: log RX buffer allocation and RX/TX dma
failures") added a few software maintained statistics using
BCMGENET_STAT_MIB_RX and BCMGENET_STAT_MIB_TX. These statistics are read from
the hardware MIB counters, such that bcmgenet_update_mib_counters() was trying
to read from a non-existing MIB offset for these counters.

Fix this by introducing a special type: BCMGENET_STAT_SOFT, similar to
BCMGENET_STAT_NETDEV, such that bcmgenet_get_ethtool_stats will read from the
software mib.

Fixes: 44c8bc3ce39f ("net: bcmgenet: log RX buffer allocation and RX/TX dma failures")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index ff83c46..c4c6d32 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -487,6 +487,7 @@ enum bcmgenet_stat_type {
 	BCMGENET_STAT_MIB_TX,
 	BCMGENET_STAT_RUNT,
 	BCMGENET_STAT_MISC,
+	BCMGENET_STAT_SOFT,
 };
 
 struct bcmgenet_stats {
@@ -515,6 +516,7 @@ struct bcmgenet_stats {
 #define STAT_GENET_MIB_RX(str, m) STAT_GENET_MIB(str, m, BCMGENET_STAT_MIB_RX)
 #define STAT_GENET_MIB_TX(str, m) STAT_GENET_MIB(str, m, BCMGENET_STAT_MIB_TX)
 #define STAT_GENET_RUNT(str, m) STAT_GENET_MIB(str, m, BCMGENET_STAT_RUNT)
+#define STAT_GENET_SOFT_MIB(str, m) STAT_GENET_MIB(str, m, BCMGENET_STAT_SOFT)
 
 #define STAT_GENET_MISC(str, m, offset) { \
 	.stat_string = str, \
@@ -614,9 +616,9 @@ static const struct bcmgenet_stats bcmgenet_gstrings_stats[] = {
 			UMAC_RBUF_OVFL_CNT),
 	STAT_GENET_MISC("rbuf_err_cnt", mib.rbuf_err_cnt, UMAC_RBUF_ERR_CNT),
 	STAT_GENET_MISC("mdf_err_cnt", mib.mdf_err_cnt, UMAC_MDF_ERR_CNT),
-	STAT_GENET_MIB_RX("alloc_rx_buff_failed", mib.alloc_rx_buff_failed),
-	STAT_GENET_MIB_RX("rx_dma_failed", mib.rx_dma_failed),
-	STAT_GENET_MIB_TX("tx_dma_failed", mib.tx_dma_failed),
+	STAT_GENET_SOFT_MIB("alloc_rx_buff_failed", mib.alloc_rx_buff_failed),
+	STAT_GENET_SOFT_MIB("rx_dma_failed", mib.rx_dma_failed),
+	STAT_GENET_SOFT_MIB("tx_dma_failed", mib.tx_dma_failed),
 };
 
 #define BCMGENET_STATS_LEN	ARRAY_SIZE(bcmgenet_gstrings_stats)
@@ -668,6 +670,7 @@ static void bcmgenet_update_mib_counters(struct bcmgenet_priv *priv)
 		s = &bcmgenet_gstrings_stats[i];
 		switch (s->type) {
 		case BCMGENET_STAT_NETDEV:
+		case BCMGENET_STAT_SOFT:
 			continue;
 		case BCMGENET_STAT_MIB_RX:
 		case BCMGENET_STAT_MIB_TX:
-- 
1.7.1
