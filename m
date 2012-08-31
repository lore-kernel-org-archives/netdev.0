From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 05/12] qlcnic: change driver firmware interface mechanism
Date: Fri, 31 Aug 2012 02:28:54 -0400
Message-ID: <1346394541-3486-6-git-send-email-sony.chacko@qlogic.com>
References: <1346394541-3486-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:60361 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751464Ab2HaGp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 02:45:56 -0400
In-Reply-To: <1346394541-3486-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Modify 82xx driver to support new adapter - Qlogic 83XX CNA
Change 82xx specific firmware interface and create mailbox based interface
Modify firmware commands to use new mailbox interface

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  345 +++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |  552 +++++++------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   77 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   85 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  120 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   79 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   86 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   61 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  889 ++++++++++----------
 9 files changed, 1277 insertions(+), 1017 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 056a8ee..f5bdcaa 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -89,6 +89,8 @@
 #define QLCNIC_CT_DEFAULT_RX_BUF_LEN	2048
 #define QLCNIC_LRO_BUFFER_EXTRA		2048
 
+#define RSS_HASHTYPE_IP_TCP     0x3
+
 /* Opcodes to be used with the commands */
 #define TX_ETHER_PKT	0x01
 #define TX_TCP_PKT	0x02
@@ -266,6 +268,8 @@ struct status_desc {
 	__le64 status_desc_data[2];
 } __attribute__ ((aligned(16)));
 
+#define QLCNIC_DEV_INFO_SIZE    1
+
 /* UNIFIED ROMIMAGE */
 #define QLCNIC_UNI_FW_MIN_SIZE		0xc8000
 #define QLCNIC_UNI_DIR_SECT_PRODUCT_TBL	0x0
@@ -468,6 +472,8 @@ struct qlcnic_hardware_context {
 	u8 mc_enabled;
 	u8 max_mc_count;
 	u8 diag_test;
+	u8 num_msix;
+	u8 nic_mode;
 	char diag_cnt;
 
 	u16 port_type;
@@ -484,14 +490,20 @@ struct qlcnic_hardware_context {
 	u16 max_rx_ques;
 	u16 max_mtu;
 	u16 msg_enable;
+	u16 act_pci_func;
 
 	u32 capabilities;
 	u32 temp;
 	u32 int_vec_bit;
 	u32 fw_hal_version;
+	u32 port_config;
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
+	struct qlcnic_intrpt_config *intr_tbl;
+	u32 *reg_tbl;
+	u32 *ext_reg_tbl;
+	spinlock_t mbx_lock;
 };
 
 struct qlcnic_adapter_stats {
@@ -550,12 +562,17 @@ struct qlcnic_host_sds_ring {
 } ____cacheline_internodealigned_in_smp;
 
 struct qlcnic_host_tx_ring {
+	int irq;
+	void __iomem *crb_intr_mask;
+	char name[IFNAMSIZ+4];
 	u16 ctx_id;
 	u32 producer;
 	u32 sw_consumer;
 	u32 num_desc;
 	void __iomem *crb_cmd_producer;
 	struct cmd_desc_type0 *desc_head;
+	struct qlcnic_adapter *adapter;
+	struct napi_struct napi;
 	struct qlcnic_cmd_buffer *cmd_buf_arr;
 	__le32 *hw_consumer;
 
@@ -1023,6 +1040,7 @@ struct qlcnic_adapter {
 
 	u8 max_rds_rings;
 	u8 max_sds_rings;
+	u8 rx_csum;
 	u8 portnum;
 
 	u8 fw_wait_cnt;
@@ -1042,10 +1060,12 @@ struct qlcnic_adapter {
 
 	u8 mac_addr[ETH_ALEN];
 
-	u64 dev_rst_time;
 	u8 mac_learn;
 	unsigned long vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	u64 dev_rst_time;
+	u8 flash_mfg_id;
 
+	struct vlan_group *vlgrp;
 	struct qlcnic_npar_info *npars;
 	struct qlcnic_eswitch *eswitch;
 	struct qlcnic_nic_template *nic_ops;
@@ -1100,7 +1120,8 @@ struct qlcnic_pci_info {
 	__le16	reserved1[2];
 
 	u8	mac[ETH_ALEN];
-	u8	reserved2[106];
+	__le16  func_count;
+	u8      reserved2[104];
 } __packed;
 
 struct qlcnic_npar_info {
@@ -1117,6 +1138,7 @@ struct qlcnic_npar_info {
 	u8	mac_anti_spoof;
 	u8	promisc_mode;
 	u8	offload_flags;
+	u8      pci_func;
 };
 
 struct qlcnic_eswitch {
@@ -1209,7 +1231,7 @@ do {	\
 			(VAL1) += (VAL2); \
 } while (0)
 
-struct qlcnic_mac_statistics{
+struct qlcnic_mac_statistics {
 	__le64	mac_tx_frames;
 	__le64	mac_tx_bytes;
 	__le64	mac_tx_mcast_pkts;
@@ -1245,7 +1267,7 @@ struct qlcnic_mac_statistics{
 	__le64	mac_rx_length_large;
 	__le64	mac_rx_jabber;
 	__le64	mac_rx_dropped;
-	__le64	mac_rx_crc_error;
+	__le64	mac_FCS_error;
 	__le64	mac_align_error;
 } __packed;
 
@@ -1419,10 +1441,8 @@ struct qlcnic_dump_operations {
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
@@ -1432,9 +1452,6 @@ struct qlcnic_cmd_args {
 
 int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter);
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
-
-u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off);
-int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
 void qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *, u64, u64 *);
@@ -1443,8 +1460,8 @@ void qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *, u64, u64);
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) < (high)) && ((addr) >= (low)))
 
-#define QLCRD32(adapter, off) \
-	adapter->ahw->hw_ops->rdreg(adapter, off)
+#define QLCRD32(adapter, off, err) \
+	(adapter->ahw->hw_ops->rdreg)(adapter, off, err)
 #define QLCWR32(adapter, off, val) \
 	adapter->ahw->hw_ops->wrtreg(adapter, off, val)
 
@@ -1459,10 +1476,6 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
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
@@ -1475,15 +1488,15 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 #define __QLCNIC_MAX_LED_RATE	0xf
 #define __QLCNIC_MAX_LED_STATE	0x2
 
-int qlcnic_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 int qlcnic_dump_fw(struct qlcnic_adapter *);
 void qlcnic_get_ocm_win(struct qlcnic_hardware_context *);
-void qlcnic_get_func_no(struct qlcnic_adapter *);
 
 /* Functions from qlcnic_init.c */
+void qlcnic_restore_indev_addr(struct net_device *, unsigned long);
+void qlcnic_schedule_work(struct qlcnic_adapter *, work_func_t, int);
 int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
 int qlcnic_need_fw_reset(struct qlcnic_adapter *adapter);
 void qlcnic_request_firmware(struct qlcnic_adapter *adapter);
@@ -1512,53 +1525,44 @@ void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter);
 
 int qlcnic_check_fw_status(struct qlcnic_adapter *adapter);
 void qlcnic_watchdog_task(struct work_struct *work);
-void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_rds_ring *rds_ring);
+void qlcnic_post_rx_buffers(struct qlcnic_adapter *,
+			struct qlcnic_host_rds_ring *, u8);
 int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max);
 void qlcnic_set_multi(struct net_device *netdev);
 void qlcnic_free_mac_list(struct qlcnic_adapter *adapter);
-int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
-int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter);
-int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable);
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd);
-int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable);
 
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features);
 int qlcnic_set_features(struct net_device *netdev, netdev_features_t features);
-int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
+int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_tx_ring *tx_ring);
-void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
-void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter);
-int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode);
-
+					struct qlcnic_host_tx_ring *tx_ring);
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
+
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 
-int qlcnic_setup_intr(struct qlcnic_adapter *);
 int qlcnic_poll(struct napi_struct *, int);
 int qlcnic_rx_poll(struct napi_struct *, int);
-
-/* Management functions */
-int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
-int qlcnic_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
-int qlcnic_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
-int qlcnic_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
+void qlcnic_set_vlan_config(struct qlcnic_adapter *,
+				struct qlcnic_esw_func_cfg *);
+void qlcnic_set_eswitch_port_features(struct qlcnic_adapter *,
+		struct qlcnic_esw_func_cfg *);
+/* functions in qlcnic_sysfs.c */
+int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
+void qlcnic_create_sysfs_entries(struct qlcnic_adapter *);
+void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *);
 
 /*  eSwitch management functions */
 int qlcnic_config_switch_port(struct qlcnic_adapter *,
@@ -1572,6 +1576,9 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *, const u8, u8,
 					struct __qlcnic_esw_statistics *);
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, u8, u8, u8);
 int qlcnic_get_mac_stats(struct qlcnic_adapter *, struct qlcnic_mac_statistics *);
+int qlcnic_is_valid_nic_func(struct qlcnic_adapter *, u8);
+void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd);
+
 extern int qlcnic_config_tso;
 
 /*
@@ -1603,20 +1610,60 @@ struct qlcnic_nic_template {
 	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
 	int (*config_led) (struct qlcnic_adapter *, u32, u32);
 	int (*start_firmware) (struct qlcnic_adapter *);
+	int (*init_driver) (struct qlcnic_adapter *);
+	void (*request_reset) (struct qlcnic_adapter *, u32);
+	void (*cancel_idc_work) (struct qlcnic_adapter *);
+	int (*napi_add)(struct qlcnic_adapter *, struct net_device *);
+	void (*config_ipaddr)(struct qlcnic_adapter *, __be32, int);
+	irqreturn_t (*clear_legacy_intr)(struct qlcnic_adapter *);
 };
+
 /* function template for hardware ops based on different chip type */
 struct qlcnic_hardware_ops {
 	void (*read_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
 	void (*write_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
-	u32 (*rdreg) (struct qlcnic_adapter *, ulong);
+	u32 (*rdreg) (struct qlcnic_adapter *, ulong, int *);
 	int (*wrtreg) (struct qlcnic_adapter *, ulong, u32);
 	void (*get_ocm_win) (struct qlcnic_hardware_context *);
 	int (*get_mac_address) (struct qlcnic_adapter *, u8 *);
-	int (*setup_intr) (struct qlcnic_adapter *);
-	void (*mbx_cmd) (struct qlcnic_adapter *, struct qlcnic_cmd_args *);
+	int (*setup_intr) (struct qlcnic_adapter *, u8);
+	int (*alloc_mbx_args)(struct qlcnic_cmd_args *,
+				struct qlcnic_adapter *, u32);
+	int (*mbx_cmd) (struct qlcnic_adapter *, struct qlcnic_cmd_args *);
 	void (*get_func_no) (struct qlcnic_adapter *);
+	int (*api_lock) (struct qlcnic_adapter *);
+	void (*api_unlock) (struct qlcnic_adapter *);
+	void (*add_sysfs) (struct qlcnic_adapter *);
+	void (*remove_sysfs) (struct qlcnic_adapter *);
+	void (*process_lb_rcv_ring_diag) (struct qlcnic_host_sds_ring *);
+	int (*create_rx_ctx) (struct qlcnic_adapter *);
+	int (*create_tx_ctx) (struct qlcnic_adapter *,
+		 struct qlcnic_host_tx_ring *, int);
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
 };
 
+extern struct qlcnic_nic_template qlcnic_vf_ops;
+
+static inline int
+qlcnic_start_firmware(struct qlcnic_adapter *adapter)
+{
+	return adapter->nic_ops->start_firmware(adapter);
+}
+
 static inline void
 qlcnic_read_crb(struct qlcnic_adapter *adapter, char *buf,
 						loff_t offset, size_t size)
@@ -1631,24 +1678,220 @@ qlcnic_write_crb(struct qlcnic_adapter *adapter, char *buf,
 	adapter->ahw->hw_ops->write_crb(adapter, buf, offset, size);
 }
 
+static inline u32
+qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *err)
+{
+	return adapter->ahw->hw_ops->rdreg(adapter, off, err);
+}
+
 static inline int
-qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
+qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 {
-	return adapter->nic_ops->config_bridged_mode(adapter, enable);
+	return adapter->ahw->hw_ops->wrtreg(adapter, off, data);
+}
 
+static inline int
+qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
+{
+	return adapter->ahw->hw_ops->get_mac_address(adapter, mac);
 }
 
 static inline int
-qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+qlcnic_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 {
-	return adapter->nic_ops->config_led(adapter, state, rate);
+	return adapter->ahw->hw_ops->setup_intr(adapter, num_intr);
+}
 
+static inline int
+qlcnic_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
+			struct qlcnic_adapter *adapter, u32 type)
+{
+	return adapter->ahw->hw_ops->alloc_mbx_args(mbx, adapter, type);
 }
 
 static inline int
-qlcnic_start_firmware(struct qlcnic_adapter *adapter)
+qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 {
-	return adapter->nic_ops->start_firmware(adapter);
+	return adapter->ahw->hw_ops->mbx_cmd(adapter, cmd);
+}
+
+static inline void
+qlcnic_get_func_no(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->get_func_no(adapter);
+}
+
+static inline int
+qlcnic_api_lock(struct qlcnic_adapter *adapter)
+{
+	return adapter->ahw->hw_ops->api_lock(adapter);
+}
+
+static inline void
+qlcnic_api_unlock(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->api_unlock(adapter);
+}
+
+static inline void
+qlcnic_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->add_sysfs(adapter);
+}
+
+static inline void
+qlcnic_remove_sysfs(struct qlcnic_adapter *adapter)
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
+static inline int
+qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
+{
+	return adapter->ahw->hw_ops->create_rx_ctx(adapter);
+}
+
+static inline int
+qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
+			struct qlcnic_host_tx_ring *tx_ring, int ring)
+{
+	return adapter->ahw->hw_ops->create_tx_ctx(adapter, tx_ring, ring);
+}
+
+static inline int
+qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable)
+{
+	return adapter->ahw->hw_ops->setup_link_event(adapter, enable);
+}
+
+static inline int
+qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
+			struct qlcnic_info *info, u8 id)
+{
+	return adapter->ahw->hw_ops->get_nic_info(adapter, info, id);
+}
+
+static inline int
+qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
+				struct qlcnic_pci_info *info)
+{
+	return adapter->ahw->hw_ops->get_pci_info(adapter, info);
+}
+
+static inline int
+qlcnic_set_nic_info(struct qlcnic_adapter *adapter,
+				struct qlcnic_info *info)
+{
+	return adapter->ahw->hw_ops->set_nic_info(adapter, info);
+}
+
+static inline int
+qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter,
+					u8 *addr, __le16 id, u8 cmd)
+{
+	return adapter->ahw->hw_ops->change_macvlan(adapter, addr, id, cmd);
+}
+
+static inline int
+qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
+{
+	return adapter->nic_ops->napi_add(adapter, netdev);
+}
+
+static inline void
+qlcnic_napi_enable(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->napi_enable(adapter);
+}
+
+static inline void
+qlcnic_napi_disable(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->napi_disable(adapter);
+}
+
+static inline void
+qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->config_intr_coal(adapter);
+}
+
+static inline int
+qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
+{
+	return adapter->ahw->hw_ops->config_rss(adapter, enable);
+}
+
+static inline int
+qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
+{
+	return adapter->ahw->hw_ops->config_hw_lro(adapter, enable);
+}
+
+static inline int
+qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+{
+	return adapter->ahw->hw_ops->config_loopback(adapter, mode);
+}
+
+static inline int
+qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+{
+	return adapter->ahw->hw_ops->config_loopback(adapter, mode);
+}
+
+static inline int
+qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
+{
+	return adapter->ahw->hw_ops->config_promisc_mode(adapter, mode);
+}
+
+static inline void
+qlcnic_change_filter(struct qlcnic_adapter *adapter, u64 *addr, __le16 id)
+{
+	adapter->ahw->hw_ops->change_l2_filter(adapter, addr, id);
+}
+
+static inline int
+qlcnic_get_board_info(struct qlcnic_adapter *adapter)
+{
+	return adapter->ahw->hw_ops->get_board_info(adapter);
+}
+
+static inline void
+qlcnic_dev_request_reset(struct qlcnic_adapter *adapter, u32 key)
+{
+	adapter->nic_ops->request_reset(adapter, key);
+}
+
+static inline void
+qlcnic_cancel_idc_work(struct qlcnic_adapter *adapter)
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
+static inline int
+qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+{
+	return adapter->nic_ops->config_led(adapter, state, rate);
+}
+
+static inline void
+qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
+{
+	adapter->nic_ops->config_ipaddr(adapter, ip, cmd);
 }
 
 #define QLCDB(adapter, lvl, _fmt, _args...) do {	\
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 12c45bf..6fc4451 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -6,13 +6,92 @@
  */
 
 #include "qlcnic.h"
