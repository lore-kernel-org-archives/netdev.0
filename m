From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2.2 08/22] fjes: net_device_ops.ndo_start_xmit
Date: Thu, 20 Aug 2015 17:46:12 +0900
Message-ID: <1440060386-13189-8-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym04.jp.fujitsu.com ([211.128.242.43]:53234 "EHLO
	mgwym04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbbHTIve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 04:51:34 -0400
In-Reply-To: <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds net_device_ops.ndo_start_xmit callback,
which is called when sending packets.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes.h      |   1 +
 drivers/net/fjes/fjes_hw.c   |  56 ++++++++++++++
 drivers/net/fjes/fjes_hw.h   |  12 +++
 drivers/net/fjes/fjes_main.c | 176 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 245 insertions(+)

diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index f182ed3..7af4304 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -29,6 +29,7 @@
 #define FJES_ACPI_SYMBOL	"Extended Socket"
 #define FJES_MAX_QUEUES		1
 #define FJES_TX_RETRY_INTERVAL	(20 * HZ)
+#define FJES_TX_RETRY_TIMEOUT	(100)
 #define FJES_OPEN_ZONE_UPDATE_WAIT	(300) /* msec */
 
 /* board specific private data structure */
diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 042f684..4965791 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -791,3 +791,59 @@ int fjes_hw_wait_epstop(struct fjes_hw *hw)
 	return (wait_time < FJES_COMMAND_EPSTOP_WAIT_TIMEOUT * 1000)
 			? 0 : -EBUSY;
 }
+
+bool fjes_hw_check_epbuf_version(struct epbuf_handler *epbh, u32 version)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	return (info->common.version == version);
+}
+
+bool fjes_hw_check_mtu(struct epbuf_handler *epbh, u32 mtu)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	return (info->v1i.frame_max == FJES_MTU_TO_FRAME_SIZE(mtu));
+}
+
+bool fjes_hw_check_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+	bool ret = false;
+
+	if (vlan_id == 0) {
+		ret = true;
+	} else {
+		for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+			if (vlan_id == info->v1i.vlan_id[i]) {
+				ret = true;
+				break;
+			}
+		}
+	}
+	return ret;
+}
+
+int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *epbh,
+			      void *frame, size_t size)
+{
+	union ep_buffer_info *info = epbh->info;
+	struct esmem_frame *ring_frame;
+
+	if (EP_RING_FULL(info->v1i.head, info->v1i.tail, info->v1i.count_max))
+		return -ENOBUFS;
+
+	ring_frame = (struct esmem_frame *)&(epbh->ring[EP_RING_INDEX
+					     (info->v1i.tail - 1,
+					      info->v1i.count_max) *
+					     info->v1i.frame_max]);
+
+	ring_frame->frame_size = size;
+	memcpy((void *)(ring_frame->frame_data), (void *)frame, size);
+
+	EP_RING_INDEX_INC(epbh->info->v1i.tail, info->v1i.count_max);
+
+	return 0;
+}
+
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index d53c508..2b49421 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -50,6 +50,9 @@ struct fjes_hw;
 
 #define FJES_ZONING_ZONE_TYPE_NONE (0xFF)
 
+#define FJES_TX_DELAY_SEND_NONE		(0)
+#define FJES_TX_DELAY_SEND_PENDING	(1)
+
 #define FJES_RX_STOP_REQ_NONE		(0x0)
 #define FJES_RX_STOP_REQ_DONE		(0x1)
 #define FJES_RX_STOP_REQ_REQUEST	(0x2)
@@ -61,6 +64,11 @@ struct fjes_hw;
 
 #define EP_RING_NUM(buffer_size, frame_size) \
 		(u32)((buffer_size) / (frame_size))
+#define EP_RING_INDEX(_num, _max) (((_num) + (_max)) % (_max))
+#define EP_RING_INDEX_INC(_num, _max) \
+	((_num) = EP_RING_INDEX((_num) + 1, (_max)))
+#define EP_RING_FULL(_head, _tail, _max)				\
+	(0 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
 
 #define FJES_MTU_TO_BUFFER_SIZE(mtu) \
 	(ETH_HLEN + VLAN_HLEN + (mtu) + ETH_FCS_LEN)
@@ -309,5 +317,9 @@ enum ep_partner_status
 
 bool fjes_hw_epid_is_same_zone(struct fjes_hw *, int);
 int fjes_hw_epid_is_shared(struct fjes_device_shared_info *, int);
+bool fjes_hw_check_epbuf_version(struct epbuf_handler *, u32);
+bool fjes_hw_check_mtu(struct epbuf_handler *, u32);
+bool fjes_hw_check_vlan_id(struct epbuf_handler *, u16);
+int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *, void *, size_t);
 
 #endif /* FJES_HW_H_ */
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 29bd7dc..be14e66 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -51,6 +51,7 @@ static int fjes_open(struct net_device *);
 static int fjes_close(struct net_device *);
 static int fjes_setup_resources(struct fjes_adapter *);
 static void fjes_free_resources(struct fjes_adapter *);
+static netdev_tx_t fjes_xmit_frame(struct sk_buff *, struct net_device *);
 static irqreturn_t fjes_intr(int, void*);
 
 static int fjes_acpi_add(struct acpi_device *);
@@ -212,6 +213,7 @@ static void fjes_free_irq(struct fjes_adapter *adapter)
 static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_open		= fjes_open,
 	.ndo_stop		= fjes_close,
+	.ndo_start_xmit		= fjes_xmit_frame,
 };
 
 /* fjes_open - Called when a network interface is made active */
@@ -402,6 +404,180 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 	}
 }
 
