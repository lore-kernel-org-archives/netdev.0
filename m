From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/3] bnxt_en: Fix race conditions in .ndo_get_stats64().
Date: Tue, 11 Jul 2017 13:05:34 -0400
Message-ID: <1499792736-28697-2-git-send-email-michael.chan@broadcom.com>
References: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:36722 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753848AbdGKRFt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 13:05:49 -0400
Received: by mail-qk0-f170.google.com with SMTP id p21so9182843qke.3
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 10:05:48 -0700 (PDT)
In-Reply-To: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.ndo_get_stats64() may not be protected by RTNL and can race with
.ndo_stop() or other ethtool operations that can free the statistics
memory.  Fix it by setting a new flag BNXT_STATE_READ_STATS and then
proceeding to read statistics memory only if the state is OPEN.  The
close path that frees the memory clears the OPEN state and then waits
for the BNXT_STATE_READ_STATS to clear before proceeding to free the
statistics memory.

Fixes: c0c050c58d84 ("bnxt_en: New Broadcom ethernet driver.")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 18 ++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a19f68f..415694d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6279,6 +6279,12 @@ static int bnxt_open(struct net_device *dev)
 	return __bnxt_open_nic(bp, true, true);
 }
 
+static bool bnxt_drv_busy(struct bnxt *bp)
+{
+	return (test_bit(BNXT_STATE_IN_SP_TASK, &bp->state) ||
+		test_bit(BNXT_STATE_READ_STATS, &bp->state));
+}
+
 int bnxt_close_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 {
 	int rc = 0;
@@ -6297,7 +6303,7 @@ int bnxt_close_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 
 	clear_bit(BNXT_STATE_OPEN, &bp->state);
 	smp_mb__after_atomic();
-	while (test_bit(BNXT_STATE_IN_SP_TASK, &bp->state))
+	while (bnxt_drv_busy(bp))
 		msleep(20);
 
 	/* Flush rings and and disable interrupts */
@@ -6358,8 +6364,15 @@ static int bnxt_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	u32 i;
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (!bp->bnapi)
+	set_bit(BNXT_STATE_READ_STATS, &bp->state);
+	/* Make sure bnxt_close_nic() sees that we are reading stats before
+	 * we check the BNXT_STATE_OPEN flag.
+	 */
+	smp_mb__after_atomic();
+	if (!test_bit(BNXT_STATE_OPEN, &bp->state)) {
+		clear_bit(BNXT_STATE_READ_STATS, &bp->state);
 		return;
+	}
 
 	/* TODO check if we need to synchronize with bnxt_close path */
 	for (i = 0; i < bp->cp_nr_rings; i++) {
@@ -6406,6 +6419,7 @@ static int bnxt_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		stats->tx_fifo_errors = le64_to_cpu(tx->tx_fifo_underruns);
 		stats->tx_errors = le64_to_cpu(tx->tx_err);
 	}
+	clear_bit(BNXT_STATE_READ_STATS, &bp->state);
 }
 
 static bool bnxt_mc_list_updated(struct bnxt *bp, u32 *rx_mask)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index f872a7d..3c9d484 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1117,6 +1117,7 @@ struct bnxt {
 	unsigned long		state;
 #define BNXT_STATE_OPEN		0
 #define BNXT_STATE_IN_SP_TASK	1
+#define BNXT_STATE_READ_STATS	2
 
 	struct bnxt_irq	*irq_tbl;
 	int			total_irqs;
-- 
1.8.3.1
