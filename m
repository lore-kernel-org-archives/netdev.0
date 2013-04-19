From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 7/8] qlcnic: Support polling for mailbox events.
Date: Fri, 19 Apr 2013 13:01:14 -0400
Message-ID: <1366390875-24570-8-git-send-email-rajesh.borundia@qlogic.com>
References: <1366390875-24570-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:12944 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752575Ab3DSRZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 13:25:06 -0400
In-Reply-To: <1366390875-24570-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o When mailbox interrupt is disabled PF should be
  able to process request from VF. Enable polling
  for such cases.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   29 ++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    5 +++-
 4 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index fef2f4b..86eaa68 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -919,6 +919,7 @@ struct qlcnic_ipaddr {
 #define __QLCNIC_ELB_INPROGRESS		8
 #define __QLCNIC_SRIOV_ENABLE		10
 #define __QLCNIC_SRIOV_CAPABLE		11
+#define __QLCNIC_MBX_POLL_ENABLE	12
 
 #define QLCNIC_INTERRUPT_TEST		1
 #define QLCNIC_LOOPBACK_TEST		2
@@ -1012,6 +1013,7 @@ struct qlcnic_adapter {
 	struct workqueue_struct *qlcnic_wq;
 	struct delayed_work fw_work;
 	struct delayed_work idc_aen_work;
+	struct delayed_work mbx_poll_work;
 
 	struct qlcnic_filter_hash fhash;
 	struct qlcnic_filter_hash rx_fhash;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index f1d06d2..32a95c1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -926,6 +926,35 @@ static void qlcnic_83xx_process_aen(struct qlcnic_adapter *adapter)
 	spin_unlock_irqrestore(&ahw->mbx_lock, flags);
 }
 
+static void qlcnic_83xx_mbx_poll_work(struct work_struct *work)
+{
+	struct qlcnic_adapter *adapter;
+
+	adapter = container_of(work, struct qlcnic_adapter, mbx_poll_work.work);
+
+	if (!test_bit(__QLCNIC_MBX_POLL_ENABLE, &adapter->state))
+		return;
+
+	qlcnic_83xx_process_aen(adapter);
+	queue_delayed_work(adapter->qlcnic_wq, &adapter->mbx_poll_work,
+			   (HZ / 10));
+}
+
+void qlcnic_83xx_enable_mbx_poll(struct qlcnic_adapter *adapter)
+{
+	if (test_and_set_bit(__QLCNIC_MBX_POLL_ENABLE, &adapter->state))
+		return;
+
+	INIT_DELAYED_WORK(&adapter->mbx_poll_work, qlcnic_83xx_mbx_poll_work);
+}
+
+void qlcnic_83xx_disable_mbx_poll(struct qlcnic_adapter *adapter)
+{
+	if (!test_and_clear_bit(__QLCNIC_MBX_POLL_ENABLE, &adapter->state))
+		return;
+	cancel_delayed_work_sync(&adapter->mbx_poll_work);
+}
+
 static int qlcnic_83xx_add_rings(struct qlcnic_adapter *adapter)
 {
 	int index, i, err, sds_mbx_size;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 73070bc..4be411c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -621,4 +621,6 @@ int qlcnic_83xx_enable_flash_write(struct qlcnic_adapter *);
 int qlcnic_83xx_disable_flash_write(struct qlcnic_adapter *);
 u32 qlcnic_83xx_mac_rcode(struct qlcnic_adapter *);
 u32 qlcnic_83xx_mbx_poll(struct qlcnic_adapter *);
+void qlcnic_83xx_enable_mbx_poll(struct qlcnic_adapter *);
+void qlcnic_83xx_disable_mbx_poll(struct qlcnic_adapter *);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 9b76881..f869bab 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3306,8 +3306,10 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 
 	qlcnic_detach(adapter);
 
-	if (qlcnic_83xx_check(adapter))
+	if (qlcnic_83xx_check(adapter)) {
 		qlcnic_83xx_free_mbx_intr(adapter);
+		qlcnic_83xx_enable_mbx_poll(adapter);
+	}
 
 	qlcnic_teardown_intr(adapter);
 	err = qlcnic_setup_intr(adapter, data);
@@ -3321,6 +3323,7 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 		/* register for NIC IDC AEN Events */
 		qlcnic_83xx_register_nic_idc_func(adapter, 1);
 		err = qlcnic_83xx_setup_mbx_intr(adapter);
+		qlcnic_83xx_disable_mbx_poll(adapter);
 		if (err) {
 			dev_err(&adapter->pdev->dev,
 				"failed to setup mbx interrupt\n");
-- 
1.6.3.3
