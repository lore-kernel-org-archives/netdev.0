From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 1/2] qlcnic: NIC Partitioning
Date: Mon, 24 May 2010 16:48:09 -0700
Message-ID: <alpine.OSX.2.00.1005241617080.27371@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:22006 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758575Ab0EXXsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 19:48:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following changes have been added to enable the adapter to work in
NIC partitioning mode where multiple PCI functions of an adapter port can
be configured to work as NIC functions. The first function that is enumerated on
the PCI bus assumes the role of management function which, besides being able
to do all the NIC functionality, can configure other NIC partitions. Other NIC
functions can be configured as privileged or non privileged functions.
Privileged function can not configure other NIC functions but can do all the
NIC functionality including any firmware initialization, chip reset etc. Non
privileged functions can do only basic IO. For chip reset etc, it depends on the 
privilege or management function.

1. Added code to determine PCI function number independent of kernel API.
2. Added Driver - FW version 2.0 support.
3. Changed producer and consumer register offset calculation.
4. Added management and privileged operation modes for npar functions. A module
   parameter has been added to control it.
6. Added support for configuring the eswitch in the adapter.

Please apply.
thanks,
Anirban

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |  121 ++++++++-
 drivers/net/qlcnic/qlcnic_ctx.c     |  513 +++++++++++++++++++++++++++++++++--
 drivers/net/qlcnic/qlcnic_ethtool.c |   11 +-
 drivers/net/qlcnic/qlcnic_hdr.h     |   70 +++++
 drivers/net/qlcnic/qlcnic_hw.c      |   14 +-
 drivers/net/qlcnic/qlcnic_init.c    |   40 ++-
 drivers/net/qlcnic/qlcnic_main.c    |  195 ++++++++++++--
 7 files changed, 890 insertions(+), 74 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 896d40d..31a0b43 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -197,8 +197,7 @@ struct cmd_desc_type0 {

        __le64 addr_buffer4;

-       __le32 reserved2;
-       __le16 reserved;
+       u8 eth_addr[ETH_ALEN];
        __le16 vlan_TCI;

 } __attribute__ ((aligned(64)));
@@ -315,6 +314,8 @@ struct uni_data_desc{
 #define QLCNIC_BRDTYPE_P3_10G_XFP      0x0032
 #define QLCNIC_BRDTYPE_P3_10G_TP       0x0080

+#define QLCNIC_MSIX_TABLE_OFFSET       0x44
+
 /* Flash memory map */
 #define QLCNIC_BRDCFG_START    0x4000          /* board config */
 #define QLCNIC_BOOTLD_START    0x10000         /* bootld */
@@ -542,7 +543,17 @@ struct qlcnic_recv_context {
 #define QLCNIC_CDRP_CMD_READ_PEXQ_PARAMETERS   0x0000001c
 #define QLCNIC_CDRP_CMD_GET_LIC_CAPABILITIES   0x0000001d
 #define QLCNIC_CDRP_CMD_READ_MAX_LRO_PER_BOARD 0x0000001e
-#define QLCNIC_CDRP_CMD_MAX                    0x0000001f
+#define QLCNIC_CDRP_CMD_MAC_ADDRESS            0x0000001f
+
+#define QLCNIC_CDRP_CMD_GET_PCI_INFO           0x00000020
+#define QLCNIC_CDRP_CMD_GET_NIC_INFO           0x00000021
+#define QLCNIC_CDRP_CMD_SET_NIC_INFO           0x00000022
+#define QLCNIC_CDRP_CMD_RESET_NPAR             0x00000023
+#define QLCNIC_CDRP_CMD_GET_ESWITCH_CAPABILITY 0x00000024
+#define QLCNIC_CDRP_CMD_TOGGLE_ESWITCH         0x00000025
+#define QLCNIC_CDRP_CMD_GET_ESWITCH_STATUS     0x00000026
+#define QLCNIC_CDRP_CMD_SET_PORTMIRRORING      0x00000027
+#define QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH      0x00000028

 #define QLCNIC_RCODE_SUCCESS           0
 #define QLCNIC_RCODE_TIMEOUT           17
@@ -560,7 +571,6 @@ struct qlcnic_recv_context {
 /*
  * Context state
  */
-#define QLCHAL_VERSION 1

 #define QLCNIC_HOST_CTX_STATE_ACTIVE   2

@@ -887,6 +897,7 @@ struct qlcnic_mac_req {
 #define MSIX_ENTRIES_PER_ADAPTER       NUM_STS_DESC_RINGS
 #define QLCNIC_MSIX_TBL_SPACE          8192
 #define QLCNIC_PCI_REG_MSIX_TBL        0x44
+#define QLCNIC_MSIX_TBL_PGSIZE         4096

 #define QLCNIC_NETDEV_WEIGHT   128
 #define QLCNIC_ADAPTER_UP_MAGIC 777
@@ -923,7 +934,6 @@ struct qlcnic_adapter {
        u8 mc_enabled;
        u8 max_mc_count;
        u8 rss_supported;
-       u8 rsrvd1;
        u8 fw_wait_cnt;
        u8 fw_fail_cnt;
        u8 tx_timeo_cnt;
@@ -940,6 +950,15 @@ struct qlcnic_adapter {
        u16 link_autoneg;
        u16 module_type;

+       u16 op_mode;
+       u16 switch_mode;
+       u16 max_tx_ques;
+       u16 max_rx_ques;
+       u16 min_tx_bw;
+       u16 max_tx_bw;
+       u16 max_mtu;
+
+       u32 fw_hal_version;
        u32 capabilities;
        u32 flags;
        u32 irq;
@@ -948,18 +967,22 @@ struct qlcnic_adapter {
        u32 int_vec_bit;
        u32 heartbit;

+       u8 max_mac_filters;
        u8 dev_state;
        u8 diag_test;
        u8 diag_cnt;
        u8 reset_ack_timeo;
        u8 dev_init_timeo;
-       u8 rsrd1;
        u16 msg_enable;

        u8 mac_addr[ETH_ALEN];

        u64 dev_rst_time;

+       struct qlcnic_pci_info *npars;
+       struct qlcnic_eswitch *eswitch;
+       struct qlcnic_nic_template *nic_ops;
+
        struct qlcnic_adapter_stats stats;

        struct qlcnic_recv_context recv_ctx;
@@ -984,6 +1007,53 @@ struct qlcnic_adapter {
        const struct firmware *fw;
 };

+struct qlcnic_info {
+       __le16  pci_func;
+       __le16  op_mode; /* 1 = Priv, 2 = NP, 3 = NP passthru */
+       __le16  phys_port;
+       __le16  switch_mode; /* 0 = disabled, 1 = int, 2 = ext */
+
+       __le32  capabilities;
+       u8      max_mac_filters;
+       u8      reserved1;
+       __le16  max_mtu;
+
+       __le16  max_tx_ques;
+       __le16  max_rx_ques;
+       __le16  min_tx_bw;
+       __le16  max_tx_bw;
+       u8      reserved2[104];
+};
+
+struct qlcnic_pci_info {
+       __le16  id; /* pci function id */
+       __le16  active; /* 1 = Enabled */
+       __le16  type; /* 1 = NIC, 2 = FCoE, 3 = iSCSI */
+       __le16  default_port; /* default port number */
+
+       __le16  tx_min_bw; /* Multiple of 100mbpc */
+       __le16  tx_max_bw;
+       __le16  reserved1[2];
+
+       u8      mac[ETH_ALEN];
+       u8      reserved2[106];
+};
+
+struct qlcnic_eswitch {
+       u8      port;
+       u8      active_vports;
+       u8      active_vlans;
+       u8      active_ucast_filters;
+       u8      max_ucast_filters;
+       u8      max_active_vlans;
+
+       u32     flags;
+#define QLCNIC_SWITCH_ENABLE           BIT_1
+#define QLCNIC_SWITCH_VLAN_FILTERING   BIT_2
+#define QLCNIC_SWITCH_PROMISC_MODE     BIT_3
+#define QLCNIC_SWITCH_PORT_MIRRORING   BIT_4
+};
+
 int qlcnic_fw_cmd_query_phy(struct qlcnic_adapter *adapter, u32 reg, u32 *val);
 int qlcnic_fw_cmd_set_phy(struct qlcnic_adapter *adapter, u32 reg, u32 val);

@@ -1070,13 +1140,14 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup);
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
 int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
-int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, int enable);
+int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
                struct qlcnic_host_tx_ring *tx_ring);
-int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, u64 *mac);
+int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, u8 *mac);
 void qlcnic_clear_ilb_mode(struct qlcnic_adapter *adapter);
 int qlcnic_set_ilb_mode(struct qlcnic_adapter *adapter);
+void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);

 /* Functions from qlcnic_main.c */
 int qlcnic_reset_context(struct qlcnic_adapter *);
@@ -1088,6 +1159,32 @@ int qlcnic_check_loopback_buff(unsigned char *data);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);

