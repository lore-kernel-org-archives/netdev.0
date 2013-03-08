From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/5] qlcnic: Enable LED test support for 83xx adapter
Date: Fri,  8 Mar 2013 14:53:50 -0500
Message-ID: <1362772433-12045-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:42431 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752146Ab3CHUQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 15:16:48 -0500
In-Reply-To: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Add support for LED test on 83xx series adapters

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   45 ++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    3 +-
 3 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 41c02ba..c08fa20 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1432,6 +1432,51 @@ mbx_err:
 	}
 }
 
+int  qlcnic_83xx_set_led(struct net_device *netdev,
+			 enum ethtool_phys_id_state state)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	int err = -EIO, active = 1;
+
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
+		netdev_warn(netdev,
+			    "LED test is not supported in non-privileged mode\n");
+		return -EOPNOTSUPP;
+	}
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state))
+			return -EBUSY;
+
+		if (test_bit(__QLCNIC_RESETTING, &adapter->state))
+			break;
+
+		err = qlcnic_83xx_config_led(adapter, active, 0);
+		if (err)
+			netdev_err(netdev, "Failed to set LED blink state\n");
+		break;
+	case ETHTOOL_ID_INACTIVE:
+		active = 0;
+
+		if (test_bit(__QLCNIC_RESETTING, &adapter->state))
+			break;
+
+		err = qlcnic_83xx_config_led(adapter, active, 0);
+		if (err)
+			netdev_err(netdev, "Failed to reset LED blink state\n");
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	if (!active || err)
+		clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
+
+	return err;
+}
+
 void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *adapter,
 				       int enable)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 94e3ee0..648a73f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -449,5 +449,6 @@ int qlcnic_83xx_get_regs_len(struct qlcnic_adapter *);
 int qlcnic_83xx_get_registers(struct qlcnic_adapter *, u32 *);
 int qlcnic_83xx_loopback_test(struct net_device *, u8);
 int qlcnic_83xx_interrupt_test(struct net_device *);
+int qlcnic_83xx_set_led(struct net_device *, enum ethtool_phys_id_state);
 int qlcnic_83xx_flash_test(struct qlcnic_adapter *);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 5641f8e..ba1502a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1176,7 +1176,8 @@ static int qlcnic_set_led(struct net_device *dev,
 	int err = -EIO, active = 1;
 
 	if (qlcnic_83xx_check(adapter))
-		return -EOPNOTSUPP;
+		return qlcnic_83xx_set_led(dev, state);
+
 	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(dev, "LED test not supported for non "
 				"privilege function\n");
-- 
1.5.6