-#include "qlcnic_hw.h"
+
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
+};
+
+/* Allocate mailbox incoming and outgoing registers. It should be used with a
+ * follow up call to qlcnic_free_mbx_args
+ */
+int qlcnic_82xx_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
+		struct qlcnic_adapter *adapter, u32 type)
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
+/* Free up mailbox registers
+ *  */
+void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd)
+{
+	kfree(cmd->req.arg);
+	cmd->req.arg = NULL;
+	kfree(cmd->rsp.arg);
+	cmd->rsp.arg = NULL;
+}
+
 
 static u32
 qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 {
 	u32 rsp;
-	int timeout = 0;
+	int err, timeout = 0;
 
 	do {
 		/* give atleast 1ms for firmware to respond */
@@ -21,15 +100,17 @@ qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 		if (++timeout > QLCNIC_OS_CRB_RETRY_COUNT)
 			return QLCNIC_CDRP_RSP_TIMEOUT;
 
-		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET);
+		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET, &err);
 	} while (!QLCNIC_CDRP_IS_RSP(rsp));
 
 	return rsp;
 }
 
-void
-qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
+int
+qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
+				struct qlcnic_cmd_args *cmd)
 {
+	int i, err;
 	u32 rsp;
 	u32 signature;
 	struct pci_dev *pdev = adapter->pdev;
@@ -39,94 +120,60 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 
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
+				cmd->rsp.arg[0]);
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
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_SET_MTU);
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
@@ -179,9 +226,6 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 						| QLCNIC_CAP0_VALIDOFF);
 	cap |= (QLCNIC_CAP0_JUMBO_CONTIGUOUS | QLCNIC_CAP0_LRO_CONTIGUOUS);
 
-	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
-		cap |= QLCNIC_CAP0_LRO_MSS;
-
 	prq->valid_field_offset = offsetof(struct qlcnic_hostrq_rx_ctx,
 							 msix_handler);
 	prq->txrx_sds_binding = nsds_rings - 1;
@@ -229,20 +273,18 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 	}
 
 	phys_addr = hostrq_phys_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = (u32) (phys_addr >> 32);
-	cmd.req.arg2 = (u32) (phys_addr & 0xffffffff);
-	cmd.req.arg3 = rq_size;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CREATE_RX_CTX;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_CREATE_RX_CTX);
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
@@ -281,24 +324,25 @@ out_free_rq:
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
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_DESTROY_RX_CTX);
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
+	struct qlcnic_host_tx_ring *tx_ring, int ring)
 {
 	struct qlcnic_hostrq_tx_ctx	*prq;
 	struct qlcnic_hostrq_cds_ring	*prq_cds;
@@ -310,7 +354,6 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	int	err;
 	u64	phys_addr;
 	dma_addr_t	rq_phys_addr, rsp_phys_addr;
-	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 
 	/* reset host resources */
 	tx_ring->producer = 0;
@@ -345,9 +388,9 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 	prq->host_int_crb_mode =
 		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
+	prq->msi_index = 0;
 
 	prq->interrupt_ctl = 0;
-	prq->msi_index = 0;
 	prq->cmd_cons_dma_addr = cpu_to_le64(tx_ring->hw_cons_phys_addr);
 
 	prq_cds = &prq->cds_ring;
@@ -356,18 +399,17 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
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
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_CREATE_TX_CTX);
+	cmd.req.arg[1] = MSD(phys_addr);
+	cmd.req.arg[2] = LSD(phys_addr);
+	cmd.req.arg[3] = rq_size;
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
 		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
-
 		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
 	} else {
 		dev_err(&adapter->pdev->dev,
@@ -380,44 +422,44 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 out_free_rq:
 	dma_free_coherent(&adapter->pdev->dev, rq_size, rq_addr, rq_phys_addr);
+	qlcnic_free_mbx_args(&cmd);
 
 	return err;
 }
 
 static void
-qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter)
+qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter,
+	struct qlcnic_host_tx_ring *tx_ring)
 {
 	struct qlcnic_cmd_args cmd;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = adapter->tx_ring->ctx_id;
-	cmd.req.arg2 = QLCNIC_DESTROY_CTX_RESET;
-	cmd.req.arg3 = 0;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_DESTROY_TX_CTX;
-	qlcnic_issue_cmd(adapter, &cmd);
-	if (cmd.rsp.cmd)
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_DESTROY_TX_CTX);
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
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_CONFIG_PORT);
+	cmd.req.arg[1] = config;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
 }
 
 int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 {
 	void *addr;
-	int err;
-	int ring;
+	int err, ring;
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -426,26 +468,28 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 
 	recv_ctx = adapter->recv_ctx;
-	tx_ring = adapter->tx_ring;
-
-	tx_ring->hw_consumer = (__le32 *) dma_alloc_coherent(&pdev->dev,
-		sizeof(u32), &tx_ring->hw_cons_phys_addr, GFP_KERNEL);
-	if (tx_ring->hw_consumer == NULL) {
-		dev_err(&pdev->dev, "failed to allocate tx consumer\n");
-		return -ENOMEM;
-	}
 
-	/* cmd desc ring */
-	addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		tx_ring->hw_consumer = (__le32 *) dma_alloc_coherent(&pdev->dev,
+			sizeof(u32), &tx_ring->hw_cons_phys_addr, GFP_KERNEL);
+		if (tx_ring->hw_consumer == NULL) {
+			dev_err(&pdev->dev, "failed to allocate tx consumer\n");
+			return -ENOMEM;
+		}
+		/* cmd desc ring */
+		addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
 			&tx_ring->phys_addr, GFP_KERNEL);
 
-	if (addr == NULL) {
-		dev_err(&pdev->dev, "failed to allocate tx desc ring\n");
-		err = -ENOMEM;
-		goto err_out_free;
-	}
+		if (addr == NULL) {
+			dev_err(&pdev->dev,
+				 "failed to allocate tx desc ring\n");
+			err = -ENOMEM;
+			goto err_out_free;
+		}
 
-	tx_ring->desc_head = addr;
+		tx_ring->desc_head = addr;
+	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -484,10 +528,9 @@ err_out_free:
 	return err;
 }
 
-
 int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 {
-	int err;
+	int i, err, ring;
 
 	if (adapter->flags & QLCNIC_NEED_FLR) {
 		pci_reset_function(adapter->pdev);
@@ -498,10 +541,18 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	err = qlcnic_fw_cmd_create_tx_ctx(adapter);
-	if (err) {
-		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-		return err;
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		err = qlcnic_fw_cmd_create_tx_ctx(adapter,
+				&adapter->tx_ring[ring], ring);
+		if (err) {
+			qlcnic_fw_cmd_destroy_rx_ctx(adapter);
+			if (ring == 0)
+				return err;
+			for (i = 0; i < ring; i++)
+				qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+					 &adapter->tx_ring[i]);
+			return err;
+		}
 	}
 
 	set_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
@@ -510,9 +561,13 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 
 void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
 {
+	int ring;
+
 	if (test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state)) {
 		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-		qlcnic_fw_cmd_destroy_tx_ctx(adapter);
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++)
+			qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+					&adapter->tx_ring[ring]);
 
 		/* Allow dma queues to drain after context reset */
 		msleep(20);
@@ -529,20 +584,22 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 
 	recv_ctx = adapter->recv_ctx;
 
-	tx_ring = adapter->tx_ring;
-	if (tx_ring->hw_consumer != NULL) {
-		dma_free_coherent(&adapter->pdev->dev,
-				sizeof(u32),
-				tx_ring->hw_consumer,
-				tx_ring->hw_cons_phys_addr);
-		tx_ring->hw_consumer = NULL;
-	}
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		if (tx_ring->hw_consumer != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+					sizeof(u32),
+					tx_ring->hw_consumer,
+					tx_ring->hw_cons_phys_addr);
+			tx_ring->hw_consumer = NULL;
+		}
 
-	if (tx_ring->desc_head != NULL) {
-		dma_free_coherent(&adapter->pdev->dev,
-				TX_DESC_RINGSIZE(tx_ring),
-				tx_ring->desc_head, tx_ring->phys_addr);
-		tx_ring->desc_head = NULL;
+		if (tx_ring->desc_head != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+					TX_DESC_RINGSIZE(tx_ring),
+					tx_ring->desc_head, tx_ring->phys_addr);
+			tx_ring->desc_head = NULL;
+		}
 	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
@@ -570,25 +627,21 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 	}
 }
 
-
 /* Get MAC address of a NIC partition */
-
-int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
+int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 {
 	int err, i;
 	struct qlcnic_cmd_args cmd;
 	u32 mac_low, mac_high;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = adapter->ahw->pci_func | BIT_8;
-	cmd.req.cmd = QLCNIC_CDRP_CMD_MAC_ADDRESS;
-	cmd.rsp.arg1 = cmd.rsp.arg2 = 1;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_MAC_ADDRESS);
+	cmd.req.arg[1] = adapter->ahw->pci_func | BIT_8;
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
-		mac_low = cmd.rsp.arg1;
-		mac_high = cmd.rsp.arg2;
+		mac_low = cmd.rsp.arg[1];
+		mac_high = cmd.rsp.arg[2];
 
 		for (i = 0; i < 2; i++)
 			mac[i] = (u8) (mac_high >> ((1 - i) * 8));
@@ -599,17 +652,17 @@ int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 			"Failed to get mac address%d\n", err);
 		err = -EIO;
 	}
-
+	qlcnic_free_mbx_args(&cmd);
 	return err;
 }
 
 /* Get info of a NIC partition */
-int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
+int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *adapter,
 				struct qlcnic_info *npar_info, u8 func_id)
 {
 	int	err;
 	dma_addr_t nic_dma_t;
-	struct qlcnic_info *nic_info;
+	const struct qlcnic_info *nic_info;
 	void *nic_info_addr;
 	struct qlcnic_cmd_args cmd;
 	size_t	nic_size = sizeof(struct qlcnic_info);
@@ -621,15 +674,14 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
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
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_NIC_INFO);
+	cmd.req.arg[1] = MSD(nic_dma_t);
+	cmd.req.arg[2] = LSD(nic_dma_t);
+	cmd.req.arg[3] = (func_id << 16 | nic_size);
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err != QLCNIC_RCODE_SUCCESS) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get nic info%d\n", err);
 		err = -EIO;
@@ -637,11 +689,14 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 
 	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
 		nic_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
 /* Configure a NIC partition */
-int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
+int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *adapter,
+						struct qlcnic_info *nic)
 {
 	int err = -EIO;
 	dma_addr_t nic_dma_t;
@@ -672,13 +727,12 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 	nic_info->min_tx_bw = cpu_to_le16(nic->min_tx_bw);
 	nic_info->max_tx_bw = cpu_to_le16(nic->max_tx_bw);
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_SET_NIC_INFO;
-	cmd.req.arg1 = MSD(nic_dma_t);
-	cmd.req.arg2 = LSD(nic_dma_t);
-	cmd.req.arg3 = ((nic->pci_func << 16) | nic_size);
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_SET_NIC_INFO);
+	cmd.req.arg[1] = MSD(nic_dma_t);
+	cmd.req.arg[2] = LSD(nic_dma_t);
+	cmd.req.arg[3] = ((nic->pci_func << 16) | nic_size);
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (err != QLCNIC_RCODE_SUCCESS) {
 		dev_err(&adapter->pdev->dev,
@@ -688,11 +742,13 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 
 	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
 		nic_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
 /* Get PCI Info of a partition */
-int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
+int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *adapter,
 				struct qlcnic_pci_info *pci_info)
 {
 	int err = 0, i;
@@ -710,19 +766,21 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 	memset(pci_info_addr, 0, pci_size);
 
 	npar = pci_info_addr;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_PCI_INFO;
-	cmd.req.arg1 = MSD(pci_info_dma_t);
-	cmd.req.arg2 = LSD(pci_info_dma_t);
-	cmd.req.arg3 = pci_size;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
-
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_GET_PCI_INFO);
+	cmd.req.arg[1] = MSD(pci_info_dma_t);
+	cmd.req.arg[2] = LSD(pci_info_dma_t);
+	cmd.req.arg[3] = pci_size;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+
+	adapter->ahw->act_pci_func = 0;
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
 			pci_info->id = le16_to_cpu(npar->id);
 			pci_info->active = le16_to_cpu(npar->active);
 			pci_info->type = le16_to_cpu(npar->type);
+			if (pci_info->type == QLCNIC_TYPE_NIC)
+				adapter->ahw->act_pci_func++;
 			pci_info->default_port =
 				le16_to_cpu(npar->default_port);
 			pci_info->tx_min_bw =
@@ -739,6 +797,8 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 
 	dma_free_coherent(&adapter->pdev->dev, pci_size, pci_info_addr,
 		pci_info_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -757,21 +817,20 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
 	arg1 = id | (enable_mirroring ? BIT_4 : 0);
 	arg1 |= pci_func << 8;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_SET_PORTMIRRORING;
-	cmd.req.arg1 = arg1;
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_SET_PORTMIRRORING);
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
@@ -808,13 +867,12 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
 	arg1 |= rx_tx << 15 | stats_size << 16;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_ESWITCH_STATS;
-	cmd.req.arg1 = arg1;
-	cmd.req.arg2 = MSD(stats_dma_t);
-	cmd.req.arg3 = LSD(stats_dma_t);
-	qlcnic_issue_cmd(adapter, &cmd);
-	err = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_ESWITCH_STATS);
+	cmd.req.arg[1] = arg1;
+	cmd.req.arg[2] = MSD(stats_dma_t);
+	cmd.req.arg[3] = LSD(stats_dma_t);
+	err = qlcnic_issue_cmd(adapter, &cmd);
 
 	if (!err) {
 		stats = stats_addr;
@@ -834,6 +892,8 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 
 	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
 		stats_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
 	return err;
 }
 
@@ -848,6 +908,9 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 	void *stats_addr;
 	int err;
 
