From: Salil <salil.mehta@huawei.com>
Subject: [PATCH net-next 1/4] net:hns: Add support of Hip06 SoC to the Hislicon Network Subsystem
Date: Tue, 20 Oct 2015 23:01:15 +0800
Message-ID: <1445353278-130498-2-git-send-email-salil.mehta@huawei.com>
References: <1445353278-130498-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: yankejian <yankejian@huawei.com>, lipeng <lipeng321@huawei.com>
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <paul.gortmaker@windriver.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>, <arnd@arndb.de>,
	<liguozhu@hisilicon.com>, <yisen.zhuang@huawei.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<salil.mehta@huawei.com>, <mehta.salil.lnk@gmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:42207 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbbJTOsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 10:48:55 -0400
In-Reply-To: <1445353278-130498-1-git-send-email-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salil Mehta <salil.mehta@huawei.com>

This patchset adds support of Hisilicon Hip06 SoC to the existing HNS
ethernet driver.

The changes in the driver are mainly due to changes in the DMA
descriptor provided by the Hip06 ethernet hardware. These changes
need to co-exist with already present Hip05 DMA descriptor and its
operating functions. The decision to choose the correct type of DMA
descriptor is taken dynamically depending upon the version of the
hardware (i.e. V1/hip05 or V2/hip06, see alredy existing
hisilicon-hns-nic.txt binding file for detailed description). other
changes includes in SBM, DSAF and PPE modules as well. Changes
affecting the driver related to the newly added ethernet hardware
features in Hip06 would be added as separate patch over this and
subsequent patches.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: yankejian <yankejian@huawei.com>
Signed-off-by: huangdaode <huangdaode@hisilicon.com>
Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: lisheng <lisheng011@huawei.com>
---
---
 drivers/net/ethernet/hisilicon/hns/hnae.h          |   51 ++-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   30 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  154 ++++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    5 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |    6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |    6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |   68 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |    8 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   67 +++-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  364 ++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   12 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |    2 +-
 12 files changed, 638 insertions(+), 135 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index cec95ac..70a662c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -35,7 +35,7 @@
 #include <linux/phy.h>
 #include <linux/types.h>
 
-#define HNAE_DRIVER_VERSION "1.3.0"
+#define HNAE_DRIVER_VERSION "2.0"
 #define HNAE_DRIVER_NAME "hns"
 #define HNAE_COPYRIGHT "Copyright(c) 2015 Huawei Corporation."
 #define HNAE_DRIVER_STRING "Hisilicon Network Subsystem Driver"
