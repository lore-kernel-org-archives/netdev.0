From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 5/7] liquidio CN23XX: VF xmit
Date: Mon, 5 Dec 2016 01:15:16 -0800
Message-ID: <1480929318-8511-6-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1480929318-8511-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0050.outbound.protection.outlook.com ([104.47.41.50]:28208
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751902AbcLEJtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 04:49:09 -0500
In-Reply-To: <1480929318-8511-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for transmit functionality in VF.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    |  21 ++
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 340 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/request_manager.c |   6 +-
 3 files changed, 364 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
index 108e487..b6117b6 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
@@ -529,6 +529,26 @@ static u64 cn23xx_vf_msix_interrupt_handler(void *dev)
 	return ret;
 }
 
+static u32 cn23xx_update_read_index(struct octeon_instr_queue *iq)
+{
+	u32 pkt_in_done = readl(iq->inst_cnt_reg);
+	u32 last_done;
+	u32 new_idx;
+
+	last_done = pkt_in_done - iq->pkt_in_done;
+	iq->pkt_in_done = pkt_in_done;
+
+	/* Modulo of the new index with the IQ size will give us
+	 * the new index.  The iq->reset_instr_cnt is always zero for
+	 * cn23xx, so no extra adjustments are needed.
+	 */
+	new_idx = (iq->octeon_read_index +
+		   (u32)(last_done & CN23XX_PKT_IN_DONE_CNT_MASK)) %
+		  iq->max_count;
+
+	return new_idx;
+}
+
 static void cn23xx_enable_vf_interrupt(struct octeon_device *oct, u8 intr_flag)
 {
 	struct octeon_cn23xx_vf *cn23xx = (struct octeon_cn23xx_vf *)oct->chip;
@@ -660,6 +680,7 @@ int cn23xx_setup_octeon_vf_device(struct octeon_device *oct)
 	oct->fn_list.msix_interrupt_handler = cn23xx_vf_msix_interrupt_handler;
 
 	oct->fn_list.setup_device_regs = cn23xx_setup_vf_device_regs;
+	oct->fn_list.update_iq_read_idx = cn23xx_update_read_index;
 
 	oct->fn_list.enable_interrupt = cn23xx_enable_vf_interrupt;
 	oct->fn_list.disable_interrupt = cn23xx_disable_vf_interrupt;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 2a5a949..514250d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -55,6 +55,21 @@ struct liquidio_if_cfg_resp {
 	u64 status;
 };
 
+union tx_info {
+	u64 u64;
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		u16 gso_size;
+		u16 gso_segs;
+		u32 reserved;
+#else
+		u32 reserved;
+		u16 gso_segs;
+		u16 gso_size;
+#endif
+	} s;
+};
+
 #define OCTNIC_MAX_SG  (MAX_SKB_FRAGS)
 
 #define OCTNIC_GSO_MAX_HEADER_SIZE 128
@@ -255,6 +270,19 @@ static void start_txq(struct net_device *netdev)
 }
 
 /**
+ * \brief Stop a queue
+ * @param netdev network device
+ * @param q which queue to stop
+ */
+static inline void stop_q(struct net_device *netdev, int q)
+{
+	if (netif_is_multiqueue(netdev))
+		netif_stop_subqueue(netdev, q);
+	else
+		netif_stop_queue(netdev);
+}
+
+/**
  * Remove the node at the head of the list. The list would be empty at
  * the end of this call if there are no more nodes in the list.
  */
