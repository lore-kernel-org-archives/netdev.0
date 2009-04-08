From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 05/11] netxen: async link event handling
Date: Wed,  8 Apr 2009 01:50:42 -0700
Message-ID: <1239180648-29842-6-git-send-email-dhananjay@netxen.com>
References: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:49849 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762195AbZDHIu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 04:50:57 -0400
In-Reply-To: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for asynchronous events from firmware,
received over one of the rx rings.

Add support for event based phy interrupts, enhanced links
status reporting from firmware.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h          |  108 ++++++++++++++++++++++--------
 drivers/net/netxen/netxen_nic_ethtool.c  |   32 +++++++++-
 drivers/net/netxen/netxen_nic_hw.c       |   22 ++++++
 drivers/net/netxen/netxen_nic_init.c     |  102 ++++++++++++++++++++++++++--
 drivers/net/netxen/netxen_nic_main.c     |   55 +++++++++------
 drivers/net/netxen/netxen_nic_phan_reg.h |    1 +
 6 files changed, 263 insertions(+), 57 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 7e208b3..f4d7e2d 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -354,6 +354,7 @@ struct rcv_desc {
 /* opcode field in status_desc */
 #define NETXEN_NIC_RXPKT_DESC  0x04
 #define NETXEN_OLD_RXPKT_DESC  0x3f
+#define NETXEN_NIC_RESPONSE_DESC 0x05
 
 /* for status field in status_desc */
 #define STATUS_NEED_CKSUM	(1)
@@ -363,8 +364,11 @@ struct rcv_desc {
 #define STATUS_OWNER_HOST	(0x1ULL << 56)
 #define STATUS_OWNER_PHANTOM	(0x2ULL << 56)
 
-/* Note: sizeof(status_desc) should always be a mutliple of 2 */
-
+/* Status descriptor:
+   0-3 port, 4-7 status, 8-11 type, 12-27 total_length
+   28-43 reference_handle, 44-47 protocol, 48-52 pkt_offset
+   53-55 desc_cnt, 56-57 owner, 58-63 opcode
+ */
 #define netxen_get_sts_port(sts_data)	\
 	((sts_data) & 0x0F)
 #define netxen_get_sts_status(sts_data)	\
@@ -379,35 +383,13 @@ struct rcv_desc {
 	(((sts_data) >> 44) & 0x0F)
 #define netxen_get_sts_pkt_offset(sts_data)	\
 	(((sts_data) >> 48) & 0x1F)
+#define netxen_get_sts_desc_cnt(sts_data)	\
+	(((sts_data) >> 53) & 0x7)
 #define netxen_get_sts_opcode(sts_data)	\
 	(((sts_data) >> 58) & 0x03F)
 
 struct status_desc {
-	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
-	   28-43 reference_handle, 44-47 protocol, 48-52 pkt_offset
-	   53-55 desc_cnt, 56-57 owner, 58-63 opcode
-	 */
-	__le64 status_desc_data;
-	union {
-		struct {
-			__le32 hash_value;
-			u8 hash_type;
-			u8 msg_type;
-			u8 unused;
-			union {
-				/* Bit pattern: 0-6 lro_count indicates frag
-				 * sequence, 7 last_frag indicates last frag
-				 */
-				u8 lro;
-
-				/* chained buffers */
-				u8 nr_frags;
-			};
-		};
-		struct {
-			__le16 frag_handles[4];
-		};
-	};
+	__le64 status_desc_data[2];
 } __attribute__ ((aligned(16)));
 
 /* The version of the main data structure */
@@ -1114,6 +1096,66 @@ typedef struct {
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
 #define VPORT_MISS_MODE_ACCEPT_MULTI	2 /* accept unmatched multicast */
 
+#define NX_FW_CAPABILITY_LINK_NOTIFICATION	(1 << 5)
+#define NX_FW_CAPABILITY_SWITCHING		(1 << 6)
+
+/* module types */
+#define LINKEVENT_MODULE_NOT_PRESENT			1
+#define LINKEVENT_MODULE_OPTICAL_UNKNOWN		2
+#define LINKEVENT_MODULE_OPTICAL_SRLR			3
+#define LINKEVENT_MODULE_OPTICAL_LRM			4
+#define LINKEVENT_MODULE_OPTICAL_SFP_1G			5
+#define LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLE	6
+#define LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLELEN	7
+#define LINKEVENT_MODULE_TWINAX				8
+
+#define LINKSPEED_10GBPS	10000
+#define LINKSPEED_1GBPS		1000
+#define LINKSPEED_100MBPS	100
+#define LINKSPEED_10MBPS	10
+
+#define LINKSPEED_ENCODED_10MBPS	0
+#define LINKSPEED_ENCODED_100MBPS	1
+#define LINKSPEED_ENCODED_1GBPS		2
+
+#define LINKEVENT_AUTONEG_DISABLED	0
+#define LINKEVENT_AUTONEG_ENABLED	1
+
+#define LINKEVENT_HALF_DUPLEX		0
+#define LINKEVENT_FULL_DUPLEX		1
+
+#define LINKEVENT_LINKSPEED_MBPS	0
+#define LINKEVENT_LINKSPEED_ENCODED	1
+
+/* firmware response header:
+ *	63:58 - message type
+ *	57:56 - owner
+ *	55:53 - desc count
+ *	52:48 - reserved
+ *	47:40 - completion id
+ *	39:32 - opcode
+ *	31:16 - error code
+ *	15:00 - reserved
+ */
+#define netxen_get_nic_msgtype(msg_hdr)	\
+	((msg_hdr >> 58) & 0x3F)
+#define netxen_get_nic_msg_compid(msg_hdr)	\
+	((msg_hdr >> 40) & 0xFF)
+#define netxen_get_nic_msg_opcode(msg_hdr)	\
+	((msg_hdr >> 32) & 0xFF)
+#define netxen_get_nic_msg_errcode(msg_hdr)	\
+	((msg_hdr >> 16) & 0xFFFF)
+
+typedef struct {
+	union {
+		struct {
+			u64 hdr;
+			u64 body[7];
+		};
+		u64 words[8];
+	};
+} nx_fw_msg_t;
+
 typedef struct {
 	__le64 qhdr;
 	__le64 req_hdr;
@@ -1177,15 +1219,21 @@ struct netxen_adapter {
 
 	u8 mc_enabled;
 	u8 max_mc_count;
+	u16 resv2;
+	u32 resv3;
+
+	u8 has_link_events;
+	u8 resv1;
 	u16 tx_context_id;
 	u16 mtu;
 	u16 is_up;
+
 	u16 link_speed;
 	u16 link_duplex;
 	u16 link_autoneg;
-	u16 resv1;
+	u16 module_type;
 
-	u32 resv2;
+	u32 capabilities;
 	u32 flags;
 	u32 irq;
 	u32 temp;
@@ -1398,6 +1446,8 @@ void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
 int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32);
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
 int netxen_config_rss(struct netxen_adapter *adapter, int enable);
+int netxen_linkevent_request(struct netxen_adapter *adapter, int enable);
+void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup);
 
 int nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index fe910c1..5fde9e0 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -110,6 +110,7 @@ static int
 netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
+	int check_sfp_module = 0;
 
 	/* read which mode */
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
@@ -143,6 +144,13 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			ecmd->advertising = ADVERTISED_10000baseT_Full;
 		}
 
+		if (netif_running(dev) && adapter->has_link_events) {
+			ecmd->speed = adapter->link_speed;
+			ecmd->autoneg = adapter->link_autoneg;
+			ecmd->duplex = adapter->link_duplex;
+			goto skip;
+		}
+
 		ecmd->port = PORT_TP;
 
 		if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
@@ -160,6 +168,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	} else
 		return -EIO;
 
+skip:
 	ecmd->phy_address = adapter->physical_port;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
@@ -190,7 +199,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	case NETXEN_BRDTYPE_P3_HMEZ:
 		ecmd->supported |= SUPPORTED_MII;
 		ecmd->advertising |= ADVERTISED_MII;
-		ecmd->port = PORT_FIBRE;
+		ecmd->port = PORT_MII;
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
 	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
@@ -198,6 +207,8 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->supported |= SUPPORTED_TP;
+		check_sfp_module = netif_running(dev) &&
+			adapter->has_link_events;
 	case NETXEN_BRDTYPE_P2_SB31_10G:
 	case NETXEN_BRDTYPE_P3_10G_XFP:
 		ecmd->supported |= SUPPORTED_FIBRE;
@@ -212,6 +223,8 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			ecmd->advertising |=
 				(ADVERTISED_FIBRE | ADVERTISED_TP);
 			ecmd->port = PORT_FIBRE;
+			check_sfp_module = netif_running(dev) &&
+				adapter->has_link_events;
 		} else {
 			ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->supported |= (SUPPORTED_TP |SUPPORTED_Autoneg);
@@ -226,6 +239,23 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		return -EIO;
 	}
 
+	if (check_sfp_module) {
+		switch (adapter->module_type) {
+		case LINKEVENT_MODULE_OPTICAL_UNKNOWN:
+		case LINKEVENT_MODULE_OPTICAL_SRLR:
+		case LINKEVENT_MODULE_OPTICAL_LRM:
+		case LINKEVENT_MODULE_OPTICAL_SFP_1G:
+			ecmd->port = PORT_FIBRE;
+			break;
+		case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLE:
+		case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLELEN:
+		case LINKEVENT_MODULE_TWINAX:
+			ecmd->port = PORT_TP;
+		default:
+			ecmd->port = -1;
+		}
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 8416962..33444a2 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -731,6 +731,28 @@ int netxen_config_rss(struct netxen_adapter *adapter, int enable)
 	return rv;
 }
 
+int netxen_linkevent_request(struct netxen_adapter *adapter, int enable)
+{
+	nx_nic_req_t req;
+	u64 word;
+	int rv;
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
+
+	word = NX_NIC_H2C_OPCODE_GET_LINKEVENT | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+	req.words[0] = cpu_to_le64(enable);
+
+	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0) {
+		printk(KERN_ERR "%s: could not configure link notification\n",
+				adapter->netdev->name);
+	}
+
+	return rv;
+}
+
 /*
  * netxen_nic_change_mtu - Change the Maximum Transfer Unit
  * @returns 0 on success, negative on failure
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 9991951..974783c 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -795,9 +795,81 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 	adapter->pci_write_normalize(adapter,
 			CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
+	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222)) {
+		adapter->capabilities = netxen_nic_reg_read(adapter,
+				CRB_FW_CAPABILITIES_1);
+	}
+
 	return err;
 }
 
+static void
+netxen_handle_linkevent(struct netxen_adapter *adapter, nx_fw_msg_t *msg)
+{
+	u32 cable_OUI;
+	u16 cable_len;
+	u16 link_speed;
+	u8  link_status, module, duplex, autoneg;
+	struct net_device *netdev = adapter->netdev;
+
+	adapter->has_link_events = 1;
+
+	cable_OUI = msg->body[1] & 0xffffffff;
+	cable_len = (msg->body[1] >> 32) & 0xffff;
+	link_speed = (msg->body[1] >> 48) & 0xffff;
+
+	link_status = msg->body[2] & 0xff;
+	duplex = (msg->body[2] >> 16) & 0xff;
+	autoneg = (msg->body[2] >> 24) & 0xff;
+
+	module = (msg->body[2] >> 8) & 0xff;
+	if (module == LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLE) {
+		printk(KERN_INFO "%s: unsupported cable: OUI 0x%x, length %d\n",
+				netdev->name, cable_OUI, cable_len);
+	} else if (module == LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLELEN) {
+		printk(KERN_INFO "%s: unsupported cable length %d\n",
+				netdev->name, cable_len);
+	}
+
+	netxen_advert_link_change(adapter, link_status);
+
+	/* update link parameters */
+	if (duplex == LINKEVENT_FULL_DUPLEX)
+		adapter->link_duplex = DUPLEX_FULL;
+	else
+		adapter->link_duplex = DUPLEX_HALF;
+	adapter->module_type = module;
+	adapter->link_autoneg = autoneg;
+	adapter->link_speed = link_speed;
+}
+
+static void
+netxen_handle_fw_message(int desc_cnt, int index,
+		struct nx_host_sds_ring *sds_ring)
+{
+	nx_fw_msg_t msg;
+	struct status_desc *desc;
+	int i = 0, opcode;
+
+	while (desc_cnt > 0 && i < 8) {
+		desc = &sds_ring->desc_head[index];
+		msg.words[i++] = le64_to_cpu(desc->status_desc_data[0]);
+		msg.words[i++] = le64_to_cpu(desc->status_desc_data[1]);
+
+		index = get_next_index(index, sds_ring->num_desc);
+		desc_cnt--;
+	}
+
+	opcode = netxen_get_nic_msg_opcode(msg.body[0]);
+	switch (opcode) {
+	case NX_NIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE:
+		netxen_handle_linkevent(sds_ring->adapter, &msg);
+		break;
+	default:
+		break;
+	}
+}
+
 static int
 netxen_alloc_rx_skb(struct netxen_adapter *adapter,
 		struct nx_host_rds_ring *rds_ring,
@@ -916,21 +988,35 @@ netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max)
 
 	int count = 0;
 	u64 sts_data;