@@ -63,6 +63,7 @@ do { \
 
 #define AE_VERSION_1 ('6' << 16 | '6' << 8 | '0')
 #define AE_VERSION_2 ('1' << 24 | '6' << 16 | '1' << 8 | '0')
+#define AE_IS_VER1(ver) ((ver) == AE_VERSION_1)
 #define AE_NAME_SIZE 16
 
 /* some said the RX and TX RCB format should not be the same in the future. But
@@ -144,23 +145,59 @@ enum hnae_led_state {
 #define HNS_RXD_ASID_S 24
 #define HNS_RXD_ASID_M (0xff << HNS_RXD_ASID_S)
 
+#define HNSV2_TXD_RI_B   1
+#define HNSV2_TXD_L4CS_B   2
+#define HNSV2_TXD_L3CS_B   3
+#define HNSV2_TXD_FE_B   4
+#define HNSV2_TXD_VLD_B  5
+
+#define HNSV2_TXD_TSE_B   0
+#define HNSV2_TXD_VLAN_EN_B   1
+#define HNSV2_TXD_SNAP_B   2
+#define HNSV2_TXD_IPV6_B   3
+#define HNSV2_TXD_SCTP_B   4
+
 /* hardware spec ring buffer format */
 struct __packed hnae_desc {
 	__le64 addr;
 	union {
 		struct {
-			__le16 asid_bufnum_pid;
+			union {
+				__le16 asid_bufnum_pid;
+				__le16 asid;
+			};
 			__le16 send_size;
-			__le32 flag_ipoffset;
-			__le32 reserved_3[4];
+			union {
+				__le32 flag_ipoffset;
+				struct {
+					__u8 bn_pid;
+					__u8 ra_ri_cs_fe_vld;
+					__u8 ip_offset;
+					__u8 tse_vlan_snap_v6_sctp_nth;
+				};
+			};
+			__le16 mss;
+			__u8 l4_len;
+			__u8 reserved1;
+			__le16 paylen;
+			__u8 vmid;
+			__u8 qid;
+			__le32 reserved2[2];
 		} tx;
 
 		struct {
 			__le32 ipoff_bnum_pid_flag;
 			__le16 pkt_len;
 			__le16 size;
-			__le32 vlan_pri_asid;
-			__le32 reserved_2[3];
+			union {
+				__le32 vlan_pri_asid;
+				struct {
+					__le16 asid;
+					__le16 vlan_cfi_pri;
+				};
+			};
+			__le32 rss_hash;
+			__le32 reserved_1[2];
 		} rx;
 	};
 };
@@ -551,11 +588,9 @@ static inline void hnae_replace_buffer(struct hnae_ring *ring, int i,
 				       struct hnae_desc_cb *res_cb)
 {
 	struct hnae_buf_ops *bops = ring->q->handle->bops;
-	struct hnae_desc_cb tmp_cb = ring->desc_cb[i];
 
 	bops->unmap_buffer(ring, &ring->desc_cb[i]);
 	ring->desc_cb[i] = *res_cb;
-	*res_cb = tmp_cb;
 	ring->desc[i].addr = (__le64)ring->desc_cb[i].dma;
 	ring->desc[i].rx.ipoff_bnum_pid_flag = 0;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 1a16c03..c3d64ce 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -334,12 +334,30 @@ void hns_ae_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
 	else
 		flag = RCB_INT_FLAG_RX;
 
-	hns_rcb_int_clr_hw(ring->q, flag);
 	hns_rcb_int_ctrl_hw(ring->q, flag, mask);
 }
 
+void hns_aev2_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
+{
+	u32 flag;
+
+	if (is_tx_ring(ring))
+		flag = RCB_INT_FLAG_TX;
+	else
+		flag = RCB_INT_FLAG_RX;
+
+	hns_rcbv2_int_ctrl_hw(ring->q, flag, mask);
+}
+
 static void hns_ae_toggle_queue_status(struct hnae_queue *queue, u32 val)
 {
+	struct dsaf_device *dsaf_dev = hns_ae_get_dsaf_dev(queue->dev);
+
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
+		hns_rcb_int_clr_hw(queue, RCB_INT_FLAG_TX | RCB_INT_FLAG_RX);
+	else
+		hns_rcbv2_int_clr_hw(queue, RCB_INT_FLAG_TX | RCB_INT_FLAG_RX);
+
 	hns_rcb_start(queue, val);
 }
 
@@ -771,6 +789,16 @@ int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev)
 {
 	struct hnae_ae_dev *ae_dev = &dsaf_dev->ae_dev;
 
+	switch (dsaf_dev->dsaf_ver) {
+	case AE_VERSION_1:
+		hns_dsaf_ops.toggle_ring_irq = hns_ae_toggle_ring_irq;
+		break;
+	case AE_VERSION_2:
+		hns_dsaf_ops.toggle_ring_irq = hns_aev2_toggle_ring_irq;
+		break;
+	default:
+		break;
+	}
 	ae_dev->ops = &hns_dsaf_ops;
 	ae_dev->dev = dsaf_dev->dev;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 2a98eba..0ab7e0f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -38,10 +38,10 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	const char *name, *mode_str;
 	struct device_node *np = dsaf_dev->dev->of_node;
 
-	if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v2"))
-		dsaf_dev->dsaf_ver = AE_VERSION_2;
-	else
+	if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v1"))
 		dsaf_dev->dsaf_ver = AE_VERSION_1;
+	else
+		dsaf_dev->dsaf_ver = AE_VERSION_2;
 
 	ret = of_property_read_string(np, "dsa_name", &name);
 	if (ret) {
@@ -274,6 +274,8 @@ static void hns_dsaf_stp_port_type_cfg(struct dsaf_device *dsaf_dev,
 	}
 }
 
+#define HNS_DSAF_SBM_NUM(dev) \
+	(AE_IS_VER1((dev)->dsaf_ver) ? DSAF_SBM_NUM : DSAFV2_SBM_NUM)
 /**
  * hns_dsaf_sbm_cfg - config sbm
  * @dsaf_id: dsa fabric id
@@ -283,7 +285,7 @@ static void hns_dsaf_sbm_cfg(struct dsaf_device *dsaf_dev)
 	u32 o_sbm_cfg;
 	u32 i;
 
-	for (i = 0; i < DSAF_SBM_NUM; i++) {
+	for (i = 0; i < HNS_DSAF_SBM_NUM(dsaf_dev); i++) {
 		o_sbm_cfg = dsaf_read_dev(dsaf_dev,
 					  DSAF_SBM_CFG_REG_0_REG + 0x80 * i);
 		dsaf_set_bit(o_sbm_cfg, DSAF_SBM_CFG_EN_S, 1);
@@ -304,13 +306,19 @@ static int hns_dsaf_sbm_cfg_mib_en(struct dsaf_device *dsaf_dev)
 	u32 reg;
 	u32 read_cnt;
 
-	for (i = 0; i < DSAF_SBM_NUM; i++) {
+	/* validate configure by setting SBM_CFG_MIB_EN bit from 0 to 1. */
+	for (i = 0; i < HNS_DSAF_SBM_NUM(dsaf_dev); i++) {
+		reg = DSAF_SBM_CFG_REG_0_REG + 0x80 * i;
+		dsaf_set_dev_bit(dsaf_dev, reg, DSAF_SBM_CFG_MIB_EN_S, 0);
+	}
+
+	for (i = 0; i < HNS_DSAF_SBM_NUM(dsaf_dev); i++) {
 		reg = DSAF_SBM_CFG_REG_0_REG + 0x80 * i;
 		dsaf_set_dev_bit(dsaf_dev, reg, DSAF_SBM_CFG_MIB_EN_S, 1);
 	}
 
 	/* waitint for all sbm enable finished */
-	for (i = 0; i < DSAF_SBM_NUM; i++) {
+	for (i = 0; i < HNS_DSAF_SBM_NUM(dsaf_dev); i++) {
 		read_cnt = 0;
 		reg = DSAF_SBM_CFG_REG_0_REG + 0x80 * i;
 		do {
@@ -418,6 +426,89 @@ static void hns_dsaf_sbm_bp_wl_cfg(struct dsaf_device *dsaf_dev)
 	}
 }
 
+static void hns_dsafv2_sbm_bp_wl_cfg(struct dsaf_device *dsaf_dev)
+{
+	u32 o_sbm_bp_cfg0;
+	u32 o_sbm_bp_cfg1;
+	u32 o_sbm_bp_cfg2;
+	u32 o_sbm_bp_cfg3;
+	u32 o_sbm_bp_cfg4;
+	u32 reg;
+	u32 i;
+
+	/* XGE */
+	for (i = 0; i < DSAFV2_SBM_XGE_CHN; i++) {
+		reg = DSAF_SBM_BP_CFG_0_XGE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg0 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg0, DSAFV2_SBM_CFG0_COM_MAX_BUF_NUM_M,
+			       DSAFV2_SBM_CFG0_COM_MAX_BUF_NUM_S, 256);
+		dsaf_set_field(o_sbm_bp_cfg0, DSAFV2_SBM_CFG0_VC0_MAX_BUF_NUM_M,
+			       DSAFV2_SBM_CFG0_VC0_MAX_BUF_NUM_S, 0);
+		dsaf_set_field(o_sbm_bp_cfg0, DSAFV2_SBM_CFG0_VC1_MAX_BUF_NUM_M,
+			       DSAFV2_SBM_CFG0_VC1_MAX_BUF_NUM_S, 0);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg0);
+
+		reg = DSAF_SBM_BP_CFG_1_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg1 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg1, DSAFV2_SBM_CFG1_TC4_MAX_BUF_NUM_M,
+			       DSAFV2_SBM_CFG1_TC4_MAX_BUF_NUM_S, 0);
+		dsaf_set_field(o_sbm_bp_cfg1, DSAFV2_SBM_CFG1_TC0_MAX_BUF_NUM_M,
+			       DSAFV2_SBM_CFG1_TC0_MAX_BUF_NUM_S, 0);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg1);
+
+		reg = DSAF_SBM_BP_CFG_2_XGE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg2 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAFV2_SBM_CFG2_SET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_SET_BUF_NUM_S, 104);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAFV2_SBM_CFG2_RESET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_RESET_BUF_NUM_S, 128);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg2);
+
+		reg = DSAF_SBM_BP_CFG_3_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg3 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg3,
+			       DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_M,
+			       DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_S, 110);
+		dsaf_set_field(o_sbm_bp_cfg3,
+			       DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_M,
+			       DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S, 160);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg3);
+
+		/* for no enable pfc mode */
+		reg = DSAF_SBM_BP_CFG_4_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg4 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg4,
+			       DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_M,
+			       DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_S, 128);
+		dsaf_set_field(o_sbm_bp_cfg4,
+			       DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_M,
+			       DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S, 192);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg4);
+	}
+
+	/* PPE */
+	for (i = 0; i < DSAFV2_SBM_PPE_CHN; i++) {
+		reg = DSAF_SBM_BP_CFG_2_PPE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg2 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAFV2_SBM_CFG2_SET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_SET_BUF_NUM_S, 10);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAFV2_SBM_CFG2_RESET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_RESET_BUF_NUM_S, 12);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg2);
+	}
+
+	/* RoCEE */
+	for (i = 0; i < DSAFV2_SBM_ROCE_CHN; i++) {
+		reg = DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg2 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAFV2_SBM_CFG2_SET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_SET_BUF_NUM_S, 2);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAFV2_SBM_CFG2_RESET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_RESET_BUF_NUM_S, 4);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg2);
+	}
+}
+
 /**
  * hns_dsaf_voq_bp_all_thrd_cfg -  voq
  * @dsaf_id: dsa fabric id
@@ -985,11 +1076,38 @@ static void hns_dsaf_inode_init(struct dsaf_device *dsaf_dev)
 	else
 		tc_cfg = HNS_DSAF_I8TC_CFG;
 
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		for (i = 0; i < DSAF_INODE_NUM; i++) {
+			reg = DSAF_INODE_IN_PORT_NUM_0_REG + 0x80 * i;
+			dsaf_set_dev_field(dsaf_dev, reg,
+					   DSAF_INODE_IN_PORT_NUM_M,
+					   DSAF_INODE_IN_PORT_NUM_S,
+					   i % DSAF_XGE_NUM);
+		}
+	} else {
+		for (i = 0; i < DSAF_PORT_TYPE_NUM; i++) {
+			reg = DSAF_INODE_IN_PORT_NUM_0_REG + 0x80 * i;
+			dsaf_set_dev_field(dsaf_dev, reg,
+					   DSAF_INODE_IN_PORT_NUM_M,
+					   DSAF_INODE_IN_PORT_NUM_S, 0);
+			dsaf_set_dev_field(dsaf_dev, reg,
+					   DSAFV2_INODE_IN_PORT1_NUM_M,
+					   DSAFV2_INODE_IN_PORT1_NUM_S, 1);
+			dsaf_set_dev_field(dsaf_dev, reg,
+					   DSAFV2_INODE_IN_PORT2_NUM_M,
+					   DSAFV2_INODE_IN_PORT2_NUM_S, 2);
+			dsaf_set_dev_field(dsaf_dev, reg,
+					   DSAFV2_INODE_IN_PORT3_NUM_M,
+					   DSAFV2_INODE_IN_PORT3_NUM_S, 3);
+			dsaf_set_dev_field(dsaf_dev, reg,
+					   DSAFV2_INODE_IN_PORT4_NUM_M,
+					   DSAFV2_INODE_IN_PORT4_NUM_S, 4);
+			dsaf_set_dev_field(dsaf_dev, reg,
+					   DSAFV2_INODE_IN_PORT5_NUM_M,
+					   DSAFV2_INODE_IN_PORT5_NUM_S, 5);
+		}
+	}
 	for (i = 0; i < DSAF_INODE_NUM; i++) {
-		reg = DSAF_INODE_IN_PORT_NUM_0_REG + 0x80 * i;
-		dsaf_set_dev_field(dsaf_dev, reg, DSAF_INODE_IN_PORT_NUM_M,
-				   DSAF_INODE_IN_PORT_NUM_S, i % DSAF_XGE_NUM);
-
 		reg = DSAF_INODE_PRI_TC_CFG_0_REG + 0x80 * i;
 		dsaf_write_dev(dsaf_dev, reg, tc_cfg);
 	}
@@ -1002,10 +1120,18 @@ static void hns_dsaf_inode_init(struct dsaf_device *dsaf_dev)
 static int hns_dsaf_sbm_init(struct dsaf_device *dsaf_dev)
 {
 	u32 flag;
+	u32 finish_flag;
 	u32 cnt = 0;
 	int ret;
 
-	hns_dsaf_sbm_bp_wl_cfg(dsaf_dev);
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		hns_dsaf_sbm_bp_wl_cfg(dsaf_dev);
+		finish_flag = DSAF_SRAM_INIT_FINISH_FLAG;
+
+	} else {
+		hns_dsafv2_sbm_bp_wl_cfg(dsaf_dev);
+		finish_flag = DSAFV2_SRAM_INIT_FINISH_FLAG;
+	}
 
 	/* enable sbm chanel, disable sbm chanel shcut function*/
 	hns_dsaf_sbm_cfg(dsaf_dev);
