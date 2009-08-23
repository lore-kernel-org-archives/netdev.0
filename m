From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 1/5] netxen: ethtool statistics and control for LRO
Date: Sun, 23 Aug 2009 11:35:09 -0700
Message-ID: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Narender Kumar <narender.kumar@qlogic.com>
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:19504 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S933716AbZHWSfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 14:35:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narender Kumar <narender.kumar@qlogic.com>

Add ethtool -K knob to control LRO in firmware.
LRO path is completely separated from GRO, LRO packets
are still fed with netif_receive_skb().

Also fix ethtool statistics to include LRO packets.
Also use correct message type while configuring interrupt coalescing.

Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   22 +++++++++++-
 drivers/net/netxen/netxen_nic_ctx.c     |    2 -
 drivers/net/netxen/netxen_nic_ethtool.c |   27 ++++++++++++++-
 drivers/net/netxen/netxen_nic_hw.c      |   56 ++++++++++++++++++++++++++++++-
 drivers/net/netxen/netxen_nic_init.c    |    7 +++-
 drivers/net/netxen/netxen_nic_main.c    |    8 ++++-
 6 files changed, 114 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 5abb41e..fa43aa0 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -576,7 +576,8 @@ struct netxen_adapter_stats {
 	u64  rxdropped;
 	u64  txdropped;
 	u64  csummed;
-	u64  no_rcv;
+	u64  rx_pkts;
+	u64  lro_pkts;
 	u64  rxbytes;
 	u64  txbytes;
 };
@@ -958,7 +959,8 @@ typedef struct {
 #define NX_NIC_H2C_OPCODE_PROXY_STOP_DONE		20
 #define NX_NIC_H2C_OPCODE_GET_LINKEVENT			21
 #define NX_NIC_C2C_OPCODE				22
-#define NX_NIC_H2C_OPCODE_LAST				23
+#define NX_NIC_H2C_OPCODE_CONFIG_HW_LRO			24
+#define NX_NIC_H2C_OPCODE_LAST				25
 
 /*
  * Firmware --> Driver
@@ -984,6 +986,19 @@ typedef struct {
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
 #define VPORT_MISS_MODE_ACCEPT_MULTI	2 /* accept unmatched multicast */
 
+#define NX_NIC_LRO_REQUEST_FIRST		0
+#define NX_NIC_LRO_REQUEST_ADD_FLOW		1
+#define NX_NIC_LRO_REQUEST_DELETE_FLOW		2
+#define NX_NIC_LRO_REQUEST_TIMER		3
+#define NX_NIC_LRO_REQUEST_CLEANUP		4
+#define NX_NIC_LRO_REQUEST_ADD_FLOW_SCHEDULED	5
+#define NX_TOE_LRO_REQUEST_ADD_FLOW		6
+#define NX_TOE_LRO_REQUEST_ADD_FLOW_RESPONSE	7
+#define NX_TOE_LRO_REQUEST_DELETE_FLOW		8
+#define NX_TOE_LRO_REQUEST_DELETE_FLOW_RESPONSE	9
+#define NX_TOE_LRO_REQUEST_TIMER		10
+#define NX_NIC_LRO_REQUEST_LAST			11
+
 #define NX_FW_CAPABILITY_LINK_NOTIFICATION	(1 << 5)
 #define NX_FW_CAPABILITY_SWITCHING		(1 << 6)
 #define NX_FW_CAPABILITY_PEXQ			(1 << 7)
@@ -1064,6 +1079,7 @@ typedef struct {
 
 #define NETXEN_NIC_MSI_ENABLED		0x02
 #define NETXEN_NIC_MSIX_ENABLED		0x04
+#define NETXEN_NIC_LRO_ENABLED		0x08
 #define NETXEN_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED))
 
@@ -1290,6 +1306,8 @@ void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup);
 
 int nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
+int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable);
+int netxen_send_lro_cleanup(struct netxen_adapter *adapter);
 
 int netxen_nic_set_mac(struct net_device *netdev, void *p);
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 412d658..9e04696 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -203,8 +203,6 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	cap = (NX_CAP0_LEGACY_CONTEXT | NX_CAP0_LEGACY_MN);
 	cap |= (NX_CAP0_JUMBO_CONTIGUOUS | NX_CAP0_LRO_CONTIGUOUS);
-	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
-		cap |= NX_CAP0_HW_LRO;
 
 	prq->capabilities[0] = cpu_to_le32(cap);
 	prq->host_int_crb_mode =
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 39a308c..db66e70 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -57,7 +57,8 @@ static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
 	{"rx_dropped", NETXEN_NIC_STAT(stats.rxdropped)},
 	{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
 	{"csummed", NETXEN_NIC_STAT(stats.csummed)},
-	{"no_rcv", NETXEN_NIC_STAT(stats.no_rcv)},
+	{"rx_pkts", NETXEN_NIC_STAT(stats.rx_pkts)},
+	{"lro_pkts", NETXEN_NIC_STAT(stats.lro_pkts)},
 	{"rx_bytes", NETXEN_NIC_STAT(stats.rxbytes)},
 	{"tx_bytes", NETXEN_NIC_STAT(stats.txbytes)},
 };
