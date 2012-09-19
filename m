From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v1 05/19] qlcnic: change driver hardware interface mechanism
Date: Wed, 19 Sep 2012 19:45:59 -0400
Message-ID: <1348098373-20745-6-git-send-email-sony.chacko@qlogic.com>
References: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:4222 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751558Ab2ITBw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 21:52:29 -0400
In-Reply-To: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA

Create mailbox based hardware interface mechanism
Seperate 82xx adapter hardware specific routines
Change register access macros:
QLCRD and QLCWR macros are used to access common registers.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  334 +++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |  500 ++++++++++--------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   73 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    5 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  132 ++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |  220 ++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   48 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   23 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  534 ++++++++++++--------
 9 files changed, 1278 insertions(+), 591 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 680b3b6..a50219b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -490,6 +490,7 @@ struct qlcnic_hardware_context {
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
+	u32 *reg_tbl;
 };
 
 struct qlcnic_adapter_stats {
@@ -583,10 +584,6 @@ struct qlcnic_recv_context {
 /* HW context creation */
 
 #define QLCNIC_OS_CRB_RETRY_COUNT	4000
-
-#define QLCNIC_CDRP_SIGNATURE_MAKE(pcifn, version) \
-	(((pcifn) & 0xff) | (((version) & 0xff) << 8) | (0xcafe << 16))
-
 #define QLCNIC_CDRP_CMD_BIT		0x80000000
 
 /*
@@ -1212,7 +1209,7 @@ do {	\
 			(VAL1) += (VAL2); \
 } while (0)
 
-struct qlcnic_mac_statistics{
+struct qlcnic_mac_statistics {
 	__le64	mac_tx_frames;
 	__le64	mac_tx_bytes;
 	__le64	mac_tx_mcast_pkts;
@@ -1422,10 +1419,8 @@ struct qlcnic_dump_operations {
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
@@ -1436,8 +1431,6 @@ struct qlcnic_cmd_args {
 int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter);
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
 
-u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off);
-int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
 void qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *, u64, u64 *);
@@ -1446,11 +1439,10 @@ void qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *, u64, u64);
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) < (high)) && ((addr) >= (low)))
 
-#define QLCRD32(adapter, off) \
-	(qlcnic_hw_read_wx_2M(adapter, off))
-
+#define QLCRD32(adapter, off, err) \
+	(adapter->ahw->hw_ops->read_reg)(adapter, off, err)
 #define QLCWR32(adapter, off, val) \
-	(qlcnic_hw_write_wx_2M(adapter, off, val))
+	adapter->ahw->hw_ops->write_reg(adapter, off, val)
 
 int qlcnic_pcie_sem_lock(struct qlcnic_adapter *, int, u32);
 void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
@@ -1463,10 +1455,6 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
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
@@ -1479,9 +1467,7 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 #define __QLCNIC_MAX_LED_RATE	0xf
 #define __QLCNIC_MAX_LED_STATE	0x2
 
-int qlcnic_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
-int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 int qlcnic_dump_fw(struct qlcnic_adapter *);
@@ -1520,46 +1506,36 @@ void qlcnic_post_rx_buffers(struct qlcnic_adapter *,
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
+void qlcnic_set_vlan_config(struct qlcnic_adapter *,
+			    struct qlcnic_esw_func_cfg *);
+/* functions in qlcnic_sysfs.c */
+int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
 
 /*  eSwitch management functions */
 int qlcnic_config_switch_port(struct qlcnic_adapter *,
@@ -1573,13 +1549,14 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *, const u8, u8,
 					struct __qlcnic_esw_statistics *);
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, u8, u8, u8);
 int qlcnic_get_mac_stats(struct qlcnic_adapter *, struct qlcnic_mac_statistics *);
-extern int qlcnic_config_tso;
+void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd);
+void qlcnic_napi_del(struct qlcnic_adapter *);
+int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *, int);
+void qlcnic_free_sds_rings(struct qlcnic_recv_context *);
+void qlcnic_free_tx_rings(struct qlcnic_adapter *);
+int qlcnic_alloc_tx_rings(struct qlcnic_adapter *, struct net_device *);
 
 void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);
-int qlcnic_napi_add(struct qlcnic_adapter *, struct net_device *);
-void qlcnic_napi_del(struct qlcnic_adapter *adapter);
-void qlcnic_napi_enable(struct qlcnic_adapter *adapter);
-void qlcnic_napi_disable(struct qlcnic_adapter *adapter);
 int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *, int);
 void qlcnic_free_sds_rings(struct qlcnic_recv_context *);
 void qlcnic_free_tx_rings(struct qlcnic_adapter *);
@@ -1631,6 +1608,271 @@ static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
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
+/* function template for hardware ops based on different chip type */
+struct qlcnic_hardware_ops {
+	void (*read_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
+	void (*write_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
+	u32 (*read_reg) (struct qlcnic_adapter *, ulong, int *);
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
+				       ulong off, int *err)
+{
+	return adapter->ahw->hw_ops->read_reg(adapter, off, err);
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
@@ -1649,12 +1891,6 @@ static inline void qlcnic_enable_int(struct qlcnic_host_sds_ring *sds_ring)
 extern const struct ethtool_ops qlcnic_ethtool_ops;
 extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
 
-struct qlcnic_nic_template {
-	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
-	int (*config_led) (struct qlcnic_adapter *, u32, u32);
-	int (*start_firmware) (struct qlcnic_adapter *);
-};
-
 #define QLC_TCP_HDR_SIZE            20
 #define QLC_TCP_TS_OPTION_SIZE      12
 #define QLC_TCP_TS_HDR_SIZE         (QLC_TCP_HDR_SIZE + QLC_TCP_TS_OPTION_SIZE)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 910b67e..56a1eba 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -7,11 +7,89 @@
 
 #include "qlcnic.h"
 
+/* Array of FW control command structs with command type and required
+ * number of input and output arguments respectively.
+*/
+static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
+	{ QLCNIC_CMD_CREATE_RX_CTX, 4, 1 },
+	{ QLCNIC_CMD_DESTROY_RX_CTX, 2, 1 },
+	{ QLCNIC_CMD_CREATE_TX_CTX, 4, 1 },
+	{ QLCNIC_CMD_DESTROY_TX_CTX, 2, 1 },
+	{ QLCNIC_CMD_INTRPT_TEST, 4, 1 },
+	{ QLCNIC_CMD_SET_MTU, 4, 1 },
+	{ QLCNIC_CMD_READ_PHY, 4, 2 },
+	{ QLCNIC_CMD_WRITE_PHY, 5, 1 },
+	{ QLCNIC_CMD_READ_HW_REG, 4, 1 },
+	{ QLCNIC_CMD_GET_FLOW_CTL, 4, 2 },
+	{ QLCNIC_CMD_SET_FLOW_CTL, 4, 1 },
+	{ QLCNIC_CMD_READ_MAX_MTU, 4, 2 },
+	{ QLCNIC_CMD_READ_MAX_LRO, 4, 2 },
+	{ QLCNIC_CMD_MAC_ADDRESS, 4, 3 },
+	{ QLCNIC_CMD_GET_PCI_INFO, 4, 1 },
+	{ QLCNIC_CMD_GET_NIC_INFO, 4, 1 },
+	{ QLCNIC_CMD_SET_NIC_INFO, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_CAPABILITY, 4, 3 },
+	{ QLCNIC_CMD_TOGGLE_ESWITCH, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_STATUS, 4, 3 },
+	{ QLCNIC_CMD_SET_PORTMIRRORING, 4, 1 },
+	{ QLCNIC_CMD_CONFIGURE_ESWITCH, 4, 1 },
+	{ QLCNIC_CMD_GET_MAC_STATS, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG, 4, 3 },
+	{ QLCNIC_CMD_GET_ESWITCH_STATS, 5, 1 },
+	{ QLCNIC_CMD_CONFIG_PORT, 4, 1 },
+	{ QLCNIC_CMD_TEMP_SIZE, 4, 4 },
+	{ QLCNIC_CMD_GET_TEMP_HDR, 4, 1 },
+	{ QLCNIC_CMD_SET_DRV_VER, 4, 1 },
+};
+
+/* Allocate mailbox registers */
+int qlcnic_82xx_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
+				struct qlcnic_adapter *adapter, u32 type)
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
+				sizeof(u32), GFP_ATOMIC);
+			if (!mbx->req.arg)
+				return -ENOMEM;
+			mbx->rsp.arg = kcalloc(mbx->rsp.num,
+				sizeof(u32), GFP_ATOMIC);
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
 	u32 rsp;