@@ -1026,9 +1152,9 @@ static int hns_dsaf_sbm_init(struct dsaf_device *dsaf_dev)
 		usleep_range(200, 210);/*udelay(200);*/
 		flag = dsaf_read_dev(dsaf_dev, DSAF_SRAM_INIT_OVER_0_REG);
 		cnt++;
-	} while (flag != DSAF_SRAM_INIT_FINISH_FLAG && cnt < DSAF_CFG_READ_CNT);
+	} while (flag != finish_flag && cnt < DSAF_CFG_READ_CNT);
 
-	if (flag != DSAF_SRAM_INIT_FINISH_FLAG) {
+	if (flag != finish_flag) {
 		dev_err(dsaf_dev->dev,
 			"hns_dsaf_sbm_init fail %s, flag=%d, cnt=%d\n",
 			dsaf_dev->ae_dev.name, flag, cnt);
@@ -2032,7 +2158,7 @@ void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data)
 		DSAF_INODE_VC1_IN_PKT_NUM_0_REG + port * 4);
 
 	/* dsaf inode registers */
-	for (i = 0; i < DSAF_SBM_NUM / DSAF_COMM_CHN; i++) {
+	for (i = 0; i < HNS_DSAF_SBM_NUM(ddev) / DSAF_COMM_CHN; i++) {
 		j = i * DSAF_COMM_CHN + port;
 		p[232 + i] = dsaf_read_dev(ddev,
 				DSAF_SBM_CFG_REG_0_REG + j * 0x80);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index b2b9348..9f22031 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -37,6 +37,7 @@ struct hns_mac_cb;
 
 #define DSAF_CFG_READ_CNT   (30)
 #define DSAF_SRAM_INIT_FINISH_FLAG (0xff)
+#define DSAFV2_SRAM_INIT_FINISH_FLAG (0x3ff)
 
 #define MAC_NUM_OCTETS_PER_ADDR 6
 
@@ -274,10 +275,6 @@ struct dsaf_device {
 	struct device *dev;
 	struct hnae_ae_dev ae_dev;
 
-	void *priv;
-
-	int virq[DSAF_IRQ_NUM];
-
 	u8 __iomem *sc_base;
 	u8 __iomem *sds_base;
 	u8 __iomem *ppe_base;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index d611388..ecbbf2d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -156,7 +156,11 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 
 	if (port < DSAF_SERVICE_NW_NUM) {
 		reg_val_1  = 0x1 << port;
-		reg_val_2  = 0x1041041 << port;
+		/* there is difference between V1 and V2 in register.*/
+		if (AE_IS_VER1(dsaf_dev->dsaf_ver))
+			reg_val_2  = 0x1041041 << port;
+		else
+			reg_val_2  = 0x2082082 << port;
 
 		if (val == 0) {
 			dsaf_write_reg(dsaf_dev->sc_base,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 67f33f1..9531992 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -341,13 +341,13 @@ void hns_ppe_reset_common(struct dsaf_device *dsaf_dev, u8 ppe_common_index)
 	if (ret)
 		return;
 
+	for (i = 0; i < ppe_common->ppe_num; i++)
+		hns_ppe_init_hw(&ppe_common->ppe_cb[i]);
+
 	ret = hns_rcb_common_init_hw(dsaf_dev->rcb_common[ppe_common_index]);
 	if (ret)
 		return;
 
-	for (i = 0; i < ppe_common->ppe_num; i++)
-		hns_ppe_init_hw(&ppe_common->ppe_cb[i]);
-
 	hns_rcb_common_init_commit_hw(dsaf_dev->rcb_common[ppe_common_index]);
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 4db32c6..07303a1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -149,6 +149,28 @@ void hns_rcb_int_clr_hw(struct hnae_queue *q, u32 flag)
 	}
 }
 
+void hns_rcbv2_int_ctrl_hw(struct hnae_queue *q, u32 flag, u32 mask)
+{
+	u32 int_mask_en = !!mask;
+
+	if (flag & RCB_INT_FLAG_TX)
+		dsaf_write_dev(q, RCB_RING_INTMSK_TXWL_REG, int_mask_en);
+
+	if (flag & RCB_INT_FLAG_RX)
+		dsaf_write_dev(q, RCB_RING_INTMSK_RXWL_REG, int_mask_en);
+}
+
+void hns_rcbv2_int_clr_hw(struct hnae_queue *q, u32 flag)
+{
+	u32 clr = 1;
+
+	if (flag & RCB_INT_FLAG_TX)
+		dsaf_write_dev(q, RCBV2_TX_RING_INT_STS_REG, clr);
+
+	if (flag & RCB_INT_FLAG_RX)
+		dsaf_write_dev(q, RCBV2_RX_RING_INT_STS_REG, clr);
+}
+
 /**
  *hns_rcb_ring_enable_hw - enable ring
  *@ring: rcb ring
@@ -193,6 +215,7 @@ static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
 			       (u32)dma);
 		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_H_REG,
 			       (u32)((dma >> 31) >> 1));
+
 		dsaf_write_dev(q, RCB_RING_RX_RING_BD_LEN_REG,
 			       bd_size_type);
 		dsaf_write_dev(q, RCB_RING_RX_RING_BD_NUM_REG,
@@ -204,6 +227,7 @@ static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
 			       (u32)dma);
 		dsaf_write_dev(q, RCB_RING_TX_RING_BASEADDR_H_REG,
 			       (u32)((dma >> 31) >> 1));
+
 		dsaf_write_dev(q, RCB_RING_TX_RING_BD_LEN_REG,
 			       bd_size_type);
 		dsaf_write_dev(q, RCB_RING_TX_RING_BD_NUM_REG,
@@ -232,9 +256,6 @@ void hns_rcb_init_hw(struct ring_pair_cb *ring)
 static void hns_rcb_set_port_desc_cnt(struct rcb_common_cb *rcb_common,
 				      u32 port_idx, u32 desc_cnt)
 {
-	if (port_idx >= HNS_RCB_SERVICE_NW_ENGINE_NUM)
-		port_idx = 0;
-
 	dsaf_write_dev(rcb_common, RCB_CFG_BD_NUM_REG + port_idx * 4,
 		       desc_cnt);
 }
@@ -249,8 +270,6 @@ static int  hns_rcb_set_port_coalesced_frames(struct rcb_common_cb *rcb_common,
 					      u32 port_idx,
 					      u32 coalesced_frames)
 {
-	if (port_idx >= HNS_RCB_SERVICE_NW_ENGINE_NUM)
-		port_idx = 0;
 	if (coalesced_frames >= rcb_common->desc_num ||
 	    coalesced_frames > HNS_RCB_MAX_COALESCED_FRAMES)
 		return -EINVAL;
@@ -354,6 +373,9 @@ int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common)
 	dsaf_write_dev(rcb_common, RCB_COM_CFG_ENDIAN_REG,
 		       HNS_RCB_COMMON_ENDIAN);
 
+	dsaf_write_dev(rcb_common, RCB_COM_CFG_FNA_REG, 0x0);
+	dsaf_write_dev(rcb_common, RCB_COM_CFG_FA_REG, 0x1);
+
 	return 0;
 }
 
@@ -387,19 +409,23 @@ static void hns_rcb_ring_get_cfg(struct hnae_queue *q, int ring_type)
 	struct rcb_common_cb *rcb_common;
 	struct ring_pair_cb *ring_pair_cb;
 	u32 buf_size;
-	u16 desc_num;
-	int irq_idx;
+	u16 desc_num, mdnum_ppkt;
+	int irq_idx, is_ver1;
 
 	ring_pair_cb = container_of(q, struct ring_pair_cb, q);
+	is_ver1 = AE_IS_VER1(ring_pair_cb->rcb_common->dsaf_dev->dsaf_ver);
 	if (ring_type == RX_RING) {
 		ring = &q->rx_ring;
 		ring->io_base = ring_pair_cb->q.io_base;
 		irq_idx = HNS_RCB_IRQ_IDX_RX;
+		mdnum_ppkt = HNS_RCB_RING_MAX_BD_PER_PKT;
 	} else {
 		ring = &q->tx_ring;
 		ring->io_base = (u8 __iomem *)ring_pair_cb->q.io_base +
 			HNS_RCB_TX_REG_OFFSET;
 		irq_idx = HNS_RCB_IRQ_IDX_TX;
+		mdnum_ppkt = is_ver1 ? HNS_RCB_RING_MAX_TXBD_PER_PKT :
+				 HNS_RCBV2_RING_MAX_TXBD_PER_PKT;
 	}
 
 	rcb_common = ring_pair_cb->rcb_common;
@@ -414,7 +440,7 @@ static void hns_rcb_ring_get_cfg(struct hnae_queue *q, int ring_type)
 
 	ring->buf_size = buf_size;
 	ring->desc_num = desc_num;
-	ring->max_desc_num_per_pkt = HNS_RCB_RING_MAX_BD_PER_PKT;
+	ring->max_desc_num_per_pkt = mdnum_ppkt;
 	ring->max_raw_data_sz_per_desc = HNS_RCB_MAX_PKT_SIZE;
 	ring->max_pkt_size = HNS_RCB_MAX_PKT_SIZE;
 	ring->next_to_use = 0;
@@ -445,14 +471,22 @@ static int hns_rcb_get_port(struct rcb_common_cb *rcb_common, int ring_idx)
 	return port;
 }
 
+#define SERVICE_RING_IRQ_IDX(v1) \
+	((v1) ? HNS_SERVICE_RING_IRQ_IDX : HNSV2_SERVICE_RING_IRQ_IDX)
+#define DEBUG_RING_IRQ_IDX(v1) \
+	((v1) ? HNS_DEBUG_RING_IRQ_IDX : HNSV2_DEBUG_RING_IRQ_IDX)
+#define DEBUG_RING_IRQ_OFFSET(v1) \
+	((v1) ? HNS_DEBUG_RING_IRQ_OFFSET : HNSV2_DEBUG_RING_IRQ_OFFSET)
 static int hns_rcb_get_base_irq_idx(struct rcb_common_cb *rcb_common)
 {
 	int comm_index = rcb_common->comm_index;
+	int is_ver1 = AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver);
 
 	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
-		return HNS_SERVICE_RING_IRQ_IDX;
+		return SERVICE_RING_IRQ_IDX(is_ver1);
 	else
-		return HNS_DEBUG_RING_IRQ_IDX + (comm_index - 1) * 2;
+		return  DEBUG_RING_IRQ_IDX(is_ver1) +
+			(comm_index - 1) * DEBUG_RING_IRQ_OFFSET(is_ver1);
 }
 
 #define RCB_COMM_BASE_TO_RING_BASE(base, ringid)\
@@ -468,6 +502,10 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 	u32 ring_num = rcb_common->ring_num;
 	int base_irq_idx = hns_rcb_get_base_irq_idx(rcb_common);
 	struct device_node *np = rcb_common->dsaf_dev->dev->of_node;
+	struct platform_device *pdev =
+		container_of(rcb_common->dsaf_dev->dev,
+			     struct platform_device, dev);
+	int is_ver1 = AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver);
 
 	for (i = 0; i < ring_num; i++) {
 		ring_pair_cb = &rcb_common->ring_pair_cb[i];
@@ -477,10 +515,12 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 		ring_pair_cb->q.io_base =
 			RCB_COMM_BASE_TO_RING_BASE(rcb_common->io_base, i);
 		ring_pair_cb->port_id_in_dsa = hns_rcb_get_port(rcb_common, i);
-		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_TX]
-			= irq_of_parse_and_map(np, base_irq_idx + i * 2);
-		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX]
-			= irq_of_parse_and_map(np, base_irq_idx + i * 2 + 1);
+		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_TX] =
+		is_ver1 ? irq_of_parse_and_map(np, base_irq_idx + i * 2) :
+			  platform_get_irq(pdev, base_irq_idx + i * 3 + 1);
+		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX] =
+		is_ver1 ? irq_of_parse_and_map(np, base_irq_idx + i * 2 + 1) :
+			  platform_get_irq(pdev, base_irq_idx + i * 3);
 		ring_pair_cb->q.phy_base =
 			RCB_COMM_BASE_TO_RING_BASE(rcb_common->phy_base, i);
 		hns_rcb_ring_pair_get_cfg(ring_pair_cb);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
index 3a2afe2..29041b1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
@@ -26,6 +26,8 @@ struct rcb_common_cb;
 #define HNS_RCB_SERVICE_NW_ENGINE_NUM		DSAF_COMM_CHN
 #define HNS_RCB_DEBUG_NW_ENGINE_NUM		1
 #define HNS_RCB_RING_MAX_BD_PER_PKT		3
+#define HNS_RCB_RING_MAX_TXBD_PER_PKT		3
+#define HNS_RCBV2_RING_MAX_TXBD_PER_PKT		8
 #define HNS_RCB_MAX_PKT_SIZE MAC_MAX_MTU
 
 #define HNS_RCB_RING_MAX_PENDING_BD		1024
@@ -106,13 +108,17 @@ void hns_rcb_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index);
 int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common);
 void hns_rcb_start(struct hnae_queue *q, u32 val);
 void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common);
-void hns_rcb_common_init_commit_hw(struct rcb_common_cb *rcb_common);
 void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, int comm_index,
 			    u16 *max_vfn, u16 *max_q_per_vf);
 
+void hns_rcb_common_init_commit_hw(struct rcb_common_cb *rcb_common);
+
 void hns_rcb_ring_enable_hw(struct hnae_queue *q, u32 val);
 void hns_rcb_int_clr_hw(struct hnae_queue *q, u32 flag);
 void hns_rcb_int_ctrl_hw(struct hnae_queue *q, u32 flag, u32 enable);
+void hns_rcbv2_int_ctrl_hw(struct hnae_queue *q, u32 flag, u32 mask);
+void hns_rcbv2_int_clr_hw(struct hnae_queue *q, u32 flag);
+
 void hns_rcb_init_hw(struct ring_pair_cb *ring);
 void hns_rcb_reset_ring_hw(struct hnae_queue *q);
 void hns_rcb_wait_fbd_clean(struct hnae_queue **qs, int q_num, u32 flag);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index b475e1b..8b1ad00 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -10,21 +10,12 @@
 #ifndef _DSAF_REG_H_
 #define _DSAF_REG_H_
 
-#define HNS_GE_FIFO_ERR_INTNUM 8
-#define HNS_XGE_ERR_INTNUM 6
-#define HNS_RCB_COMM_ERR_INTNUM 12
-#define HNS_PPE_TNL_ERR_INTNUM 8
-#define HNS_DSAF_EVENT_INTNUM 21
-#define HNS_DEBUG_RING_INTNUM 4
-#define HNS_SERVICE_RING_INTNUM 256
-
-#define HNS_DEBUG_RING_IRQ_IDX (HNS_GE_FIFO_ERR_INTNUM + HNS_XGE_ERR_INTNUM +\
-		HNS_RCB_COMM_ERR_INTNUM + HNS_PPE_TNL_ERR_INTNUM +\
-		HNS_DSAF_EVENT_INTNUM)
-#define HNS_SERVICE_RING_IRQ_IDX (HNS_DEBUG_RING_IRQ_IDX +\
-		HNS_DEBUG_RING_INTNUM)
-
-#define DSAF_IRQ_NUM 18
+#define HNS_DEBUG_RING_IRQ_IDX 55
+#define HNS_SERVICE_RING_IRQ_IDX 59
+#define HNS_DEBUG_RING_IRQ_OFFSET 2
+#define HNSV2_DEBUG_RING_IRQ_IDX 409
+#define HNSV2_SERVICE_RING_IRQ_IDX 25
+#define HNSV2_DEBUG_RING_IRQ_OFFSET 9
 
 #define DSAF_MAX_PORT_NUM_PER_CHIP 8
 #define DSAF_SERVICE_PORT_NUM_PER_DSAF 6
@@ -39,9 +30,14 @@
 #define DSAF_GE_NUM		((DSAF_SERVICE_NW_NUM) + (DSAF_DEBUG_NW_NUM))
 #define DSAF_PORT_NUM		((DSAF_SERVICE_NW_NUM) + (DSAF_DEBUG_NW_NUM))
 #define DSAF_XGE_NUM		DSAF_SERVICE_NW_NUM
+#define DSAF_PORT_TYPE_NUM 3
 #define DSAF_NODE_NUM		18
 #define DSAF_XOD_BIG_NUM	DSAF_NODE_NUM
 #define DSAF_SBM_NUM		DSAF_NODE_NUM
+#define DSAFV2_SBM_NUM		8
+#define DSAFV2_SBM_XGE_CHN    6
+#define DSAFV2_SBM_PPE_CHN    1
+#define DSAFV2_SBM_ROCE_CHN   1
 #define DSAF_VOQ_NUM		DSAF_NODE_NUM
 #define DSAF_INODE_NUM		DSAF_NODE_NUM
 #define DSAF_XOD_NUM		8
@@ -178,6 +174,7 @@
 #define DSAF_SBM_BP_CFG_2_XGE_REG_0_REG		0x200C
 #define DSAF_SBM_BP_CFG_2_PPE_REG_0_REG		0x230C
 #define DSAF_SBM_BP_CFG_2_ROCEE_REG_0_REG	0x260C
+#define DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG		 0x238C
 #define DSAF_SBM_FREE_CNT_0_0_REG		0x2010
 #define DSAF_SBM_FREE_CNT_1_0_REG		0x2014
 #define DSAF_SBM_BP_CNT_0_0_REG			0x2018
@@ -431,8 +428,10 @@
 
 #define RCB_RING_INTMSK_RXWL_REG		0x000A0
 #define RCB_RING_INTSTS_RX_RING_REG		0x000A4
+#define RCBV2_RX_RING_INT_STS_REG		0x000A8
 #define RCB_RING_INTMSK_TXWL_REG		0x000AC
 #define RCB_RING_INTSTS_TX_RING_REG		0x000B0
+#define RCBV2_TX_RING_INT_STS_REG		0x000B4
 #define RCB_RING_INTMSK_RX_OVERTIME_REG		0x000B8
 #define RCB_RING_INTSTS_RX_OVERTIME_REG		0x000BC
 #define RCB_RING_INTMSK_TX_OVERTIME_REG		0x000C4
@@ -685,6 +684,7 @@
 #define DSAF_CFG_MIX_MODE_S 4
 #define DSAF_CFG_STP_MODE_S 5
 #define DSAF_CFG_LOCA_ADDR_EN_S 6
+#define DSAFV2_CFG_VLAN_TAG_MODE_S 17
 
 #define DSAF_CNT_CLR_CE_S 0
 #define DSAF_SNAP_EN_S 1
@@ -707,6 +707,16 @@
 
 #define DSAF_INODE_IN_PORT_NUM_M 7
 #define DSAF_INODE_IN_PORT_NUM_S 0
+#define DSAFV2_INODE_IN_PORT1_NUM_M (7ULL << 3)
+#define DSAFV2_INODE_IN_PORT1_NUM_S 3
+#define DSAFV2_INODE_IN_PORT2_NUM_M (7ULL << 6)
+#define DSAFV2_INODE_IN_PORT2_NUM_S 6
+#define DSAFV2_INODE_IN_PORT3_NUM_M (7ULL << 9)
+#define DSAFV2_INODE_IN_PORT3_NUM_S 9
+#define DSAFV2_INODE_IN_PORT4_NUM_M (7ULL << 12)
+#define DSAFV2_INODE_IN_PORT4_NUM_S 12
+#define DSAFV2_INODE_IN_PORT5_NUM_M (7ULL << 15)
+#define DSAFV2_INODE_IN_PORT5_NUM_S 15
 
 #define HNS_DSAF_I4TC_CFG 0x18688688
 #define HNS_DSAF_I8TC_CFG 0x18FAC688
@@ -738,6 +748,33 @@
 #define DSAF_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S 10
 #define DSAF_SBM_CFG3_RESET_BUF_NUM_NO_PFC_M (((1ULL << 10) - 1) << 10)
 
+#define DSAFV2_SBM_CFG0_VC1_MAX_BUF_NUM_S 0
+#define DSAFV2_SBM_CFG0_VC1_MAX_BUF_NUM_M (((1ULL << 9) - 1) << 0)
+#define DSAFV2_SBM_CFG0_VC0_MAX_BUF_NUM_S 9
+#define DSAFV2_SBM_CFG0_VC0_MAX_BUF_NUM_M (((1ULL << 9) - 1) << 9)
+#define DSAFV2_SBM_CFG0_COM_MAX_BUF_NUM_S 18
+#define DSAFV2_SBM_CFG0_COM_MAX_BUF_NUM_M (((1ULL << 10) - 1) << 18)
+
+#define DSAFV2_SBM_CFG1_TC4_MAX_BUF_NUM_S 0
+#define DSAFV2_SBM_CFG1_TC4_MAX_BUF_NUM_M (((1ULL << 9) - 1) << 0)
+#define DSAFV2_SBM_CFG1_TC0_MAX_BUF_NUM_S 9
+#define DSAFV2_SBM_CFG1_TC0_MAX_BUF_NUM_M (((1ULL << 9) - 1) << 9)
+
+#define DSAFV2_SBM_CFG2_SET_BUF_NUM_S 0
+#define DSAFV2_SBM_CFG2_SET_BUF_NUM_M (((1ULL << 9) - 1) << 0)
+#define DSAFV2_SBM_CFG2_RESET_BUF_NUM_S 9
+#define DSAFV2_SBM_CFG2_RESET_BUF_NUM_M (((1ULL << 9) - 1) << 9)
+
+#define DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_S 0
+#define DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_M (((1ULL << 9) - 1) << 0)
+#define DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S 9
+#define DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_M (((1ULL << 9) - 1) << 9)
+
+#define DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_S 0
+#define DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_M (((1ULL << 9) - 1) << 0)
+#define DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S 9
+#define DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_M (((1ULL << 9) - 1) << 9)
+
 #define DSAF_TBL_TCAM_ADDR_S 0
 #define DSAF_TBL_TCAM_ADDR_M ((1ULL << 9) - 1)
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 302d3ae..7d996a4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -34,9 +34,103 @@
 #define RCB_IRQ_NOT_INITED 0
 #define RCB_IRQ_INITED 1
 
+#define BD_MAX_SEND_SIZE 8191
+#define SKB_TMP_LEN(SKB) \
+	(((SKB)->transport_header - (SKB)->mac_header) + tcp_hdrlen(SKB))
+
+static void fill_v2_desc(struct hnae_ring *ring, void *priv,
+			 int size, dma_addr_t dma, int frag_end,
+			 int buf_num, enum hns_desc_type type, int mtu)
+{
+	struct hnae_desc *desc = &ring->desc[ring->next_to_use];
+	struct hnae_desc_cb *desc_cb = &ring->desc_cb[ring->next_to_use];
+	struct iphdr *iphdr;
+	struct ipv6hdr *ipv6hdr;
+	struct sk_buff *skb;
+	int skb_tmp_len;
+	__be16 protocol;
+	u8 bn_pid = 0;
+	u8 rrcfv = 0;
+	u8 ip_offset = 0;
+	u8 tvsvsn = 0;
+	u16 mss = 0;
+	u8 l4_len = 0;
+	u16 paylen = 0;
+
+	desc_cb->priv = priv;
+	desc_cb->length = size;
+	desc_cb->dma = dma;
+	desc_cb->type = type;
+
+	desc->addr = cpu_to_le64(dma);
+	desc->tx.send_size = cpu_to_le16((u16)size);
+
+	/*config bd buffer end */
+	hnae_set_bit(rrcfv, HNSV2_TXD_VLD_B, 1);
+	hnae_set_field(bn_pid, 0x7, 0, buf_num - 1);
+
+	if (type == DESC_TYPE_SKB) {
+		skb = (struct sk_buff *)priv;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			skb_reset_mac_len(skb);
+			protocol = skb->protocol;
+			ip_offset = ETH_HLEN;
+
+			if (protocol == htons(ETH_P_8021Q)) {
+				ip_offset += VLAN_HLEN;
+				protocol = vlan_get_protocol(skb);
+				skb->protocol = protocol;
+			}
+
+			if (skb->protocol == htons(ETH_P_IP)) {
+				iphdr = ip_hdr(skb);
+				hnae_set_bit(rrcfv, HNSV2_TXD_L3CS_B, 1);
+				hnae_set_bit(rrcfv, HNSV2_TXD_L4CS_B, 1);
+
+				/* check for tcp/udp header */
+				if (iphdr->protocol == IPPROTO_TCP) {
+					hnae_set_bit(tvsvsn,
+						     HNSV2_TXD_TSE_B, 1);
+					skb_tmp_len = SKB_TMP_LEN(skb);
+					l4_len = tcp_hdrlen(skb);
+					mss = mtu - skb_tmp_len - ETH_FCS_LEN;
+					paylen = skb->len - skb_tmp_len;
+				}
+			} else if (skb->protocol == htons(ETH_P_IPV6)) {
+				hnae_set_bit(tvsvsn, HNSV2_TXD_IPV6_B, 1);
+				ipv6hdr = ipv6_hdr(skb);
+				hnae_set_bit(rrcfv, HNSV2_TXD_L4CS_B, 1);
+
+				/* check for tcp/udp header */
+				if (ipv6hdr->nexthdr == IPPROTO_TCP) {
+					hnae_set_bit(tvsvsn,
+						     HNSV2_TXD_TSE_B, 1);
+					skb_tmp_len = SKB_TMP_LEN(skb);
+					l4_len = tcp_hdrlen(skb);
+					mss = mtu - skb_tmp_len - ETH_FCS_LEN;
+					paylen = skb->len - skb_tmp_len;
+				}
+			}
+			desc->tx.ip_offset = ip_offset;
+			desc->tx.tse_vlan_snap_v6_sctp_nth = tvsvsn;
+			desc->tx.mss = cpu_to_le16(mss);
+			desc->tx.l4_len = l4_len;
+			desc->tx.paylen = cpu_to_le16(paylen);
+		}
+	}
+
+	hnae_set_bit(rrcfv, HNSV2_TXD_FE_B, frag_end);
+
+	desc->tx.bn_pid = bn_pid;
+	desc->tx.ra_ri_cs_fe_vld = rrcfv;
+
+	ring_ptr_move_fw(ring, next_to_use);
+}
+
 static void fill_desc(struct hnae_ring *ring, void *priv,
 		      int size, dma_addr_t dma, int frag_end,
-		      int buf_num, enum hns_desc_type type)
+		      int buf_num, enum hns_desc_type type, int mtu)
 {
 	struct hnae_desc *desc = &ring->desc[ring->next_to_use];
 	struct hnae_desc_cb *desc_cb = &ring->desc_cb[ring->next_to_use];
@@ -100,47 +194,64 @@ static void unfill_desc(struct hnae_ring *ring)
 	ring_ptr_move_bw(ring, next_to_use);
 }
 
-int hns_nic_net_xmit_hw(struct net_device *ndev,
-			struct sk_buff *skb,
-			struct hns_nic_ring_data *ring_data)
+static int hns_nic_maybe_stop_tx(
+	struct sk_buff **out_skb, int *bnum, struct hnae_ring *ring)
 {
-	struct hns_nic_priv *priv = netdev_priv(ndev);
-	struct device *dev = priv->dev;
-	struct hnae_ring *ring = ring_data->ring;
-	struct netdev_queue *dev_queue;
-	struct skb_frag_struct *frag;
+	struct sk_buff *skb = *out_skb;
+	struct sk_buff *new_skb = NULL;
 	int buf_num;
-	dma_addr_t dma;
-	int size, next_to_use;
-	int i, j;
-	struct sk_buff *new_skb;
-
-	assert(ring->max_desc_num_per_pkt <= ring->desc_num);
 
 	/* no. of segments (plus a header) */
 	buf_num = skb_shinfo(skb)->nr_frags + 1;
 
 	if (unlikely(buf_num > ring->max_desc_num_per_pkt)) {
-		if (ring_space(ring) < 1) {
-			ring->stats.tx_busy++;
-			goto out_net_tx_busy;
-		}
+		if (ring_space(ring) < 1)
+			return -EBUSY;
 
 		new_skb = skb_copy(skb, GFP_ATOMIC);
-		if (!new_skb) {
-			ring->stats.sw_err_cnt++;
-			netdev_err(ndev, "no memory to xmit!\n");
-			goto out_err_tx_ok;
-		}
+		if (!new_skb)
+			return -ENOMEM;
 
 		dev_kfree_skb_any(skb);
-		skb = new_skb;
+		*out_skb = new_skb;
 		buf_num = 1;
-		assert(skb_shinfo(skb)->nr_frags == 1);
 	} else if (buf_num > ring_space(ring)) {
+		return -EBUSY;
+	}
+
+	*bnum = buf_num;
+	return 0;
+}
+
+int hns_nic_net_xmit_hw(struct net_device *ndev,
+			struct sk_buff *skb,
+			struct hns_nic_ring_data *ring_data)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct device *dev = priv->dev;
+	struct hnae_ring *ring = ring_data->ring;
+	struct netdev_queue *dev_queue;
+	struct skb_frag_struct *frag;
+	int buf_num;
+	int seg_num;
+	dma_addr_t dma;
+	int size, next_to_use;
+	int i;
+
+	switch (priv->ops.maybe_stop_tx(&skb, &buf_num, ring)) {
+	case -EBUSY:
 		ring->stats.tx_busy++;
 		goto out_net_tx_busy;
+	case -ENOMEM:
+		ring->stats.sw_err_cnt++;
+		netdev_err(ndev, "no memory to xmit!\n");
+		goto out_err_tx_ok;
+	default:
+		break;
 	}
+
+	/* no. of segments (plus a header) */
+	seg_num = skb_shinfo(skb)->nr_frags + 1;
 	next_to_use = ring->next_to_use;
 
 	/* fill the first part */
@@ -151,11 +262,11 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
 		ring->stats.sw_err_cnt++;
 		goto out_err_tx_ok;
 	}
