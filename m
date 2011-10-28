From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 5/5] qlcnic: fix beacon and LED test.
Date: Fri, 28 Oct 2011 15:57:15 -0700
Message-ID: <1319842636-14936-5-git-send-email-anirban.chakraborty@qlogic.com>
References: <1319842636-14936-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:44100
	"EHLO AM1EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933781Ab1J1XJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 19:09:40 -0400
In-Reply-To: <1319842636-14936-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Updated version number to 5.0.25

o Do not hold onto RESETTING_BIT for entire duration of LED/ beacon test.
  Instead, just checking for RESETTING_BIT not set before sending config_led
  command down to card.

o Take rtnl_lock instead of RESETTING_BIT for beacon test while sending
  config_led command down to make sure interface cannot be brought up/ down.

o Allocate and free resources if interface is down before
  sending the config_led command. This is to make sure config_led
  command sending doesn't fail.

o Clear QLCNIC_LED_ENABLE bit if beacon/ LED test fails to start.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   45 +++++++++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   39 ++++++++++-------
 3 files changed, 57 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 2fd1ba8..7ed53db 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -36,8 +36,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 24
-#define QLCNIC_LINUX_VERSIONID  "5.0.24"
+#define _QLCNIC_LINUX_SUBVERSION 25
+#define QLCNIC_LINUX_VERSIONID  "5.0.25"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 5d8bec2..8aa1c6e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -935,31 +935,49 @@ static int qlcnic_set_led(struct net_device *dev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int max_sds_rings = adapter->max_sds_rings;
+	int err = -EIO, active = 1;
+
+	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+		netdev_warn(dev, "LED test not supported for non "
+				"privilege function\n");
+		return -EOPNOTSUPP;
+	}
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
 		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state))
 			return -EBUSY;
 
-		if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
-			if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-				return -EIO;
+		if (test_bit(__QLCNIC_RESETTING, &adapter->state))
+			break;
 
-			if (qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST)) {
-				clear_bit(__QLCNIC_RESETTING, &adapter->state);
-				return -EIO;
-			}
+		if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+			if (qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST))
+				break;
 			set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
 		}
 
-		if (adapter->nic_ops->config_led(adapter, 1, 0xf) == 0)
-			return 0;
+		if (adapter->nic_ops->config_led(adapter, 1, 0xf) == 0) {
+			err = 0;
+			break;
+		}
 
 		dev_err(&adapter->pdev->dev,
 			"Failed to set LED blink state.\n");
 		break;
 
 	case ETHTOOL_ID_INACTIVE:
+		active = 0;
+
+		if (test_bit(__QLCNIC_RESETTING, &adapter->state))
+			break;
+
+		if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+			if (qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST))
+				break;
+			set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
+		}
+
 		if (adapter->nic_ops->config_led(adapter, 0, 0xf))
 			dev_err(&adapter->pdev->dev,
 				"Failed to reset LED blink state.\n");
@@ -970,14 +988,13 @@ static int qlcnic_set_led(struct net_device *dev,
 		return -EINVAL;
 	}
 
-	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state)) {
+	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state))
 		qlcnic_diag_free_res(dev, max_sds_rings);
-		clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	}
 
-	clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
+	if (!active || err)
+		clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
 
-	return -EIO;
+	return err;
 }
 
 static void
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 2edffce..0bd1638 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3504,11 +3504,16 @@ qlcnic_store_beacon(struct device *dev,
 {
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int max_sds_rings = adapter->max_sds_rings;
-	int dev_down = 0;
 	u16 beacon;
 	u8 b_state, b_rate;
 	int err;
 
+	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+		dev_warn(dev, "LED test not supported for non "
+				"privilege function\n");
+		return -EOPNOTSUPP;
+	}
+
 	if (len != sizeof(u16))
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3520,36 +3525,40 @@ qlcnic_store_beacon(struct device *dev,
 	if (adapter->ahw->beacon_state == b_state)
 		return len;
 
+	rtnl_lock();
+
 	if (!adapter->ahw->beacon_state)
-		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state))
+		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state)) {
+			rtnl_unlock();
 			return -EBUSY;
+		}
+
+	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
+		err = -EIO;
+		goto out;
+	}
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
-		if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-			return -EIO;
 		err = qlcnic_diag_alloc_res(adapter->netdev, QLCNIC_LED_TEST);
-		if (err) {
-			clear_bit(__QLCNIC_RESETTING, &adapter->state);
-			clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
-			return err;
-		}
-		dev_down = 1;
+		if (err)
+			goto out;
+		set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
 	}
 
 	err = qlcnic_config_led(adapter, b_state, b_rate);
 
 	if (!err) {
-		adapter->ahw->beacon_state = b_state;
 		err = len;
+		adapter->ahw->beacon_state = b_state;
 	}
 
-	if (dev_down) {
+	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state))
 		qlcnic_diag_free_res(adapter->netdev, max_sds_rings);
-		clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	}
 
-	if (!b_state)
+ out:
+	if (!adapter->ahw->beacon_state)
 		clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
+	rtnl_unlock();
 
 	return err;
 }
-- 
1.7.4.1
