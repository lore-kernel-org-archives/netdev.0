From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 16/16] sfc: Remove dependency of PTP on having a
 dedicated channel
Date: Thu, 12 Dec 2013 23:03:45 +0000
Message-ID: <1386889425.1516.353.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29572 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab3LLXDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:03:48 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need a dedicated channel on Siena to ensure we can match up
the separate RX and timestamp events for each PTP packet.  We won't
do this for EF10 as timestamps are delivered inline.

Pass a channel index of 0 to MC_CMD_PTP_OP_ENABLE when there is no
dedicated channel.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.h   |  4 ++-
 drivers/net/ethernet/sfc/ptp.c   | 59 +++++++++++++++++++++++++---------------
 drivers/net/ethernet/sfc/siena.c |  2 +-
 3 files changed, 41 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 7ac9c000696f..25178536f053 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -554,7 +554,9 @@ int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf,
 			      bool spoofchk);
 
 struct ethtool_ts_info;
-void efx_ptp_probe(struct efx_nic *efx);
+int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel);
+void efx_ptp_defer_probe_with_channel(struct efx_nic *efx);
+void efx_ptp_remove(struct efx_nic *efx);
 int efx_ptp_set_ts_config(struct efx_nic *efx, struct ifreq *ifr);
 int efx_ptp_get_ts_config(struct efx_nic *efx, struct ifreq *ifr);
 void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info);
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 7ae66d900256..aa4876edaac6 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -214,7 +214,8 @@ struct efx_ptp_timeset {
 
 /**
  * struct efx_ptp_data - Precision Time Protocol (PTP) state
- * @channel: The PTP channel
+ * @efx: The NIC context
+ * @channel: The PTP channel (Siena only)
  * @rxq: Receive queue (awaiting timestamps)
  * @txq: Transmit queue
  * @evt_list: List of MC receive events awaiting packets
@@ -265,6 +266,7 @@ struct efx_ptp_timeset {
  * @timeset: Last set of synchronisation statistics.
  */
 struct efx_ptp_data {
+	struct efx_nic *efx;
 	struct efx_channel *channel;
 	struct sk_buff_head rxq;
 	struct sk_buff_head txq;
@@ -319,7 +321,8 @@ static int efx_ptp_enable(struct efx_nic *efx)
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_ENABLE);
 	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ENABLE_QUEUE,
-		       efx->ptp_data->channel->channel);
+		       efx->ptp_data->channel ?
+		       efx->ptp_data->channel->channel : 0);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ENABLE_MODE, efx->ptp_data->mode);
 
 	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
@@ -774,7 +777,7 @@ static int efx_ptp_insert_multicast_filters(struct efx_nic *efx)
 	struct efx_filter_spec rxfilter;
 	int rc;
 
-	if (ptp->rxfilter_installed)
+	if (!ptp->channel || ptp->rxfilter_installed)
 		return 0;
 
 	/* Must filter on both event and general ports to ensure
@@ -882,7 +885,7 @@ static void efx_ptp_pps_worker(struct work_struct *work)
 {
 	struct efx_ptp_data *ptp =
 		container_of(work, struct efx_ptp_data, pps_work);
-	struct efx_nic *efx = ptp->channel->efx;
+	struct efx_nic *efx = ptp->efx;
 	struct ptp_clock_event ptp_evt;
 
 	if (efx_ptp_synchronize(efx, PTP_SYNC_ATTEMPTS))
@@ -899,7 +902,7 @@ static void efx_ptp_worker(struct work_struct *work)
 {
 	struct efx_ptp_data *ptp_data =
 		container_of(work, struct efx_ptp_data, work);
-	struct efx_nic *efx = ptp_data->channel->efx;
+	struct efx_nic *efx = ptp_data->efx;
 	struct sk_buff *skb;
 	struct sk_buff_head tempq;
 
@@ -923,31 +926,25 @@ static void efx_ptp_worker(struct work_struct *work)
 		efx_ptp_process_rx(efx, skb);
 }
 
-/* Initialise PTP channel and state.
- *
- * Setting core_index to zero causes the queue to be initialised and doesn't
- * overlap with 'rxq0' because ptp.c doesn't use skb_record_rx_queue.
- */
-static int efx_ptp_probe_channel(struct efx_channel *channel)
+/* Initialise PTP state. */
+int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 {
-	struct efx_nic *efx = channel->efx;
 	struct efx_ptp_data *ptp;
 	int rc = 0;
 	unsigned int pos;
 
-	channel->irq_moderation = 0;
-	channel->rx_queue.core_index = 0;
-
 	ptp = kzalloc(sizeof(struct efx_ptp_data), GFP_KERNEL);
 	efx->ptp_data = ptp;
 	if (!efx->ptp_data)
 		return -ENOMEM;
 
+	ptp->efx = efx;
+	ptp->channel = channel;
+
 	rc = efx_nic_alloc_buffer(efx, &ptp->start, sizeof(int), GFP_KERNEL);
 	if (rc != 0)
 		goto fail1;
 
-	ptp->channel = channel;
 	skb_queue_head_init(&ptp->rxq);
 	skb_queue_head_init(&ptp->txq);
 	ptp->workwq = create_singlethread_workqueue("sfc_ptp");
@@ -1014,14 +1011,27 @@ fail1:
 	return rc;
 }
 
