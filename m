From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [RESENDv2 08/11] netxen: mtu, mac, link status changes
Date: Mon, 21 Jul 2008 19:44:07 -0700
Message-ID: <1216694650-23257-9-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:47599 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754956AbYGVCoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 22:44:12 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAC addr, multicast filters, mtu are set through firmware commands
in firmware v4.0.0+ because of virtualization of physical ports.
Link status is also read from registers allocated by firmware for
each virtual port.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h          |   12 +-
 drivers/net/netxen/netxen_nic_hdr.h      |    6 +
 drivers/net/netxen/netxen_nic_hw.c       |  198 +++++++++++++++++++++++++++---
 drivers/net/netxen/netxen_nic_init.c     |    2 +-
 drivers/net/netxen/netxen_nic_main.c     |   35 ++++--
 drivers/net/netxen/netxen_nic_niu.c      |   22 ++--
 drivers/net/netxen/netxen_nic_phan_reg.h |    4 +-
 7 files changed, 236 insertions(+), 43 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 9362190..e41f623 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1119,7 +1119,7 @@ typedef struct {
 	u64 qhdr;
 	u64 req_hdr;
 	u64 words[6];
-} nic_request_t;
+} nx_nic_req_t;
 
 typedef struct {
 	u8 op;
@@ -1127,6 +1127,7 @@ typedef struct {
 	u8 mac_addr[6];
 } nx_mac_req_t;
 
+#define MAX_PENDING_DESC_BLOCK_SIZE	64
 
 #define NETXEN_NIC_MSI_ENABLED		0x02
 #define NETXEN_NIC_MSIX_ENABLED		0x04
@@ -1152,7 +1153,6 @@ struct netxen_adapter {
 	int pci_using_dac;
 	struct napi_struct napi;
 	struct net_device_stats net_stats;
-	unsigned char mac_addr[ETH_ALEN];
 	int mtu;
 	int portnum;
 	u8 physical_port;
@@ -1160,6 +1160,7 @@ struct netxen_adapter {
 
 	uint8_t		mc_enabled;
 	uint8_t		max_mc_count;
+	nx_mac_list_t	*mac_list;
 
 	struct netxen_legacy_intr_set legacy_intr;
 	u32	crb_intr_mask;
@@ -1231,7 +1232,6 @@ struct netxen_adapter {
 	int (*phy_read) (struct netxen_adapter *, long reg, u32 *);
 	int (*phy_write) (struct netxen_adapter *, long reg, u32 val);
 	int (*init_port) (struct netxen_adapter *, int);
-	void (*init_niu) (struct netxen_adapter *);
 	int (*stop_port) (struct netxen_adapter *);
 
 	int (*hw_read_wx)(struct netxen_adapter *, ulong, void *, int);
@@ -1316,7 +1316,6 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
 /* Functions available from netxen_nic_hw.c */
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu);
 int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu);
-void netxen_nic_init_niu_gb(struct netxen_adapter *adapter);
 void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val);
 int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off);
 void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32 value);
@@ -1404,7 +1403,8 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx,
 			    u32 ringid);
 int netxen_process_cmd_ring(struct netxen_adapter *adapter);
 u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
-void netxen_nic_set_multi(struct net_device *netdev);
+void netxen_p2_nic_set_multi(struct net_device *netdev);
+void netxen_p3_nic_set_multi(struct net_device *netdev);
 
 u32 nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, u32 mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
@@ -1412,6 +1412,8 @@ int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
 int netxen_nic_set_mac(struct net_device *netdev, void *p);
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
 
+void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
+		uint32_t crb_producer);
 
 /*
  * NetXen Board information
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 2374d8d..3ce13e4 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -718,6 +718,12 @@ enum {
 #define XG_LINK_UP	0x10
 #define XG_LINK_DOWN	0x20
 
+#define XG_LINK_UP_P3	0x01
+#define XG_LINK_DOWN_P3	0x02
+#define XG_LINK_STATE_P3_MASK 0xf
+#define XG_LINK_STATE_P3(pcifn,val) \
+	(((val) >> ((pcifn) * 4)) & XG_LINK_STATE_P3_MASK)
+
 #define NETXEN_CAM_RAM_BASE	(NETXEN_CRB_CAM + 0x02000)
 #define NETXEN_CAM_RAM(reg)	(NETXEN_CAM_RAM_BASE + (reg))
 #define NETXEN_FW_VERSION_MAJOR (NETXEN_CAM_RAM(0x150))
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index d46b4df..9d4e9c9 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -314,8 +314,10 @@ int netxen_nic_set_mac(struct net_device *netdev, void *p)
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
-	if (adapter->macaddr_set)
-		adapter->macaddr_set(adapter, addr->sa_data);
+	/* For P3, MAC addr is not set in NIU */
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		if (adapter->macaddr_set)
+			adapter->macaddr_set(adapter, addr->sa_data);
 
 	return 0;
 }
