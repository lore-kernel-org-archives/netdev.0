From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 5/6] Drivers: net: hyperv: Enable send side checksum offload
Date: Thu,  6 Mar 2014 03:13:09 -0800
Message-ID: <1394104390-23477-5-git-send-email-kys@microsoft.com>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394104390-23477-1-git-send-email-kys@microsoft.com>
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
 drivers/net/hyperv/netvsc_drv.c |   70 +++++++++++++++++++++++++++++++++++++-
 1 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 98562fc..e8159a8 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -259,6 +259,36 @@ static int netvsc_get_slots(struct sk_buff *skb)
 	return slots + frag_slots;
 }
 
+bool get_net_transport_info(struct sk_buff *skb, bool *is_v4,
+				bool *is_tcp, bool *is_udp, u32 *trans_off)
+{
+	*is_tcp = false;
+	*is_udp = false;
+
+	if ((eth_hdr(skb)->h_proto != htons(ETH_P_IP)) &&
+		(eth_hdr(skb)->h_proto != htons(ETH_P_IPV6))) {
+		return false;
+	}
+
+	*trans_off = skb_transport_offset(skb);
+
+	if ((eth_hdr(skb)->h_proto == htons(ETH_P_IP))) {
+		struct iphdr *iphdr = ip_hdr(skb);
+		*is_v4 = true;
+		if (iphdr->protocol == IPPROTO_TCP)
+			*is_tcp = true;
+		else if (iphdr->protocol == IPPROTO_UDP)
+			*is_udp = true;
+	} else {
+		*is_v4 = false;
+		if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+			*is_tcp = true;
+		else if (ipv6_hdr(skb)->nexthdr == IPPROTO_UDP)
+			*is_udp = true;
+	}
+	return true;
+}
+
 static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(net);
@@ -270,6 +300,12 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	u32 rndis_msg_size;
 	bool isvlan;
 	struct rndis_per_packet_info *ppi;
+	struct ndis_tcp_ip_checksum_info *csum_info;
+	int  hdr_offset;
+	bool is_v4;
+	bool is_tcp;
+	bool is_udp;
+
 
 	/*
 	 * We will atmost need two pages to describe the rndis
@@ -338,6 +374,35 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 				VLAN_PRIO_SHIFT;
 	}
 
+	if (!get_net_transport_info(skb, &is_v4, &is_tcp, &is_udp, &hdr_offset))
+		goto do_send;
+	/*
+	 * Setup the sendside checksum offload only if this is not a
+	 * GSO packet.
+	 */
+	if (skb_is_gso(skb))
+		goto do_send;
+
+	rndis_msg_size += NDIS_CSUM_PPI_SIZE;
+	ppi = init_ppi_data(rndis_msg, NDIS_CSUM_PPI_SIZE,
+				TCPIP_CHKSUM_PKTINFO);
+
+	csum_info = (struct ndis_tcp_ip_checksum_info *)((ulong)ppi +
+			ppi->ppi_offset);
+
+	if (is_v4)
+		csum_info->transmit.is_ipv4 = 1;
+	else
+		csum_info->transmit.is_ipv6 = 1;
+
+	if (is_tcp) {
+		csum_info->transmit.tcp_checksum = 1;
+		csum_info->transmit.tcp_header_offset = hdr_offset;
+	} else if (is_udp) {
+		csum_info->transmit.udp_checksum = 1;
+	}
+
+do_send:
 	/* Start filling in the page buffers with the rndis hdr */
 	rndis_msg->msg_len += rndis_msg_size;
 	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
@@ -593,8 +658,9 @@ static int netvsc_probe(struct hv_device *dev,
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