-	fill_desc(ring, skb, size, dma, buf_num == 1 ? 1 : 0, buf_num,
-		  DESC_TYPE_SKB);
+	priv->ops.fill_desc(ring, skb, size, dma, seg_num == 1 ? 1 : 0,
+			    buf_num, DESC_TYPE_SKB, ndev->mtu);
 
 	/* fill the fragments */
-	for (i = 1; i < buf_num; i++) {
+	for (i = 1; i < seg_num; i++) {
 		frag = &skb_shinfo(skb)->frags[i - 1];
 		size = skb_frag_size(frag);
 		dma = skb_frag_dma_map(dev, frag, 0, size, DMA_TO_DEVICE);
@@ -164,8 +275,9 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
 			ring->stats.sw_err_cnt++;
 			goto out_map_frag_fail;
 		}
-		fill_desc(ring, skb_frag_page(frag), size, dma,
-			  buf_num - 1 == i ? 1 : 0, buf_num, DESC_TYPE_PAGE);
+		priv->ops.fill_desc(ring, skb_frag_page(frag), size, dma,
+				    seg_num - 1 == i ? 1 : 0, buf_num,
+				    DESC_TYPE_PAGE, ndev->mtu);
 	}
 
 	/*complete translate all packets*/
@@ -182,19 +294,20 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
 
 out_map_frag_fail:
 
