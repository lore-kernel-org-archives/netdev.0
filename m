From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 11/22] fjes: NAPI polling function
Date: Fri, 21 Aug 2015 17:29:27 +0900
Message-ID: <1440145778-15941-11-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym01.jp.fujitsu.com ([211.128.242.40]:58834 "EHLO
	mgwym01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbbHUIfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 04:35:05 -0400
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds NAPI polling function and receive related work.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c   |  40 ++++++++++
 drivers/net/fjes/fjes_hw.h   |   5 ++
 drivers/net/fjes/fjes_main.c | 171 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 214 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 487dbc6..3c96d06 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -825,6 +825,46 @@ bool fjes_hw_check_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
 	return ret;
 }
 
+bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *epbh)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	if (info->v1i.count_max == 0)
+		return true;
+
+	return EP_RING_EMPTY(info->v1i.head, info->v1i.tail,
+			     info->v1i.count_max);
+}
+
+void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *epbh,
+				       size_t *psize)
+{
+	union ep_buffer_info *info = epbh->info;
+	struct esmem_frame *ring_frame;
+	void *frame;
+
+	ring_frame = (struct esmem_frame *)&(epbh->ring[EP_RING_INDEX
+					     (info->v1i.head,
+					      info->v1i.count_max) *
+					     info->v1i.frame_max]);
+
+	*psize = (size_t)ring_frame->frame_size;
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
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 07e1226..3511db2 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -69,6 +69,8 @@ struct fjes_hw;
 	((_num) = EP_RING_INDEX((_num) + 1, (_max)))
 #define EP_RING_FULL(_head, _tail, _max)				\
 	(0 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
+#define EP_RING_EMPTY(_head, _tail, _max) \
+	(1 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
 
 #define FJES_MTU_TO_BUFFER_SIZE(mtu) \
 	(ETH_HLEN + VLAN_HLEN + (mtu) + ETH_FCS_LEN)
@@ -320,6 +322,9 @@ int fjes_hw_epid_is_shared(struct fjes_device_shared_info *, int);
 bool fjes_hw_check_epbuf_version(struct epbuf_handler *, u32);
 bool fjes_hw_check_mtu(struct epbuf_handler *, u32);
 bool fjes_hw_check_vlan_id(struct epbuf_handler *, u16);
+bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *);
+void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *, size_t *);
+void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *);
 int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *, void *, size_t);
 
 #endif /* FJES_HW_H_ */
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index ac1e076..6194962 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -66,6 +66,9 @@ static int fjes_remove(struct platform_device *);
 static int fjes_sw_init(struct fjes_adapter *);
 static void fjes_netdev_setup(struct net_device *);
 
