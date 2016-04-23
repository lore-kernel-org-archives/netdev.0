From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 01/13] net: hns: add a new dsaf mode for debug port
Date: Sat, 23 Apr 2016 17:05:05 +0800
Message-ID: <1461402317-136499-2-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a new dsaf mode named "single-port" mode for debug port.
This mode only contains one debug port. This patch also changes the
method of distinguishing the port type.

Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   8 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  16 +--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   2 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   4 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |   6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  | 132 ++++++++++-----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   1 -
 9 files changed, 84 insertions(+), 89 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 1591422..1e8bf22 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -96,7 +96,7 @@ static struct ring_pair_cb *hns_ae_get_base_ring_pair(
 	int q_num = rcb_comm->max_q_per_vf;
 	int vf_num = rcb_comm->max_vfn;
 
-	if (common_idx == HNS_DSAF_COMM_SERVICE_NW_IDX)
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
 		return &rcb_comm->ring_pair_cb[port * q_num * vf_num];
 	else
 		return &rcb_comm->ring_pair_cb[0];
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 10c367d..353b9e7 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -249,7 +249,7 @@ int hns_mac_change_vf_addr(struct hns_mac_cb *mac_cb,
 	struct mac_entry_idx *old_entry;
 
 	old_entry = &mac_cb->addr_entry_idx[vmid];
-	if (dsaf_dev) {
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
 		mac_entry.in_vlan_id = old_entry->vlan_id;
 		mac_entry.in_port_num = mac_cb->mac_id;
@@ -289,7 +289,7 @@ int hns_mac_set_multi(struct hns_mac_cb *mac_cb,
 	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
 	struct dsaf_drv_mac_single_dest_entry mac_entry;
 
-	if (dsaf_dev && addr) {
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev) && addr) {
 		memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
 		mac_entry.in_vlan_id = 0;/*vlan_id;*/
 		mac_entry.in_port_num = mac_cb->mac_id;
@@ -380,7 +380,7 @@ static int hns_mac_port_config_bc_en(struct hns_mac_cb *mac_cb,
 	if (mac_cb->mac_type == HNAE_PORT_DEBUG)
 		return 0;
 
-	if (dsaf_dev) {
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
 		mac_entry.in_vlan_id = vlan_id;
 		mac_entry.in_port_num = mac_cb->mac_id;
@@ -418,7 +418,7 @@ int hns_mac_vm_config_bc_en(struct hns_mac_cb *mac_cb, u32 vmid, bool enable)
 
 	uc_mac_entry = &mac_cb->addr_entry_idx[vmid];
 
-	if (dsaf_dev)  {
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))  {
 		memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
 		mac_entry.in_vlan_id = uc_mac_entry->vlan_id;
 		mac_entry.in_port_num = mac_cb->mac_id;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 8439f6d..7692853 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -28,6 +28,7 @@ const char *g_dsaf_mode_match[DSAF_MODE_MAX] = {
 	[DSAF_MODE_DISABLE_2PORT_64VM] = "2port-64vf",
 	[DSAF_MODE_DISABLE_6PORT_0VM] = "6port-16rss",
 	[DSAF_MODE_DISABLE_6PORT_16VM] = "6port-16vf",
+	[DSAF_MODE_DISABLE_SP] = "single-port",
 };
 
 int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
@@ -217,9 +218,7 @@ static void hns_dsaf_mix_def_qid_cfg(struct dsaf_device *dsaf_dev)
 	u32 q_id, q_num_per_port;
 	u32 i;
 
-	hns_rcb_get_queue_mode(dsaf_dev->dsaf_mode,
-			       HNS_DSAF_COMM_SERVICE_NW_IDX,
-			       &max_vfn, &max_q_per_vf);
+	hns_rcb_get_queue_mode(dsaf_dev->dsaf_mode, &max_vfn, &max_q_per_vf);
 	q_num_per_port = max_vfn * max_q_per_vf;
 
 	for (i = 0, q_id = 0; i < DSAF_SERVICE_NW_NUM; i++) {
@@ -239,9 +238,7 @@ static void hns_dsaf_inner_qid_cfg(struct dsaf_device *dsaf_dev)
 	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
 		return;
 
-	hns_rcb_get_queue_mode(dsaf_dev->dsaf_mode,
-			       HNS_DSAF_COMM_SERVICE_NW_IDX,
-			       &max_vfn, &max_q_per_vf);
+	hns_rcb_get_queue_mode(dsaf_dev->dsaf_mode, &max_vfn, &max_q_per_vf);
 	q_num_per_port = max_vfn * max_q_per_vf;
 
 	for (mac_id = 0, q_id = 0; mac_id < DSAF_SERVICE_NW_NUM; mac_id++) {
@@ -712,7 +709,9 @@ static void hns_dsaf_tbl_tcam_data_ucast_pul(
 
 void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en)
 {
-	dsaf_set_dev_bit(dsaf_dev, DSAF_CFG_0_REG, DSAF_CFG_MIX_MODE_S, !!en);
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
+		dsaf_set_dev_bit(dsaf_dev, DSAF_CFG_0_REG,
+				 DSAF_CFG_MIX_MODE_S, !!en);
 }
 
 void hns_dsaf_set_inner_lb(struct dsaf_device *dsaf_dev, u32 mac_id, u32 en)
@@ -1307,6 +1306,9 @@ static int hns_dsaf_init(struct dsaf_device *dsaf_dev)
 	u32 i;
 	int ret;
 
+	if (HNS_DSAF_IS_DEBUG(dsaf_dev))
+		return 0;
+
 	ret = hns_dsaf_init_hw(dsaf_dev);
 	if (ret)
 		return ret;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index e8eedc5..a783019 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -41,6 +41,7 @@ struct hns_mac_cb;
 #define DSAF_STATIC_NUM 28
 
 #define DSAF_STATS_READ(p, offset) (*((u64 *)((u8 *)(p) + (offset))))
+#define HNS_DSAF_IS_DEBUG(dev) (dev->dsaf_mode == DSAF_MODE_DISABLE_SP)
 
 enum hal_dsaf_mode {
 	HRD_DSAF_NO_DSAF_MODE	= 0x0,
@@ -117,6 +118,7 @@ enum dsaf_mode {
 	DSAF_MODE_ENABLE_32VM,	/**< en DSAF-mode, support 32 VM */
 	DSAF_MODE_ENABLE_128VM,	/**< en DSAF-mode, support 128 VM */
 	DSAF_MODE_ENABLE,		/**< before is enable DSAF mode*/
+	DSAF_MODE_DISABLE_SP,	/* <non-dsaf, single port mode */
 	DSAF_MODE_DISABLE_FIX,	/**< non-dasf, fixed to queue*/
 	DSAF_MODE_DISABLE_2PORT_8VM,	/**< non-dasf, 2port 8VM */
 	DSAF_MODE_DISABLE_2PORT_16VM,	/**< non-dasf, 2port 16VM */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index e69b022..8cb13d9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -147,7 +147,7 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	if (port >= DSAF_GE_NUM)
 		return;
 
-	if (port < DSAF_SERVICE_NW_NUM) {
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		reg_val_1  = 0x1 << port;
 		/* there is difference between V1 and V2 in register.*/
 		if (AE_IS_VER1(dsaf_dev->dsaf_ver))
@@ -218,7 +218,7 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
 	u32 reg_val;
 	u32 reg_addr;
 
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		reg_val = RESET_REQ_OR_DREQ;
 		if (val == 0)
 			reg_addr = DSAF_SUB_SC_RCB_PPE_COM_RESET_REQ_REG;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index ab27b3b..3f59a8a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -68,7 +68,7 @@ static void __iomem *hns_ppe_common_get_ioaddr(
 
 	int idx = ppe_common->comm_index;
 
-	if (idx == HNS_DSAF_COMM_SERVICE_NW_IDX)
+	if (!HNS_DSAF_IS_DEBUG(ppe_common->dsaf_dev))
 		base_addr = ppe_common->dsaf_dev->ppe_base
 			+ PPE_COMMON_REG_OFFSET;
 	else
@@ -90,7 +90,7 @@ int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
 	struct ppe_common_cb *ppe_common;
 	int ppe_num;
 
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
 		ppe_num = HNS_PPE_SERVICE_NW_ENGINE_NUM;
 	else
 		ppe_num = HNS_PPE_DEBUG_NW_ENGINE_NUM;
@@ -103,7 +103,7 @@ int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
 	ppe_common->ppe_num = ppe_num;
 	ppe_common->dsaf_dev = dsaf_dev;
 	ppe_common->comm_index = comm_index;
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
 		ppe_common->ppe_mode = PPE_COMMON_MODE_SERVICE;
 	else
 		ppe_common->ppe_mode = PPE_COMMON_MODE_DEBUG;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 28ee26e..121ba4e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -270,7 +270,7 @@ static void hns_rcb_set_port_timeout(
 
 static int hns_rcb_common_get_port_num(struct rcb_common_cb *rcb_common)
 {
-	if (rcb_common->comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+	if (!HNS_DSAF_IS_DEBUG(rcb_common->dsaf_dev))
 		return HNS_RCB_SERVICE_NW_ENGINE_NUM;
 	else
 		return HNS_RCB_DEBUG_NW_ENGINE_NUM;
@@ -430,11 +430,10 @@ static void hns_rcb_ring_pair_get_cfg(struct ring_pair_cb *ring_pair_cb)
 static int hns_rcb_get_port_in_comm(
 	struct rcb_common_cb *rcb_common, int ring_idx)
 {
-	int comm_index = rcb_common->comm_index;
 	int port;
 	int q_num;
 
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+	if (!HNS_DSAF_IS_DEBUG(rcb_common->dsaf_dev)) {
 		q_num = (int)rcb_common->max_q_per_vf * rcb_common->max_vfn;
 		port = ring_idx / q_num;
 	} else {
@@ -455,7 +454,7 @@ static int hns_rcb_get_base_irq_idx(struct rcb_common_cb *rcb_common)
 	int comm_index = rcb_common->comm_index;
 	bool is_ver1 = AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver);
 
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+	if (!HNS_DSAF_IS_DEBUG(rcb_common->dsaf_dev))
 		return SERVICE_RING_IRQ_IDX(is_ver1);
 	else
 		return  DEBUG_RING_IRQ_IDX(is_ver1) +
@@ -549,7 +548,7 @@ int hns_rcb_set_coalesce_usecs(
 		return 0;
 
 	if (AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver)) {
-		if (rcb_common->comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+		if (!HNS_DSAF_IS_DEBUG(rcb_common->dsaf_dev)) {
 			dev_err(rcb_common->dsaf_dev->dev,
 				"error: not support coalesce_usecs setting!\n");
 			return -EINVAL;
@@ -601,74 +600,67 @@ int hns_rcb_set_coalesced_frames(
  *@max_vfn : max vfn number
  *@max_q_per_vf:max ring number per vm
  */
-void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, int comm_index,
-			    u16 *max_vfn, u16 *max_q_per_vf)
+void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, u16 *max_vfn,
+			    u16 *max_q_per_vf)
 {
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
-		switch (dsaf_mode) {
-		case DSAF_MODE_DISABLE_6PORT_0VM:
-			*max_vfn = 1;
-			*max_q_per_vf = 16;
-			break;
-		case DSAF_MODE_DISABLE_FIX:
-			*max_vfn = 1;
-			*max_q_per_vf = 1;
-			break;
-		case DSAF_MODE_DISABLE_2PORT_64VM:
-			*max_vfn = 64;
-			*max_q_per_vf = 1;
-			break;
-		case DSAF_MODE_DISABLE_6PORT_16VM:
-			*max_vfn = 16;
-			*max_q_per_vf = 1;
-			break;
-		default:
-			*max_vfn = 1;
-			*max_q_per_vf = 16;
-			break;
-		}
-	} else {
+	switch (dsaf_mode) {
+	case DSAF_MODE_DISABLE_6PORT_0VM:
+		*max_vfn = 1;
+		*max_q_per_vf = 16;
+		break;
+	case DSAF_MODE_DISABLE_FIX:
+	case DSAF_MODE_DISABLE_SP:
 		*max_vfn = 1;
 		*max_q_per_vf = 1;
+		break;
+	case DSAF_MODE_DISABLE_2PORT_64VM:
+		*max_vfn = 64;
+		*max_q_per_vf = 1;
+		break;
+	case DSAF_MODE_DISABLE_6PORT_16VM:
+		*max_vfn = 16;
+		*max_q_per_vf = 1;
+		break;
+	default:
+		*max_vfn = 1;
+		*max_q_per_vf = 16;
+		break;
 	}
 }
 
-int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev, int comm_index)
+int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev)
 {
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
-		switch (dsaf_dev->dsaf_mode) {
-		case DSAF_MODE_ENABLE_FIX:
-			return 1;
-
-		case DSAF_MODE_DISABLE_FIX:
-			return 6;
-
-		case DSAF_MODE_ENABLE_0VM:
-			return 32;
-
-		case DSAF_MODE_DISABLE_6PORT_0VM:
-		case DSAF_MODE_ENABLE_16VM:
-		case DSAF_MODE_DISABLE_6PORT_2VM:
-		case DSAF_MODE_DISABLE_6PORT_16VM:
-		case DSAF_MODE_DISABLE_6PORT_4VM:
-		case DSAF_MODE_ENABLE_8VM:
-			return 96;
-
-		case DSAF_MODE_DISABLE_2PORT_16VM:
-		case DSAF_MODE_DISABLE_2PORT_8VM:
-		case DSAF_MODE_ENABLE_32VM:
-		case DSAF_MODE_DISABLE_2PORT_64VM:
-		case DSAF_MODE_ENABLE_128VM:
-			return 128;
-
-		default:
-			dev_warn(dsaf_dev->dev,
-				 "get ring num fail,use default!dsaf_mode=%d\n",
-				 dsaf_dev->dsaf_mode);
-			return 128;
-		}
-	} else {
+	switch (dsaf_dev->dsaf_mode) {
+	case DSAF_MODE_ENABLE_FIX:
+	case DSAF_MODE_DISABLE_SP:
 		return 1;
+
+	case DSAF_MODE_DISABLE_FIX:
+		return 6;
+
+	case DSAF_MODE_ENABLE_0VM:
+		return 32;
+
+	case DSAF_MODE_DISABLE_6PORT_0VM:
+	case DSAF_MODE_ENABLE_16VM:
+	case DSAF_MODE_DISABLE_6PORT_2VM:
+	case DSAF_MODE_DISABLE_6PORT_16VM:
+	case DSAF_MODE_DISABLE_6PORT_4VM:
+	case DSAF_MODE_ENABLE_8VM:
+		return 96;
+
+	case DSAF_MODE_DISABLE_2PORT_16VM:
+	case DSAF_MODE_DISABLE_2PORT_8VM:
+	case DSAF_MODE_ENABLE_32VM:
+	case DSAF_MODE_DISABLE_2PORT_64VM:
+	case DSAF_MODE_ENABLE_128VM:
+		return 128;
+
+	default:
+		dev_warn(dsaf_dev->dev,
+			 "get ring num fail,use default!dsaf_mode=%d\n",
+			 dsaf_dev->dsaf_mode);
+		return 128;
 	}
 }
 
@@ -677,7 +669,7 @@ void __iomem *hns_rcb_common_get_vaddr(struct dsaf_device *dsaf_dev,
 {
 	void __iomem *base_addr;
 
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
 		base_addr = dsaf_dev->ppe_base + RCB_COMMON_REG_OFFSET;
 	else
 		base_addr = dsaf_dev->sds_base
@@ -697,7 +689,7 @@ static phys_addr_t hns_rcb_common_get_paddr(struct dsaf_device *dsaf_dev,
 	u64 size = 0;
 	int index = 0;
 
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		index    = 2;
 		addr_offset = RCB_COMMON_REG_OFFSET;
 	} else {
@@ -717,7 +709,7 @@ int hns_rcb_common_get_cfg(struct dsaf_device *dsaf_dev,
 	enum dsaf_mode dsaf_mode = dsaf_dev->dsaf_mode;
 	u16 max_vfn;
 	u16 max_q_per_vf;
-	int ring_num = hns_rcb_get_ring_num(dsaf_dev, comm_index);
+	int ring_num = hns_rcb_get_ring_num(dsaf_dev);
 
 	rcb_common =
 		devm_kzalloc(dsaf_dev->dev, sizeof(*rcb_common) +
@@ -732,7 +724,7 @@ int hns_rcb_common_get_cfg(struct dsaf_device *dsaf_dev,
 
 	rcb_common->desc_num = dsaf_dev->desc_num;
 
-	hns_rcb_get_queue_mode(dsaf_mode, comm_index, &max_vfn, &max_q_per_vf);
+	hns_rcb_get_queue_mode(dsaf_mode, &max_vfn, &max_q_per_vf);
 	rcb_common->max_vfn = max_vfn;
 	rcb_common->max_q_per_vf = max_q_per_vf;
 
@@ -932,7 +924,7 @@ void hns_rcb_get_common_regs(struct rcb_common_cb *rcb_com, void *data)
 {
 	u32 *regs = data;
 	bool is_ver1 = AE_IS_VER1(rcb_com->dsaf_dev->dsaf_ver);
-	bool is_dbg = (rcb_com->comm_index != HNS_DSAF_COMM_SERVICE_NW_IDX);
+	bool is_dbg = HNS_DSAF_IS_DEBUG(rcb_com->dsaf_dev);
 	u32 reg_tmp;
 	u32 reg_num_tmp;
 	u32 i = 0;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
index eb61014..bd54dac 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
@@ -111,7 +111,7 @@ void hns_rcb_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index);
 int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common);
 void hns_rcb_start(struct hnae_queue *q, u32 val);
 void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common);
-void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, int comm_index,
+void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode,
 			    u16 *max_vfn, u16 *max_q_per_vf);
 
 void hns_rcb_common_init_commit_hw(struct rcb_common_cb *rcb_common);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 7ff195e..cffd244 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -23,7 +23,6 @@
 
 #define DSAF_COMM_DEV_NUM 3
 #define DSAF_PPE_INODE_BASE 6
-#define HNS_DSAF_COMM_SERVICE_NW_IDX 0
 #define DSAF_DEBUG_NW_NUM	2
 #define DSAF_SERVICE_NW_NUM	6
 #define DSAF_COMM_CHN		DSAF_SERVICE_NW_NUM
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