+/* Functions from qlcnic_vf.c */
+int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
+int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
+int qlcnicvf_set_ilb_mode(struct qlcnic_adapter *adapter);
+void qlcnicvf_clear_ilb_mode(struct qlcnic_adapter *adapter);
+void qlcnicvf_set_port_mode(struct qlcnic_adapter *adapter);
+
+/* Management functions */
+int qlcnic_set_mac_address(struct qlcnic_adapter *, u8*);
+int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
+int qlcnic_get_nic_info(struct qlcnic_adapter *, u8);
+int qlcnic_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
+int qlcnic_get_pci_info(struct qlcnic_adapter *);
+int qlcnic_reset_partition(struct qlcnic_adapter *, u8);
+
+/*  eSwitch management functions */
+int qlcnic_get_eswitch_capabilities(struct qlcnic_adapter *, u8,
+                               struct qlcnic_eswitch *);
+int qlcnic_get_eswitch_status(struct qlcnic_adapter *, u8,
+                               struct qlcnic_eswitch *);
+int qlcnic_toggle_eswitch(struct qlcnic_adapter *, u8, u8);
+int qlcnic_config_switch_port(struct qlcnic_adapter *, u8, int, u8, u8,
+                       u8, u8, u16);
+int qlcnic_config_port_mirroring(struct qlcnic_adapter *, u8, u8, u8);
+extern int qlcnic_config_tso;
+
 /*
  * QLOGIC Board information
  */
@@ -1131,6 +1228,14 @@ static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)

 extern const struct ethtool_ops qlcnic_ethtool_ops;