+	if (mac_stats == NULL)
+		return -ENOMEM;
+
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
 			&stats_dma_t, GFP_KERNEL);
 	if (!stats_addr) {
@@ -856,15 +919,12 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
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
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_MAC_STATS);
+	cmd.req.arg[1] = stats_size << 16;
+	cmd.req.arg[2] = MSD(stats_dma_t);
+	cmd.req.arg[3] = LSD(stats_dma_t);
+	err = qlcnic_issue_cmd(adapter, &cmd);
 	if (!err) {
 		stats = stats_addr;
 		mac_stats->mac_tx_frames = le64_to_cpu(stats->mac_tx_frames);
@@ -885,11 +945,15 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 				le64_to_cpu(stats->mac_rx_length_large);
 		mac_stats->mac_rx_jabber = le64_to_cpu(stats->mac_rx_jabber);
 		mac_stats->mac_rx_dropped = le64_to_cpu(stats->mac_rx_dropped);
-		mac_stats->mac_rx_crc_error = le64_to_cpu(stats->mac_rx_crc_error);
+		mac_stats->mac_FCS_error = le64_to_cpu(stats->mac_FCS_error);
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"%s: Get mac stats failed, err=%d.\n", __func__, err);
 	}
 
 	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
 		stats_dma_t);
+	qlcnic_free_mbx_args(&cmd);
 	return err;
 }
 
@@ -949,7 +1013,7 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 		const u8 port, const u8 rx_tx)
 {
-
+	int err;
 	u32 arg1;
 	struct qlcnic_cmd_args cmd;
 
@@ -972,15 +1036,17 @@ int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 	arg1 = port | QLCNIC_STATS_VERSION << 8 | func_esw << 12;
 	arg1 |= BIT_14 | rx_tx << 15;
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_ESWITCH_STATS;
-	cmd.req.arg1 = arg1;
-	qlcnic_issue_cmd(adapter, &cmd);
-	return cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_ESWITCH_STATS);
+	cmd.req.arg[1] = arg1;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
 
 err_ret:
-	dev_err(&adapter->pdev->dev, "Invalid argument func_esw=%d port=%d"
-		"rx_ctx=%d\n", func_esw, port, rx_tx);
+	dev_err(&adapter->pdev->dev,
+			"Invalid args func_esw %d port %d rx_ctx %d\n",
+							func_esw, port, rx_tx);
 	return -EIO;
 }
 
@@ -993,22 +1059,21 @@ __qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
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
+		QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG);
+	cmd.req.arg[1] = *arg1;
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	*arg1 = cmd.rsp.arg[1];
+	*arg2 = cmd.rsp.arg[2];
+	qlcnic_free_mbx_args(&cmd);
 
-	if (err == QLCNIC_RCODE_SUCCESS) {
+	if (err == QLCNIC_RCODE_SUCCESS)
 		dev_info(&adapter->pdev->dev,
 			"eSwitch port config for pci func %d\n", pci_func);
-	} else {
+	else
 		dev_err(&adapter->pdev->dev,
 			"Failed to get eswitch port config for pci func %d\n",
 								pci_func);
-	}
 	return err;
 }
 /* Configure eSwitch port
@@ -1070,20 +1135,19 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 		return err;
 	}
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH;
-	cmd.req.arg1 = arg1;
-	cmd.req.arg2 = arg2;
-	qlcnic_issue_cmd(adapter, &cmd);
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_CONFIGURE_ESWITCH);
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
 			"Configured eSwitch for pci func %d\n", pci_func);
-	}
 
 	return err;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 130408e..85d281e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -13,7 +13,6 @@
 #include <linux/ethtool.h>
 
 #include "qlcnic.h"
-#include "qlcnic_hw.h"
 
 struct qlcnic_stats {
 	char stat_string[ETH_GSTRING_LEN];
@@ -135,11 +134,9 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 #define QLCNIC_MAX_EEPROM_LEN   1024
 
 static const u32 diag_registers[] = {
-	CRB_CMDPEG_STATE,
-	CRB_RCVPEG_STATE,
-	CRB_XG_STATE_P3P,
-	CRB_FW_CAPABILITIES_1,
-	ISR_INT_STATE_REG,
+	QLCNIC_CMDPEG_STATE,
+	QLCNIC_RCVPEG_STATE,
+	QLCNIC_FW_CAPABILITIES,
 	QLCNIC_CRB_DRV_ACTIVE,
 	QLCNIC_CRB_DEV_STATE,
 	QLCNIC_CRB_DRV_STATE,
@@ -173,12 +170,13 @@ static int qlcnic_get_eeprom_len(struct net_device *dev)
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
 
@@ -192,6 +190,7 @@ qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 static int
 qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int check_sfp_module = 0;
@@ -217,7 +216,7 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	} else if (ahw->port_type == QLCNIC_XGBE) {
 		u32 val;
 
-		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
+		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
 		if (val == QLCNIC_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
 			ecmd->advertising = ADVERTISED_1000baseT_Full;
@@ -375,6 +374,7 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 static void
 qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -390,7 +390,7 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
 
 	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[j] != -1; j++, i++)
-		regs_buff[i] = QLCRD32(adapter, diag_registers[j]);
+		regs_buff[i] = QLCRD32(adapter, diag_registers[j], &err);
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return;
@@ -415,10 +415,11 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 
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
@@ -545,6 +546,7 @@ static void
 qlcnic_get_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int port = adapter->ahw->physical_port;
@@ -554,9 +556,9 @@ qlcnic_get_pauseparam(struct net_device *netdev,
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
@@ -576,7 +578,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
-		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, &err);
 		if (port == 0)
 			pause->tx_pause = !(qlcnic_xg_get_xg0_mask(val));
 		else
@@ -591,6 +593,7 @@ static int
 qlcnic_set_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int port = adapter->ahw->physical_port;
@@ -601,7 +604,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port));
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), &err);
 
 		if (pause->rx_pause)
 			qlcnic_gb_rx_flowctl(val);
@@ -610,7 +613,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 
 		QLCWR32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), val);
 		/* set autoneg */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, &err);
 		switch (port) {
 		case 0:
 			if (pause->tx_pause)
@@ -646,7 +649,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return -EIO;
 
-		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, &err);
 		if (port == 0) {
 			if (pause->tx_pause)
 				qlcnic_xg_unset_xg0_mask(val);
@@ -668,10 +671,11 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 
 static int qlcnic_reg_test(struct net_device *dev)
 {
+	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 data_read;
 
-	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0));
+	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0), &err);
 	if ((data_read & 0xffff) != adapter->pdev->vendor)
 		return 1;
 
@@ -708,20 +712,20 @@ static int qlcnic_irq_test(struct net_device *netdev)
 		goto clear_it;
 
 	adapter->ahw->diag_cnt = 0;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_INTRPT_TEST;
-	cmd.req.arg1 = adapter->ahw->pci_func;
-	qlcnic_issue_cmd(adapter, &cmd);
-	ret = cmd.rsp.cmd;
+	qlcnic_alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_INTRPT_TEST);
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
@@ -848,7 +852,7 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 
 	ret = qlcnic_do_lb_test(adapter, mode);
 
-	qlcnic_clear_lb_mode(adapter);
+	qlcnic_clear_lb_mode(adapter, mode);
 
  free_res:
 	qlcnic_diag_free_res(netdev, max_sds_rings);
@@ -967,7 +971,6 @@ qlcnic_fill_stats(int *index, u64 *data, void *stats, int type)
 		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_large);
 		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_jabber);
 		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_dropped);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_crc_error);
 		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_align_error);
 	} else if (type == QLCNIC_ESW_STATS) {
 		struct __qlcnic_esw_statistics *esw_stats =
@@ -1096,17 +1099,18 @@ static int qlcnic_set_led(struct net_device *dev,
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
@@ -1114,17 +1118,18 @@ qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
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
@@ -1288,7 +1293,7 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 static int
 qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 {
-	int i;
+	int i, err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
 	u32 state;
@@ -1309,7 +1314,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 			return 0;
 		}
 		netdev_info(netdev, "Forcing a FW dump\n");
-		qlcnic_dev_request_reset(adapter);
+		qlcnic_dev_request_reset(adapter, 0);
 		break;
 	case QLCNIC_DISABLE_FW_DUMP:
 		if (fw_dump->enable && fw_dump->tmpl_hdr) {
@@ -1329,12 +1334,12 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
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
index 808b445..72615d1 100644
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
@@ -387,9 +389,6 @@ enum {
 #define QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT (ROMUSB_ROM + 0x0014)
 #define QLCNIC_ROMUSB_ROM_RDATA		(ROMUSB_ROM + 0x0018)
 
-/* Lock IDs for ROM lock */
-#define ROM_LOCK_DRIVER	0x0d417340
-
 /******************************************************************************
 *
 *    Definitions specific to M25P flash
@@ -488,7 +487,7 @@ enum {
 #define QLCNIC_NIU_GB_MAC_CONFIG_1(I)		\
 		(QLCNIC_CRB_NIU + 0x30004 + (I)*0x10000)
 
-
+#define MAX_CTL_CHECK   1000
 #define TEST_AGT_CTRL	(0x00)
 
 #define TA_CTL_START	BIT_0
@@ -496,27 +495,6 @@ enum {
 #define TA_CTL_WRITE	BIT_2
 #define TA_CTL_BUSY	BIT_3
 
-/*
- *   Register offsets for MN
- */
-#define MIU_TEST_AGT_BASE		(0x90)
-
-#define MIU_TEST_AGT_ADDR_LO		(0x04)
-#define MIU_TEST_AGT_ADDR_HI		(0x08)
-#define MIU_TEST_AGT_WRDATA_LO		(0x10)
-#define MIU_TEST_AGT_WRDATA_HI		(0x14)
-#define MIU_TEST_AGT_WRDATA_UPPER_LO	(0x20)
-#define MIU_TEST_AGT_WRDATA_UPPER_HI	(0x24)
-#define MIU_TEST_AGT_WRDATA(i)		(0x10+(0x10*((i)>>1))+(4*((i)&1)))
-#define MIU_TEST_AGT_RDDATA_LO		(0x18)
-#define MIU_TEST_AGT_RDDATA_HI		(0x1c)
-#define MIU_TEST_AGT_RDDATA_UPPER_LO	(0x28)
-#define MIU_TEST_AGT_RDDATA_UPPER_HI	(0x2c)
-#define MIU_TEST_AGT_RDDATA(i)		(0x18+(0x10*((i)>>1))+(4*((i)&1)))
-
-#define MIU_TEST_AGT_ADDR_MASK		0xfffffff8
-#define MIU_TEST_AGT_UPPER_ADDR(off)	(0)
-
 #define QLCNIC_MS_CTRL     0x41000090
 #define QLCNIC_MS_ADDR_LO  0x41000094
 #define QLCNIC_MS_ADDR_HI  0x41000098
@@ -532,13 +510,12 @@ enum {
 #define QLCNIC_MS_RDDATA_UHI       0x410000BC
 
 static const u32 QLCNIC_MS_READ_DATA[] = {
-	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC};
+	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
 
 #define QLC_TA_WRITE_ENABLE (TA_CTL_ENABLE | TA_CTL_WRITE)
 #define QLC_TA_WRITE_START (TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE)
 #define QLC_TA_START_ENABLE (TA_CTL_START | TA_CTL_ENABLE)
 
-
 /* XG Link status */
 #define XG_LINK_UP	0x10
 #define XG_LINK_DOWN	0x20
@@ -558,9 +535,6 @@ static const u32 QLCNIC_MS_READ_DATA[] = {
 
 #define QLCNIC_CAM_RAM_BASE	(QLCNIC_CRB_CAM + 0x02000)
 #define QLCNIC_CAM_RAM(reg)	(QLCNIC_CAM_RAM_BASE + (reg))
-#define QLCNIC_FW_VERSION_MAJOR (QLCNIC_CAM_RAM(0x150))
-#define QLCNIC_FW_VERSION_MINOR (QLCNIC_CAM_RAM(0x154))
-#define QLCNIC_FW_VERSION_SUB	(QLCNIC_CAM_RAM(0x158))
 #define QLCNIC_ROM_LOCK_ID	(QLCNIC_CAM_RAM(0x100))
 #define QLCNIC_PHY_LOCK_ID	(QLCNIC_CAM_RAM(0x120))
 #define QLCNIC_CRB_WIN_LOCK_ID	(QLCNIC_CAM_RAM(0x124))
@@ -570,23 +544,19 @@ static const u32 QLCNIC_MS_READ_DATA[] = {
 #define QLCNIC_REG(X)		(NIC_CRB_BASE+(X))
 #define QLCNIC_REG_2(X) 	(NIC_CRB_BASE_2+(X))
 
+#define QLCNIC_CDRP_MAX_ARGS   4
+#define QLCNIC_CDRP_ARG(i)             (QLCNIC_REG(0x18 + ((i) * 4)))
+
 #define QLCNIC_CDRP_CRB_OFFSET		(QLCNIC_REG(0x18))
-#define QLCNIC_ARG1_CRB_OFFSET		(QLCNIC_REG(0x1c))
-#define QLCNIC_ARG2_CRB_OFFSET		(QLCNIC_REG(0x20))
-#define QLCNIC_ARG3_CRB_OFFSET		(QLCNIC_REG(0x24))
 #define QLCNIC_SIGN_CRB_OFFSET		(QLCNIC_REG(0x28))
 
-#define CRB_CMDPEG_STATE		(QLCNIC_REG(0x50))
-#define CRB_RCVPEG_STATE		(QLCNIC_REG(0x13c))
 
 #define CRB_XG_STATE_P3P		(QLCNIC_REG(0x98))
 #define CRB_PF_LINK_SPEED_1		(QLCNIC_REG(0xe8))
 
-#define CRB_TEMP_STATE			(QLCNIC_REG(0x1b4))
 
 #define CRB_DRIVER_VERSION		(QLCNIC_REG(0x2a0))
 
-#define CRB_FW_CAPABILITIES_1		(QLCNIC_CAM_RAM(0x128))
 #define CRB_FW_CAPABILITIES_2		(QLCNIC_CAM_RAM(0x12c))
 
 /*
@@ -675,17 +645,6 @@ enum {
 #define QLCNIC_PEG_TUNE_CAPABILITY	(QLCNIC_CAM_RAM(0x02c))
 
 #define QLCNIC_DMA_WATCHDOG_CTRL	(QLCNIC_CAM_RAM(0x14))
-#define QLCNIC_PEG_ALIVE_COUNTER	(QLCNIC_CAM_RAM(0xb0))
-#define QLCNIC_PEG_HALT_STATUS1 	(QLCNIC_CAM_RAM(0xa8))
-#define QLCNIC_PEG_HALT_STATUS2 	(QLCNIC_CAM_RAM(0xac))
-#define QLCNIC_CRB_DRV_ACTIVE	(QLCNIC_CAM_RAM(0x138))
-#define QLCNIC_CRB_DEV_STATE		(QLCNIC_CAM_RAM(0x140))
-
-#define QLCNIC_CRB_DRV_STATE		(QLCNIC_CAM_RAM(0x144))
-#define QLCNIC_CRB_DRV_SCRATCH		(QLCNIC_CAM_RAM(0x148))
-#define QLCNIC_CRB_DEV_PARTITION_INFO	(QLCNIC_CAM_RAM(0x14c))
-#define QLCNIC_CRB_DRV_IDC_VER		(QLCNIC_CAM_RAM(0x174))
-#define QLCNIC_CRB_DEV_NPAR_STATE	(QLCNIC_CAM_RAM(0x19c))
 #define QLCNIC_ROM_DEV_INIT_TIMEOUT	(0x3e885c)
 #define QLCNIC_ROM_DRV_RESET_TIMEOUT	(0x3e8860)
 
@@ -704,7 +663,6 @@ enum {
 #define QLCNIC_DEV_NPAR_OPER		1 /* NPAR Operational */
 #define QLCNIC_DEV_NPAR_OPER_TIMEO	30 /* Operational time out */
 
-#define QLC_DEV_CHECK_ACTIVE(VAL, FN)		((VAL) & (1 << (FN * 4)))
 #define QLC_DEV_SET_REF_CNT(VAL, FN)		((VAL) |= (1 << (FN * 4)))
 #define QLC_DEV_CLR_REF_CNT(VAL, FN)		((VAL) &= ~(1 << (FN * 4)))
 #define QLC_DEV_SET_RST_RDY(VAL, FN)		((VAL) |= (1 << (FN * 4)))
@@ -761,16 +719,11 @@ struct qlcnic_legacy_intr_set {
 	u32	tgt_mask_reg;
 };
 
-#define QLCNIC_FW_API		0x1b216c
-#define QLCNIC_DRV_OP_MODE	0x1b2170
 #define QLCNIC_MSIX_BASE	0x132110
 #define QLCNIC_MAX_PCI_FUNC	8
 #define QLCNIC_MAX_VLAN_FILTERS	64
 
 /* FW dump defines */
-#define MIU_TEST_CTR		0x41000090
-#define MIU_TEST_ADDR_LO	0x41000094
-#define MIU_TEST_ADDR_HI	0x41000098
 #define FLASH_ROM_WINDOW	0x42110030
 #define FLASH_ROM_DATA		0x42150000
 
@@ -778,36 +731,18 @@ struct qlcnic_legacy_intr_set {
 static const u32 FW_DUMP_LEVELS[] = {
 	0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff };
 
-static const u32 MIU_TEST_READ_DATA[] = {
-	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
-
 #define QLCNIC_FW_DUMP_REG1	0x00130060
 #define QLCNIC_FW_DUMP_REG2	0x001e0000
 #define QLCNIC_FLASH_SEM2_LK	0x0013C010
 #define QLCNIC_FLASH_SEM2_ULK	0x0013C014
 #define QLCNIC_FLASH_LOCK_ID	0x001B2100
 
-#define QLCNIC_RD_DUMP_REG(addr, bar0, data) do {			\
-	writel((addr & 0xFFFF0000), (void *) (bar0 +			\
-		QLCNIC_FW_DUMP_REG1));					\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG1));			\
-	*data = readl((void *) (bar0 + QLCNIC_FW_DUMP_REG2 +		\
-		LSW(addr)));						\
-} while (0)
-
-#define QLCNIC_WR_DUMP_REG(addr, bar0, data) do {			\
-	writel((addr & 0xFFFF0000), (void *) (bar0 +			\
-		QLCNIC_FW_DUMP_REG1));					\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG1));			\
-	writel(data, (void *) (bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr)));\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr)));	\
-} while (0)
-
 /* PCI function operational mode */
 enum {
 	QLCNIC_MGMT_FUNC	= 0,
 	QLCNIC_PRIV_FUNC	= 1,
-	QLCNIC_NON_PRIV_FUNC	= 2
+	QLCNIC_NON_PRIV_FUNC	= 2,
+	QLCNIC_UNKNOWN_FUNC_MODE = 3
 };
 
 enum {
@@ -1008,6 +943,8 @@ enum {
 #define QLCNIC_NIU_PROMISC_MODE		1
 #define QLCNIC_NIU_ALLMULTI_MODE	2
 
+#define QLCNIC_PCIE_SEM_TIMEOUT	10000
+
 struct crb_128M_2M_sub_block_map {
 	unsigned valid;
 	unsigned start_128M;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 890f25b..743300b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -13,18 +13,6 @@
 #include <net/ip.h>
 #include <linux/bitops.h>
 
-#define MASK(n) ((1ULL<<(n))-1)
-#define OCM_WIN_P3P(addr) (addr & 0xffc0000)
-
-#define GET_MEM_OFFS_2M(addr) (addr & MASK(18))
-
-#define CRB_BLK(off)	((off >> 20) & 0x3f)
-#define CRB_SUBBLK(off)	((off >> 16) & 0xf)
-#define CRB_WINDOW_2M	(0x130060)
-#define CRB_HI(off)	((crb_hub_agt[CRB_BLK(off)] << 20) | ((off) & 0xf0000))
-#define CRB_INDIRECT_2M	(0x1e0000UL)
-
-
 #ifndef readq
 static inline u64 readq(void __iomem *addr)
 {
@@ -277,8 +265,6 @@ static const u32 msi_tgt_status[8] = {
 
 /*  PCI Windowing for DDR regions.  */
 
-#define QLCNIC_PCIE_SEM_TIMEOUT	10000
-
 static void
 qlcnic_read_dump_reg(u32 addr, void __iomem *bar0, u32 *data)
 {
@@ -311,16 +297,18 @@ qlcnic_write_dump_reg(u32 addr, void __iomem *bar0, u32 data)
 int
 qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 {
-	int done = 0, timeout = 0;
+	int err, done = 0, timeout = 0;
 
 	while (!done) {
-		done = QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)));
+		done = QLCRD32(adapter,
+			QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)), &err);
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
@@ -332,12 +320,6 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
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
@@ -355,6 +337,13 @@ void qlcnic_ind_wr(struct qlcnic_adapter *adapter, u32 addr, u32 data)
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
@@ -412,9 +401,9 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
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
@@ -511,7 +500,7 @@ send_fw_cmd:
 	qlcnic_nic_set_promisc(adapter, mode);
 }
 
-int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
+int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -583,9 +572,10 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
 		head = &(adapter->fhash.fhead[i]);
 
 		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
-			qlcnic_sre_macaddr_change(adapter, tmp_fil->faddr,
-				tmp_fil->vlan_id, tmp_fil->vlan_id ?
-				QLCNIC_MAC_VLAN_DEL :  QLCNIC_MAC_DEL);
+			qlcnic_sre_macaddr_change(adapter,
+				tmp_fil->faddr, tmp_fil->vlan_id,
+				tmp_fil->vlan_id ?  QLCNIC_MAC_VLAN_DEL :
+				QLCNIC_MAC_DEL);
 			spin_lock_bh(&adapter->mac_learn_lock);
 			adapter->fhash.fnum--;
 			hlist_del(&tmp_fil->fnode);
@@ -595,7 +585,7 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
 	}
 }
 
