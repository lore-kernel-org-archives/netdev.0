From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 2/2] be2net: csum, tso and rss steering offload support for VxLAN
Date: Thu, 20 Mar 2014 16:10:11 +0530
Message-ID: <1395312011-899-3-git-send-email-sathya.perla@emulex.com>
References: <1395312011-899-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40912 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755070AbaCTKgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 06:36:20 -0400
In-Reply-To: <1395312011-899-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch mainly implements the add/del_vxlan_port() methods by invoking
the needed FW cmds for supporting VxLAN offloads for Skyhawk-R.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    7 +-
 drivers/net/ethernet/emulex/benet/be_hw.h   |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  122 +++++++++++++++++++++++++--
 3 files changed, 123 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a587c8a..8ccaa25 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -296,6 +296,7 @@ struct be_rx_compl_info {
 	u8 qnq;
 	u8 pkt_type;
 	u8 ip_frag;
+	u8 tunneled;
 };
 
 struct be_rx_obj {
@@ -371,10 +372,11 @@ enum vf_state {
 #define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
 #define BE_FLAGS_VLAN_PROMISC			(1 << 4)
 #define BE_FLAGS_NAPI_ENABLED			(1 << 9)
-#define BE_UC_PMAC_COUNT		30
-#define BE_VF_UC_PMAC_COUNT		2
 #define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
+#define BE_FLAGS_VXLAN_OFFLOADS			(1 << 12)
 
+#define BE_UC_PMAC_COUNT			30
+#define BE_VF_UC_PMAC_COUNT			2
 /* Ethtool set_dump flags */
 #define LANCER_INITIATE_FW_DUMP			0x1
 
@@ -494,6 +496,7 @@ struct be_adapter {
 	u32 sli_family;
 	u8 hba_port_num;
 	u16 pvid;
+	__be16 vxlan_port;
 	struct phy_info phy;
 	u8 wol_cap;
 	bool wol_en;
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 28ac8dd..3bd1985 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -407,7 +407,8 @@ struct amap_eth_rx_compl_v1 {
 	u8 vntagp;		/* dword 2 */
 	u8 header_len[8];	/* dword 2 */
 	u8 header_split[2];	/* dword 2 */
-	u8 rsvd1[13];		/* dword 2 */
+	u8 rsvd1[12];		/* dword 2 */
+	u8 tunneled;
 	u8 valid;		/* dword 2 */
 	u8 rsshash[32];		/* dword 3 */
 } __packed;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 8790e54..fb40e04 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -23,6 +23,7 @@
 #include <linux/aer.h>
 #include <linux/if_bridge.h>
 #include <net/busy_poll.h>
+#include <net/vxlan.h>
 
 MODULE_VERSION(DRV_VER);
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -718,10 +719,23 @@ static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
 	return vlan_tag;
 }
 
+/* Used only for IP tunnel packets */
+static u16 skb_inner_ip_proto(struct sk_buff *skb)
+{
+	return (inner_ip_hdr(skb)->version == 4) ?
+		inner_ip_hdr(skb)->protocol : inner_ipv6_hdr(skb)->nexthdr;
+}
+
+static u16 skb_ip_proto(struct sk_buff *skb)
+{
+	return (ip_hdr(skb)->version == 4) ?
+		ip_hdr(skb)->protocol : ipv6_hdr(skb)->nexthdr;
+}
+
 static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		struct sk_buff *skb, u32 wrb_cnt, u32 len, bool skip_hw_vlan)
 {
-	u16 vlan_tag;
+	u16 vlan_tag, proto;
 
 	memset(hdr, 0, sizeof(*hdr));
 
@@ -734,9 +748,15 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		if (skb_is_gso_v6(skb) && !lancer_chip(adapter))
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso6, hdr, 1);
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		if (is_tcp_pkt(skb))
+		if (skb->encapsulation) {
+			AMAP_SET_BITS(struct amap_eth_hdr_wrb, ipcs, hdr, 1);
+			proto = skb_inner_ip_proto(skb);
+		} else {
+			proto = skb_ip_proto(skb);
+		}
+		if (proto == IPPROTO_TCP)
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, tcpcs, hdr, 1);
-		else if (is_udp_pkt(skb))
+		else if (proto == IPPROTO_UDP)
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, udpcs, hdr, 1);
 	}
 
