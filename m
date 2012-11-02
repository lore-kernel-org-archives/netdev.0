From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V5 05/22] qlcnic: change driver hardware interface mechanism
Date: Thu,  1 Nov 2012 21:06:37 -0400
Message-ID: <1351818414-25197-6-git-send-email-sony.chacko@qlogic.com>
References: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:55440 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1760135Ab2KBB0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 21:26:09 -0400
In-Reply-To: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA

Create adapter abstraction layer
Create mailbox based HW interface mechanism
Seperate 82xx adapter hardware specific routines

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  327 +++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |  493 +++++++++++---------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   19 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    5 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   99 +++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |  160 +++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   13 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  317 ++++++++------
 8 files changed, 993 insertions(+), 440 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 3ec57fc..4631484 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -490,6 +490,7 @@ struct qlcnic_hardware_context {
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
+	u32 *reg_tbl;
 };
 
 struct qlcnic_adapter_stats {
@@ -585,10 +586,6 @@ struct qlcnic_recv_context {
 /* HW context creation */
 
 #define QLCNIC_OS_CRB_RETRY_COUNT	4000
-
-#define QLCNIC_CDRP_SIGNATURE_MAKE(pcifn, version) \
-	(((pcifn) & 0xff) | (((version) & 0xff) << 8) | (0xcafe << 16))
-
 #define QLCNIC_CDRP_CMD_BIT		0x80000000
 
 /*
@@ -1215,7 +1212,7 @@ do {	\
 			(VAL1) += (VAL2); \
 } while (0)
 
-struct qlcnic_mac_statistics{
+struct qlcnic_mac_statistics {
 	__le64	mac_tx_frames;
 	__le64	mac_tx_bytes;
 	__le64	mac_tx_mcast_pkts;
@@ -1425,10 +1422,8 @@ struct qlcnic_dump_operations {
 };
 
 struct _cdrp_cmd {
-	u32 cmd;
-	u32 arg1;
-	u32 arg2;
-	u32 arg3;
+	u32 num;
+	u32 *arg;
 };
 
 struct qlcnic_cmd_args {
@@ -1439,8 +1434,6 @@ struct qlcnic_cmd_args {
 int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter);
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
 
-int qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off);
-int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
 void qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *, u64, u64 *);
@@ -1450,10 +1443,10 @@ void qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *, u64, u64);
 	(((addr) < (high)) && ((addr) >= (low)))
 
 #define QLCRD32(adapter, off) \
-	(qlcnic_hw_read_wx_2M(adapter, off))
+	(adapter->ahw->hw_ops->read_reg)(adapter, off)
 
 #define QLCWR32(adapter, off, val) \
-	(qlcnic_hw_write_wx_2M(adapter, off, val))
+	adapter->ahw->hw_ops->write_reg(adapter, off, val)
 
 int qlcnic_pcie_sem_lock(struct qlcnic_adapter *, int, u32);
 void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
@@ -1466,10 +1459,6 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 	qlcnic_pcie_sem_lock((a), 3, QLCNIC_PHY_LOCK_ID)
 #define qlcnic_phy_unlock(a)	\
 	qlcnic_pcie_sem_unlock((a), 3)
-#define qlcnic_api_lock(a)	\
-	qlcnic_pcie_sem_lock((a), 5, 0)
-#define qlcnic_api_unlock(a)	\
-	qlcnic_pcie_sem_unlock((a), 5)
 #define qlcnic_sw_lock(a)	\
 	qlcnic_pcie_sem_lock((a), 6, 0)
 #define qlcnic_sw_unlock(a)	\
@@ -1482,9 +1471,7 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 #define __QLCNIC_MAX_LED_RATE	0xf
 #define __QLCNIC_MAX_LED_STATE	0x2
 
-int qlcnic_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
-int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 int qlcnic_dump_fw(struct qlcnic_adapter *);
@@ -1523,46 +1510,32 @@ void qlcnic_post_rx_buffers(struct qlcnic_adapter *,
 int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max);
 void qlcnic_set_multi(struct net_device *netdev);
 void qlcnic_free_mac_list(struct qlcnic_adapter *adapter);
-int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
-int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter);
-int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable);
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd);
-int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable);
-void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup);
 
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features);
 int qlcnic_set_features(struct net_device *netdev, netdev_features_t features);
-int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
 int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring);
-void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
-void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter);
-int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode);
 
 /* Functions from qlcnic_ethtool.c */
 int qlcnic_check_loopback_buff(unsigned char *data, u8 mac[]);
 
 /* Functions from qlcnic_main.c */
 int qlcnic_reset_context(struct qlcnic_adapter *);
-void qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *);
 void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings);
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
-int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val);
 int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data);
-void qlcnic_dev_request_reset(struct qlcnic_adapter *);
+int qlcnic_validate_max_rss(struct net_device *netdev, u8, u8);
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 
 /* Management functions */
-int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
-int qlcnic_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
-int qlcnic_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
-int qlcnic_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
+int qlcnic_poll(struct napi_struct *, int);
+int qlcnic_rx_poll(struct napi_struct *, int);
 
 /*  eSwitch management functions */
 int qlcnic_config_switch_port(struct qlcnic_adapter *,
@@ -1576,17 +1549,13 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *, const u8, u8,
 					struct __qlcnic_esw_statistics *);
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, u8, u8, u8);
 int qlcnic_get_mac_stats(struct qlcnic_adapter *, struct qlcnic_mac_statistics *);
-extern int qlcnic_config_tso;
-
-void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);
-int qlcnic_napi_add(struct qlcnic_adapter *, struct net_device *);
-void qlcnic_napi_del(struct qlcnic_adapter *adapter);
-void qlcnic_napi_enable(struct qlcnic_adapter *adapter);
-void qlcnic_napi_disable(struct qlcnic_adapter *adapter);
+void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd);
+void qlcnic_napi_del(struct qlcnic_adapter *);
 int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *, int);
 void qlcnic_free_sds_rings(struct qlcnic_recv_context *);
 void qlcnic_free_tx_rings(struct qlcnic_adapter *);
 int qlcnic_alloc_tx_rings(struct qlcnic_adapter *, struct net_device *);