+struct qlcnic_nic_template {
+       int (*get_mac_addr) (struct qlcnic_adapter *, u8*);
+       int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
+       int (*config_led) (struct qlcnic_adapter *, u32, u32);
+       int (*set_ilb_mode) (struct qlcnic_adapter *);
+       void (*clear_ilb_mode) (struct qlcnic_adapter *);
+};
+
 #define QLCDB(adapter, lvl, _fmt, _args...) do {       \
        if (NETIF_MSG_##lvl & adapter->msg_enable)      \
                printk(KERN_INFO "%s: %s: " _fmt,       \
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index c2c1f5c..1e1dc58 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -88,12 +88,12 @@ qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)

        if (recv_ctx->state == QLCNIC_HOST_CTX_STATE_ACTIVE) {
                if (qlcnic_issue_cmd(adapter,
-                               adapter->ahw.pci_func,
-                               QLCHAL_VERSION,
-                               recv_ctx->context_id,
-                               mtu,
-                               0,
-                               QLCNIC_CDRP_CMD_SET_MTU)) {
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       recv_ctx->context_id,
+                       mtu,
+                       0,
+                       QLCNIC_CDRP_CMD_SET_MTU)) {

                        dev_err(&adapter->pdev->dev, "Failed to set mtu\n");
                        return -EIO;
@@ -121,7 +121,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)

        int i, nrds_rings, nsds_rings;
        size_t rq_size, rsp_size;
-       u32 cap, reg, val;
+       u32 cap, reg, val, reg2;
        int err;

        struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
@@ -197,7 +197,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
        phys_addr = hostrq_phys_addr;
        err = qlcnic_issue_cmd(adapter,
                        adapter->ahw.pci_func,
-                       QLCHAL_VERSION,
+                       adapter->fw_hal_version,
                        (u32)(phys_addr >> 32),
                        (u32)(phys_addr & 0xffffffff),
                        rq_size,
@@ -216,8 +216,12 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
                rds_ring = &recv_ctx->rds_rings[i];

                reg = le32_to_cpu(prsp_rds[i].host_producer_crb);
-               rds_ring->crb_rcv_producer = qlcnic_get_ioaddr(adapter,
+               if (adapter->fw_hal_version == QLCNIC_FW_BASE)
+                       rds_ring->crb_rcv_producer = qlcnic_get_ioaddr(adapter,
                                QLCNIC_REG(reg - 0x200));
+               else
+                       rds_ring->crb_rcv_producer = adapter->ahw.pci_base0 +
+                               reg;
        }

        prsp_sds = ((struct qlcnic_cardrsp_sds_ring *)
@@ -227,12 +231,18 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
                sds_ring = &recv_ctx->sds_rings[i];

                reg = le32_to_cpu(prsp_sds[i].host_consumer_crb);
-               sds_ring->crb_sts_consumer = qlcnic_get_ioaddr(adapter,
-                               QLCNIC_REG(reg - 0x200));
+               reg2 = le32_to_cpu(prsp_sds[i].interrupt_crb);

-               reg = le32_to_cpu(prsp_sds[i].interrupt_crb);
-               sds_ring->crb_intr_mask = qlcnic_get_ioaddr(adapter,
+               if (adapter->fw_hal_version == QLCNIC_FW_BASE) {
+                       sds_ring->crb_sts_consumer = qlcnic_get_ioaddr(adapter,
                                QLCNIC_REG(reg - 0x200));
+                       sds_ring->crb_intr_mask = qlcnic_get_ioaddr(adapter,
+                               QLCNIC_REG(reg2 - 0x200));
+               } else {
+                       sds_ring->crb_sts_consumer = adapter->ahw.pci_base0 +
+                               reg;
+                       sds_ring->crb_intr_mask = adapter->ahw.pci_base0 + reg2;
+               }
        }

        recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
@@ -253,7 +263,7 @@ qlcnic_fw_cmd_destroy_rx_ctx(struct qlcnic_adapter *adapter)

        if (qlcnic_issue_cmd(adapter,
                        adapter->ahw.pci_func,
-                       QLCHAL_VERSION,
+                       adapter->fw_hal_version,
                        recv_ctx->context_id,
                        QLCNIC_DESTROY_CTX_RESET,
                        0,
@@ -319,7 +329,7 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
        phys_addr = rq_phys_addr;
        err = qlcnic_issue_cmd(adapter,
                        adapter->ahw.pci_func,
-                       QLCHAL_VERSION,
+                       adapter->fw_hal_version,
                        (u32)(phys_addr >> 32),
                        ((u32)phys_addr & 0xffffffff),
                        rq_size,
@@ -327,8 +337,12 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)

        if (err == QLCNIC_RCODE_SUCCESS) {
                temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
-               tx_ring->crb_cmd_producer = qlcnic_get_ioaddr(adapter,
+               if (adapter->fw_hal_version == QLCNIC_FW_BASE)
+                       tx_ring->crb_cmd_producer = qlcnic_get_ioaddr(adapter,
                                QLCNIC_REG(temp - 0x200));
+               else
+                       tx_ring->crb_cmd_producer = adapter->ahw.pci_base0 +
+                               temp;

                adapter->tx_context_id =
                        le16_to_cpu(prsp->context_id);
@@ -351,7 +365,7 @@ qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter)
 {
        if (qlcnic_issue_cmd(adapter,
                        adapter->ahw.pci_func,
-                       QLCHAL_VERSION,
+                       adapter->fw_hal_version,
                        adapter->tx_context_id,
                        QLCNIC_DESTROY_CTX_RESET,
                        0,
@@ -368,7 +382,7 @@ qlcnic_fw_cmd_query_phy(struct qlcnic_adapter *adapter, u32 reg, u32 *val)

        if (qlcnic_issue_cmd(adapter,
                        adapter->ahw.pci_func,
-                       QLCHAL_VERSION,
+                       adapter->fw_hal_version,
                        reg,
                        0,
                        0,
@@ -385,7 +399,7 @@ qlcnic_fw_cmd_set_phy(struct qlcnic_adapter *adapter, u32 reg, u32 val)
 {
        return qlcnic_issue_cmd(adapter,
                        adapter->ahw.pci_func,
-                       QLCHAL_VERSION,
+                       adapter->fw_hal_version,
                        reg,
                        val,
                        0,
@@ -533,3 +547,464 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
        }
 }

+/* Set MAC address of a NIC partition */
+int qlcnic_set_mac_address(struct qlcnic_adapter *adapter, u8* mac)
+{
+       int err = 0;
+       u32 arg1, arg2, arg3;
+
+       arg1 = adapter->ahw.pci_func | BIT_9;
+       arg2 = mac[0] | (mac[1] << 8) | (mac[2] << 16) | (mac[3] << 24);
+       arg3 = mac[4] | (mac[5] << 16);
+
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       arg1,
+                       arg2,
+                       arg3,
+                       QLCNIC_CDRP_CMD_MAC_ADDRESS);
+
+       if (err != QLCNIC_RCODE_SUCCESS) {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to set mac address%d\n", err);
+               err = -EIO;
+       }
+
+       return err;
+}
+
+/* Get MAC address of a NIC partition */
+int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
+{
+       int err;
+       u32 arg1;
+
+       arg1 = adapter->ahw.pci_func | BIT_8;
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       arg1,
+                       0,
+                       0,
+                       QLCNIC_CDRP_CMD_MAC_ADDRESS);
+
+       if (err == QLCNIC_RCODE_SUCCESS) {
+               qlcnic_fetch_mac(adapter, QLCNIC_ARG1_CRB_OFFSET,
+                               QLCNIC_ARG2_CRB_OFFSET, 0, mac);
+               dev_info(&adapter->pdev->dev, "MAC address: %pM\n", mac);
+       } else {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to get mac address%d\n", err);
+               err = -EIO;
+       }
+
+       return err;
+}
+
+/* Get info of a NIC partition */
+int qlcnic_get_nic_info(struct qlcnic_adapter *adapter, u8 func_id)
+{
+       int     err;
+       dma_addr_t nic_dma_t;
+       struct qlcnic_info *nic_info;
+       void *nic_info_addr;
+       size_t  nic_size = sizeof(struct qlcnic_info);
+
+       nic_info_addr = pci_alloc_consistent(adapter->pdev,
+               nic_size, &nic_dma_t);
+       if (!nic_info_addr)
+               return -ENOMEM;
+       memset(nic_info_addr, 0, nic_size);
+
+       nic_info = (struct qlcnic_info *) nic_info_addr;
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       MSD(nic_dma_t),
+                       LSD(nic_dma_t),
+                       (func_id << 16 | nic_size),
+                       QLCNIC_CDRP_CMD_GET_NIC_INFO);
+
+       if (err == QLCNIC_RCODE_SUCCESS) {
+               adapter->physical_port = le16_to_cpu(nic_info->phys_port);
+               adapter->switch_mode = le16_to_cpu(nic_info->switch_mode);
+               adapter->max_tx_ques = le16_to_cpu(nic_info->max_tx_ques);
+               adapter->max_rx_ques = le16_to_cpu(nic_info->max_rx_ques);
+               adapter->min_tx_bw = le16_to_cpu(nic_info->min_tx_bw);
+               adapter->max_tx_bw = le16_to_cpu(nic_info->max_tx_bw);
+               adapter->max_mtu = le16_to_cpu(nic_info->max_mtu);
+               adapter->capabilities = le32_to_cpu(nic_info->capabilities);
+               adapter->max_mac_filters = nic_info->max_mac_filters;
+
+               dev_info(&adapter->pdev->dev,
+                       "phy port: %d switch_mode: %d,\n"
+                       "\tmax_tx_q: %d max_rx_q: %d min_tx_bw: 0x%x,\n"
+                       "\tmax_tx_bw: 0x%x max_mtu:0x%x, capabilities: 0x%x\n",
+                       adapter->physical_port, adapter->switch_mode,
+                       adapter->max_tx_ques, adapter->max_rx_ques,
+                       adapter->min_tx_bw, adapter->max_tx_bw,
+                       adapter->max_mtu, adapter->capabilities);
+       } else {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to get nic info%d\n", err);
+               err = -EIO;
+       }
+
+       pci_free_consistent(adapter->pdev, nic_size, nic_info_addr, nic_dma_t);
+       return err;
+}
+
+/* Configure a NIC partition */
+int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
+{
+       int err = -EIO;
+       u32 func_state;
+       dma_addr_t nic_dma_t;
+       void *nic_info_addr;
+       struct qlcnic_info *nic_info;
+       size_t nic_size = sizeof(struct qlcnic_info);
+
+       if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+               return err;
+
+       if (qlcnic_api_lock(adapter))
+               return err;
+
+       func_state = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
+       if (QLC_DEV_CHECK_ACTIVE(func_state, nic->pci_func)) {
+               qlcnic_api_unlock(adapter);
+               return err;
+       }
+
+       qlcnic_api_unlock(adapter);
+
+       nic_info_addr = pci_alloc_consistent(adapter->pdev, nic_size,
+                       &nic_dma_t);
+       if (!nic_info_addr)
+               return -ENOMEM;
+
+       memset(nic_info_addr, 0, nic_size);
+       nic_info = (struct qlcnic_info *)nic_info_addr;
+
+       nic_info->pci_func = cpu_to_le16(nic->pci_func);
+       nic_info->op_mode = cpu_to_le16(nic->op_mode);
+       nic_info->phys_port = cpu_to_le16(nic->phys_port);
+       nic_info->switch_mode = cpu_to_le16(nic->switch_mode);
+       nic_info->capabilities = cpu_to_le32(nic->capabilities);
+       nic_info->max_mac_filters = nic->max_mac_filters;
+       nic_info->max_tx_ques = cpu_to_le16(nic->max_tx_ques);
+       nic_info->max_rx_ques = cpu_to_le16(nic->max_rx_ques);
+       nic_info->min_tx_bw = cpu_to_le16(nic->min_tx_bw);
+       nic_info->max_tx_bw = cpu_to_le16(nic->max_tx_bw);
+
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       MSD(nic_dma_t),
+                       LSD(nic_dma_t),
+                       nic_size,
+                       QLCNIC_CDRP_CMD_SET_NIC_INFO);
+
+       if (err != QLCNIC_RCODE_SUCCESS) {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to set nic info%d\n", err);
+               err = -EIO;
+       }
+
+       pci_free_consistent(adapter->pdev, nic_size, nic_info_addr, nic_dma_t);
+       return err;
+}
+
+/* Get PCI Info of a partition */
+int qlcnic_get_pci_info(struct qlcnic_adapter *adapter)
+{
+       int err = 0, i;
+       dma_addr_t pci_info_dma_t;
+       struct qlcnic_pci_info *npar;
+       void *pci_info_addr;
+       size_t npar_size = sizeof(struct qlcnic_pci_info);
+       size_t pci_size = npar_size * QLCNIC_MAX_PCI_FUNC;
+
+       pci_info_addr = pci_alloc_consistent(adapter->pdev, pci_size,
+                       &pci_info_dma_t);
+       if (!pci_info_addr)
+               return -ENOMEM;
+       memset(pci_info_addr, 0, pci_size);
+
+       if (!adapter->npars)
+               adapter->npars = kzalloc(pci_size, GFP_KERNEL);
+       if (!adapter->npars) {
+               err = -ENOMEM;
+               goto err_npar;
+       }
+
+       if (!adapter->eswitch)
+               adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
+                               QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
+       if (!adapter->eswitch) {
+               err = -ENOMEM;
+               goto err_eswitch;
+       }
+
+       npar = (struct qlcnic_pci_info *) pci_info_addr;
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       MSD(pci_info_dma_t),
+                       LSD(pci_info_dma_t),
+                       pci_size,
+                       QLCNIC_CDRP_CMD_GET_PCI_INFO);
+
+       if (err == QLCNIC_RCODE_SUCCESS) {
+               for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++) {
+                       adapter->npars[i].id = le32_to_cpu(npar->id);
+                       adapter->npars[i].active = le32_to_cpu(npar->active);
+                       adapter->npars[i].type = le32_to_cpu(npar->type);
+                       adapter->npars[i].default_port =
+                               le32_to_cpu(npar->default_port);
+                       adapter->npars[i].tx_min_bw =
+                               le32_to_cpu(npar->tx_min_bw);
+                       adapter->npars[i].tx_max_bw =
+                               le32_to_cpu(npar->tx_max_bw);
+                       memcpy(adapter->npars[i].mac, npar->mac, ETH_ALEN);
+               }
+       } else {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to get PCI Info%d\n", err);
+               kfree(adapter->npars);
+               err = -EIO;
+       }
+       goto err_npar;
+
+err_eswitch:
+       kfree(adapter->npars);
+       adapter->npars = NULL;
+
+err_npar:
+       pci_free_consistent(adapter->pdev, pci_size, pci_info_addr,
+               pci_info_dma_t);
+       return err;
+}
+
+/* Reset a NIC partition */
+
+int qlcnic_reset_partition(struct qlcnic_adapter *adapter, u8 func_no)
+{
+       int err = -EIO;
+
+       if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+               return err;
+
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       func_no,
+                       0,
+                       0,
+                       QLCNIC_CDRP_CMD_RESET_NPAR);
+
+       if (err != QLCNIC_RCODE_SUCCESS) {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to issue reset partition%d\n", err);
+               err = -EIO;
+       }
+
+       return err;
+}
+
+/* Get eSwitch Capabilities */
+int qlcnic_get_eswitch_capabilities(struct qlcnic_adapter *adapter, u8 port,
+                                       struct qlcnic_eswitch *eswitch)
+{
+       int err = -EIO;
+       u32 arg1, arg2;
+
+       if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+               return err;
+
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       port,
+                       0,
+                       0,
+                       QLCNIC_CDRP_CMD_GET_ESWITCH_CAPABILITY);
+
+       if (err == QLCNIC_RCODE_SUCCESS) {
+               arg1 = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
+               arg2 = QLCRD32(adapter, QLCNIC_ARG2_CRB_OFFSET);
+
+               eswitch->port = arg1 & 0xf;
+               eswitch->active_vports = LSB(arg2);
+               eswitch->max_ucast_filters = MSB(arg2);
+               eswitch->max_active_vlans = LSB(MSW(arg2));
+               if (arg1 & BIT_6)
+                       eswitch->flags |= QLCNIC_SWITCH_VLAN_FILTERING;
+               if (arg1 & BIT_7)
+                       eswitch->flags |= QLCNIC_SWITCH_PROMISC_MODE;
+               if (arg1 & BIT_8)
+                       eswitch->flags |= QLCNIC_SWITCH_PORT_MIRRORING;
+       } else {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to get eswitch capabilities%d\n", err);
+       }
+
+       return err;
+}
+
+/* Get current status of eswitch */
+int qlcnic_get_eswitch_status(struct qlcnic_adapter *adapter, u8 port,
+                               struct qlcnic_eswitch *eswitch)
+{
+       int err = -EIO;
+       u32 arg1, arg2;
+
+       if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+               return err;
+
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       port,
+                       0,
+                       0,
+                       QLCNIC_CDRP_CMD_GET_ESWITCH_STATUS);
+
+       if (err == QLCNIC_RCODE_SUCCESS) {
+               arg1 = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
+               arg2 = QLCRD32(adapter, QLCNIC_ARG2_CRB_OFFSET);
+
+               eswitch->port = arg1 & 0xf;
+               eswitch->active_vports = LSB(arg2);
+               eswitch->active_ucast_filters = MSB(arg2);
+               eswitch->active_vlans = LSB(MSW(arg2));
+               if (arg1 & BIT_6)
+                       eswitch->flags |= QLCNIC_SWITCH_VLAN_FILTERING;
+               if (arg1 & BIT_8)
+                       eswitch->flags |= QLCNIC_SWITCH_PORT_MIRRORING;
+
+       } else {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to get eswitch status%d\n", err);
+       }
+
+       return err;
+}
+
+/* Enable/Disable eSwitch */
+int qlcnic_toggle_eswitch(struct qlcnic_adapter *adapter, u8 id, u8 enable)
+{
+       int err = -EIO;
+       u32 arg1, arg2;
+       struct qlcnic_eswitch *eswitch;
+
+       if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+               return err;
+
+       eswitch = &adapter->eswitch[id];
+       if (!eswitch)
+               return err;
+
+       arg1 = eswitch->port | (enable ? BIT_4 : 0);
+       arg2 = eswitch->active_vports | (eswitch->max_ucast_filters << 8) |
+               (eswitch->max_active_vlans << 16);
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       arg1,
+                       arg2,
+                       0,
+                       QLCNIC_CDRP_CMD_TOGGLE_ESWITCH);
+
+       if (err != QLCNIC_RCODE_SUCCESS) {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to enable eswitch%d\n", eswitch->port);
+               eswitch->flags &= ~QLCNIC_SWITCH_ENABLE;
+               err = -EIO;
+       } else {
+               eswitch->flags |= QLCNIC_SWITCH_ENABLE;
+               dev_info(&adapter->pdev->dev,
+                       "Enabled eSwitch for port %d\n", eswitch->port);
+       }
+
+       return err;
+}
+
+/* Configure eSwitch for port mirroring */
+int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
+                               u8 enable_mirroring, u8 pci_func)
+{
+       int err = -EIO;
+       u32 arg1;
+
+       if (adapter->op_mode != QLCNIC_MGMT_FUNC ||
+               !(adapter->eswitch[id].flags & QLCNIC_SWITCH_ENABLE))
+               return err;
+
+       arg1 = id | (enable_mirroring ? BIT_4 : 0);
+       arg1 |= pci_func << 8;
+
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       arg1,
+                       0,
+                       0,
+                       QLCNIC_CDRP_CMD_SET_PORTMIRRORING);
+
+       if (err != QLCNIC_RCODE_SUCCESS) {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to configure port mirroring%d on eswitch:%d\n",
+                       pci_func, id);
+       } else {
+               dev_info(&adapter->pdev->dev,
+                       "Configured eSwitch %d for port mirroring:%d\n",
+                       id, pci_func);
+       }
+
+       return err;
+}
+
+/* Configure eSwitch port */
+int qlcnic_config_switch_port(struct qlcnic_adapter *adapter, u8 id,
+               int vlan_tagging, u8 discard_tagged, u8 promsc_mode,
+               u8 mac_learn, u8 pci_func, u16 vlan_id)
+{
+       int err = -EIO;
+       u32 arg1;
+       struct qlcnic_eswitch *eswitch;
+
+       if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+               return err;
+
+       eswitch = &adapter->eswitch[id];
+       if (!(eswitch->flags & QLCNIC_SWITCH_ENABLE))
+               return err;
+
+       arg1 = eswitch->port | (discard_tagged ? BIT_4 : 0);
+       arg1 |= (promsc_mode ? BIT_6 : 0) | (mac_learn ? BIT_7 : 0);
+       arg1 |= pci_func << 8;
+       if (vlan_tagging)
+               arg1 |= BIT_5 | (vlan_id << 16);
+
+       err = qlcnic_issue_cmd(adapter,
+                       adapter->ahw.pci_func,
+                       adapter->fw_hal_version,
+                       arg1,
+                       0,
+                       0,
+                       QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH);
+
+       if (err != QLCNIC_RCODE_SUCCESS) {
+               dev_err(&adapter->pdev->dev,
+                       "Failed to configure eswitch port%d\n", eswitch->port);
+               eswitch->flags |= QLCNIC_SWITCH_ENABLE;
+       } else {
+               eswitch->flags &= ~QLCNIC_SWITCH_ENABLE;
+               dev_info(&adapter->pdev->dev,
+                       "Configured eSwitch for port %d\n", eswitch->port);
+       }
+
+       return err;
+}
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 3bd514e..3e4822a 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -683,13 +683,13 @@ static int qlcnic_loopback_test(struct net_device *netdev)
        if (ret)
                goto clear_it;