@@ -405,10 +407,7 @@ netxen_nic_set_mcast_addr(struct netxen_adapter *adapter,
 	return 0;
 }
 
-/*
- * netxen_nic_set_multi - Multicast
- */
-void netxen_nic_set_multi(struct net_device *netdev)
+void netxen_p2_nic_set_multi(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct dev_mc_list *mc_ptr;
@@ -456,18 +455,186 @@ void netxen_nic_set_multi(struct net_device *netdev)
 		netxen_nic_set_mcast_addr(adapter, index, null_addr);
 }
 
+static int nx_p3_nic_add_mac(struct netxen_adapter *adapter,
+		u8 *addr, nx_mac_list_t **add_list, nx_mac_list_t **del_list)
+{
+	nx_mac_list_t *cur, *prev;
+
+	/* if in del_list, move it to adapter->mac_list */
+	for (cur = *del_list, prev = NULL; cur;) {
+		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0) {
+			if (prev == NULL)
+				*del_list = cur->next;
+			else
+				prev->next = cur->next;
+			cur->next = adapter->mac_list;
+			adapter->mac_list = cur;
+			return 0;
+		}
+		prev = cur;
+		cur = cur->next;
+	}
+
+	/* make sure to add each mac address only once */
+	for (cur = adapter->mac_list; cur; cur = cur->next) {
+		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0)
+			return 0;
+	}
+	/* not in del_list, create new entry and add to add_list */
+	cur = kmalloc(sizeof(*cur), in_atomic()? GFP_ATOMIC : GFP_KERNEL);
+	if (cur == NULL) {
+		printk(KERN_ERR "%s: cannot allocate memory. MAC filtering may"
+				"not work properly from now.\n", __func__);
+		return -1;
+	}
+
+	memcpy(cur->mac_addr, addr, ETH_ALEN);
+	cur->next = *add_list;
+	*add_list = cur;
+	return 0;
+}
+
+static int
+netxen_send_cmd_descs(struct netxen_adapter *adapter,
+		struct cmd_desc_type0 *cmd_desc_arr, int nr_elements)
+{
+	uint32_t i, producer;
+	struct netxen_cmd_buffer *pbuf;
+	struct cmd_desc_type0 *cmd_desc;
+
+	if (nr_elements > MAX_PENDING_DESC_BLOCK_SIZE || nr_elements == 0) {
+		printk(KERN_WARNING "%s: Too many command descriptors in a "
+			      "request\n", __func__);
+		return -EINVAL;
+	}
+
+	i = 0;
+
+	producer = adapter->cmd_producer;
+	do {
+		cmd_desc = &cmd_desc_arr[i];
+
+		pbuf = &adapter->cmd_buf_arr[producer];
+		pbuf->mss = 0;
+		pbuf->total_length = 0;
+		pbuf->skb = NULL;
+		pbuf->cmd = 0;
+		pbuf->frag_count = 0;
+		pbuf->port = 0;
+
+		/* adapter->ahw.cmd_desc_head[producer] = *cmd_desc; */
+		memcpy(&adapter->ahw.cmd_desc_head[producer],
+			&cmd_desc_arr[i], sizeof(struct cmd_desc_type0));
+
+		producer = get_next_index(producer,
+				adapter->max_tx_desc_count);
+		i++;
+
+	} while (i != nr_elements);
+
+	adapter->cmd_producer = producer;
+
+	/* write producer index to start the xmit */
+
+	netxen_nic_update_cmd_producer(adapter, adapter->cmd_producer);
+
+	return 0;
+}
+
+#define NIC_REQUEST		0x14
+#define NETXEN_MAC_EVENT	0x1
+
+static int nx_p3_sre_macaddr_change(struct net_device *dev,
+		u8 *addr, unsigned op)
+{
+	struct netxen_adapter *adapter = (struct netxen_adapter *)dev->priv;
+	nx_nic_req_t req;
+	nx_mac_req_t mac_req;
+	int rv;
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+	req.qhdr |= (NIC_REQUEST << 23);
+	req.req_hdr |= NETXEN_MAC_EVENT;
+	req.req_hdr |= ((u64)adapter->portnum << 16);
+	mac_req.op = op;
+	memcpy(&mac_req.mac_addr, addr, 6);
+	req.words[0] = cpu_to_le64(*(u64 *)&mac_req);
+
+	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0) {
+		printk(KERN_ERR "ERROR. Could not send mac update\n");
+		return rv;
+	}
+
+	return 0;
+}
+
+void netxen_p3_nic_set_multi(struct net_device *netdev)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	nx_mac_list_t *cur, *next, *del_list, *add_list = NULL;
+	struct dev_mc_list *mc_ptr;
+	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+
+	adapter->set_promisc(adapter, NETXEN_NIU_PROMISC_MODE);
+
+	/*
+	 * Programming mac addresses will automaticly enabling L2 filtering.
+	 * HW will replace timestamp with L2 conid when L2 filtering is
+	 * enabled. This causes problem for LSA. Do not enabling L2 filtering
+	 * until that problem is fixed.
+	 */
+	if ((netdev->flags & IFF_PROMISC) ||
+			(netdev->mc_count > adapter->max_mc_count))
+		return;
+
+	del_list = adapter->mac_list;
+	adapter->mac_list = NULL;
+
+	nx_p3_nic_add_mac(adapter, netdev->dev_addr, &add_list, &del_list);
+	if (netdev->mc_count > 0) {
+		nx_p3_nic_add_mac(adapter, bcast_addr, &add_list, &del_list);
+		for (mc_ptr = netdev->mc_list; mc_ptr;
+		     mc_ptr = mc_ptr->next) {
+			nx_p3_nic_add_mac(adapter, mc_ptr->dmi_addr,
+					  &add_list, &del_list);
+		}
+	}
+	for (cur = del_list; cur;) {
+		nx_p3_sre_macaddr_change(netdev, cur->mac_addr, NETXEN_MAC_DEL);
+		next = cur->next;
+		kfree(cur);
+		cur = next;
+	}
+	for (cur = add_list; cur;) {
+		nx_p3_sre_macaddr_change(netdev, cur->mac_addr, NETXEN_MAC_ADD);
+		next = cur->next;
+		cur->next = adapter->mac_list;
+		adapter->mac_list = cur;
+		cur = next;
+	}
+}
+
 /*
  * netxen_nic_change_mtu - Change the Maximum Transfer Unit
  * @returns 0 on success, negative on failure
  */