+void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);
 
 /*
  * QLOGIC Board information
@@ -1634,6 +1603,271 @@ static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 				tx_ring->producer;
 }
 
+struct qlcnic_nic_template {
+	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
+	int (*config_led) (struct qlcnic_adapter *, u32, u32);
+	int (*start_firmware) (struct qlcnic_adapter *);
+	int (*init_driver) (struct qlcnic_adapter *);
+	void (*request_reset) (struct qlcnic_adapter *, u32);
+	void (*cancel_idc_work) (struct qlcnic_adapter *);
+	int (*napi_add)(struct qlcnic_adapter *, struct net_device *);
+	void (*config_ipaddr)(struct qlcnic_adapter *, __be32, int);
+	irqreturn_t (*clear_legacy_intr)(struct qlcnic_adapter *);
+};
+
+/* Adapter hardware abstraction */
+struct qlcnic_hardware_ops {
+	void (*read_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
+	void (*write_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
+	int (*read_reg) (struct qlcnic_adapter *, ulong);
+	int (*write_reg) (struct qlcnic_adapter *, ulong, u32);
+	void (*get_ocm_win) (struct qlcnic_hardware_context *);
+	int (*get_mac_address) (struct qlcnic_adapter *, u8 *);
+	int (*setup_intr) (struct qlcnic_adapter *, u8);
+	int (*alloc_mbx_args)(struct qlcnic_cmd_args *,
+			      struct qlcnic_adapter *, u32);
+	int (*mbx_cmd) (struct qlcnic_adapter *, struct qlcnic_cmd_args *);
+	void (*get_func_no) (struct qlcnic_adapter *);
+	int (*api_lock) (struct qlcnic_adapter *);
+	void (*api_unlock) (struct qlcnic_adapter *);
+	void (*add_sysfs) (struct qlcnic_adapter *);
+	void (*remove_sysfs) (struct qlcnic_adapter *);
+	void (*process_lb_rcv_ring_diag) (struct qlcnic_host_sds_ring *);
+	int (*create_rx_ctx) (struct qlcnic_adapter *);
+	int (*create_tx_ctx) (struct qlcnic_adapter *,
+	struct qlcnic_host_tx_ring *, int);
+	int (*setup_link_event) (struct qlcnic_adapter *, int);
+	int (*get_nic_info) (struct qlcnic_adapter *, struct qlcnic_info *, u8);
+	int (*get_pci_info) (struct qlcnic_adapter *, struct qlcnic_pci_info *);
+	int (*set_nic_info) (struct qlcnic_adapter *, struct qlcnic_info *);
+	int (*change_macvlan) (struct qlcnic_adapter *, u8*, __le16, u8);
+	void (*napi_enable) (struct qlcnic_adapter *);
+	void (*napi_disable) (struct qlcnic_adapter *);
+	void (*config_intr_coal) (struct qlcnic_adapter *);
+	int (*config_rss) (struct qlcnic_adapter *, int);
+	int (*config_hw_lro) (struct qlcnic_adapter *, int);
+	int (*config_loopback) (struct qlcnic_adapter *, u8);
+	int (*clear_loopback) (struct qlcnic_adapter *, u8);
+	int (*config_promisc_mode) (struct qlcnic_adapter *, u32);
+	void (*change_l2_filter) (struct qlcnic_adapter *, u64 *, __le16);
+	int (*get_board_info) (struct qlcnic_adapter *);
+};
+
+extern struct qlcnic_nic_template qlcnic_vf_ops;
+
+static inline int qlcnic_start_firmware(struct qlcnic_adapter *adapter)
+{
+	return adapter->nic_ops->start_firmware(adapter);
+}
+
+static inline void qlcnic_read_crb(struct qlcnic_adapter *adapter, char *buf,
+				   loff_t offset, size_t size)
+{
+	adapter->ahw->hw_ops->read_crb(adapter, buf, offset, size);
+}
+
+static inline void qlcnic_write_crb(struct qlcnic_adapter *adapter, char *buf,
+				    loff_t offset, size_t size)
+{
+	adapter->ahw->hw_ops->write_crb(adapter, buf, offset, size);
+}
+
+static inline u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter,
+				       ulong off)
+{
+	return adapter->ahw->hw_ops->read_reg(adapter, off);
+}
+
+static inline int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter,
+					ulong off, u32 data)
+{
+	return adapter->ahw->hw_ops->write_reg(adapter, off, data);
+}
+
+static inline int qlcnic_get_mac_address(struct qlcnic_adapter *adapter,
+					 u8 *mac)
+{
+	return adapter->ahw->hw_ops->get_mac_address(adapter, mac);
+}
+
+static inline int qlcnic_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
+{
+	return adapter->ahw->hw_ops->setup_intr(adapter, num_intr);
+}
+
+static inline int qlcnic_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
+					struct qlcnic_adapter *adapter, u32 arg)
+{
+	return adapter->ahw->hw_ops->alloc_mbx_args(mbx, adapter, arg);
+}
+
+static inline int qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
+				   struct qlcnic_cmd_args *cmd)
+{
+	return adapter->ahw->hw_ops->mbx_cmd(adapter, cmd);
+}
+
+static inline void qlcnic_get_func_no(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->get_func_no(adapter);
+}
+
+static inline int qlcnic_api_lock(struct qlcnic_adapter *adapter)
+{
+	return adapter->ahw->hw_ops->api_lock(adapter);
+}
+
+static inline void qlcnic_api_unlock(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->api_unlock(adapter);
+}
+
+static inline void qlcnic_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->add_sysfs(adapter);
+}
+
+static inline void qlcnic_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->remove_sysfs(adapter);
+}
+
+static inline void
+qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
+{
+	sds_ring->adapter->ahw->hw_ops->process_lb_rcv_ring_diag(sds_ring);
+}
+
+static inline int qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
+{
+	return adapter->ahw->hw_ops->create_rx_ctx(adapter);
+}
+
+static inline int qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
+					      struct qlcnic_host_tx_ring *ptr,
+					      int ring)
+{
+	return adapter->ahw->hw_ops->create_tx_ctx(adapter, ptr, ring);
+}
+
+static inline int qlcnic_linkevent_request(struct qlcnic_adapter *adapter,
+					   int enable)
+{
+	return adapter->ahw->hw_ops->setup_link_event(adapter, enable);
+}
+
+static inline int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
+				      struct qlcnic_info *info, u8 id)
+{
+	return adapter->ahw->hw_ops->get_nic_info(adapter, info, id);
+}
+
+static inline int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
+				      struct qlcnic_pci_info *info)
+{
+	return adapter->ahw->hw_ops->get_pci_info(adapter, info);
+}
+
+static inline int qlcnic_set_nic_info(struct qlcnic_adapter *adapter,
+				      struct qlcnic_info *info)
+{
+	return adapter->ahw->hw_ops->set_nic_info(adapter, info);
+}
+
+static inline int qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter,
+					    u8 *addr, __le16 id, u8 cmd)
+{
+	return adapter->ahw->hw_ops->change_macvlan(adapter, addr, id, cmd);
+}
+
+static inline int qlcnic_napi_add(struct qlcnic_adapter *adapter,
+				  struct net_device *netdev)
+{
+	return adapter->nic_ops->napi_add(adapter, netdev);
+}
+
+static inline void qlcnic_napi_enable(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->napi_enable(adapter);
+}
+
+static inline void qlcnic_napi_disable(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->napi_disable(adapter);
+}
+
+static inline void qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->config_intr_coal(adapter);
+}
+
+static inline int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
+{
+	return adapter->ahw->hw_ops->config_rss(adapter, enable);
+}
+
+static inline int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter,
+				       int enable)
+{
+	return adapter->ahw->hw_ops->config_hw_lro(adapter, enable);
+}
+
+static inline int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+{
+	return adapter->ahw->hw_ops->config_loopback(adapter, mode);
+}
+
+static inline int qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+{
+	return adapter->ahw->hw_ops->config_loopback(adapter, mode);
+}
+
+static inline int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter,
+					 u32 mode)
+{
+	return adapter->ahw->hw_ops->config_promisc_mode(adapter, mode);
+}
+
+static inline void qlcnic_change_filter(struct qlcnic_adapter *adapter,
+					u64 *addr, __le16 id)
+{
+	adapter->ahw->hw_ops->change_l2_filter(adapter, addr, id);
+}
+
+static inline int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
+{
+	return adapter->ahw->hw_ops->get_board_info(adapter);
+}
+
+static inline void qlcnic_dev_request_reset(struct qlcnic_adapter *adapter,
+					    u32 key)
+{
+	adapter->nic_ops->request_reset(adapter, key);
+}
+
+static inline void qlcnic_cancel_idc_work(struct qlcnic_adapter *adapter)
+{
+	adapter->nic_ops->cancel_idc_work(adapter);
+}
+
+static inline irqreturn_t
+qlcnic_clear_legacy_intr(struct qlcnic_adapter *adapter)
+{
+	return adapter->nic_ops->clear_legacy_intr(adapter);
+}
+
+static inline int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state,
+				    u32 rate)
+{
+	return adapter->nic_ops->config_led(adapter, state, rate);
+}
+
+static inline void qlcnic_config_ipaddr(struct qlcnic_adapter *adapter,
+					__be32 ip, int cmd)
+{
+	adapter->nic_ops->config_ipaddr(adapter, ip, cmd);
+}
+
 static inline void qlcnic_disable_int(struct qlcnic_host_sds_ring *sds_ring)
 {
 	writel(0, sds_ring->crb_intr_mask);
@@ -1651,13 +1885,6 @@ static inline void qlcnic_enable_int(struct qlcnic_host_sds_ring *sds_ring)
 extern const struct ethtool_ops qlcnic_ethtool_ops;
 extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
 
-struct qlcnic_nic_template {
-	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
-	int (*config_led) (struct qlcnic_adapter *, u32, u32);
-	int (*start_firmware) (struct qlcnic_adapter *);
-};
-
-
 /* List of PCI device IDs */
 #define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
 #define PCI_DEVICE_ID_QLOGIC_QLE834X	0x8030
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index b44bf87..66e13c7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -7,6 +7,84 @@
 
 #include "qlcnic.h"
 
+/* Array of FW control command structs with command type and required
+ * number of input and output arguments respectively.
+*/
+static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
+	{QLCNIC_CMD_CREATE_RX_CTX, 4, 1},
+	{QLCNIC_CMD_DESTROY_RX_CTX, 2, 1},
+	{QLCNIC_CMD_CREATE_TX_CTX, 4, 1},
+	{QLCNIC_CMD_DESTROY_TX_CTX, 2, 1},
+	{QLCNIC_CMD_INTRPT_TEST, 4, 1},
+	{QLCNIC_CMD_SET_MTU, 4, 1},
+	{QLCNIC_CMD_READ_PHY, 4, 2},
+	{QLCNIC_CMD_WRITE_PHY, 5, 1},
+	{QLCNIC_CMD_READ_HW_REG, 4, 1},
+	{QLCNIC_CMD_GET_FLOW_CTL, 4, 2},
+	{QLCNIC_CMD_SET_FLOW_CTL, 4, 1},
+	{QLCNIC_CMD_READ_MAX_MTU, 4, 2},
+	{QLCNIC_CMD_READ_MAX_LRO, 4, 2},
+	{QLCNIC_CMD_MAC_ADDRESS, 4, 3},
+	{QLCNIC_CMD_GET_PCI_INFO, 4, 1},
+	{QLCNIC_CMD_GET_NIC_INFO, 4, 1},
+	{QLCNIC_CMD_SET_NIC_INFO, 4, 1},
+	{QLCNIC_CMD_GET_ESWITCH_CAPABILITY, 4, 3},
+	{QLCNIC_CMD_TOGGLE_ESWITCH, 4, 1},
+	{QLCNIC_CMD_GET_ESWITCH_STATUS, 4, 3},
+	{QLCNIC_CMD_SET_PORTMIRRORING, 4, 1},
+	{QLCNIC_CMD_CONFIGURE_ESWITCH, 4, 1},
+	{QLCNIC_CMD_GET_MAC_STATS, 4, 1},
+	{QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG, 4, 3},
+	{QLCNIC_CMD_GET_ESWITCH_STATS, 5, 1},
+	{QLCNIC_CMD_CONFIG_PORT, 4, 1},
+	{QLCNIC_CMD_TEMP_SIZE, 4, 4},
+	{QLCNIC_CMD_GET_TEMP_HDR, 4, 1},
+	{QLCNIC_CMD_SET_DRV_VER, 4, 1},
+};
+
+/* Allocate mailbox registers */
+int qlcnic_82xx_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
+			       struct qlcnic_adapter *adapter, u32 type)
+{
+	int i, size;
+	const struct qlcnic_mailbox_metadata *mbx_tbl;
+
+	mbx_tbl = qlcnic_mbx_tbl;
+	size = ARRAY_SIZE(qlcnic_mbx_tbl);
+	for (i = 0; i < size; i++) {
+		if (type == mbx_tbl[i].cmd) {
+			mbx->req.num = mbx_tbl[i].in_args;
+			mbx->rsp.num = mbx_tbl[i].out_args;
+			mbx->req.arg = kcalloc(mbx->req.num,
+					       sizeof(u32), GFP_ATOMIC);
+			if (!mbx->req.arg)
+				return -ENOMEM;
+			mbx->rsp.arg = kcalloc(mbx->rsp.num,
+					       sizeof(u32), GFP_ATOMIC);
+			if (!mbx->rsp.arg) {
+				kfree(mbx->req.arg);
+				mbx->req.arg = NULL;
+				return -ENOMEM;
+			}
+			memset(mbx->req.arg, 0, sizeof(u32) * mbx->req.num);
+			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
+			mbx->req.arg[0] = type;
+			break;
+		}
+	}
+	return 0;
+}
+
+/* Free up mailbox registers */
+void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd)
+{
+	kfree(cmd->req.arg);
+	cmd->req.arg = NULL;
+	kfree(cmd->rsp.arg);
+	cmd->rsp.arg = NULL;
+}
+
+
 static u32
 qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 {
@@ -26,107 +104,77 @@ qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 	return rsp;
 }
 
