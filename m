From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 12/18] liquidio: RX control commands
Date: Sun, 21 Aug 2016 17:12:39 -0700
Message-ID: <1471824765-26473-13-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0082.outbound.protection.outlook.com ([104.47.33.82]:62277
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753857AbcHVA3O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:29:14 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for RX control commands on cn23xx device.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 100 ++++++++++++++++++---
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   1 +
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   8 +-
 3 files changed, 96 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 1bdaa2d..6d109d6 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -98,6 +98,14 @@ struct liquidio_if_cfg_resp {
 	u64 status;
 };
 
+struct liquidio_rx_ctl_context {
+	int octeon_id;
+
+	wait_queue_head_t wc;
+
+	int cond;
+};
+
 struct oct_link_status_resp {
 	u64 rh;
 	struct oct_link_info link_info;
@@ -1374,23 +1382,89 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 }
 
 /**
+ * \brief Callback for rx ctrl
+ * @param status status of request
+ * @param buf pointer to resp structure
+ */
+static void rx_ctl_callback(struct octeon_device *oct,
+			    u32 status,
+			    void *buf)
+{
+	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
+	struct liquidio_rx_ctl_context *ctx;
+
+	ctx  = (struct liquidio_rx_ctl_context *)sc->ctxptr;
+
+	oct = lio_get_device(ctx->octeon_id);
+	if (status)
+		dev_err(&oct->pci_dev->dev, "rx ctl instruction failed. Status: %llx\n",
+			CVM_CAST64(status));
+	WRITE_ONCE(ctx->cond, 1);
+
+	/* This barrier is required to be sure that the response has been
+	 * written fully before waking up the handler
+	 */
+	wmb();
+
+	wake_up_interruptible(&ctx->wc);
+}
+
+/**
  * \brief Send Rx control command
  * @param lio per-network private data
  * @param start_stop whether to start or stop
  */
 static void send_rx_ctrl_cmd(struct lio *lio, int start_stop)
 {
-	struct octnic_ctrl_pkt nctrl;
+	struct octeon_soft_command *sc;
+	struct liquidio_rx_ctl_context *ctx;
+	union octnet_cmd *ncmd;
+	int ctx_size = sizeof(struct liquidio_rx_ctl_context);
+	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
+	int retval;
 
-	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+	if (oct->props[lio->ifidx].rx_on == start_stop)
+		return;
 
-	nctrl.ncmd.s.cmd = OCTNET_CMD_RX_CTL;
-	nctrl.ncmd.s.param1 = start_stop;
-	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
-	nctrl.netpndev = (u64)lio->netdev;
+	sc = (struct octeon_soft_command *)
+		octeon_alloc_soft_command(oct, OCTNET_CMD_SIZE,
+					  16, ctx_size);
+
+	ncmd = (union octnet_cmd *)sc->virtdptr;
+	ctx  = (struct liquidio_rx_ctl_context *)sc->ctxptr;
+
+	WRITE_ONCE(ctx->cond, 0);
+	ctx->octeon_id = lio_get_device_id(oct);
+	init_waitqueue_head(&ctx->wc);
+
+	ncmd->u64 = 0;
+	ncmd->s.cmd = OCTNET_CMD_RX_CTL;
+	ncmd->s.param1 = start_stop;
+
+	octeon_swap_8B_data((u64 *)ncmd, (OCTNET_CMD_SIZE >> 3));
+
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+
+	octeon_prepare_soft_command(oct, sc, OPCODE_NIC,
+				    OPCODE_NIC_CMD, 0, 0, 0);
+
+	sc->callback = rx_ctl_callback;
+	sc->callback_arg = sc;
+	sc->wait_time = 5000;
 
-	if (octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl) < 0)
+	retval = octeon_send_soft_command(oct, sc);
+	if (retval == IQ_SEND_FAILED) {
 		netif_info(lio, rx_err, lio->netdev, "Failed to send RX Control message\n");
+	} else {
+		/* Sleep on a wait queue till the cond flag indicates that the
+		 * response arrived or timed-out.
+		 */
+		if (sleep_cond(&ctx->wc, &ctx->cond) == -EINTR)
+			return;
+		oct->props[lio->ifidx].rx_on = start_stop;
+	}
+
+	octeon_free_soft_command(oct, sc);
 }
 
 /**
@@ -1417,10 +1491,8 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 
 	dev_dbg(&oct->pci_dev->dev, "NIC device cleanup\n");
 
-	send_rx_ctrl_cmd(lio, 0);
-
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
-		txqs_stop(netdev);
+		liquidio_stop(netdev);
 
 	if (oct->props[lio->ifidx].napi_enabled == 1) {
 		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
@@ -3558,7 +3630,11 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		/* Sleep on a wait queue till the cond flag indicates that the
 		 * response arrived or timed-out.
 		 */
-		sleep_cond(&ctx->wc, &ctx->cond);
+		if (sleep_cond(&ctx->wc, &ctx->cond) == -EINTR) {
+			dev_err(&octeon_dev->pci_dev->dev, "Wait interrupted\n");
+			goto setup_nic_wait_intr;
+		}
+
 		retval = resp->status;
 		if (retval) {
 			dev_err(&octeon_dev->pci_dev->dev, "iq/oq config failed\n");
@@ -3758,6 +3834,8 @@ setup_nic_dev_fail:
 
 	octeon_free_soft_command(octeon_dev, sc);
 
+setup_nic_wait_intr:
+
 	while (i--) {
 		dev_err(&octeon_dev->pci_dev->dev,
 			"NIC ifidx:%d Setup failed\n", i);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 8e28ff4..ec3cb22 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -277,6 +277,7 @@ struct octdev_props {
 	/* Each interface in the Octeon device has a network
 	 * device pointer (used for OS specific calls).
 	 */
+	int    rx_on;
 	int    napi_enabled;
 	int    gmxport;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index ebeef95..366298f 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -181,22 +181,26 @@ cnnic_numa_alloc_aligned_dma(u32 size,
 #define cnnic_free_aligned_dma(pci_dev, ptr, size, orig_ptr, dma_addr) \
 		free_pages(orig_ptr, get_order(size))
 
-static inline void
+static inline int
 sleep_cond(wait_queue_head_t *wait_queue, int *condition)
 {
+	int errno = 0;
 	wait_queue_t we;
 
 	init_waitqueue_entry(&we, current);
 	add_wait_queue(wait_queue, &we);
 	while (!(READ_ONCE(*condition))) {
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (signal_pending(current))
+		if (signal_pending(current)) {
+			errno = -EINTR;
 			goto out;
+		}
 		schedule();
 	}
 out:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(wait_queue, &we);
+	return errno;
 }
 
 static inline void
-- 
1.8.3.1