+
+#define MTU_FUDGE_FACTOR	100
+
 int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	int eff_mtu = mtu + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FCS_SIZE;
+	int max_mtu;
 
-	if ((eff_mtu > NETXEN_MAX_MTU) || (eff_mtu < NETXEN_MIN_MTU)) {
-		printk(KERN_ERR "%s: %s %d is not supported.\n",
-		       netxen_nic_driver_name, netdev->name, mtu);
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		max_mtu = P3_MAX_MTU;
+	else
+		max_mtu = P2_MAX_MTU;
+
+	if (mtu > max_mtu) {
+		printk(KERN_ERR "%s: mtu > %d bytes unsupported\n",
+				netdev->name, max_mtu);
 		return -EINVAL;
 	}
 
@@ -475,6 +642,12 @@ int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 		adapter->set_mtu(adapter, mtu);
 	netdev->mtu = mtu;
 
+	mtu += MTU_FUDGE_FACTOR;
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		nx_fw_cmd_set_mtu(adapter, mtu);
+	else if (adapter->set_mtu)
+		adapter->set_mtu(adapter, mtu);
+
 	return 0;
 }
 
@@ -1882,11 +2055,6 @@ int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 	return 0;
 }
 
-void netxen_nic_init_niu_gb(struct netxen_adapter *adapter)
-{
-	netxen_niu_gbe_init_port(adapter, adapter->physical_port);
-}
-
 void
 netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
 		unsigned long off, int data)
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index d222436..7b51240 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -329,7 +329,7 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 		adapter->set_promisc = netxen_niu_set_promiscuous_mode;
 		adapter->phy_read = netxen_niu_gbe_phy_read;
 		adapter->phy_write = netxen_niu_gbe_phy_write;
-		adapter->init_niu = netxen_nic_init_niu_gb;
+		adapter->init_port = netxen_niu_gbe_init_port;
 		adapter->stop_port = netxen_niu_disable_gbe_port;
 		break;
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 03d796d..df48f89 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -123,7 +123,7 @@ static uint32_t crb_cmd_producer[4] = {
 	CRB_CMD_PRODUCER_OFFSET_2, CRB_CMD_PRODUCER_OFFSET_3
 };
 