-void
-qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
+static inline u32 qlcnic_get_cmd_signature(struct qlcnic_hardware_context *ahw)
 {
+	return (ahw->pci_func & 0xff) | ((ahw->fw_hal_version & 0xff) << 8) |
+	       (0xcafe << 16);
+}
+
+int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
+			  struct qlcnic_cmd_args *cmd)
+{
+	int i;
 	u32 rsp;
 	u32 signature;
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	signature = QLCNIC_CDRP_SIGNATURE_MAKE(ahw->pci_func,
-					       ahw->fw_hal_version);
+	signature = qlcnic_get_cmd_signature(ahw);
 
 	/* Acquire semaphore before accessing CRB */
 	if (qlcnic_api_lock(adapter)) {
-		cmd->rsp.cmd = QLCNIC_RCODE_TIMEOUT;
-		return;
+		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
+		return cmd->rsp.arg[0];
 	}
 
 	QLCWR32(adapter, QLCNIC_SIGN_CRB_OFFSET, signature);
-	QLCWR32(adapter, QLCNIC_ARG1_CRB_OFFSET, cmd->req.arg1);
-	QLCWR32(adapter, QLCNIC_ARG2_CRB_OFFSET, cmd->req.arg2);
-	QLCWR32(adapter, QLCNIC_ARG3_CRB_OFFSET, cmd->req.arg3);
+	for (i = 1; i < QLCNIC_CDRP_MAX_ARGS; i++)
+		QLCWR32(adapter, QLCNIC_CDRP_ARG(i), cmd->req.arg[i]);
 	QLCWR32(adapter, QLCNIC_CDRP_CRB_OFFSET,
-		QLCNIC_CDRP_FORM_CMD(cmd->req.cmd));
-
+		QLCNIC_CDRP_FORM_CMD(cmd->req.arg[0]));
 	rsp = qlcnic_poll_rsp(adapter);
 
 	if (rsp == QLCNIC_CDRP_RSP_TIMEOUT) {
-		dev_err(&pdev->dev, "CDRP response timeout.\n");
-		cmd->rsp.cmd = QLCNIC_RCODE_TIMEOUT;
+		dev_err(&pdev->dev, "card response timeout.\n");
+		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
 	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
-		cmd->rsp.cmd = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
-		switch (cmd->rsp.cmd) {
-		case QLCNIC_RCODE_INVALID_ARGS:
-			dev_err(&pdev->dev, "CDRP invalid args: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		case QLCNIC_RCODE_NOT_SUPPORTED:
-		case QLCNIC_RCODE_NOT_IMPL:
-			dev_err(&pdev->dev,
-				"CDRP command not supported: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		case QLCNIC_RCODE_NOT_PERMITTED:
-			dev_err(&pdev->dev,
-				"CDRP requested action not permitted: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		case QLCNIC_RCODE_INVALID:
-			dev_err(&pdev->dev,
-				"CDRP invalid or unknown cmd received: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		case QLCNIC_RCODE_TIMEOUT:
-			dev_err(&pdev->dev, "CDRP command timeout: 0x%x.\n",
-				cmd->rsp.cmd);
-			break;
-		default:
-			dev_err(&pdev->dev, "CDRP command failed: 0x%x.\n",
-				cmd->rsp.cmd);
-		}
-	} else if (rsp == QLCNIC_CDRP_RSP_OK) {
-		cmd->rsp.cmd = QLCNIC_RCODE_SUCCESS;
-		if (cmd->rsp.arg2)
-			cmd->rsp.arg2 = QLCRD32(adapter,
-				QLCNIC_ARG2_CRB_OFFSET);
-		if (cmd->rsp.arg3)
-			cmd->rsp.arg3 = QLCRD32(adapter,
-				QLCNIC_ARG3_CRB_OFFSET);
-	}
-	if (cmd->rsp.arg1)
-		cmd->rsp.arg1 = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
+		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1));
+		dev_err(&pdev->dev, "failed card response code:0x%x\n",
+			cmd->rsp.arg[0]);
+	} else if (rsp == QLCNIC_CDRP_RSP_OK)
+		cmd->rsp.arg[0] = QLCNIC_RCODE_SUCCESS;
+
+	for (i = 1; i < cmd->rsp.num; i++)
+		cmd->rsp.arg[i] = QLCRD32(adapter, QLCNIC_CDRP_ARG(i));
 
 	/* Release semaphore */
 	qlcnic_api_unlock(adapter);
-
+	return cmd->rsp.arg[0];
 }
 
 int
 qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
 {
+	int err = 0;
 	struct qlcnic_cmd_args cmd;
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_SET_MTU;
-	cmd.req.arg1 = recv_ctx->context_id;
-	cmd.req.arg2 = mtu;
-	cmd.req.arg3 = 0;
-	if (recv_ctx->state == QLCNIC_HOST_CTX_STATE_ACTIVE) {
-		qlcnic_issue_cmd(adapter, &cmd);
-		if (cmd.rsp.cmd) {
-			dev_err(&adapter->pdev->dev, "Failed to set mtu\n");
-			return -EIO;
-		}
-	}
+	if (recv_ctx->state != QLCNIC_HOST_CTX_STATE_ACTIVE)
+		return err;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_SET_MTU);
+	cmd.req.arg[1] = recv_ctx->context_id;
+	cmd.req.arg[2] = mtu;
 
-	return 0;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev, "Failed to set mtu\n");
+		err = -EIO;
+	}
+	qlcnic_free_mbx_args(&cmd);
+	return err;
 }
 
-static int
-qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
+int qlcnic_82xx_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 {
 	void *addr;
 	struct qlcnic_hostrq_rx_ctx *prq;
@@ -179,9 +227,6 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 						| QLCNIC_CAP0_VALIDOFF);
 	cap |= (QLCNIC_CAP0_JUMBO_CONTIGUOUS | QLCNIC_CAP0_LRO_CONTIGUOUS);
 
-	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
-		cap |= QLCNIC_CAP0_LRO_MSS;
-
 	prq->valid_field_offset = offsetof(struct qlcnic_hostrq_rx_ctx,
 							 msix_handler);
 	prq->txrx_sds_binding = nsds_rings - 1;
@@ -229,20 +274,17 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 	}
 
 	phys_addr = hostrq_phys_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = (u32) (phys_addr >> 32);
-	cmd.req.arg2 = (u32) (phys_addr & 0xffffffff);
-	cmd.req.arg3 = rq_size;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CREATE_RX_CTX;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CREATE_RX_CTX);
+	cmd.req.arg[1] = MSD(phys_addr);
+	cmd.req.arg[2] = LSD(phys_addr);
+	cmd.req.arg[3] = rq_size;
+	err = qlcnic_issue_cmd(adapter, &cmd);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to create rx ctx in firmware%d\n", err);
 		goto out_free_rsp;
 	}
 
-
 	prsp_rds = ((struct qlcnic_cardrsp_rds_ring *)
 			 &prsp->data[le32_to_cpu(prsp->rds_ring_offset)]);
 
@@ -273,6 +315,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 out_free_rsp:
 	dma_free_coherent(&adapter->pdev->dev, rsp_size, prsp,
 		cardrsp_phys_addr);
+	qlcnic_free_mbx_args(&cmd);
 out_free_rq:
 	dma_free_coherent(&adapter->pdev->dev, rq_size, prq, hostrq_phys_addr);
 	return err;
@@ -281,24 +324,24 @@ out_free_rq:
 static void
 qlcnic_fw_cmd_destroy_rx_ctx(struct qlcnic_adapter *adapter)
 {
+	int err;
 	struct qlcnic_cmd_args cmd;
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = recv_ctx->context_id;
-	cmd.req.arg2 = QLCNIC_DESTROY_CTX_RESET;
-	cmd.req.arg3 = 0;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_DESTROY_RX_CTX;
-	qlcnic_issue_cmd(adapter, &cmd);
-	if (cmd.rsp.cmd)
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_DESTROY_RX_CTX);
+	cmd.req.arg[1] = recv_ctx->context_id;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err)
 		dev_err(&adapter->pdev->dev,
 			"Failed to destroy rx ctx in firmware\n");
 
 	recv_ctx->state = QLCNIC_HOST_CTX_STATE_FREED;
+	qlcnic_free_mbx_args(&cmd);
 }
 
-static int
-qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
+int qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
+				     struct qlcnic_host_tx_ring *tx_ring,
+				     int ring)
 {
 	struct qlcnic_hostrq_tx_ctx	*prq;
 	struct qlcnic_hostrq_cds_ring	*prq_cds;
@@ -310,7 +353,6 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	int	err;
 	u64	phys_addr;
 	dma_addr_t	rq_phys_addr, rsp_phys_addr;
-	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 
 	/* reset host resources */
 	tx_ring->producer = 0;
@@ -345,9 +387,9 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 	prq->host_int_crb_mode =
 		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
+	prq->msi_index = 0;
 
 	prq->interrupt_ctl = 0;
-	prq->msi_index = 0;
 	prq->cmd_cons_dma_addr = cpu_to_le64(tx_ring->hw_cons_phys_addr);
 
 	prq_cds = &prq->cds_ring;
@@ -356,18 +398,17 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	prq_cds->ring_size = cpu_to_le32(tx_ring->num_desc);
 
 	phys_addr = rq_phys_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = (u32)(phys_addr >> 32);
-	cmd.req.arg2 = ((u32)phys_addr & 0xffffffff);
-	cmd.req.arg3 = rq_size;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CREATE_TX_CTX;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CREATE_TX_CTX);
+	cmd.req.arg[1] = MSD(phys_addr);
+	cmd.req.arg[2] = LSD(phys_addr);
+	cmd.req.arg[3] = rq_size;
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
 		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
-		adapter->tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
+		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
 	} else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to create tx ctx in firmware%d\n", err);
@@ -375,41 +416,40 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	}
 
 	dma_free_coherent(&adapter->pdev->dev, rsp_size, rsp_addr,
-		rsp_phys_addr);
+			  rsp_phys_addr);
 
 out_free_rq:
 	dma_free_coherent(&adapter->pdev->dev, rq_size, rq_addr, rq_phys_addr);
+	qlcnic_free_mbx_args(&cmd);
 
 	return err;
 }
 
 static void
-qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter)
+qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter,
+			     struct qlcnic_host_tx_ring *tx_ring)
 {
 	struct qlcnic_cmd_args cmd;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = adapter->tx_ring->ctx_id;
-	cmd.req.arg2 = QLCNIC_DESTROY_CTX_RESET;
-	cmd.req.arg3 = 0;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_DESTROY_TX_CTX;
-	qlcnic_issue_cmd(adapter, &cmd);
-	if (cmd.rsp.cmd)
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_DESTROY_TX_CTX);
+	cmd.req.arg[1] = tx_ring->ctx_id;
+	if (qlcnic_issue_cmd(adapter, &cmd))
 		dev_err(&adapter->pdev->dev,
 			"Failed to destroy tx ctx in firmware\n");