-static void efx_ptp_remove_channel(struct efx_channel *channel)
+/* Initialise PTP channel.
+ *
+ * Setting core_index to zero causes the queue to be initialised and doesn't
+ * overlap with 'rxq0' because ptp.c doesn't use skb_record_rx_queue.
+ */
+static int efx_ptp_probe_channel(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
 
+	channel->irq_moderation = 0;
+	channel->rx_queue.core_index = 0;
+
+	return efx_ptp_probe(efx, channel);
+}
+
+void efx_ptp_remove(struct efx_nic *efx)
+{
 	if (!efx->ptp_data)
 		return;
 
-	(void)efx_ptp_disable(channel->efx);
+	(void)efx_ptp_disable(efx);
 
 	cancel_work_sync(&efx->ptp_data->work);
 	cancel_work_sync(&efx->ptp_data->pps_work);
@@ -1038,6 +1048,11 @@ static void efx_ptp_remove_channel(struct efx_channel *channel)
 	kfree(efx->ptp_data);
 }
 
+static void efx_ptp_remove_channel(struct efx_channel *channel)
+{
+	efx_ptp_remove(channel->efx);
+}
+
 static void efx_ptp_get_channel_name(struct efx_channel *channel,
 				     char *buf, size_t len)
 {
@@ -1449,7 +1464,7 @@ static int efx_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	struct efx_ptp_data *ptp_data = container_of(ptp,
 						     struct efx_ptp_data,
 						     phc_clock_info);
-	struct efx_nic *efx = ptp_data->channel->efx;
+	struct efx_nic *efx = ptp_data->efx;
 	MCDI_DECLARE_BUF(inadj, MC_CMD_PTP_IN_ADJUST_LEN);
 	s64 adjustment_ns;
 	int rc;
@@ -1482,7 +1497,7 @@ static int efx_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	struct efx_ptp_data *ptp_data = container_of(ptp,
 						     struct efx_ptp_data,
 						     phc_clock_info);
-	struct efx_nic *efx = ptp_data->channel->efx;
+	struct efx_nic *efx = ptp_data->efx;
 	struct timespec delta_ts = ns_to_timespec(delta);
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_ADJUST_LEN);
 
@@ -1500,7 +1515,7 @@ static int efx_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 	struct efx_ptp_data *ptp_data = container_of(ptp,
 						     struct efx_ptp_data,
 						     phc_clock_info);
-	struct efx_nic *efx = ptp_data->channel->efx;
+	struct efx_nic *efx = ptp_data->efx;
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_READ_NIC_TIME_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_PTP_OUT_READ_NIC_TIME_LEN);
 	int rc;
@@ -1566,7 +1581,7 @@ static const struct efx_channel_type efx_ptp_channel_type = {
 	.keep_eventq		= false,
 };
 
-void efx_ptp_probe(struct efx_nic *efx)
+void efx_ptp_defer_probe_with_channel(struct efx_nic *efx)
 {
 	/* Check whether PTP is implemented on this NIC.  The DISABLE
 	 * operation will succeed if and only if it is implemented.
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index f2a7ad4c76aa..53b4ce67be0e 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -259,7 +259,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 		goto fail5;
 
 	efx_sriov_probe(efx);
-	efx_ptp_probe(efx);
+	efx_ptp_defer_probe_with_channel(efx);
 
 	return 0;
 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
