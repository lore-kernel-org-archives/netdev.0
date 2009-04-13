From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 1/2] be2net: changes for checksum and segmentation offload
Date: Mon, 13 Apr 2009 13:34:35 +0530
Message-ID: <20090413080434.GC6824@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Ajit Khaparde <ajitk@serverengines.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:21003 "EHLO
	ajitk-desktop" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752140AbZDMIPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 04:15:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, this patch does the following:

- Enables Rx checksum feature by default.
- Disables support for ipv6 tso.
- Changes in Rx path to handle Rx completions with various checksum options.

Thanks
Ajit 




Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
----
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9b75aa6..8994b03 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -637,6 +637,22 @@ static void be_rx_stats_update(struct be_adapter *adapter,
 	stats->be_rx_bytes += pktsize;
 }
 
+static inline bool do_pkt_csum(struct be_eth_rx_compl *rxcp, bool cso)
+{
+	u8 l4_cksm, ip_version, ipcksm, tcpf = 0, udpf = 0, ipv6_chk;
+
+	l4_cksm = AMAP_GET_BITS(struct amap_eth_rx_compl, l4_cksm, rxcp);
+	ipcksm = AMAP_GET_BITS(struct amap_eth_rx_compl, ipcksm, rxcp);
+	ip_version = AMAP_GET_BITS(struct amap_eth_rx_compl, ip_version, rxcp);
+	if (ip_version) {
+		tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl, tcpf, rxcp);
+		udpf = AMAP_GET_BITS(struct amap_eth_rx_compl, udpf, rxcp);
+	}
+	ipv6_chk = (ip_version && (tcpf || udpf));
+
+	return ((l4_cksm && ipv6_chk && ipcksm) && cso) ? false : true;
+}
+
 static struct be_rx_page_info *
 get_rx_page_info(struct be_adapter *adapter, u16 frag_idx)
 {
@@ -752,9 +768,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 {
 	struct sk_buff *skb;
 	u32 vtp, vid;
-	int l4_cksm;
 
-	l4_cksm = AMAP_GET_BITS(struct amap_eth_rx_compl, l4_cksm, rxcp);
 	vtp = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 
 	skb = netdev_alloc_skb(adapter->netdev, BE_HDR_LEN + NET_IP_ALIGN);
@@ -769,10 +783,10 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	skb_fill_rx_data(adapter, skb, rxcp);
 
-	if (l4_cksm && adapter->rx_csum)
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	else
+	if (do_pkt_csum(rxcp, adapter->rx_csum))
 		skb->ip_summed = CHECKSUM_NONE;
+	else
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
@@ -1626,10 +1640,12 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netdev->features |= NETIF_F_SG | NETIF_F_HW_VLAN_RX | NETIF_F_TSO |
 		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
+		NETIF_F_IPV6_CSUM;
 
 	netdev->flags |= IFF_MULTICAST;
 
+	adapter->rx_csum = true;
+
 	BE_SET_NETDEV_OPS(netdev, &be_netdev_ops);
 
 	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