-	for (j = i - 1; j > 0; j--) {
+	while (ring->next_to_use != next_to_use) {
 		unfill_desc(ring);
-		next_to_use = ring->next_to_use;
-		dma_unmap_page(dev, ring->desc_cb[next_to_use].dma,
-			       ring->desc_cb[next_to_use].length,
-			       DMA_TO_DEVICE);
+		if (ring->next_to_use != next_to_use)
+			dma_unmap_page(dev,
+				       ring->desc_cb[ring->next_to_use].dma,
+				       ring->desc_cb[ring->next_to_use].length,
+				       DMA_TO_DEVICE);
+		else
+			dma_unmap_single(dev,
+					 ring->desc_cb[next_to_use].dma,
+					 ring->desc_cb[next_to_use].length,
+					 DMA_TO_DEVICE);
 	}
 
-	unfill_desc(ring);
-	next_to_use = ring->next_to_use;
-	dma_unmap_single(dev, ring->desc_cb[next_to_use].dma,
-			 ring->desc_cb[next_to_use].length, DMA_TO_DEVICE);
-
 out_err_tx_ok:
 
 	dev_kfree_skb_any(skb);
@@ -302,7 +415,8 @@ static unsigned int hns_nic_get_headlen(unsigned char *data, u32 flag,
 		network += sizeof(struct udphdr);
 	}
 
-	/* If everything has gone correctly network should be the
+	/**
+	 * If everything has gone correctly network should be the
 	 * data section of the packet and will be the end of the header.
 	 * If not then it probably represents the end of the last recognized
 	 * header.
@@ -329,11 +443,24 @@ hns_nic_reuse_page(struct hnae_desc_cb *desc_cb, int tsize, int last_offset)
 	}
 }
 
+static void get_v2rx_desc_bnum(u32 bnum_flag, int *out_bnum)
+{
+	*out_bnum = hnae_get_field(bnum_flag,
+				   HNS_RXD_BUFNUM_M, HNS_RXD_BUFNUM_S) + 1;
+}
+
+static void get_rx_desc_bnum(u32 bnum_flag, int *out_bnum)
+{
+	*out_bnum = hnae_get_field(bnum_flag,
+				   HNS_RXD_BUFNUM_M, HNS_RXD_BUFNUM_S);
+}
+
 static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 			       struct sk_buff **out_skb, int *out_bnum)
 {
 	struct hnae_ring *ring = ring_data->ring;
 	struct net_device *ndev = ring_data->napi.dev;
+	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct sk_buff *skb;
 	struct hnae_desc *desc;
 	struct hnae_desc_cb *desc_cb;
@@ -345,19 +472,37 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 	last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
 	desc = &ring->desc[ring->next_to_clean];
 	desc_cb = &ring->desc_cb[ring->next_to_clean];
-	length = le16_to_cpu(desc->rx.pkt_len);
-	bnum_flag = le32_to_cpu(desc->rx.ipoff_bnum_pid_flag);
-	bnum = hnae_get_field(bnum_flag, HNS_RXD_BUFNUM_M, HNS_RXD_BUFNUM_S);
-	*out_bnum = bnum;
+
+	prefetch(desc);
+
 	va = (unsigned char *)desc_cb->buf + desc_cb->page_offset;
 
-	skb = *out_skb = napi_alloc_skb(&ring_data->napi, HNS_RX_HEAD_SIZE);
+	/* prefetch first cache line of first page */
+	prefetch(va);
+#if L1_CACHE_BYTES < 128
+	prefetch(va + L1_CACHE_BYTES);
+#endif
+
+	skb = *out_skb = napi_alloc_skb(&ring_data->napi,
+					HNS_RX_HEAD_SIZE);
 	if (unlikely(!skb)) {
 		netdev_err(ndev, "alloc rx skb fail\n");
 		ring->stats.sw_err_cnt++;
 		return -ENOMEM;
 	}
 
+	length = le16_to_cpu(desc->rx.pkt_len);
+	bnum_flag = le32_to_cpu(desc->rx.ipoff_bnum_pid_flag);
+	priv->ops.get_rxd_bnum(bnum_flag, &bnum);
+	*out_bnum = bnum;
+
+	/**
+	 * we will be copying header into skb->data in
+	 * pskb_may_pull so it is in our interest to prefetch
+	 * it now to avoid a possible cache miss
+	 */
+	prefetchw(skb->data);
+
 	if (length <= HNS_RX_HEAD_SIZE) {
 		memcpy(__skb_put(skb, length), va, ALIGN(length, sizeof(long)));
 
@@ -540,20 +685,19 @@ recv:
 	}
 
 	/* make all data has been write before submit */
-	if (clean_count > 0) {
-		hns_nic_alloc_rx_buffers(ring_data, clean_count);
-		clean_count = 0;
-	}
-
 	if (recv_pkts < budget) {
 		ex_num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
 		rmb(); /*complete read rx ring bd number*/
-		if (ex_num > 0) {
-			num += ex_num;
+		if (ex_num > clean_count) {
+			num += ex_num - clean_count;
 			goto recv;
 		}
 	}
 
+	/* make all data has been write before submit */
+	if (clean_count > 0)
+		hns_nic_alloc_rx_buffers(ring_data, clean_count);
+
 	return recv_pkts;
 }
 
@@ -650,6 +794,9 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 	dev_queue = netdev_get_tx_queue(ndev, ring_data->queue_index);
 	netdev_tx_completed_queue(dev_queue, pkts, bytes);
 
+	if (unlikely(priv->link && !netif_carrier_ok(ndev)))
+		netif_carrier_on(ndev);
+
 	if (unlikely(pkts && netif_carrier_ok(ndev) &&
 		     (ring_space(ring) >= ring->max_desc_num_per_pkt * 2))) {
 		/* Make sure that anybody stopping the queue after this
@@ -848,15 +995,58 @@ static void hns_nic_ring_close(struct net_device *netdev, int idx)
 	napi_disable(&priv->ring_data[idx].napi);
 }
 
-static int hns_nic_init_irq(struct hns_nic_priv *priv)
+void hns_set_irq_affinity(struct hns_nic_priv *priv)
 {
 	struct hnae_handle *h = priv->ae_handle;
 	struct hns_nic_ring_data *rd;
 	int i;
-	int ret;
 	int cpu;
 	cpumask_t mask;
 
+	/*diffrent irq banlance for 16core and 32core*/
+	if (h->q_num == num_possible_cpus()) {
+		for (i = 0; i < h->q_num * 2; i++) {
+			rd = &priv->ring_data[i];
+			if (cpu_online(rd->queue_index)) {
+				cpumask_clear(&mask);
+				cpu = rd->queue_index;
+				cpumask_set_cpu(cpu, &mask);
+				(void)irq_set_affinity_hint(rd->ring->irq,
+							    &mask);
+			}
+		}
+	} else {
+		for (i = 0; i < h->q_num; i++) {
+			rd = &priv->ring_data[i];
+			if (cpu_online(rd->queue_index * 2)) {
+				cpumask_clear(&mask);
+				cpu = rd->queue_index * 2;
+				cpumask_set_cpu(cpu, &mask);
+				(void)irq_set_affinity_hint(rd->ring->irq,
+							    &mask);
+			}
+		}
+
+		for (i = h->q_num; i < h->q_num * 2; i++) {
+			rd = &priv->ring_data[i];
+			if (cpu_online(rd->queue_index * 2 + 1)) {
+				cpumask_clear(&mask);
+				cpu = rd->queue_index * 2 + 1;
+				cpumask_set_cpu(cpu, &mask);
+				(void)irq_set_affinity_hint(rd->ring->irq,
+							    &mask);
+			}
+		}
+	}
+}
+
+static int hns_nic_init_irq(struct hns_nic_priv *priv)
+{
+	struct hnae_handle *h = priv->ae_handle;
+	struct hns_nic_ring_data *rd;
+	int i;
+	int ret;
+
 	for (i = 0; i < h->q_num * 2; i++) {
 		rd = &priv->ring_data[i];
 
@@ -878,16 +1068,11 @@ static int hns_nic_init_irq(struct hns_nic_priv *priv)
 		}
 		disable_irq(rd->ring->irq);
 		rd->ring->irq_init_flag = RCB_IRQ_INITED;
-
-		/*set cpu affinity*/
-		if (cpu_online(rd->queue_index)) {
-			cpumask_clear(&mask);
-			cpu = rd->queue_index;
-			cpumask_set_cpu(cpu, &mask);
-			irq_set_affinity_hint(rd->ring->irq, &mask);
-		}
 	}
 
+	/*set cpu affinity*/
+	hns_set_irq_affinity(priv);
+
 	return 0;
 }
 
