From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH v2 net-next 1/2] sfc: make TSO version a per-queue parameter
Date: Mon, 30 Nov 2015 09:05:35 +0000
Message-ID: <565C115F.6050504@solarflare.com>
References: <5655DC18.7090208@solarflare.com>
 <cover.1448874133.git.bkenward@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:32533 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752628AbbK3JF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 04:05:56 -0500
In-Reply-To: <cover.1448874133.git.bkenward@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Solarflare 8000 series NIC will use a new TSO scheme. The current
driver refuses to load if the current TSO scheme is not found. Remove
that check and instead make the TSO version a per-queue parameter.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 13 ++++++-------
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 drivers/net/ethernet/sfc/tx.c         |  8 ++++++--
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index bc6d21b..425df3d 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -181,13 +181,6 @@ static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 		MCDI_WORD(outbuf, GET_CAPABILITIES_OUT_TX_DPCPU_FW_ID);
 
 	if (!(nic_data->datapath_caps &
-	      (1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN))) {
-		netif_err(efx, drv, efx->net_dev,
-			  "current firmware does not support TSO\n");
-		return -ENODEV;
-	}
-
-	if (!(nic_data->datapath_caps &
 	      (1 << MC_CMD_GET_CAPABILITIES_OUT_RX_PREFIX_LEN_14_LBN))) {
 		netif_err(efx, probe, efx->net_dev,
 			  "current firmware does not support an RX prefix\n");
@@ -1797,6 +1790,12 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 			     ESF_DZ_TX_OPTION_UDP_TCP_CSUM, csum_offload,
 			     ESF_DZ_TX_OPTION_IP_CSUM, csum_offload);
 	tx_queue->write_count = 1;
+
+	if (nic_data->datapath_caps &
+	    (1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN)) {
+		tx_queue->tso_version = 1;
+	}
+
 	wmb();
 	efx_ef10_push_tx_desc(tx_queue, txd);
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index a8ddd12..5c0d0ba 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -182,6 +182,7 @@ struct efx_tx_buffer {
  *
  * @efx: The associated Efx NIC
  * @queue: DMA queue number
+ * @tso_version: Version of TSO in use for this queue.
  * @channel: The associated channel
  * @core_txq: The networking core TX queue structure
  * @buffer: The software buffer ring
@@ -228,6 +229,7 @@ struct efx_tx_queue {
 	/* Members which don't change on the fast path */
 	struct efx_nic *efx ____cacheline_aligned_in_smp;
 	unsigned queue;
+	unsigned int tso_version;
 	struct efx_channel *channel;
 	struct netdev_queue *core_txq;
 	struct efx_tx_buffer *buffer;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 67f6afa..f7a0ec1 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -1010,13 +1010,17 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue,
 
 /* Parse the SKB header and initialise state. */
 static int tso_start(struct tso_state *st, struct efx_nic *efx,
+		     struct efx_tx_queue *tx_queue,
 		     const struct sk_buff *skb)
 {
-	bool use_opt_desc = efx_nic_rev(efx) >= EFX_REV_HUNT_A0;
 	struct device *dma_dev = &efx->pci_dev->dev;
 	unsigned int header_len, in_len;
+	bool use_opt_desc = false;
 	dma_addr_t dma_addr;
 
+	if (tx_queue->tso_version == 1)
+		use_opt_desc = true;
+
 	st->ip_off = skb_network_header(skb) - skb->data;
 	st->tcp_off = skb_transport_header(skb) - skb->data;
 	header_len = st->tcp_off + (tcp_hdr(skb)->doff << 2u);
@@ -1271,7 +1275,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	/* Find the packet protocol and sanity-check it */
 	state.protocol = efx_tso_check_protocol(skb);
 
-	rc = tso_start(&state, efx, skb);
+	rc = tso_start(&state, efx, tx_queue, skb);
 	if (rc)
 		goto mem_err;
 
-- 
2.4.3
