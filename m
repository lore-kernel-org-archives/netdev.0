From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V3 4/6] Drivers: net: hyperv: Enable receive side IP checksum
 offload
Date: Sat,  8 Mar 2014 19:23:16 -0800
Message-ID: <1394335398-11167-4-git-send-email-kys@microsoft.com>
References: <1394335362-11126-1-git-send-email-kys@microsoft.com>
 <1394335398-11167-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394335398-11167-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Enable receive side checksum offload.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |   33 ++++++++++++++++++++++++++++++++-
 drivers/net/hyperv/netvsc_drv.c   |   19 +++++++++++++++----
 drivers/net/hyperv/rndis_filter.c |    4 +++-
 3 files changed, 50 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 8bc4e76..faeb746 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -30,6 +30,7 @@
 
 /* Fwd declaration */
 struct hv_netvsc_packet;
+struct ndis_tcp_ip_checksum_info;
 
 /* Represent the xfer page packet which contains 1 or more netvsc packet */
 struct xferpage_packet {
@@ -117,7 +118,8 @@ int netvsc_send(struct hv_device *device,
 void netvsc_linkstatus_callback(struct hv_device *device_obj,
 				unsigned int status);
 int netvsc_recv_callback(struct hv_device *device_obj,
-			struct hv_netvsc_packet *packet);
+			struct hv_netvsc_packet *packet,
+			struct ndis_tcp_ip_checksum_info *csum_info);
 int rndis_filter_open(struct hv_device *dev);
 int rndis_filter_close(struct hv_device *dev);
 int rndis_filter_device_add(struct hv_device *dev,
@@ -776,9 +778,38 @@ struct ndis_offload_params {
 	};
 };
 
+struct ndis_tcp_ip_checksum_info {
+	union {
+		struct {
+			u32 is_ipv4:1;
+			u32 is_ipv6:1;
+			u32 tcp_checksum:1;
+			u32 udp_checksum:1;
+			u32 ip_header_checksum:1;
+			u32 reserved:11;
+			u32 tcp_header_offset:10;
+		} transmit;
+		struct {
+			u32 tcp_checksum_failed:1;
+			u32 udp_checksum_failed:1;
+			u32 ip_checksum_failed:1;
+			u32 tcp_checksum_succeeded:1;
+			u32 udp_checksum_succeeded:1;
+			u32 ip_checksum_succeeded:1;
+			u32 loopback:1;
+			u32 tcp_checksum_value_invalid:1;
+			u32 ip_checksum_value_invalid:1;
+		} receive;
+		u32  value;
+	};
+};
+
 #define NDIS_VLAN_PPI_SIZE (sizeof(struct rndis_per_packet_info) + \
 		sizeof(struct ndis_pkt_8021q_info))
 
+#define NDIS_CSUM_PPI_SIZE (sizeof(struct rndis_per_packet_info) + \
+		sizeof(struct ndis_tcp_ip_checksum_info))
+
 /* Format of Information buffer passed in a SetRequest for the OID */
 /* OID_GEN_RNDIS_CONFIG_PARAMETER. */
 struct rndis_config_parameter_info {
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 7010c06..9bee065 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -391,7 +391,8 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
  * "wire" on the specified device.
  */
 int netvsc_recv_callback(struct hv_device *device_obj,
-				struct hv_netvsc_packet *packet)
+				struct hv_netvsc_packet *packet,
+				struct ndis_tcp_ip_checksum_info *csum_info)
 {
 	struct net_device *net;
 	struct sk_buff *skb;
@@ -418,7 +419,17 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 		packet->total_data_buflen);
 
 	skb->protocol = eth_type_trans(skb, net);
-	skb->ip_summed = CHECKSUM_NONE;
+	if (csum_info) {
+		/* We only look at the IP checksum here.
+		 * Should we be dropping the packet if checksum
+		 * failed? How do we deal with other checksums - TCP/UDP?
+		 */
+		if (csum_info->receive.ip_checksum_succeeded)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = CHECKSUM_NONE;
+	}
+
 	if (packet->vlan_tci & VLAN_TAG_PRESENT)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 				       packet->vlan_tci);
@@ -578,8 +589,8 @@ static int netvsc_probe(struct hv_device *dev,
 	net->netdev_ops = &device_ops;
 
 	/* TODO: Add GSO and Checksum offload */
-	net->hw_features = NETIF_F_SG;
-	net->features = NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG;
+	net->hw_features = NETIF_F_RXCSUM | NETIF_F_SG;
+	net->features = NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM;
 
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, &dev->device);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 9b02f21..4a37e3d 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -370,6 +370,7 @@ static void rndis_filter_receive_data(struct rndis_device *dev,
 	struct rndis_packet *rndis_pkt;
 	u32 data_offset;
 	struct ndis_pkt_8021q_info *vlan;
+	struct ndis_tcp_ip_checksum_info *csum_info;
 
 	rndis_pkt = &msg->msg.pkt;
 
@@ -408,7 +409,8 @@ static void rndis_filter_receive_data(struct rndis_device *dev,
 		pkt->vlan_tci = 0;
 	}
 
-	netvsc_recv_callback(dev->net_dev->dev, pkt);
+	csum_info = rndis_get_ppi(rndis_pkt, TCPIP_CHKSUM_PKTINFO);
+	netvsc_recv_callback(dev->net_dev->dev, pkt, csum_info);
 }
 
 int rndis_filter_receive(struct hv_device *dev,
-- 
1.7.4.1
