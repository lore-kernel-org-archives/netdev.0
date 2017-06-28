From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 04/14] amd-xgbe: Add a check for an skb in the
 timestamp path
Date: Wed, 28 Jun 2017 13:41:58 -0500
Message-ID: <20170628184158.21972.76092.stgit@tlendack-t1.amdoffice.net>
References: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0042.outbound.protection.outlook.com ([104.47.32.42]:29872
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751642AbdF1SmD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 14:42:03 -0400
In-Reply-To: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spurious Tx timestamp interrupts can cause an oops in the Tx timestamp
processing function if a Tx timestamp skb is NULL. Add a check to insure
a Tx timestamp skb is present before attempting to use it.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index a934bd5..2068510 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1212,6 +1212,10 @@ static void xgbe_tx_tstamp(struct work_struct *work)
 	u64 nsec;
 	unsigned long flags;
 
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+	if (!pdata->tx_tstamp_skb)
+		goto unlock;
+
 	if (pdata->tx_tstamp) {
 		nsec = timecounter_cyc2time(&pdata->tstamp_tc,
 					    pdata->tx_tstamp);
@@ -1223,8 +1227,9 @@ static void xgbe_tx_tstamp(struct work_struct *work)
 
 	dev_kfree_skb_any(pdata->tx_tstamp_skb);
 
-	spin_lock_irqsave(&pdata->tstamp_lock, flags);
 	pdata->tx_tstamp_skb = NULL;
+
+unlock:
 	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
 }
 