-	int timeout = 0;
+	int err, timeout = 0;
 
 	do {
 		/* give atleast 1ms for firmware to respond */
@@ -20,113 +98,85 @@ qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 		if (++timeout > QLCNIC_OS_CRB_RETRY_COUNT)
 			return QLCNIC_CDRP_RSP_TIMEOUT;
 
-		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET);
+		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET, &err);
 	} while (!QLCNIC_CDRP_IS_RSP(rsp));
 
 	return rsp;
 }
 
-void
-qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
+static inline u32 qlcnic_get_cmd_signature(struct qlcnic_hardware_context *ahw)
+{                                 \
+	return ((ahw->pci_func) & 0xff) |
+		(((ahw->fw_hal_version) & 0xff) << 8) | (0xcafe << 16);
+}
+
+int
+qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
+		       struct qlcnic_cmd_args *cmd)
 {
+	int i, err;
 	u32 rsp;
 	u32 signature;
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	signature = QLCNIC_CDRP_SIGNATURE_MAKE(ahw->pci_func,
-		adapter->ahw->fw_hal_version);
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
+		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1), &err);
+		dev_err(&pdev->dev, "failed card response code:0x%x\n",
+			cmd->rsp.arg[0]);
+	} else if (rsp == QLCNIC_CDRP_RSP_OK)
+		cmd->rsp.arg[0] = QLCNIC_RCODE_SUCCESS;
+
+	for (i = 1; i < cmd->rsp.num; i++)
+		cmd->rsp.arg[i] = QLCRD32(adapter, QLCNIC_CDRP_ARG(i), &err);
 
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
+int
+qlcnic_82xx_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 {
 	void *addr;
 	struct qlcnic_hostrq_rx_ctx *prq;
@@ -179,9 +229,6 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 						| QLCNIC_CAP0_VALIDOFF);
 	cap |= (QLCNIC_CAP0_JUMBO_CONTIGUOUS | QLCNIC_CAP0_LRO_CONTIGUOUS);
 
-	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
-		cap |= QLCNIC_CAP0_LRO_MSS;
-
 	prq->valid_field_offset = offsetof(struct qlcnic_hostrq_rx_ctx,
 							 msix_handler);
 	prq->txrx_sds_binding = nsds_rings - 1;
@@ -229,20 +276,17 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
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
 
@@ -273,6 +317,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 out_free_rsp:
 	dma_free_coherent(&adapter->pdev->dev, rsp_size, prsp,
 		cardrsp_phys_addr);
+	qlcnic_free_mbx_args(&cmd);
 out_free_rq:
 	dma_free_coherent(&adapter->pdev->dev, rq_size, prq, hostrq_phys_addr);
 	return err;
@@ -281,24 +326,24 @@ out_free_rq:
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
+int
+qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
+				 struct qlcnic_host_tx_ring *tx_ring, int ring)
 {
 	struct qlcnic_hostrq_tx_ctx	*prq;
 	struct qlcnic_hostrq_cds_ring	*prq_cds;
@@ -310,7 +355,6 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	int	err;
 	u64	phys_addr;
 	dma_addr_t	rq_phys_addr, rsp_phys_addr;
-	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 
 	/* reset host resources */
 	tx_ring->producer = 0;
@@ -345,9 +389,9 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 	prq->host_int_crb_mode =
 		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
+	prq->msi_index = 0;
 
 	prq->interrupt_ctl = 0;
-	prq->msi_index = 0;
 	prq->cmd_cons_dma_addr = cpu_to_le64(tx_ring->hw_cons_phys_addr);
 
 	prq_cds = &prq->cds_ring;
@@ -356,20 +400,17 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
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
-
-		adapter->tx_ring->ctx_id =
-			le16_to_cpu(prsp->context_id);
+		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
 	} else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to create tx ctx in firmware%d\n", err);
@@ -377,41 +418,40 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
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
+			      struct qlcnic_host_tx_ring *tx_ring)
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
@@ -488,7 +528,7 @@ err_out_free:
 
 int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 {
-	int err;
+	int i, err, ring;
 
 	if (adapter->flags & QLCNIC_NEED_FLR) {
 		pci_reset_function(adapter->pdev);
@@ -499,10 +539,19 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
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
+			for (i = 0; i < ring; i++)
+				qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+							&adapter->tx_ring[i]);
+			return err;
+		}
 	}
 
 	set_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
@@ -511,9 +560,13 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 
 void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
 {
+	int ring;
+
 	if (test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state)) {
 		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-		qlcnic_fw_cmd_destroy_tx_ctx(adapter);
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++)
+			qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+						     &adapter->tx_ring[ring]);
 
 		/* Allow dma queues to drain after context reset */
 		msleep(20);
@@ -571,38 +624,41 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
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
@@ -614,27 +670,28 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
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
+			      struct qlcnic_info *nic)
 {
 	int err = -EIO;
 	dma_addr_t nic_dma_t;
@@ -665,13 +722,11 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
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
@@ -681,12 +736,14 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 
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
+			      struct qlcnic_pci_info *pci_info)
 {
 	int err = 0, i;
 	struct qlcnic_cmd_args cmd;
@@ -703,13 +760,11 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
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
@@ -732,6 +787,8 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 
 	dma_free_coherent(&adapter->pdev->dev, pci_size, pci_info_addr,
 		pci_info_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -750,21 +807,19 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
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
@@ -784,7 +839,7 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 		return -ENOMEM;
 
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC &&
-	    func != adapter->ahw->pci_func) {
+		func != adapter->ahw->pci_func) {
 		dev_err(&adapter->pdev->dev,
 			"Not privilege to query stats for func=%d", func);
 		return -EIO;
@@ -801,13 +856,11 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
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
@@ -827,6 +880,8 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 
 	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
 		stats_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -841,6 +896,9 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 	void *stats_addr;
 	int err;
 
+	if (mac_stats == NULL)
+		return -ENOMEM;
+
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
 			&stats_dma_t, GFP_KERNEL);
 	if (!stats_addr) {
@@ -849,15 +907,11 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
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
@@ -879,10 +933,16 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
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
 
@@ -942,7 +1002,7 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 		const u8 port, const u8 rx_tx)
 {
-
+	int err;
 	u32 arg1;
 	struct qlcnic_cmd_args cmd;
 
@@ -965,15 +1025,16 @@ int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
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
 
@@ -986,22 +1047,21 @@ __qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
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
@@ -1063,20 +1123,18 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
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
index 19ea2fc..3c10c97 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -23,6 +23,9 @@ struct qlcnic_stats {
 #define QLC_SIZEOF(m) FIELD_SIZEOF(struct qlcnic_adapter, m)
 #define QLC_OFF(m) offsetof(struct qlcnic_adapter, m)
 
+#define QLCNIC_READ_LINK_SPEED(adapter, pcifn, err)\
+	QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn), err)
+
 static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 	{"xmit_called",
 		QLC_SIZEOF(stats.xmitcalled), QLC_OFF(stats.xmitcalled)},
@@ -172,12 +175,13 @@ static int qlcnic_get_eeprom_len(struct net_device *dev)
 static void
 qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 fw_major, fw_minor, fw_build;
 
-	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
-	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
-	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
+	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR, &err);
+	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR, &err);
+	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB, &err);
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
 		"%d.%d.%d", fw_major, fw_minor, fw_build);
 
@@ -191,6 +195,7 @@ qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 static int
 qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int check_sfp_module = 0;
 
@@ -215,7 +220,7 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		u32 val;
 
-		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
+		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
 		if (val == QLCNIC_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
 			ecmd->advertising = ADVERTISED_1000baseT_Full;
@@ -373,6 +378,7 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 static void
 qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -387,7 +393,7 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
 
 	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[j] != -1; j++, i++)
