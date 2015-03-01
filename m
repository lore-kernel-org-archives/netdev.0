From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: systemport: fix software maintained statistics
Date: Sat, 28 Feb 2015 18:09:17 -0800
Message-ID: <1425175757-13378-3-git-send-email-f.fainelli@gmail.com>
References: <1425175757-13378-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34005 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbbCACJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 21:09:35 -0500
Received: by pdjg10 with SMTP id g10so30447668pdj.1
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 18:09:35 -0800 (PST)
In-Reply-To: <1425175757-13378-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 60b4ea1781fd ("net: systemport: log RX buffer allocation and RX/TX DMA
failures") added a few software maintained statistics using
BCM_SYSPORT_STAT_MIB_RX and BCM_SYSPORT_STAT_MIB_TX. These statistics are read
from the hardware MIB counters, such that bcm_sysport_update_mib_counters() was
trying to read from a non-existing MIB offset for these counters.

Fix this by introducing a special type: BCM_SYSPORT_STAT_SOFT, similar to
BCM_SYSPORT_STAT_NETDEV, such that bcm_sysport_get_ethtool_stats will read from
the software mib.

Fixes: 60b4ea1781fd ("net: systemport: log RX buffer allocation and RX/TX DMA failures")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c |    7 ++++---
 drivers/net/ethernet/broadcom/bcmsysport.h |    2 ++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 5b308a4..783543a 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -274,9 +274,9 @@ static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
 	/* RBUF misc statistics */
 	STAT_RBUF("rbuf_ovflow_cnt", mib.rbuf_ovflow_cnt, RBUF_OVFL_DISC_CNTR),
 	STAT_RBUF("rbuf_err_cnt", mib.rbuf_err_cnt, RBUF_ERR_PKT_CNTR),
-	STAT_MIB_RX("alloc_rx_buff_failed", mib.alloc_rx_buff_failed),
-	STAT_MIB_RX("rx_dma_failed", mib.rx_dma_failed),
-	STAT_MIB_TX("tx_dma_failed", mib.tx_dma_failed),
+	STAT_MIB_SOFT("alloc_rx_buff_failed", mib.alloc_rx_buff_failed),
+	STAT_MIB_SOFT("rx_dma_failed", mib.rx_dma_failed),
+	STAT_MIB_SOFT("tx_dma_failed", mib.tx_dma_failed),
 };
 
 #define BCM_SYSPORT_STATS_LEN	ARRAY_SIZE(bcm_sysport_gstrings_stats)
@@ -345,6 +345,7 @@ static void bcm_sysport_update_mib_counters(struct bcm_sysport_priv *priv)
 		s = &bcm_sysport_gstrings_stats[i];
 		switch (s->type) {
 		case BCM_SYSPORT_STAT_NETDEV:
+		case BCM_SYSPORT_STAT_SOFT:
 			continue;
 		case BCM_SYSPORT_STAT_MIB_RX:
 		case BCM_SYSPORT_STAT_MIB_TX:
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index fc19417..7e3d87a 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -570,6 +570,7 @@ enum bcm_sysport_stat_type {
 	BCM_SYSPORT_STAT_RUNT,
 	BCM_SYSPORT_STAT_RXCHK,
 	BCM_SYSPORT_STAT_RBUF,
+	BCM_SYSPORT_STAT_SOFT,
 };
 
 /* Macros to help define ethtool statistics */
@@ -590,6 +591,7 @@ enum bcm_sysport_stat_type {
 #define STAT_MIB_RX(str, m) STAT_MIB(str, m, BCM_SYSPORT_STAT_MIB_RX)
 #define STAT_MIB_TX(str, m) STAT_MIB(str, m, BCM_SYSPORT_STAT_MIB_TX)
 #define STAT_RUNT(str, m) STAT_MIB(str, m, BCM_SYSPORT_STAT_RUNT)
+#define STAT_MIB_SOFT(str, m) STAT_MIB(str, m, BCM_SYSPORT_STAT_SOFT)
 
 #define STAT_RXCHK(str, m, ofs) { \
 	.stat_string = str, \
-- 
1.7.1