+static int fjes_tx_send(struct fjes_adapter *adapter, int dest,
+			void *data, size_t len)
+{
+	int retval;
+
+	retval = fjes_hw_epbuf_tx_pkt_send(&adapter->hw.ep_shm_info[dest].tx,
+					   data, len);
+	if (retval)
+		return retval;
+
+	adapter->hw.ep_shm_info[dest].tx.info->v1i.tx_status =
+		FJES_TX_DELAY_SEND_PENDING;
+
+	retval = 0;
+	return retval;
+}
+
+static netdev_tx_t
+fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status pstatus;
+
+	int len;
+	char *data, shortpkt[VLAN_ETH_HLEN];
+
+	u16 queue_no = 0;
+	struct netdev_queue *cur_queue = netdev_get_tx_queue(netdev, queue_no);
+	netdev_tx_t ret = NETDEV_TX_OK;
+	struct ethhdr *eth;
+	int dest_epid;
+
+	int max_epid, my_epid;
+	u16 vlan_id = 0;
+	bool vlan = false;
+	bool is_multi = false;
+
+	eth = (struct ethhdr *)skb->data;
+	my_epid = hw->my_epid;
+
+	vlan = (vlan_get_tag(skb, &vlan_id) == 0) ? true : false;
+
+	data = skb->data;
+	len = skb->len;
+
+	if (is_multicast_ether_addr(eth->h_dest)) {
+		dest_epid = 0;
+		max_epid = hw->max_epid;
+		is_multi = true;
+	} else if (is_local_ether_addr(eth->h_dest)) {
+		dest_epid = eth->h_dest[ETH_ALEN - 1];
+		max_epid = dest_epid + 1;
+
+		if ((eth->h_dest[0] == 0x02) &&
+		    (0x00 == (eth->h_dest[1] | eth->h_dest[2] |
+			      eth->h_dest[3] | eth->h_dest[4])) &&
+		    (dest_epid < hw->max_epid)) {
+			;
+		} else {
+			dest_epid = 0;
+			max_epid = 0;
+			ret = NETDEV_TX_OK;
+
+			adapter->stats64.tx_packets += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+			adapter->stats64.tx_bytes += len;
+			hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+		}
+	} else {
+		dest_epid = 0;
+		max_epid = 0;
+		ret = NETDEV_TX_OK;
+
+		adapter->stats64.tx_packets += 1;
+		hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+		adapter->stats64.tx_bytes += len;
+		hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+	}
+
+	for (; dest_epid < max_epid; dest_epid++) {
+		if (my_epid == dest_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, dest_epid);
+		if (pstatus != EP_PARTNER_SHARED) {
+			ret = NETDEV_TX_OK;
+		} else if (!fjes_hw_check_epbuf_version(
+				&adapter->hw.ep_shm_info[dest_epid].rx, 0)) {
+			/* version is NOT 0 */
+			adapter->stats64.tx_carrier_errors += 1;
+			hw->ep_shm_info[my_epid].net_stats
+						.tx_carrier_errors += 1;
+
+			ret = NETDEV_TX_OK;
+		} else if (!fjes_hw_check_mtu(
+				&adapter->hw.ep_shm_info[dest_epid].rx,
+				netdev->mtu)) {
+			adapter->stats64.tx_dropped += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_dropped += 1;
+			adapter->stats64.tx_errors += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_errors += 1;
+
+			ret = NETDEV_TX_OK;
+		} else if (vlan &&
+			   !fjes_hw_check_vlan_id(
+				&adapter->hw.ep_shm_info[dest_epid].rx,
+				vlan_id)) {
+			ret = NETDEV_TX_OK;
+		} else {
+			if (len < VLAN_ETH_HLEN) {
+				memset(shortpkt, 0, VLAN_ETH_HLEN);
+				memcpy(shortpkt, skb->data, skb->len);
+				len = VLAN_ETH_HLEN;
+				data = shortpkt;
+			}
+
+			if (adapter->tx_retry_count == 0) {
+				adapter->tx_start_jiffies = jiffies;
+				adapter->tx_retry_count = 1;
+			} else {
+				adapter->tx_retry_count++;
+			}
+
+			if (fjes_tx_send(adapter, dest_epid, data, len)) {
+				if (is_multi) {
+					ret = NETDEV_TX_OK;
+				} else if (
+					   ((long)jiffies -
+					    (long)adapter->tx_start_jiffies) >=
+					    FJES_TX_RETRY_TIMEOUT) {
+					adapter->stats64.tx_fifo_errors += 1;
+					hw->ep_shm_info[my_epid].net_stats
+								.tx_fifo_errors += 1;
+					adapter->stats64.tx_errors += 1;
+					hw->ep_shm_info[my_epid].net_stats
+								.tx_errors += 1;
+
+					ret = NETDEV_TX_OK;
+				} else {
+					netdev->trans_start = jiffies;
+					netif_tx_stop_queue(cur_queue);
+
+					ret = NETDEV_TX_BUSY;
+				}
+			} else {
+				if (!is_multi) {
+					adapter->stats64.tx_packets += 1;
+					hw->ep_shm_info[my_epid].net_stats
+								.tx_packets += 1;
+					adapter->stats64.tx_bytes += len;
+					hw->ep_shm_info[my_epid].net_stats
+								.tx_bytes += len;
+				}
+
+				adapter->tx_retry_count = 0;
+				ret = NETDEV_TX_OK;
+			}
+		}
+	}
+
+	if (ret == NETDEV_TX_OK) {
+		dev_kfree_skb(skb);
+		if (is_multi) {
+			adapter->stats64.tx_packets += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+			adapter->stats64.tx_bytes += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+		}
+	}
+
+	return ret;
+}
+
 static irqreturn_t fjes_intr(int irq, void *data)
 {
 	struct fjes_adapter *adapter = data;
-- 
1.8.3.1
