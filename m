From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v4 13/21] qlcnic: 83xx data path routines
Date: Mon, 29 Oct 2012 20:14:44 -0400
Message-ID: <1351556092-16417-14-git-send-email-sony.chacko@qlogic.com>
References: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:63111 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755869Ab2J3AeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 20:34:12 -0400
In-Reply-To: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

83xx adapter data path routines

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    7 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    5 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   18 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |  455 +++++++++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    1 +
 5 files changed, 481 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index edd050c..f03f494 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1547,7 +1547,6 @@ int qlcnic_is_valid_nic_func(struct qlcnic_adapter *, u8);
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, u8, u8, u8);
 int qlcnic_get_mac_stats(struct qlcnic_adapter *, struct qlcnic_mac_statistics *);
 void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd);
-void qlcnic_napi_del(struct qlcnic_adapter *);
 int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *, int);
 void qlcnic_free_sds_rings(struct qlcnic_recv_context *);
 void qlcnic_advert_link_change(struct qlcnic_adapter *, int);
@@ -1584,6 +1583,7 @@ struct qlcnic_nic_template {
 	void (*request_reset) (struct qlcnic_adapter *, u32);
 	void (*cancel_idc_work) (struct qlcnic_adapter *);
 	int (*napi_add)(struct qlcnic_adapter *, struct net_device *);
+	void (*napi_del)(struct qlcnic_adapter *);
 	void (*config_ipaddr)(struct qlcnic_adapter *, __be32, int);
 	irqreturn_t (*clear_legacy_intr)(struct qlcnic_adapter *);
 };
@@ -1759,6 +1759,11 @@ static inline int qlcnic_napi_add(struct qlcnic_adapter *adapter,
 	return adapter->nic_ops->napi_add(adapter, netdev);
 }
 
