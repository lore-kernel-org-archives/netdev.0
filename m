From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [RESENDv2 10/11] netxen: enable tso6, intr coalescing.
Date: Mon, 21 Jul 2008 19:44:09 -0700
Message-ID: <1216694650-23257-11-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:47603 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754965AbYGVCoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 22:44:12 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable tso6 and ipv6 checksum, interrupt coalescing for NX3031.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   40 +++++++++++
 drivers/net/netxen/netxen_nic_ethtool.c |  116 ++++++++++++++++++++++++++++++-
 drivers/net/netxen/netxen_nic_hw.c      |   47 +++++++-----
 drivers/net/netxen/netxen_nic_main.c    |   38 ++++++++--
 4 files changed, 213 insertions(+), 28 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 705fdf1..bcc551e 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1133,6 +1133,40 @@ typedef struct nx_mac_list_s {
 	uint8_t mac_addr[MAX_ADDR_LEN];
 } nx_mac_list_t;
 
+/*
+ * Interrupt coalescing defaults. The defaults are for 1500 MTU. It is
+ * adjusted based on configured MTU.
+ */
+#define NETXEN_DEFAULT_INTR_COALESCE_RX_TIME_US	3
+#define NETXEN_DEFAULT_INTR_COALESCE_RX_PACKETS	256
+#define NETXEN_DEFAULT_INTR_COALESCE_TX_PACKETS	64
+#define NETXEN_DEFAULT_INTR_COALESCE_TX_TIME_US	4
+
+#define NETXEN_NIC_INTR_DEFAULT			0x04
+
+typedef union {
+	struct {
+		uint16_t	rx_packets;
+		uint16_t	rx_time_us;
+		uint16_t	tx_packets;
+		uint16_t	tx_time_us;
+	} data;
+	uint64_t		word;
+} nx_nic_intr_coalesce_data_t;
+
+typedef struct {
+	uint16_t			stats_time_us;
+	uint16_t			rate_sample_time;
+	uint16_t			flags;
+	uint16_t			rsvd_1;
+	uint32_t			low_threshold;
+	uint32_t			high_threshold;
+	nx_nic_intr_coalesce_data_t	normal;
+	nx_nic_intr_coalesce_data_t	low;
+	nx_nic_intr_coalesce_data_t	high;
+	nx_nic_intr_coalesce_data_t	irq;
+} nx_nic_intr_coalesce_t;
+
 typedef struct {
 	u64 qhdr;
 	u64 req_hdr;
@@ -1158,6 +1192,10 @@ typedef struct {
 
 #define NETXEN_DB_MAPSIZE_BYTES    	0x1000
 
+#define NETXEN_NETDEV_WEIGHT 120
+#define NETXEN_ADAPTER_UP_MAGIC 777
+#define NETXEN_NIC_PEG_TUNE 0
+
 struct netxen_dummy_dma {
 	void *addr;
 	dma_addr_t phys_addr;
@@ -1236,6 +1274,7 @@ struct netxen_adapter {
 
 	int is_up;
 	struct netxen_dummy_dma dummy_dma;
+	nx_nic_intr_coalesce_t coal;
 
 	/* Context interface shared between card and host */
 	struct netxen_ring_ctx *ctx_desc;
@@ -1423,6 +1462,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter);
 u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
 void netxen_p2_nic_set_multi(struct net_device *netdev);
 void netxen_p3_nic_set_multi(struct net_device *netdev);
+int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
 
 u32 nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, u32 mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 381d55a..48ee06b 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -752,6 +752,117 @@ static int netxen_nic_set_rx_csum(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static u32 netxen_nic_get_tso(struct net_device *dev)
+{
+	struct netxen_adapter *adapter = netdev_priv(dev);
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return (dev->features & (NETIF_F_TSO | NETIF_F_TSO6)) != 0;
+
+	return (dev->features & NETIF_F_TSO) != 0;
+}
+
+static int netxen_nic_set_tso(struct net_device *dev, u32 data)
+{
+	if (data) {
+		struct netxen_adapter *adapter = netdev_priv(dev);
+
+		dev->features |= NETIF_F_TSO;
+		if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+			dev->features |= NETIF_F_TSO6;
+	} else
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+
+	return 0;
+}
+
+/*
+ * Set the coalescing parameters. Currently only normal is supported.
+ * If rx_coalesce_usecs == 0 or rx_max_coalesced_frames == 0 then set the
+ * firmware coalescing to default.
+ */
+static int netxen_set_intr_coalesce(struct net_device *netdev,
+			struct ethtool_coalesce *ethcoal)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+
+	if (!NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return -EINVAL;
+
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return -EINVAL;
+
+	/*
+	* Return Error if unsupported values or
+	* unsupported parameters are set.
+	*/
+	if (ethcoal->rx_coalesce_usecs > 0xffff ||
+		ethcoal->rx_max_coalesced_frames > 0xffff ||
+		ethcoal->tx_coalesce_usecs > 0xffff ||
+		ethcoal->tx_max_coalesced_frames > 0xffff ||
+		ethcoal->rx_coalesce_usecs_irq ||
+		ethcoal->rx_max_coalesced_frames_irq ||
+		ethcoal->tx_coalesce_usecs_irq ||
+		ethcoal->tx_max_coalesced_frames_irq ||
+		ethcoal->stats_block_coalesce_usecs ||
+		ethcoal->use_adaptive_rx_coalesce ||
+		ethcoal->use_adaptive_tx_coalesce ||
+		ethcoal->pkt_rate_low ||
+		ethcoal->rx_coalesce_usecs_low ||
+		ethcoal->rx_max_coalesced_frames_low ||
+		ethcoal->tx_coalesce_usecs_low ||
+		ethcoal->tx_max_coalesced_frames_low ||
+		ethcoal->pkt_rate_high ||
+		ethcoal->rx_coalesce_usecs_high ||
+		ethcoal->rx_max_coalesced_frames_high ||
+		ethcoal->tx_coalesce_usecs_high ||
+		ethcoal->tx_max_coalesced_frames_high)
+		return -EINVAL;
+
+	if (!ethcoal->rx_coalesce_usecs ||
+		!ethcoal->rx_max_coalesced_frames) {
+		adapter->coal.flags = NETXEN_NIC_INTR_DEFAULT;
+		adapter->coal.normal.data.rx_time_us =
+			NETXEN_DEFAULT_INTR_COALESCE_RX_TIME_US;
+		adapter->coal.normal.data.rx_packets =
+			NETXEN_DEFAULT_INTR_COALESCE_RX_PACKETS;
+	} else {
+		adapter->coal.flags = 0;
+		adapter->coal.normal.data.rx_time_us =
+		ethcoal->rx_coalesce_usecs;
+		adapter->coal.normal.data.rx_packets =
+		ethcoal->rx_max_coalesced_frames;
+	}
+	adapter->coal.normal.data.tx_time_us = ethcoal->tx_coalesce_usecs;
+	adapter->coal.normal.data.tx_packets =
+	ethcoal->tx_max_coalesced_frames;
+
+	netxen_config_intr_coalesce(adapter);
+
+	return 0;
+}
+
+static int netxen_get_intr_coalesce(struct net_device *netdev,
+			struct ethtool_coalesce *ethcoal)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+
+	if (!NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return -EINVAL;
+
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return -EINVAL;
+
+	ethcoal->rx_coalesce_usecs = adapter->coal.normal.data.rx_time_us;
+	ethcoal->tx_coalesce_usecs = adapter->coal.normal.data.tx_time_us;
+	ethcoal->rx_max_coalesced_frames =
+		adapter->coal.normal.data.rx_packets;
+	ethcoal->tx_max_coalesced_frames =
+		adapter->coal.normal.data.tx_packets;
+
+	return 0;
+}
+
 struct ethtool_ops netxen_nic_ethtool_ops = {
 	.get_settings = netxen_nic_get_settings,
 	.set_settings = netxen_nic_set_settings,
@@ -769,11 +880,14 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
 	.set_pauseparam = netxen_nic_set_pauseparam,
 	.set_tx_csum = ethtool_op_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
-	.set_tso = ethtool_op_set_tso,
+	.get_tso = netxen_nic_get_tso,
+	.set_tso = netxen_nic_set_tso,
 	.self_test = netxen_nic_diag_test,
 	.get_strings = netxen_nic_get_strings,
 	.get_ethtool_stats = netxen_nic_get_ethtool_stats,
 	.get_sset_count = netxen_get_sset_count,
 	.get_rx_csum = netxen_nic_get_rx_csum,
 	.set_rx_csum = netxen_nic_set_rx_csum,
+	.get_coalesce = netxen_get_intr_coalesce,
+	.set_coalesce = netxen_set_intr_coalesce,
 };
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9d4e9c9..ed8aa5a 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -615,6 +615,33 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 	}
 }
 
+#define	NETXEN_CONFIG_INTR_COALESCE	3
+
+/*
+ * Send the interrupt coalescing parameter set by ethtool to the card.
+ */
+int netxen_config_intr_coalesce(struct netxen_adapter *adapter)
+{
+	nx_nic_req_t req;
+	int rv;
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+
+	req.qhdr |= (NIC_REQUEST << 23);
+	req.req_hdr |= NETXEN_CONFIG_INTR_COALESCE;
+	req.req_hdr |= ((u64)adapter->portnum << 16);
+
+	memcpy(&req.words[0], &adapter->coal, sizeof(adapter->coal));
+
+	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0) {
+		printk(KERN_ERR "ERROR. Could not send "
+			"interrupt coalescing parameters\n");
+	}
+
+	return rv;
+}
+
 /*
  * netxen_nic_change_mtu - Change the Maximum Transfer Unit
  * @returns 0 on success, negative on failure
@@ -651,26 +678,6 @@ int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 	return 0;
 }
 
-void netxen_tso_check(struct netxen_adapter *adapter,
-		      struct cmd_desc_type0 *desc, struct sk_buff *skb)
-{
-	if (desc->mss) {
-		desc->total_hdr_length = (sizeof(struct ethhdr) +
-					  ip_hdrlen(skb) + tcp_hdrlen(skb));
-		netxen_set_cmd_desc_opcode(desc, TX_TCP_LSO);
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		if (ip_hdr(skb)->protocol == IPPROTO_TCP) {
-			netxen_set_cmd_desc_opcode(desc, TX_TCP_PKT);
-		} else if (ip_hdr(skb)->protocol == IPPROTO_UDP) {
-			netxen_set_cmd_desc_opcode(desc, TX_UDP_PKT);
-		} else {
-			return;
-		}
-	}
-	desc->tcp_hdr_offset = skb_transport_offset(skb);
-	desc->ip_hdr_offset = skb_network_offset(skb);
-}
-
 int netxen_is_flash_supported(struct netxen_adapter *adapter)
 {
 	const int locs[] = { 0, 0x4, 0x100, 0x4000, 0x4128 };
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b3c084f..91d209a 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -58,10 +58,6 @@ static int use_msi = 1;
 
 static int use_msi_x = 1;
 
-#define NETXEN_NETDEV_WEIGHT 120
-#define NETXEN_ADAPTER_UP_MAGIC 777
-#define NETXEN_NIC_PEG_TUNE 0
-
 /* Local functions to NetXen NIC driver */
 static int __devinit netxen_nic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
@@ -735,8 +731,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->features = NETIF_F_SG;
 	netdev->features |= NETIF_F_IP_CSUM;
 	netdev->features |= NETIF_F_TSO;
-	if (NX_IS_REVISION_P3(revision_id))
+	if (NX_IS_REVISION_P3(revision_id)) {
+		netdev->features |= NETIF_F_IPV6_CSUM;
 		netdev->features |= NETIF_F_TSO6;
+	}
 
 	if (adapter->pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -1164,6 +1162,31 @@ static int netxen_nic_close(struct net_device *netdev)
 	return 0;
 }
 
+void netxen_tso_check(struct netxen_adapter *adapter,
+		      struct cmd_desc_type0 *desc, struct sk_buff *skb)
+{
+	if (desc->mss) {
+		desc->total_hdr_length = (sizeof(struct ethhdr) +
+					  ip_hdrlen(skb) + tcp_hdrlen(skb));
+
+		if ((NX_IS_REVISION_P3(adapter->ahw.revision_id)) &&
+				(skb->protocol == htons(ETH_P_IPV6)))
+			netxen_set_cmd_desc_opcode(desc, TX_TCP_LSO6);
+		else
+			netxen_set_cmd_desc_opcode(desc, TX_TCP_LSO);
+
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+			netxen_set_cmd_desc_opcode(desc, TX_TCP_PKT);
+		else if (ip_hdr(skb)->protocol == IPPROTO_UDP)
+			netxen_set_cmd_desc_opcode(desc, TX_UDP_PKT);
+		else
+			return;
+	}
+	desc->tcp_hdr_offset = skb_transport_offset(skb);
+	desc->ip_hdr_offset = skb_network_offset(skb);
+}
+
 static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
@@ -1185,7 +1208,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	/* There 4 fragments per descriptor */
 	no_of_desc = (frag_count + 3) >> 2;
-	if (netdev->features & NETIF_F_TSO) {
+	if (netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) {
 		if (skb_shinfo(skb)->gso_size > 0) {
 
 			no_of_desc++;
@@ -1212,7 +1235,8 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
 	/* Take skb->data itself */
 	pbuf = &adapter->cmd_buf_arr[producer];
-	if ((netdev->features & NETIF_F_TSO) && skb_shinfo(skb)->gso_size > 0) {
+	if ((netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
+			skb_shinfo(skb)->gso_size > 0) {
 		pbuf->mss = skb_shinfo(skb)->gso_size;
 		hwdesc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 	} else {
-- 
1.5.4.3