-		regs_buff[i] = QLCRD32(adapter, diag_registers[j]);
+		regs_buff[i] = QLCRD32(adapter, diag_registers[j], &err);
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return;
@@ -412,10 +418,11 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 
 static u32 qlcnic_test_link(struct net_device *dev)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 val;
 
-	val = QLCRD32(adapter, CRB_XG_STATE_P3P);
+	val = QLCRD32(adapter, CRB_XG_STATE_P3P, &err);
 	val = XG_LINK_STATE_P3P(adapter->ahw->pci_func, val);
 	return (val == XG_LINK_UP_P3P) ? 0 : 1;
 }
@@ -542,6 +549,7 @@ static void
 qlcnic_get_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int port = adapter->ahw->physical_port;
 	__u32 val;
@@ -550,9 +558,9 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port));
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), &err);
 		pause->rx_pause = qlcnic_gb_get_rx_flowctl(val);
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, &err);
 		switch (port) {
 		case 0:
 			pause->tx_pause = !(qlcnic_gb_get_gb0_mask(val));
@@ -572,7 +580,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
-		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, &err);
 		if (port == 0)
 			pause->tx_pause = !(qlcnic_xg_get_xg0_mask(val));
 		else
@@ -587,6 +595,7 @@ static int
 qlcnic_set_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int port = adapter->ahw->physical_port;
 	__u32 val;
@@ -596,7 +605,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port));
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), &err);
 
 		if (pause->rx_pause)
 			qlcnic_gb_rx_flowctl(val);
@@ -606,7 +615,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		QLCWR32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port),
 				val);
 		/* set autoneg */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, &err);
 		switch (port) {
 		case 0:
 			if (pause->tx_pause)
@@ -642,7 +651,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return -EIO;
 
-		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, &err);
 		if (port == 0) {
 			if (pause->tx_pause)
 				qlcnic_xg_unset_xg0_mask(val);
@@ -664,10 +673,11 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 
 static int qlcnic_reg_test(struct net_device *dev)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 data_read;
 
-	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0));
+	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0), &err);
 	if ((data_read & 0xffff) != adapter->pdev->vendor)
 		return 1;
 
@@ -704,20 +714,19 @@ static int qlcnic_irq_test(struct net_device *netdev)
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
@@ -796,12 +805,12 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int max_sds_rings = adapter->max_sds_rings;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_host_sds_ring *sds_ring;
 	int loop = 0;
 	int ret;
 
-	if (!(adapter->ahw->capabilities &
-		QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK)) {
+	if (!(ahw->capabilities & QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK)) {
 		netdev_info(netdev, "Firmware is not loopback test capable\n");
 		return -EOPNOTSUPP;
 	}
@@ -844,7 +853,7 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 
 	ret = qlcnic_do_lb_test(adapter, mode);
 
-	qlcnic_clear_lb_mode(adapter);
+	qlcnic_clear_lb_mode(adapter, mode);
 
  free_res:
 	qlcnic_diag_free_res(netdev, max_sds_rings);
@@ -1092,17 +1101,18 @@ static int qlcnic_set_led(struct net_device *dev,
 static void
 qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 wol_cfg;
 
 	wol->supported = 0;
 	wol->wolopts = 0;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
 	if (wol_cfg & (1UL << adapter->portnum))
 		wol->supported |= WAKE_MAGIC;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
 	if (wol_cfg & (1UL << adapter->portnum))
 		wol->wolopts |= WAKE_MAGIC;
 }
@@ -1110,17 +1120,18 @@ qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 static int
 qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 wol_cfg;
 
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EOPNOTSUPP;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
 	if (!(wol_cfg & (1 << adapter->portnum)))
 		return -EOPNOTSUPP;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
 	if (wol->wolopts & WAKE_MAGIC)
 		wol_cfg |= 1UL << adapter->portnum;
 	else
@@ -1284,7 +1295,7 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 static int
 qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 {
-	int i;
+	int i, err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
 	u32 state;
@@ -1305,7 +1316,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 			return 0;
 		}
 		netdev_info(netdev, "Forcing a FW dump\n");
-		qlcnic_dev_request_reset(adapter);
+		qlcnic_dev_request_reset(adapter, 0);
 		break;
 	case QLCNIC_DISABLE_FW_DUMP:
 		if (fw_dump->enable && fw_dump->tmpl_hdr) {
@@ -1325,12 +1336,12 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 		return 0;
 	case QLCNIC_FORCE_FW_RESET:
 		netdev_info(netdev, "Forcing a FW reset\n");
-		qlcnic_dev_request_reset(adapter);
+		qlcnic_dev_request_reset(adapter, 0);
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		return 0;
 	case QLCNIC_SET_QUIESCENT:
 	case QLCNIC_RESET_QUIESCENT:
-		state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE, &err);
 		if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
 			netdev_info(netdev, "Device in FAILED state\n");
 		return 0;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 4afc1e7..85c9ce0 100644
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
@@ -567,6 +569,9 @@ enum {
 #define QLCNIC_REG(X)		(NIC_CRB_BASE+(X))
 #define QLCNIC_REG_2(X) 	(NIC_CRB_BASE_2+(X))
 
+#define QLCNIC_CDRP_MAX_ARGS	4
+#define QLCNIC_CDRP_ARG(i)	(QLCNIC_REG(0x18 + ((i) * 4)))
+
 #define QLCNIC_CDRP_CRB_OFFSET		(QLCNIC_REG(0x18))
 #define QLCNIC_ARG1_CRB_OFFSET		(QLCNIC_REG(0x1c))
 #define QLCNIC_ARG2_CRB_OFFSET		(QLCNIC_REG(0x20))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index d2c57fc..959eb82 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -311,16 +311,18 @@ qlcnic_write_dump_reg(u32 addr, void __iomem *bar0, u32 data)
 int
 qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 {
-	int done = 0, timeout = 0;
+	int err, done = 0, timeout = 0;
 
 	while (!done) {
-		done = QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)));
+		done = QLCRD32(adapter,
+			       QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)), &err);
 		if (done == 1)
 			break;
 		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT) {
 			dev_err(&adapter->pdev->dev,
-				"Failed to acquire sem=%d lock; holdby=%d\n",
-				sem, id_reg ? QLCRD32(adapter, id_reg) : -1);
+				"Failed to acquire sem=%d lock; held by=%d\n",
+				sem,
+				id_reg ? QLCRD32(adapter, id_reg, &err) : -1);
 			return -EIO;
 		}
 		msleep(1);
@@ -332,12 +334,6 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 	return 0;
 }
 
-void
-qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
-{
-	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
-}
-
 u32 qlcnic_ind_rd(struct qlcnic_adapter *adapter, u32 addr)
 {
 	u32 data;
@@ -355,6 +351,13 @@ void qlcnic_ind_wr(struct qlcnic_adapter *adapter, u32 addr, u32 data)
 		qlcnic_write_dump_reg(addr, adapter->ahw->pci_base0, data);
 }
 
+void
+qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
+{
+	int err;
+	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)), &err);
+}
+
 static int
 qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 		struct cmd_desc_type0 *cmd_desc_arr, int nr_desc)
@@ -412,9 +415,9 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int
-qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
-				__le16 vlan_id, unsigned op)
+int
+qlcnic_82xx_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
+				__le16 vlan_id, u8 op)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_mac_req *mac_req;
@@ -511,7 +514,7 @@ send_fw_cmd:
 	qlcnic_nic_set_promisc(adapter, mode);
 }
 
-int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
+int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -615,12 +618,13 @@ int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
 	return rv;
 }
 
-int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+int qlcnic_82xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
 	if (qlcnic_set_fw_loopback(adapter, mode))
 		return -EIO;
 
-	if (qlcnic_nic_set_promisc(adapter, VPORT_MISS_MODE_ACCEPT_ALL)) {
+	if (qlcnic_nic_set_promisc(adapter,
+		VPORT_MISS_MODE_ACCEPT_ALL)) {
 		qlcnic_set_fw_loopback(adapter, 0);
 		return -EIO;
 	}
@@ -629,11 +633,11 @@ int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
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
@@ -643,12 +647,13 @@ void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter)
 
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
@@ -670,10 +675,9 @@ int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
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
@@ -731,7 +735,7 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 
 #define RSS_HASHTYPE_IP_TCP	0x3
 
