From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net] qlcnic: Validate Tx queue only for 82xx adapters.
Date: Thu, 17 Oct 2013 18:26:38 -0400
Message-ID: <ee136cd9c8e22123662b55a614e509277cfeba40.1382067199.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:22497 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750933Ab3JQW5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 18:57:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o validate Tx queue only in case of adapters which supports
  multi Tx queue.

  This patch is to fix regression introduced in commit
  aa4a1f7df7cbb98797c9f4edfde3c726e2b3841f
  "qlcnic: Enable Tx queue changes using ethtool for 82xx Series adapter"

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 8 +-------
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index ebe4c86..ff83a9f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -665,7 +665,7 @@ static int qlcnic_set_channels(struct net_device *dev,
 			return err;
 	}
 
-	if (channel->tx_count) {
+	if (qlcnic_82xx_check(adapter) && channel->tx_count) {
 		err = qlcnic_validate_max_tx_rings(adapter, channel->tx_count);
 		if (err)
 			return err;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index f07f2b0..9e61eb8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3651,11 +3651,6 @@ int qlcnic_validate_max_tx_rings(struct qlcnic_adapter *adapter, u32 txq)
 	u8 max_hw = QLCNIC_MAX_TX_RINGS;
 	u32 max_allowed;
 
-	if (!qlcnic_82xx_check(adapter)) {
-		netdev_err(netdev, "No Multi TX-Q support\n");
-		return -EINVAL;
-	}
-
 	if (!qlcnic_use_msi_x && !qlcnic_use_msi) {
 		netdev_err(netdev, "No Multi TX-Q support in INT-x mode\n");
 		return -EINVAL;
@@ -3695,8 +3690,7 @@ int qlcnic_validate_max_rss(struct qlcnic_adapter *adapter,
 	u8 max_hw = adapter->ahw->max_rx_ques;
 	u32 max_allowed;
 
-	if (qlcnic_82xx_check(adapter) && !qlcnic_use_msi_x &&
-	    !qlcnic_use_msi) {
+	if (!qlcnic_use_msi_x && !qlcnic_use_msi) {
 		netdev_err(netdev, "No RSS support in INT-x mode\n");
 		return -EINVAL;
 	}
-- 
1.8.1.4
