From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 3/5] qede: Add support for PTP resource locking.
Date: Wed, 26 Apr 2017 09:00:51 -0700
Message-ID: <20170426160053.8356-4-sudarsana.kalluru@cavium.com>
References: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0065.outbound.protection.outlook.com ([104.47.42.65]:3147
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934705AbdDZQBb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 12:01:31 -0400
In-Reply-To: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds necessary changes to the driver to use qed resource
locking functionality. Currently the ptp initialization is spread
between driver probe/open implementations, associated APIs are
qede_ptp_register_phc()/qede_ptp_start(). Clubbed this functionality
into single API qed_ptp_enable() to simplify the usage of qed resource
locking implementation. The new API will be invoked in the probe path.
Similarly the ptp clean-up code is moved to qede_ptp_disable() which
gets invoked in the driver unload path.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c |  18 +---
 drivers/net/ethernet/qlogic/qede/qede_ptp.c  | 150 +++++++++++++--------------
 drivers/net/ethernet/qlogic/qede/qede_ptp.h  |   6 +-
 3 files changed, 75 insertions(+), 99 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 292e2dc..b9ba23d 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -907,13 +907,8 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 	edev->ops->common->set_id(cdev, edev->ndev->name, DRV_MODULE_VERSION);
 
 	/* PTP not supported on VFs */
-	if (!is_vf) {
-		rc = qede_ptp_register_phc(edev);
-		if (rc) {
-			DP_NOTICE(edev, "Cannot register PHC\n");
-			goto err5;
-		}
-	}
+	if (!is_vf)
+		qede_ptp_enable(edev, true);
 
 	edev->ops->register_ops(cdev, &qede_ll_ops, edev);
 
@@ -928,8 +923,6 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	return 0;
 
-err5:
-	unregister_netdev(edev->ndev);
 err4:
 	qede_roce_dev_remove(edev);
 err3:
@@ -980,7 +973,7 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 	unregister_netdev(ndev);
 	cancel_delayed_work_sync(&edev->sp_task);
 
-	qede_ptp_remove(edev);
+	qede_ptp_disable(edev);
 
 	qede_roce_dev_remove(edev);
 
@@ -1877,8 +1870,6 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode,
 	qede_roce_dev_event_close(edev);
 	edev->state = QEDE_STATE_CLOSED;
 
-	qede_ptp_stop(edev);
-
 	/* Close OS Tx */
 	netif_tx_disable(edev->ndev);
 	netif_carrier_off(edev->ndev);
@@ -1987,13 +1978,10 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode,
 
 	qede_roce_dev_event_open(edev);
 
-	qede_ptp_start(edev, (mode == QEDE_LOAD_NORMAL));
-
 	edev->state = QEDE_STATE_OPEN;
 
 	DP_INFO(edev, "Ending successfully qede load\n");
 
-
 	goto out;
 err4:
 	qede_sync_free_irqs(edev);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ptp.c b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
index 2e62dec..6396363 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ptp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
@@ -206,21 +206,6 @@ static u64 qede_ptp_read_cc(const struct cyclecounter *cc)
 	return phc_cycles;
 }
 
-static void qede_ptp_init_cc(struct qede_dev *edev)
-{
-	struct qede_ptp *ptp;
-
-	ptp = edev->ptp;
-	if (!ptp)
-		return;
-
-	memset(&ptp->cc, 0, sizeof(ptp->cc));
-	ptp->cc.read = qede_ptp_read_cc;
-	ptp->cc.mask = CYCLECOUNTER_MASK(64);
-	ptp->cc.shift = 0;
-	ptp->cc.mult = 1;
-}
-
 static int qede_ptp_cfg_filters(struct qede_dev *edev)
 {
 	struct qede_ptp *ptp = edev->ptp;
@@ -324,61 +309,6 @@ int qede_ptp_hw_ts(struct qede_dev *edev, struct ifreq *ifr)
 			    sizeof(config)) ? -EFAULT : 0;
 }
 
-/* Called during load, to initialize PTP-related stuff */
-static void qede_ptp_init(struct qede_dev *edev, bool init_tc)
-{
-	struct qede_ptp *ptp;
-	int rc;
-
-	ptp = edev->ptp;
-	if (!ptp)
-		return;
-
-	spin_lock_init(&ptp->lock);
-
-	/* Configure PTP in HW */
-	rc = ptp->ops->enable(edev->cdev);
-	if (rc) {
-		DP_ERR(edev, "Stopping PTP initialization\n");
-		return;
-	}
-
-	/* Init work queue for Tx timestamping */
-	INIT_WORK(&ptp->work, qede_ptp_task);
-
-	/* Init cyclecounter and timecounter. This is done only in the first
-	 * load. If done in every load, PTP application will fail when doing
-	 * unload / load (e.g. MTU change) while it is running.
-	 */
-	if (init_tc) {
-		qede_ptp_init_cc(edev);
-		timecounter_init(&ptp->tc, &ptp->cc,
-				 ktime_to_ns(ktime_get_real()));
-	}
-
-	DP_VERBOSE(edev, QED_MSG_DEBUG, "PTP initialization is successful\n");
-}
-
-void qede_ptp_start(struct qede_dev *edev, bool init_tc)
-{
-	qede_ptp_init(edev, init_tc);
-	qede_ptp_cfg_filters(edev);
-}
-
-void qede_ptp_remove(struct qede_dev *edev)
-{
-	struct qede_ptp *ptp;
-
-	ptp = edev->ptp;
-	if (ptp && ptp->clock) {
-		ptp_clock_unregister(ptp->clock);
-		ptp->clock = NULL;
-	}
-
-	kfree(ptp);
-	edev->ptp = NULL;
-}
-
 int qede_ptp_get_ts_info(struct qede_dev *edev, struct ethtool_ts_info *info)
 {
 	struct qede_ptp *ptp = edev->ptp;
@@ -417,8 +347,7 @@ int qede_ptp_get_ts_info(struct qede_dev *edev, struct ethtool_ts_info *info)
 	return 0;
 }
 
