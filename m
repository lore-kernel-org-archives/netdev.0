From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next v3 2/2] be2net: csum, tso and rss steering offload support for VxLAN
Date: Tue, 25 Mar 2014 19:20:30 +0530
Message-ID: <1395755430-17451-3-git-send-email-sathya.perla@emulex.com>
References: <1395755430-17451-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:17221 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbaCYNql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:46:41 -0400
In-Reply-To: <1395755430-17451-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch mainly implements the add/del_vxlan_port() methods by invoking
the needed FW cmds for supporting VxLAN offloads for Skyhawk-R.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |   14 ++-
 drivers/net/ethernet/emulex/benet/be_hw.h   |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  180 ++++++++++++++++++++++++++-
 3 files changed, 188 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a587c8a..eac61f7 100644
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
@@ -506,6 +509,13 @@ struct be_adapter {
 	u64 rss_flags;
 };
 
+/* Used for deffered FW config cmds. Add fields to this struct as reqd */
+struct be_config_work {
+	struct work_struct work;
+	struct be_adapter *adapter;
+	__be16 vxlan_port;
+};
+
 #define be_physfn(adapter)		(!adapter->virtfn)
 #define be_virtfn(adapter)		(adapter->virtfn)
 #define	sriov_enabled(adapter)		(adapter->num_vfs > 0)
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
index 8790e54..3a50982 100644
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
@@ -2989,13 +3019,30 @@ static void be_mac_clear(struct be_adapter *adapter)
 	}
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
 static int be_clear(struct be_adapter *adapter)
 {
 	be_cancel_worker(adapter);
 
+	flush_scheduled_work();
+
 	if (sriov_enabled(adapter))
 		be_vf_clear(adapter);
 
+	be_disable_vxlan_offloads(adapter);
+
 	/* delete the primary mac along with the uc-mac list */
 	be_mac_clear(adapter);
 
@@ -4120,6 +4167,119 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       BRIDGE_MODE_VEPA : BRIDGE_MODE_VEB);
 }
 
+static struct be_config_work *
+be_alloc_cfg_work(struct be_adapter *adapter, void (*fun)(struct work_struct *))
+{
+	struct be_config_work *cfg_work;
+
+	cfg_work = kzalloc(sizeof(*cfg_work), GFP_ATOMIC);
+	if (!cfg_work) {
+		dev_err(&adapter->pdev->dev,
+			"cfg_work memory allocation failed\n");
+		return NULL;
+	}
+
+	INIT_WORK(&cfg_work->work, fun);
+	cfg_work->adapter = adapter;
+	return cfg_work;
+}
+
+static void be_work_add_vxlan_port(struct work_struct *work)
+{
+	struct be_config_work *cfg_work =
+			container_of(work, struct be_config_work, work);
+	struct be_adapter *adapter = cfg_work->adapter;
+	struct device *dev = &adapter->pdev->dev;
+	int status;
+
+	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
+		dev_warn(dev, "Cannot add UDP port %d for VxLAN offloads\n",
+			 be16_to_cpu(cfg_work->vxlan_port));
+		dev_info(dev,
+			 "Only one UDP port supported for VxLAN offloads\n");
+		goto done;
+	}
+
+	status = be_cmd_manage_iface(adapter, adapter->if_handle,
+				     OP_CONVERT_NORMAL_TO_TUNNEL);
+	if (status) {
+		dev_warn(dev, "Failed to convert normal interface to tunnel\n");
+		goto err;
+	}
+
+	status = be_cmd_set_vxlan_port(adapter, cfg_work->vxlan_port);
+	if (status) {
+		dev_warn(dev, "Failed to add VxLAN port\n");
+		goto err;
+	}
+	adapter->flags |= BE_FLAGS_VXLAN_OFFLOADS;
+	adapter->vxlan_port = cfg_work->vxlan_port;
+
+	dev_info(dev, "Enabled VxLAN offloads for UDP port %d\n",
+		 be16_to_cpu(adapter->vxlan_port));
+	goto done;
+err:
+	be_disable_vxlan_offloads(adapter);
+done:
+	kfree(cfg_work);
+}
+
+static void be_work_del_vxlan_port(struct work_struct *work)
+{
+	struct be_config_work *cfg_work =
+			container_of(work, struct be_config_work, work);
+	struct be_adapter *adapter = cfg_work->adapter;
+
+	if (adapter->vxlan_port != cfg_work->vxlan_port)
+		goto done;
+
+	be_disable_vxlan_offloads(adapter);
+
+	dev_info(&adapter->pdev->dev,
+		 "Disabled VxLAN offloads for UDP port %d\n",
+		 be16_to_cpu(cfg_work->vxlan_port));
+done:
+	kfree(cfg_work);
+}
+
+static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
+			      __be16 port)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_config_work *cfg_work;
+
+	if (lancer_chip(adapter) || BEx_chip(adapter))
+		return;
+
+	cfg_work = be_alloc_cfg_work(adapter, be_work_add_vxlan_port);
+	if (!cfg_work) {
+		dev_err(&adapter->pdev->dev, "%s failed\n", __func__);
+		return;
+	}
+
+	cfg_work->vxlan_port = port;
+	schedule_work(&cfg_work->work);
+}
+
+static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
+			      __be16 port)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_config_work *cfg_work;
+
+	if (lancer_chip(adapter) || BEx_chip(adapter))
+		return;
+
+	cfg_work = be_alloc_cfg_work(adapter, be_work_del_vxlan_port);
+	if (!cfg_work) {
+		dev_err(&adapter->pdev->dev, "%s failed\n", __func__);
+		return;
+	}
+
+	cfg_work->vxlan_port = port;
+	schedule_work(&cfg_work->work);
+}
+
 static const struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
@@ -4142,14 +4302,22 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_bridge_setlink	= be_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= be_ndo_bridge_getlink,
 #ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= be_busy_poll
+	.ndo_busy_poll		= be_busy_poll,
 #endif
+	.ndo_add_vxlan_port	= be_add_vxlan_port,
+	.ndo_del_vxlan_port	= be_del_vxlan_port
 };
 
 static void be_netdev_init(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
+	if (skyhawk_chip(adapter)) {
+		netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+					   NETIF_F_TSO | NETIF_F_TSO6 |
+					   NETIF_F_GSO_UDP_TUNNEL;
+		netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+	}
 	netdev->hw_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
 		NETIF_F_HW_VLAN_CTAG_TX;
-- 
1.7.1
