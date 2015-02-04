From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: Fix NAPI poll routine for Tx completion
Date: Wed, 4 Feb 2015 05:41:25 -0500
Message-ID: <1423046485-9526-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:2743 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932598AbbBDLUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 06:20:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

After d75b1ade567f ("net: less interrupt masking in NAPI")
driver's NAPI poll routine is expected to return
exact budget value if it wants to be re-called.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Fixes: d75b1ade567f ("net: less interrupt masking in NAPI")
---
Hi Dave,

Please apply this patch to net

Thanks,
Shahed
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |   27 +++++++++++++++++++++--
 1 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 18e5de7..4e1f58c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -967,7 +967,12 @@ static int qlcnic_poll(struct napi_struct *napi, int budget)
 	tx_complete = qlcnic_process_cmd_ring(adapter, tx_ring,
 					      budget);
 	work_done = qlcnic_process_rcv_ring(sds_ring, budget);
-	if ((work_done < budget) && tx_complete) {
+
+	/* Check if we need a repoll */
+	if (!tx_complete)
+		work_done = budget;
+
+	if (work_done < budget) {
 		napi_complete(&sds_ring->napi);
 		if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 			qlcnic_enable_sds_intr(adapter, sds_ring);
@@ -992,6 +997,9 @@ static int qlcnic_tx_poll(struct napi_struct *napi, int budget)
 		napi_complete(&tx_ring->napi);
 		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
 			qlcnic_enable_tx_intr(adapter, tx_ring);
+	} else {
+		/* As qlcnic_process_cmd_ring() returned 0, we need a repoll*/
+		work_done = budget;
 	}
 
 	return work_done;
@@ -1950,7 +1958,12 @@ static int qlcnic_83xx_msix_sriov_vf_poll(struct napi_struct *napi, int budget)
 
 	tx_complete = qlcnic_process_cmd_ring(adapter, tx_ring, budget);
 	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
-	if ((work_done < budget) && tx_complete) {
+
+	/* Check if we need a repoll */
+	if (!tx_complete)
+		work_done = budget;
+
+	if (work_done < budget) {
 		napi_complete(&sds_ring->napi);
 		qlcnic_enable_sds_intr(adapter, sds_ring);
 	}
@@ -1973,7 +1986,12 @@ static int qlcnic_83xx_poll(struct napi_struct *napi, int budget)
 
 	tx_complete = qlcnic_process_cmd_ring(adapter, tx_ring, budget);
 	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
-	if ((work_done < budget) && tx_complete) {
+
+	/* Check if we need a repoll */
+	if (!tx_complete)
+		work_done = budget;
+
+	if (work_done < budget) {
 		napi_complete(&sds_ring->napi);
 		qlcnic_enable_sds_intr(adapter, sds_ring);
 	}
@@ -1995,6 +2013,9 @@ static int qlcnic_83xx_msix_tx_poll(struct napi_struct *napi, int budget)
 		napi_complete(&tx_ring->napi);
 		if (test_bit(__QLCNIC_DEV_UP , &adapter->state))
 			qlcnic_enable_tx_intr(adapter, tx_ring);
+	} else {
+		/* need a repoll */
+		work_done = budget;
 	}
 
 	return work_done;
-- 
1.7.1
