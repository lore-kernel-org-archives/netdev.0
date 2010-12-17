From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/3] qlcnic: fix LED test when interface is down.
Date: Fri, 17 Dec 2010 00:59:00 -0800
Message-ID: <1292576342-1359-2-git-send-email-amit.salecha@qlogic.com>
References: <1292576342-1359-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1914 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752215Ab0LQI72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 03:59:28 -0500
In-Reply-To: <1292576342-1359-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

When interface is down, create temporary context to config LED.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    1 +
 drivers/net/qlcnic/qlcnic_ethtool.c |   27 ++++++++++++++++++++++-----
 2 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index f267da4..4028d0c 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -925,6 +925,7 @@ struct qlcnic_ipaddr {
 
 #define QLCNIC_INTERRUPT_TEST		1
 #define QLCNIC_LOOPBACK_TEST		2
+#define QLCNIC_LED_TEST		3
 
 #define QLCNIC_FILTER_AGE	80
 #define QLCNIC_READD_AGE	20
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 0eaf31b..1e7af70 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -834,16 +834,27 @@ static int qlcnic_set_tso(struct net_device *dev, u32 data)
 static int qlcnic_blink_led(struct net_device *dev, u32 val)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	int max_sds_rings = adapter->max_sds_rings;
+	int dev_down = 0;
 	int ret;
 
-	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
-		return -EIO;
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+		dev_down = 1;
+		if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+			return -EIO;
+
+		ret = qlcnic_diag_alloc_res(dev, QLCNIC_LED_TEST);
+		if (ret) {
+			clear_bit(__QLCNIC_RESETTING, &adapter->state);
+			return ret;
+		}
+	}
 
 	ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
 	if (ret) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to set LED blink state.\n");
-		return ret;
+		goto done;
 	}
 
 	msleep_interruptible(val * 1000);
@@ -852,10 +863,16 @@ static int qlcnic_blink_led(struct net_device *dev, u32 val)
 	if (ret) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to reset LED blink state.\n");
-		return ret;
+		goto done;
 	}
 
-	return 0;
+done:
+	if (dev_down) {
+		qlcnic_diag_free_res(dev, max_sds_rings);
+		clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	}
+	return ret;
+
 }
 
 static void
-- 
1.7.3.2

