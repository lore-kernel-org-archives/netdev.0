From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 3/5] qed*: Don't reset statistics on inner reload
Date: Sun, 19 Jun 2016 15:18:13 +0300
Message-ID: <1466338695-15538-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:49984 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751734AbcFSMSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 08:18:36 -0400
In-Reply-To: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several user APIs can cause driver to perform an inner-reload.
Currently, doing this would cause the HW/FW statistics of the
adapter to reset, which isn't the expected behavior [statistics
should only reset on explicit unloads].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c     | 3 ++-
 drivers/net/ethernet/qlogic/qede/qede_main.c | 7 ++++---
 include/linux/qed/qed_eth_if.h               | 1 +
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 0e8d43c..90be67e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1745,7 +1745,8 @@ static int qed_start_vport(struct qed_dev *cdev,
 			   start.vport_id, start.mtu);
 	}
 
-	qed_reset_vport_stats(cdev);
+	if (params->clear_stats)
+		qed_reset_vport_stats(cdev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 5733d18..f8e11f9 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -3231,7 +3231,7 @@ static int qede_stop_queues(struct qede_dev *edev)
 	return rc;
 }
 
-static int qede_start_queues(struct qede_dev *edev)
+static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 {
 	int rc, tc, i;
 	int vlan_removal_en = 1;
@@ -3462,6 +3462,7 @@ out:
 
 enum qede_load_mode {
 	QEDE_LOAD_NORMAL,
+	QEDE_LOAD_RELOAD,
 };
 
 static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
@@ -3500,7 +3501,7 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 		goto err3;
 	DP_INFO(edev, "Setup IRQs succeeded\n");
 
-	rc = qede_start_queues(edev);
+	rc = qede_start_queues(edev, mode != QEDE_LOAD_RELOAD);
 	if (rc)
 		goto err4;
 	DP_INFO(edev, "Start VPORT, RXQ and TXQ succeeded\n");
@@ -3555,7 +3556,7 @@ void qede_reload(struct qede_dev *edev,
 	if (func)
 		func(edev, args);
 
-	qede_load(edev, QEDE_LOAD_NORMAL);
+	qede_load(edev, QEDE_LOAD_RELOAD);
 
 	mutex_lock(&edev->qede_lock);
 	qede_config_rx_mode(edev->ndev);
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index 6ae8cb4..6c876a6 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -49,6 +49,7 @@ struct qed_start_vport_params {
 	bool drop_ttl0;
 	u8 vport_id;
 	u16 mtu;
+	bool clear_stats;
 };
 
 struct qed_stop_rxq_params {
-- 
1.9.3
