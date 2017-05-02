From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 1/2] qede: Fix concurrency issue in PTP Tx path processing.
Date: Tue, 2 May 2017 01:11:02 -0700
Message-ID: <20170502081103.4252-2-sudarsana.kalluru@cavium.com>
References: <20170502081103.4252-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0075.outbound.protection.outlook.com ([104.47.38.75]:63856
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751279AbdEBILb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 04:11:31 -0400
In-Reply-To: <20170502081103.4252-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTP Tx timestamping data structures are not protected against the
concurrent access in the Tx paths. Protecting the same using atomic
bit locks.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h     | 5 +++--
 drivers/net/ethernet/qlogic/qede/qede_ptp.c | 4 ++++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index f2aaef2..378b654 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -147,10 +147,11 @@ struct qede_dev {
 	u32				dp_module;
 	u8				dp_level;
 
-	u32 flags;
-#define QEDE_FLAG_IS_VF	BIT(0)
+	unsigned long flags;
+#define QEDE_FLAG_IS_VF			BIT(0)
 #define IS_VF(edev)	(!!((edev)->flags & QEDE_FLAG_IS_VF))
 #define QEDE_TX_TIMESTAMPING_EN		BIT(1)
+#define QEDE_FLAGS_PTP_TX_IN_PRORGESS	BIT(2)
 
 	const struct qed_eth_ops	*ops;
 	struct qede_ptp			*ptp;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ptp.c b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
index 2e62dec..f5f743f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ptp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
@@ -181,6 +181,7 @@ static void qede_ptp_task(struct work_struct *work)
 	skb_tstamp_tx(ptp->tx_skb, &shhwtstamps);
 	dev_kfree_skb_any(ptp->tx_skb);
 	ptp->tx_skb = NULL;
+	clear_bit_unlock(QEDE_FLAGS_PTP_TX_IN_PRORGESS, &edev->flags);
 
 	DP_VERBOSE(edev, QED_MSG_DEBUG,
 		   "Tx timestamp, timestamp cycles = %llu, ns = %llu\n",
@@ -495,6 +496,9 @@ void qede_ptp_tx_ts(struct qede_dev *edev, struct sk_buff *skb)
 	if (!ptp)
 		return;
 
+	if (test_and_set_bit_lock(QEDE_FLAGS_PTP_TX_IN_PRORGESS, &edev->flags))
+		return;
+
 	if (unlikely(!(edev->flags & QEDE_TX_TIMESTAMPING_EN))) {
 		DP_NOTICE(edev,
 			  "Tx timestamping was not enabled, this packet will not be timestamped\n");
-- 
1.8.3.1
