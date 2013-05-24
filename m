From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 07/12] qlcnic: diagnostics routine changes
Date: Fri, 24 May 2013 03:04:31 -0400
Message-ID: <1369379076-4718-8-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:24797
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759561Ab3EXH37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:29:59 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Test and set diagnostics mode bit before starting
diagnostics tests. Stop diagnostics tests if adapter is resetting.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   12 ++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   28 +++++++++++++------
 2 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index e8127c2..3e8941a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -928,6 +928,7 @@ struct qlcnic_ipaddr {
 #define __QLCNIC_SRIOV_ENABLE		10
 #define __QLCNIC_SRIOV_CAPABLE		11
 #define __QLCNIC_MBX_POLL_ENABLE	12
+#define __QLCNIC_DIAG_MODE		13
 
 #define QLCNIC_INTERRUPT_TEST		1
 #define QLCNIC_LOOPBACK_TEST		2
@@ -1472,6 +1473,7 @@ int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_host_tx_ring *);
 
 /* Functions from qlcnic_ethtool.c */
+
 int qlcnic_check_loopback_buff(unsigned char *, u8 []);
 int qlcnic_do_lb_test(struct qlcnic_adapter *, u8);
 int qlcnic_loopback_test(struct net_device *, u8);
@@ -1879,6 +1881,16 @@ static inline void qlcnic_enable_int(struct qlcnic_host_sds_ring *sds_ring)
 		writel(0xfbff, adapter->tgt_mask_reg);
 }
 
+static inline int qlcnic_get_diag_lock(struct qlcnic_adapter *adapter)
+{
+	return test_and_set_bit(__QLCNIC_DIAG_MODE, &adapter->state);
+}
+
+static inline void qlcnic_release_diag_lock(struct qlcnic_adapter *adapter)
+{
+	clear_bit(__QLCNIC_DIAG_MODE, &adapter->state);
+}
+
 extern const struct ethtool_ops qlcnic_sriov_vf_ethtool_ops;
 extern const struct ethtool_ops qlcnic_ethtool_ops;
 extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 9f5683f..1e699e6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1593,16 +1593,24 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int ret = 0, loop = 0, max_sds_rings = adapter->max_sds_rings;
 
-	QLCDB(adapter, DRV, "%s loopback test in progress\n",
-	      mode == QLCNIC_ILB_MODE ? "internal" : "external");
 	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		dev_warn(&adapter->pdev->dev,
-			 "Loopback test not supported for non privilege function\n");
+		netdev_warn(netdev,
+			    "Loopback test not supported in non privileged mode\n");
 		return ret;
 	}
 
-	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
+		netdev_info(netdev, "Device is resetting\n");
 		return -EBUSY;
+	}
+
+	if (qlcnic_get_diag_lock(adapter)) {
+		netdev_info(netdev, "Device is in diagnostics mode\n");
+		return -EBUSY;
+	}
+
+	netdev_info(netdev, "%s loopback test in progress\n",
+		    mode == QLCNIC_ILB_MODE ? "internal" : "external");
 
 	ret = qlcnic_83xx_diag_alloc_res(netdev, QLCNIC_LOOPBACK_TEST,
 					 max_sds_rings);
@@ -1643,7 +1651,7 @@ free_diag_res:
 
 fail_diag_alloc:
 	adapter->max_sds_rings = max_sds_rings;
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	qlcnic_release_diag_lock(adapter);
 	return ret;
 }
 
@@ -3118,8 +3126,10 @@ int qlcnic_83xx_interrupt_test(struct net_device *netdev)
 	u8 val;
 	int ret, max_sds_rings = adapter->max_sds_rings;
 
-	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		return -EIO;
+	if (qlcnic_get_diag_lock(adapter)) {
+		netdev_info(netdev, "Device in diagnostics mode\n");
+		return -EBUSY;
+	}
 
 	ret = qlcnic_83xx_diag_alloc_res(netdev, QLCNIC_INTERRUPT_TEST,
 					 max_sds_rings);
@@ -3161,7 +3171,7 @@ done:
 
 fail_diag_irq:
 	adapter->max_sds_rings = max_sds_rings;
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	qlcnic_release_diag_lock(adapter);
 	return ret;
 }
 
-- 
1.5.6