-	int opcode, ring, index, length, cksum, pkt_offset;
+	int opcode, ring, index, length, cksum, pkt_offset, desc_cnt;
 
 	while (count < max) {
 		desc = &sds_ring->desc_head[consumer];
-		sts_data = le64_to_cpu(desc->status_desc_data);
+		sts_data = le64_to_cpu(desc->status_desc_data[0]);
 
 		if (!(sts_data & STATUS_OWNER_HOST))
 			break;
 
+		desc_cnt = netxen_get_sts_desc_cnt(sts_data);
 		ring   = netxen_get_sts_type(sts_data);
+
 		if (ring > RCV_RING_JUMBO)
-			continue;
+			goto skip;
 
 		opcode = netxen_get_sts_opcode(sts_data);
 
+		switch (opcode) {
+		case NETXEN_NIC_RXPKT_DESC:
+		case NETXEN_OLD_RXPKT_DESC:
+			break;
+		case NETXEN_NIC_RESPONSE_DESC:
+			netxen_handle_fw_message(desc_cnt, consumer, sds_ring);
+		default:
+			goto skip;
+		}
+
+		WARN_ON(desc_cnt > 1);
+
 		index  = netxen_get_sts_refhandle(sts_data);
 		length = netxen_get_sts_totallength(sts_data);
 		cksum  = netxen_get_sts_status(sts_data);
@@ -942,9 +1028,13 @@ netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max)
 		if (rxbuf)
 			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
 
