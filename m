From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V2 17/17] hv_netvsc: Eliminate vlan_tci from struct
 hv_netvsc_packet
Date: Sat, 28 Nov 2015 12:20:45 -0800
Message-ID: <1448742045-22732-17-git-send-email-kys@microsoft.com>
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

Eliminate vlan_tci from struct hv_netvsc_packet.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    4 ++--
 drivers/net/hyperv/netvsc_drv.c   |   14 +++++++-------
 drivers/net/hyperv/rndis_filter.c |    7 +++----
 3 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 128b296..0c04362 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -136,7 +136,6 @@ struct hv_netvsc_packet {
 	u8 rmsg_pgcnt; /* page count of RNDIS header and PPI */
 	u8 page_buf_cnt;
 
-	u16 vlan_tci;
 	u16 q_idx;
 	u32 send_buf_index;
 
@@ -188,7 +187,8 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 			struct hv_netvsc_packet *packet,
 			void **data,
 			struct ndis_tcp_ip_checksum_info *csum_info,
-			struct vmbus_channel *channel);
+			struct vmbus_channel *channel,
+			u16 vlan_tci);
 void netvsc_channel_cb(void *context);
 int rndis_filter_open(struct hv_device *dev);
 int rndis_filter_close(struct hv_device *dev);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 490672e..ba21272 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -470,7 +470,6 @@ check_size:
 			FIELD_SIZEOF(struct sk_buff, cb));
 	packet = (struct hv_netvsc_packet *)skb->cb;
 
-	packet->vlan_tci = skb->vlan_tci;
 
 	packet->q_idx = skb_get_queue_mapping(skb);
 
@@ -480,7 +479,7 @@ check_size:
 
 	memset(rndis_msg, 0, RNDIS_AND_PPI_SIZE);
 
-	isvlan = packet->vlan_tci & VLAN_TAG_PRESENT;
+	isvlan = skb->vlan_tci & VLAN_TAG_PRESENT;
 
 	/* Add the rndis header */
 	rndis_msg->ndis_msg_type = RNDIS_MSG_PACKET;
@@ -508,8 +507,8 @@ check_size:
 					IEEE_8021Q_INFO);
 		vlan = (struct ndis_pkt_8021q_info *)((void *)ppi +
 						ppi->ppi_offset);
-		vlan->vlanid = packet->vlan_tci & VLAN_VID_MASK;
-		vlan->pri = (packet->vlan_tci & VLAN_PRIO_MASK) >>
+		vlan->vlanid = skb->vlan_tci & VLAN_VID_MASK;
+		vlan->pri = (skb->vlan_tci & VLAN_PRIO_MASK) >>
 				VLAN_PRIO_SHIFT;
 	}
 
@@ -676,7 +675,8 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 				struct hv_netvsc_packet *packet,
 				void **data,
 				struct ndis_tcp_ip_checksum_info *csum_info,
-				struct vmbus_channel *channel)
+				struct vmbus_channel *channel,
+				u16 vlan_tci)
 {
 	struct net_device *net;
 	struct net_device_context *net_device_ctx;
@@ -716,9 +716,9 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 			skb->ip_summed = CHECKSUM_NONE;
 	}
 
-	if (packet->vlan_tci & VLAN_TAG_PRESENT)
+	if (vlan_tci & VLAN_TAG_PRESENT)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
-				       packet->vlan_tci);
+				       vlan_tci);
 
 	skb_record_rx_queue(skb, channel->
 			    offermsg.offer.sub_channel_index);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 28adf6a..a37bbda 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -354,6 +354,7 @@ static int rndis_filter_receive_data(struct rndis_device *dev,
 	u32 data_offset;
 	struct ndis_pkt_8021q_info *vlan;
 	struct ndis_tcp_ip_checksum_info *csum_info;
+	u16 vlan_tci = 0;
 
 	rndis_pkt = &msg->msg.pkt;
 
@@ -384,15 +385,13 @@ static int rndis_filter_receive_data(struct rndis_device *dev,
 
 	vlan = rndis_get_ppi(rndis_pkt, IEEE_8021Q_INFO);
 	if (vlan) {
-		pkt->vlan_tci = VLAN_TAG_PRESENT | vlan->vlanid |
+		vlan_tci = VLAN_TAG_PRESENT | vlan->vlanid |
 			(vlan->pri << VLAN_PRIO_SHIFT);
-	} else {
-		pkt->vlan_tci = 0;
 	}
 
 	csum_info = rndis_get_ppi(rndis_pkt, TCPIP_CHKSUM_PKTINFO);
 	return netvsc_recv_callback(dev->net_dev->dev, pkt, data,
-				    csum_info, channel);
+				    csum_info, channel, vlan_tci);
 }
 
 int rndis_filter_receive(struct hv_device *dev,
-- 
1.7.4.1