+	qlcnic_free_mbx_args(&cmd);
 }
 
 int
 qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config)
 {
+	int err;
 	struct qlcnic_cmd_args cmd;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = config;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CONFIG_PORT;
-	qlcnic_issue_cmd(adapter, &cmd);
-
-	return cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIG_PORT);
+	cmd.req.arg[1] = config;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
 }
 
 int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
@@ -486,7 +526,8 @@ err_out_free:
 
 int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 {
-	int err;
+	int i, err, ring;
+	struct qlcnic_host_tx_ring tx_ring;
 
 	if (adapter->flags & QLCNIC_NEED_FLR) {
 		pci_reset_function(adapter->pdev);
@@ -497,10 +538,20 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	err = qlcnic_fw_cmd_create_tx_ctx(adapter);
-	if (err) {
-		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-		return err;
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		err = qlcnic_fw_cmd_create_tx_ctx(adapter,
+						  &adapter->tx_ring[ring],
+						  ring);
+		if (err) {
+			qlcnic_fw_cmd_destroy_rx_ctx(adapter);
+			if (ring == 0)
+				return err;
+			for (i = 0; i < ring; i++) {
+				tx_ring = adapter->tx_ring[i];
+				qlcnic_fw_cmd_destroy_tx_ctx(adapter, &tx_ring);
+			}
+			return err;
+		}
 	}
 
 	set_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
@@ -509,10 +560,13 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 
 void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
 {
+	int ring;
+
 	if (test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state)) {
 		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-		qlcnic_fw_cmd_destroy_tx_ctx(adapter);
-
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++)
+			qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+						     &adapter->tx_ring[ring]);
 		/* Allow dma queues to drain after context reset */
 		mdelay(20);
 	}
@@ -569,38 +623,41 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 	}
 }
 
-
 /* Get MAC address of a NIC partition */
-int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
+int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 {
-	int err;
+	int err, i;
 	struct qlcnic_cmd_args cmd;
+	u32 mac_low, mac_high;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = adapter->ahw->pci_func | BIT_8;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_MAC_ADDRESS;
-	cmd.rsp.arg1 = cmd.rsp.arg2 = 1;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_MAC_ADDRESS);
+	cmd.req.arg[1] = adapter->ahw->pci_func | BIT_8;
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
-	if (err == QLCNIC_RCODE_SUCCESS)
-		qlcnic_fetch_mac(adapter, cmd.rsp.arg1, cmd.rsp.arg2, 0, mac);
-	else {
+	if (err == QLCNIC_RCODE_SUCCESS) {
+		mac_low = cmd.rsp.arg[1];
+		mac_high = cmd.rsp.arg[2];
+
+		for (i = 0; i < 2; i++)
+			mac[i] = (u8) (mac_high >> ((1 - i) * 8));
+		for (i = 2; i < 6; i++)
+			mac[i] = (u8) (mac_low >> ((5 - i) * 8));
+	} else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get mac address%d\n", err);
 		err = -EIO;
 	}
-
+	qlcnic_free_mbx_args(&cmd);
 	return err;
 }
 
 /* Get info of a NIC partition */
-int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
-				struct qlcnic_info *npar_info, u8 func_id)
+int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *adapter,
+			      struct qlcnic_info *npar_info, u8 func_id)
 {
 	int	err;
 	dma_addr_t nic_dma_t;
-	struct qlcnic_info *nic_info;
+	const struct qlcnic_info *nic_info;
 	void *nic_info_addr;
 	struct qlcnic_cmd_args cmd;
 	size_t	nic_size = sizeof(struct qlcnic_info);
@@ -612,27 +669,28 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 	memset(nic_info_addr, 0, nic_size);
 
 	nic_info = nic_info_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_NIC_INFO;
-	cmd.req.arg1 = MSD(nic_dma_t);
-	cmd.req.arg2 = LSD(nic_dma_t);
-	cmd.req.arg3 = (func_id << 16 | nic_size);
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
 
-	if (err) {
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_NIC_INFO);
+	cmd.req.arg[1] = MSD(nic_dma_t);
+	cmd.req.arg[2] = LSD(nic_dma_t);
+	cmd.req.arg[3] = (func_id << 16 | nic_size);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err != QLCNIC_RCODE_SUCCESS) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get nic info%d\n", err);
 		err = -EIO;
 	}
 
 	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
-		nic_dma_t);
+			  nic_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
 /* Configure a NIC partition */
-int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
+int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *adapter,
+			     struct qlcnic_info *nic)
 {
 	int err = -EIO;
 	dma_addr_t nic_dma_t;
@@ -663,13 +721,11 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 	nic_info->min_tx_bw = cpu_to_le16(nic->min_tx_bw);
 	nic_info->max_tx_bw = cpu_to_le16(nic->max_tx_bw);
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_SET_NIC_INFO;
-	cmd.req.arg1 = MSD(nic_dma_t);
-	cmd.req.arg2 = LSD(nic_dma_t);
-	cmd.req.arg3 = ((nic->pci_func << 16) | nic_size);
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_SET_NIC_INFO);
+	cmd.req.arg[1] = MSD(nic_dma_t);
+	cmd.req.arg[2] = LSD(nic_dma_t);
+	cmd.req.arg[3] = ((nic->pci_func << 16) | nic_size);
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (err != QLCNIC_RCODE_SUCCESS) {
 		dev_err(&adapter->pdev->dev,
@@ -679,12 +735,14 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 
 	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
 		nic_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
 /* Get PCI Info of a partition */
-int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
-				struct qlcnic_pci_info *pci_info)
+int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *adapter,
+			     struct qlcnic_pci_info *pci_info)
 {
 	int err = 0, i;
 	struct qlcnic_cmd_args cmd;
@@ -701,13 +759,11 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 	memset(pci_info_addr, 0, pci_size);
 
 	npar = pci_info_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_PCI_INFO;
-	cmd.req.arg1 = MSD(pci_info_dma_t);
-	cmd.req.arg2 = LSD(pci_info_dma_t);
-	cmd.req.arg3 = pci_size;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_PCI_INFO);
+	cmd.req.arg[1] = MSD(pci_info_dma_t);
+	cmd.req.arg[2] = LSD(pci_info_dma_t);
+	cmd.req.arg[3] = pci_size;
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
@@ -730,6 +786,8 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 
 	dma_free_coherent(&adapter->pdev->dev, pci_size, pci_info_addr,
 		pci_info_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -748,21 +806,19 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
 	arg1 = id | (enable_mirroring ? BIT_4 : 0);
 	arg1 |= pci_func << 8;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_SET_PORTMIRRORING;
-	cmd.req.arg1 = arg1;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_SET_PORTMIRRORING);
+	cmd.req.arg[1] = arg1;
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
-	if (err != QLCNIC_RCODE_SUCCESS) {
+	if (err != QLCNIC_RCODE_SUCCESS)
 		dev_err(&adapter->pdev->dev,
 			"Failed to configure port mirroring%d on eswitch:%d\n",
 			pci_func, id);
-	} else {
+	else
 		dev_info(&adapter->pdev->dev,
 			"Configured eSwitch %d for port mirroring:%d\n",
 			id, pci_func);
-	}
+	qlcnic_free_mbx_args(&cmd);
 
 	return err;
 }
@@ -799,13 +855,11 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
 	arg1 |= rx_tx << 15 | stats_size << 16;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_ESWITCH_STATS;
-	cmd.req.arg1 = arg1;
-	cmd.req.arg2 = MSD(stats_dma_t);
-	cmd.req.arg3 = LSD(stats_dma_t);
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_ESWITCH_STATS);
+	cmd.req.arg[1] = arg1;
+	cmd.req.arg[2] = MSD(stats_dma_t);
+	cmd.req.arg[3] = LSD(stats_dma_t);
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (!err) {
 		stats = stats_addr;
@@ -825,6 +879,8 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 
 	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
 		stats_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -839,6 +895,9 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 	void *stats_addr;
 	int err;
 
+	if (mac_stats == NULL)
+		return -ENOMEM;
+
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
 			&stats_dma_t, GFP_KERNEL);
 	if (!stats_addr) {
@@ -847,15 +906,11 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 	}
 	memset(stats_addr, 0, stats_size);
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_MAC_STATS;
-	cmd.req.arg1 = stats_size << 16;
-	cmd.req.arg2 = MSD(stats_dma_t);
-	cmd.req.arg3 = LSD(stats_dma_t);
-
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
-
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_MAC_STATS);
+	cmd.req.arg[1] = stats_size << 16;
+	cmd.req.arg[2] = MSD(stats_dma_t);
+	cmd.req.arg[3] = LSD(stats_dma_t);
+	err = qlcnic_issue_cmd(adapter, &cmd);
 	if (!err) {
 		stats = stats_addr;
 		mac_stats->mac_tx_frames = le64_to_cpu(stats->mac_tx_frames);
@@ -877,10 +932,16 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 		mac_stats->mac_rx_jabber = le64_to_cpu(stats->mac_rx_jabber);
 		mac_stats->mac_rx_dropped = le64_to_cpu(stats->mac_rx_dropped);
 		mac_stats->mac_rx_crc_error = le64_to_cpu(stats->mac_rx_crc_error);
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"%s: Get mac stats failed, err=%d.\n", __func__, err);
 	}
 
 	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
 		stats_dma_t);
+
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -940,7 +1001,7 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 		const u8 port, const u8 rx_tx)
 {
-
+	int err;
 	u32 arg1;
 	struct qlcnic_cmd_args cmd;
 
@@ -963,15 +1024,16 @@ int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 	arg1 = port | QLCNIC_STATS_VERSION << 8 | func_esw << 12;
 	arg1 |= BIT_14 | rx_tx << 15;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_ESWITCH_STATS;
-	cmd.req.arg1 = arg1;
-	qlcnic_issue_cmd(adapter, &cmd);
-	return cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_ESWITCH_STATS);
+	cmd.req.arg[1] = arg1;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
 
 err_ret:
-	dev_err(&adapter->pdev->dev, "Invalid argument func_esw=%d port=%d"
-		"rx_ctx=%d\n", func_esw, port, rx_tx);
+	dev_err(&adapter->pdev->dev,
+		"Invalid args func_esw %d port %d rx_ctx %d\n",
+		func_esw, port, rx_tx);
 	return -EIO;
 }
 