+static void fjes_rx_irq(struct fjes_adapter *, int);
+static int fjes_poll(struct napi_struct *, int);
+
 static const struct acpi_device_id fjes_acpi_ids[] = {
 	{"PNP0C02", 0},
 	{"", 0},
@@ -235,6 +238,8 @@ static int fjes_open(struct net_device *netdev)
 	hw->txrx_stop_req_bit = 0;
 	hw->epstop_req_bit = 0;
 
+	napi_enable(&adapter->napi);
+
 	fjes_hw_capture_interrupt_status(hw);
 
 	result = fjes_request_irq(adapter);
@@ -250,6 +255,7 @@ static int fjes_open(struct net_device *netdev)
 
 err_req_irq:
 	fjes_free_irq(adapter);
+	napi_disable(&adapter->napi);
 
 err_setup_res:
 	fjes_free_resources(adapter);
@@ -268,6 +274,8 @@ static int fjes_close(struct net_device *netdev)
 
 	fjes_hw_raise_epstop(hw);
 
+	napi_disable(&adapter->napi);
+
 	for (epidx = 0; epidx < hw->max_epid; epidx++) {
 		if (epidx == hw->my_epid)
 			continue;
@@ -701,14 +709,167 @@ static irqreturn_t fjes_intr(int irq, void *data)
 
 	icr = fjes_hw_capture_interrupt_status(hw);
 
-	if (icr & REG_IS_MASK_IS_ASSERT)
+	if (icr & REG_IS_MASK_IS_ASSERT) {
+		if (icr & REG_ICTL_MASK_RX_DATA)
+			fjes_rx_irq(adapter, icr & REG_IS_MASK_EPID);
+
 		ret = IRQ_HANDLED;
-	else
+	} else {
 		ret = IRQ_NONE;
+	}
 
 	return ret;
 }
 
+static int fjes_rxframe_search_exist(struct fjes_adapter *adapter,
+				     int start_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status pstatus;
+	int max_epid, cur_epid;
+	int i;
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
+			if (!fjes_hw_epbuf_rx_is_empty(
+				&hw->ep_shm_info[cur_epid].rx))
+				return cur_epid;
+		}
+	}
+	return -1;
+}
+
+static void *fjes_rxframe_get(struct fjes_adapter *adapter, size_t *psize,
+			      int *cur_epid)
+{
+	void *frame;
+
+	*cur_epid = fjes_rxframe_search_exist(adapter, *cur_epid);
+	if (*cur_epid < 0)
+		return NULL;
+
+	frame =
+	fjes_hw_epbuf_rx_curpkt_get_addr(
+		&adapter->hw.ep_shm_info[*cur_epid].rx, psize);
+
+	return frame;
+}
+
+static void fjes_rxframe_release(struct fjes_adapter *adapter, int cur_epid)
+{
+	fjes_hw_epbuf_rx_curpkt_drop(&adapter->hw.ep_shm_info[cur_epid].rx);
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
+}
+
+static int fjes_poll(struct napi_struct *napi, int budget)
+{
+	struct fjes_adapter *adapter =
+			container_of(napi, struct fjes_adapter, napi);
+	struct net_device *netdev = napi->dev;
+	struct fjes_hw *hw = &adapter->hw;
+	struct sk_buff *skb;
+	int work_done = 0;
+	int cur_epid = 0;
+	int epidx;
+	size_t frame_len;
+	void *frame;
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
+		prefetch(&adapter->hw);
+		frame = fjes_rxframe_get(adapter, &frame_len, &cur_epid);
+
+		if (frame) {
+			skb = napi_alloc_skb(napi, frame_len);
+			if (!skb) {
+				adapter->stats64.rx_dropped += 1;
+				hw->ep_shm_info[cur_epid].net_stats
+							 .rx_dropped += 1;
+				adapter->stats64.rx_errors += 1;
+				hw->ep_shm_info[cur_epid].net_stats
+							 .rx_errors += 1;
+			} else {
+				memcpy(skb_put(skb, frame_len),
+				       frame, frame_len);
+				skb->protocol = eth_type_trans(skb, netdev);
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+				netif_receive_skb(skb);
+
+				work_done++;
+
+				adapter->stats64.rx_packets += 1;
+				hw->ep_shm_info[cur_epid].net_stats
+							 .rx_packets += 1;
+				adapter->stats64.rx_bytes += frame_len;
+				hw->ep_shm_info[cur_epid].net_stats
+							 .rx_bytes += frame_len;
+
+				if (is_multicast_ether_addr(
+					((struct ethhdr *)frame)->h_dest)) {
+					adapter->stats64.multicast += 1;
+					hw->ep_shm_info[cur_epid].net_stats
+								 .multicast += 1;
+				}
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
+		napi_complete(napi);
+
+		if (adapter->unset_rx_last) {
+			adapter->rx_last_jiffies = jiffies;
+			adapter->unset_rx_last = false;
+		}
+
+		if (((long)jiffies - (long)adapter->rx_last_jiffies) < 3) {
+			napi_reschedule(napi);
+		} else {
+			for (epidx = 0; epidx < hw->max_epid; epidx++) {
+				if (epidx == hw->my_epid)
+					continue;
+				adapter->hw.ep_shm_info[epidx]
+					   .tx.info->v1i.rx_status &=
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
 /* fjes_probe - Device Initialization Routine */
 static int fjes_probe(struct platform_device *plat_dev)
 {
@@ -797,6 +958,8 @@ static int fjes_remove(struct platform_device *plat_dev)
 
 	fjes_hw_exit(hw);
 
+	netif_napi_del(&adapter->napi);
+
 	free_netdev(netdev);
 
 	return 0;
@@ -804,6 +967,10 @@ static int fjes_remove(struct platform_device *plat_dev)
 
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