-int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
+static int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
 {
 	struct qlcnic_nic_req req;
 	int rv;
@@ -615,12 +605,13 @@ int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
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
@@ -629,11 +620,11 @@ int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
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
@@ -643,12 +634,13 @@ void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter)
 
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
@@ -670,10 +662,9 @@ int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
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
@@ -699,7 +690,7 @@ int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 	return rv;
 }
 
-int qlcnic_82xx_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
+int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -728,10 +719,7 @@ int qlcnic_82xx_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 	return rv;
 }
 
-
-#define RSS_HASHTYPE_IP_TCP	0x3
-
-int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
+int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_nic_req req;
 	u64 word;
@@ -774,7 +762,8 @@ int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
 	return rv;
 }
 
-int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
+void qlcnic_82xx_config_ipaddr(struct qlcnic_adapter *adapter,
+						__be32 ip, int cmd)
 {
 	struct qlcnic_nic_req req;
 	struct qlcnic_ipaddr *ipa;
@@ -794,25 +783,21 @@ int qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
 	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0)
 		dev_err(&adapter->netdev->dev,
-				"could not notify %s IP 0x%x reuqest\n",
+				"could not notify %s IP 0x%x request\n",
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
@@ -978,7 +963,7 @@ qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 }
 
 int
-qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
+qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 {
 	unsigned long flags;
 	int rv;
@@ -1010,7 +995,7 @@ qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 }
 
 u32
-qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
+qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *err)
 {
 	unsigned long flags;
 	int rv;
@@ -1036,6 +1021,9 @@ qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 	dev_err(&adapter->pdev->dev,
 			"%s: invalid offset: 0x%016lx\n", __func__, off);
 	dump_stack();
+	if (err)
+		*err = -1;
+
 	return -1;
 }
 
@@ -1271,9 +1259,9 @@ qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
 	return ret;
 }
 
-int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
+int qlcnic_82xx_get_board_info(struct qlcnic_adapter *adapter)
 {
-	int offset, board_type, magic;
+	int offset, board_type, magic, err;
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
@@ -1294,7 +1282,7 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 	ahw->board_type = board_type;
 
 	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
-		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I);
+		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I, &err);
 		if ((gpio & 0x8000) == 0)
 			board_type = QLCNIC_BRDTYPE_P3P_10G_TP;
 	}
@@ -1333,11 +1321,12 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
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
@@ -1367,7 +1356,7 @@ int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 	return rv;
 }
 
-void qlcnic_get_func_no(struct qlcnic_adapter *adapter)
+void qlcnic_82xx_get_func_no(struct qlcnic_adapter *adapter)
 {
 	void __iomem *msix_base_addr;
 	u32 func;
@@ -1389,6 +1378,7 @@ void qlcnic_get_ocm_win(struct qlcnic_hardware_context *ahw)
 void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
 	loff_t offset, size_t size)
 {
+	int err;
 	u32 data;
 	u64 qmdata;
 
@@ -1396,7 +1386,7 @@ void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
 		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
 		memcpy(buf, &qmdata, size);
 	} else {
-		data = QLCRD32(adapter, offset);
+		data = QLCRD32(adapter, offset, &err);
 		memcpy(buf, &data, size);
 	}
 }
@@ -1415,3 +1405,13 @@ void qlcnic_82xx_write_crb(struct qlcnic_adapter *adapter, char *buf,
 		QLCWR32(adapter, offset, data);
 	}
 }
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
index 8f16098..168df18 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -1,8 +1,6 @@
 #ifndef __QLCNIC_HW_H
 #define __QLCNIC_HW_H
 
-#include "qlcnic.h"
-
 #define MASK(n) ((1ULL<<(n))-1)
 #define OCM_WIN_P3P(addr) (addr & 0xffc0000)
 #define OCM_WIN_83XX(addr)	(addr & 0xFFE0000)
@@ -30,6 +28,33 @@
 #define QLCNIC_IS_82XX(adapter)	\
 	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? 1 : 0)
 
+/* Existing registers in 83xx and 82xx */
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
@@ -199,10 +224,56 @@ do {							\
 	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX) :\
 	1)
 
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
+					struct net_device *netdev);
+void qlcnic_82xx_change_filter(struct qlcnic_adapter *, u64 *, __le16);
+void qlcnic_82xx_config_intr_coalesce(struct qlcnic_adapter *adapter);
+int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable);
+void qlcnic_82xx_config_ipaddr(struct qlcnic_adapter *adapter,
+						__be32 ip, int cmd);
+int qlcnic_82xx_linkevent_request(struct qlcnic_adapter *adapter, int enable);
+void qlcnic_82xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
+int qlcnic_82xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8);
+int qlcnic_82xx_set_lb_mode(struct qlcnic_adapter *, u8);
 void qlcnic_82xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
 void qlcnic_82xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
-int qlcnic_82xx_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
+void qlcnic_82xx_dev_request_reset(struct qlcnic_adapter *, u32);
+int qlcnic_82xx_setup_intr(struct qlcnic_adapter *, u8);
+irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *);
+int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
+					struct qlcnic_cmd_args *);
+int qlcnic_82xx_fw_cmd_create_rx_ctx(struct qlcnic_adapter *);
+int qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *,
+				struct qlcnic_host_tx_ring *tx_ring, int);
+int qlcnic_82xx_sre_macaddr_change(struct qlcnic_adapter *, u8 *, __le16, u8);
+int qlcnic_82xx_get_mac_address(struct qlcnic_adapter *, u8*);
+int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *, struct qlcnic_info *, u8);
+int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
+int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info*);
+int qlcnic_82xx_alloc_mbx_args(struct qlcnic_cmd_args *,
+				struct qlcnic_adapter *, u32);
+u32 qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *);
+int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
+int qlcnic_82xx_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
-int qlcnic_82xx_start_firmware(struct qlcnic_adapter *);
+void qlcnic_82xx_get_func_no(struct qlcnic_adapter *);
+int qlcnic_82xx_api_lock(struct qlcnic_adapter *);
+void qlcnic_82xx_api_unlock(struct qlcnic_adapter *);
 
 #endif				/* __QLCNIC_HW_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 72c6477..7e4064c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -163,13 +163,12 @@ void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
 
 	recv_ctx = adapter->recv_ctx;
 
 	if (recv_ctx->rds_rings == NULL)
-		goto skip_rds;
+		return;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
@@ -177,16 +176,6 @@ void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
 		rds_ring->rx_buf_arr = NULL;
 	}
 	kfree(recv_ctx->rds_rings);
-
-skip_rds:
-	if (adapter->tx_ring == NULL)
-		return;
-
-	tx_ring = adapter->tx_ring;
-	vfree(tx_ring->cmd_buf_arr);
-	tx_ring->cmd_buf_arr = NULL;
-	kfree(adapter->tx_ring);
-	adapter->tx_ring = NULL;
 }
 
 int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
@@ -194,32 +183,12 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 	struct qlcnic_recv_context *recv_ctx;
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
 	struct qlcnic_rx_buffer *rx_buf;
 	int ring, i, size;
 
-	struct qlcnic_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	size = sizeof(struct qlcnic_host_tx_ring);
-	tx_ring = kzalloc(size, GFP_KERNEL);
-	if (tx_ring == NULL) {
-		dev_err(&netdev->dev, "failed to allocate tx ring struct\n");
-		return -ENOMEM;
-	}
-	adapter->tx_ring = tx_ring;
-
-	tx_ring->num_desc = adapter->num_txd;
-	tx_ring->txq = netdev_get_tx_queue(netdev, 0);
-
-	cmd_buf_arr = vzalloc(TX_BUFF_RINGSIZE(tx_ring));
-	if (cmd_buf_arr == NULL) {
-		dev_err(&netdev->dev, "failed to allocate cmd buffer ring\n");
-		goto err_out;
-	}
-	tx_ring->cmd_buf_arr = cmd_buf_arr;
-
 	recv_ctx = adapter->recv_ctx;
 
 	size = adapter->max_rds_rings * sizeof(struct qlcnic_host_rds_ring);
@@ -251,12 +220,14 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 				rds_ring->dma_size + NET_IP_ALIGN;
 			break;
 		}
-		rds_ring->rx_buf_arr = vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
+		rds_ring->rx_buf_arr = (struct qlcnic_rx_buffer *)
+			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
-			dev_err(&netdev->dev, "Failed to allocate "
-				"rx buffer ring %d\n", ring);
+			dev_err(&netdev->dev,
+				"Failed to allocate rx buffer ring %d\n", ring);
 			goto err_out;
 		}