@@ -984,22 +1046,21 @@ __qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
 	u8 pci_func;
 	pci_func = (*arg1 >> 8);
 
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_ESWITCH_PORT_CONFIG;
-	cmd.req.arg1 = *arg1;
-	cmd.rsp.arg1 = cmd.rsp.arg2 = 1;
-	qlcnic_issue_cmd(adapter, &cmd);
-	*arg1 = cmd.rsp.arg1;
-	*arg2 = cmd.rsp.arg2;
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+			      QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG);
+	cmd.req.arg[1] = *arg1;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	*arg1 = cmd.rsp.arg[1];
+	*arg2 = cmd.rsp.arg[2];
+	qlcnic_free_mbx_args(&cmd);
 
-	if (err == QLCNIC_RCODE_SUCCESS) {
+	if (err == QLCNIC_RCODE_SUCCESS)
 		dev_info(&adapter->pdev->dev,
-			"eSwitch port config for pci func %d\n", pci_func);
-	} else {
+			 "eSwitch port config for pci func %d\n", pci_func);
+	else
 		dev_err(&adapter->pdev->dev,
 			"Failed to get eswitch port config for pci func %d\n",
 								pci_func);
-	}
 	return err;
 }
 /* Configure eSwitch port
@@ -1061,20 +1122,18 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 		return err;
 	}
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH;
-	cmd.req.arg1 = arg1;
-	cmd.req.arg2 = arg2;
-	qlcnic_issue_cmd(adapter, &cmd);
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIGURE_ESWITCH);
+	cmd.req.arg[1] = arg1;
+	cmd.req.arg[2] = arg2;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
 
-	err = cmd.rsp.cmd;
-	if (err != QLCNIC_RCODE_SUCCESS) {
+	if (err != QLCNIC_RCODE_SUCCESS)
 		dev_err(&adapter->pdev->dev,
 			"Failed to configure eswitch pci func %d\n", pci_func);
-	} else {
+	else
 		dev_info(&adapter->pdev->dev,
-			"Configured eSwitch for pci func %d\n", pci_func);
-	}
+			 "Configured eSwitch for pci func %d\n", pci_func);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index c6dddf8..078ee48 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -706,20 +706,19 @@ static int qlcnic_irq_test(struct net_device *netdev)
 		goto clear_it;
 
 	adapter->ahw->diag_cnt = 0;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_INTRPT_TEST;
-	cmd.req.arg1 = adapter->ahw->pci_func;
-	qlcnic_issue_cmd(adapter, &cmd);
-	ret = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_INTRPT_TEST);
+
+	cmd.req.arg[1] = cpu_to_le32(adapter->ahw->pci_func);
+	ret = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (ret)
 		goto done;
 
-	msleep(10);
-
+	usleep_range(1000, 12000);
 	ret = !adapter->ahw->diag_cnt;
 
 done:
+	qlcnic_free_mbx_args(&cmd);
 	qlcnic_diag_free_res(netdev, max_sds_rings);
 
 clear_it:
@@ -846,7 +845,7 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 
 	ret = qlcnic_do_lb_test(adapter, mode);
 
-	qlcnic_clear_lb_mode(adapter);
+	qlcnic_clear_lb_mode(adapter, mode);
 
  free_res:
 	qlcnic_diag_free_res(netdev, max_sds_rings);
@@ -1307,7 +1306,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 			return 0;
 		}
 		netdev_info(netdev, "Forcing a FW dump\n");
-		qlcnic_dev_request_reset(adapter);
+		qlcnic_dev_request_reset(adapter, 0);
 		break;
 	case QLCNIC_DISABLE_FW_DUMP:
 		if (fw_dump->enable && fw_dump->tmpl_hdr) {
@@ -1327,7 +1326,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 		return 0;
 	case QLCNIC_FORCE_FW_RESET:
 		netdev_info(netdev, "Forcing a FW reset\n");
-		qlcnic_dev_request_reset(adapter);
+		qlcnic_dev_request_reset(adapter, 0);
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		return 0;
 	case QLCNIC_SET_QUIESCENT:
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index ac85816..df59392 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -11,6 +11,8 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 
+#include "qlcnic_hw.h"
+
 /*
  * The basic unit of access when reading/writing control registers.
  */
@@ -568,6 +570,9 @@ enum {
 #define QLCNIC_REG(X)		(NIC_CRB_BASE+(X))
 #define QLCNIC_REG_2(X) 	(NIC_CRB_BASE_2+(X))
 
+#define QLCNIC_CDRP_MAX_ARGS	4
+#define QLCNIC_CDRP_ARG(i)	(QLCNIC_REG(0x18 + ((i) * 4)))
+
 #define QLCNIC_CDRP_CRB_OFFSET		(QLCNIC_REG(0x18))
 #define QLCNIC_ARG1_CRB_OFFSET		(QLCNIC_REG(0x1c))
 #define QLCNIC_ARG2_CRB_OFFSET		(QLCNIC_REG(0x20))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 9e38099..7574a92 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -338,8 +338,7 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 	return 0;
 }
 
-void
-qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
+void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
 {
 	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
 }
@@ -418,9 +417,8 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int
-qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
-				__le16 vlan_id, unsigned op)
+int qlcnic_82xx_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
+				   __le16 vlan_id, u8 op)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_mac_req *mac_req;
@@ -517,7 +515,7 @@ send_fw_cmd:
 	qlcnic_nic_set_promisc(adapter, mode);
 }
 
-int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
+int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -621,12 +619,13 @@ int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
 	return rv;
 }
 
-int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+int qlcnic_82xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
 	if (qlcnic_set_fw_loopback(adapter, mode))
 		return -EIO;
 
-	if (qlcnic_nic_set_promisc(adapter, VPORT_MISS_MODE_ACCEPT_ALL)) {
+	if (qlcnic_nic_set_promisc(adapter,
+				   VPORT_MISS_MODE_ACCEPT_ALL)) {
 		qlcnic_set_fw_loopback(adapter, 0);
 		return -EIO;
 	}
@@ -635,11 +634,11 @@ int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 	return 0;
 }
 
-void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter)
+int qlcnic_82xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
-	int mode = VPORT_MISS_MODE_DROP;
 	struct net_device *netdev = adapter->netdev;
 
+	mode = VPORT_MISS_MODE_DROP;
 	qlcnic_set_fw_loopback(adapter, 0);
 
 	if (netdev->flags & IFF_PROMISC)
@@ -649,12 +648,13 @@ void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter)
 
 	qlcnic_nic_set_promisc(adapter, mode);
 	msleep(1000);
+	return 0;
 }
 
 /*
  * Send the interrupt coalescing parameter set by ethtool to the card.
  */
-int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
+void qlcnic_82xx_config_intr_coalesce(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_nic_req req;
 	int rv;
@@ -676,10 +676,9 @@ int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
 	if (rv != 0)
 		dev_err(&adapter->netdev->dev,
 			"Could not send interrupt coalescing parameters\n");
-	return rv;
 }
 
-int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
+int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -737,7 +736,7 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 
 #define RSS_HASHTYPE_IP_TCP	0x3
 
-int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
+int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -780,7 +779,8 @@ int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
 	return rv;
 }
 
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
+void qlcnic_82xx_config_ipaddr(struct qlcnic_adapter *adapter,
+				__be32 ip, int cmd)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_ipaddr *ipa;
@@ -802,23 +802,19 @@ int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
 		dev_err(&adapter->netdev->dev,
 				"could not notify %s IP 0x%x reuqest\n",
 				(cmd == QLCNIC_IP_UP) ? "Add" : "Remove", ip);
-
-	return rv;
 }
 
-int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable)
+int qlcnic_82xx_linkevent_request(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
 	int rv;
-
 	memset(&req, 0, sizeof(struct qlcnic_nic_req));
 	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
 
 	word = QLCNIC_H2C_OPCODE_GET_LINKEVENT | ((u64)adapter->portnum << 16);
 	req.req_hdr = cpu_to_le64(word);
 	req.words[0] = cpu_to_le64(enable | (enable << 8));
-
 	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0)
 		dev_err(&adapter->netdev->dev,
@@ -982,7 +978,8 @@ qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 	return 0;
 }
 
-int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
+int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off,
+			       u32 data)
 {
 	unsigned long flags;
 	int rv;
@@ -1013,7 +1010,7 @@ int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 	return -EIO;
 }
 
-int qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
+int qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 {
 	unsigned long flags;
 	int rv;
@@ -1042,7 +1039,6 @@ int qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 	return -1;
 }
 
-
 void __iomem *qlcnic_get_ioaddr(struct qlcnic_hardware_context *ahw,
 				u32 offset)
 {
@@ -1268,7 +1264,7 @@ int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
 	return ret;
 }
 
