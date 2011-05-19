From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 08/13] tg3: Fix stats for 5704 and later
 devices
Date: Thu, 19 May 2011 15:12:51 -0700
Message-ID: <1305843176-32358-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1122 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934944Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4d95847381228639844c7197deb8b2211274ef22, entitled
"tg3: Workaround rx_discards stat bug" modified the hardware statistics
data structure.  The modification shifted the statistics so that the
labels no longer corresponded to the counter values.  This patch fixes
the problem by utilizing reserved space for the new counters.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    7 +++++--
 drivers/net/tg3.h |   10 ++++++++--
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d05c6a0..574fe97 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -364,7 +364,6 @@ static const struct {
 	{ "dma_write_prioq_full" },
 	{ "rxbds_empty" },
 	{ "rx_discards" },
-	{ "mbuf_lwm_thresh_hit" },
 	{ "rx_errors" },
 	{ "rx_threshold_hit" },
 
@@ -376,7 +375,9 @@ static const struct {
 	{ "ring_status_update" },
 	{ "nic_irqs" },
 	{ "nic_avoided_irqs" },
-	{ "nic_tx_threshold_hit" }
+	{ "nic_tx_threshold_hit" },
+
+	{ "mbuf_lwm_thresh_hit" },
 };
 
 #define TG3_NUM_STATS	ARRAY_SIZE(ethtool_stats_keys)
@@ -9546,6 +9547,8 @@ static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp)
 	ESTAT_ADD(nic_avoided_irqs);
 	ESTAT_ADD(nic_tx_threshold_hit);
 
+	ESTAT_ADD(mbuf_lwm_thresh_hit);
+
 	return estats;
 }
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 83f45bf..5b3d2f3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2620,7 +2620,6 @@ struct tg3_hw_stats {
 	tg3_stat64_t			dma_write_prioq_full;
 	tg3_stat64_t			rxbds_empty;
 	tg3_stat64_t			rx_discards;
-	tg3_stat64_t			mbuf_lwm_thresh_hit;
 	tg3_stat64_t			rx_errors;
 	tg3_stat64_t			rx_threshold_hit;
 
@@ -2639,7 +2638,12 @@ struct tg3_hw_stats {
 	tg3_stat64_t			nic_avoided_irqs;
 	tg3_stat64_t			nic_tx_threshold_hit;
 
-	u8				__reserved4[0xb00-0x9c0];
+	/* NOT a part of the hardware statistics block format.
+	 * These stats are here as storage for tg3_periodic_fetch_stats().
+	 */
+	tg3_stat64_t			mbuf_lwm_thresh_hit;
+
+	u8				__reserved4[0xb00-0x9c8];
 };
 
 /* 'mapping' is superfluous as the chip does not write into
@@ -2771,6 +2775,8 @@ struct tg3_ethtool_stats {
 	u64		nic_irqs;
 	u64		nic_avoided_irqs;
 	u64		nic_tx_threshold_hit;
+
+	u64		mbuf_lwm_thresh_hit;
 };
 
 struct tg3_rx_prodring_set {
-- 
1.7.3.4