-		desc->status_desc_data = cpu_to_le64(STATUS_OWNER_PHANTOM);
-
-		consumer = get_next_index(consumer, sds_ring->num_desc);
+skip:
+		for (; desc_cnt > 0; desc_cnt--) {
+			desc = &sds_ring->desc_head[consumer];
+			desc->status_desc_data[0] =
+				cpu_to_le64(STATUS_OWNER_PHANTOM);
+			consumer = get_next_index(consumer, sds_ring->num_desc);
+		}
 		count++;
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f3fbe11..9050d62 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -787,6 +787,9 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (adapter->max_sds_rings > 1)
 		netxen_config_rss(adapter, 1);
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netxen_linkevent_request(adapter, 1);
+
 	return 0;
 }
 
@@ -1493,26 +1496,9 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 	return rv;
 }
 
-static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
+void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup)
 {
 	struct net_device *netdev = adapter->netdev;
-	u32 val, port, linkup;
-
-	port = adapter->physical_port;
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE_P3);
-		val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
-		linkup = (val == XG_LINK_UP_P3);
-	} else {
-		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
-		if (adapter->ahw.port_type == NETXEN_NIC_GBE)
-			linkup = (val >> port) & 1;
-		else {
-			val = (val >> port*8) & 0xff;
-			linkup = (val == XG_LINK_UP);
-		}
-	}
 
 	if (adapter->ahw.linkup && !linkup) {
 		printk(KERN_INFO "%s: %s NIC Link is down\n",
@@ -1523,7 +1509,9 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 			netif_stop_queue(netdev);
 		}
 
-		netxen_nic_set_link_parameters(adapter);
+		if (!adapter->has_link_events)
+			netxen_nic_set_link_parameters(adapter);
+
 	} else if (!adapter->ahw.linkup && linkup) {
 		printk(KERN_INFO "%s: %s NIC Link is up\n",
 		       netxen_nic_driver_name, netdev->name);
@@ -1533,10 +1521,34 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 			netif_wake_queue(netdev);
 		}
 