+		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
@@ -320,13 +291,13 @@ static u32 qlcnic_decode_crb_addr(u32 addr)
 
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
@@ -341,6 +312,8 @@ static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 static int do_rom_fast_read(struct qlcnic_adapter *adapter,
 			    u32 addr, u32 *valp)
 {
+	int err;
+
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ADDRESS, addr);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ABYTE_CNT, 3);
@@ -354,7 +327,7 @@ static int do_rom_fast_read(struct qlcnic_adapter *adapter,
 	udelay(10);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
-	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA);
+	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA, &err);
 	return 0;
 }
 
@@ -406,15 +379,15 @@ int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp)
 
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
@@ -439,7 +412,7 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xb0000, 0x00);
 
 	/* halt sre */
-	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000);
+	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000, &err);
 	QLCWR32(adapter, QLCNIC_CRB_SRE + 0x1000, val & (~(0x1)));
 
 	/* halt epg */
@@ -561,8 +534,8 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
 	msleep(1);
 
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
 
 	return 0;
 }
@@ -573,7 +546,7 @@ static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 	int retries = QLCNIC_CMDPEG_CHECK_RETRY_COUNT;
 
 	do {
-		val = QLCRD32(adapter, CRB_CMDPEG_STATE);
+		val = QLCRD(adapter, QLCNIC_CMDPEG_STATE);
 
 		switch (val) {
 		case PHAN_INITIALIZE_COMPLETE:
@@ -589,7 +562,7 @@ static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 
 	} while (--retries);
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
 
 out_err:
 	dev_err(&adapter->pdev->dev, "Command Peg initialization not "
@@ -604,7 +577,7 @@ qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
 	int retries = QLCNIC_RCVPEG_CHECK_RETRY_COUNT;
 
 	do {
-		val = QLCRD32(adapter, CRB_RCVPEG_STATE);
+		val = QLCRD(adapter, QLCNIC_RCVPEG_STATE);
 
 		if (val == PHAN_PEG_RCV_INITIALIZED)
 			return 0;
@@ -635,7 +608,7 @@ qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
 	return err;
 }
@@ -646,7 +619,7 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 	int timeo;
 	u32 val;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
+	val = QLCRD(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
 	val = QLC_DEV_GET_DRV(val, adapter->portnum);
 	if ((val & 0x3) != QLCNIC_TYPE_NIC) {
 		dev_err(&adapter->pdev->dev,
@@ -686,11 +659,12 @@ static int qlcnic_get_flt_entry(struct qlcnic_adapter *adapter, u8 region,
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
@@ -759,10 +733,11 @@ qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
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
 
@@ -1085,11 +1060,11 @@ qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
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
@@ -1259,7 +1234,7 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 		return -EINVAL;
 	}
 
-	QLCWR32(adapter, QLCNIC_CAM_RAM(0x1fc), QLCNIC_BDINFO_MAGIC);
+	QLCWR(adapter, QLCNIC_FW_IMG_VALID, QLCNIC_BDINFO_MAGIC);
 	return 0;
 }
 
@@ -1315,6 +1290,7 @@ next:
 void
 qlcnic_release_firmware(struct qlcnic_adapter *adapter)
 {
-	release_firmware(adapter->fw);
+	if (adapter->fw)
+		release_firmware(adapter->fw);
 	adapter->fw = NULL;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index d39c86b..2761fc6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -6,17 +6,14 @@
 #include "qlcnic.h"
 #include "qlcnic_hw.h"
 
-static void
-qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
-	struct qlcnic_host_rds_ring *rds_ring);
-
-static void qlcnic_change_filter(struct qlcnic_adapter *adapter,
-		u64 uaddr, __le16 vlan_id, struct qlcnic_host_tx_ring *tx_ring)
+void qlcnic_82xx_change_filter(struct qlcnic_adapter *adapter,
+		u64 *uaddr, __le16 vlan_id)
 {
 	struct cmd_desc_type0 *hwdesc;
 	struct qlcnic_nic_req *req;
 	struct qlcnic_mac_req *mac_req;
 	struct qlcnic_vlan_req *vlan_req;
+	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 	u32 producer;
 	u64 word;
 
@@ -77,8 +74,8 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 
 			if (jiffies >
 			    (QLCNIC_READD_AGE * HZ + tmp_fil->ftime))
-				qlcnic_change_filter(adapter, src_addr, vlan_id,
-								tx_ring);
+				qlcnic_change_filter(adapter,
+							&src_addr, vlan_id);
 			tmp_fil->ftime = jiffies;
 			return;
 		}
@@ -88,7 +85,7 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	if (!fil)
 		return;
 
-	qlcnic_change_filter(adapter, src_addr, vlan_id, tx_ring);
+	qlcnic_change_filter(adapter, &src_addr, vlan_id);
 
 	fil->ftime = jiffies;
 	fil->vlan_id = vlan_id;
@@ -436,7 +433,6 @@ drop_packet:
 void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 {
 	struct net_device *netdev = adapter->netdev;
-
 	if (adapter->ahw->linkup && !linkup) {
 		netdev_info(netdev, "NIC Link is down\n");
 		adapter->ahw->linkup = 0;
@@ -454,7 +450,8 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 	}
 }
 
-static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter)
+int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter,
+		struct qlcnic_host_tx_ring *tx_ring, int budget)
 {
 	u32 sw_consumer, hw_consumer;
 	int count = 0, i;
@@ -463,7 +460,6 @@ static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_skb_frag *frag;
 	int done;
-	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 
 	if (!spin_trylock(&adapter->tx_clean_lock))
 		return 1;
@@ -491,7 +487,7 @@ static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter)
 		}
 
 		sw_consumer = get_next_index(sw_consumer, tx_ring->num_desc);
-		if (++count >= MAX_STATUS_HANDLE)
+		if (++count >= budget)
 			break;
 	}
 
@@ -538,7 +534,8 @@ int qlcnic_poll(struct napi_struct *napi, int budget)
 	int tx_complete;
 	int work_done;
 
-	tx_complete = qlcnic_process_cmd_ring(adapter);
+	tx_complete = qlcnic_process_cmd_ring(adapter, adapter->tx_ring,
+						budget);
 
 	work_done = qlcnic_process_rcv_ring(sds_ring, budget);
 
@@ -582,7 +579,6 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 
 	adapter->ahw->has_link_events = 1;
-
 	cable_OUI = msg->body[1] & 0xffffffff;
 	cable_len = (msg->body[1] >> 32) & 0xffff;
 	link_speed = (msg->body[1] >> 48) & 0xffff;
@@ -639,7 +635,6 @@ qlcnic_handle_fw_message(int desc_cnt, int index,
 	adapter = sds_ring->adapter;
 	dev = &adapter->pdev->dev;
 	opcode = qlcnic_get_nic_msg_opcode(msg.body[0]);
-
 	switch (opcode) {
 	case QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE:
 		qlcnic_handle_linkevent(adapter, &msg);
@@ -671,7 +666,7 @@ qlcnic_handle_fw_message(int desc_cnt, int index,
 	}
 }
 
-static int
+int
 qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_rds_ring *rds_ring,
 		struct qlcnic_rx_buffer *buffer)
@@ -703,7 +698,7 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
+struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_rds_ring *rds_ring, u16 index, u16 cksum)
 {
 	struct qlcnic_rx_buffer *buffer;
@@ -736,7 +731,7 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 	return skb;
 }
 
-static inline int
+inline int
 qlcnic_check_rx_tagging(struct qlcnic_adapter *adapter, struct sk_buff *skb,
 			u16 *vlan_tag)
 {
@@ -820,10 +815,6 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 	return buffer;
 }
 
-#define QLC_TCP_HDR_SIZE            20
-#define QLC_TCP_TS_OPTION_SIZE      12
-#define QLC_TCP_TS_HDR_SIZE         (QLC_TCP_HDR_SIZE + QLC_TCP_TS_OPTION_SIZE)
-
 static struct qlcnic_rx_buffer *
 qlcnic_process_lro(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_sds_ring *sds_ring,
@@ -914,7 +905,8 @@ qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
 	u64 sts_data0, sts_data1;
 
 	int count = 0;
-	int opcode, ring, desc_cnt;
+	int opcode, desc_cnt;
+	u8 ring;
 	u32 consumer = sds_ring->consumer;
 
 	while (count < max) {
@@ -980,7 +972,6 @@ skip:
 			spin_unlock(&rds_ring->lock);
 		}
 
-		qlcnic_post_rx_buffers_nodb(adapter, rds_ring);
 	}
 
 	if (count) {
@@ -993,7 +984,7 @@ skip:
 
 void
 qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
-	struct qlcnic_host_rds_ring *rds_ring)
+	struct qlcnic_host_rds_ring *rds_ring, u8 ring_id)
 {
 	struct rcv_desc *pdesc;
 	struct qlcnic_rx_buffer *buffer;
@@ -1019,9 +1010,9 @@ qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 		/* make a rcv descriptor  */
 		pdesc = &rds_ring->desc_head[producer];
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
-		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
+		pdesc->reference_handle = cpu_to_le16(QLCNIC_MAKE_REF_HANDLE(
+			adapter, buffer->ref_handle, ring_id));
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
-
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
 
@@ -1032,9 +1023,9 @@ qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 	}
 }
 
-static void
+void
 qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_rds_ring *rds_ring)
+		struct qlcnic_host_rds_ring *rds_ring, u8 ring_id)
 {
 	struct rcv_desc *pdesc;
 	struct qlcnic_rx_buffer *buffer;
@@ -1062,10 +1053,10 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 
 		/* make a rcv descriptor  */
 		pdesc = &rds_ring->desc_head[producer];
-		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
+		pdesc->reference_handle = cpu_to_le16(QLCNIC_MAKE_REF_HANDLE(
+			adapter, buffer->ref_handle, ring_id));
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
-
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
 
@@ -1077,7 +1068,7 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 	spin_unlock(&rds_ring->lock);
 }
 
-static void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
+void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
 {
 	int i;
 	unsigned char *data = skb->data;
@@ -1090,7 +1081,7 @@ static void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
 	}
 }
 
-void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
+static void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_sds_ring *sds_ring,
 		int ring, u64 sts_data0)
 {
@@ -1137,7 +1128,7 @@ void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 }
 
 void
-qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
+qlcnic_82xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 {
 	struct qlcnic_adapter *adapter = sds_ring->adapter;
 	struct status_desc *desc;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 5836603..e6822b1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2,10 +2,15 @@
  * QLogic qlcnic NIC Driver
  * Copyright (c)  2009-2010 QLogic Corporation
  *
+ * PCI searching functions pci_get_domain_bus_and_slot & pci_channel_offline
+ * Copyright (C) 1993 -- 1997 Drew Eckhardt, Frederic Potter,
+ *					David Mosberger-Tang
+ * Copyright (C) 1997 -- 2000 Martin Mares <mj@ucw.cz>
+ * Copyright (C) 2003 -- 2004 Greg Kroah-Hartman <greg@kroah.com>.
+ *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
-#include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 
@@ -14,10 +19,10 @@
 
 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <linux/ipv6.h>
 #include <linux/inetdevice.h>
-#include <linux/sysfs.h>
 #include <linux/aer.h>
 #include <linux/log2.h>
 
@@ -64,17 +69,14 @@ static void qlcnic_tx_timeout(struct net_device *netdev);
 static void qlcnic_attach_work(struct work_struct *work);
 static void qlcnic_fwinit_work(struct work_struct *work);
 static void qlcnic_fw_poll_work(struct work_struct *work);
-static void qlcnic_schedule_work(struct qlcnic_adapter *adapter,
-		work_func_t func, int delay);
-static void qlcnic_cancel_fw_work(struct qlcnic_adapter *adapter);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev);
 #endif
 
-static void qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter);
-static void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
+static void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter);
+static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter);
 
 static void qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding);
 static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8);
@@ -84,9 +86,9 @@ static irqreturn_t qlcnic_tmp_intr(int irq, void *data);
 static irqreturn_t qlcnic_intr(int irq, void *data);
 static irqreturn_t qlcnic_msi_intr(int irq, void *data);
 static irqreturn_t qlcnic_msix_intr(int irq, void *data);
+static irqreturn_t qlcnic_clear_legacy_intr(struct qlcnic_adapter *);
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
-static void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long);
 
 static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter);
 static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
@@ -95,9 +97,6 @@ static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
 static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
-static int qlcnic_vlan_rx_add(struct net_device *, u16);
-static int qlcnic_vlan_rx_del(struct net_device *, u16);
-
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
@@ -105,6 +104,7 @@ static int qlcnic_vlan_rx_del(struct net_device *, u16);
 
 static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
+	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE834X),
 	{0,}
 };
 
@@ -178,7 +178,7 @@ static const struct qlcnic_brdinfo qlcnic_boards[] = {
 static const
 struct qlcnic_legacy_intr_set legacy_intr[] = QLCNIC_LEGACY_INTR_CONFIG;
 
-static int
+int
 qlcnic_alloc_sds_rings(struct qlcnic_recv_context *recv_ctx, int count)
 {
 	int size = sizeof(struct qlcnic_host_sds_ring) * count;
@@ -188,7 +188,7 @@ qlcnic_alloc_sds_rings(struct qlcnic_recv_context *recv_ctx, int count)
 	return recv_ctx->sds_rings == NULL;
 }
 
-static void
+void
 qlcnic_free_sds_rings(struct qlcnic_recv_context *recv_ctx)
 {
 	if (recv_ctx->sds_rings != NULL)
@@ -247,8 +247,8 @@ qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	return 0;
 }
 
-static int
-qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
+int
+qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -259,13 +259,17 @@ qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
-
 		if (ring == adapter->max_sds_rings - 1)
 			netif_napi_add(netdev, &sds_ring->napi, qlcnic_poll,
-				QLCNIC_NETDEV_WEIGHT/adapter->max_sds_rings);
+				 QLCNIC_NETDEV_WEIGHT/adapter->max_sds_rings);
 		else
-			netif_napi_add(netdev, &sds_ring->napi,
-				qlcnic_rx_poll, QLCNIC_NETDEV_WEIGHT*2);
+			netif_napi_add(netdev, &sds_ring->napi, qlcnic_rx_poll,
+				QLCNIC_NETDEV_WEIGHT*2);
+	}
+
+	if (qlcnic_alloc_tx_rings(adapter, netdev)) {
+		qlcnic_free_sds_rings(recv_ctx);
+		return -ENOMEM;
 	}
 
 	return 0;
@@ -284,10 +288,12 @@ qlcnic_napi_del(struct qlcnic_adapter *adapter)
 	}
 
 	qlcnic_free_sds_rings(adapter->recv_ctx);
+
+	qlcnic_free_tx_rings(adapter);
 }
 
 static void
-qlcnic_napi_enable(struct qlcnic_adapter *adapter)
+qlcnic_82xx_napi_enable(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -304,7 +310,7 @@ qlcnic_napi_enable(struct qlcnic_adapter *adapter)
 }
 
 static void