-int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
+int qlcnic_82xx_get_board_info(struct qlcnic_adapter *adapter)
 {
 	int offset, board_type, magic;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1341,7 +1337,7 @@ qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
-int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 {
 	struct qlcnic_nic_req   req;
 	int rv;
@@ -1362,3 +1358,56 @@ int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 
 	return rv;
 }
+
+void qlcnic_82xx_get_func_no(struct qlcnic_adapter *adapter)
+{
+	void __iomem *msix_base_addr;
+	u32 func;
+	u32 msix_base;
+
+	pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
+	msix_base_addr = adapter->ahw->pci_base0 + QLCNIC_MSIX_BASE;
+	msix_base = readl(msix_base_addr);
+	func = (func - msix_base) / QLCNIC_MSIX_TBL_PGSIZE;
+	adapter->ahw->pci_func = func;
+}
+
+void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
+			  loff_t offset, size_t size)
+{
+	u32 data;
+	u64 qmdata;
+
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
+		memcpy(buf, &qmdata, size);
+	} else {
+		data = QLCRD32(adapter, offset);
+		memcpy(buf, &data, size);
+	}
+}
+
+void qlcnic_82xx_write_crb(struct qlcnic_adapter *adapter, char *buf,
+			   loff_t offset, size_t size)
+{
+	u32 data;
+	u64 qmdata;
+
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		memcpy(&qmdata, buf, size);
+		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
+	} else {
+		memcpy(&data, buf, size);
+		QLCWR32(adapter, offset, data);
+	}
+}
+
+int qlcnic_82xx_api_lock(struct qlcnic_adapter *adapter)
+{
+	return qlcnic_pcie_sem_lock(adapter, 5, 0);
+}
+
+void qlcnic_82xx_api_unlock(struct qlcnic_adapter *adapter)
+{
+	qlcnic_pcie_sem_unlock(adapter, 5);
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
new file mode 100644
index 0000000..2b37630
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -0,0 +1,160 @@
+#ifndef __QLCNIC_HW_H
+#define __QLCNIC_HW_H
+
+/* Common registers in 83xx and 82xx */
+enum qlcnic_regs {
+	QLCNIC_PEG_HALT_STATUS1 = 0,
+	QLCNIC_PEG_HALT_STATUS2,
+	QLCNIC_PEG_ALIVE_COUNTER,
+	QLCNIC_FLASH_LOCK_OWNER,
+	QLCNIC_FW_CAPABILITIES,
+	QLCNIC_CRB_DRV_ACTIVE,
+	QLCNIC_CRB_DEV_STATE,
+	QLCNIC_CRB_DRV_STATE,
+	QLCNIC_CRB_DRV_SCRATCH,
+	QLCNIC_CRB_DEV_PARTITION_INFO,
+	QLCNIC_CRB_DRV_IDC_VER,
+	QLCNIC_FW_VERSION_MAJOR,
+	QLCNIC_FW_VERSION_MINOR,
+	QLCNIC_FW_VERSION_SUB,
+	QLCNIC_CRB_DEV_NPAR_STATE,
+	QLCNIC_FW_IMG_VALID,
+	QLCNIC_CMDPEG_STATE,
+	QLCNIC_RCVPEG_STATE,
+	QLCNIC_ASIC_TEMP,
+	QLCNIC_FW_API,
+	QLCNIC_DRV_OP_MODE,
+	QLCNIC_FLASH_LOCK,
+	QLCNIC_FLASH_UNLOCK,
+};
+
+#define QLCNIC_CMD_CONFIGURE_IP_ADDR		0x1
+#define QLCNIC_CMD_CONFIG_INTRPT		0x2
+#define QLCNIC_CMD_CREATE_RX_CTX		0x7
+#define QLCNIC_CMD_DESTROY_RX_CTX		0x8
+#define QLCNIC_CMD_CREATE_TX_CTX		0x9
+#define QLCNIC_CMD_DESTROY_TX_CTX		0xa
+#define QLCNIC_CMD_CONFIGURE_LRO		0xC
+#define QLCNIC_CMD_CONFIGURE_MAC_LEARNING	0xD
+#define QLCNIC_CMD_GET_STATISTICS		0xF
+#define QLCNIC_CMD_INTRPT_TEST			0x11
+#define QLCNIC_CMD_SET_MTU			0x12
+#define QLCNIC_CMD_READ_PHY			0x13
+#define QLCNIC_CMD_WRITE_PHY			0x14
+#define QLCNIC_CMD_READ_HW_REG			0x15
+#define QLCNIC_CMD_GET_FLOW_CTL		0x16
+#define QLCNIC_CMD_SET_FLOW_CTL		0x17
+#define QLCNIC_CMD_READ_MAX_MTU		0x18
+#define QLCNIC_CMD_READ_MAX_LRO		0x19
+#define QLCNIC_CMD_MAC_ADDRESS			0x1f
+#define QLCNIC_CMD_GET_PCI_INFO		0x20
+#define QLCNIC_CMD_GET_NIC_INFO		0x21
+#define QLCNIC_CMD_SET_NIC_INFO		0x22
+#define QLCNIC_CMD_GET_ESWITCH_CAPABILITY	0x24
+#define QLCNIC_CMD_TOGGLE_ESWITCH		0x25
+#define QLCNIC_CMD_GET_ESWITCH_STATUS		0x26
+#define QLCNIC_CMD_SET_PORTMIRRORING		0x27
+#define QLCNIC_CMD_CONFIGURE_ESWITCH		0x28
+#define QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG	0x29
+#define QLCNIC_CMD_GET_ESWITCH_STATS		0x2a
+#define QLCNIC_CMD_CONFIG_PORT			0x2e
+#define QLCNIC_CMD_TEMP_SIZE			0x2f
+#define QLCNIC_CMD_GET_TEMP_HDR		0x30
+#define QLCNIC_CMD_GET_MAC_STATS		0x37
+#define QLCNIC_CMD_SET_DRV_VER			0x38
+#define QLCNIC_CMD_CONFIGURE_RSS		0x41
+#define QLCNIC_CMD_CONFIG_INTR_COAL		0x43
+#define QLCNIC_CMD_CONFIGURE_LED		0x44
+#define QLCNIC_CMD_CONFIG_MAC_VLAN		0x45
+#define QLCNIC_CMD_GET_LINK_EVENT		0x48
+#define QLCNIC_CMD_CONFIGURE_MAC_RX_MODE	0x49
+#define QLCNIC_CMD_CONFIGURE_HW_LRO		0x4A
+#define QLCNIC_CMD_INIT_NIC_FUNC		0x60
+#define QLCNIC_CMD_STOP_NIC_FUNC		0x61
+#define QLCNIC_CMD_IDC_ACK			0x63
+#define QLCNIC_CMD_SET_PORT_CONFIG		0x66
+#define QLCNIC_CMD_GET_PORT_CONFIG		0x67
+#define QLCNIC_CMD_GET_LINK_STATUS		0x68
+#define QLCNIC_CMD_SET_LED_CONFIG		0x69
+#define QLCNIC_CMD_GET_LED_CONFIG		0x6A
+
+#define QLCNIC_INTRPT_INTX			1
+#define QLCNIC_INTRPT_MSIX			3
+#define QLCNIC_INTRPT_ADD			1
+#define QLCNIC_INTRPT_DEL			2
+
+#define QLCNIC_GET_CURRENT_MAC			1
+#define QLCNIC_SET_STATION_MAC			2
+#define QLCNIC_GET_DEFAULT_MAC			3
+#define QLCNIC_GET_FAC_DEF_MAC			4
+#define QLCNIC_SET_FAC_DEF_MAC			5
+
+#define QLCNIC_MBX_LINK_EVENT		0x8001
+#define QLCNIC_MBX_COMP_EVENT		0x8100
+#define QLCNIC_MBX_REQUEST_EVENT	0x8101
+#define QLCNIC_MBX_TIME_EXTEND_EVENT	0x8102
+#define QLCNIC_MBX_SFP_INSERT_EVENT	0x8130
+#define QLCNIC_MBX_SFP_REMOVE_EVENT	0x8131
+
+struct qlcnic_mailbox_metadata {
+	u32 cmd;
+	u32 in_args;
+	u32 out_args;
+};
+
+#define QLCNIC_MBX_RSP_OK	1
+#define QLCNIC_MBX_PORT_RSP_OK	0x1a
+
+struct qlcnic_pci_info;
+struct qlcnic_info;
+struct qlcnic_cmd_args;
+struct ethtool_stats;
+struct pci_device_id;
+struct qlcnic_host_sds_ring;
+struct qlcnic_host_tx_ring;
+struct qlcnic_host_tx_ring;
+struct qlcnic_hardware_context;
+struct qlcnic_adapter;
+
+int qlcnic_82xx_start_firmware(struct qlcnic_adapter *);
+int qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong);
+int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong, u32);
+int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int);
+int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
+int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
+			 struct net_device *netdev);
+void qlcnic_82xx_change_filter(struct qlcnic_adapter *, u64 *, __le16);
+void qlcnic_82xx_config_intr_coalesce(struct qlcnic_adapter *adapter);
+int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int);
+void qlcnic_82xx_config_ipaddr(struct qlcnic_adapter *adapter,
+			       __be32, int);
+int qlcnic_82xx_linkevent_request(struct qlcnic_adapter *adapter, int);
+void qlcnic_82xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
+int qlcnic_82xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8);
+int qlcnic_82xx_set_lb_mode(struct qlcnic_adapter *, u8);
+void qlcnic_82xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
+void qlcnic_82xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
+void qlcnic_82xx_dev_request_reset(struct qlcnic_adapter *, u32);
+int qlcnic_82xx_setup_intr(struct qlcnic_adapter *, u8);
+irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *);
+int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
+			  struct qlcnic_cmd_args *);
+int qlcnic_82xx_fw_cmd_create_rx_ctx(struct qlcnic_adapter *);
+int qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *,
+				     struct qlcnic_host_tx_ring *tx_ring, int);
+int qlcnic_82xx_sre_macaddr_change(struct qlcnic_adapter *, u8 *, __le16, u8);
+int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *, u8*);
+int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
+int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
+int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
+int qlcnic_82xx_alloc_mbx_args(struct qlcnic_cmd_args *,
+			       struct qlcnic_adapter *, u32);
+int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong, u32);
+int qlcnic_82xx_get_board_info(struct qlcnic_adapter *);
+int qlcnic_82xx_config_led(struct qlcnic_adapter *, u32, u32);
+void qlcnic_82xx_get_func_no(struct qlcnic_adapter *);
+int qlcnic_82xx_api_lock(struct qlcnic_adapter *);
+void qlcnic_82xx_api_unlock(struct qlcnic_adapter *);
+void qlcnic_82xx_napi_enable(struct qlcnic_adapter *);
+void qlcnic_82xx_napi_disable(struct qlcnic_adapter *);
+#endif				/* __QLCNIC_HW_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index aff714a..15879ec 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -29,8 +29,8 @@ static inline u32 qlcnic_get_ref_handle(struct qlcnic_adapter *adapter,
 		return handle;
 }
 
-void qlcnic_change_filter(struct qlcnic_adapter *adapter, u64 *uaddr,
-			  __le16 vlan_id)
+void qlcnic_82xx_change_filter(struct qlcnic_adapter *adapter, u64 *uaddr,
+			       __le16 vlan_id)
 {
 	struct cmd_desc_type0 *hwdesc;
 	struct qlcnic_nic_req *req;
@@ -1078,7 +1078,7 @@ static void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 	return;
 }
 
-void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
+void qlcnic_82xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 {
 	struct qlcnic_adapter *adapter = sds_ring->adapter;
 	struct status_desc *desc;
@@ -1135,7 +1135,8 @@ void qlcnic_fetch_mac(struct qlcnic_adapter *adapter, u32 off1, u32 off2,
 		mac[i] = (u8)(mac_low >> ((5 - i) * 8));
 }
 
-int qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
+int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
+			 struct net_device *netdev)
 {
 	int ring, max_sds_rings;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -1179,7 +1180,7 @@ void qlcnic_napi_del(struct qlcnic_adapter *adapter)
 	qlcnic_free_tx_rings(adapter);
 }
 