-int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
+int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -774,7 +778,8 @@ int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
 	return rv;
 }
 
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
+void qlcnic_82xx_config_ipaddr(struct qlcnic_adapter *adapter,
+				__be32 ip, int cmd)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_ipaddr *ipa;
@@ -796,23 +801,19 @@ int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
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
@@ -978,7 +979,7 @@ qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 }
 
 int
-qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
+qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 {
 	unsigned long flags;
 	int rv;
@@ -1010,7 +1011,7 @@ qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 }
 
 u32
-qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
+qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *err)
 {
 	unsigned long flags;
 	int rv;
@@ -1036,10 +1037,12 @@ qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 	dev_err(&adapter->pdev->dev,
 			"%s: invalid offset: 0x%016lx\n", __func__, off);
 	dump_stack();
+	if (err)
+		*err = -1;
+
 	return -1;
 }
 
-
 void __iomem *
 qlcnic_get_ioaddr(struct qlcnic_hardware_context *ahw, u32 offset)
 {
@@ -1270,9 +1273,9 @@ qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
 	return ret;
 }
 
-int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
+int qlcnic_82xx_get_board_info(struct qlcnic_adapter *adapter)
 {
-	int offset, board_type, magic;
+	int offset, board_type, magic, err;
 	struct pci_dev *pdev = adapter->pdev;
 
 	offset = QLCNIC_FW_MAGIC_OFFSET;
@@ -1292,7 +1295,7 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 	adapter->ahw->board_type = board_type;
 
 	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
-		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I);
+		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I, &err);
 		if ((gpio & 0x8000) == 0)
 			board_type = QLCNIC_BRDTYPE_P3P_10G_TP;
 	}
@@ -1331,11 +1334,12 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 int
 qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 wol_cfg;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
 	if (wol_cfg & (1UL << adapter->portnum)) {
-		wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
+		wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
 		if (wol_cfg & (1 << adapter->portnum))
 			return 1;
 	}
@@ -1343,7 +1347,7 @@ qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
-int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 {
 	struct qlcnic_nic_req   req;
 	int rv;
@@ -1364,3 +1368,57 @@ int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 
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
+	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
+	adapter->ahw->pci_func = func;
+}
+
+void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
+			  loff_t offset, size_t size)
+{
+	int err;
+	u32 data;
+	u64 qmdata;
+
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
+		memcpy(buf, &qmdata, size);
+	} else {
+		data = QLCRD32(adapter, offset, &err);
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
index 8bc481b..0720d00 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -1,6 +1,56 @@
 #ifndef __QLCNIC_HW_H
 #define __QLCNIC_HW_H
 
+#define MASK(n) ((1ULL<<(n))-1)
+#define OCM_WIN_P3P(addr) (addr & 0xffc0000)
+
+#define GET_MEM_OFFS_2M(addr) (addr & MASK(18))
+
+#define CRB_BLK(off)	((off >> 20) & 0x3f)
+#define CRB_SUBBLK(off)	((off >> 16) & 0xf)
+#define CRB_WINDOW_2M	(0x130060)
+#define CRB_HI(off)	((crb_hub_agt[CRB_BLK(off)] << 20) | ((off) & 0xf0000))
+#define CRB_INDIRECT_2M	(0x1e0000UL)
+
+/* List of PCI device IDs */
+#define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
+#define PCI_DEVICE_ID_QLOGIC_QLE834X	0x8030
+#define QLCNIC_82XX_BAR0_LENGTH	0x00200000UL
+#define QLCNIC_83XX_BAR0_LENGTH	0x4000
+
+#define QLCNIC_IS_83XX(adapter)	\
+	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ? 1 : 0)
+
+#define QLCNIC_IS_82XX(adapter)	\
+	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? 1 : 0)
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
 struct qlcnic_ms_reg_ctrl {
 	u32 ocm_window;
 	u32 control;
@@ -11,4 +61,174 @@ struct qlcnic_ms_reg_ctrl {
 	u64 off;
 };
 
+/* Read from an address offset from BAR0, existing registers */
+#define QLCRD(a, addr)			\
+	readl(((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
+/* Write to an address offset from BAR0, existing registers */
+#define QLCWR(a, addr, value)		\
+	writel(value, ((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
+
+/* Read from a direct address offset from BAR0, additional registers */
+#define QLCRDX(ahw, addr)			\
+	readl(((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr]))
+/* Write to a direct address offset from BAR0, additional registers */
+#define QLCWRX(ahw, addr, value)		\
+	writel(value, (((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr])))
+
+#define QLCNIC_SET_OWNER	1
+#define QLCNIC_CLR_OWNER	0
+#define QLCNIC_MBX_TIMEOUT	10000
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
+#define QLC_TCP_HDR_SIZE            20
+#define QLC_TCP_TS_OPTION_SIZE      12
+#define QLC_TCP_TS_HDR_SIZE         (QLC_TCP_HDR_SIZE + QLC_TCP_TS_OPTION_SIZE)
+
+#define QLCNIC_INTRPT_INTX	1
+#define QLCNIC_INTRPT_MSIX	3
+#define QLCNIC_INTRPT_ADD	1
+#define QLCNIC_INTRPT_DEL	2
+
+#define QLCNIC_GET_CURRENT_MAC	1
+#define QLCNIC_SET_STATION_MAC	2
+#define QLCNIC_GET_DEFAULT_MAC	3
+#define QLCNIC_GET_FAC_DEF_MAC	4
+#define QLCNIC_SET_FAC_DEF_MAC	5
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
+#define QLCNIC_ENABLE_INTR(adapter, crb) {		\
+	writel(1, crb);					\
+	if (!QLCNIC_IS_MSI_FAMILY(adapter))		\
+		writel(0xfbff, adapter->tgt_mask_reg);	\
+}
+
+#define QLCNIC_DISABLE_INTR(crb) {			\
+	writel(0, crb);					\
+}
+
+#define QLCNIC_MBX_RSP_OK	1
+#define QLCNIC_MBX_PORT_RSP_OK	0x1a
+
+#define QLCNIC_MBX_RSP(reg)		LSW(reg)
+#define QLCNIC_MBX_NUM_REGS(reg)	(MSW(reg) & 0x1FF)
+#define QLCNIC_MBX_STATUS(reg)		(((reg) >> 25) & 0x7F)
+
+/* Mailbox registers*/
+#define QLCNIC_MBX_HOST(ahw, i)		((ahw)->pci_base0 + ((i) * 4))
+#define QLCNIC_MBX_FW(ahw, i)		((ahw)->pci_base0 + 0x800 + ((i) * 4))
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
+u32 qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *);
+int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
+int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
+int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
+int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
+			 struct net_device *netdev);
+void qlcnic_82xx_change_filter(struct qlcnic_adapter *, u64 *, __le16);
+void qlcnic_82xx_config_intr_coalesce(struct qlcnic_adapter *adapter);
+int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable);
+void qlcnic_82xx_config_ipaddr(struct qlcnic_adapter *adapter,
+				__be32 ip, int cmd);
+int qlcnic_82xx_linkevent_request(struct qlcnic_adapter *adapter, int enable);
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
+int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
+int qlcnic_82xx_get_board_info(struct qlcnic_adapter *adapter);
+int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
+void qlcnic_82xx_get_func_no(struct qlcnic_adapter *);
+int qlcnic_82xx_api_lock(struct qlcnic_adapter *);
+void qlcnic_82xx_api_unlock(struct qlcnic_adapter *);
+void qlcnic_82xx_napi_enable(struct qlcnic_adapter *);
+void qlcnic_82xx_napi_disable(struct qlcnic_adapter *);
+
 #endif				/* __QLCNIC_HW_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index c023587..39fa32d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -5,11 +5,8 @@
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
-#include <linux/netdevice.h>
-#include <linux/delay.h>
-#include <linux/slab.h>
-#include <linux/if_vlan.h>
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 struct crb_addr_pair {
 	u32 addr;
@@ -323,13 +320,13 @@ static u32 qlcnic_decode_crb_addr(u32 addr)
 
 static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 {
+	int err;
 	long timeout = 0;
 	long done = 0;
 
 	cond_resched();
-
 	while (done == 0) {
-		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS);
+		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS, &err);
 		done &= 2;
 		if (++timeout >= QLCNIC_MAX_ROM_WAIT_USEC) {
 			dev_err(&adapter->pdev->dev,
@@ -344,6 +341,8 @@ static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 static int do_rom_fast_read(struct qlcnic_adapter *adapter,
 			    u32 addr, u32 *valp)
 {
+	int err;
+
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ADDRESS, addr);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ABYTE_CNT, 3);
@@ -357,7 +356,7 @@ static int do_rom_fast_read(struct qlcnic_adapter *adapter,
 	udelay(10);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
-	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA);
+	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA, &err);
 	return 0;
 }
 
@@ -409,15 +408,15 @@ int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp)
 
 int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 {
-	int addr, val;
+	int addr, val, err;
 	int i, n, init_delay;
 	struct crb_addr_pair *buf;
 	unsigned offset;
 	u32 off;
 	struct pci_dev *pdev = adapter->pdev;
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, 0);
-	QLCWR32(adapter, CRB_RCVPEG_STATE, 0);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, 0);
+	QLCWR(adapter, QLCNIC_RCVPEG_STATE, 0);
 
 	/* Halt all the indiviual PEGs and other blocks */
 	/* disable all I2Q */