@@ -1315,22 +1500,26 @@ static void hns_nic_reset_subtask(struct hns_nic_priv *priv)
 		return;
 
 	hns_nic_dump(priv);
-	netdev_info(priv->netdev, "Reset %s port\n",
-		    (type == HNAE_PORT_DEBUG ? "debug" : "business"));
+	netdev_info(priv->netdev, "try to reset %s port!\n",
+		    (type == HNAE_PORT_DEBUG ? "debug" : "service"));
 
 	rtnl_lock();
 	/* put off any impending NetWatchDogTimeout */
 	priv->netdev->trans_start = jiffies;
 
-	if (type == HNAE_PORT_DEBUG)
+	if (type == HNAE_PORT_DEBUG) {
 		hns_nic_net_reinit(priv->netdev);
+	} else {
+		netif_carrier_off(priv->netdev);
+		netif_tx_disable(priv->netdev);
+	}
 	rtnl_unlock();
 }
 
 /* for doing service complete*/
 static void hns_nic_service_event_complete(struct hns_nic_priv *priv)
 {
-	assert(!test_bit(NIC_STATE_SERVICE_SCHED, &priv->state));
+	WARN_ON(!test_bit(NIC_STATE_SERVICE_SCHED, &priv->state));
 
 	smp_mb__before_atomic();
 	clear_bit(NIC_STATE_SERVICE_SCHED, &priv->state);
@@ -1435,8 +1624,9 @@ static void hns_nic_uninit_ring_data(struct hns_nic_priv *priv)
 	for (i = 0; i < h->q_num * 2; i++) {
 		netif_napi_del(&priv->ring_data[i].napi);
 		if (priv->ring_data[i].ring->irq_init_flag == RCB_IRQ_INITED) {
-			irq_set_affinity_hint(priv->ring_data[i].ring->irq,
-					      NULL);
+			(void)irq_set_affinity_hint(
+				priv->ring_data[i].ring->irq,
+				NULL);
 			free_irq(priv->ring_data[i].ring->irq,
 				 &priv->ring_data[i]);
 		}
@@ -1446,6 +1636,21 @@ static void hns_nic_uninit_ring_data(struct hns_nic_priv *priv)
 	kfree(priv->ring_data);
 }
 
+static void hns_nic_set_priv_ops(struct net_device *netdev)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+
+	if (AE_IS_VER1(priv->enet_ver)) {
+		priv->ops.fill_desc = fill_desc;
+		priv->ops.get_rxd_bnum = get_rx_desc_bnum;
+		priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tx;
+	} else {
+		priv->ops.get_rxd_bnum = get_v2rx_desc_bnum;
+		priv->ops.fill_desc = fill_v2_desc;
+		priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tx;
+	}
+}
+
 static int hns_nic_try_get_ae(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
@@ -1473,6 +1678,8 @@ static int hns_nic_try_get_ae(struct net_device *ndev)
 		goto out_init_ring_data;
 	}
 