-qlcnic_napi_disable(struct qlcnic_adapter *adapter)
+qlcnic_82xx_napi_disable(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
@@ -353,7 +359,7 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 		return -EOPNOTSUPP;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
+		return -EINVAL;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 		netif_device_detach(netdev);
@@ -389,6 +395,15 @@ qlcnic_vlan_rx_del(struct net_device *netdev, u16 vid)
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
@@ -401,41 +416,65 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_fix_features  = qlcnic_fix_features,
 	.ndo_set_features  = qlcnic_set_features,
 	.ndo_tx_timeout	   = qlcnic_tx_timeout,
-	.ndo_vlan_rx_add_vid	= qlcnic_vlan_rx_add,
-	.ndo_vlan_rx_kill_vid	= qlcnic_vlan_rx_del,
+	.ndo_vlan_rx_add_vid    = qlcnic_vlan_rx_add,
+	.ndo_vlan_rx_kill_vid   = qlcnic_vlan_rx_del,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = qlcnic_poll_controller,
 #endif
 };
 
-static const struct net_device_ops qlcnic_netdev_failed_ops = {
-	.ndo_open	   = qlcnic_open,
-};
-
 static struct qlcnic_nic_template qlcnic_ops = {
-	.config_bridged_mode = qlcnic_82xx_config_bridged_mode,
+	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_82xx_config_led,
-	.start_firmware = qlcnic_82xx_start_firmware
+	.start_firmware = qlcnic_82xx_start_firmware,
+	.request_reset = qlcnic_82xx_dev_request_reset,
+	.cancel_idc_work = qlcnic_82xx_cancel_idc_work,
+	.napi_add = qlcnic_82xx_napi_add,
+	.config_ipaddr = qlcnic_82xx_config_ipaddr,
+	.clear_legacy_intr = qlcnic_82xx_clear_legacy_intr,
 };
 
-static struct qlcnic_nic_template qlcnic_vf_ops = {
+struct qlcnic_nic_template qlcnic_vf_ops = {
 	.config_bridged_mode = qlcnicvf_config_bridged_mode,
 	.config_led = qlcnicvf_config_led,
 	.start_firmware = qlcnicvf_start_firmware
 };
 
-static struct qlcnic_hardware_ops qlcnic_82xx_ops = {
+static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 	.read_crb = qlcnic_82xx_read_crb,
 	.write_crb = qlcnic_82xx_write_crb,
-	.rdreg = qlcnic_hw_read_wx_2M,
-	.wrtreg = qlcnic_hw_write_wx_2M,
-	.get_mac_address = qlcnic_get_mac_address,
-	.setup_intr = qlcnic_setup_intr,
-	.mbx_cmd = qlcnic_issue_cmd,
-	.get_func_no = qlcnic_get_func_no,
+	.rdreg = qlcnic_82xx_hw_read_wx_2M,
+	.wrtreg = qlcnic_82xx_hw_write_wx_2M,
+	.get_mac_address = qlcnic_82xx_get_mac_address,
+	.setup_intr = qlcnic_82xx_setup_intr,
+	.alloc_mbx_args = qlcnic_82xx_alloc_mbx_args,
+	.mbx_cmd = qlcnic_82xx_issue_cmd,
+	.get_func_no = qlcnic_82xx_get_func_no,
+	.api_lock = qlcnic_82xx_api_lock,
+	.api_unlock = qlcnic_82xx_api_unlock,
+	.add_sysfs = qlcnic_82xx_add_sysfs,
+	.remove_sysfs = qlcnic_82xx_remove_sysfs,
+	.process_lb_rcv_ring_diag = qlcnic_82xx_process_rcv_ring_diag,
+	.create_rx_ctx = qlcnic_82xx_fw_cmd_create_rx_ctx,
+	.create_tx_ctx = qlcnic_82xx_fw_cmd_create_tx_ctx,
+	.setup_link_event = qlcnic_82xx_linkevent_request,
+	.get_nic_info = qlcnic_82xx_get_nic_info,
+	.get_pci_info = qlcnic_82xx_get_pci_info,
+	.set_nic_info = qlcnic_82xx_set_nic_info,
+	.change_macvlan = qlcnic_82xx_sre_macaddr_change,
+	.napi_enable = qlcnic_82xx_napi_enable,
+	.napi_disable = qlcnic_82xx_napi_disable,
+	.config_intr_coal = qlcnic_82xx_config_intr_coalesce,
+	.config_rss = qlcnic_82xx_config_rss,
+	.config_hw_lro = qlcnic_82xx_config_hw_lro,
+	.config_loopback = qlcnic_82xx_set_lb_mode,
+	.clear_loopback = qlcnic_82xx_clear_lb_mode,
+	.config_promisc_mode = qlcnic_82xx_nic_set_promisc,
+	.change_l2_filter = qlcnic_82xx_change_filter,
+	.get_board_info = qlcnic_82xx_get_board_info,
 };
 
-static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
+int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int err = -1, i;
@@ -456,24 +495,26 @@ static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
  enable_msix:
 		for (i = 0; i < num_msix; i++)
 			adapter->msix_entries[i].entry = i;
-
 		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
 		if (err == 0) {
 			adapter->flags |= QLCNIC_MSIX_ENABLED;
 			adapter->max_sds_rings = num_msix;
-
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
 			return err;
 		} else if (err > 0) {
+			dev_info(&pdev->dev, "Didn't get %d vectors\n",
+					num_msix);
 			num_msix = rounddown_pow_of_two(err);
 			if (num_msix) {
-				dev_info(&pdev->dev,
-				"Can't get %d vectors,trying %d vectors\n",
-								err, num_msix);
+				dev_info(&pdev->dev, "Trying %d vectors\n",
+					num_msix);
 				goto enable_msix;
 			}
-		}
+		} else
+			dev_info(&pdev->dev, "Failed to get %d vectors\n",
+				num_msix);
 	}
+
 	return err;
 }
 
@@ -502,18 +543,22 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 
 	adapter->crb_int_state_reg = qlcnic_get_ioaddr(adapter->ahw,
 			ISR_INT_STATE_REG);
+
 	dev_info(&pdev->dev, "using legacy interrupts\n");
 	adapter->msix_entries[0].vector = pdev->irq;
 }
 
 int
-qlcnic_setup_intr(struct qlcnic_adapter *adapter)
+qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 {
 	int num_msix, err;
 
+	if (!num_intr)
+		num_intr = QLCNIC_DEF_NUM_STS_DESC_RINGS;
+
 	if (adapter->ahw->msix_supported)
 		num_msix = rounddown_pow_of_two(min_t(int, num_online_cpus(),
-				QLCNIC_DEF_NUM_STS_DESC_RINGS));
+				num_intr));
 	else
 		num_msix = 1;
 
@@ -532,6 +577,13 @@ qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 		pci_disable_msix(adapter->pdev);
 	if (adapter->flags & QLCNIC_MSI_ENABLED)
 		pci_disable_msi(adapter->pdev);
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
+
+	if (adapter->ahw->intr_tbl) {
+		vfree(adapter->ahw->intr_tbl);
+		adapter->ahw->intr_tbl = NULL;
+	}
 }
 
 static void
@@ -541,19 +593,26 @@ qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
 		iounmap(ahw->pci_base0);
 }
 
-static int
+int
 qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_pci_info *pci_info;
-	int i, ret = 0;
+	int i, ret = 0, j = 0;
+	u16 act_pci_func;
 	u8 pfn;
 
 	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
 	if (!pci_info)
 		return -ENOMEM;
 
+	ret = qlcnic_get_pci_info(adapter, pci_info);
+	if (ret)
+		goto err_pci_info;
+
+	act_pci_func = adapter->ahw->act_pci_func;
+
 	adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
-				QLCNIC_MAX_PCI_FUNC, GFP_KERNEL);
+				act_pci_func, GFP_KERNEL);
 	if (!adapter->npars) {
 		ret = -ENOMEM;
 		goto err_pci_info;
@@ -566,21 +625,25 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		goto err_npars;
 	}
 
-	ret = qlcnic_get_pci_info(adapter, pci_info);
-	if (ret)
-		goto err_eswitch;
-
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
 		pfn = pci_info[i].id;
-		if (pfn >= QLCNIC_MAX_PCI_FUNC) {
+
+		if (pfn > QLCNIC_MAX_PCI_FUNC) {
 			ret = QL_STATUS_INVALID_PARAM;
 			goto err_eswitch;
 		}
-		adapter->npars[pfn].active = (u8)pci_info[i].active;
-		adapter->npars[pfn].type = (u8)pci_info[i].type;
-		adapter->npars[pfn].phy_port = (u8)pci_info[i].default_port;
-		adapter->npars[pfn].min_bw = pci_info[i].tx_min_bw;
-		adapter->npars[pfn].max_bw = pci_info[i].tx_max_bw;
+
+		if (!pci_info[i].active ||
+				(pci_info[i].type != QLCNIC_TYPE_NIC))
+			continue;
+
+		adapter->npars[j].pci_func = pfn;
+		adapter->npars[j].active = (u8)pci_info[i].active;
+		adapter->npars[j].type = (u8)pci_info[i].type;
+		adapter->npars[j].phy_port = (u8)pci_info[i].default_port;
+		adapter->npars[j].min_bw = pci_info[i].tx_min_bw;
+		adapter->npars[j].max_bw = pci_info[i].tx_max_bw;
+		j++;
 	}
 
 	for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
@@ -608,52 +671,49 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 	u32 ref_count;
 	int i, ret = 1;
 	u32 data = QLCNIC_MGMT_FUNC;
-	void __iomem *priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	/* If other drivers are not in use set their privilege level */
-	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	ref_count = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	ret = qlcnic_api_lock(adapter);
 	if (ret)
 		goto err_lock;
 
 	if (qlcnic_config_npars) {
-		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-			id = i;
-			if (adapter->npars[i].type != QLCNIC_TYPE_NIC ||
-				id == adapter->ahw->pci_func)
+		for (i = 0; i < ahw->act_pci_func; i++) {
+			id = adapter->npars[i].pci_func;
+			if (id == ahw->pci_func)
 				continue;
 			data |= (qlcnic_config_npars &
 					QLC_DEV_SET_DRV(0xf, id));
 		}
 	} else {
-		data = readl(priv_op);
-		data = (data & ~QLC_DEV_SET_DRV(0xf, adapter->ahw->pci_func)) |
+		data = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
+		data = (data & ~QLC_DEV_SET_DRV(0xf, ahw->pci_func)) |
 			(QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC,
-			adapter->ahw->pci_func));
+			ahw->pci_func));
 	}
-	writel(data, priv_op);
+	QLCWR(adapter, QLCNIC_DRV_OP_MODE, data);
 	qlcnic_api_unlock(adapter);
 err_lock:
 	return ret;
 }
 
 static void
-qlcnic_check_vf(struct qlcnic_adapter *adapter)
+qlcnic_check_vf(struct qlcnic_adapter *adapter, const struct pci_device_id *ent)
 {
 	void __iomem *priv_op;
 	u32 op_mode, priv_level;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	/* Determine FW API version */
-	ahw->fw_hal_version = readl(adapter->ahw->pci_base0 +
-					QLCNIC_FW_API);
-
+	ahw->fw_hal_version = QLCRD(adapter, QLCNIC_FW_API);
 	/* Find PCI function number */
-	ahw->hw_ops->get_func_no(adapter);
+	qlcnic_get_func_no(adapter);
 
 	/* Determine function privilege level */
 	priv_op = ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
-	op_mode = readl(priv_op);
+	op_mode = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
@@ -665,8 +725,9 @@ qlcnic_check_vf(struct qlcnic_adapter *adapter)
 			"HAL Version: %d Non Privileged function\n",
 			ahw->fw_hal_version);
 		adapter->nic_ops = &qlcnic_vf_ops;
-	} else
+	} else {
 		adapter->nic_ops = &qlcnic_ops;
+	}
 }
 
 static int
