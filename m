From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 2/2] hv_netvsc: Eliminate memory allocation in the
 packet send path
Date: Sun, 29 Mar 2015 21:08:42 -0700
Message-ID: <1427688522-27991-2-git-send-email-kys@microsoft.com>
References: <1427688478-27950-1-git-send-email-kys@microsoft.com>
 <1427688522-27991-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1427688522-27991-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The network protocol used to communicate with the host is the remote ndis (rndis)
protocol. We need to decorate each outgoing packet with a rndis header and
additional rndis state (rndis per-packet state). To manage this state, we
currently allocate memory in the transmit path. Eliminate this allocation by
requesting additional head room in the skb.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    3 +-
 drivers/net/hyperv/netvsc.c       |   10 ++++--
 drivers/net/hyperv/netvsc_drv.c   |   67 +++++++++++++++++++++++++++----------
 drivers/net/hyperv/rndis_filter.c |    2 +
 4 files changed, 60 insertions(+), 22 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 384f057..309adee 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -128,6 +128,7 @@ struct ndis_tcp_ip_checksum_info;
 struct hv_netvsc_packet {
 	/* Bookkeeping stuff */
 	u32 status;
+	bool part_of_skb;
 
 	struct hv_device *device;
 	bool is_data_pkt;
@@ -150,7 +151,7 @@ struct hv_netvsc_packet {
 	/* Points to the send/receive buffer where the ethernet frame is */
 	void *data;
 	u32 page_buf_cnt;
-	struct hv_page_buffer page_buf[0];
+	struct hv_page_buffer *page_buf;
 };
 
 struct netvsc_device_info {
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index ecbd813..f699236 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -866,11 +866,15 @@ int netvsc_send(struct hv_device *device,
 		netvsc_copy_to_send_buf(net_device,
 					section_index, msd_len,
 					packet);
-		skb = (struct sk_buff *)
-		       (unsigned long)packet->send_completion_tid;
+		if (!packet->part_of_skb) {
+			skb = (struct sk_buff *)
+				(unsigned long)
+				packet->send_completion_tid;
+
+			packet->send_completion_tid = 0;
+		}
 
 		packet->page_buf_cnt = 0;
-		packet->send_completion_tid = 0;
 		packet->send_buf_index = section_index;
 		packet->total_data_buflen += msd_len;
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 75beb89..f9db6bc 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -235,7 +235,8 @@ static void netvsc_xmit_completion(void *context)
 	struct sk_buff *skb = (struct sk_buff *)
 		(unsigned long)packet->send_completion_tid;
 
-	kfree(packet);
+	if (!packet->part_of_skb)
+		kfree(packet);
 
 	if (skb)
 		dev_kfree_skb_any(skb);
@@ -383,6 +384,9 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	u32 net_trans_info;
 	u32 hash;
 	u32 skb_length = skb->len;
+	u32 head_room = skb_headroom(skb);
+	u32 pkt_sz;
+	struct hv_page_buffer page_buf[MAX_PAGE_BUFFER_COUNT];
 
 
 	/* We will atmost need two pages to describe the rndis
@@ -397,24 +401,32 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		return NETDEV_TX_OK;
 	}
 
-	/* Allocate a netvsc packet based on # of frags. */
-	packet = kzalloc(sizeof(struct hv_netvsc_packet) +
-			 (num_data_pgs * sizeof(struct hv_page_buffer)) +
-			 sizeof(struct rndis_message) +
-			 NDIS_VLAN_PPI_SIZE + NDIS_CSUM_PPI_SIZE +
-			 NDIS_LSO_PPI_SIZE + NDIS_HASH_PPI_SIZE, GFP_ATOMIC);
-	if (!packet) {
-		/* out of memory, drop packet */
-		netdev_err(net, "unable to allocate hv_netvsc_packet\n");
-
-		dev_kfree_skb(skb);
-		net->stats.tx_dropped++;
-		return NETDEV_TX_OK;
+	pkt_sz = sizeof(struct hv_netvsc_packet) +
+			sizeof(struct rndis_message) +
+			NDIS_VLAN_PPI_SIZE + NDIS_CSUM_PPI_SIZE +
+			NDIS_LSO_PPI_SIZE + NDIS_HASH_PPI_SIZE;
+
+	if (head_room < pkt_sz) {
+		packet = kmalloc(pkt_sz, GFP_ATOMIC);
+		if (!packet) {
+			/* out of memory, drop packet */
+			netdev_err(net, "unable to alloc hv_netvsc_packet\n");
+			dev_kfree_skb(skb);
+			net->stats.tx_dropped++;
+			return NETDEV_TX_OK;
+		}
+		packet->part_of_skb = false;
+	} else {
+		/* Use the headroom for building up the packet */
+		packet = (struct hv_netvsc_packet *)skb->head;
+		packet->part_of_skb = true;
 	}
 
+	packet->status = 0;
 	packet->xmit_more = skb->xmit_more;
 
 	packet->vlan_tci = skb->vlan_tci;
+	packet->page_buf = page_buf;
 
 	packet->q_idx = skb_get_queue_mapping(skb);
 
@@ -422,8 +434,13 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	packet->total_data_buflen = skb->len;
 
 	packet->rndis_msg = (struct rndis_message *)((unsigned long)packet +
-				sizeof(struct hv_netvsc_packet) +
-				(num_data_pgs * sizeof(struct hv_page_buffer)));
+				sizeof(struct hv_netvsc_packet));
+
+	memset(packet->rndis_msg, 0, sizeof(struct rndis_message) +
+					NDIS_VLAN_PPI_SIZE +
+					NDIS_CSUM_PPI_SIZE +
+					NDIS_LSO_PPI_SIZE +
+					NDIS_HASH_PPI_SIZE);
 
 	/* Set the completion routine */
 	packet->send_completion = netvsc_xmit_completion;
@@ -555,7 +572,7 @@ do_send:
 	rndis_msg->msg_len += rndis_msg_size;
 	packet->total_data_buflen = rndis_msg->msg_len;
 	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
-					skb, &packet->page_buf[0]);
+					skb, &page_buf[0]);
 
 	ret = netvsc_send(net_device_ctx->device_ctx, packet);
 
@@ -564,7 +581,8 @@ drop:
 		net->stats.tx_bytes += skb_length;
 		net->stats.tx_packets++;
 	} else {
-		kfree(packet);
+		if (!packet->part_of_skb)
+			kfree(packet);
 		if (ret != -EAGAIN) {
 			dev_kfree_skb_any(skb);
 			net->stats.tx_dropped++;
@@ -846,12 +864,18 @@ static int netvsc_probe(struct hv_device *dev,
 	struct netvsc_device_info device_info;
 	struct netvsc_device *nvdev;
 	int ret;
+	u32 max_needed_headroom;
 
 	net = alloc_etherdev_mq(sizeof(struct net_device_context),
 				num_online_cpus());
 	if (!net)
 		return -ENOMEM;
 
+	max_needed_headroom = sizeof(struct hv_netvsc_packet) +
+				sizeof(struct rndis_message) +
+				NDIS_VLAN_PPI_SIZE + NDIS_CSUM_PPI_SIZE +
+				NDIS_LSO_PPI_SIZE + NDIS_HASH_PPI_SIZE;
+
 	netif_carrier_off(net);
 
 	net_device_ctx = netdev_priv(net);
@@ -870,6 +894,13 @@ static int netvsc_probe(struct hv_device *dev,
 	net->ethtool_ops = &ethtool_ops;
 	SET_NETDEV_DEV(net, &dev->device);
 
+	/*
+	 * Request additional head room in the skb.
+	 * We will use this space to build the rndis
+	 * heaser and other state we need to maintain.
+	 */
+	net->needed_headroom = max_needed_headroom;
+
 	/* Notify the netvsc driver of the new device */
 	device_info.ring_size = ring_size;
 	ret = rndis_filter_device_add(dev, &device_info);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index fdfab1f..a160437 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -210,6 +210,7 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 {
 	int ret;
 	struct hv_netvsc_packet *packet;
+	struct hv_page_buffer page_buf[2];
 
 	/* Setup the packet to send it */
 	packet = &req->pkt;
@@ -217,6 +218,7 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 	packet->is_data_pkt = false;
 	packet->total_data_buflen = req->request_msg.msg_len;
 	packet->page_buf_cnt = 1;
+	packet->page_buf = page_buf;
 
 	packet->page_buf[0].pfn = virt_to_phys(&req->request_msg) >>
 					PAGE_SHIFT;
-- 
1.7.4.1