@@ -442,7 +441,7 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xb0000, 0x00);
 
 	/* halt sre */
-	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000);
+	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000, &err);
 	QLCWR32(adapter, QLCNIC_CRB_SRE + 0x1000, val & (~(0x1)));
 
 	/* halt epg */
@@ -564,8 +563,8 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
 	msleep(1);
 
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
 
 	return 0;
 }
@@ -576,7 +575,7 @@ static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 	int retries = QLCNIC_CMDPEG_CHECK_RETRY_COUNT;
 
 	do {
-		val = QLCRD32(adapter, CRB_CMDPEG_STATE);
+		val = QLCRD(adapter, QLCNIC_CMDPEG_STATE);
 
 		switch (val) {
 		case PHAN_INITIALIZE_COMPLETE:
@@ -592,7 +591,7 @@ static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 
 	} while (--retries);
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
 
 out_err:
 	dev_err(&adapter->pdev->dev, "Command Peg initialization not "
@@ -607,7 +606,7 @@ qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
 	int retries = QLCNIC_RCVPEG_CHECK_RETRY_COUNT;
 
 	do {
-		val = QLCRD32(adapter, CRB_RCVPEG_STATE);
+		val = QLCRD(adapter, QLCNIC_RCVPEG_STATE);
 
 		if (val == PHAN_PEG_RCV_INITIALIZED)
 			return 0;
@@ -638,7 +637,7 @@ qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
 	return err;
 }
@@ -649,7 +648,7 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 	int timeo;
 	u32 val;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
+	val = QLCRD(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
 	val = QLC_DEV_GET_DRV(val, adapter->portnum);
 	if ((val & 0x3) != QLCNIC_TYPE_NIC) {
 		dev_err(&adapter->pdev->dev,
@@ -689,11 +688,12 @@ static int qlcnic_get_flt_entry(struct qlcnic_adapter *adapter, u8 region,
 	}
 
 	entry_size = flt_hdr.len - sizeof(struct qlcnic_flt_header);
-	flt_entry = (struct qlcnic_flt_entry *)vzalloc(entry_size);
+	flt_entry = vmalloc(entry_size);
 	if (flt_entry == NULL) {
 		dev_warn(&adapter->pdev->dev, "error allocating memory\n");
 		return -EIO;
 	}
+	memset(flt_entry, 0, entry_size);
 
 	ret = qlcnic_rom_fast_read_words(adapter, QLCNIC_FLT_LOCATION +
 					 sizeof(struct qlcnic_flt_header),
@@ -762,10 +762,11 @@ qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
 static int
 qlcnic_has_mn(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 capability;
 	capability = 0;
 
-	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY);
+	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY, &err);
 	if (capability & QLCNIC_PEG_TUNE_MN_PRESENT)
 		return 1;
 
@@ -1088,11 +1089,11 @@ qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
 	u32 heartbeat, ret = -EIO;
 	int retries = QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT;
 
-	adapter->heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+	adapter->heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 
 	do {
 		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
-		heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+		heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 		if (heartbeat != adapter->heartbeat) {
 			ret = QLCNIC_RCODE_SUCCESS;
 			break;
@@ -1262,7 +1263,7 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 		return -EINVAL;
 	}
 
-	QLCWR32(adapter, QLCNIC_CAM_RAM(0x1fc), QLCNIC_BDINFO_MAGIC);
+	QLCWR(adapter, QLCNIC_FW_IMG_VALID, QLCNIC_BDINFO_MAGIC);
 	return 0;
 }
 
@@ -1314,6 +1315,7 @@ next:
 	}
 }
 
+
 void
 qlcnic_release_firmware(struct qlcnic_adapter *adapter)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 4152cf1..0d92dc1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -4,10 +4,20 @@
 #include <linux/ipv6.h>
 
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
+/* Make a handle with reference handle (0:14) and RDS ring
+ * number (15).
+ */
+#define QLCNIC_MAKE_REF_HANDLE(adapter, handle, ring_id)		\
+	((adapter->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ?	\
+	((handle) | ((ring_id) << 15)) : handle)
 
-void qlcnic_change_filter(struct qlcnic_adapter *adapter, u64 *uaddr,
-			  __le16 vlan_id)
+#define QLCNIC_FETCH_RING_ID(handle)			\
+	((handle) >> 63)
+
+void qlcnic_82xx_change_filter(struct qlcnic_adapter *adapter, u64 *uaddr,
+			       __le16 vlan_id)
 {
 	struct cmd_desc_type0 *hwdesc;
 	struct qlcnic_nic_req *req;
@@ -1125,7 +1135,7 @@ static void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 	return;
 }
 
-void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
+void qlcnic_82xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 {
 	struct qlcnic_adapter *adapter = sds_ring->adapter;
 	struct status_desc *desc;
@@ -1182,7 +1192,8 @@ void qlcnic_fetch_mac(struct qlcnic_adapter *adapter, u32 off1, u32 off2,
 		mac[i] = (u8)(mac_low >> ((5 - i) * 8));
 }
 
-int qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
+int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
+			 struct net_device *netdev)
 {
 	int ring;
 	int max_sds_rings;
@@ -1238,7 +1249,7 @@ void qlcnic_napi_del(struct qlcnic_adapter *adapter)
 	qlcnic_free_tx_rings(adapter);
 }
 
-void qlcnic_napi_enable(struct qlcnic_adapter *adapter)
+void qlcnic_82xx_napi_enable(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -1254,7 +1265,7 @@ void qlcnic_napi_enable(struct qlcnic_adapter *adapter)
 	}
 }
 
-void qlcnic_napi_disable(struct qlcnic_adapter *adapter)
+void qlcnic_82xx_napi_disable(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b49e134..ba09627 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -10,6 +10,7 @@
 #include <linux/interrupt.h>
 
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
@@ -74,6 +75,8 @@ static void qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
+static void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter);
+static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter);
 
 static void qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding);
 static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8);
@@ -112,6 +115,13 @@ static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 
 MODULE_DEVICE_TABLE(pci, qlcnic_pci_tbl);
 
+#define QLCNIC_IS_TSO_CAPABLE(adapter)\
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+
+#define QLCNIC_IS_VLAN_TX_CAPABLE(adapter) \
+	((QLCNIC_IS_82XX(adapter)) ?\
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX) :\
+	1)
 
 inline void
 qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
@@ -127,6 +137,32 @@ static const u32 msi_tgt_status[8] = {
 	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
 };
 
