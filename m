From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V2 16/17] hv_netvsc: Eliminate status from struct
 hv_netvsc_packet
Date: Sat, 28 Nov 2015 12:20:44 -0800
Message-ID: <1448742045-22732-16-git-send-email-kys@microsoft.com>
References: <1448742017-22693-1-git-send-email-kys@microsoft.com>
 <1448742045-22732-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448742045-22732-1-git-send-email-kys@microsoft.com>
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

Eliminate status from struct hv_netvsc_packet.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    1 -
 drivers/net/hyperv/netvsc.c       |    6 ++----
 drivers/net/hyperv/netvsc_drv.c   |    8 ++------
 drivers/net/hyperv/rndis_filter.c |   20 +++++++++-----------
 4 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 96d34e2..128b296 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -130,7 +130,6 @@ struct ndis_tcp_ip_checksum_info;
  */
 struct hv_netvsc_packet {
 	/* Bookkeeping stuff */
-	u8 status;
 	u8 cp_partial; /* partial copy into send buffer */
 
 	u8 rmsg_size; /* RNDIS header and PPI size */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index cd5b65e..02bab9a 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1045,17 +1045,15 @@ static void netvsc_receive(struct netvsc_device *net_device,
 	/* Each range represents 1 RNDIS pkt that contains 1 ethernet frame */
 	for (i = 0; i < count; i++) {
 		/* Initialize the netvsc packet */
-		netvsc_packet->status = NVSP_STAT_SUCCESS;
 		data = (void *)((unsigned long)net_device->
 			recv_buf + vmxferpage_packet->ranges[i].byte_offset);
 		netvsc_packet->total_data_buflen =
 					vmxferpage_packet->ranges[i].byte_count;
 
 		/* Pass it to the upper layer */
-		rndis_filter_receive(device, netvsc_packet, &data, channel);
+		status = rndis_filter_receive(device, netvsc_packet, &data,
+					      channel);
 
-		if (netvsc_packet->status != NVSP_STAT_SUCCESS)
-			status = NVSP_STAT_FAIL;
 	}
 
 	netvsc_send_recv_completion(device, channel, net_device,
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 7520c52..490672e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -470,8 +470,6 @@ check_size:
 			FIELD_SIZEOF(struct sk_buff, cb));
 	packet = (struct hv_netvsc_packet *)skb->cb;
 
-	packet->status = 0;
-
 	packet->vlan_tci = skb->vlan_tci;
 
 	packet->q_idx = skb_get_queue_mapping(skb);
@@ -687,8 +685,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 
 	net = ((struct netvsc_device *)hv_get_drvdata(device_obj))->ndev;
 	if (!net || net->reg_state != NETREG_REGISTERED) {
-		packet->status = NVSP_STAT_FAIL;
-		return 0;
+		return NVSP_STAT_FAIL;
 	}
 	net_device_ctx = netdev_priv(net);
 	rx_stats = this_cpu_ptr(net_device_ctx->rx_stats);
@@ -697,8 +694,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	skb = netdev_alloc_skb_ip_align(net, packet->total_data_buflen);
 	if (unlikely(!skb)) {
 		++net->stats.rx_dropped;
-		packet->status = NVSP_STAT_FAIL;
-		return 0;
+		return NVSP_STAT_FAIL;
 	}
 
 	/*
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 3c06aa7..28adf6a 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -344,7 +344,7 @@ static inline void *rndis_get_ppi(struct rndis_packet *rpkt, u32 type)
 	return NULL;
 }
 
-static void rndis_filter_receive_data(struct rndis_device *dev,
+static int rndis_filter_receive_data(struct rndis_device *dev,
 				   struct rndis_message *msg,
 				   struct hv_netvsc_packet *pkt,
 				   void **data,
@@ -371,7 +371,7 @@ static void rndis_filter_receive_data(struct rndis_device *dev,
 			   "overflow detected (got %u, min %u)"
 			   "...dropping this message!\n",
 			   pkt->total_data_buflen, rndis_pkt->data_len);
-		return;
+		return NVSP_STAT_FAIL;
 	}
 
 	/*
@@ -391,7 +391,8 @@ static void rndis_filter_receive_data(struct rndis_device *dev,
 	}
 
 	csum_info = rndis_get_ppi(rndis_pkt, TCPIP_CHKSUM_PKTINFO);
-	netvsc_recv_callback(dev->net_dev->dev, pkt, data, csum_info, channel);
+	return netvsc_recv_callback(dev->net_dev->dev, pkt, data,
+				    csum_info, channel);
 }
 
 int rndis_filter_receive(struct hv_device *dev,
@@ -406,7 +407,7 @@ int rndis_filter_receive(struct hv_device *dev,
 	int ret = 0;
 
 	if (!net_dev) {
-		ret = -EINVAL;
+		ret = NVSP_STAT_FAIL;
 		goto exit;
 	}
 
@@ -416,7 +417,7 @@ int rndis_filter_receive(struct hv_device *dev,
 	if (!net_dev->extension) {
 		netdev_err(ndev, "got rndis message but no rndis device - "
 			  "dropping this message!\n");
-		ret = -ENODEV;
+		ret = NVSP_STAT_FAIL;
 		goto exit;
 	}
 
@@ -424,7 +425,7 @@ int rndis_filter_receive(struct hv_device *dev,
 	if (rndis_dev->state == RNDIS_DEV_UNINITIALIZED) {
 		netdev_err(ndev, "got rndis message but rndis device "
 			   "uninitialized...dropping this message!\n");
-		ret = -ENODEV;
+		ret = NVSP_STAT_FAIL;
 		goto exit;
 	}
 
@@ -436,8 +437,8 @@ int rndis_filter_receive(struct hv_device *dev,
 	switch (rndis_msg->ndis_msg_type) {
 	case RNDIS_MSG_PACKET:
 		/* data msg */
-		rndis_filter_receive_data(rndis_dev, rndis_msg, pkt,
-					  data, channel);
+		ret = rndis_filter_receive_data(rndis_dev, rndis_msg, pkt,
+						data, channel);
 		break;
 
 	case RNDIS_MSG_INIT_C:
@@ -460,9 +461,6 @@ int rndis_filter_receive(struct hv_device *dev,
 	}
 
 exit:
-	if (ret != 0)
-		pkt->status = NVSP_STAT_FAIL;
-
 	return ret;
 }
 
-- 
1.7.4.1