-void qlcnic_napi_enable(struct qlcnic_adapter *adapter)
+void qlcnic_82xx_napi_enable(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -1195,7 +1196,7 @@ void qlcnic_napi_enable(struct qlcnic_adapter *adapter)
 	}
 }
 
-void qlcnic_napi_disable(struct qlcnic_adapter *adapter)
+void qlcnic_82xx_napi_disable(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 309ac3a..19dd239 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -74,6 +74,8 @@ static void qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
+static void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter);
+static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter);
 
 static void qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding);
 static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8);
@@ -127,6 +129,32 @@ static const u32 msi_tgt_status[8] = {
 	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
 };
 
+static const u32 qlcnic_reg_tbl[] = {
+	0x1B20A8,	/* PEG_HALT_STAT1 */
+	0x1B20AC,	/* PEG_HALT_STAT2 */
+	0x1B20B0,	/* FW_HEARTBEAT */
+	0x1B2100,	/* LOCK ID */
+	0x1B2128,	/* FW_CAPABILITIES */
+	0x1B2138,	/* drv active */
+	0x1B2140,	/* dev state */
+	0x1B2144,	/* drv state */
+	0x1B2148,	/* drv scratch */
+	0x1B214C,	/* dev partition info */
+	0x1B2174,	/* drv idc ver */
+	0x1B2150,	/* fw version major */
+	0x1B2154,	/* fw version minor */
+	0x1B2158,	/* fw version sub */
+	0x1B219C,	/* npar state */
+	0x1B21FC,	/* FW_IMG_VALID */
+	0x1B2250,	/* CMD_PEG_STATE */
+	0x1B233C,	/* RCV_PEG_STATE */
+	0x1B23B4,	/* ASIC TEMP */
+	0x1B216C,	/* FW api */
+	0x1B2170,	/* drv op mode */
+	0x13C010,	/* flash lock */
+	0x13C014,	/* flash unlock */
+};
+
 static const
 struct qlcnic_legacy_intr_set legacy_intr[] = QLCNIC_LEGACY_INTR_CONFIG;
 
@@ -147,11 +175,6 @@ void qlcnic_free_sds_rings(struct qlcnic_recv_context *recv_ctx)
 	recv_ctx->sds_rings = NULL;
 }
 
-static void qlcnic_clear_stats(struct qlcnic_adapter *adapter)
-{
-	memset(&adapter->stats, 0, sizeof(adapter->stats));
-}
-
 static void qlcnic_set_msix_bit(struct pci_dev *pdev, int enable)
 {
 	u32 control;
@@ -226,6 +249,14 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
+static void qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
+{
+	while (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		usleep_range(10000, 11000);
+
+	cancel_delayed_work_sync(&adapter->fw_work);
+}
+
 static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_open	   = qlcnic_open,
 	.ndo_stop	   = qlcnic_close,
@@ -250,15 +281,54 @@ static const struct net_device_ops qlcnic_netdev_failed_ops = {
 };
 
 static struct qlcnic_nic_template qlcnic_ops = {
-	.config_bridged_mode = qlcnic_config_bridged_mode,
-	.config_led = qlcnic_config_led,
-	.start_firmware = qlcnic_start_firmware
+	.config_bridged_mode	= qlcnic_config_bridged_mode,
+	.config_led		= qlcnic_82xx_config_led,
+	.start_firmware		= qlcnic_82xx_start_firmware,
+	.request_reset		= qlcnic_82xx_dev_request_reset,
+	.cancel_idc_work	= qlcnic_82xx_cancel_idc_work,
+	.napi_add		= qlcnic_82xx_napi_add,
+	.config_ipaddr		= qlcnic_82xx_config_ipaddr,
+	.clear_legacy_intr	= qlcnic_82xx_clear_legacy_intr,
+};
+
+struct qlcnic_nic_template qlcnic_vf_ops = {
+	.config_bridged_mode	= qlcnicvf_config_bridged_mode,
+	.config_led		= qlcnicvf_config_led,
+	.start_firmware		= qlcnicvf_start_firmware
 };
 
-static struct qlcnic_nic_template qlcnic_vf_ops = {
-	.config_bridged_mode = qlcnicvf_config_bridged_mode,
-	.config_led = qlcnicvf_config_led,
-	.start_firmware = qlcnicvf_start_firmware
+static struct qlcnic_hardware_ops qlcnic_hw_ops = {
+	.read_crb			= qlcnic_82xx_read_crb,
+	.write_crb			= qlcnic_82xx_write_crb,
+	.read_reg			= qlcnic_82xx_hw_read_wx_2M,
+	.write_reg			= qlcnic_82xx_hw_write_wx_2M,
+	.get_mac_address		= qlcnic_82xx_get_mac_address,
+	.setup_intr			= qlcnic_82xx_setup_intr,
+	.alloc_mbx_args			= qlcnic_82xx_alloc_mbx_args,
+	.mbx_cmd			= qlcnic_82xx_issue_cmd,
+	.get_func_no			= qlcnic_82xx_get_func_no,
+	.api_lock			= qlcnic_82xx_api_lock,
+	.api_unlock			= qlcnic_82xx_api_unlock,
+	.add_sysfs			= qlcnic_82xx_add_sysfs,
+	.remove_sysfs			= qlcnic_82xx_remove_sysfs,
+	.process_lb_rcv_ring_diag	= qlcnic_82xx_process_rcv_ring_diag,
+	.create_rx_ctx			= qlcnic_82xx_fw_cmd_create_rx_ctx,
+	.create_tx_ctx			= qlcnic_82xx_fw_cmd_create_tx_ctx,
+	.setup_link_event		= qlcnic_82xx_linkevent_request,
+	.get_nic_info			= qlcnic_82xx_get_nic_info,
+	.get_pci_info			= qlcnic_82xx_get_pci_info,
+	.set_nic_info			= qlcnic_82xx_set_nic_info,
+	.change_macvlan			= qlcnic_82xx_sre_macaddr_change,
+	.napi_enable			= qlcnic_82xx_napi_enable,
+	.napi_disable			= qlcnic_82xx_napi_disable,
+	.config_intr_coal		= qlcnic_82xx_config_intr_coalesce,
+	.config_rss			= qlcnic_82xx_config_rss,
+	.config_hw_lro			= qlcnic_82xx_config_hw_lro,
+	.config_loopback		= qlcnic_82xx_set_lb_mode,
+	.clear_loopback			= qlcnic_82xx_clear_lb_mode,
+	.config_promisc_mode		= qlcnic_82xx_nic_set_promisc,
+	.change_l2_filter		= qlcnic_82xx_change_filter,
+	.get_board_info			= qlcnic_82xx_get_board_info,
 };
 
 static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
@@ -321,21 +391,25 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 	adapter->msix_entries[0].vector = pdev->irq;
 }
 
-static void
-qlcnic_setup_intr(struct qlcnic_adapter *adapter)
+int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 {
-	int num_msix;
+	int num_msix, err;
 
-	if (adapter->ahw->msix_supported) {
+	if (!num_intr)
+		num_intr = QLCNIC_DEF_NUM_STS_DESC_RINGS;
+
+	if (adapter->ahw->msix_supported)
 		num_msix = rounddown_pow_of_two(min_t(int, num_online_cpus(),
-				QLCNIC_DEF_NUM_STS_DESC_RINGS));
-	} else
+						num_intr));
+	else
 		num_msix = 1;
 
-	if (!qlcnic_enable_msix(adapter, num_msix))
-		return;
+	err = qlcnic_enable_msix(adapter, num_msix);
+	if (err == -ENOMEM || !err)
+		return err;
 
 	qlcnic_enable_msi_legacy(adapter);
+	return 0;
 }
 
 static void
@@ -347,11 +421,10 @@ qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 		pci_disable_msi(adapter->pdev);
 }
 
-static void
-qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
+static void qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
 {
-	if (adapter->ahw->pci_base0 != NULL)
-		iounmap(adapter->ahw->pci_base0);
+	if (ahw->pci_base0 != NULL)
+		iounmap(ahw->pci_base0);
 }
 
 static int
@@ -450,29 +523,21 @@ err_lock:
 	return ret;
 }
 
-static void
-qlcnic_check_vf(struct qlcnic_adapter *adapter)
+static void qlcnic_check_vf(struct qlcnic_adapter *adapter,
+			    const struct pci_device_id *ent)
 {
-	void __iomem *msix_base_addr;
 	void __iomem *priv_op;
-	u32 func;
-	u32 msix_base;
 	u32 op_mode, priv_level;
 
 	/* Determine FW API version */
-	adapter->ahw->fw_hal_version = readl(adapter->ahw->pci_base0 +
-					     QLCNIC_FW_API);
+	adapter->ahw->fw_hal_version = QLCRD32(adapter, QLCNIC_FW_API);
 
 	/* Find PCI function number */
-	pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
-	msix_base_addr = adapter->ahw->pci_base0 + QLCNIC_MSIX_BASE;
-	msix_base = readl(msix_base_addr);
-	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
-	adapter->ahw->pci_func = func;
+	qlcnic_get_func_no(adapter);
 
 	/* Determine function privilege level */
 	priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
-	op_mode = readl(priv_op);
+	op_mode = QLCRD32(adapter, QLCNIC_DRV_OP_MODE);
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
@@ -921,8 +986,7 @@ qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static int
-qlcnic_start_firmware(struct qlcnic_adapter *adapter)
+int qlcnic_82xx_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int err;
 
@@ -1452,19 +1516,6 @@ static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
 	return 0;
 }
 
-static int
-qlcnic_alloc_msix_entries(struct qlcnic_adapter *adapter, u16 count)
-{
-	adapter->msix_entries = kcalloc(count, sizeof(struct msix_entry),
-					GFP_KERNEL);
-
-	if (adapter->msix_entries)
-		return 0;
-
-	dev_err(&adapter->pdev->dev, "failed allocating msix_entries\n");
-	return -ENOMEM;
-}
-
 void qlcnic_free_tx_rings(struct qlcnic_adapter *adapter)
 {
 	int ring;
@@ -1518,8 +1569,8 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
 	struct qlcnic_adapter *adapter = NULL;
+	struct qlcnic_hardware_context *ahw;
 	int err;
-	uint8_t revision_id;
 	uint8_t pci_using_dac;
 	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
@@ -1543,10 +1594,23 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_master(pdev);
 	pci_enable_pcie_error_reporting(pdev);
 
+	ahw = kzalloc(sizeof(struct qlcnic_hardware_context), GFP_KERNEL);
+	if (!ahw)
+		goto err_out_free_res;
+
+	if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE824X) {
+		ahw->hw_ops = &qlcnic_hw_ops;
+		ahw->reg_tbl = (u32 *)qlcnic_reg_tbl;
+	}
+
+	err = qlcnic_setup_pci_map(pdev, ahw);
+	if (err)
+		goto err_out_free_hw_res;
+
 	netdev = alloc_etherdev(sizeof(struct qlcnic_adapter));
 	if (!netdev) {
 		err = -ENOMEM;
-		goto err_out_free_res;
+		goto err_out_iounmap;
 	}
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -1560,8 +1624,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_netdev;
 
 	adapter->dev_rst_time = jiffies;