+static const u32 qlcnic_reg_tbl[] = {
+	0x1B20A8, /* PEG_HALT_STAT1 */
+	0x1B20AC, /* PEG_HALT_STAT2 */
+	0x1B20B0, /* FW_HEARTBEAT */
+	0x1B2100, /* LOCK ID */
+	0x1B2128, /* FW_CAPABILITIES */
+	0x1B2138, /* drv active */
+	0x1B2140, /* dev state */
+	0x1B2144, /* drv state */
+	0x1B2148, /* drv scratch */
+	0x1B214C, /* dev partition info */
+	0x1B2174, /* drv idc ver */
+	0x1B2150, /* fw version major */
+	0x1B2154, /* fw version minor */
+	0x1B2158, /* fw version sub */
+	0x1B019C, /* npar state */
+	0x1B21FC, /* FW_IMG_VALID */
+	0x1B2250, /* CMD_PEG_STATE */
+	0x1B233C, /* RCV_PEG_STATE */
+	0x1B23B4, /* ASIC TEMP */
+	0x1B216C, /* FW api */
+	0x1B2170, /* drv op mode */
+	0x13C010, /* flash lock */
+	0x13C014, /* flash unlock */
+};
+
 static const
 struct qlcnic_legacy_intr_set legacy_intr[] = QLCNIC_LEGACY_INTR_CONFIG;
 
@@ -208,11 +244,6 @@ qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	return 0;
 }
 
-static void qlcnic_clear_stats(struct qlcnic_adapter *adapter)
-{
-	memset(&adapter->stats, 0, sizeof(adapter->stats));
-}
-
 static void qlcnic_set_msix_bit(struct pci_dev *pdev, int enable)
 {
 	u32 control;
@@ -287,6 +318,15 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
+static void
+qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
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
@@ -311,15 +351,54 @@ static const struct net_device_ops qlcnic_netdev_failed_ops = {
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
 };
 
-static struct qlcnic_nic_template qlcnic_vf_ops = {
-	.config_bridged_mode = qlcnicvf_config_bridged_mode,
-	.config_led = qlcnicvf_config_led,
-	.start_firmware = qlcnicvf_start_firmware
+struct qlcnic_nic_template qlcnic_vf_ops = {
+	.config_bridged_mode	= qlcnicvf_config_bridged_mode,
+	.config_led		= qlcnicvf_config_led,
+	.start_firmware		= qlcnicvf_start_firmware
+};
+
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
@@ -384,23 +463,27 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 	adapter->msix_entries[0].vector = pdev->irq;
 }
 
-static void
-qlcnic_setup_intr(struct qlcnic_adapter *adapter)
+int
+qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
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
-
 static void
 qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 {
@@ -411,10 +494,10 @@ qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 }
 
 static void
-qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
+qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
 {
-	if (adapter->ahw->pci_base0 != NULL)
-		iounmap(adapter->ahw->pci_base0);
+	if (ahw->pci_base0 != NULL)
+		iounmap(ahw->pci_base0);
 }
 
 static int
@@ -482,12 +565,12 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 {
 	u8 id;
 	u32 ref_count;
-	int i, ret = 1;
+	int i, err, ret = 1;
 	u32 data = QLCNIC_MGMT_FUNC;
 	void __iomem *priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
 
 	/* If other drivers are not in use set their privilege level */
-	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE, &err);
 	ret = qlcnic_api_lock(adapter);
 	if (ret)
 		goto err_lock;
@@ -514,28 +597,20 @@ err_lock:
 }
 
 static void
-qlcnic_check_vf(struct qlcnic_adapter *adapter)
+qlcnic_check_vf(struct qlcnic_adapter *adapter, const struct pci_device_id *ent)
 {
-	void __iomem *msix_base_addr;
 	void __iomem *priv_op;
-	u32 func;
-	u32 msix_base;
 	u32 op_mode, priv_level;
 
 	/* Determine FW API version */
-	adapter->ahw->fw_hal_version = readl(adapter->ahw->pci_base0 +
-					QLCNIC_FW_API);
+	adapter->ahw->fw_hal_version = QLCRD(adapter, QLCNIC_FW_API);
 
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
+	op_mode = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
@@ -547,24 +622,40 @@ qlcnic_check_vf(struct qlcnic_adapter *adapter)
 			"HAL Version: %d Non Privileged function\n",
 			adapter->ahw->fw_hal_version);
 		adapter->nic_ops = &qlcnic_vf_ops;
-	} else
+	} else {
 		adapter->nic_ops = &qlcnic_ops;
+	}
+}
+
+static void qlcnic_get_bar_length(u32 dev_id, ulong *bar)
+{
+	switch (dev_id) {
+	case PCI_DEVICE_ID_QLOGIC_QLE824X:
+		*bar = QLCNIC_82XX_BAR0_LENGTH;
+		break;
+	case PCI_DEVICE_ID_QLOGIC_QLE834X:
+		*bar = QLCNIC_83XX_BAR0_LENGTH;
+		break;
+	default:
+		*bar = 0;
+	}
 }
 
 static int
-qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
+qlcnic_setup_pci_map(struct pci_dev *pdev,
+		     struct qlcnic_hardware_context *ahw)
 {
+	u32 offset;
 	void __iomem *mem_ptr0 = NULL;
 	resource_size_t mem_base;
-	unsigned long mem_len, pci_len0 = 0;
-
-	struct pci_dev *pdev = adapter->pdev;
+	unsigned long mem_len, pci_len0 = 0, bar0_len;
 
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
 	mem_len = pci_resource_len(pdev, 0);
 
-	if (mem_len == QLCNIC_PCI_2MB_SIZE) {
+	qlcnic_get_bar_length(pdev->device, &bar0_len);
+	if (mem_len >= bar0_len) {
 
 		mem_ptr0 = pci_ioremap_bar(pdev, 0);
 		if (mem_ptr0 == NULL) {
@@ -575,17 +666,13 @@ qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
 	} else {
 		return -EIO;
 	}
-
 	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
-	adapter->ahw->pci_base0 = mem_ptr0;
-	adapter->ahw->pci_len0 = pci_len0;
-
-	qlcnic_check_vf(adapter);
+	ahw->pci_base0 = mem_ptr0;
+	ahw->pci_len0 = pci_len0;
 
-	adapter->ahw->ocm_win_crb = qlcnic_get_ioaddr(adapter->ahw,
-		QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(
-			adapter->ahw->pci_func)));
+	offset = QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(ahw->pci_func));
+	qlcnic_get_ioaddr(ahw, offset);
 
 	return 0;
 }
@@ -616,19 +703,26 @@ static void get_brd_name(struct qlcnic_adapter *adapter, char *name)
 static void
 qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 fw_major, fw_minor, fw_build, prev_fw_version;
 	struct pci_dev *pdev = adapter->pdev;
-	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlcnic_fw_dump *fw_dump = &ahw->fw_dump;
 
 	prev_fw_version = adapter->fw_version;
 