@@ -945,6 +973,45 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 }
 
 /**
+ * \brief Setup input and output queues
+ * @param octeon_dev octeon device
+ * @param ifidx Interface index
+ *
+ * Note: Queues are with respect to the octeon device. Thus
+ * an input queue is for egress packets, and output queues
+ * are for ingress packets.
+ */
+static inline int setup_io_queues(struct octeon_device *octeon_dev, int ifidx)
+{
+	struct net_device *netdev;
+	int num_tx_descs;
+	struct lio *lio;
+	int retval = 0;
+	int q;
+
+	netdev = octeon_dev->props[ifidx].netdev;
+
+	lio = GET_LIO(netdev);
+
+	/* set up IQs. */
+	for (q = 0; q < lio->linfo.num_txpciq; q++) {
+		num_tx_descs = CFG_GET_NUM_TX_DESCS_NIC_IF(
+		    octeon_get_conf(octeon_dev), lio->ifidx);
+		retval = octeon_setup_iq(octeon_dev, ifidx, q,
+					 lio->linfo.txpciq[q], num_tx_descs,
+					 netdev_get_tx_queue(netdev, q));
+		if (retval) {
+			dev_err(&octeon_dev->pci_dev->dev,
+				" %s : Runtime IQ(TxQ) creation failed.\n",
+				__func__);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
+/**
  * \brief Net device open for LiquidIO
  * @param netdev network device
  */
@@ -1180,6 +1247,259 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+/** \brief Transmit networks packets to the Octeon interface
+ * @param skbuff   skbuff struct to be passed to network layer.
+ * @param netdev   pointer to network device
+ * @returns whether the packet was transmitted to the device okay or not
+ *             (NETDEV_TX_OK or NETDEV_TX_BUSY)
+ */
+static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct octnet_buf_free_info *finfo;
+	union octnic_cmd_setup cmdsetup;
+	struct octnic_data_pkt ndata;
+	struct octeon_instr_irh *irh;
+	struct oct_iq_stats *stats;
+	struct octeon_device *oct;
+	int q_idx = 0, iq_no = 0;
+	union tx_info *tx_info;
+	struct lio *lio;
+	int status = 0;
+	u64 dptr = 0;
+	u32 tag = 0;
+	int j;
+
+	lio = GET_LIO(netdev);
+	oct = lio->oct_dev;
+
+	if (netif_is_multiqueue(netdev)) {
+		q_idx = skb->queue_mapping;
+		q_idx = (q_idx % (lio->linfo.num_txpciq));
+		tag = q_idx;
+		iq_no = lio->linfo.txpciq[q_idx].s.q_no;
+	} else {
+		iq_no = lio->txq;
+	}
+
+	stats = &oct->instr_queue[iq_no]->stats;
+
+	/* Check for all conditions in which the current packet cannot be
+	 * transmitted.
+	 */
+	if (!(atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING) ||
+	    (!lio->linfo.link.s.link_up) || (skb->len <= 0)) {
+		netif_info(lio, tx_err, lio->netdev, "Transmit failed link_status : %d\n",
+			   lio->linfo.link.s.link_up);
+		goto lio_xmit_failed;
+	}
+
+	/* Use space in skb->cb to store info used to unmap and
+	 * free the buffers.
+	 */
+	finfo = (struct octnet_buf_free_info *)skb->cb;
+	finfo->lio = lio;
+	finfo->skb = skb;
+	finfo->sc = NULL;
+
+	/* Prepare the attributes for the data to be passed to OSI. */
+	memset(&ndata, 0, sizeof(struct octnic_data_pkt));
+
+	ndata.buf = (void *)finfo;
+
+	ndata.q_no = iq_no;
+
+	if (netif_is_multiqueue(netdev)) {
+		if (octnet_iq_is_full(oct, ndata.q_no)) {
+			/* defer sending if queue is full */
+			netif_info(lio, tx_err, lio->netdev, "Transmit failed iq:%d full\n",
+				   ndata.q_no);
+			stats->tx_iq_busy++;
+			return NETDEV_TX_BUSY;
+		}
+	} else {
+		if (octnet_iq_is_full(oct, lio->txq)) {
+			/* defer sending if queue is full */
+			stats->tx_iq_busy++;
+			netif_info(lio, tx_err, lio->netdev, "Transmit failed iq:%d full\n",
+				   ndata.q_no);
+			return NETDEV_TX_BUSY;
+		}
+	}
+
+	ndata.datasize = skb->len;
+
+	cmdsetup.u64 = 0;
+	cmdsetup.s.iq_no = iq_no;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		cmdsetup.s.transport_csum = 1;
+
+	if (!skb_shinfo(skb)->nr_frags) {
+		cmdsetup.s.u.datasize = skb->len;
+		octnet_prepare_pci_cmd(oct, &ndata.cmd, &cmdsetup, tag);
+		/* Offload checksum calculation for TCP/UDP packets */
+		dptr = dma_map_single(&oct->pci_dev->dev,
+				      skb->data,
+				      skb->len,
+				      DMA_TO_DEVICE);
+		if (dma_mapping_error(&oct->pci_dev->dev, dptr)) {
+			dev_err(&oct->pci_dev->dev, "%s DMA mapping error 1\n",
+				__func__);
+			return NETDEV_TX_BUSY;
+		}
+
+		ndata.cmd.cmd3.dptr = dptr;
+		finfo->dptr = dptr;
+		ndata.reqtype = REQTYPE_NORESP_NET;
+
+	} else {
+		struct skb_frag_struct *frag;
+		struct octnic_gather *g;
+		int i, frags;
+
+		spin_lock(&lio->glist_lock[q_idx]);
+		g = (struct octnic_gather *)list_delete_head(
+		    &lio->glist[q_idx]);
+		spin_unlock(&lio->glist_lock[q_idx]);
+
+		if (!g) {
+			netif_info(lio, tx_err, lio->netdev,
+				   "Transmit scatter gather: glist null!\n");
+			goto lio_xmit_failed;
+		}
+
+		cmdsetup.s.gather = 1;
+		cmdsetup.s.u.gatherptrs = (skb_shinfo(skb)->nr_frags + 1);
+		octnet_prepare_pci_cmd(oct, &ndata.cmd, &cmdsetup, tag);
+
+		memset(g->sg, 0, g->sg_size);
+
+		g->sg[0].ptr[0] = dma_map_single(&oct->pci_dev->dev,
+						 skb->data,
+						 (skb->len - skb->data_len),
+						 DMA_TO_DEVICE);
+		if (dma_mapping_error(&oct->pci_dev->dev, g->sg[0].ptr[0])) {
+			dev_err(&oct->pci_dev->dev, "%s DMA mapping error 2\n",
+				__func__);
+			return NETDEV_TX_BUSY;
+		}
+		add_sg_size(&g->sg[0], (skb->len - skb->data_len), 0);
+
+		frags = skb_shinfo(skb)->nr_frags;
+		i = 1;
+		while (frags--) {
+			frag = &skb_shinfo(skb)->frags[i - 1];
+
+			g->sg[(i >> 2)].ptr[(i & 3)] =
+				dma_map_page(&oct->pci_dev->dev,
+					     frag->page.p,
+					     frag->page_offset,
+					     frag->size,
+					     DMA_TO_DEVICE);
+			if (dma_mapping_error(&oct->pci_dev->dev,
+					      g->sg[i >> 2].ptr[i & 3])) {
+				dma_unmap_single(&oct->pci_dev->dev,
+						 g->sg[0].ptr[0],
+						 skb->len - skb->data_len,
+						 DMA_TO_DEVICE);
+				for (j = 1; j < i; j++) {
+					frag = &skb_shinfo(skb)->frags[j - 1];
+					dma_unmap_page(&oct->pci_dev->dev,
+						       g->sg[j >> 2].ptr[j & 3],
+						       frag->size,
+						       DMA_TO_DEVICE);
+				}
+				dev_err(&oct->pci_dev->dev, "%s DMA mapping error 3\n",
+					__func__);
+				return NETDEV_TX_BUSY;
+			}
+
+			add_sg_size(&g->sg[(i >> 2)], frag->size, (i & 3));
+			i++;
+		}
+
+		dptr = dma_map_single(&oct->pci_dev->dev,
+				      g->sg, g->sg_size,
+				      DMA_TO_DEVICE);
+		if (dma_mapping_error(&oct->pci_dev->dev, dptr)) {
+			dev_err(&oct->pci_dev->dev, "%s DMA mapping error 4\n",
+				__func__);
+			dma_unmap_single(&oct->pci_dev->dev, g->sg[0].ptr[0],
+					 skb->len - skb->data_len,
+					 DMA_TO_DEVICE);
+			for (j = 1; j <= frags; j++) {
+				frag = &skb_shinfo(skb)->frags[j - 1];
+				dma_unmap_page(&oct->pci_dev->dev,
+					       g->sg[j >> 2].ptr[j & 3],
+					       frag->size, DMA_TO_DEVICE);
+			}
+			return NETDEV_TX_BUSY;
+		}
+
+		ndata.cmd.cmd3.dptr = dptr;
+		finfo->dptr = dptr;
+		finfo->g = g;
+
+		ndata.reqtype = REQTYPE_NORESP_NET_SG;
+	}
+
+	irh = (struct octeon_instr_irh *)&ndata.cmd.cmd3.irh;
+	tx_info = (union tx_info *)&ndata.cmd.cmd3.ossp[0];
+
+	if (skb_shinfo(skb)->gso_size) {
+		tx_info->s.gso_size = skb_shinfo(skb)->gso_size;
+		tx_info->s.gso_segs = skb_shinfo(skb)->gso_segs;
+	}
+
+	status = octnet_send_nic_data_pkt(oct, &ndata);
+	if (status == IQ_SEND_FAILED)
+		goto lio_xmit_failed;
+
+	netif_info(lio, tx_queued, lio->netdev, "Transmit queued successfully\n");
+
+	if (status == IQ_SEND_STOP) {
+		dev_err(&oct->pci_dev->dev, "Rcvd IQ_SEND_STOP signal; stopping IQ-%d\n",
+			iq_no);
+		stop_q(lio->netdev, q_idx);
+	}
+
+	netif_trans_update(netdev);
+
+	if (skb_shinfo(skb)->gso_size)
+		stats->tx_done += skb_shinfo(skb)->gso_segs;
+	else
+		stats->tx_done++;
+	stats->tx_tot_bytes += skb->len;
+
+	return NETDEV_TX_OK;
+
+lio_xmit_failed:
+	stats->tx_dropped++;
+	netif_info(lio, tx_err, lio->netdev, "IQ%d Transmit dropped:%llu\n",
+		   iq_no, stats->tx_dropped);
+	if (dptr)
+		dma_unmap_single(&oct->pci_dev->dev, dptr,
+				 ndata.datasize, DMA_TO_DEVICE);
+	tx_buffer_free(skb);
+	return NETDEV_TX_OK;
+}
+
+/** \brief Network device Tx timeout
+ * @param netdev    pointer to network device
+ */
+static void liquidio_tx_timeout(struct net_device *netdev)
+{
+	struct lio *lio;
+
+	lio = GET_LIO(netdev);
+
+	netif_info(lio, tx_err, lio->netdev,
+		   "Transmit timeout tx_dropped:%ld, waking up queues now!!\n",
+		   netdev->stats.tx_dropped);
+	netif_trans_update(netdev);
+	txqs_wake(netdev);
+}
+
 /** Sending command to enable/disable RX checksum offload
  * @param netdev                pointer to network device
  * @param command               OCTNET_CMD_TNL_RX_CSUM_CTL
@@ -1282,8 +1602,10 @@ static int liquidio_set_features(struct net_device *netdev,
 static const struct net_device_ops lionetdevops = {
 	.ndo_open		= liquidio_open,
 	.ndo_stop		= liquidio_stop,
+	.ndo_start_xmit		= liquidio_xmit,
 	.ndo_set_mac_address	= liquidio_set_mac,
 	.ndo_set_rx_mode	= liquidio_set_mcast_list,
+	.ndo_tx_timeout		= liquidio_tx_timeout,
 	.ndo_change_mtu		= liquidio_change_mtu,
 	.ndo_fix_features	= liquidio_fix_features,
 	.ndo_set_features	= liquidio_set_features,
@@ -1507,6 +1829,24 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		/* Copy MAC Address to OS network device structure */
 		ether_addr_copy(netdev->dev_addr, mac);
 
+		if (setup_io_queues(octeon_dev, i)) {
+			dev_err(&octeon_dev->pci_dev->dev, "I/O queues creation failed\n");
+			goto setup_nic_dev_fail;
+		}
+
+		/* For VFs, enable Octeon device interrupts here,
+		 * as this is contingent upon IO queue setup
+		 */
+		octeon_dev->fn_list.enable_interrupt(octeon_dev,
+						     OCTEON_ALL_INTR);
+
+		/* By default all interfaces on a single Octeon uses the same
+		 * tx and rx queues
+		 */
+		lio->txq = lio->linfo.txpciq[0].s.q_no;
+
+		lio->tx_qsize = octeon_get_tx_qsize(octeon_dev, lio->txq);
+
 		if (setup_glists(lio, num_iqueues)) {
 			dev_err(&octeon_dev->pci_dev->dev,
 				"Gather list allocation failed\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index ea2b7e4..3ce6675 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -394,7 +394,7 @@ static inline void __copy_cmd_into_iq(struct octeon_instr_queue *iq,
 		case REQTYPE_SOFT_COMMAND:
 			sc = buf;
 
-			if (OCTEON_CN23XX_PF(oct))
+			if (OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct))
 				irh = (struct octeon_instr_irh *)
 					&sc->cmd.cmd3.irh;
 			else
@@ -607,7 +607,7 @@ static void check_db_timeout(struct work_struct *work)
 
 	oct_cfg = octeon_get_conf(oct);
 
-	if (OCTEON_CN23XX_PF(oct)) {
+	if (OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct)) {
 		ih3 = (struct octeon_instr_ih3 *)&sc->cmd.cmd3.ih3;
 
 		ih3->pkind = oct->instr_queue[sc->iq_no]->txpciq.s.pkind;
@@ -700,7 +700,7 @@ int octeon_send_soft_command(struct octeon_device *oct,
 	struct octeon_instr_irh *irh;
 	u32 len;
 
-	if (OCTEON_CN23XX_PF(oct)) {
+	if (OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct)) {
 		ih3 =  (struct octeon_instr_ih3 *)&sc->cmd.cmd3.ih3;
 		if (ih3->dlengsz) {
 			WARN_ON(!sc->dmadptr);
-- 
1.8.3.1