@@ -1467,9 +1487,10 @@ static void be_rx_stats_update(struct be_rx_obj *rxo,
 static inline bool csum_passed(struct be_rx_compl_info *rxcp)
 {
 	/* L4 checksum is not reliable for non TCP/UDP packets.
-	 * Also ignore ipcksm for ipv6 pkts */
+	 * Also ignore ipcksm for ipv6 pkts
+	 */
 	return (rxcp->tcpf || rxcp->udpf) && rxcp->l4_csum &&
-				(rxcp->ip_csum || rxcp->ipv6);
+		(rxcp->ip_csum || rxcp->ipv6) && !rxcp->err;
 }
 
 static struct be_rx_page_info *get_rx_page_info(struct be_rx_obj *rxo)
@@ -1612,6 +1633,8 @@ static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
 	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (netdev->features & NETIF_F_RXHASH)
 		skb_set_hash(skb, rxcp->rss_hash, PKT_HASH_TYPE_L3);
+
+	skb->encapsulation = rxcp->tunneled;
 	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
@@ -1668,6 +1691,8 @@ static void be_rx_compl_process_gro(struct be_rx_obj *rxo,
 	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb_set_hash(skb, rxcp->rss_hash, PKT_HASH_TYPE_L3);
+
+	skb->encapsulation = rxcp->tunneled;
 	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
@@ -1704,6 +1729,8 @@ static void be_parse_rx_compl_v1(struct be_eth_rx_compl *compl,
 					       compl);
 	}
 	rxcp->port = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, port, compl);
+	rxcp->tunneled =
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, tunneled, compl);
 }
 
 static void be_parse_rx_compl_v0(struct be_eth_rx_compl *compl,
@@ -2834,6 +2861,9 @@ static int be_open(struct net_device *netdev)
 
 	netif_tx_start_all_queues(netdev);
 	be_roce_dev_open(adapter);
+
+	if (skyhawk_chip(adapter))
+		vxlan_get_rx_port(netdev);
 	return 0;
 err:
 	be_close(adapter->netdev);
@@ -4120,6 +4150,78 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       BRIDGE_MODE_VEPA : BRIDGE_MODE_VEB);
 }
 
+static void be_disable_vxlan_offloads(struct be_adapter *adapter)
+{
+	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS)
+		be_cmd_manage_iface(adapter, adapter->if_handle,
+				    OP_CONVERT_TUNNEL_TO_NORMAL);
+
+	if (adapter->vxlan_port)
+		be_cmd_set_vxlan_port(adapter, 0);
+
+	adapter->flags &= ~BE_FLAGS_VXLAN_OFFLOADS;
+	adapter->vxlan_port = 0;
+}
+
+static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
+			      __be16 port)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct device *dev = &adapter->pdev->dev;
+	int status;
+
+	if (lancer_chip(adapter) || BEx_chip(adapter))
+		return;
+
+	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
+		dev_warn(dev, "Cannot add UDP port %d for VxLAN offloads\n",
+			 be16_to_cpu(port));
+		dev_info(dev,
+			 "Only one UDP port supported for VxLAN offloads\n");
+		return;
+	}
+
+	status = be_cmd_manage_iface(adapter, adapter->if_handle,
+				     OP_CONVERT_NORMAL_TO_TUNNEL);
+	if (status) {
+		dev_warn(dev, "Failed to convert normal interface to tunnel\n");
+		goto err;
+	}
+
+	status = be_cmd_set_vxlan_port(adapter, port);
+	if (status) {
+		dev_warn(dev, "Failed to add VxLAN port\n");
+		goto err;
+	}
+	adapter->flags |= BE_FLAGS_VXLAN_OFFLOADS;
+	adapter->vxlan_port = port;
+
+	dev_info(dev, "Enabled VxLAN offloads for UDP port %d\n",
+		 be16_to_cpu(port));
+	return;
+err:
+	be_disable_vxlan_offloads(adapter);
+	return;
+}
+
+static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
+			      __be16 port)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	if (lancer_chip(adapter) || BEx_chip(adapter))
+		return;
+
+	if (adapter->vxlan_port != port)
+		return;
+
+	be_disable_vxlan_offloads(adapter);
+
+	dev_info(&adapter->pdev->dev,
+		 "Disabled VxLAN offloads for UDP port %d\n",
+		 be16_to_cpu(port));
+}
+
 static const struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
@@ -4142,14 +4244,22 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_bridge_setlink	= be_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= be_ndo_bridge_getlink,
 #ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= be_busy_poll
+	.ndo_busy_poll		= be_busy_poll,
 #endif
+	.ndo_add_vxlan_port	= be_add_vxlan_port,
+	.ndo_del_vxlan_port	= be_del_vxlan_port,
 };
 
 static void be_netdev_init(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
+	if (skyhawk_chip(adapter)) {
+		netdev->hw_enc_features = NETIF_F_SG | NETIF_F_IP_CSUM |
+					  NETIF_F_IPV6_CSUM | NETIF_F_TSO |
+					  NETIF_F_TSO6 | NETIF_F_GSO_UDP_TUNNEL;
+		netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+	}
 	netdev->hw_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
 		NETIF_F_HW_VLAN_CTAG_TX;
-- 
1.7.1
