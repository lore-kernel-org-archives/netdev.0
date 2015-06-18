From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 11/22] fjes: NAPI polling function
Date: Thu, 18 Jun 2015 09:49:36 +0900
Message-ID: <1434588587-25655-11-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds NAPI polling function and receive related work.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_hw.c   |  46 +++++++++
 drivers/platform/x86/fjes/fjes_hw.h   |   6 ++
 drivers/platform/x86/fjes/fjes_main.c | 179 ++++++++++++++++++++++++++++++++++
 3 files changed, 231 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
index 8be343f..da509bd 100644
--- a/drivers/platform/x86/fjes/fjes_hw.c
+++ b/drivers/platform/x86/fjes/fjes_hw.c
@@ -843,6 +843,52 @@ bool fjes_hw_check_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
 	return ret;
 }
 
+bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *epbh)
+{
+	union ep_buffer_info *info;
+	static bool log_output;
+
+	info = epbh->info;
+
+	if (info->v1i.count_max == 0) {
+		if (false == log_output)
+			log_output = true;
+		return true;
+	}
+	return EP_RING_EMPTY(info->v1i.head, info->v1i.tail,
+			info->v1i.count_max);
+}
+
+void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *epbh,
+	size_t *psize)
+{
+	union ep_buffer_info *info = epbh->info;
+	struct esmem_frame_t *ring_frame;
+	void *frame;
+
+	ring_frame =
+	    (struct esmem_frame_t *)
+		  &(epbh->ring[EP_RING_INDEX(info->v1i.head,
+			info->v1i.count_max) *
+			info->v1i.frame_max]);
+
+	*psize = (size_t) ring_frame->frame_size;
+
+	frame = ring_frame->frame_data;
+
+	return frame;
+}
+
+void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *epbh)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	if (fjes_hw_epbuf_rx_is_empty(epbh))
+		return;
+
+	EP_RING_INDEX_INC(epbh->info->v1i.head, info->v1i.count_max);
+}
+
 int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *epbh,
 		void *frame, size_t size)
 {
diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
index f6fdae5..1ad0fcb 100644
--- a/drivers/platform/x86/fjes/fjes_hw.h
+++ b/drivers/platform/x86/fjes/fjes_hw.h
@@ -68,6 +68,8 @@ struct fjes_hw;
 	((_num) = EP_RING_INDEX((_num) + 1, (_max)))
 #define EP_RING_FULL(_head, _tail, _max)				\
 	(0 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
+#define EP_RING_EMPTY(_head, _tail, _max) \
+	(1 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
 
 #define FJES_MTU_TO_BUFFER_SIZE(mtu) \
 	(ETH_HLEN + VLAN_HLEN + (mtu) + ETH_FCS_LEN)
@@ -323,6 +325,10 @@ int fjes_hw_epid_is_shared(struct fjes_device_shared_info *, int);
 bool fjes_hw_check_epbuf_version(struct epbuf_handler *, u32);
 bool fjes_hw_check_mtu(struct epbuf_handler *, u32);
 bool fjes_hw_check_vlan_id(struct epbuf_handler *, u16);
+bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *);
+void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *,
+		size_t *);
+void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *);
 int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *, void *, size_t);
 
 #endif /* FJES_HW_H_ */
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index a2dddb2..97bf487 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -68,6 +68,9 @@ static int fjes_remove(struct platform_device *);
 static int fjes_sw_init(struct fjes_adapter *);
 static void fjes_netdev_setup(struct net_device *);
 