-/* Called during unload, to stop PTP-related stuff */
-void qede_ptp_stop(struct qede_dev *edev)
+void qede_ptp_disable(struct qede_dev *edev)
 {
 	struct qede_ptp *ptp;
 
@@ -426,6 +355,11 @@ void qede_ptp_stop(struct qede_dev *edev)
 	if (!ptp)
 		return;
 
+	if (ptp->clock) {
+		ptp_clock_unregister(ptp->clock);
+		ptp->clock = NULL;
+	}
+
 	/* Cancel PTP work queue. Should be done after the Tx queues are
 	 * drained to prevent additional scheduling.
 	 */
@@ -439,11 +373,54 @@ void qede_ptp_stop(struct qede_dev *edev)
 	spin_lock_bh(&ptp->lock);
 	ptp->ops->disable(edev->cdev);
 	spin_unlock_bh(&ptp->lock);
+
+	kfree(ptp);
+	edev->ptp = NULL;
 }
 
-int qede_ptp_register_phc(struct qede_dev *edev)
+static int qede_ptp_init(struct qede_dev *edev, bool init_tc)
 {
 	struct qede_ptp *ptp;
+	int rc;
+
+	ptp = edev->ptp;
+	if (!ptp)
+		return -EINVAL;
+
+	spin_lock_init(&ptp->lock);
+
+	/* Configure PTP in HW */
+	rc = ptp->ops->enable(edev->cdev);
+	if (rc) {
+		DP_INFO(edev, "PTP HW enable failed\n");
+		return rc;
+	}
+
+	/* Init work queue for Tx timestamping */
+	INIT_WORK(&ptp->work, qede_ptp_task);
+
+	/* Init cyclecounter and timecounter. This is done only in the first
+	 * load. If done in every load, PTP application will fail when doing
+	 * unload / load (e.g. MTU change) while it is running.
+	 */
+	if (init_tc) {
+		memset(&ptp->cc, 0, sizeof(ptp->cc));
+		ptp->cc.read = qede_ptp_read_cc;
+		ptp->cc.mask = CYCLECOUNTER_MASK(64);
+		ptp->cc.shift = 0;
+		ptp->cc.mult = 1;
+
+		timecounter_init(&ptp->tc, &ptp->cc,
+				 ktime_to_ns(ktime_get_real()));
+	}
+
+	return rc;
+}
+
+int qede_ptp_enable(struct qede_dev *edev, bool init_tc)
+{
+	struct qede_ptp *ptp;
+	int rc;
 
 	ptp = kzalloc(sizeof(*ptp), GFP_KERNEL);
 	if (!ptp) {
@@ -454,14 +431,19 @@ int qede_ptp_register_phc(struct qede_dev *edev)
 	ptp->edev = edev;
 	ptp->ops = edev->ops->ptp;
 	if (!ptp->ops) {
-		kfree(ptp);
-		edev->ptp = NULL;
-		DP_ERR(edev, "PTP clock registeration failed\n");
-		return -EIO;
+		DP_INFO(edev, "PTP enable failed\n");
+		rc = -EIO;
+		goto err1;
 	}
 
 	edev->ptp = ptp;
 
+	rc = qede_ptp_init(edev, init_tc);
+	if (rc)
+		goto err1;
+
+	qede_ptp_cfg_filters(edev);
+
 	/* Fill the ptp_clock_info struct and register PTP clock */
 	ptp->clock_info.owner = THIS_MODULE;
 	snprintf(ptp->clock_info.name, 16, "%s", edev->ndev->name);
@@ -478,13 +460,21 @@ int qede_ptp_register_phc(struct qede_dev *edev)
 
 	ptp->clock = ptp_clock_register(&ptp->clock_info, &edev->pdev->dev);
 	if (IS_ERR(ptp->clock)) {
-		ptp->clock = NULL;
-		kfree(ptp);
-		edev->ptp = NULL;
+		rc = -EINVAL;
 		DP_ERR(edev, "PTP clock registeration failed\n");
+		goto err2;
 	}
 
 	return 0;
+
+err2:
+	qede_ptp_disable(edev);
+	ptp->clock = NULL;
+err1:
+	kfree(ptp);
+	edev->ptp = NULL;
+
+	return rc;
 }
 
 void qede_ptp_tx_ts(struct qede_dev *edev, struct sk_buff *skb)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ptp.h b/drivers/net/ethernet/qlogic/qede/qede_ptp.h
index f328f9b..691a14c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ptp.h
+++ b/drivers/net/ethernet/qlogic/qede/qede_ptp.h
@@ -40,10 +40,8 @@
 void qede_ptp_rx_ts(struct qede_dev *edev, struct sk_buff *skb);
 void qede_ptp_tx_ts(struct qede_dev *edev, struct sk_buff *skb);
 int qede_ptp_hw_ts(struct qede_dev *edev, struct ifreq *req);
-void qede_ptp_start(struct qede_dev *edev, bool init_tc);
-void qede_ptp_stop(struct qede_dev *edev);
-void qede_ptp_remove(struct qede_dev *edev);
-int qede_ptp_register_phc(struct qede_dev *edev);
+void qede_ptp_disable(struct qede_dev *edev);
+int qede_ptp_enable(struct qede_dev *edev, bool init_tc);
 int qede_ptp_get_ts_info(struct qede_dev *edev, struct ethtool_ts_info *ts);
 
 static inline void qede_ptp_record_rx_ts(struct qede_dev *edev,
-- 
1.8.3.1