-       ret = qlcnic_set_ilb_mode(adapter);
+       ret = adapter->nic_ops->set_ilb_mode(adapter);
        if (ret)
                goto done;

        ret = qlcnic_do_ilb_test(adapter);

-       qlcnic_clear_ilb_mode(adapter);
+       adapter->nic_ops->clear_ilb_mode(adapter);

 done:
        qlcnic_diag_free_res(netdev, max_sds_rings);
@@ -715,7 +715,8 @@ static int qlcnic_irq_test(struct net_device *netdev)

        adapter->diag_cnt = 0;
        ret = qlcnic_issue_cmd(adapter, adapter->ahw.pci_func,
-                       QLCHAL_VERSION, adapter->portnum, 0, 0, 0x00000011);
+                       adapter->fw_hal_version, adapter->portnum,
+                       0, 0, 0x00000011);
        if (ret)
                goto done;

@@ -834,7 +835,7 @@ static int qlcnic_blink_led(struct net_device *dev, u32 val)
        struct qlcnic_adapter *adapter = netdev_priv(dev);
        int ret;

-       ret = qlcnic_config_led(adapter, 1, 0xf);
+       ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
        if (ret) {
                dev_err(&adapter->pdev->dev,
                        "Failed to set LED blink state.\n");
@@ -843,7 +844,7 @@ static int qlcnic_blink_led(struct net_device *dev, u32 val)

        msleep_interruptible(val * 1000);

-       ret = qlcnic_config_led(adapter, 0, 0xf);
+       ret = adapter->nic_ops->config_led(adapter, 0, 0xf);
        if (ret) {
                dev_err(&adapter->pdev->dev,
                        "Failed to reset LED blink state.\n");
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index ad9d167..1bcfb12 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -208,6 +208,39 @@ enum {
        QLCNIC_HW_PX_MAP_CRB_PGR0
 };

+#define        BIT_0   0x1
+#define        BIT_1   0x2
+#define        BIT_2   0x4
+#define        BIT_3   0x8
+#define        BIT_4   0x10
+#define        BIT_5   0x20
+#define        BIT_6   0x40
+#define        BIT_7   0x80
+#define        BIT_8   0x100
+#define        BIT_9   0x200
+#define        BIT_10  0x400
+#define        BIT_11  0x800
+#define        BIT_12  0x1000
+#define        BIT_13  0x2000
+#define        BIT_14  0x4000
+#define        BIT_15  0x8000
+#define        BIT_16  0x10000
+#define        BIT_17  0x20000
+#define        BIT_18  0x40000
+#define        BIT_19  0x80000
+#define        BIT_20  0x100000
+#define        BIT_21  0x200000
+#define        BIT_22  0x400000
+#define        BIT_23  0x800000
+#define        BIT_24  0x1000000
+#define        BIT_25  0x2000000
+#define        BIT_26  0x4000000
+#define        BIT_27  0x8000000
+#define        BIT_28  0x10000000
+#define        BIT_29  0x20000000
+#define        BIT_30  0x40000000
+#define        BIT_31  0x80000000
+
 /*  This field defines CRB adr [31:20] of the agents */

 #define QLCNIC_HW_CRB_HUB_AGT_ADR_MN   \
@@ -684,12 +717,20 @@ enum {
 #define QLCNIC_DEV_FAILED              0x6
 #define QLCNIC_DEV_QUISCENT            0x7

+#define QLC_DEV_CHECK_ACTIVE(VAL, FN)          ((VAL) &= (1 << (FN * 4)))
 #define QLC_DEV_SET_REF_CNT(VAL, FN)           ((VAL) |= (1 << (FN * 4)))
 #define QLC_DEV_CLR_REF_CNT(VAL, FN)           ((VAL) &= ~(1 << (FN * 4)))
 #define QLC_DEV_SET_RST_RDY(VAL, FN)           ((VAL) |= (1 << (FN * 4)))
 #define QLC_DEV_SET_QSCNT_RDY(VAL, FN)         ((VAL) |= (2 << (FN * 4)))
 #define QLC_DEV_CLR_RST_QSCNT(VAL, FN)         ((VAL) &= ~(3 << (FN * 4)))

+#define QLC_DEV_GET_DRV(VAL, FN)               (0xf & ((VAL) >> (FN * 4)))
+#define QLC_DEV_SET_DRV(VAL, FN)               ((VAL) << (FN * 4))
+
+#define QLCNIC_TYPE_NIC                1
+#define QLCNIC_TYPE_FCOE               2
+#define QLCNIC_TYPE_ISCSI              3
+
 #define QLCNIC_RCODE_DRIVER_INFO               0x20000000
 #define QLCNIC_RCODE_DRIVER_CAN_RELOAD         0x40000000
 #define QLCNIC_RCODE_FATAL_ERROR               0x80000000
@@ -721,6 +762,35 @@ struct qlcnic_legacy_intr_set {
        u32     pci_int_reg;
 };

+#define QLCNIC_FW_API          0x1b216c
+#define QLCNIC_DRV_OP_MODE     0x1b2170
+#define QLCNIC_MSIX_BASE       0x132110
+#define QLCNIC_MAX_PCI_FUNC    8
+
+/* PCI function operational mode */
+enum {
+       QLCNIC_MGMT_FUNC        = 0,
+       QLCNIC_PRIV_FUNC        = 1,
+       QLCNIC_NON_PRIV_FUNC    = 2
+};
+
+/* FW HAL api version */
+enum {
+       QLCNIC_FW_BASE  = 1,
+       QLCNIC_FW_NPAR  = 2
+};
+
+#define QLC_DEV_DRV_DEFAULT 0x11111111
+
+#define LSB(x) ((uint8_t)(x))
+#define MSB(x) ((uint8_t)((uint16_t)(x) >> 8))
+
+#define LSW(x)  ((uint16_t)((uint32_t)(x)))
+#define MSW(x)  ((uint16_t)((uint32_t)(x) >> 16))
+
+#define LSD(x)  ((uint32_t)((uint64_t)(x)))
+#define MSD(x)  ((uint32_t)((((uint64_t)(x)) >> 16) >> 16))
+
 #define        QLCNIC_LEGACY_INTR_CONFIG                                       \
 {                                                                      \
        {                                                               \
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 0c2e1f0..f776956 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -538,7 +538,7 @@ int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
        return rv;
 }

-int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, int enable)
+int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 {
        struct qlcnic_nic_req req;
        u64 word;
@@ -704,21 +704,15 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
        return rc;
 }

-int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, u64 *mac)
+int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, u8 *mac)
 {
-       u32 crbaddr, mac_hi, mac_lo;
+       u32 crbaddr;
        int pci_func = adapter->ahw.pci_func;

        crbaddr = CRB_MAC_BLOCK_START +
                (4 * ((pci_func/2) * 3)) + (4 * (pci_func & 1));

-       mac_lo = QLCRD32(adapter, crbaddr);
-       mac_hi = QLCRD32(adapter, crbaddr+4);
-
-       if (pci_func & 1)
-               *mac = le64_to_cpu((mac_lo >> 16) | ((u64)mac_hi << 16));
-       else
-               *mac = le64_to_cpu((u64)mac_lo | ((u64)mac_hi << 32));
+       qlcnic_fetch_mac(adapter, crbaddr, crbaddr+4, pci_func & 1, mac);

        return 0;
 }
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 71a4e66..635c990 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -520,17 +520,16 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
        int timeo;
        u32 val;

-       val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
-       val = (val >> (adapter->portnum * 4)) & 0xf;
-
-       if ((val & 0x3) != 1) {
-               dev_err(&adapter->pdev->dev, "Not an Ethernet NIC func=%u\n",
-                                                                       val);
-               return -EIO;
+       if (adapter->fw_hal_version == QLCNIC_FW_BASE) {
+               val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
+               val = QLC_DEV_GET_DRV(val, adapter->portnum);
+               if ((val & 0x3) != QLCNIC_TYPE_NIC) {
+                       dev_err(&adapter->pdev->dev,
+                               "Not an Ethernet NIC func=%u\n", val);
+                       return -EIO;
+               }
+               adapter->physical_port = (val >> 2);
        }
-
-       adapter->physical_port = (val >> 2);
-
        if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
                timeo = 30;

@@ -1701,3 +1700,24 @@ qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
        sds_ring->consumer = consumer;
        writel(consumer, sds_ring->crb_sts_consumer);
 }
+
+void
+qlcnic_fetch_mac(struct qlcnic_adapter *adapter, u32 off1, u32 off2,
+                       u8 alt_mac, u8 *mac)
+{
+       u32 mac_low, mac_high;
+       int i;
+
+       mac_low = QLCRD32(adapter, off1);
+       mac_high = QLCRD32(adapter, off2);
+
+       if (alt_mac) {
+               mac_low |= (mac_low >> 16) | (mac_high << 16);
+               mac_high >>= 16;
+       }
+
+       for (i = 0; i < 2; i++)
+               mac[i] = (u8)(mac_high >> ((1 - i) * 8));
+       for (i = 2; i < 6; i++)
+               mac[i] = (u8)(mac_low >> ((5 - i) * 8));
+}
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 1003eb7..3b4fdb3 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -65,6 +65,10 @@ static int load_fw_file;
 module_param(load_fw_file, int, 0644);
 MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");

+static int qlcnic_config_npars;
+module_param(qlcnic_config_npars, int, 0644);
+MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled");
+
 static int __devinit qlcnic_probe(struct pci_dev *pdev,
                const struct pci_device_id *ent);
 static void __devexit qlcnic_remove(struct pci_dev *pdev);
@@ -307,19 +311,14 @@ static void qlcnic_init_msix_entries(struct qlcnic_adapter *adapter, int count)
 static int
 qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 {
-       int i;
-       unsigned char *p;
-       u64 mac_addr;
+       u8 mac_addr[ETH_ALEN];
        struct net_device *netdev = adapter->netdev;
        struct pci_dev *pdev = adapter->pdev;

-       if (qlcnic_get_mac_addr(adapter, &mac_addr) != 0)
+       if (adapter->nic_ops->get_mac_addr(adapter, mac_addr) != 0)
                return -EIO;

-       p = (unsigned char *)&mac_addr;
-       for (i = 0; i < 6; i++)
-               netdev->dev_addr[i] = *(p + 5 - i);
-
+       memcpy(netdev->dev_addr, mac_addr, ETH_ALEN);
        memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
        memcpy(adapter->mac_addr, netdev->dev_addr, netdev->addr_len);

@@ -371,6 +370,22 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 #endif
 };

+static struct qlcnic_nic_template qlcnic_ops = {
+       .get_mac_addr = qlcnic_get_mac_addr,
+       .config_bridged_mode = qlcnic_config_bridged_mode,
+       .config_led = qlcnic_config_led,
+       .set_ilb_mode = qlcnic_set_ilb_mode,
+       .clear_ilb_mode = qlcnic_clear_ilb_mode
+};
+
+static struct qlcnic_nic_template qlcnic_pf_ops = {
+       .get_mac_addr = qlcnic_get_mac_address,
+       .config_bridged_mode = qlcnic_config_bridged_mode,
+       .config_led = qlcnic_config_led,
+       .set_ilb_mode = qlcnic_set_ilb_mode,
+       .clear_ilb_mode = qlcnic_clear_ilb_mode
+};
+
 static void
 qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 {
@@ -452,6 +467,125 @@ qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
                iounmap(adapter->ahw.pci_base0);
 }

+/* Use api lock to access this function */
+static int
+qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
+{
+       u8 id;
+       u32 ref_count;
+       int i, ret = 1;
+       u32 data = QLCNIC_MGMT_FUNC;
+       void __iomem *priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
+
+       /* If other drivers are not in use set their privilege level */
+       ref_count = QLCRD32(adapter, QLCNIC_CRB_DEV_REF_COUNT);
+       ret = qlcnic_api_lock(adapter);
+       if (ret)
+               goto err_lock;
+       if (QLC_DEV_CLR_REF_CNT(ref_count, adapter->ahw.pci_func))
+               goto err_npar;
+
+       for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+               id = adapter->npars[i].id;
+               if (adapter->npars[i].type != QLCNIC_TYPE_NIC ||
+                       id == adapter->ahw.pci_func)
+                       continue;
+               data |= (qlcnic_config_npars & QLC_DEV_SET_DRV(0xf, id));
+       }
+       writel(data, priv_op);
+
+err_npar:
+       qlcnic_api_unlock(adapter);
+err_lock:
+       return ret;
+}
+
+static u8
+qlcnic_set_mgmt_driver(struct qlcnic_adapter *adapter)
+{
+       u8 i, ret = 0;
+
+       if (qlcnic_get_pci_info(adapter))
+               return ret;
+       /* Set the eswitch */
+       for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++) {
+               if (!qlcnic_get_eswitch_capabilities(adapter, i,
+                       &adapter->eswitch[i])) {
+                       ret++;
+                       qlcnic_toggle_eswitch(adapter, i, ret);
+               }
+       }
+       return ret;
+}
+
+static u32
+qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
+{
+       void __iomem *msix_base_addr;
+       void __iomem *priv_op;
+       u32 func;
+       u32 msix_base;
+       u32 op_mode, priv_level;
+
+       /* Determine FW API version */
+       adapter->fw_hal_version = readl(adapter->ahw.pci_base0 + QLCNIC_FW_API);
+       if (adapter->fw_hal_version == ~0) {
+               adapter->nic_ops = &qlcnic_ops;
+               adapter->fw_hal_version = QLCNIC_FW_BASE;
+               adapter->ahw.pci_func = PCI_FUNC(adapter->pdev->devfn);
+               dev_info(&adapter->pdev->dev,
+                       "FW does not support nic partion\n");
+               return adapter->fw_hal_version;
+       }
+
+       /* Find PCI function number */
+       pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
+       msix_base_addr = adapter->ahw.pci_base0 + QLCNIC_MSIX_BASE;
+       msix_base = readl(msix_base_addr);
+       func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
+       adapter->ahw.pci_func = func;
+
+       /* Determine function privilege level */
+       priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
+       op_mode = readl(priv_op);
+       if (op_mode == QLC_DEV_DRV_DEFAULT) {
+               priv_level = QLCNIC_MGMT_FUNC;
+               if (qlcnic_api_lock(adapter))
+                       return 0;
+               op_mode = (op_mode & ~QLC_DEV_SET_DRV(0xf, func)) |
+                               (QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC, func));
+               writel(op_mode, priv_op);
+               qlcnic_api_unlock(adapter);
+
+       } else
+               priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
+
+       switch (priv_level) {
+       case QLCNIC_MGMT_FUNC:
+               adapter->op_mode = QLCNIC_MGMT_FUNC;
+               adapter->nic_ops = &qlcnic_pf_ops;
+               /* Set privilege level for other functions */
+               if (qlcnic_config_npars)
+                       qlcnic_set_function_modes(adapter);
+               dev_info(&adapter->pdev->dev,
+                       "HAL Version: %d, Management function\n",
+                       adapter->fw_hal_version);
+               break;
+       case QLCNIC_PRIV_FUNC:
+               adapter->op_mode = QLCNIC_PRIV_FUNC;
+               dev_info(&adapter->pdev->dev,
+                       "HAL Version: %d, Privileged function\n",
+                       adapter->fw_hal_version);
+               adapter->nic_ops = &qlcnic_pf_ops;
+               break;
+       default:
+               dev_info(&adapter->pdev->dev, "Unknown function mode: %d\n",
+                       priv_level);
+               return 0;
+       }
+       return adapter->fw_hal_version;
+}
+
 static int
 qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
 {
@@ -460,7 +594,6 @@ qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
        unsigned long mem_len, pci_len0 = 0;

        struct pci_dev *pdev = adapter->pdev;
-       int pci_func = adapter->ahw.pci_func;

        /* remap phys address */
        mem_base = pci_resource_start(pdev, 0); /* 0 is for BAR 0 */
@@ -483,8 +616,13 @@ qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
        adapter->ahw.pci_base0 = mem_ptr0;
        adapter->ahw.pci_len0 = pci_len0;

+       if (!qlcnic_get_driver_mode(adapter)) {
+               iounmap(adapter->ahw.pci_base0);
+               return -EIO;
+       }
+
        adapter->ahw.ocm_win_crb = qlcnic_get_ioaddr(adapter,
-               QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(pci_func)));
+               QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(adapter->ahw.pci_func)));

        return 0;
 }
