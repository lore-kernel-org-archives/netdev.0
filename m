From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 6/7] liquidio CN23XX: VF TX buffers
Date: Tue, 6 Dec 2016 13:06:06 -0800
Message-ID: <1481058367-3937-7-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1481058367-3937-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam01on0089.outbound.protection.outlook.com ([104.47.34.89]:48791
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751212AbcLFVV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 16:21:58 -0500
In-Reply-To: <1481058367-3937-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for freeing VF xmit buffers.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 182 +++++++++++++++++++++
 1 file changed, 182 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index cf80722..ce5cdcd 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -270,6 +270,19 @@ static void start_txq(struct net_device *netdev)
 }
 
 /**
+ * \brief Wake a queue
+ * @param netdev network device
+ * @param q which queue to wake
+ */
+static inline void wake_q(struct net_device *netdev, int q)
+{
+	if (netif_is_multiqueue(netdev))
+		netif_wake_subqueue(netdev, q);
+	else
+		netif_wake_queue(netdev);
+}
+
+/**
  * \brief Stop a queue
  * @param netdev network device
  * @param q which queue to stop
@@ -920,6 +933,163 @@ static int octeon_pci_os_setup(struct octeon_device *oct)
 	return 0;
 }
 
+static inline int skb_iq(struct lio *lio, struct sk_buff *skb)
+{
+	int q = 0;
+
+	if (netif_is_multiqueue(lio->netdev))
+		q = skb->queue_mapping % lio->linfo.num_txpciq;
+
+	return q;
+}
+
+/**
+ * \brief Check Tx queue state for a given network buffer
+ * @param lio per-network private data
+ * @param skb network buffer
+ */
+static inline int check_txq_state(struct lio *lio, struct sk_buff *skb)
+{
+	int q = 0, iq = 0;
+
+	if (netif_is_multiqueue(lio->netdev)) {
+		q = skb->queue_mapping;
+		iq = lio->linfo.txpciq[(q % (lio->linfo.num_txpciq))].s.q_no;
+	} else {
+		iq = lio->txq;
+		q = iq;
+	}
+
+	if (octnet_iq_is_full(lio->oct_dev, iq))
+		return 0;
+
+	if (__netif_subqueue_stopped(lio->netdev, q)) {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq, tx_restart, 1);
+		wake_q(lio->netdev, q);
+	}
+
+	return 1;
+}
+
+/**
+ * \brief Unmap and free network buffer
+ * @param buf buffer
+ */
+static void free_netbuf(void *buf)
+{
+	struct octnet_buf_free_info *finfo;
+	struct sk_buff *skb;
+	struct lio *lio;
+
+	finfo = (struct octnet_buf_free_info *)buf;
+	skb = finfo->skb;
+	lio = finfo->lio;
+
+	dma_unmap_single(&lio->oct_dev->pci_dev->dev, finfo->dptr, skb->len,
+			 DMA_TO_DEVICE);
+
+	check_txq_state(lio, skb);
+
+	tx_buffer_free(skb);
+}
+
+/**
+ * \brief Unmap and free gather buffer
+ * @param buf buffer
+ */
+static void free_netsgbuf(void *buf)
+{
+	struct octnet_buf_free_info *finfo;
+	struct octnic_gather *g;
+	struct sk_buff *skb;
+	int i, frags, iq;
+	struct lio *lio;
+
+	finfo = (struct octnet_buf_free_info *)buf;
+	skb = finfo->skb;
+	lio = finfo->lio;
+	g = finfo->g;
+	frags = skb_shinfo(skb)->nr_frags;
+
+	dma_unmap_single(&lio->oct_dev->pci_dev->dev,
+			 g->sg[0].ptr[0], (skb->len - skb->data_len),
+			 DMA_TO_DEVICE);
+
+	i = 1;
+	while (frags--) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
+
+		pci_unmap_page((lio->oct_dev)->pci_dev,
+			       g->sg[(i >> 2)].ptr[(i & 3)],
+			       frag->size, DMA_TO_DEVICE);
+		i++;
+	}
+
+	dma_unmap_single(&lio->oct_dev->pci_dev->dev,
+			 finfo->dptr, g->sg_size,
+			 DMA_TO_DEVICE);
+
+	iq = skb_iq(lio, skb);
+
+	spin_lock(&lio->glist_lock[iq]);
+	list_add_tail(&g->list, &lio->glist[iq]);
+	spin_unlock(&lio->glist_lock[iq]);
+
+	check_txq_state(lio, skb); /* mq support: sub-queue state check */
+
+	tx_buffer_free(skb);
+}
+
+/**
+ * \brief Unmap and free gather buffer with response
+ * @param buf buffer
+ */
+static void free_netsgbuf_with_resp(void *buf)
+{
+	struct octnet_buf_free_info *finfo;
+	struct octeon_soft_command *sc;
+	struct octnic_gather *g;
+	struct sk_buff *skb;
+	int i, frags, iq;
+	struct lio *lio;
+
+	sc = (struct octeon_soft_command *)buf;
+	skb = (struct sk_buff *)sc->callback_arg;
+	finfo = (struct octnet_buf_free_info *)&skb->cb;
+
+	lio = finfo->lio;
+	g = finfo->g;
+	frags = skb_shinfo(skb)->nr_frags;
+
+	dma_unmap_single(&lio->oct_dev->pci_dev->dev,
+			 g->sg[0].ptr[0], (skb->len - skb->data_len),
+			 DMA_TO_DEVICE);
+
+	i = 1;
+	while (frags--) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
+
+		pci_unmap_page((lio->oct_dev)->pci_dev,
+			       g->sg[(i >> 2)].ptr[(i & 3)],
+			       frag->size, DMA_TO_DEVICE);
+		i++;
+	}
+
+	dma_unmap_single(&lio->oct_dev->pci_dev->dev,
+			 finfo->dptr, g->sg_size,
+			 DMA_TO_DEVICE);
+
+	iq = skb_iq(lio, skb);
+
+	spin_lock(&lio->glist_lock[iq]);
+	list_add_tail(&g->list, &lio->glist[iq]);
+	spin_unlock(&lio->glist_lock[iq]);
+
+	/* Don't free the skb yet */
+
+	check_txq_state(lio, skb);
+}
+
 /**
  * \brief Callback for getting interface configuration
  * @param status status of request
@@ -1675,6 +1845,18 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC, OPCODE_NIC_INFO,
 				    lio_nic_info, octeon_dev);
 
+	/* REQTYPE_RESP_NET and REQTYPE_SOFT_COMMAND do not have free functions.
+	 * They are handled directly.
+	 */
+	octeon_register_reqtype_free_fn(octeon_dev, REQTYPE_NORESP_NET,
+					free_netbuf);
+
+	octeon_register_reqtype_free_fn(octeon_dev, REQTYPE_NORESP_NET_SG,
+					free_netsgbuf);
+
+	octeon_register_reqtype_free_fn(octeon_dev, REQTYPE_RESP_NET_SG,
+					free_netsgbuf_with_resp);
+
 	for (i = 0; i < octeon_dev->ifcount; i++) {
 		resp_size = sizeof(struct liquidio_if_cfg_resp);
 		ctx_size = sizeof(struct liquidio_if_cfg_context);
-- 
1.8.3.1