+static inline void qlcnic_napi_del(struct qlcnic_adapter *adapter)
+{
+	adapter->nic_ops->napi_del(adapter);
+}
+
 static inline void qlcnic_napi_enable(struct qlcnic_adapter *adapter)
 {
 	adapter->ahw->hw_ops->napi_enable(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 2f29dbb..3829849 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -146,6 +146,7 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.get_func_no			= qlcnic_83xx_get_func_no,
 	.api_lock			= qlcnic_83xx_cam_lock,
 	.api_unlock			= qlcnic_83xx_cam_unlock,
+	.process_lb_rcv_ring_diag	= qlcnic_83xx_process_rcv_ring_diag,
 	.create_rx_ctx			= qlcnic_83xx_create_rx_ctx,
 	.create_tx_ctx			= qlcnic_83xx_create_tx_ctx,
 	.setup_link_event		= qlcnic_83xx_setup_link_event,
@@ -153,6 +154,8 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.get_pci_info			= qlcnic_83xx_get_pci_info,
 	.set_nic_info			= qlcnic_83xx_set_nic_info,
 	.change_macvlan			= qlcnic_83xx_sre_macaddr_change,
+	.napi_enable			= qlcnic_83xx_napi_enable,
+	.napi_disable			= qlcnic_83xx_napi_disable,
 	.config_intr_coal		= qlcnic_83xx_config_intr_coal,
 	.config_rss			= qlcnic_83xx_config_rss,
 	.config_hw_lro			= qlcnic_83xx_config_hw_lro,
@@ -166,6 +169,8 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 static struct qlcnic_nic_template qlcnic_83xx_ops = {
 	.config_bridged_mode	= qlcnic_config_bridged_mode,
 	.config_led		= qlcnic_config_led,
+	.napi_add		= qlcnic_83xx_napi_add,
+	.napi_del		= qlcnic_83xx_napi_del,
 	.config_ipaddr		= qlcnic_83xx_config_ipaddr,
 	.clear_legacy_intr	= qlcnic_83xx_clear_legacy_intr,
 };
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 1112042..4396903 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -50,6 +50,20 @@
 #define QLCNIC_HOST_83XX_RDS_MODE_UNIQUE	0
 #define QLCNIC_HOST_SDS_MBX_IDX			8
 
+#define qlcnic_83xx_pktln(sts)		((sts >> 32) & 0x3FFF)
+#define qlcnic_83xx_hndl(sts)		((sts >> 48) & 0x7FFF)
+#define qlcnic_83xx_csum_status(sts)	((sts >> 39) & 7)
+#define qlcnic_83xx_opcode(sts)	((sts >> 42) & 0xF)
+#define qlcnic_83xx_vlan_tag(sts)	(((sts) >> 48) & 0xFFFF)
+#define qlcnic_83xx_lro_pktln(sts)	(((sts) >> 32) & 0x3FFF)
+#define qlcnic_83xx_l2_hdr_off(sts)	(((sts) >> 16) & 0xFF)
+#define qlcnic_83xx_l4_hdr_off(sts)	(((sts) >> 24) & 0xFF)
+#define qlcnic_83xx_pkt_cnt(sts)	(((sts) >> 16) & 0x7)
+#define qlcnic_83xx_is_tstamp(sts)	(((sts) >> 40) & 1)
+#define qlcnic_83xx_is_psh_bit(sts)	(((sts) >> 41) & 1)
+#define qlcnic_83xx_is_ip_align(sts)	(((sts) >> 46) & 1)
+#define qlcnic_83xx_has_vlan_tag(sts)	(((sts) >> 47) & 1)
+
 /* status descriptor mailbox data
  * @phy_addr: physical address of buffer
  * @sds_ring_size: buffer size
@@ -299,6 +313,10 @@ int qlcnic_83xx_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info *);
 int qlcnic_83xx_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
 void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *, int);
 
+int qlcnic_83xx_napi_add(struct qlcnic_adapter *, struct net_device *);
+void qlcnic_83xx_napi_del(struct qlcnic_adapter *);
+void qlcnic_83xx_napi_enable(struct qlcnic_adapter *);
+void qlcnic_83xx_napi_disable(struct qlcnic_adapter *);
 void qlcnic_ind_wr(struct qlcnic_adapter *, u32, u32);
 int qlcnic_ind_rd(struct qlcnic_adapter *, u32);
 void qlcnic_83xx_get_stats(struct qlcnic_adapter *,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 5af2b96..274ac1b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -5,6 +5,7 @@
 
 #include "qlcnic.h"
 
+#define QLCNIC_TX_POLL_BUDGET		128
 #define QLCNIC_TCP_HDR_SIZE		20
 #define QLCNIC_TCP_TS_OPTION_SIZE	12
 #define QLCNIC_FETCH_RING_ID(handle)	((handle) >> 63)
@@ -977,9 +978,9 @@ void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 	}
 }
 
-void qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
-				 struct qlcnic_host_rds_ring *rds_ring,
-				 u8 ring_id)
+static void qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
+					struct qlcnic_host_rds_ring *rds_ring,
+					u8 ring_id)
 {
 	struct rcv_desc *pdesc;
 	struct qlcnic_rx_buffer *buffer;
@@ -1145,7 +1146,7 @@ int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-void qlcnic_napi_del(struct qlcnic_adapter *adapter)
+void qlcnic_82xx_napi_del(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -1192,3 +1193,449 @@ void qlcnic_82xx_napi_disable(struct qlcnic_adapter *adapter)
 		napi_disable(&sds_ring->napi);
 	}
 }
+
+static struct qlcnic_rx_buffer *
+qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
+			struct qlcnic_host_sds_ring *sds_ring,
+			u8 ring, u64 sts_data[])
+{
+	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_rx_buffer *buffer;
+	struct sk_buff *skb;
+	struct qlcnic_host_rds_ring *rds_ring;
+	int index, length, cksum;
+	u16 vid = 0xffff;
+
+	if (unlikely(ring >= adapter->max_rds_rings))
+		return NULL;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+
+	index = qlcnic_83xx_hndl(sts_data[0]);
+	if (unlikely(index >= rds_ring->num_desc))
+		return NULL;
+
+	buffer = &rds_ring->rx_buf_arr[index];
+	length = qlcnic_83xx_pktln(sts_data[0]);
+	cksum  = qlcnic_83xx_csum_status(sts_data[1]);
+	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, cksum);
+	if (!skb)
+		return buffer;
+
+	if (length > rds_ring->skb_size)
+		skb_put(skb, rds_ring->skb_size);
+	else
+		skb_put(skb, length);
+
+	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
+		adapter->stats.rxdropped++;
+		dev_kfree_skb(skb);
+		return buffer;
+	}
+
+	skb->protocol = eth_type_trans(skb, netdev);
+
+	if (vid != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vid);
+
+	napi_gro_receive(&sds_ring->napi, skb);
+
+	adapter->stats.rx_pkts++;
+	adapter->stats.rxbytes += length;
+
+	return buffer;
+}
+
+static struct qlcnic_rx_buffer *
+qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
+			struct qlcnic_host_sds_ring *sds_ring,
+			u8 ring, u64 sts_data[])
+{
+	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_rx_buffer *buffer;
+	struct sk_buff *skb;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
+	struct tcphdr *th;
+	bool push;
+	int l2_hdr_offset, l4_hdr_offset;
+	int index;
+	u16 lro_length, length, data_offset;
+	u16 vid = 0xffff;
+
+	if (unlikely(ring > adapter->max_rds_rings))
+		return NULL;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+
+	index = qlcnic_83xx_hndl(sts_data[0]);
+	if (unlikely(index > rds_ring->num_desc))
+		return NULL;
+
+	buffer = &rds_ring->rx_buf_arr[index];
+
+	lro_length = qlcnic_83xx_lro_pktln(sts_data[0]);
+	l2_hdr_offset = qlcnic_83xx_l2_hdr_off(sts_data[1]);
+	l4_hdr_offset = qlcnic_83xx_l4_hdr_off(sts_data[1]);
+	push = qlcnic_83xx_is_psh_bit(sts_data[1]);
+
+	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, STATUS_CKSUM_OK);
+	if (!skb)
+		return buffer;
+	if (qlcnic_83xx_is_tstamp(sts_data[1]))
+		data_offset = l4_hdr_offset + QLCNIC_TCP_TS_HDR_SIZE;
+	else
+		data_offset = l4_hdr_offset + QLCNIC_TCP_HDR_SIZE;
+
+	skb_put(skb, lro_length + data_offset);
+	skb_pull(skb, l2_hdr_offset);
+
+	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
+		adapter->stats.rxdropped++;
+		dev_kfree_skb(skb);
+		return buffer;
+	}
+
+	skb->protocol = eth_type_trans(skb, netdev);
+	if (htons(skb->protocol) == ETH_P_IPV6) {
+		ipv6h = (struct ipv6hdr *)skb->data;
+		th = (struct tcphdr *)(skb->data + sizeof(struct ipv6hdr));
+
+		length = (th->doff << 2) + lro_length;
+		ipv6h->payload_len = htons(length);
+	} else {
+		iph = (struct iphdr *)skb->data;
+		th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
+		length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
+		iph->tot_len = htons(length);
+		iph->check = 0;
+		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+	}
+
+	th->psh = push;
+	length = skb->len;
+
+	if (vid != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vid);
+
+	netif_receive_skb(skb);
+
+	adapter->stats.lro_pkts++;
+	adapter->stats.lrobytes += length;
+	return buffer;
+}
+
+static int qlcnic_83xx_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring,
+					int max)
+{
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+	struct list_head *cur;
+	struct status_desc *desc;
+	struct qlcnic_rx_buffer *rxbuf = NULL;
+	u8 ring;
+	u64 sts_data[2];
+	int count = 0, opcode;
+	u32 consumer = sds_ring->consumer;
+
+	while (count < max) {
+		desc = &sds_ring->desc_head[consumer];
+		sts_data[1] = le64_to_cpu(desc->status_desc_data[1]);
+		opcode = qlcnic_83xx_opcode(sts_data[1]);
+		if (!opcode)
+			break;
+		sts_data[0] = le64_to_cpu(desc->status_desc_data[0]);
+		ring = QLCNIC_FETCH_RING_ID(sts_data[0]);
+
+		switch (opcode) {
+		case QLC_83XX_REG_DESC:
+			rxbuf = qlcnic_83xx_process_rcv(adapter, sds_ring,
+							ring, sts_data);
+			break;
+		case QLC_83XX_LRO_DESC:
+			rxbuf = qlcnic_83xx_process_lro(adapter, sds_ring,
+							ring, sts_data);
+			break;
+		default:
+			dev_info(&adapter->pdev->dev,
+				 "Unkonwn opcode: 0x%x\n", opcode);
+			goto skip;
+		}
+
+		if (likely(rxbuf))
+			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
+		else
+			adapter->stats.null_rxbuf++;
+skip:
+		desc = &sds_ring->desc_head[consumer];
+		/* Reset the descriptor */
+		desc->status_desc_data[1] = 0;
+		consumer = get_next_index(consumer, sds_ring->num_desc);
+		count++;
+	}
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &adapter->recv_ctx->rds_rings[ring];
+		if (!list_empty(&sds_ring->free_list[ring])) {
+			list_for_each(cur, &sds_ring->free_list[ring]) {
+				rxbuf = list_entry(cur, struct qlcnic_rx_buffer,
+						   list);
+				qlcnic_alloc_rx_skb(adapter, rds_ring, rxbuf);
+			}
+			spin_lock(&rds_ring->lock);
+			list_splice_tail_init(&sds_ring->free_list[ring],
+					      &rds_ring->free_list);
+			spin_unlock(&rds_ring->lock);
+		}
+		qlcnic_post_rx_buffers_nodb(adapter, rds_ring, ring);
+	}
+	if (count) {
+		sds_ring->consumer = consumer;
+		writel(consumer, sds_ring->crb_sts_consumer);
+	}
+	return count;
+}
+
+static int qlcnic_83xx_poll(struct napi_struct *napi, int budget)
+{
+	int tx_complete;
+	int work_done;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_adapter *adapter;
+	struct qlcnic_host_tx_ring *tx_ring;
+
+	sds_ring = container_of(napi, struct qlcnic_host_sds_ring, napi);
+	adapter = sds_ring->adapter;
+	/* tx ring count = 1 */
+	tx_ring = adapter->tx_ring;
+
+	if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
+		qlcnic_83xx_process_aen(adapter);
+
+	tx_complete = qlcnic_process_cmd_ring(adapter, tx_ring, budget);
+	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
+	if ((work_done < budget) && tx_complete) {
+		napi_complete(&sds_ring->napi);
+		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
+			qlcnic_83xx_enable_intr(adapter, sds_ring);
+	}
+
+	return work_done;
+}
+
+static int qlcnic_83xx_msix_tx_poll(struct napi_struct *napi, int budget)
+{
+	int work_done;
+	struct qlcnic_host_tx_ring *tx_ring;
+	struct qlcnic_adapter *adapter;
+
+	tx_ring = container_of(napi, struct qlcnic_host_tx_ring, napi);
+	adapter = tx_ring->adapter;
+	work_done = qlcnic_process_cmd_ring(adapter, tx_ring,
+					    QLCNIC_TX_POLL_BUDGET);
+	if (work_done) {
+		napi_complete(&tx_ring->napi);
+		if (test_bit(__QLCNIC_DEV_UP , &adapter->state))
+			qlcnic_83xx_enable_tx_intr(adapter, tx_ring);
+	}
+
+	return work_done;
+}
+
+static int qlcnic_83xx_rx_poll(struct napi_struct *napi, int budget)
+{
+	int work_done;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_adapter *adapter;
+
+	sds_ring = container_of(napi, struct qlcnic_host_sds_ring, napi);
+	adapter = sds_ring->adapter;
+	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
+	if (work_done < budget) {
+		napi_complete(&sds_ring->napi);
+		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
+			qlcnic_83xx_enable_intr(adapter, sds_ring);
+	}
+
+	return work_done;
+}
+
+void qlcnic_83xx_napi_enable(struct qlcnic_adapter *adapter)
+{
+	int ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+
+	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+		return;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		napi_enable(&sds_ring->napi);
+		qlcnic_83xx_enable_intr(adapter, sds_ring);
+	}
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			napi_enable(&tx_ring->napi);
+			qlcnic_83xx_enable_tx_intr(adapter, tx_ring);
+		}
+	}
+}
+
+void qlcnic_83xx_napi_disable(struct qlcnic_adapter *adapter)
+{
+	int ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_host_tx_ring *tx_ring;
+
+	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+		return;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		writel(1, sds_ring->crb_intr_mask);
+		napi_synchronize(&sds_ring->napi);
+		napi_disable(&sds_ring->napi);
+	}
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			qlcnic_83xx_disable_tx_intr(adapter, tx_ring);
+			napi_synchronize(&tx_ring->napi);
+			napi_disable(&tx_ring->napi);
+		}
+	}
+}
+
+int qlcnic_83xx_napi_add(struct qlcnic_adapter *adapter,
+			 struct net_device *netdev)
+{
+	int ring, max_sds_rings;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+
+	if (qlcnic_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
+		return -ENOMEM;
+
+	max_sds_rings = adapter->max_sds_rings;
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			netif_napi_add(netdev, &sds_ring->napi,
+				       qlcnic_83xx_rx_poll,
+				       QLCNIC_NETDEV_WEIGHT * 2);
+		else
+			netif_napi_add(netdev, &sds_ring->napi,
+				       qlcnic_83xx_poll,
+				       QLCNIC_NETDEV_WEIGHT / max_sds_rings);
+	}
+
+	if (qlcnic_alloc_tx_rings(adapter, netdev)) {
+		qlcnic_free_sds_rings(recv_ctx);
+		return -ENOMEM;
+	}
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			netif_napi_add(netdev, &tx_ring->napi,
+				       qlcnic_83xx_msix_tx_poll,
+				       QLCNIC_NETDEV_WEIGHT);
+		}
+	}
+
+	return 0;
+}
+
+void qlcnic_83xx_napi_del(struct qlcnic_adapter *adapter)
+{
+	int ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_host_tx_ring *tx_ring;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		netif_napi_del(&sds_ring->napi);
+	}
+
+	qlcnic_free_sds_rings(adapter->recv_ctx);
+
+	if ((adapter->flags & QLCNIC_MSIX_ENABLED)) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			netif_napi_del(&tx_ring->napi);
+		}
+	}
+
+	qlcnic_free_tx_rings(adapter);
+}
+
+void qlcnic_83xx_process_rcv_diag(struct qlcnic_adapter *adapter,
+				  struct qlcnic_host_sds_ring *sds_ring,
+				  int ring, u64 sts_data[])
+{
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct sk_buff *skb;
+	struct qlcnic_host_rds_ring *rds_ring;
+	int index, length, cksum;
+
+	if (unlikely(ring >= adapter->max_rds_rings))
+		return;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+	index = qlcnic_83xx_hndl(sts_data[0]);
+	if (unlikely(index >= rds_ring->num_desc))
+		return;
+
+	length = qlcnic_83xx_pktln(sts_data[0]);
+	cksum = qlcnic_83xx_csum_status(sts_data[0]);
+	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, STATUS_CKSUM_OK);
+	if (!skb)
+		return;
+
+	if (length > rds_ring->skb_size)
+		skb_put(skb, rds_ring->skb_size);
+	else
+		skb_put(skb, length);
+
+	if (!qlcnic_check_loopback_buff(skb->data, adapter->mac_addr))
+		adapter->ahw->diag_cnt++;
+	else
+		dump_skb(skb, adapter);
+
+	dev_kfree_skb_any(skb);
+	return;
+}
+
+void qlcnic_83xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
+{
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+	struct status_desc *desc;
+	u64 sts_data[2];
+	int ring, opcode;
+	u32 consumer = sds_ring->consumer;
+
+	desc = &sds_ring->desc_head[consumer];
+	sts_data[0] = le64_to_cpu(desc->status_desc_data[0]);
+	sts_data[1] = le64_to_cpu(desc->status_desc_data[1]);
+	opcode = qlcnic_83xx_opcode(sts_data[1]);
+	if (!opcode)
+		return;
+
+	ring = QLCNIC_FETCH_RING_ID(qlcnic_83xx_hndl(sts_data[0]));
+	qlcnic_83xx_process_rcv_diag(adapter, sds_ring, ring, sts_data);
+	desc = &sds_ring->desc_head[consumer];
+	desc->status_desc_data[0] = cpu_to_le64(STATUS_OWNER_PHANTOM);
+	consumer = get_next_index(consumer, sds_ring->num_desc);
+	sds_ring->consumer = consumer;
+	writel(consumer, sds_ring->crb_sts_consumer);
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 03b0e11..a05276a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -315,6 +315,7 @@ static struct qlcnic_nic_template qlcnic_ops = {
 	.request_reset		= qlcnic_82xx_dev_request_reset,
 	.cancel_idc_work	= qlcnic_82xx_cancel_idc_work,
 	.napi_add		= qlcnic_82xx_napi_add,
+	.napi_del		= qlcnic_82xx_napi_del,
 	.config_ipaddr		= qlcnic_82xx_config_ipaddr,
 	.clear_legacy_intr	= qlcnic_82xx_clear_legacy_intr,
 };
-- 
1.7.1