-	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
-	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
-	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
+	fw_major = QLCRD(adapter, QLCNIC_FW_VERSION_MAJOR);
+	fw_minor = QLCRD(adapter, QLCNIC_FW_VERSION_MINOR);
+	fw_build = QLCRD(adapter, QLCNIC_FW_VERSION_SUB);
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
-	if (adapter->ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
+	err = qlcnic_get_board_info(adapter);
+	if (err) {
+		dev_err(&pdev->dev, "Error getting board config info.\n");
+		return;
+	}
+	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
 		if (fw_dump->tmpl_hdr == NULL ||
 				adapter->fw_version > prev_fw_version) {
 			if (fw_dump->tmpl_hdr)
@@ -690,7 +784,7 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static void
+void
 qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
@@ -742,7 +836,7 @@ qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 	qlcnic_set_netdev_features(adapter, esw_cfg);
 }
 
-static int
+int
 qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_esw_func_cfg esw_cfg;
@@ -941,10 +1035,10 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
 	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 		return 0;
 
-	npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	while (npar_state != QLCNIC_DEV_NPAR_OPER && --npar_opt_timeo) {
 		msleep(1000);
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	}
 	if (!npar_opt_timeo) {
 		dev_err(&adapter->pdev->dev,
@@ -976,8 +1070,8 @@ qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static int
-qlcnic_start_firmware(struct qlcnic_adapter *adapter)
+int
+qlcnic_82xx_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int err;
 
@@ -1017,9 +1111,8 @@ check_fw_status:
 	if (err)
 		goto err_out;
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
+	QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
-
 	err = qlcnic_check_eswitch_mode(adapter);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
@@ -1037,7 +1130,7 @@ check_fw_status:
 	return 0;
 
 err_out:
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+	QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
 	dev_err(&adapter->pdev->dev, "Device state set to failed\n");
 
 	qlcnic_release_firmware(adapter);
@@ -1508,26 +1601,13 @@ static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
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
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
 	struct qlcnic_adapter *adapter = NULL;
+	struct qlcnic_hardware_context *ahw;
 	int err;
-	uint8_t revision_id;
 	uint8_t pci_using_dac;
 	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
@@ -1551,10 +1631,23 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_master(pdev);
 	pci_enable_pcie_error_reporting(pdev);
 
+	ahw = kzalloc(sizeof(struct qlcnic_hardware_context), GFP_KERNEL);
+	if (!ahw)
+		goto err_out_free_res;
+
+	if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE824X) {
+		ahw->hw_ops = &qlcnic_hw_ops;
+		ahw->reg_tbl = (u32 *) qlcnic_reg_tbl;
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
@@ -1567,8 +1660,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_netdev;
 
 	adapter->dev_rst_time = jiffies;
-	revision_id = pdev->revision;
-	adapter->ahw->revision_id = revision_id;
+	adapter->ahw->revision_id = pdev->revision;
 	adapter->mac_learn = qlcnic_mac_learn;
 
 	rwlock_init(&adapter->ahw->crb_lock);
@@ -1577,30 +1669,20 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
 
-	err = qlcnic_setup_pci_map(adapter);
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
+	if (QLCNIC_IS_82XX(adapter)) {
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
@@ -1613,22 +1695,21 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
+	if (QLCNIC_IS_82XX(adapter)) {
+		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
+				     FW_POLL_DELAY);
+	}
 
 	switch (adapter->ahw->port_type) {
 	case QLCNIC_GBE:
@@ -1644,26 +1725,29 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
 
@@ -1671,54 +1755,43 @@ err_out_disable_pdev:
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
 		return;
 
 	netdev = adapter->netdev;
-
-	qlcnic_cancel_fw_work(adapter);
+	ahw = adapter->ahw;
+	qlcnic_cancel_idc_work(adapter);
 
 	unregister_netdev(netdev);
 
-	qlcnic_detach(adapter);
 
+	qlcnic_detach(adapter);
 	if (adapter->npars != NULL)
 		kfree(adapter->npars);
 	if (adapter->eswitch != NULL)
 		kfree(adapter->eswitch);
 
-	qlcnic_clr_all_drv_state(adapter, 0);
+	if (QLCNIC_IS_82XX(adapter))
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
 
@@ -1728,8 +1801,10 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 
 	qlcnic_free_adapter_resources(adapter);
+	kfree(ahw);
 	free_netdev(netdev);
 }
+
 static int __qlcnic_shutdown(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
@@ -1818,9 +1893,9 @@ done:
 
 static int qlcnic_open(struct net_device *netdev)
 {
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 	int err;
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE, &err);
 
 	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD)) {
 		netdev_err(netdev, "Device in FAILED state\n");
@@ -1888,13 +1963,16 @@ static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
 	adapter->fhash.fmax = 0;
 }
 
-static int qlcnic_check_temp(struct qlcnic_adapter *adapter)
+int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	u32 temp, temp_state, temp_val;
 	int rv = 0;
 
-	temp = QLCRD32(adapter, CRB_TEMP_STATE);
+	temp = 0;
+
+	if (QLCNIC_IS_82XX(adapter))
+		temp = QLCRD(adapter, QLCNIC_ASIC_TEMP);
 
 	temp_state = qlcnic_get_temp_state(temp);
 	temp_val = qlcnic_get_temp_val(temp);
@@ -1954,7 +2032,7 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
 	return stats;
 }
 
-static irqreturn_t qlcnic_clear_legacy_intr(struct qlcnic_adapter *adapter)
+irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
 {
 	u32 status;
 
@@ -2056,7 +2134,7 @@ qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding)
 	val |= encoding << 7;
 	val |= (jiffies - adapter->dev_rst_time) << 8;
 
-	QLCWR32(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
 	adapter->dev_rst_time = jiffies;
 }
 
@@ -2071,14 +2149,14 @@ qlcnic_set_drv_state(struct qlcnic_adapter *adapter, u8 state)
 	if (qlcnic_api_lock(adapter))
 		return -EIO;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 
 	if (state == QLCNIC_DEV_NEED_RESET)
 		QLC_DEV_SET_RST_RDY(val, adapter->portnum);
 	else if (state == QLCNIC_DEV_NEED_QUISCENT)
 		QLC_DEV_SET_QSCNT_RDY(val, adapter->portnum);
 
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
 
@@ -2093,9 +2171,9 @@ qlcnic_clr_drv_state(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -EBUSY;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
 
@@ -2110,20 +2188,20 @@ qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8 failed)
 	if (qlcnic_api_lock(adapter))
 		goto err;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	QLC_DEV_CLR_REF_CNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
 
 	if (failed) {
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
 		dev_info(&adapter->pdev->dev,
 				"Device state set to Failed. Please Reboot\n");
 	} else if (!(val & 0x11111111))
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_COLD);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_COLD);
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
 err:
