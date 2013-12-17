From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 4/7] qlcnic: Allow single Tx/Rx queue for all adapters.
Date: Tue, 17 Dec 2013 09:01:52 -0500
Message-ID: <1387288915-2981-5-git-send-email-manish.chopra@qlogic.com>
References: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:48061 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753456Ab3LQOew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 09:34:52 -0500
In-Reply-To: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Allow user to set sigle Tx/Rx queue in MSI-x mode,
  for ALL supported adapters.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    6 ++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    9 +--------
 3 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 406ab1b..01c7799 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -289,6 +289,7 @@ int qlcnic_83xx_setup_intr(struct qlcnic_adapter *adapter)
 		if (qlcnic_sriov_vf_check(adapter))
 			return -EINVAL;
 		num_msix = 1;
+		adapter->drv_tx_rings = QLCNIC_SINGLE_RING;
 	}
 	/* setup interrupt mapping table for fw */
 	ahw->intr_tbl = vzalloc(num_msix *
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 0149c94..9e1494a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1466,8 +1466,7 @@ int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
 	for (ring = 0; ring < adapter->drv_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 		if (qlcnic_check_multi_tx(adapter) &&
-		    !adapter->ahw->diag_test &&
-		    (adapter->drv_tx_rings > QLCNIC_SINGLE_RING)) {
+		    !adapter->ahw->diag_test) {
 			netif_napi_add(netdev, &sds_ring->napi, qlcnic_rx_poll,
 				       NAPI_POLL_WEIGHT);
 		} else {
@@ -1540,8 +1539,7 @@ void qlcnic_82xx_napi_enable(struct qlcnic_adapter *adapter)
 
 	if (qlcnic_check_multi_tx(adapter) &&
 	    (adapter->flags & QLCNIC_MSIX_ENABLED) &&
-	    !adapter->ahw->diag_test &&
-	    (adapter->drv_tx_rings > QLCNIC_SINGLE_RING)) {
+	    !adapter->ahw->diag_test) {
 		for (ring = 0; ring < adapter->drv_tx_rings; ring++) {
 			tx_ring = &adapter->tx_ring[ring];
 			napi_enable(&tx_ring->napi);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 45b1da1..72a1c12 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -646,8 +646,7 @@ int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 			} else {
 				adapter->ahw->num_msix = num_msix;
 				if (qlcnic_check_multi_tx(adapter) &&
-				    !adapter->ahw->diag_test &&
-				    (adapter->drv_tx_rings > 1))
+				    !adapter->ahw->diag_test)
 					drv_sds_rings = num_msix - drv_tx_rings;
 				else
 					drv_sds_rings = num_msix;
@@ -3722,12 +3721,6 @@ int qlcnic_validate_rings(struct qlcnic_adapter *adapter, __u32 ring_cnt,
 		return -EINVAL;
 	}
 
-	if (ring_cnt < 2) {
-		netdev_err(netdev,
-			   "%s rings value should not be lower than 2\n", buf);
-		return -EINVAL;
-	}
-
 	if (!is_power_of_2(ring_cnt)) {
 		netdev_err(netdev, "%s rings value should be a power of 2\n",
 			   buf);
-- 
1.5.6