-		netxen_nic_set_link_parameters(adapter);
+		if (!adapter->has_link_events)
+			netxen_nic_set_link_parameters(adapter);
 	}
 }
 
+static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
+{
+	u32 val, port, linkup;
+
+	port = adapter->physical_port;
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE_P3);
+		val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
+		linkup = (val == XG_LINK_UP_P3);
+	} else {
+		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
+		if (adapter->ahw.port_type == NETXEN_NIC_GBE)
+			linkup = (val >> port) & 1;
+		else {
+			val = (val >> port*8) & 0xff;
+			linkup = (val == XG_LINK_UP);
+		}
+	}
+
+	netxen_advert_link_change(adapter, linkup);
+}
+
 static void netxen_watchdog(unsigned long v)
 {
 	struct netxen_adapter *adapter = (struct netxen_adapter *)v;
@@ -1552,7 +1564,8 @@ void netxen_watchdog_task(struct work_struct *work)
 	if ((adapter->portnum  == 0) && netxen_nic_check_temp(adapter))
 		return;
 
-	netxen_nic_handle_phy_intr(adapter);
+	if (!adapter->has_link_events)
+		netxen_nic_handle_phy_intr(adapter);
 
 	if (netif_running(adapter->netdev))
 		mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 18ea35d..ecd622e 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -134,6 +134,7 @@
 #define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
 #define CRB_NIC_MSI_MODE_HOST		NETXEN_NIC_REG(0x270)
 #define CRB_NIC_MSI_MODE_FW	  	NETXEN_NIC_REG(0x274)
+#define CRB_FW_CAPABILITIES_1		NETXEN_NIC_REG(0x128)
 
 #define INTR_SCHEME_PERPORT	      	0x1
 #define MSI_MODE_MULTIFUNC	      	0x1
-- 
1.6.0.2