-	revision_id = pdev->revision;
-	adapter->ahw->revision_id = revision_id;
+	adapter->ahw->revision_id = pdev->revision;
 	adapter->mac_learn = qlcnic_mac_learn;
 
 	rwlock_init(&adapter->ahw->crb_lock);
@@ -1570,30 +1633,20 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
 
-	err = qlcnic_setup_pci_map(pdev, adapter->ahw);
-	if (err)
-		goto err_out_free_hw;
-
-	/* This will be reset for mezz cards  */
-	adapter->portnum = adapter->ahw->pci_func;
-
-	err = qlcnic_get_board_info(adapter);
-	if (err) {
-		dev_err(&pdev->dev, "Error getting board config info.\n");
-		goto err_out_iounmap;
-	}
-
-	err = qlcnic_setup_idc_param(adapter);
-	if (err)
-		goto err_out_iounmap;
+	if (qlcnic_82xx_check(adapter)) {
+		qlcnic_check_vf(adapter, ent);
+		adapter->portnum = adapter->ahw->pci_func;
+		err = qlcnic_start_firmware(adapter);
+		if (err) {
+			dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n");
+			goto err_out_free_hw;
+		}
 
-	adapter->flags |= QLCNIC_NEED_FLR;
+		err = qlcnic_setup_idc_param(adapter);
+		if (err)
+			goto err_out_free_hw;
 
-	err = adapter->nic_ops->start_firmware(adapter);
-	if (err) {
-		dev_err(&pdev->dev, "Loading fw failed. Please Reboot\n"
-			"\t\tIf reboot doesn't help, try flashing the card\n");
-		goto err_out_maintenance_mode;
+		adapter->flags |= QLCNIC_NEED_FLR;
 	}
 
 	if (qlcnic_read_mac_addr(adapter))
@@ -1606,22 +1659,20 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				module_name(THIS_MODULE),
 				brd_name, adapter->ahw->revision_id);
 	}
-
-	qlcnic_clear_stats(adapter);
-
-	err = qlcnic_alloc_msix_entries(adapter, adapter->ahw->max_rx_ques);
+	err = qlcnic_setup_intr(adapter, 0);
 	if (err)
-		goto err_out_decr_ref;
+		goto err_out_disable_msi;
 
-	qlcnic_setup_intr(adapter);
 
 	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
 	if (err)
-		goto err_out_disable_msi;
+		goto err_out_disable_mbx_intr;
 
 	pci_set_drvdata(pdev, adapter);
 
-	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
+	if (qlcnic_82xx_check(adapter))
+		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
+				     FW_POLL_DELAY);
 
 	switch (adapter->ahw->port_type) {
 	case QLCNIC_GBE:
@@ -1637,26 +1688,29 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (adapter->mac_learn)
 		qlcnic_alloc_lb_filters_mem(adapter);
 
-	qlcnic_create_diag_entries(adapter);
+	qlcnic_add_sysfs(adapter);
 
 	return 0;
 
+err_out_disable_mbx_intr:
+
 err_out_disable_msi:
 	qlcnic_teardown_intr(adapter);
-	kfree(adapter->msix_entries);
-
-err_out_decr_ref:
+	qlcnic_cancel_idc_work(adapter);
 	qlcnic_clr_all_drv_state(adapter, 0);
 
-err_out_iounmap:
-	qlcnic_cleanup_pci_map(adapter);
-
 err_out_free_hw:
 	qlcnic_free_adapter_resources(adapter);
 
 err_out_free_netdev:
 	free_netdev(netdev);
 
+err_out_iounmap:
+	qlcnic_cleanup_pci_map(ahw);
+
+err_out_free_hw_res:
+	kfree(ahw);
+
 err_out_free_res:
 	pci_release_regions(pdev);
 
@@ -1664,24 +1718,13 @@ err_out_disable_pdev:
 	pci_set_drvdata(pdev, NULL);
 	pci_disable_device(pdev);
 	return err;
-
-err_out_maintenance_mode:
-	netdev->netdev_ops = &qlcnic_netdev_failed_ops;
-	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_failed_ops);
-	err = register_netdev(netdev);
-	if (err) {
-		dev_err(&pdev->dev, "failed to register net device\n");
-		goto err_out_decr_ref;
-	}
-	pci_set_drvdata(pdev, adapter);
-	qlcnic_create_diag_entries(adapter);
-	return 0;
 }
 
 static void __devexit qlcnic_remove(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter;
 	struct net_device *netdev;
+	struct qlcnic_hardware_context *ahw;
 
 	adapter = pci_get_drvdata(pdev);
 	if (adapter == NULL)
@@ -1689,7 +1732,8 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 
 	netdev = adapter->netdev;
 
-	qlcnic_cancel_fw_work(adapter);
+	qlcnic_cancel_idc_work(adapter);
+	ahw = adapter->ahw;
 
 	unregister_netdev(netdev);
 
@@ -1700,18 +1744,18 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	if (adapter->eswitch != NULL)
 		kfree(adapter->eswitch);
 
-	qlcnic_clr_all_drv_state(adapter, 0);
+	if (qlcnic_82xx_check(adapter))
+		qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
 	qlcnic_free_lb_filters_mem(adapter);
 
 	qlcnic_teardown_intr(adapter);
-	kfree(adapter->msix_entries);
 
-	qlcnic_remove_diag_entries(adapter);
+	qlcnic_remove_sysfs(adapter);
 
-	qlcnic_cleanup_pci_map(adapter);
+	qlcnic_cleanup_pci_map(ahw);
 
 	qlcnic_release_firmware(adapter);
 
@@ -1721,8 +1765,10 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 
 	qlcnic_free_adapter_resources(adapter);
+	kfree(ahw);
 	free_netdev(netdev);
 }
+
 static int __qlcnic_shutdown(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
@@ -1743,10 +1789,11 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	retval = pci_save_state(pdev);
 	if (retval)
 		return retval;
-
-	if (qlcnic_wol_supported(adapter)) {
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
+	if (qlcnic_82xx_check(adapter)) {
+		if (qlcnic_wol_supported(adapter)) {
+			pci_enable_wake(pdev, PCI_D3cold, 1);
+			pci_enable_wake(pdev, PCI_D3hot, 1);
+		}
 	}
 
 	return 0;
@@ -1881,7 +1928,7 @@ static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
 	adapter->fhash.fmax = 0;
 }
 
-static int qlcnic_check_temp(struct qlcnic_adapter *adapter)
+int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	u32 temp, temp_state, temp_val;
@@ -1947,7 +1994,7 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
 	return stats;
 }
 
-static irqreturn_t qlcnic_clear_legacy_intr(struct qlcnic_adapter *adapter)
+irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
 {
 	u32 status;
 
@@ -2302,7 +2349,7 @@ skip_ack_check:
 		qlcnic_api_unlock(adapter);
 
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
-		if (!adapter->nic_ops->start_firmware(adapter)) {
+		if (!qlcnic_start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			adapter->fw_wait_cnt = 0;
 			return;
@@ -2318,7 +2365,7 @@ wait_npar:
 
 	switch (dev_state) {
 	case QLCNIC_DEV_READY:
-		if (!adapter->nic_ops->start_firmware(adapter)) {
+		if (!qlcnic_start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			adapter->fw_wait_cnt = 0;
 			return;
@@ -2416,9 +2463,7 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
 	qlcnic_api_unlock(adapter);
 }
 
-/*Transit to RESET state from READY state only */
-void
-qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
+void qlcnic_82xx_dev_request_reset(struct qlcnic_adapter *adapter, u32 key)
 {
 	u32 state, xg_val = 0, gb_val = 0;
 
@@ -2433,16 +2478,11 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 	dev_info(&adapter->pdev->dev, "Pause control frames disabled"
 				" on all ports\n");
 	adapter->need_fw_reset = 1;
+
 	if (qlcnic_api_lock(adapter))
 		return;
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-	if (state  == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD)) {
-		netdev_err(adapter->netdev,
-				"Device is in FAILED state, Please Reboot\n");
-		qlcnic_api_unlock(adapter);
-		return;
-	}
 
 	if (state == QLCNIC_DEV_READY) {
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
@@ -2451,7 +2491,8 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 		qlcnic_idc_debug_info(adapter, 0);
 	}
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
+	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
+		QLCNIC_DEV_NPAR_NON_OPER);
 	qlcnic_api_unlock(adapter);
 }
 
@@ -2541,7 +2582,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		goto detach;
 
 	if (adapter->need_fw_reset)
-		qlcnic_dev_request_reset(adapter);
+		qlcnic_dev_request_reset(adapter, 0);
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 	if (state == QLCNIC_DEV_NEED_RESET) {
@@ -2570,7 +2611,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 
 	adapter->flags |= QLCNIC_FW_HANG;
 
-	qlcnic_dev_request_reset(adapter);
+	qlcnic_dev_request_reset(adapter, 0);
 
 	if (auto_fw_reset)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
@@ -2677,12 +2718,14 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	}
 	qlcnic_api_unlock(adapter);
 
-	err = adapter->nic_ops->start_firmware(adapter);
+	err = qlcnic_start_firmware(adapter);
 	if (err)
 		return err;
 
 	qlcnic_clr_drv_state(adapter);
-	qlcnic_setup_intr(adapter);
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
+	err = qlcnic_setup_intr(adapter, 0);
 
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
@@ -3771,6 +3814,16 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	device_remove_bin_file(dev, &bin_attr_esw_stats);
 }
 
+static void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_create_diag_entries(adapter);
+}
+
+static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_remove_diag_entries(adapter);
+}
+
 #ifdef CONFIG_INET
 
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
-- 
1.7.1
