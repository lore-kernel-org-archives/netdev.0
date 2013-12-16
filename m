From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 3/8] qlcnic: Fix TSS/RSS ring validation logic.
Date: Mon, 16 Dec 2013 15:36:58 -0500
Message-ID: <d3e96e65adcd25c2f4d4fcdb2298f8ee518f4e48.1387256276.git.himanshu.madhani@qlogic.com>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:63841 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751984Ab3LPVJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:53 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o TSS/RSS ring validation does not take into account that either
  of these ring values can be 0. This patch fixes this validation
  and would fail set_channel operation if any of these ring value
  is 0. This regression was added as part of commit id
  34e8c406fda5b5a9d2e126a92bab84cd28e3b5fa ("qlcnic: refactor Tx/SDS
  ring calculation and validation in driver.")

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c   | 6 +++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      | 1 +
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 89208e5..fae1b71 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2073,8 +2073,8 @@ int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter)
 		ahw->nic_mode = QLCNIC_DEFAULT_MODE;
 		adapter->nic_ops->init_driver = qlcnic_83xx_init_default_driver;
 		ahw->idc.state_entry = qlcnic_83xx_idc_ready_state_entry;
-		adapter->max_sds_rings = ahw->max_rx_ques;
-		adapter->max_tx_rings = ahw->max_tx_ques;
+		adapter->max_sds_rings = QLCNIC_MAX_SDS_RINGS;
+		adapter->max_tx_rings = QLCNIC_MAX_TX_RINGS;
 	} else {
 		return -EIO;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 6d3edf6..78f5e81 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -667,9 +667,13 @@ qlcnic_set_ringparam(struct net_device *dev,
 static int qlcnic_validate_ring_count(struct qlcnic_adapter *adapter,
 				      u8 rx_ring, u8 tx_ring)
 {
+	if (rx_ring == 0 || tx_ring == 0)
+		return -EINVAL;
+
 	if (rx_ring != 0) {
 		if (rx_ring > adapter->max_sds_rings) {
-			netdev_err(adapter->netdev, "Invalid ring count, SDS ring count %d should not be greater than max %d driver sds rings.\n",
+			netdev_err(adapter->netdev,
+				   "Invalid ring count, SDS ring count %d should not be greater than max %d driver sds rings.\n",
 				   rx_ring, adapter->max_sds_rings);
 			return -EINVAL;
 		}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index aa019c3..2c8cac0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1178,6 +1178,7 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	} else {
 		adapter->ahw->nic_mode = QLCNIC_DEFAULT_MODE;
 		adapter->max_tx_rings = QLCNIC_MAX_HW_TX_RINGS;
+		adapter->max_sds_rings = QLCNIC_MAX_SDS_RINGS;
 		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
 	}
 
-- 
1.8.1.4
