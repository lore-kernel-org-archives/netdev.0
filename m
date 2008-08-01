From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 5/7] netxen: fix promisc mode, mtu setting
Date: Fri,  1 Aug 2008 03:14:59 -0700
Message-ID: <1217585701-13958-6-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:42820 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753319AbYHAKPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 06:15:06 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For NX3031, multicast filtering, promisc mode, and max frame size
setting is handled by firmware, driver needs to send request to
enable/disable it.

For old chip revisions / firmware, driver still sets it directly.

Added function pointer to set mtu according to chip revision.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   35 ++++++++++++++-
 drivers/net/netxen/netxen_nic_ctx.c  |    9 +++-
 drivers/net/netxen/netxen_nic_hw.c   |   77 ++++++++++++++++++---------------
 drivers/net/netxen/netxen_nic_hw.h   |   13 ++----
 drivers/net/netxen/netxen_nic_init.c |    5 ++
 drivers/net/netxen/netxen_nic_main.c |    4 +-
 drivers/net/netxen/netxen_nic_niu.c  |    4 +-
 7 files changed, 94 insertions(+), 53 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 22f9042..de180f2 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1171,6 +1171,36 @@ typedef struct {
 	nx_nic_intr_coalesce_data_t	irq;
 } nx_nic_intr_coalesce_t;
 
+#define NX_HOST_REQUEST		0x13
+#define NX_NIC_REQUEST		0x14
+
+#define NX_MAC_EVENT		0x1
+
+enum {
+	NX_NIC_H2C_OPCODE_START = 0,
+	NX_NIC_H2C_OPCODE_CONFIG_RSS,
+	NX_NIC_H2C_OPCODE_CONFIG_RSS_TBL,
+	NX_NIC_H2C_OPCODE_CONFIG_INTR_COALESCE,
+	NX_NIC_H2C_OPCODE_CONFIG_LED,
+	NX_NIC_H2C_OPCODE_CONFIG_PROMISCUOUS,
+	NX_NIC_H2C_OPCODE_CONFIG_L2_MAC,
+	NX_NIC_H2C_OPCODE_LRO_REQUEST,
+	NX_NIC_H2C_OPCODE_GET_SNMP_STATS,
+	NX_NIC_H2C_OPCODE_PROXY_START_REQUEST,
+	NX_NIC_H2C_OPCODE_PROXY_STOP_REQUEST,
+	NX_NIC_H2C_OPCODE_PROXY_SET_MTU,
+	NX_NIC_H2C_OPCODE_PROXY_SET_VPORT_MISS_MODE,
+	NX_H2P_OPCODE_GET_FINGER_PRINT_REQUEST,
+	NX_H2P_OPCODE_INSTALL_LICENSE_REQUEST,
+	NX_H2P_OPCODE_GET_LICENSE_CAPABILITY_REQUEST,
+	NX_NIC_H2C_OPCODE_GET_NET_STATS,
+	NX_NIC_H2C_OPCODE_LAST
+};
+
+#define VPORT_MISS_MODE_DROP		0 /* drop all unmatched */
+#define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
+#define VPORT_MISS_MODE_ACCEPT_MULTI	2 /* accept unmatched multicast */
+
 typedef struct {
 	u64 qhdr;
 	u64 req_hdr;
@@ -1289,7 +1319,7 @@ struct netxen_adapter {
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	int (*macaddr_set) (struct netxen_adapter *, netxen_ethernet_macaddr_t);
 	int (*set_mtu) (struct netxen_adapter *, int);
-	int (*set_promisc) (struct netxen_adapter *, netxen_niu_prom_mode_t);
+	int (*set_promisc) (struct netxen_adapter *, u32);
 	int (*phy_read) (struct netxen_adapter *, long reg, u32 *);
 	int (*phy_write) (struct netxen_adapter *, long reg, u32 val);
 	int (*init_port) (struct netxen_adapter *, int);
@@ -1466,9 +1496,10 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter);
 u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
 void netxen_p2_nic_set_multi(struct net_device *netdev);
 void netxen_p3_nic_set_multi(struct net_device *netdev);
+int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32);
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
 
-u32 nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, u32 mtu);
+int nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
 
 int netxen_nic_set_mac(struct net_device *netdev, void *p);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 64babc5..64b5164 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -145,8 +145,8 @@ netxen_issue_cmd(struct netxen_adapter *adapter,
 	return rcode;
 }
 
-u32
-nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, u32 mtu)
+int
+nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu)
 {
 	u32 rcode = NX_RCODE_SUCCESS;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx[0];
@@ -160,7 +160,10 @@ nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, u32 mtu)
 				0,
 				NX_CDRP_CMD_SET_MTU);
 
