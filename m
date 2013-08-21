From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 4/5] qlcnic: Implement ndo_get_phys_port_id for 82xx adapter
Date: Wed, 21 Aug 2013 11:24:13 -0400
Message-ID: <fa6e15e3f70d8e7e73893ab0e610f7fc177a2e09.1377122994.git.himanshu.madhani@qlogic.com>
References: <cover.1377122994.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34579 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752089Ab3HUPwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 11:52:43 -0400
In-Reply-To: <cover.1377122994.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Each function driver instance uses the MAC address of the
lowest function belonging to that physical port as a unique
port identifier. This port identifier is read and cached in
driver during probe and provided to user space through
ndo_get_phys_port_id()

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 17 ++++++++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  4 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |  5 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     | 16 +++++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 28 +++++++++++++++++++---
 7 files changed, 63 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 45a5a2a..9d8f80e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -471,6 +471,7 @@ struct qlcnic_hardware_context {
 	u32 mbox_reg[4];
 	struct qlcnic_mailbox *mailbox;
 	u8 extend_lb_time;
+	u8 phys_port_id[ETH_ALEN];
 };
 
 struct qlcnic_adapter_stats {
@@ -926,6 +927,8 @@ struct qlcnic_ipaddr {
 #define QLCNIC_FW_LRO_MSS_CAP		0x8000
 #define QLCNIC_TX_INTR_SHARED		0x10000
 #define QLCNIC_APP_CHANGED_FLAGS	0x20000
+#define QLCNIC_HAS_PHYS_PORT_ID		0x40000
+
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 #define QLCNIC_IS_TSO_CAPABLE(adapter)  \
@@ -1510,6 +1513,7 @@ void __qlcnic_set_multi(struct net_device *, u16);
 int qlcnic_nic_add_mac(struct qlcnic_adapter *, const u8 *, u16);
 int qlcnic_nic_del_mac(struct qlcnic_adapter *, const u8 *);
 void qlcnic_82xx_free_mac_list(struct qlcnic_adapter *adapter);
+int qlcnic_82xx_read_phys_port_id(struct qlcnic_adapter *);
 
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
 int qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *, u32);
@@ -1679,7 +1683,7 @@ struct qlcnic_hardware_ops {
 	int (*read_reg) (struct qlcnic_adapter *, ulong, int *);
 	int (*write_reg) (struct qlcnic_adapter *, ulong, u32);
 	void (*get_ocm_win) (struct qlcnic_hardware_context *);
-	int (*get_mac_address) (struct qlcnic_adapter *, u8 *);
+	int (*get_mac_address) (struct qlcnic_adapter *, u8 *, u8);
 	int (*setup_intr) (struct qlcnic_adapter *, u8, int);
 	int (*alloc_mbx_args)(struct qlcnic_cmd_args *,
 			      struct qlcnic_adapter *, u32);
@@ -1713,6 +1717,7 @@ struct qlcnic_hardware_ops {
 	int (*get_board_info) (struct qlcnic_adapter *);
 	void (*set_mac_filter_count) (struct qlcnic_adapter *);
 	void (*free_mac_list) (struct qlcnic_adapter *);
+	int (*read_phys_port_id) (struct qlcnic_adapter *);
 };
 
 extern struct qlcnic_nic_template qlcnic_vf_ops;
@@ -1741,9 +1746,9 @@ static inline int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter,
 }
 
 static inline int qlcnic_get_mac_address(struct qlcnic_adapter *adapter,
-					 u8 *mac)
+					 u8 *mac, u8 function)
 {
-	return adapter->ahw->hw_ops->get_mac_address(adapter, mac);
+	return adapter->ahw->hw_ops->get_mac_address(adapter, mac, function);
 }
 
 static inline int qlcnic_setup_intr(struct qlcnic_adapter *adapter,
@@ -1940,6 +1945,12 @@ static inline void qlcnic_set_mac_filter_count(struct qlcnic_adapter *adapter)
 		adapter->ahw->hw_ops->set_mac_filter_count(adapter);
 }
 
+static inline void qlcnic_read_phys_port_id(struct qlcnic_adapter *adapter)
+{
+	if (adapter->ahw->hw_ops->read_phys_port_id)
+		adapter->ahw->hw_ops->read_phys_port_id(adapter);
+}
+
 static inline void qlcnic_dev_request_reset(struct qlcnic_adapter *adapter,
 					    u32 key)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index ea44828..6c059f9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2037,12 +2037,14 @@ void qlcnic_83xx_configure_mac(struct qlcnic_adapter *adapter, u8 *mac,
 	cmd->req.arg[1] = type;
 }
 
-int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
+int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac,
+				u8 function)
 {
 	int err, i;
 	struct qlcnic_cmd_args cmd;
 	u32 mac_low, mac_high;
 
+	function = 0;
 	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_MAC_ADDRESS);
 	if (err)
 		return err;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index bfd2741..0fc5616 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -564,7 +564,7 @@ int qlcnic_83xx_setup_link_event(struct qlcnic_adapter *, int);
 void qlcnic_83xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *);
 int qlcnic_83xx_config_intrpt(struct qlcnic_adapter *, bool);
 int qlcnic_83xx_sre_macaddr_change(struct qlcnic_adapter *, u8 *, u16, u8);
