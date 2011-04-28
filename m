From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [NEXT PATCH 1/3] qlcnic: fix memory leak in qlcnic_blink_led.
Date: Wed, 27 Apr 2011 17:43:44 -0700
Message-ID: <1303951426-4341-2-git-send-email-amit.salecha@qlogic.com>
References: <1303951426-4341-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:30790 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757154Ab1D0XoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 19:44:03 -0400
In-Reply-To: <1303951426-4341-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Memory allocated in ETHTOOL_ACTIVE mode, is not getting freed. So,
  in ETHTOOL_ID_INACTIVE mode, return after freeing allocated memory.
o Using set bit instead of blink_down field, as it is also required
  in internal Loopback test and etc.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    2 +-
 drivers/net/qlcnic/qlcnic_ethtool.c |   12 +++++-------
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index fa5b15c..f7acb80 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -884,6 +884,7 @@ struct qlcnic_ipaddr {
 #define __QLCNIC_RESETTING		2
 #define __QLCNIC_START_FW 		4
 #define __QLCNIC_AER			5
+#define __QLCNIC_DIAG_RES_ALLOC		6
 
 #define QLCNIC_INTERRUPT_TEST		1
 #define QLCNIC_LOOPBACK_TEST		2
@@ -913,7 +914,6 @@ struct qlcnic_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 
-	bool 		blink_was_down;
 	unsigned long state;
 	u32 flags;
 
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 615a5ab..de65847 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -772,7 +772,6 @@ static int qlcnic_set_led(struct net_device *dev,
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
-		adapter->blink_was_down = false;
 		if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 			if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
 				return -EIO;
@@ -781,7 +780,7 @@ static int qlcnic_set_led(struct net_device *dev,
 				clear_bit(__QLCNIC_RESETTING, &adapter->state);
 				return -EIO;
 			}
-			adapter->blink_was_down = true;
+			set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
 		}
 
 		if (adapter->nic_ops->config_led(adapter, 1, 0xf) == 0)
@@ -792,18 +791,17 @@ static int qlcnic_set_led(struct net_device *dev,
 		break;
 
 	case ETHTOOL_ID_INACTIVE:
-		if (adapter->nic_ops->config_led(adapter, 0, 0xf) == 0)
-			return 0;
+		if (adapter->nic_ops->config_led(adapter, 0, 0xf))
+			dev_err(&adapter->pdev->dev,
+				"Failed to reset LED blink state.\n");
 
-		dev_err(&adapter->pdev->dev,
-			"Failed to reset LED blink state.\n");
 		break;
 
 	default:
 		return -EINVAL;
 	}
 
-	if (adapter->blink_was_down) {
+	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state)) {
 		qlcnic_diag_free_res(dev, max_sds_rings);
 		clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	}
-- 
1.6.3.3