+	hns_nic_set_priv_ops(ndev);
+
 	ret = register_netdev(ndev);
 	if (ret) {
 		dev_err(priv->dev, "probe register netdev fail!\n");
@@ -1524,10 +1731,10 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	priv->dev = dev;
 	priv->netdev = ndev;
 
-	if (of_device_is_compatible(node, "hisilicon,hns-nic-v2"))
-		priv->enet_ver = AE_VERSION_2;
-	else
+	if (of_device_is_compatible(node, "hisilicon,hns-nic-v1"))
 		priv->enet_ver = AE_VERSION_1;
+	else
+		priv->enet_ver = AE_VERSION_2;
 
 	ret = of_property_read_string(node, "ae-name", &priv->ae_name);
 	if (ret)
@@ -1543,6 +1750,7 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	ndev->priv_flags |= IFF_UNICAST_FLT;
 	ndev->netdev_ops = &hns_nic_netdev_ops;
 	hns_ethtool_set_ops(ndev);
+
 	ndev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_GSO |
 		NETIF_F_GRO;
@@ -1550,6 +1758,16 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
 	ndev->vlan_features |= NETIF_F_SG | NETIF_F_GSO | NETIF_F_GRO;
 
+	switch (priv->enet_ver) {
+	case AE_VERSION_2:
+		ndev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+			NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_GSO |
+			NETIF_F_GRO;
+		break;
+	default:
+		break;
+	}
+
 	SET_NETDEV_DEV(ndev, dev);
 
 	if (!dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)))
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
index dae0ed1..4b75270 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
@@ -40,6 +40,16 @@ struct hns_nic_ring_data {
 	void (*fini_process)(struct hns_nic_ring_data *);
 };
 
