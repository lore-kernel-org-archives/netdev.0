From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 06/14] sfc: record the PF's vport ID in nic_data
Date: Wed, 6 May 2015 00:57:14 +0100
Message-ID: <554958DA.7090502@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:40167 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475AbbEEX5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:57:19 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The default port ID of EVB_PORT_ID_ASSIGNED is a "magic" number
for the MCFW to select the physical port of the PF.  If other
vswitches and vports are created on top of the default firmware
configuration, the ID of the newly created vport is then required
when passed to MCDI commands.  Currently, this doesn't happen so
the vport_id is never changed, but a subsequent patch will change
this behaviour so that other vswitches and vports are created.

The vport_id recorded in nic_data is only relevant for PFs.
VFs will have their vports created by their parent PF, and in
that case the parent PF will record the vport ID of each VF.
For a VF, nic_data->vport_id is expected to remain at the default
value.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 13 +++++++++----
 drivers/net/ethernet/sfc/nic.h  |  2 ++
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4f9775f..8db717e 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -217,6 +217,8 @@ static int efx_ef10_probe(struct efx_nic *efx)
 
 	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
 
+	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
+
 	/* In case we're recovering from a crash (kexec), we want to
 	 * cancel any outstanding request by the previous user of this
 	 * function.  We send a special message using the least
@@ -1245,6 +1247,7 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 	size_t entries = tx_queue->txd.buf.len / EFX_BUF_SIZE;
 	struct efx_channel *channel = tx_queue->channel;
 	struct efx_nic *efx = tx_queue->efx;
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	size_t inlen, outlen;
 	dma_addr_t dma_addr;
 	efx_qword_t *txd;
@@ -1259,7 +1262,7 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 			      INIT_TXQ_IN_FLAG_IP_CSUM_DIS, !csum_offload,
 			      INIT_TXQ_IN_FLAG_TCP_CSUM_DIS, !csum_offload);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_OWNER_ID, 0);
-	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_PORT_ID, EVB_PORT_ID_ASSIGNED);
+	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_PORT_ID, nic_data->vport_id);
 
 	dma_addr = tx_queue->txd.buf.dma_addr;
 
@@ -1390,11 +1393,12 @@ static int efx_ef10_alloc_rss_context(struct efx_nic *efx, u32 *context)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_RSS_CONTEXT_ALLOC_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_RSS_CONTEXT_ALLOC_OUT_LEN);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	size_t outlen;
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_UPSTREAM_PORT_ID,
-		       EVB_PORT_ID_ASSIGNED);
+		       nic_data->vport_id);
 	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_TYPE,
 		       MC_CMD_RSS_CONTEXT_ALLOC_IN_TYPE_EXCLUSIVE);
 	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_ALLOC_IN_NUM_QUEUES,
@@ -1508,6 +1512,7 @@ static void efx_ef10_rx_init(struct efx_rx_queue *rx_queue)
 	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 	size_t entries = rx_queue->rxd.buf.len / EFX_BUF_SIZE;
 	struct efx_nic *efx = rx_queue->efx;
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	size_t inlen, outlen;
 	dma_addr_t dma_addr;
 	int rc;
@@ -1525,7 +1530,7 @@ static void efx_ef10_rx_init(struct efx_rx_queue *rx_queue)
 			      INIT_RXQ_IN_FLAG_PREFIX, 1,
 			      INIT_RXQ_IN_FLAG_TIMESTAMP, 1);
 	MCDI_SET_DWORD(inbuf, INIT_RXQ_IN_OWNER_ID, 0);
-	MCDI_SET_DWORD(inbuf, INIT_RXQ_IN_PORT_ID, EVB_PORT_ID_ASSIGNED);
+	MCDI_SET_DWORD(inbuf, INIT_RXQ_IN_PORT_ID, nic_data->vport_id);
 
 	dma_addr = rx_queue->rxd.buf.dma_addr;
 
@@ -2294,7 +2299,7 @@ static void efx_ef10_filter_push_prep(struct efx_nic *efx,
 			       match_fields);
 	}
 
-	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_PORT_ID, EVB_PORT_ID_ASSIGNED);
+	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_PORT_ID, nic_data->vport_id);
 	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_RX_DEST,
 		       spec->dmaq_id == EFX_FILTER_RX_DMAQ_ID_DROP ?
 		       MC_CMD_FILTER_OP_IN_RX_DEST_DROP :
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 17ee3ae..f29e4ec 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -493,6 +493,7 @@ enum {
  *	%MC_CMD_GET_CAPABILITIES response)
  * @rx_dpcpu_fw_id: Firmware ID of the RxDPCPU
  * @tx_dpcpu_fw_id: Firmware ID of the TxDPCPU
+ * @vport_id: The function's vport ID, only relevant for PFs
  */
 struct efx_ef10_nic_data {
 	struct efx_buffer mcdi_buf;
@@ -513,6 +514,7 @@ struct efx_ef10_nic_data {
 	u32 datapath_caps;
 	unsigned int rx_dpcpu_fw_id;
 	unsigned int tx_dpcpu_fw_id;
+	unsigned int vport_id;
 };
 
 int efx_init_sriov(void);
