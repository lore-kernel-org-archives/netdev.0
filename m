From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 1/1] qede: prevent chip hang when increasing channels
Date: Thu, 5 May 2016 00:35:16 -0400
Message-ID: <1462422916-25584-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:56624 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756224AbcEEFRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 01:17:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qede requires qed to provide enough resources to accommodate 16 combined
channels, but that upper-bound isn't actually being enforced by it.
Instead, qed inform back to qede how many channels can be opened based on
available resources - but that calculation doesn't really take into account
the resources requested by qede; Instead it considers other FW/HW available
resources.

As a result, if a user would increase the number of channels to more than
16 [e.g., using ethtool] the chip would hang.

This change increments the resources requested by qede to 64 combined
channels instead of 16; This value is an upper bound on the possible
available channels [due to other FW/HW resources].

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 7869465..8d5248c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1938,8 +1938,6 @@ static struct qede_dev *qede_alloc_etherdev(struct qed_dev *cdev,
 	edev->q_num_rx_buffers = NUM_RX_BDS_DEF;
 	edev->q_num_tx_buffers = NUM_TX_BDS_DEF;
 
-	DP_INFO(edev, "Allocated netdev with 64 tx queues and 64 rx queues\n");
-
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	memset(&edev->stats, 0, sizeof(edev->stats));
@@ -2090,9 +2088,9 @@ static void qede_update_pf_params(struct qed_dev *cdev)
 {
 	struct qed_pf_params pf_params;
 
-	/* 16 rx + 16 tx */
+	/* 64 rx + 64 tx */
 	memset(&pf_params, 0, sizeof(struct qed_pf_params));
-	pf_params.eth_pf_params.num_cons = 32;
+	pf_params.eth_pf_params.num_cons = 128;
 	qed_ops->common->update_pf_params(cdev, &pf_params);
 }
 
-- 
1.8.3.1
