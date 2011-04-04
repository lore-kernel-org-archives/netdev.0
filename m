From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 12/12] qlcnic: convert to set_phys_id
Date: Mon, 04 Apr 2011 11:43:52 -0700
Message-ID: <20110404184502.382340801@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52834 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755307Ab1DDSvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:18 -0400
Content-Disposition: inline; filename=qlcnic-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to use new ethtool set_phys_id.
Not completely sure that this is correct for all cases of device
up/down and doing operation. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/qlcnic/qlcnic_ethtool.c	2011-04-04 11:30:54.689092370 -0700
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c	2011-04-04 11:36:55.776744627 -0700
@@ -831,48 +831,51 @@ static int qlcnic_set_tso(struct net_dev
 	return 0;
 }
 
-static int qlcnic_blink_led(struct net_device *dev, u32 val)
+static int qlcnic_set_led(struct net_device *dev,
+			  enum ethtool_phys_id_state state)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int max_sds_rings = adapter->max_sds_rings;
-	int dev_down = 0;
 	int ret;
 
-	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
-		dev_down = 1;
-		if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-			return -EIO;
-
-		ret = qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST);
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+			if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+				return -EIO;
+
+			ret = qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST);
+			if (ret) {
+				clear_bit(__QLCNIC_RESETTING, &adapter->state);
+				return ret;
+			}
+		}
+
+		ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
 		if (ret) {
-			clear_bit(__QLCNIC_RESETTING, &adapter->state);
-			return ret;
+			dev_err(&adapter->pdev->dev,
+				"Failed to set LED blink state.\n");
+			break;
 		}
-	}
-
-	ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
-	if (ret) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to set LED blink state.\n");
-		goto done;
-	}
+		return 0;
 
-	msleep_interruptible(val * 1000);
+	case ETHTOOL_ID_INACTIVE:
+		ret = adapter->nic_ops->config_led(adapter, 0, 0xf);
+		if (ret)
+			dev_err(&adapter->pdev->dev,
+				"Failed to reset LED blink state.\n");
+		break;
 
-	ret = adapter->nic_ops->config_led(adapter, 0, 0xf);
-	if (ret) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to reset LED blink state.\n");
-		goto done;
+	default:
+		return -EINVAL;
 	}
 
-done:
-	if (dev_down) {
+	if (!netif_running(dev)) {
 		qlcnic_diag_free_res(dev, max_sds_rings);
 		clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	}
-	return ret;
 
+	return ret;
 }
 
 static void
@@ -1080,7 +1083,7 @@ const struct ethtool_ops qlcnic_ethtool_
 	.set_coalesce = qlcnic_set_intr_coalesce,
 	.get_flags = ethtool_op_get_flags,
 	.set_flags = qlcnic_set_flags,
-	.phys_id = qlcnic_blink_led,
+	.set_phys_id = qlcnic_set_led,
 	.set_msglevel = qlcnic_set_msglevel,
 	.get_msglevel = qlcnic_get_msglevel,
 };