@@ -553,7 +691,10 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
        dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
                        fw_major, fw_minor, fw_build);

-       adapter->capabilities = QLCRD32(adapter, CRB_FW_CAPABILITIES_1);
+       if (adapter->fw_hal_version == QLCNIC_FW_NPAR)
+               qlcnic_get_nic_info(adapter, adapter->ahw.pci_func);
+       else
+               adapter->capabilities = QLCRD32(adapter, CRB_FW_CAPABILITIES_1);

        adapter->flags &= ~QLCNIC_LRO_ENABLED;

@@ -633,6 +774,10 @@ wait_init:

        qlcnic_check_options(adapter);

+       if (adapter->fw_hal_version != QLCNIC_FW_BASE &&
+                       adapter->op_mode == QLCNIC_MGMT_FUNC)
+               qlcnic_set_mgmt_driver(adapter);
+
        adapter->need_fw_reset = 0;

        qlcnic_release_firmware(adapter);
@@ -977,12 +1122,11 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,

        SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);

-       netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
-       netdev->features |= (NETIF_F_GRO);
-       netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+       netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
+               NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_TSO | NETIF_F_TSO6);

-       netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
-       netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
+       netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
+               NETIF_F_IPV6_CSUM | NETIF_F_TSO | NETIF_F_TSO6);

        if (pci_using_dac) {
                netdev->features |= NETIF_F_HIGHDMA;
@@ -1036,7 +1180,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
        struct net_device *netdev = NULL;
        struct qlcnic_adapter *adapter = NULL;
        int err;
-       int pci_func_id = PCI_FUNC(pdev->devfn);
        uint8_t revision_id;
        uint8_t pci_using_dac;

@@ -1072,7 +1215,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
        adapter->netdev  = netdev;
        adapter->pdev    = pdev;
        adapter->dev_rst_time = jiffies;
-       adapter->ahw.pci_func  = pci_func_id;

        revision_id = pdev->revision;
        adapter->ahw.revision_id = revision_id;
@@ -1088,7 +1230,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
                goto err_out_free_netdev;

        /* This will be reset for mezz cards  */
-       adapter->portnum = pci_func_id;
+       adapter->portnum = adapter->ahw.pci_func;

        err = qlcnic_get_board_info(adapter);
        if (err) {
@@ -1175,6 +1317,11 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)

        qlcnic_detach(adapter);

+       if (adapter->npars != NULL)
+               kfree(adapter->npars);
+       if (adapter->eswitch != NULL)
+               kfree(adapter->eswitch);
+
        qlcnic_clr_all_drv_state(adapter);

        clear_bit(__QLCNIC_RESETTING, &adapter->state);
@@ -1340,11 +1487,11 @@ qlcnic_tso_check(struct net_device *netdev,
        u8 opcode = TX_ETHER_PKT;
        __be16 protocol = skb->protocol;
        u16 flags = 0, vid = 0;
-       u32 producer;
        int copied, offset, copy_len, hdr_len = 0, tso = 0, vlan_oob = 0;
        struct cmd_desc_type0 *hwdesc;
        struct vlan_ethhdr *vh;
        struct qlcnic_adapter *adapter = netdev_priv(netdev);
+       u32 producer = tx_ring->producer;

        if (protocol == cpu_to_be16(ETH_P_8021Q)) {

@@ -1360,6 +1507,11 @@ qlcnic_tso_check(struct net_device *netdev,
                vlan_oob = 1;
        }

+       if (*(skb->data) & BIT_0) {
+               flags |= BIT_0;
+               memcpy(&first_desc->eth_addr, skb->data, ETH_ALEN);
+       }
+
        if ((netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
                        skb_shinfo(skb)->gso_size > 0) {

@@ -1409,7 +1561,6 @@ qlcnic_tso_check(struct net_device *netdev,
        /* For LSO, we need to copy the MAC/IP/TCP headers into
         * the descriptor ring
         */
-       producer = tx_ring->producer;
        copied = 0;
        offset = 2;

@@ -2382,7 +2533,7 @@ qlcnic_store_bridged_mode(struct device *dev,
        if (strict_strtoul(buf, 2, &new))
                goto err_out;

-       if (!qlcnic_config_bridged_mode(adapter, !!new))
+       if (!adapter->nic_ops->config_bridged_mode(adapter, !!new))
                ret = len;

 err_out:
--
1.6.0.2