@@ -682,7 +743,7 @@ qlcnic_setup_pci_map(struct pci_dev *pdev,
 	mem_len = pci_resource_len(pdev, 0);
 
 	QLCNIC_BAR_LENGTH(pdev->device, &bar0_len);
-	if (mem_len == bar0_len) {
+	if (mem_len >= bar0_len) {
 
 		mem_ptr0 = pci_ioremap_bar(pdev, 0);
 		if (mem_ptr0 == NULL) {
@@ -693,7 +754,6 @@ qlcnic_setup_pci_map(struct pci_dev *pdev,
 	} else {
 		return -EIO;
 	}
-
 	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
 	ahw->pci_base0 = mem_ptr0;
@@ -731,6 +791,7 @@ static void qlcnic_get_brd_name(struct qlcnic_adapter *adapter, char *name)
 static void
 qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 fw_major, fw_minor, fw_build, prev_fw_version;
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -738,12 +799,17 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	prev_fw_version = adapter->fw_version;
 
-	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
-	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
-	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
+	fw_major = QLCRD(adapter, QLCNIC_FW_VERSION_MAJOR);
+	fw_minor = QLCRD(adapter, QLCNIC_FW_VERSION_MINOR);
+	fw_build = QLCRD(adapter, QLCNIC_FW_VERSION_SUB);
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
+	err = qlcnic_get_board_info(adapter);
+	if (err) {
+		dev_err(&pdev->dev, "Error getting board config info.\n");
+		return;
+	}
 	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
 		if (fw_dump->tmpl_hdr == NULL ||
 				adapter->fw_version > prev_fw_version) {
@@ -785,20 +851,21 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 {
 	int err;
 	struct qlcnic_info nic_info;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	err = qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw->pci_func);
+	err = qlcnic_get_nic_info(adapter, &nic_info, ahw->pci_func);
 	if (err)
 		return err;
 
-	adapter->ahw->physical_port = (u8)nic_info.phys_port;
-	adapter->ahw->switch_mode = nic_info.switch_mode;
-	adapter->ahw->max_tx_ques = nic_info.max_tx_ques;
-	adapter->ahw->max_rx_ques = nic_info.max_rx_ques;
-	adapter->ahw->capabilities = nic_info.capabilities;
-	adapter->ahw->max_mac_filters = nic_info.max_mac_filters;
-	adapter->ahw->max_mtu = nic_info.max_mtu;
+	ahw->physical_port = (u8) nic_info.phys_port;
+	ahw->switch_mode = nic_info.switch_mode;
+	ahw->max_tx_ques = nic_info.max_tx_ques;
+	ahw->max_rx_ques = nic_info.max_rx_ques;
+	ahw->capabilities = nic_info.capabilities;
+	ahw->max_mac_filters = nic_info.max_mac_filters;
+	ahw->max_mtu = nic_info.max_mtu;
 
-	if (adapter->ahw->capabilities & BIT_6)
+	if (ahw->capabilities & BIT_6)
 		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
 	else
 		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
@@ -806,7 +873,7 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static void
+void
 qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
@@ -821,8 +888,7 @@ qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
 		adapter->pvid = 0;
 }
 
-static void
-qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
+void qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	adapter->flags &= ~(QLCNIC_MACSPOOF | QLCNIC_MAC_OVERRIDE_DISABLED |
@@ -840,8 +906,7 @@ qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 	qlcnic_set_netdev_features(adapter, esw_cfg);
 }
 
-static int
-qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
+int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_esw_func_cfg esw_cfg;
 
@@ -862,14 +927,14 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	struct net_device *netdev = adapter->netdev;
-	netdev_features_t features, vlan_features;
+	unsigned long features, vlan_features;
 
-	features = (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+	features = (NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
 	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
-			NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);
+			NETIF_F_IPV6_CSUM);
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
+	if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
 		features |= (NETIF_F_TSO | NETIF_F_TSO6);
 		vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
 	}
@@ -879,12 +944,14 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 
 	if (esw_cfg->offload_flags & BIT_0) {
 		netdev->features |= features;
+		adapter->rx_csum = 1;
 		if (!(esw_cfg->offload_flags & BIT_1))
 			netdev->features &= ~NETIF_F_TSO;
 		if (!(esw_cfg->offload_flags & BIT_2))
 			netdev->features &= ~NETIF_F_TSO6;
 	} else {
 		netdev->features &= ~features;
+		adapter->rx_csum = 0;
 	}
 
 	netdev->vlan_features = (features & vlan_features);
@@ -906,7 +973,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 		return 0;
 
 	priv_op = ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
-	op_mode = readl(priv_op);
+	op_mode = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
 	priv_level = QLC_DEV_GET_DRV(op_mode, ahw->pci_func);
 
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
@@ -938,7 +1005,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static int
+int
 qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_esw_func_cfg esw_cfg;
@@ -948,16 +1015,16 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 	if (adapter->need_fw_reset)
 		return 0;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		memset(&esw_cfg, 0, sizeof(struct qlcnic_esw_func_cfg));
-		esw_cfg.pci_func = i;
-		esw_cfg.offload_flags = BIT_0;
+		esw_cfg.pci_func = adapter->npars[i].pci_func;
 		esw_cfg.mac_override = BIT_0;
 		esw_cfg.promisc_mode = BIT_0;
-		if (adapter->ahw->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
-			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		if (QLCNIC_IS_82XX(adapter)) {
+			esw_cfg.offload_flags = BIT_0;
+			if (QLCNIC_IS_TSO_CAPABLE(adapter))
+				esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		}
 		if (qlcnic_config_switch_port(adapter, &esw_cfg))
 			return -EIO;
 		npar = &adapter->npars[i];
@@ -972,6 +1039,7 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+
 static int
 qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 			struct qlcnic_npar_info *npar, int pci_func)
@@ -995,22 +1063,24 @@ qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int
+int
 qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 {
 	int i, err;
 	struct qlcnic_npar_info *npar;
 	struct qlcnic_info nic_info;
+	u8 pci_func;
 
-	if (!adapter->need_fw_reset)
-		return 0;
+	if (QLCNIC_IS_82XX(adapter))
+		if (!adapter->need_fw_reset)
+			return 0;
 
 	/* Set the NPAR config data after FW reset */
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		npar = &adapter->npars[i];
-		if (npar->type != QLCNIC_TYPE_NIC)
-			continue;
-		err = qlcnic_get_nic_info(adapter, &nic_info, i);
+		pci_func = npar->pci_func;
+		err = qlcnic_get_nic_info(adapter,
+						&nic_info, pci_func);
 		if (err)
 			return err;
 		nic_info.min_tx_bw = npar->min_bw;
@@ -1021,11 +1091,11 @@ qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 
 		if (npar->enable_pm) {
 			err = qlcnic_config_port_mirroring(adapter,
-							npar->dest_npar, 1, i);
+						npar->dest_npar, 1, pci_func);
 			if (err)
 				return err;
 		}
-		err = qlcnic_reset_eswitch_config(adapter, npar, i);
+		err = qlcnic_reset_eswitch_config(adapter, npar, pci_func);
 		if (err)
 			return err;
 	}
@@ -1040,10 +1110,10 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
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
@@ -1116,9 +1186,8 @@ check_fw_status:
 	if (err)
 		goto err_out;
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
+	QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
-
 	err = qlcnic_check_eswitch_mode(adapter);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
@@ -1136,7 +1205,7 @@ check_fw_status:
 	return 0;
 
 err_out:
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+	QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
 	dev_err(&adapter->pdev->dev, "Device state set to failed\n");
 
 	qlcnic_release_firmware(adapter);
@@ -1155,7 +1224,8 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
-		handler = qlcnic_tmp_intr;
+		if (QLCNIC_IS_82XX(adapter))
+			handler = qlcnic_tmp_intr;
 		if (!QLCNIC_IS_MSI_FAMILY(adapter))
 			flags |= IRQF_SHARED;
 
@@ -1171,15 +1241,17 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	}
 	adapter->irq = netdev->irq;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		sprintf(sds_ring->name, "%s[%d]", netdev->name, ring);
-		err = request_irq(sds_ring->irq, handler,
-				  flags, sds_ring->name, sds_ring);
-		if (err)
-			return err;
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &recv_ctx->sds_rings[ring];
+			sprintf(sds_ring->name, "%s[%d]",
+						netdev->name, ring);
+			err = request_irq(sds_ring->irq, handler, flags,
+					sds_ring->name, sds_ring);
+			if (err)
+				return err;
+		}
 	}
-
 	return 0;
 }
 
@@ -1191,46 +1263,42 @@ qlcnic_free_irq(struct qlcnic_adapter *adapter)
 
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		free_irq(sds_ring->irq, sds_ring);
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &recv_ctx->sds_rings[ring];
+			free_irq(sds_ring->irq, sds_ring);
+		}
 	}
 }
 
 static int
 __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
-	int ring;
-	u32 capab2;
-
+	u8 ring;
 	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
 		return -EIO;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return 0;
+
 	if (qlcnic_set_eswitch_port_config(adapter))
 		return -EIO;
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
-		capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
-		if (capab2 & QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG)
-			adapter->flags |= QLCNIC_FW_LRO_MSS_CAP;
-	}
-
 	if (qlcnic_fw_create_ctx(adapter))
 		return -EIO;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &adapter->recv_ctx->rds_rings[ring];
-		qlcnic_post_rx_buffers(adapter, rds_ring);
+		qlcnic_post_rx_buffers(adapter, rds_ring, ring);
 	}
 
 	qlcnic_set_multi(netdev);
 	qlcnic_fw_cmd_set_mtu(adapter, netdev->mtu);
 
-	adapter->ahw->linkup = 0;
+	ahw->linkup = 0;
 
 	if (adapter->max_sds_rings > 1)
 		qlcnic_config_rss(adapter, 1);
@@ -1242,16 +1310,16 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	qlcnic_napi_enable(adapter);
 
-	qlcnic_linkevent_request(adapter, 1);
-
-	adapter->ahw->reset_context = 0;
+	ahw->reset_context = 0;
 	set_bit(__QLCNIC_DEV_UP, &adapter->state);
+
+	qlcnic_linkevent_request(adapter, 1);
 	return 0;
 }
 
 /* Usage: During resume and firmware recovery module.*/
 
-static int
+int
 qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	int err = 0;
@@ -1283,12 +1351,12 @@ __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (adapter->fhash.fnum)
 		qlcnic_delete_lb_filters(adapter);
 
-	qlcnic_nic_set_promisc(adapter, QLCNIC_NIU_NON_PROMISC_MODE);
+	qlcnic_nic_set_promisc(adapter,
+		QLCNIC_NIU_NON_PROMISC_MODE);
 
 	qlcnic_napi_disable(adapter);
 
 	qlcnic_fw_destroy_ctx(adapter);
-	adapter->flags &= ~QLCNIC_FW_LRO_MSS_CAP;
 
 	qlcnic_reset_rx_buffers_list(adapter);
 	qlcnic_release_tx_buffers(adapter);
@@ -1297,22 +1365,21 @@ __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 /* Usage: During suspend and firmware recovery module */
 
-static void
+void
 qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	rtnl_lock();
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
 	rtnl_unlock();
-
 }
 
-static int
+int
 qlcnic_attach(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-	int err;
+	int err = -1;
 
 	if (adapter->is_up == QLCNIC_ADAPTER_UP_MAGIC)
 		return 0;
@@ -1353,7 +1420,7 @@ err_out_napi_del:
 	return err;
 }
 
-static void
+void
 qlcnic_detach(struct qlcnic_adapter *adapter)
 {
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
@@ -1430,6 +1497,8 @@ static void qlcnic_free_adapter_resources(struct qlcnic_adapter *adapter)
 		vfree(adapter->ahw->fw_dump.tmpl_hdr);
 		adapter->ahw->fw_dump.tmpl_hdr = NULL;
 	}
+
+	adapter->ahw->fw_dump.tmpl_hdr = NULL;
 }
 
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
@@ -1437,7 +1506,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_host_rds_ring *rds_ring;
-	int ring;
+	u8 ring;
 	int ret;
 
 	netif_device_detach(netdev);
@@ -1465,13 +1534,16 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &adapter->recv_ctx->rds_rings[ring];
-		qlcnic_post_rx_buffers(adapter, rds_ring);
+		qlcnic_post_rx_buffers(adapter, rds_ring, ring);
 	}
 
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
-			QLCNIC_ENABLE_INTR(adapter, sds_ring->crb_intr_mask);
+			if (QLCNIC_IS_82XX(adapter)) {
+				QLCNIC_ENABLE_INTR(adapter,
+					sds_ring->crb_intr_mask);
+			}
 		}
 	}
 
@@ -1503,6 +1575,7 @@ qlcnic_reset_hw_context(struct qlcnic_adapter *adapter)
 	netif_device_attach(netdev);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	dev_err(&adapter->pdev->dev, "%s:\n", __func__);
 	return 0;
 }
 
@@ -1546,33 +1619,37 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	int err;
 	struct pci_dev *pdev = adapter->pdev;
 
+	adapter->rx_csum = 1;
 	adapter->ahw->mc_enabled = 0;
 	adapter->ahw->max_mc_count = QLCNIC_MAX_MC_COUNT;
 
 	netdev->netdev_ops	   = &qlcnic_netdev_ops;
-	netdev->watchdog_timeo     = QLCNIC_WATCHDOG_TIMEOUTVALUE*HZ;
+	netdev->watchdog_timeo     = QLCNIC_WATCHDOG_TIMEOUTVALUE * HZ;
 
 	qlcnic_change_mtu(netdev, netdev->mtu);
 
 	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);
 
-	netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
+	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
+		NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_HW_VLAN_RX);
+	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
+		NETIF_F_IPV6_CSUM);
+
+	if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
+		netdev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
+		netdev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
+	}
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
-		netdev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
-	if (pci_using_dac)
-		netdev->hw_features |= NETIF_F_HIGHDMA;
+	if (pci_using_dac) {
+		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
-	netdev->vlan_features = netdev->hw_features;
+	if (QLCNIC_IS_VLAN_TX_CAPABLE(adapter))
+		netdev->features |= (NETIF_F_HW_VLAN_TX);
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX)
-		netdev->hw_features |= NETIF_F_HW_VLAN_TX;
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
-		netdev->hw_features |= NETIF_F_LRO;
-
-	netdev->features |= netdev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+		netdev->features |= NETIF_F_LRO;
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
@@ -1601,6 +1678,17 @@ static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
 	return 0;
 }
 
+int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
+{
+	int i;
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		if (adapter->npars[i].pci_func == pci_func)
+			return i;
+	}
+
+	return -1;
+}
+
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1635,10 +1723,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!ahw)
 		goto err_out_free_res;
 
-	if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE824X)
-		ahw->hw_ops = &qlcnic_82xx_ops;
-	else
-		goto err_out_free_hw_res;
+	if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE824X) {
+		ahw->hw_ops = &qlcnic_hw_ops;
+		ahw->reg_tbl = (u32 *) qlcnic_reg_tbl;
+	}
 
 	err = qlcnic_setup_pci_map(pdev, ahw);
 	if (err)
@@ -1663,6 +1751,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->dev_rst_time = jiffies;
 	adapter->ahw->revision_id = pdev->revision;
 	adapter->mac_learn = qlcnic_mac_learn;
+	adapter->max_drv_tx_rings = 1;
 
 	rwlock_init(&adapter->ahw->crb_lock);
 	mutex_init(&adapter->ahw->mem_lock);
@@ -1670,28 +1759,21 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
 
-	qlcnic_check_vf(adapter);
-
-	/* This will be reset for mezz cards  */
-	adapter->portnum = adapter->ahw->pci_func;
-
-	err = qlcnic_get_board_info(adapter);
-	if (err) {
-		dev_err(&pdev->dev, "Error getting board config info.\n");
-		goto err_out_free_hw;
-	}
-
-	err = qlcnic_setup_idc_param(adapter);
-	if (err)
-		goto err_out_free_hw;
+	/* hilda workaorund */
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
 
-	err = qlcnic_start_firmware(adapter);
-	if (err) {
-		dev_err(&pdev->dev, "Loading fw failed. Please Reboot\n"
-			"\t\tIf reboot doesn't help, try flashing the card\n");
-		goto err_out_maintenance_mode;
+		adapter->flags |= QLCNIC_NEED_FLR;
 	}
 
 	if (qlcnic_read_mac_addr(adapter))
@@ -1704,18 +1786,21 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				module_name(THIS_MODULE),
 				brd_name, adapter->ahw->revision_id);
 	}
+	err = qlcnic_setup_intr(adapter, 0);
+	if (err)
+		goto err_out_disable_msi;
 
-	err = qlcnic_setup_intr(adapter);
-	if (err == -ENOMEM)
-		goto err_out_decr_ref;
 
 	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
 	if (err)
-		goto err_out_disable_msi;
+		goto err_out_disable_mbx_intr;
 
 	pci_set_drvdata(pdev, adapter);
 
-	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
+	if (QLCNIC_IS_82XX(adapter)) {
+		qlcnic_schedule_work(adapter,
+			qlcnic_fw_poll_work, FW_POLL_DELAY);
+	}
 
 	switch (adapter->ahw->port_type) {
 	case QLCNIC_GBE:
@@ -1731,15 +1816,15 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
 
 err_out_free_hw:
@@ -1761,18 +1846,6 @@ err_out_disable_pdev:
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
@@ -1787,28 +1860,27 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 
 	netdev = adapter->netdev;
 	ahw = adapter->ahw;
-
-	qlcnic_cancel_fw_work(adapter);
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
 
 	qlcnic_cleanup_pci_map(ahw);
 
@@ -1830,13 +1902,13 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	int retval;
 
 	netif_device_detach(netdev);
-
-	qlcnic_cancel_fw_work(adapter);
+	qlcnic_cancel_idc_work(adapter);
 
 	if (netif_running(netdev))
 		qlcnic_down(adapter, netdev);
 
-	qlcnic_clr_all_drv_state(adapter, 0);
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
@@ -1844,9 +1916,11 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	if (retval)
 		return retval;
 
-	if (qlcnic_wol_supported(adapter)) {
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
+	if (QLCNIC_IS_82XX(adapter)) {
+		if (qlcnic_wol_supported(adapter)) {
+			pci_enable_wake(pdev, PCI_D3cold, 1);
+			pci_enable_wake(pdev, PCI_D3hot, 1);
+		}
 	}
 
 	return 0;
@@ -1912,16 +1986,9 @@ done:
 static int qlcnic_open(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 	int err;
 
-	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD)) {
-		netdev_err(netdev, "Device in FAILED state\n");
-		return -EIO;
-	}
-
 	netif_carrier_off(netdev);
-
 	err = qlcnic_attach(adapter);
 	if (err)
 		return err;
@@ -1981,13 +2048,16 @@ static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
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
@@ -2047,7 +2117,7 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
 	return stats;
 }
 
-static irqreturn_t qlcnic_clear_legacy_intr(struct qlcnic_adapter *adapter)
+irqreturn_t qlcnic_82xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
 {
 	u32 status;
 
@@ -2149,7 +2219,7 @@ qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding)
 	val |= encoding << 7;
 	val |= (jiffies - adapter->dev_rst_time) << 8;
 
