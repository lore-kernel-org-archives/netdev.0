From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 12/12] qlcnic: convert to set_phys_id
Date: Wed, 6 Apr 2011 14:47:23 -0700
Message-ID: <20110406144723.26467b77@nehalam>
References: <20110404184340.604594357@linuxplumber.net>
	<20110404184502.382340801@linuxplumber.net>
	<20110406.143226.42783062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, amit.salecha@qlogic.com,
	anirban.chakraborty@qlogic.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48140 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755465Ab1DFVrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 17:47:25 -0400
In-Reply-To: <20110406.143226.42783062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to use new ethtool set_phys_id.
Not completely sure that this is correct for all cases of device
up/down and doing operation. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 -use adapter variable to hold state across active/inactive

--- a/drivers/net/qlcnic/qlcnic_ethtool.c	2011-04-06 12:30:35.673116770 -0700
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c	2011-04-06 12:52:06.250784682 -0700
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
-	int ret;
 
-	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
-		dev_down = 1;
-		if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-			return -EIO;
-
-		ret = qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST);
-		if (ret) {
-			clear_bit(__QLCNIC_RESETTING, &adapter->state);
-			return ret;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		adapter->blink_was_down = false;
+		if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+			if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+				return -EIO;
+
+			if (qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST)) {
+				clear_bit(__QLCNIC_RESETTING, &adapter->state);
+				return -EIO;
+			}
+			adapter->blink_was_down = true;
 		}
-	}
 
-	ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
-	if (ret) {
+		if (adapter->nic_ops->config_led(adapter, 1, 0xf) == 0)
+			return 0;
+
 		dev_err(&adapter->pdev->dev,
 			"Failed to set LED blink state.\n");
-		goto done;
-	}
+		break;
 
-	msleep_interruptible(val * 1000);
+	case ETHTOOL_ID_INACTIVE:
+		if (adapter->nic_ops->config_led(adapter, 0, 0xf) == 0)
+			return 0;
 
-	ret = adapter->nic_ops->config_led(adapter, 0, 0xf);
-	if (ret) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to reset LED blink state.\n");
-		goto done;
+		break;
+
+	default:
+		return -EINVAL;
 	}
 
-done:
-	if (dev_down) {
+	if (adapter->blink_was_down) {
 		qlcnic_diag_free_res(dev, max_sds_rings);
 		clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	}
-	return ret;
 
+	return -EIO;
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
--- a/drivers/net/qlcnic/qlcnic.h	2011-04-06 12:32:53.622576568 -0700
+++ b/drivers/net/qlcnic/qlcnic.h	2011-04-06 12:51:55.698672781 -0700
@@ -1056,6 +1056,7 @@ struct qlcnic_adapter {
 
 	struct qlcnic_filter_hash fhash;
 
+	bool 		blink_was_down;
 	unsigned long state;
 	__le32 file_prd_off;	/*File fw product offset*/
 	u32 fw_version;