+/* compatible the difference between two versions */
+struct hns_nic_ops {
+	void (*fill_desc)(struct hnae_ring *ring, void *priv,
+			  int size, dma_addr_t dma, int frag_end,
+			  int buf_num, enum hns_desc_type type, int mtu);
+	int (*maybe_stop_tx)(struct sk_buff **out_skb,
+			     int *bnum, struct hnae_ring *ring);
+	void (*get_rxd_bnum)(u32 bnum_flag, int *out_bnum);
+};
+
 struct hns_nic_priv {
 	const char *ae_name;
 	u32 enet_ver;
@@ -51,6 +61,8 @@ struct hns_nic_priv {
 	struct device *dev;
 	struct hnae_handle *ae_handle;
 
+	struct hns_nic_ops ops;
+
 	/* the cb for nic to manage the ring buffer, the first half of the
 	 * array is for tx_ring and vice versa for the second half
 	 */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index a033212..9df63ae 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -11,7 +11,6 @@
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
-
 #include "hns_enet.h"
 
 #define HNS_PHY_PAGE_MDIX	0
@@ -667,6 +666,7 @@ static void hns_nic_get_drvinfo(struct net_device *net_dev,
 	drvinfo->bus_info[ETHTOOL_BUSINFO_LEN - 1] = '\0';
 
 	strncpy(drvinfo->fw_version, "N/A", ETHTOOL_FWVERS_LEN);
+	drvinfo->eedump_len = 0;
 }
 
 /**
-- 
1.7.9.5