-	QLCWR32(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
 	adapter->dev_rst_time = jiffies;
 }
 
@@ -2164,14 +2234,14 @@ qlcnic_set_drv_state(struct qlcnic_adapter *adapter, u8 state)
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
 
@@ -2186,9 +2256,9 @@ qlcnic_clr_drv_state(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -EBUSY;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
 
@@ -2203,20 +2273,20 @@ qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8 failed)
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
@@ -2233,8 +2303,8 @@ qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 	int act, state, active_mask;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-	act = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	state = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
+	act = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 
 	if (adapter->flags & QLCNIC_FW_RESET_OWNER) {
 		active_mask = (~(1 << (ahw->pci_func * 4)));
@@ -2250,7 +2320,7 @@ qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 
 static int qlcnic_check_idc_ver(struct qlcnic_adapter *adapter)
 {
-	u32 val = QLCRD32(adapter, QLCNIC_CRB_DRV_IDC_VER);
+	u32 val = QLCRD(adapter, QLCNIC_CRB_DRV_IDC_VER);
 
 	if (val != QLCNIC_DRV_IDC_VER) {
 		dev_warn(&adapter->pdev->dev, "IDC Version mismatch, driver's"
@@ -2274,19 +2344,19 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
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
@@ -2297,15 +2367,15 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
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
@@ -2322,7 +2392,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 
 	do {
 		msleep(1000);
-		prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		prev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 		if (prev_state == QLCNIC_DEV_QUISCENT)
 			continue;
@@ -2337,9 +2407,9 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -1;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	ret = qlcnic_check_idc_ver(adapter);
 	qlcnic_api_unlock(adapter);
@@ -2354,12 +2424,11 @@ qlcnic_fwinit_work(struct work_struct *work)
 			struct qlcnic_adapter, fw_work.work);
 	u32 dev_state = 0xf;
 	u32 val;
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	if (qlcnic_api_lock(adapter))
 		goto err_ret;
 
-	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	if (dev_state == QLCNIC_DEV_QUISCENT ||
 	    dev_state == QLCNIC_DEV_NEED_QUISCENT) {
 		qlcnic_api_unlock(adapter);
@@ -2388,28 +2457,21 @@ qlcnic_fwinit_work(struct work_struct *work)
 
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
-		if (ahw->fw_dump.enable &&
-		    (adapter->flags & QLCNIC_FW_RESET_OWNER)) {
-			QLCDB(adapter, DRV, "Take FW dump\n");
-			adapter->flags |= QLCNIC_FW_HANG;
-		}
-		rtnl_unlock();
 
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		if (!qlcnic_start_firmware(adapter)) {
@@ -2423,7 +2485,7 @@ skip_ack_check:
 	qlcnic_api_unlock(adapter);
 
 wait_npar:
-	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
 
 	switch (dev_state) {
@@ -2465,7 +2527,7 @@ qlcnic_detach_work(struct work_struct *work)
 	} else
 		qlcnic_down(adapter, netdev);
 
-	status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
+	status = QLCRD(adapter, QLCNIC_PEG_HALT_STATUS1);
 
 	if (status & QLCNIC_RCODE_FATAL_ERROR) {
 		dev_err(&adapter->pdev->dev,
@@ -2516,19 +2578,19 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
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
 
@@ -2540,28 +2602,23 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 	qlcnic_gb_set_gb2_mask(gb_val);
 	qlcnic_gb_set_gb3_mask(gb_val);
 	QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, gb_val);
-	dev_info(&adapter->pdev->dev, "Pause control frames disabled"
-				" on all ports\n");
+	dev_info(&adapter->pdev->dev,
+			"Pause control frames disabled on all ports\n");
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
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
 		QLCNIC_DEV_NPAR_NON_OPER);
 	qlcnic_api_unlock(adapter);
 }
@@ -2573,13 +2630,13 @@ qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return;
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
 	QLCDB(adapter, DRV, "NPAR operational state set\n");
 
 	qlcnic_api_unlock(adapter);
 }
 
-static void
+void
 qlcnic_schedule_work(struct qlcnic_adapter *adapter,
 		work_func_t func, int delay)
 {
@@ -2588,19 +2645,7 @@ qlcnic_schedule_work(struct qlcnic_adapter *adapter,
 
 	INIT_DELAYED_WORK(&adapter->fw_work, func);
 	queue_delayed_work(qlcnic_wq, &adapter->fw_work,
-					round_jiffies_relative(delay));
-}
-
-static void
-qlcnic_cancel_fw_work(struct qlcnic_adapter *adapter)
-{
-	while (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		msleep(10);
-
-	if (!adapter->fw_work.work.func)
-		return;
-
-	cancel_delayed_work_sync(&adapter->fw_work);
+				round_jiffies_relative(delay));
 }
 
 static void
@@ -2612,7 +2657,7 @@ qlcnic_attach_work(struct work_struct *work)
 	u32 npar_state;
 
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 		if (adapter->fw_wait_cnt++ > QLCNIC_DEV_NPAR_OPER_TIMEO)
 			qlcnic_clr_all_drv_state(adapter, 0);
 		else if (npar_state != QLCNIC_DEV_NPAR_OPER)
@@ -2645,6 +2690,7 @@ done:
 static int
 qlcnic_check_health(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 state = 0, heartbeat;
 	u32 peg_status;
 
@@ -2652,16 +2698,16 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
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
@@ -2681,25 +2727,25 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 
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
@@ -2738,6 +2784,19 @@ reschedule:
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 }
 
+struct pci_dev *pci_get_domain_bus_and_slot(int domain, unsigned int bus,
+					    unsigned int devfn)
+{
+	struct pci_dev *dev = NULL;
+
+	while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
+		if (pci_domain_nr(dev->bus) == domain &&
+		    (dev->bus->number == bus && dev->devfn == devfn))
+			return dev;
+	}
+	return NULL;
+}
+
 static int qlcnic_is_first_func(struct pci_dev *pdev)
 {
 	struct pci_dev *oth_pdev;
@@ -2763,8 +2822,8 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 {
 	int err, first_func;
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	pdev->error_state = pci_channel_io_normal;
 
@@ -2784,7 +2843,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
 		adapter->need_fw_reset = 1;
 		set_bit(__QLCNIC_START_FW, &adapter->state);
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
 		QLCDB(adapter, DRV, "Restarting fw\n");
 	}
 	qlcnic_api_unlock(adapter);
@@ -2796,7 +2855,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	qlcnic_clr_drv_state(adapter);
 	kfree(adapter->msix_entries);
 	adapter->msix_entries = NULL;
-	err = qlcnic_setup_intr(adapter);
+	err = qlcnic_setup_intr(adapter, 0);
 
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
@@ -2861,7 +2920,7 @@ static void qlcnic_io_resume(struct pci_dev *pdev)
 
 	pci_cleanup_aer_uncorrect_error_status(pdev);
 
-	if (QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) == QLCNIC_DEV_READY &&
+	if (QLCRD(adapter, QLCNIC_CRB_DEV_STATE) == QLCNIC_DEV_READY &&
 	    test_and_clear_bit(__QLCNIC_AER, &adapter->state))
 		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
 						FW_POLL_DELAY);
@@ -2921,7 +2980,7 @@ qlcnic_store_bridged_mode(struct device *dev,
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		goto err_out;
 
-	if (strict_strtoul(buf, 2, &new))
+	if (kstrtoul(buf, 2, &new))
 		goto err_out;
 
 	if (!qlcnic_config_bridged_mode(adapter, !!new))
@@ -2945,9 +3004,9 @@ qlcnic_show_bridged_mode(struct device *dev,
 }
 
 static struct device_attribute dev_attr_bridged_mode = {
-       .attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
-       .show = qlcnic_show_bridged_mode,
-       .store = qlcnic_store_bridged_mode,
+	.attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
+	.show = qlcnic_show_bridged_mode,
+	.store = qlcnic_store_bridged_mode,
 };
 
 static ssize_t
@@ -2957,7 +3016,7 @@ qlcnic_store_diag_mode(struct device *dev,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	unsigned long new;
 
-	if (strict_strtoul(buf, 2, &new))
+	if (kstrtoul(buf, 2, &new))
 		return -EINVAL;
 
 	if (!!new != !!(adapter->flags & QLCNIC_DIAG_ENABLED))
@@ -3011,13 +3070,10 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
 		__qlcnic_down(adapter, netdev);
 	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
-	kfree(adapter->msix_entries);
-	adapter->msix_entries = NULL;
 
-	if (qlcnic_enable_msix(adapter, data)) {
+	err = qlcnic_setup_intr(adapter, data);
+	if (err)
 		netdev_info(netdev, "failed setting max_rss; rss disabled\n");
-		qlcnic_enable_msi_legacy(adapter);
-	}
 
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
@@ -3061,16 +3117,11 @@ qlcnic_store_beacon(struct device *dev,
 {
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int max_sds_rings = adapter->max_sds_rings;
+	int dev_down = 0;
 	u16 beacon;
 	u8 b_state, b_rate;
 	int err;
 
-	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		dev_warn(dev, "LED test not supported for non "
-				"privilege function\n");
-		return -EOPNOTSUPP;
-	}
-
 	if (len != sizeof(u16))
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3082,40 +3133,36 @@ qlcnic_store_beacon(struct device *dev,
 	if (adapter->ahw->beacon_state == b_state)
 		return len;
 
-	rtnl_lock();
-
 	if (!adapter->ahw->beacon_state)
-		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state)) {
-			rtnl_unlock();
+		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state))
 			return -EBUSY;
-		}
-
-	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
-		err = -EIO;
-		goto out;
-	}
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+		if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+			return -EIO;
 		err = qlcnic_diag_alloc_res(adapter->netdev, QLCNIC_LED_TEST);
-		if (err)
-			goto out;
-		set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
+		if (err) {
+			clear_bit(__QLCNIC_RESETTING, &adapter->state);
+			clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
+			return err;
+		}
+		dev_down = 1;
 	}
 
 	err = qlcnic_config_led(adapter, b_state, b_rate);
 
 	if (!err) {
-		err = len;
 		adapter->ahw->beacon_state = b_state;
+		err = len;
 	}
 
-	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state))
+	if (dev_down) {
 		qlcnic_diag_free_res(adapter->netdev, max_sds_rings);
+		clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	}
 
- out:
-	if (!adapter->ahw->beacon_state)
+	if (!b_state)
 		clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
-	rtnl_unlock();
 
 	return err;
 }
@@ -3136,79 +3183,6 @@ static struct device_attribute dev_attr_beacon = {
 };
 
 static int
-qlcnic_sysfs_validate_crb(struct qlcnic_adapter *adapter,
-		loff_t offset, size_t size)
-{
-	size_t crb_size = 4;
-
-	if (!(adapter->flags & QLCNIC_DIAG_ENABLED))
-		return -EIO;
-
-	if (offset < QLCNIC_PCI_CRBSPACE) {
-		if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM,
-					QLCNIC_PCI_CAMQM_END))
-			crb_size = 8;
-		else
-			return -EINVAL;
-	}
-
-	if ((size != crb_size) || (offset & (crb_size-1)))
-		return  -EINVAL;
-
-	return 0;
-}
-
-static ssize_t
-qlcnic_sysfs_read_crb(struct file *filp, struct kobject *kobj,
-		struct bin_attribute *attr,
-		char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u32 data;
-	u64 qmdata;
-	int ret;
-
-	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
-	if (ret != 0)
-		return ret;
-
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
-		memcpy(buf, &qmdata, size);
-	} else {
-		data = QLCRD32(adapter, offset);
-		memcpy(buf, &data, size);
-	}
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_write_crb(struct file *filp, struct kobject *kobj,
-		struct bin_attribute *attr,
-		char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u32 data;
-	u64 qmdata;
-	int ret;
-
-	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
-	if (ret != 0)
-		return ret;
-
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		memcpy(&qmdata, buf, size);
-		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
-	} else {
-		memcpy(&data, buf, size);
-		QLCWR32(adapter, offset, data);
-	}
-	return size;
-}
-
-static int
 qlcnic_sysfs_validate_mem(struct qlcnic_adapter *adapter,
 		loff_t offset, size_t size)
 {
@@ -3265,13 +3239,6 @@ qlcnic_sysfs_write_mem(struct file *filp, struct kobject *kobj,
 	return size;
 }
 
-static struct bin_attribute bin_attr_crb = {
-	.attr = {.name = "crb", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_read_crb,
-	.write = qlcnic_sysfs_write_crb,
-};
-
 static struct bin_attribute bin_attr_mem = {
 	.attr = {.name = "mem", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
@@ -3800,22 +3767,24 @@ static struct bin_attribute bin_attr_pm_config = {
 	.write = qlcnic_sysfs_write_pm_config,
 };
 
-static void
+void
 qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
+	qlcnic_create_diag_entries(adapter);
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		if (device_create_file(dev, &dev_attr_bridged_mode))
 			dev_warn(dev,
 				"failed to create bridged_mode sysfs entry\n");
 }
 
-static void
+void
 qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
+	qlcnic_remove_diag_entries(adapter);
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		device_remove_file(dev, &dev_attr_bridged_mode);
 }
@@ -3824,7 +3793,6 @@ static void
 qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
 		dev_info(dev, "failed to create port stats sysfs entry");
@@ -3833,14 +3801,9 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 		return;
 	if (device_create_file(dev, &dev_attr_diag_mode))
 		dev_info(dev, "failed to create diag_mode sysfs entry\n");
-	if (device_create_bin_file(dev, &bin_attr_crb))
-		dev_info(dev, "failed to create crb sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_mem))
 		dev_info(dev, "failed to create mem sysfs entry\n");
 
-	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
-		return;
-
 	if (device_create_bin_file(dev, &bin_attr_pci_config))
 		dev_info(dev, "failed to create pci config sysfs entry");
 	if (device_create_file(dev, &dev_attr_beacon))
@@ -3864,17 +3827,13 @@ static void
 qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 
 	device_remove_bin_file(dev, &bin_attr_port_stats);
 
 	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	device_remove_file(dev, &dev_attr_diag_mode);
-	device_remove_bin_file(dev, &bin_attr_crb);
 	device_remove_bin_file(dev, &bin_attr_mem);
-	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
-		return;
 	device_remove_bin_file(dev, &bin_attr_pci_config);
 	device_remove_file(dev, &dev_attr_beacon);
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
@@ -3887,6 +3846,18 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
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
@@ -3919,7 +3890,7 @@ qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
 	in_dev_put(indev);
 }
 
-static void
+void
 qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
@@ -4000,10 +3971,12 @@ recheck:
 
 	switch (event) {
 	case NETDEV_UP:
-		qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_UP);
+		qlcnic_config_ipaddr(adapter, ifa->ifa_address,
+						 QLCNIC_IP_UP);
 		break;
 	case NETDEV_DOWN:
-		qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_DOWN);
+		qlcnic_config_ipaddr(adapter, ifa->ifa_address,
+						 QLCNIC_IP_DOWN);
 		break;
 	default:
 		break;
@@ -4021,7 +3994,7 @@ static struct notifier_block qlcnic_inetaddr_cb = {
 	.notifier_call = qlcnic_inetaddr_event,
 };
 #else
-static void
+void
 qlcnic_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
 #endif
-- 
1.7.1
