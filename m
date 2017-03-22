From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: allocate RX buffers in OOM conditions in
 PF and VF
Date: Wed, 22 Mar 2017 11:31:13 -0700
Message-ID: <20170322183113.GA1035@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0084.outbound.protection.outlook.com ([104.47.33.84]:43787
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965529AbdCVSbT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 14:31:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satanand Burla <satananda.burla@cavium.com>

Add workqueue that is periodically run to try to allocate RX buffers in OOM
conditions in PF and VF.

Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |  2 +
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 56 ++++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  5 ++
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |  5 ++
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 26 ++++++++++
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  2 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  7 +++
 7 files changed, 103 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
index 2fedd91..dee6046 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -43,6 +43,8 @@ struct octeon_cn23xx_pf {
 	struct octeon_config *conf;
 };
 
+#define CN23XX_SLI_DEF_BP			0x40
+
 int setup_cn23xx_octeon_pf_device(struct octeon_device *oct);
 
 int validate_cn23xx_pf_config_info(struct octeon_device *oct,
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 65a1a9e..08676df 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -26,6 +26,9 @@
 #include "octeon_main.h"
 #include "octeon_network.h"
 
+/* OOM task polling interval */
+#define LIO_OOM_POLL_INTERVAL_MS 250
+
 int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -293,3 +296,56 @@ void octeon_pf_changed_vf_macaddr(struct octeon_device *oct, u8 *mac)
 	 * the PF did that already
 	 */
 }
+
+static void octnet_poll_check_rxq_oom_status(struct work_struct *work)
+{
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct lio *lio = (struct lio *)wk->ctxptr;
+	struct octeon_device *oct = lio->oct_dev;
+	struct octeon_droq *droq;
+	int q, q_no = 0;
+
+	if (ifstate_check(lio, LIO_IFSTATE_RUNNING)) {
+		for (q = 0; q < lio->linfo.num_rxpciq; q++) {
+			q_no = lio->linfo.rxpciq[q].s.q_no;
+			droq = oct->droq[q_no];
+			if (!droq)
+				continue;
+			octeon_droq_check_oom(droq);
+		}
+	}
+	queue_delayed_work(lio->rxq_status_wq.wq,
+			   &lio->rxq_status_wq.wk.work,
+			   msecs_to_jiffies(LIO_OOM_POLL_INTERVAL_MS));
+}
+
+int setup_rx_oom_poll_fn(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+
+	lio->rxq_status_wq.wq = alloc_workqueue("rxq-oom-status",
+						WQ_MEM_RECLAIM, 0);
+	if (!lio->rxq_status_wq.wq) {
+		dev_err(&oct->pci_dev->dev, "unable to create cavium rxq oom status wq\n");
+		return -ENOMEM;
+	}
+	INIT_DELAYED_WORK(&lio->rxq_status_wq.wk.work,
+			  octnet_poll_check_rxq_oom_status);
+	lio->rxq_status_wq.wk.ctxptr = lio;
+	queue_delayed_work(lio->rxq_status_wq.wq,
+			   &lio->rxq_status_wq.wk.work,
+			   msecs_to_jiffies(LIO_OOM_POLL_INTERVAL_MS));
+	return 0;
+}
+
+void cleanup_rx_oom_poll_fn(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	if (lio->rxq_status_wq.wq) {
+		cancel_delayed_work_sync(&lio->rxq_status_wq.wk.work);
+		flush_workqueue(lio->rxq_status_wq.wq);
+		destroy_workqueue(lio->rxq_status_wq.wq);
+	}
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index b23485c..5298a79 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1672,6 +1672,8 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 
 	cleanup_link_status_change_wq(netdev);
 
+	cleanup_rx_oom_poll_fn(netdev);
+
 	delete_glists(lio);
 
 	free_netdev(netdev);
@@ -4146,6 +4148,9 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		if (setup_link_status_change_wq(netdev))
 			goto setup_nic_dev_fail;
 
+		if (setup_rx_oom_poll_fn(netdev))
+			goto setup_nic_dev_fail;
+
 		/* Register the network device with the OS */
 		if (register_netdev(netdev)) {
 			dev_err(&octeon_dev->pci_dev->dev, "Device registration failed\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index f72db33..af0032e 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1154,6 +1154,8 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
+	cleanup_rx_oom_poll_fn(netdev);
+
 	cleanup_link_status_change_wq(netdev);
 
 	delete_glists(lio);
@@ -2994,6 +2996,9 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		if (setup_link_status_change_wq(netdev))
 			goto setup_nic_dev_fail;
 
+		if (setup_rx_oom_poll_fn(netdev))
+			goto setup_nic_dev_fail;
+
 		/* Register the network device with the OS */
 		if (register_netdev(netdev)) {
 			dev_err(&octeon_dev->pci_dev->dev, "Device registration failed\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 0097059..286be55 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -513,6 +513,32 @@ octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
 	return desc_refilled;
 }
 
+/** check if we can allocate packets to get out of oom.
+ *  @param  droq - Droq being checked.
+ *  @return does not return anything
+ */
+void octeon_droq_check_oom(struct octeon_droq *droq)
+{
+	int desc_refilled;
+	struct octeon_device *oct = droq->oct_dev;
+
+	if (readl(droq->pkts_credit_reg) <= CN23XX_SLI_DEF_BP) {
+		spin_lock_bh(&droq->lock);
+		desc_refilled = octeon_droq_refill(oct, droq);
+		if (desc_refilled) {
+			/* Flush the droq descriptor data to memory to be sure
+			 * that when we update the credits the data in memory
+			 * is accurate.
+			 */
+			wmb();
+			writel(desc_refilled, droq->pkts_credit_reg);
+			/* make sure mmio write completes */
+			mmiowb();
+		}
+		spin_unlock_bh(&droq->lock);
+	}
+}
+
 static inline u32
 octeon_droq_get_bufcount(u32 buf_size, u32 total_len)
 {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 6982c0a..9781577 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -426,4 +426,6 @@ int octeon_droq_process_packets(struct octeon_device *oct,
 int octeon_process_droq_poll_cmd(struct octeon_device *oct, u32 q_no,
 				 int cmd, u32 arg);
 
+void octeon_droq_check_oom(struct octeon_droq *droq);
+
 #endif	/*__OCTEON_DROQ_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index ddb61bf..454ec0c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -129,6 +129,9 @@ struct lio {
 	/* work queue for  txq status */
 	struct cavium_wq	txq_status_wq;
 
+	/* work queue for  rxq oom status */
+	struct cavium_wq	rxq_status_wq;
+
 	/* work queue for  link status */
 	struct cavium_wq	link_status_wq;
 
@@ -152,6 +155,10 @@ struct lio {
  */
 int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1);
 
+int setup_rx_oom_poll_fn(struct net_device *netdev);
+
+void cleanup_rx_oom_poll_fn(struct net_device *netdev);
+
 /**
  * \brief Link control command completion callback
  * @param nctrl_ptr pointer to control packet structure