@@ -941,6 +942,28 @@ static int netxen_get_intr_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int netxen_nic_set_flags(struct net_device *netdev, u32 data)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	int hw_lro;
+
+	if (!(adapter->capabilities & NX_FW_CAPABILITY_HW_LRO))
+		return -EINVAL;
+
+	ethtool_op_set_flags(netdev, data);
+
+	hw_lro = (data & ETH_FLAG_LRO) ? NETXEN_NIC_LRO_ENABLED : 0;
+
+	if (netxen_config_hw_lro(adapter, hw_lro))
+		return -EIO;
+
+	if ((hw_lro == 0) && netxen_send_lro_cleanup(adapter))
+		return -EIO;
+
+
+	return 0;
+}
+
 struct ethtool_ops netxen_nic_ethtool_ops = {
 	.get_settings = netxen_nic_get_settings,
 	.set_settings = netxen_nic_set_settings,
@@ -968,4 +991,6 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
 	.set_rx_csum = netxen_nic_set_rx_csum,
 	.get_coalesce = netxen_get_intr_coalesce,
 	.set_coalesce = netxen_set_intr_coalesce,
+	.get_flags = ethtool_op_get_flags,
+	.set_flags = netxen_nic_set_flags,
 };
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 673dcf5..965f783 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -643,7 +643,7 @@ int netxen_config_intr_coalesce(struct netxen_adapter *adapter)
 
 	memset(&req, 0, sizeof(nx_nic_req_t));
 
-	req.qhdr = cpu_to_le64(NX_NIC_REQUEST << 23);
+	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
 
 	word = NETXEN_CONFIG_INTR_COALESCE | ((u64)adapter->portnum << 16);
 	req.req_hdr = cpu_to_le64(word);
@@ -659,6 +659,35 @@ int netxen_config_intr_coalesce(struct netxen_adapter *adapter)
 	return rv;
 }
 
+int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable)
+{
+	nx_nic_req_t req;
+	u64 word;
+	int rv = 0;
+
+	if ((adapter->flags & NETXEN_NIC_LRO_ENABLED) == enable)
+		return 0;
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+
+	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
+
+	word = NX_NIC_H2C_OPCODE_CONFIG_HW_LRO | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64(enable);
+
+	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0) {
+		printk(KERN_ERR "ERROR. Could not send "
+			"configure hw lro request\n");
+	}
+
+	adapter->flags ^= NETXEN_NIC_LRO_ENABLED;
+
+	return rv;
+}
+
 #define RSS_HASHTYPE_IP_TCP	0x3
 
 int netxen_config_rss(struct netxen_adapter *adapter, int enable)
@@ -752,6 +781,29 @@ int netxen_linkevent_request(struct netxen_adapter *adapter, int enable)
 	return rv;
 }
 
+int netxen_send_lro_cleanup(struct netxen_adapter *adapter)
+{
+	nx_nic_req_t req;
+	u64 word;
+	int rv;
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
+
+	word = NX_NIC_H2C_OPCODE_LRO_REQUEST |
+		((u64)adapter->portnum << 16) |
+		((u64)NX_NIC_LRO_REQUEST_CLEANUP << 56) ;
+
+	req.req_hdr = cpu_to_le64(word);
+
+	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0) {
+		printk(KERN_ERR "%s: could not cleanup lro flows\n",
+				adapter->netdev->name);
+	}
+	return rv;
+}
+
 /*
  * netxen_nic_change_mtu - Change the Maximum Transfer Unit
  * @returns 0 on success, negative on failure
@@ -2066,6 +2118,8 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 
 	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222))
 		adapter->capabilities = NXRD32(adapter, CRB_FW_CAPABILITIES_1);
+
+	adapter->flags &= ~NETXEN_NIC_LRO_ENABLED;
 }
 
 int
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index e8bdbf9..c3609e4 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1277,7 +1277,7 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 
 	napi_gro_receive(&sds_ring->napi, skb);
 
-	adapter->stats.no_rcv++;
+	adapter->stats.rx_pkts++;
 	adapter->stats.rxbytes += length;
 
 	return buffer;
@@ -1350,8 +1350,13 @@ netxen_process_lro(struct netxen_adapter *adapter,
 	th->psh = push;
 	th->seq = htonl(seq_number);
 
+	length = skb->len;
+
 	netif_receive_skb(skb);
 
+	adapter->stats.lro_pkts++;
+	adapter->stats.rxbytes += length;
+
 	return buffer;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 4e3fb30..de67e42 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -892,6 +892,9 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		netxen_config_intr_coalesce(adapter);
 
+	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
+		netxen_config_hw_lro(adapter, NETXEN_NIC_LRO_ENABLED);
+
 	netxen_napi_enable(adapter);
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_LINK_NOTIFICATION)
@@ -1077,6 +1080,9 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 	if (adapter->capabilities & NX_FW_CAPABILITY_FVLANTX)
 		netdev->features |= (NETIF_F_HW_VLAN_TX);
 
+	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
+		netdev->features |= NETIF_F_LRO;
+
 	netdev->irq = adapter->msix_entries[0].vector;
 
 	err = netxen_napi_add(adapter, netdev);
@@ -1812,7 +1818,7 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 
 	memset(stats, 0, sizeof(*stats));
 
-	stats->rx_packets = adapter->stats.no_rcv;
+	stats->rx_packets = adapter->stats.rx_pkts + adapter->stats.lro_pkts;
 	stats->tx_packets = adapter->stats.xmitfinished;
 	stats->rx_bytes = adapter->stats.rxbytes;
 	stats->tx_bytes = adapter->stats.txbytes;
-- 
1.6.0.2

