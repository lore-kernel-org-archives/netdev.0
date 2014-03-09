From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V3 6/6] Drivers: net: hyperv: Enable large send offload
Date: Sat,  8 Mar 2014 19:23:18 -0800
Message-ID: <1394335398-11167-6-git-send-email-kys@microsoft.com>
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

Enable segmentation offload.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |   40 +++++++++++++++++++++++++++++++++++++++
 drivers/net/hyperv/netvsc_drv.c |   38 +++++++++++++++++++++++++++++++++---
 2 files changed, 74 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 4cf2382..7d06b49 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -742,6 +742,10 @@ struct ndis_oject_header {
 #define NDIS_OFFLOAD_PARAMETERS_RX_ENABLED_TX_DISABLED 3
 #define NDIS_OFFLOAD_PARAMETERS_TX_RX_ENABLED 4
 
+#define NDIS_TCP_LARGE_SEND_OFFLOAD_V2_TYPE	1
+#define NDIS_TCP_LARGE_SEND_OFFLOAD_IPV4	0
+#define NDIS_TCP_LARGE_SEND_OFFLOAD_IPV6	1
+
 /*
  * New offload OIDs for NDIS 6
  */
@@ -804,12 +808,48 @@ struct ndis_tcp_ip_checksum_info {
 	};
 };
 
+struct ndis_tcp_lso_info {
+	union {
+		struct {
+			u32 unused:30;
+			u32 type:1;
+			u32 reserved2:1;
+		} transmit;
+		struct {
+			u32 mss:20;
+			u32 tcp_header_offset:10;
+			u32 type:1;
+			u32 reserved2:1;
+		} lso_v1_transmit;
+		struct {
+			u32 tcp_payload:30;
+			u32 type:1;
+			u32 reserved2:1;
+		} lso_v1_transmit_complete;
+		struct {
+			u32 mss:20;
+			u32 tcp_header_offset:10;
+			u32 type:1;
+			u32 ip_version:1;
+		} lso_v2_transmit;
+		struct {
+			u32 reserved:30;
+			u32 type:1;
+			u32 reserved2:1;
+		} lso_v2_transmit_complete;
+		u32  value;
+	};
+};
+
 #define NDIS_VLAN_PPI_SIZE (sizeof(struct rndis_per_packet_info) + \
 		sizeof(struct ndis_pkt_8021q_info))
 
 #define NDIS_CSUM_PPI_SIZE (sizeof(struct rndis_per_packet_info) + \
 		sizeof(struct ndis_tcp_ip_checksum_info))
 
+#define NDIS_LSO_PPI_SIZE (sizeof(struct rndis_per_packet_info) + \
+		sizeof(struct ndis_tcp_lso_info))
+
 /* Format of Information buffer passed in a SetRequest for the OID */
 /* OID_GEN_RNDIS_CONFIG_PARAMETER. */
 struct rndis_config_parameter_info {
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 6978375..3d06990 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -298,6 +298,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	bool isvlan;
 	struct rndis_per_packet_info *ppi;
 	struct ndis_tcp_ip_checksum_info *csum_info;
+	struct ndis_tcp_lso_info *lso_info;
 	int  hdr_offset;
 	u32 net_trans_info;
 
@@ -377,7 +378,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	 * GSO packet.
 	 */
 	if (skb_is_gso(skb))
-		goto do_send;
+		goto do_lso;
 
 	rndis_msg_size += NDIS_CSUM_PPI_SIZE;
 	ppi = init_ppi_data(rndis_msg, NDIS_CSUM_PPI_SIZE,
@@ -397,6 +398,35 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	} else if (net_trans_info & INFO_UDP) {
 		csum_info->transmit.udp_checksum = 1;
 	}
+	goto do_send;
+
+do_lso:
+	rndis_msg_size += NDIS_LSO_PPI_SIZE;
+	ppi = init_ppi_data(rndis_msg, NDIS_LSO_PPI_SIZE,
+			    TCP_LARGESEND_PKTINFO);
+
+	lso_info = (struct ndis_tcp_lso_info *)((void *)ppi +
+			ppi->ppi_offset);
+
+	lso_info->lso_v2_transmit.type = NDIS_TCP_LARGE_SEND_OFFLOAD_V2_TYPE;
+	if (net_trans_info & (INFO_IPV4 << 16)) {
+		lso_info->lso_v2_transmit.ip_version =
+			NDIS_TCP_LARGE_SEND_OFFLOAD_IPV4;
+		ip_hdr(skb)->tot_len = 0;
+		ip_hdr(skb)->check = 0;
+		tcp_hdr(skb)->check =
+		~csum_tcpudp_magic(ip_hdr(skb)->saddr,
+				   ip_hdr(skb)->daddr, 0, IPPROTO_TCP, 0);
+	} else {
+		lso_info->lso_v2_transmit.ip_version =
+			NDIS_TCP_LARGE_SEND_OFFLOAD_IPV6;
+		ipv6_hdr(skb)->payload_len = 0;
+		tcp_hdr(skb)->check =
+		~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+				&ipv6_hdr(skb)->daddr, 0, IPPROTO_TCP, 0);
+	}
+	lso_info->lso_v2_transmit.tcp_header_offset = hdr_offset;
+	lso_info->lso_v2_transmit.mss = skb_shinfo(skb)->gso_size;
 
 do_send:
 	/* Start filling in the page buffers with the rndis hdr */
@@ -652,10 +682,10 @@ static int netvsc_probe(struct hv_device *dev,
 
 	net->netdev_ops = &device_ops;
 
-	/* TODO: Add GSO and Checksum offload */
-	net->hw_features = NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM;
+	net->hw_features = NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM |
+				NETIF_F_TSO;
 	net->features = NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM |
-			NETIF_F_IP_CSUM;
+			NETIF_F_IP_CSUM | NETIF_F_TSO;
 
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, &dev->device);
-- 
1.7.4.1
