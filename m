From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V3 5/6] Drivers: net: hyperv: Enable send side checksum offload
Date: Sat,  8 Mar 2014 19:23:17 -0800
Message-ID: <1394335398-11167-5-git-send-email-kys@microsoft.com>
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

Enable send side checksum offload.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |   10 ++++++
 drivers/net/hyperv/netvsc_drv.c |   69 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 77 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index faeb746..4cf2382 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -1035,6 +1035,16 @@ struct rndis_message {
 #define NDIS_PACKET_TYPE_FUNCTIONAL	0x00000400
 #define NDIS_PACKET_TYPE_MAC_FRAME	0x00000800
 
+#define INFO_IPV4       2
+#define INFO_IPV6       4
+#define INFO_TCP        2
+#define INFO_UDP        4
+
+#define TRANSPORT_INFO_NOT_IP   0
+#define TRANSPORT_INFO_IPV4_TCP ((INFO_IPV4 << 16) | INFO_TCP)
+#define TRANSPORT_INFO_IPV4_UDP ((INFO_IPV4 << 16) | INFO_UDP)
+#define TRANSPORT_INFO_IPV6_TCP ((INFO_IPV6 << 16) | INFO_TCP)
+#define TRANSPORT_INFO_IPV6_UDP ((INFO_IPV6 << 16) | INFO_UDP)
 
 
 #endif /* _HYPERV_NET_H */
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 9bee065..6978375 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -257,6 +257,35 @@ static int netvsc_get_slots(struct sk_buff *skb)
 	return slots + frag_slots;
 }
 
+static u32 get_net_transport_info(struct sk_buff *skb, u32 *trans_off)
+{
+	u32 ret_val = TRANSPORT_INFO_NOT_IP;
+
+	if ((eth_hdr(skb)->h_proto != htons(ETH_P_IP)) &&
+		(eth_hdr(skb)->h_proto != htons(ETH_P_IPV6))) {
+		goto not_ip;
+	}
+
+	*trans_off = skb_transport_offset(skb);
+
+	if ((eth_hdr(skb)->h_proto == htons(ETH_P_IP))) {
+		struct iphdr *iphdr = ip_hdr(skb);
+
+		if (iphdr->protocol == IPPROTO_TCP)
+			ret_val = TRANSPORT_INFO_IPV4_TCP;
+		else if (iphdr->protocol == IPPROTO_UDP)
+			ret_val = TRANSPORT_INFO_IPV4_UDP;
+	} else {
+		if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+			ret_val = TRANSPORT_INFO_IPV6_TCP;
+		else if (ipv6_hdr(skb)->nexthdr == IPPROTO_UDP)
+			ret_val = TRANSPORT_INFO_IPV6_UDP;
+	}
+
+not_ip:
+	return ret_val;
+}
+
 static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(net);
@@ -268,6 +297,10 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	u32 rndis_msg_size;
 	bool isvlan;
 	struct rndis_per_packet_info *ppi;
+	struct ndis_tcp_ip_checksum_info *csum_info;
+	int  hdr_offset;
+	u32 net_trans_info;
+
 
 	/* We will atmost need two pages to describe the rndis
 	 * header. We can only transmit MAX_PAGE_BUFFER_COUNT number
@@ -335,6 +368,37 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 				VLAN_PRIO_SHIFT;
 	}
 
+	net_trans_info = get_net_transport_info(skb, &hdr_offset);
+	if (net_trans_info == TRANSPORT_INFO_NOT_IP)
+		goto do_send;
+
+	/*
+	 * Setup the sendside checksum offload only if this is not a
+	 * GSO packet.
+	 */
+	if (skb_is_gso(skb))
+		goto do_send;
+
+	rndis_msg_size += NDIS_CSUM_PPI_SIZE;
+	ppi = init_ppi_data(rndis_msg, NDIS_CSUM_PPI_SIZE,
+			    TCPIP_CHKSUM_PKTINFO);
+
+	csum_info = (struct ndis_tcp_ip_checksum_info *)((void *)ppi +
+			ppi->ppi_offset);
+
+	if (net_trans_info & (INFO_IPV4 << 16))
+		csum_info->transmit.is_ipv4 = 1;
+	else
+		csum_info->transmit.is_ipv6 = 1;
+
+	if (net_trans_info & INFO_TCP) {
+		csum_info->transmit.tcp_checksum = 1;
+		csum_info->transmit.tcp_header_offset = hdr_offset;
+	} else if (net_trans_info & INFO_UDP) {
+		csum_info->transmit.udp_checksum = 1;
+	}
+
+do_send:
 	/* Start filling in the page buffers with the rndis hdr */
 	rndis_msg->msg_len += rndis_msg_size;
 	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
@@ -589,8 +653,9 @@ static int netvsc_probe(struct hv_device *dev,
 	net->netdev_ops = &device_ops;
 
 	/* TODO: Add GSO and Checksum offload */
-	net->hw_features = NETIF_F_RXCSUM | NETIF_F_SG;
-	net->features = NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM;
+	net->hw_features = NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM;
+	net->features = NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM |
+			NETIF_F_IP_CSUM;
 
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, &dev->device);
-- 
1.7.4.1