-int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *, u8 *);
+int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *, u8 *, u8);
 void qlcnic_83xx_configure_mac(struct qlcnic_adapter *, u8 *, u8,
 			       struct qlcnic_cmd_args *);
 int qlcnic_83xx_alloc_mbx_args(struct qlcnic_cmd_args *,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 2b68779..d4f0e95 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -821,7 +821,8 @@ int qlcnic_82xx_config_intrpt(struct qlcnic_adapter *adapter, u8 op_type)
 	return err;
 }
 
-int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
+int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac,
+				u8 function)
 {
 	int err, i;
 	struct qlcnic_cmd_args cmd;
@@ -831,7 +832,7 @@ int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 	if (err)
 		return err;
 
-	cmd.req.arg[1] = adapter->ahw->pci_func | BIT_8;
+	cmd.req.arg[1] = function | BIT_8;
 	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 9e49c15..f8adc7b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -740,6 +740,22 @@ int qlcnic_82xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 	return 0;
 }
 
+int qlcnic_82xx_read_phys_port_id(struct qlcnic_adapter *adapter)
+{
+	u8 mac[ETH_ALEN];
+	int ret;
+
+	ret = qlcnic_get_mac_address(adapter, mac,
+				     adapter->ahw->physical_port);
+	if (ret)
+		return ret;
+
+	memcpy(adapter->ahw->phys_port_id, mac, ETH_ALEN);
+	adapter->flags |= QLCNIC_HAS_PHYS_PORT_ID;
+
+	return 0;
+}
+
 /*
  * Send the interrupt coalescing parameter set by ethtool to the card.
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index cf35220..786366c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -186,7 +186,7 @@ void qlcnic_82xx_fw_cmd_del_rx_ctx(struct qlcnic_adapter *);
 void qlcnic_82xx_fw_cmd_del_tx_ctx(struct qlcnic_adapter *,
 				   struct qlcnic_host_tx_ring *);
 int qlcnic_82xx_sre_macaddr_change(struct qlcnic_adapter *, u8 *, u16, u8);
-int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *, u8*);
+int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *, u8*, u8);
 int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
 int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
 int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 25a858f..8321d1a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -284,12 +284,15 @@ void qlcnic_free_sds_rings(struct qlcnic_recv_context *recv_ctx)
 
 int qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 {
-	u8 mac_addr[ETH_ALEN];
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
+	u8 mac_addr[ETH_ALEN];
+	int ret;
 
-	if (qlcnic_get_mac_address(adapter, mac_addr) != 0)
-		return -EIO;
+	ret = qlcnic_get_mac_address(adapter, mac_addr,
+				     adapter->ahw->pci_func);
+	if (ret)
+		return ret;
 
 	memcpy(netdev->dev_addr, mac_addr, ETH_ALEN);
 	memcpy(adapter->mac_addr, netdev->dev_addr, netdev->addr_len);
@@ -431,6 +434,21 @@ static void qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
 	cancel_delayed_work_sync(&adapter->fw_work);
 }
 
+static int qlcnic_get_phys_port_id(struct net_device *netdev,
+				   struct netdev_phys_port_id *ppid)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	if (!(adapter->flags & QLCNIC_HAS_PHYS_PORT_ID))
+		return -EOPNOTSUPP;
+
+	ppid->id_len = sizeof(ahw->phys_port_id);
+	memcpy(ppid->id, ahw->phys_port_id, ppid->id_len);
+
+	return 0;
+}
+
 static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_open	   = qlcnic_open,
 	.ndo_stop	   = qlcnic_close,
@@ -448,6 +466,7 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_fdb_add		= qlcnic_fdb_add,
 	.ndo_fdb_del		= qlcnic_fdb_del,
 	.ndo_fdb_dump		= qlcnic_fdb_dump,
+	.ndo_get_phys_port_id	= qlcnic_get_phys_port_id,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = qlcnic_poll_controller,
 #endif
@@ -520,6 +539,7 @@ static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 	.get_board_info			= qlcnic_82xx_get_board_info,
 	.set_mac_filter_count		= qlcnic_82xx_set_mac_filter_count,
 	.free_mac_list			= qlcnic_82xx_free_mac_list,
+	.read_phys_port_id		= qlcnic_82xx_read_phys_port_id,
 };
 
 static void qlcnic_get_multiq_capability(struct qlcnic_adapter *adapter)
@@ -2245,6 +2265,8 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (qlcnic_read_mac_addr(adapter))
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
+	qlcnic_read_phys_port_id(adapter);
+
 	if (adapter->portnum == 0) {
 		qlcnic_get_board_name(adapter, board_name);
 
-- 
1.8.1.4