@@ -2138,12 +2216,13 @@ static int
 qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 {
 	int act, state, active_mask;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-	act = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	state = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
+	act = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 
 	if (adapter->flags & QLCNIC_FW_RESET_OWNER) {
-		active_mask = (~(1 << (adapter->ahw->pci_func * 4)));
+		active_mask = (~(1 << (ahw->pci_func * 4)));
 		act = act & active_mask;
 	}
 
@@ -2156,7 +2235,7 @@ qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 
 static int qlcnic_check_idc_ver(struct qlcnic_adapter *adapter)
 {
-	u32 val = QLCRD32(adapter, QLCNIC_CRB_DRV_IDC_VER);
+	u32 val = QLCRD(adapter, QLCNIC_CRB_DRV_IDC_VER);
 
 	if (val != QLCNIC_DRV_IDC_VER) {
 		dev_warn(&adapter->pdev->dev, "IDC Version mismatch, driver's"
@@ -2180,19 +2259,19 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -1;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	if (!(val & (1 << (portnum * 4)))) {
 		QLC_DEV_SET_REF_CNT(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
 	}
 
-	prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	prev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	QLCDB(adapter, HW, "Device state = %u\n", prev_state);
 
 	switch (prev_state) {
 	case QLCNIC_DEV_COLD:
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_IDC_VER, QLCNIC_DRV_IDC_VER);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCWR(adapter, QLCNIC_CRB_DRV_IDC_VER, QLCNIC_DRV_IDC_VER);
 		qlcnic_idc_debug_info(adapter, 0);
 		qlcnic_api_unlock(adapter);
 		return 1;
@@ -2203,15 +2282,15 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 		return ret;
 
 	case QLCNIC_DEV_NEED_RESET:
-		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+		val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 		QLC_DEV_SET_RST_RDY(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		break;
 
 	case QLCNIC_DEV_NEED_QUISCENT:
-		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+		val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 		QLC_DEV_SET_QSCNT_RDY(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		break;
 
 	case QLCNIC_DEV_FAILED:
@@ -2228,7 +2307,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 
 	do {
 		msleep(1000);
-		prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		prev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 		if (prev_state == QLCNIC_DEV_QUISCENT)
 			continue;
@@ -2243,9 +2322,9 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -1;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	ret = qlcnic_check_idc_ver(adapter);
 	qlcnic_api_unlock(adapter);
@@ -2264,7 +2343,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 	if (qlcnic_api_lock(adapter))
 		goto err_ret;
 
-	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	if (dev_state == QLCNIC_DEV_QUISCENT ||
 	    dev_state == QLCNIC_DEV_NEED_QUISCENT) {
 		qlcnic_api_unlock(adapter);
@@ -2293,31 +2372,24 @@ qlcnic_fwinit_work(struct work_struct *work)
 
 	if (!qlcnic_check_drv_state(adapter)) {
 skip_ack_check:
-		dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 		if (dev_state == QLCNIC_DEV_NEED_RESET) {
-			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
+			QLCWR(adapter, QLCNIC_CRB_DEV_STATE,
 						QLCNIC_DEV_INITIALIZING);
 			set_bit(__QLCNIC_START_FW, &adapter->state);
 			QLCDB(adapter, DRV, "Restarting fw\n");
 			qlcnic_idc_debug_info(adapter, 0);
-			val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+			val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 			QLC_DEV_SET_RST_RDY(val, adapter->portnum);
-			QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+			QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		}
 
 		qlcnic_api_unlock(adapter);
 
-		rtnl_lock();
-		if (adapter->ahw->fw_dump.enable &&
-		    (adapter->flags & QLCNIC_FW_RESET_OWNER)) {
-			QLCDB(adapter, DRV, "Take FW dump\n");
-			adapter->flags |= QLCNIC_FW_HANG;
-		}
-		rtnl_unlock();
 
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
-		if (!adapter->nic_ops->start_firmware(adapter)) {
+		if (!qlcnic_start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			adapter->fw_wait_cnt = 0;
 			return;
@@ -2328,12 +2400,12 @@ skip_ack_check:
 	qlcnic_api_unlock(adapter);
 
 wait_npar:
-	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
 
 	switch (dev_state) {
 	case QLCNIC_DEV_READY:
-		if (!adapter->nic_ops->start_firmware(adapter)) {
+		if (!qlcnic_start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			adapter->fw_wait_cnt = 0;
 			return;
@@ -2370,7 +2442,7 @@ qlcnic_detach_work(struct work_struct *work)
 	} else
 		qlcnic_down(adapter, netdev);
 
-	status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
+	status = QLCRD(adapter, QLCNIC_PEG_HALT_STATUS1);
 
 	if (status & QLCNIC_RCODE_FATAL_ERROR) {
 		dev_err(&adapter->pdev->dev,
@@ -2421,19 +2493,19 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
 {
 	u32 state;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	if (state == QLCNIC_DEV_NPAR_NON_OPER)
 		return;
 
 	if (qlcnic_api_lock(adapter))
 		return;
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
 	qlcnic_api_unlock(adapter);
 }
 
 /*Transit to RESET state from READY state only */
 void
-qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
+qlcnic_82xx_dev_request_reset(struct qlcnic_adapter *adapter, u32 key)
 {
 	u32 state, xg_val = 0, gb_val = 0;
 
@@ -2445,28 +2517,24 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 	qlcnic_gb_set_gb2_mask(gb_val);
 	qlcnic_gb_set_gb3_mask(gb_val);
 	QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, gb_val);
-	dev_info(&adapter->pdev->dev, "Pause control frames disabled"
-				" on all ports\n");
+	dev_info(&adapter->pdev->dev,
+		 "Pause control frames disabled on all ports\n");
 	adapter->need_fw_reset = 1;
+
 	if (qlcnic_api_lock(adapter))
 		return;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-	if (state  == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD)) {
-		netdev_err(adapter->netdev,
-				"Device is in FAILED state, Please Reboot\n");
-		qlcnic_api_unlock(adapter);
-		return;
-	}
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 	if (state == QLCNIC_DEV_READY) {
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
 		adapter->flags |= QLCNIC_FW_RESET_OWNER;
 		QLCDB(adapter, DRV, "NEED_RESET state set\n");
 		qlcnic_idc_debug_info(adapter, 0);
 	}
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
+	      QLCNIC_DEV_NPAR_NON_OPER);
 	qlcnic_api_unlock(adapter);
 }
 
@@ -2477,7 +2545,7 @@ qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return;
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
 	QLCDB(adapter, DRV, "NPAR operational state set\n");
 
 	qlcnic_api_unlock(adapter);
@@ -2516,7 +2584,7 @@ qlcnic_attach_work(struct work_struct *work)
 	u32 npar_state;
 
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 		if (adapter->fw_wait_cnt++ > QLCNIC_DEV_NPAR_OPER_TIMEO)
 			qlcnic_clr_all_drv_state(adapter, 0);
 		else if (npar_state != QLCNIC_DEV_NPAR_OPER)
@@ -2549,6 +2617,7 @@ done:
 static int
 qlcnic_check_health(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 state = 0, heartbeat;
 	u32 peg_status;
 
@@ -2556,16 +2625,16 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		goto detach;
 
 	if (adapter->need_fw_reset)
-		qlcnic_dev_request_reset(adapter);
+		qlcnic_dev_request_reset(adapter, 0);
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	if (state == QLCNIC_DEV_NEED_RESET) {
 		qlcnic_set_npar_non_operational(adapter);
 		adapter->need_fw_reset = 1;
 	} else if (state == QLCNIC_DEV_NEED_QUISCENT)
 		goto detach;
 
-	heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+	heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 	if (heartbeat != adapter->heartbeat) {
 		adapter->heartbeat = heartbeat;
 		adapter->fw_fail_cnt = 0;
@@ -2585,25 +2654,25 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 
 	adapter->flags |= QLCNIC_FW_HANG;
 
-	qlcnic_dev_request_reset(adapter);
+	qlcnic_dev_request_reset(adapter, 0);
 
 	if (auto_fw_reset)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
 	dev_err(&adapter->pdev->dev, "firmware hang detected\n");
+	peg_status = QLCRD(adapter, QLCNIC_PEG_HALT_STATUS1);
 	dev_err(&adapter->pdev->dev, "Dumping hw/fw registers\n"
 			"PEG_HALT_STATUS1: 0x%x, PEG_HALT_STATUS2: 0x%x,\n"
 			"PEG_NET_0_PC: 0x%x, PEG_NET_1_PC: 0x%x,\n"
 			"PEG_NET_2_PC: 0x%x, PEG_NET_3_PC: 0x%x,\n"
 			"PEG_NET_4_PC: 0x%x\n",
-			QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1),
-			QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS2),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c));
-	peg_status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
+			peg_status,
+			QLCRD(adapter, QLCNIC_PEG_HALT_STATUS2),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c, &err));
 	if (QLCNIC_FWERROR_CODE(peg_status) == 0x67)
 		dev_err(&adapter->pdev->dev,
 			"Firmware aborted with error code 0x00006700. "
@@ -2668,6 +2737,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	int err, first_func;
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	pdev->error_state = pci_channel_io_normal;
 
@@ -2684,20 +2754,22 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	if (qlcnic_api_lock(adapter))
 		return -EINVAL;
 
-	if (adapter->ahw->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
+	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
 		adapter->need_fw_reset = 1;
 		set_bit(__QLCNIC_START_FW, &adapter->state);
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
 		QLCDB(adapter, DRV, "Restarting fw\n");
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
@@ -2762,7 +2834,7 @@ static void qlcnic_io_resume(struct pci_dev *pdev)
 
 	pci_cleanup_aer_uncorrect_error_status(pdev);
 
-	if (QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) == QLCNIC_DEV_READY &&
+	if (QLCRD(adapter, QLCNIC_CRB_DEV_STATE) == QLCNIC_DEV_READY &&
 	    test_and_clear_bit(__QLCNIC_AER, &adapter->state))
 		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
 						FW_POLL_DELAY);
@@ -3066,7 +3138,7 @@ qlcnic_sysfs_read_crb(struct file *filp, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	u32 data;
 	u64 qmdata;
-	int ret;
+	int err, ret;
 
 	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
@@ -3076,7 +3148,7 @@ qlcnic_sysfs_read_crb(struct file *filp, struct kobject *kobj,
 		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
 		memcpy(buf, &qmdata, size);
 	} else {
-		data = QLCRD32(adapter, offset);
+		data = QLCRD32(adapter, offset, &err);
 		memcpy(buf, &data, size);
 	}
 	return size;
@@ -3722,8 +3794,9 @@ qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
 static void
 qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 {
+	int err;
 	struct device *dev = &adapter->pdev->dev;
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE, &err);
 
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
 		dev_info(dev, "failed to create port stats sysfs entry");
@@ -3762,8 +3835,9 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 static void
 qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 {
+	int err;
 	struct device *dev = &adapter->pdev->dev;
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE, &err);
 
 	device_remove_bin_file(dev, &bin_attr_port_stats);
 
@@ -3786,6 +3860,18 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	device_remove_bin_file(dev, &bin_attr_esw_stats);
 }
 
+static void
+qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_create_diag_entries(adapter);
+}
+
+static void
+qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_remove_diag_entries(adapter);
+}
+
 #ifdef CONFIG_INET
 
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
-- 
1.7.1
