From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 4/6] sfc: use new performance based event queue init
Date: Thu, 11 Aug 2016 13:01:54 +0100
Message-ID: <a70015d3-7540-b721-d118-054b9d024428@solarflare.com>
References: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:3647 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751722AbcHKMZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 08:25:47 -0400
In-Reply-To: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than explicitly specifying flags we can now specify a desired
performance target to the firmware, ie higher throughput or lower latency.
For now we use the default "auto" configuration.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 43 +++++++++++++++++++++++++++++------------
 1 file changed, 31 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index fd5d086..e57fa2e 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2541,13 +2541,12 @@ fail:
 static int efx_ef10_ev_init(struct efx_channel *channel)
 {
 	MCDI_DECLARE_BUF(inbuf,
-			 MC_CMD_INIT_EVQ_IN_LEN(EFX_MAX_EVQ_SIZE * 8 /
-						EFX_BUF_SIZE));
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_INIT_EVQ_OUT_LEN);
+			 MC_CMD_INIT_EVQ_V2_IN_LEN(EFX_MAX_EVQ_SIZE * 8 /
+						   EFX_BUF_SIZE));
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_INIT_EVQ_V2_OUT_LEN);
 	size_t entries = channel->eventq.buf.len / EFX_BUF_SIZE;
 	struct efx_nic *efx = channel->efx;
 	struct efx_ef10_nic_data *nic_data;
-	bool supports_rx_merge;
 	size_t inlen, outlen;
 	unsigned int enabled, implemented;
 	dma_addr_t dma_addr;
@@ -2555,9 +2554,6 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 	int i;
 
 	nic_data = efx->nic_data;
-	supports_rx_merge =
-		!!(nic_data->datapath_caps &
-		   1 << MC_CMD_GET_CAPABILITIES_OUT_RX_BATCHING_LBN);
 
 	/* Fill event queue with all ones (i.e. empty events) */
 	memset(channel->eventq.buf.addr, 0xff, channel->eventq.buf.len);
@@ -2566,11 +2562,6 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 	MCDI_SET_DWORD(inbuf, INIT_EVQ_IN_INSTANCE, channel->channel);
 	/* INIT_EVQ expects index in vector table, not absolute */
 	MCDI_SET_DWORD(inbuf, INIT_EVQ_IN_IRQ_NUM, channel->channel);
-	MCDI_POPULATE_DWORD_4(inbuf, INIT_EVQ_IN_FLAGS,
-			      INIT_EVQ_IN_FLAG_INTERRUPTING, 1,
-			      INIT_EVQ_IN_FLAG_RX_MERGE, 1,
-			      INIT_EVQ_IN_FLAG_TX_MERGE, 1,
-			      INIT_EVQ_IN_FLAG_CUT_THRU, !supports_rx_merge);
 	MCDI_SET_DWORD(inbuf, INIT_EVQ_IN_TMR_MODE,
 		       MC_CMD_INIT_EVQ_IN_TMR_MODE_DIS);
 	MCDI_SET_DWORD(inbuf, INIT_EVQ_IN_TMR_LOAD, 0);
@@ -2579,6 +2570,27 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 		       MC_CMD_INIT_EVQ_IN_COUNT_MODE_DIS);
 	MCDI_SET_DWORD(inbuf, INIT_EVQ_IN_COUNT_THRSHLD, 0);
 
+	if (nic_data->datapath_caps2 &
+	    1 << MC_CMD_GET_CAPABILITIES_V2_OUT_INIT_EVQ_V2_LBN) {
+		/* Use the new generic approach to specifying event queue
+		 * configuration, requesting lower latency or higher throughput.
+		 * The options that actually get used appear in the output.
+		 */
+		MCDI_POPULATE_DWORD_2(inbuf, INIT_EVQ_V2_IN_FLAGS,
+				      INIT_EVQ_V2_IN_FLAG_INTERRUPTING, 1,
+				      INIT_EVQ_V2_IN_FLAG_TYPE,
+				      MC_CMD_INIT_EVQ_V2_IN_FLAG_TYPE_AUTO);
+	} else {
+		bool cut_thru = !(nic_data->datapath_caps &
+			1 << MC_CMD_GET_CAPABILITIES_OUT_RX_BATCHING_LBN);
+
+		MCDI_POPULATE_DWORD_4(inbuf, INIT_EVQ_IN_FLAGS,
+				      INIT_EVQ_IN_FLAG_INTERRUPTING, 1,
+				      INIT_EVQ_IN_FLAG_RX_MERGE, 1,
+				      INIT_EVQ_IN_FLAG_TX_MERGE, 1,
+				      INIT_EVQ_IN_FLAG_CUT_THRU, cut_thru);
+	}
+
 	dma_addr = channel->eventq.buf.dma_addr;
 	for (i = 0; i < entries; ++i) {
 		MCDI_SET_ARRAY_QWORD(inbuf, INIT_EVQ_IN_DMA_ADDR, i, dma_addr);
@@ -2589,6 +2601,13 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_INIT_EVQ, inbuf, inlen,
 			  outbuf, sizeof(outbuf), &outlen);
+
+	if (outlen >= MC_CMD_INIT_EVQ_V2_OUT_LEN)
+		netif_dbg(efx, drv, efx->net_dev,
+			  "Channel %d using event queue flags %08x\n",
+			  channel->channel,
+			  MCDI_DWORD(outbuf, INIT_EVQ_V2_OUT_FLAGS));
+
 	/* IRQ return is ignored */
 	if (channel->channel || rc)
 		return rc;
-- 
2.7.4