-	return rcode;
+	if (rcode != NX_RCODE_SUCCESS)
+		return -EIO;
+
+	return 0;
 }
 
 static int
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index d0c6935..4259f3f 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -285,14 +285,7 @@ static unsigned crb_hub_agt[64] =
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) <= (high)) && ((addr) >= (low)))
 
-#define NETXEN_MAX_MTU		8000 + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FCS_SIZE
-#define NETXEN_MIN_MTU		64
-#define NETXEN_ETH_FCS_SIZE     4
-#define NETXEN_ENET_HEADER_SIZE 14
 #define NETXEN_WINDOW_ONE 	0x2000000 /*CRB Window: bit 25 of CRB address */
-#define NETXEN_FIRMWARE_LEN 	((16 * 1024) / 4)
-#define NETXEN_NIU_HDRSIZE	(0x1 << 6)
-#define NETXEN_NIU_TLRSIZE	(0x1 << 5)
 
 #define NETXEN_NIC_ZERO_PAUSE_ADDR     0ULL
 #define NETXEN_NIC_UNIT_PAUSE_ADDR     0x200ULL
@@ -541,9 +534,6 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 	return 0;
 }
 
-#define NIC_REQUEST		0x14
-#define NETXEN_MAC_EVENT	0x1
-
 static int nx_p3_sre_macaddr_change(struct net_device *dev,
 		u8 *addr, unsigned op)
 {
@@ -553,8 +543,8 @@ static int nx_p3_sre_macaddr_change(struct net_device *dev,
 	int rv;
 
 	memset(&req, 0, sizeof(nx_nic_req_t));
-	req.qhdr |= (NIC_REQUEST << 23);
-	req.req_hdr |= NETXEN_MAC_EVENT;
+	req.qhdr |= (NX_NIC_REQUEST << 23);
+	req.req_hdr |= NX_MAC_EVENT;
 	req.req_hdr |= ((u64)adapter->portnum << 16);
 	mac_req.op = op;
 	memcpy(&mac_req.mac_addr, addr, 6);
@@ -575,31 +565,35 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 	nx_mac_list_t *cur, *next, *del_list, *add_list = NULL;
 	struct dev_mc_list *mc_ptr;
 	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
-
-	adapter->set_promisc(adapter, NETXEN_NIU_PROMISC_MODE);
-
-	/*
-	 * Programming mac addresses will automaticly enabling L2 filtering.
-	 * HW will replace timestamp with L2 conid when L2 filtering is
-	 * enabled. This causes problem for LSA. Do not enabling L2 filtering
-	 * until that problem is fixed.
-	 */
-	if ((netdev->flags & IFF_PROMISC) ||
-			(netdev->mc_count > adapter->max_mc_count))
-		return;
+	u32 mode = VPORT_MISS_MODE_DROP;
 
 	del_list = adapter->mac_list;
 	adapter->mac_list = NULL;
 
 	nx_p3_nic_add_mac(adapter, netdev->dev_addr, &add_list, &del_list);
+	nx_p3_nic_add_mac(adapter, bcast_addr, &add_list, &del_list);
+
+	if (netdev->flags & IFF_PROMISC) {
+		mode = VPORT_MISS_MODE_ACCEPT_ALL;
+		goto send_fw_cmd;
+	}
+
+	if ((netdev->flags & IFF_ALLMULTI) ||
+			(netdev->mc_count > adapter->max_mc_count)) {
+		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
+		goto send_fw_cmd;
+	}
+
 	if (netdev->mc_count > 0) {
-		nx_p3_nic_add_mac(adapter, bcast_addr, &add_list, &del_list);
 		for (mc_ptr = netdev->mc_list; mc_ptr;
 		     mc_ptr = mc_ptr->next) {
 			nx_p3_nic_add_mac(adapter, mc_ptr->dmi_addr,
 					  &add_list, &del_list);
 		}
 	}
+
+send_fw_cmd:
+	adapter->set_promisc(adapter, mode);
 	for (cur = del_list; cur;) {
 		nx_p3_sre_macaddr_change(netdev, cur->mac_addr, NETXEN_MAC_DEL);
 		next = cur->next;
@@ -615,6 +609,21 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 	}
 }
 
+int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
+{
+	nx_nic_req_t req;
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+
+	req.qhdr |= (NX_HOST_REQUEST << 23);
+	req.req_hdr |= NX_NIC_H2C_OPCODE_PROXY_SET_VPORT_MISS_MODE;
+	req.req_hdr |= ((u64)adapter->portnum << 16);
+	req.words[0] = cpu_to_le64(mode);
+
+	return netxen_send_cmd_descs(adapter,
+				(struct cmd_desc_type0 *)&req, 1);
+}
+
 #define	NETXEN_CONFIG_INTR_COALESCE	3
 
 /*
@@ -627,7 +636,7 @@ int netxen_config_intr_coalesce(struct netxen_adapter *adapter)
 
 	memset(&req, 0, sizeof(nx_nic_req_t));
 
-	req.qhdr |= (NIC_REQUEST << 23);
+	req.qhdr |= (NX_NIC_REQUEST << 23);
 	req.req_hdr |= NETXEN_CONFIG_INTR_COALESCE;
 	req.req_hdr |= ((u64)adapter->portnum << 16);
 
@@ -653,6 +662,7 @@ int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int max_mtu;
+	int rc = 0;
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		max_mtu = P3_MAX_MTU;
@@ -666,16 +676,12 @@ int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 	}
 
 	if (adapter->set_mtu)
-		adapter->set_mtu(adapter, mtu);
-	netdev->mtu = mtu;
+		rc = adapter->set_mtu(adapter, mtu);
 
-	mtu += MTU_FUDGE_FACTOR;
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		nx_fw_cmd_set_mtu(adapter, mtu);
-	else if (adapter->set_mtu)
-		adapter->set_mtu(adapter, mtu);
+	if (!rc)
+		netdev->mtu = mtu;
 
-	return 0;
+	return rc;
 }
 
 int netxen_is_flash_supported(struct netxen_adapter *adapter)
@@ -2047,6 +2053,7 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 
 int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu)
 {
+	new_mtu += MTU_FUDGE_FACTOR;
 	netxen_nic_write_w0(adapter,
 		NETXEN_NIU_GB_MAX_FRAME_SIZE(adapter->physical_port),
 		new_mtu);
@@ -2055,7 +2062,7 @@ int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu)
 
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 {
-	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
+	new_mtu += MTU_FUDGE_FACTOR;
 	if (adapter->physical_port == 0)
 		netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE,
 				new_mtu);
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index b8e0030..aae737d 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -419,12 +419,9 @@ typedef enum {
 #define netxen_get_niu_enable_ge(config_word)	\
 		_netxen_crb_get_bit(config_word, 1)
 
-/* Promiscous mode options (GbE mode only) */
-typedef enum {
-	NETXEN_NIU_PROMISC_MODE = 0,
-	NETXEN_NIU_NON_PROMISC_MODE,
-	NETXEN_NIU_ALLMULTI_MODE
-} netxen_niu_prom_mode_t;
+#define NETXEN_NIU_NON_PROMISC_MODE	0
+#define NETXEN_NIU_PROMISC_MODE		1
+#define NETXEN_NIU_ALLMULTI_MODE	2
 
 /*
  * NIU GB Drop CRC Register
@@ -471,9 +468,9 @@ typedef enum {
 
 /* Set promiscuous mode for a GbE interface */
 int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
-				    netxen_niu_prom_mode_t mode);
+				    u32 mode);
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
-				       netxen_niu_prom_mode_t mode);
+				       u32 mode);
 
 /* set the MAC address for a given MAC */
 int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 01ab31b..519fc86 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -364,6 +364,11 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 	default:
 		break;
 	}
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		adapter->set_mtu = nx_fw_cmd_set_mtu;
+		adapter->set_promisc = netxen_p3_nic_set_promisc;
+	}
 }
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 311a4bd..7615c71 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1113,9 +1113,7 @@ static int netxen_nic_open(struct net_device *netdev)
 	netxen_nic_set_link_parameters(adapter);
 
 	netdev->set_multicast_list(netdev);
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		nx_fw_cmd_set_mtu(adapter, netdev->mtu);
-	else
+	if (adapter->set_mtu)
 		adapter->set_mtu(adapter, netdev->mtu);
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index c9493e2..27f07f6 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -764,7 +764,7 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 
 /* Set promiscuous mode for a GbE interface */
 int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
-				    netxen_niu_prom_mode_t mode)
+		u32 mode)
 {
 	__u32 reg;
 	u32 port = adapter->physical_port;
@@ -906,7 +906,7 @@ int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
 #endif  /*  0  */
 
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
-				       netxen_niu_prom_mode_t mode)
+		u32 mode)
 {
 	__u32 reg;
 	u32 port = adapter->physical_port;
-- 
1.5.4.3