-static inline void
+void
 netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
 		uint32_t crb_producer)
 {
@@ -716,7 +716,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->stop		   = netxen_nic_close;
 	netdev->hard_start_xmit    = netxen_nic_xmit_frame;
 	netdev->get_stats	   = netxen_nic_get_stats;
-	netdev->set_multicast_list = netxen_nic_set_multi;
+	if (NX_IS_REVISION_P3(revision_id))
+		netdev->set_multicast_list = netxen_p3_nic_set_multi;
+	else
+		netdev->set_multicast_list = netxen_p2_nic_set_multi;
 	netdev->set_mac_address    = netxen_nic_set_mac;
 	netdev->change_mtu	   = netxen_nic_change_mtu;
 	netdev->tx_timeout	   = netxen_tx_timeout;
@@ -1100,7 +1103,7 @@ static int netxen_nic_open(struct net_device *netdev)
 
 	/* Done here again so that even if phantom sw overwrote it,
 	 * we set it */
-	err = adapter->init_port(adapter, adapter->portnum);
+	err = adapter->init_port(adapter, adapter->physical_port);
 	if (err) {
 		printk(KERN_ERR "%s: Failed to initialize port %d\n",
 				netxen_nic_driver_name, adapter->portnum);
@@ -1110,8 +1113,11 @@ static int netxen_nic_open(struct net_device *netdev)
 
 	netxen_nic_set_link_parameters(adapter);
 
-	netxen_nic_set_multi(netdev);
-	adapter->set_mtu(adapter, netdev->mtu);
+	netdev->set_multicast_list(netdev);
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		nx_fw_cmd_set_mtu(adapter, netdev->mtu);
+	else
+		adapter->set_mtu(adapter, netdev->mtu);
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
@@ -1379,12 +1385,21 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 
 	port = adapter->physical_port;
 
-	val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE)
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
+		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
 		linkup = (val >> port) & 1;
-	else {
-		val = (val >> port*8) & 0xff;
-		linkup = (val == XG_LINK_UP);
+	} else {
+		if (adapter->fw_major < 4) {
+			val = adapter->pci_read_normalize(adapter,
+					CRB_XG_STATE);
+			val = (val >> port*8) & 0xff;
+			linkup = (val == XG_LINK_UP);
+		} else {
+			val = adapter->pci_read_normalize(adapter,
+				CRB_XG_STATE_P3);
+			val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
+			linkup = (val == XG_LINK_UP_P3);
+		}
 	}
 
 	if (adapter->ahw.linkup && !linkup) {
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 78905d9..4cb8f4a 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -400,14 +400,16 @@ int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 {
 	int result = 0;
 	__u32 status;
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return 0;
+
 	if (adapter->disable_phy_interrupts)
 		adapter->disable_phy_interrupts(adapter);
 	mdelay(2);
 
-	if (0 ==
-	    netxen_niu_gbe_phy_read(adapter,
-				    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-				    &status)) {
+	if (0 == netxen_niu_gbe_phy_read(adapter,
+			NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS, &status)) {
 		if (netxen_get_phy_link(status)) {
 			if (netxen_get_phy_speed(status) == 2) {
 				netxen_niu_gbe_set_gmii_mode(adapter, port, 1);
@@ -455,12 +457,12 @@ int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
-	u32 portnum = adapter->physical_port;
-
-	netxen_crb_writelit_adapter(adapter,
-		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), 0x1447);
-	netxen_crb_writelit_adapter(adapter,
-		NETXEN_NIU_XGE_CONFIG_0+(0x10000*portnum), 0x5);
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		netxen_crb_writelit_adapter(adapter,
+			NETXEN_NIU_XGE_CONFIG_1+(0x10000*port), 0x1447);
+		netxen_crb_writelit_adapter(adapter,
+			NETXEN_NIU_XGE_CONFIG_0+(0x10000*port), 0x5);
+	}
 
 	return 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index a637623..3bfa51b 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -76,8 +76,8 @@
 #define CRB_RX_LRO_MID_TIMER        NETXEN_NIC_REG(0x88)
 #define CRB_DMA_MAX_RCV_BUFS        NETXEN_NIC_REG(0x8c)
 #define CRB_MAX_DMA_ENTRIES         NETXEN_NIC_REG(0x90)
-#define CRB_XG_STATE                NETXEN_NIC_REG(0x94)	/* XG Link status */
-#define CRB_AGENT_GO                NETXEN_NIC_REG(0x98)	/* NIC pkt gen agent */
+#define CRB_XG_STATE                NETXEN_NIC_REG(0x94) /* XG Link status */
+#define CRB_XG_STATE_P3             NETXEN_NIC_REG(0x98) /* XG PF Link status */
 #define CRB_AGENT_TX_SIZE           NETXEN_NIC_REG(0x9c)
 #define CRB_AGENT_TX_TYPE           NETXEN_NIC_REG(0xa0)
 #define CRB_AGENT_TX_ADDR           NETXEN_NIC_REG(0xa4)
-- 
1.5.4.3