+static void fjes_rx_irq(struct fjes_adapter *, int);
+static int fjes_poll(struct napi_struct *, int);
+
 
 static const struct acpi_device_id fjes_acpi_ids[] = {
 	{"PNP0C02", 0},
@@ -241,6 +244,8 @@ static int fjes_open(struct net_device *netdev)
 	hw->txrx_stop_req_bit = 0;
 	hw->epstop_req_bit = 0;
 
+	napi_enable(&adapter->napi);
+
 	fjes_hw_capture_interrupt_status(hw);
 
 	result = fjes_request_irq(adapter);
@@ -256,6 +261,7 @@ static int fjes_open(struct net_device *netdev)
 
 err_req_irq:
 	fjes_free_irq(adapter);
+	napi_disable(&adapter->napi);
 
 err_setup_res:
 	fjes_free_resources(adapter);
@@ -277,6 +283,8 @@ static int fjes_close(struct net_device *netdev)
 
 	fjes_hw_raise_epstop(hw);
 
+	napi_disable(&adapter->napi);
+
 	for (epidx = 0; epidx < hw->max_epid; epidx++) {
 		if (epidx == hw->my_epid)
 			continue;
@@ -736,6 +744,10 @@ static irqreturn_t fjes_intr(int irq, void *data)
 	icr = fjes_hw_capture_interrupt_status(hw);
 
 	if (icr & REG_IS_MASK_IS_ASSERT) {
+
+		if (icr & REG_ICTL_MASK_RX_DATA)
+			fjes_rx_irq(adapter, icr & REG_IS_MASK_EPID);
+
 		ret = IRQ_HANDLED;
 	} else
 		ret = IRQ_NONE;
@@ -743,6 +755,167 @@ static irqreturn_t fjes_intr(int irq, void *data)
 	return ret;
 }
 
+static int fjes_rxframe_search_exist(struct fjes_adapter *adapter, int start_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	int cur_epid;
+	int max_epid;
+	int i;
+	enum ep_partner_status pstatus;
+
+	max_epid = hw->max_epid;
+	start_epid = (start_epid + 1 + max_epid) % max_epid;
+
+	for (i = 0; i < max_epid; i++) {
+		cur_epid = (start_epid + i) % max_epid;
+		if (cur_epid == hw->my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, cur_epid);
+		if (pstatus == EP_PARTNER_SHARED) {
+
+			if (!fjes_hw_epbuf_rx_is_empty(&hw->ep_shm_info[cur_epid].rx))
+				return cur_epid;
+
+		}
+
+	}
+	return -1;
+}
+
+static void *fjes_rxframe_get(struct fjes_adapter *adapter, size_t *psize,
+		int *cur_epid)
+{
+	void *frameBuf;
+
+	*cur_epid = fjes_rxframe_search_exist(adapter, *cur_epid);
+	if (*cur_epid < 0)
+		return NULL;
+
+	frameBuf =
+	    fjes_hw_epbuf_rx_curpkt_get_addr(&
+					   (adapter->hw.
+					    ep_shm_info[*cur_epid].rx), psize);
+
+	return frameBuf;
+}
+
+static void fjes_rxframe_release(struct fjes_adapter *adapter,
+		int cur_epid)
+{
+	fjes_hw_epbuf_rx_curpkt_drop(&(adapter->hw.ep_shm_info[cur_epid].rx));
+}
+
+static void fjes_rx_irq(struct fjes_adapter *adapter, int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_RX_DATA, true);
+
+	adapter->unset_rx_last = true;
+	napi_schedule(&adapter->napi);
+
+}
+
+static int fjes_poll(struct napi_struct *napi, int budget)
+{
+
+	struct fjes_adapter *adapter =
+			container_of(napi, struct fjes_adapter, napi);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = napi->dev;
+	int work_done = 0;
+	struct sk_buff *skb;
+	void *frameData;
+	size_t frameLen;
+	int cur_epid = 0;
+	int epidx = 0;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status |=
+			FJES_RX_POLL_WORK;
+	}
+
+	while (work_done < budget) {
+
+		prefetch(&adapter->hw);
+		frameData = fjes_rxframe_get(adapter, &frameLen, &cur_epid);
+
+		if (frameData) {
+
+			skb = napi_alloc_skb(napi, frameLen);
+			if (!skb) {
+
+				adapter->stats64.rx_dropped += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_dropped += 1;
+				adapter->stats64.rx_errors += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_errors += 1;
+
+			} else {
+
+				memcpy(skb_put(skb, frameLen), frameData,
+					frameLen);
+				skb->protocol = eth_type_trans(skb, netdev);
+				skb->ip_summed = CHECKSUM_UNNECESSARY;	/* don't check it */
+
+				netif_receive_skb(skb);
+
+				work_done++;
+
+				adapter->stats64.rx_packets += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_packets += 1;
+				adapter->stats64.rx_bytes += frameLen;
+				hw->ep_shm_info[cur_epid].net_stats.rx_bytes += frameLen;
+
+
+				if (is_multicast_ether_addr
+					(((struct ethhdr *)frameData)->h_dest)) {
+
+					adapter->stats64.multicast += 1;
+					hw->ep_shm_info[cur_epid].net_stats.multicast += 1;
+
+				}
+
+			}
+
+			fjes_rxframe_release(adapter, cur_epid);
+			adapter->unset_rx_last = true;
+		} else {
+			break;
+		}
+	}
+
+	if (work_done < budget) {
+
+		napi_complete(napi);
+
+		if (adapter->unset_rx_last) {
+			adapter->rx_last_jiffies = jiffies;
+			adapter->unset_rx_last = false;
+		}
+
+		if (((long)jiffies - (long)adapter->rx_last_jiffies) < 3)
+			napi_reschedule(napi);
+		else {
+
+			for (epidx = 0; epidx < hw->max_epid; epidx++) {
+				if (epidx == hw->my_epid)
+					continue;
+				adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status &=
+						~FJES_RX_POLL_WORK;
+			}
+
+			fjes_hw_set_irqmask(hw, REG_ICTL_MASK_RX_DATA, false);
+		}
+	}
+
+	return work_done;
+}
+
+
 /*
  *  fjes_probe - Device Initialization Routine
  *
@@ -837,6 +1010,8 @@ static int fjes_remove(struct platform_device *plat_dev)
 
 	fjes_hw_exit(hw);
 
+	netif_napi_del(&adapter->napi);
+
 	free_netdev(netdev);
 
 	return 0;
@@ -844,6 +1019,10 @@ static int fjes_remove(struct platform_device *plat_dev)
 
 static int fjes_sw_init(struct fjes_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
+
+	netif_napi_add(netdev, &adapter->napi, fjes_poll, 64);
+
 	return 0;
 }
 
-- 
1.8.3.1
