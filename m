From: Satha Koteswara Rao <satha.rao@caviumnetworks.com>
Subject: [RFC PATCH 5/7] Multiple VF's grouped together under single physical
 port called PF group PF Group maintainance API's
Date: Wed, 21 Dec 2016 14:16:49 +0530
Message-ID: <1482310011-1862-6-git-send-email-satha.rao@caviumnetworks.com>
References: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rvatsavayi@caviumnetworks.com, rric@kernel.org, david.daney@cavium.com,
 netdev@vger.kernel.org, satha.rao@caviumnetworks.com,
 derek.chickles@caviumnetworks.com, sgoutham@cavium.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, philip.romanov@cavium.com
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

---
 drivers/net/ethernet/cavium/thunder/pf_globals.h |  78 +++++
 drivers/net/ethernet/cavium/thunder/pf_locals.h  | 365 +++++++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/pf_vf.c      | 207 +++++++++++++
 3 files changed, 650 insertions(+)
 create mode 100644 drivers/net/ethernet/cavium/thunder/pf_globals.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/pf_locals.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/pf_vf.c

diff --git a/drivers/net/ethernet/cavium/thunder/pf_globals.h b/drivers/net/ethernet/cavium/thunder/pf_globals.h
new file mode 100644
index 0000000..79fab86
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/pf_globals.h
@@ -0,0 +1,78 @@
+/*
+ * Copyright (C) 2015 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ */
+
+#ifndef NIC_PF_H
+#define	NIC_PF_H
+
+#include <linux/netdevice.h>
+#include <linux/interrupt.h>
+#include <linux/firmware.h>
+#include "thunder_bgx.h"
+#include "tbl_access.h"
+
+#define TNS_MAX_LMAC	8
+#define TNS_MIN_LMAC    0
+
+struct tns_global_st {
+	u64 magic;
+	char     version[16];
+	u64 reg_cnt;
+	struct table_static_s tbl_info[TNS_MAX_TABLE];
+};
+
+#define PF_COUNT 3
+#define PF_1	0
+#define PF_2	64
+#define PF_3	96
+#define PF_END	128
+
+int is_pf(int node_id, int vf);
+int get_pf(int node_id, int vf);
+void get_vf_group(int node_id, int lmac, int *start_vf, int *end_vf);
+int vf_to_pport(int node_id, int vf);
+int pf_filter_init(void);
+int tns_init(const struct firmware *fw, struct device *dev);
+void tns_exit(void);
+void pf_notify_msg_handler(int node_id, void *arg);
+void nic_init_pf_vf_mapping(void);
+int nic_set_pf_vf_mapping(int node_id);
+int get_bgx_id(int node_id, int vf_id, int *bgx_id, int *lmac);
+int phy_port_to_bgx_lmac(int node, int port, int *bgx, int *lmac);
+int tns_filter_valid_entry(int node, int req_type, int vf, int vlan);
+void nic_enable_valid_vf(int max_vf_cnt);
+
+union nic_pf_qsx_rqx_bp_cfg {
+	u64 u;
+	struct nic_pf_qsx_rqx_bp_cfg_s {
+		u64 bpid		: 8;
+		u64 cq_bp		: 8;
+		u64 rbdr_bp		: 8;
+		u64 reserved_24_61	: 38;
+		u64 cq_bp_ena		: 1;
+		u64 rbdr_bp_ena		: 1;
+	} s;
+};
+
+#define NIC_PF_QSX_RQX_BP_CFG	0x20010500ul
+#define RBDR_CQ_BP		129
+
+union nic_pf_intfx_bp_cfg {
+	u64 u;
+	struct bdk_nic_pf_intfx_bp_cfg_s {
+		u64 bp_id		: 4;
+		u64 bp_type		: 1;
+		u64 reserved_5_62	: 58;
+		u64 bp_ena		: 1;
+	} s;
+};
+
+#define NIC_PF_INTFX_BP_CFG	0x208ull
+
+#define FW_NAME	"tns_firmware.bin"
+
+#endif
diff --git a/drivers/net/ethernet/cavium/thunder/pf_locals.h b/drivers/net/ethernet/cavium/thunder/pf_locals.h
new file mode 100644
index 0000000..f7e74bb
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/pf_locals.h
@@ -0,0 +1,365 @@
+/*
+ * Copyright (C) 2015 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ */
+
+#ifndef __PF_LOCALS__
+#define __PF_LOCALS__
+
+#include <linux/printk.h>
+
+#define XP_TOTAL_PORTS	(137)
+#define MAX_SYS_PORTS	XP_TOTAL_PORTS
+//Loopback port was invalid in MAC filter design
+#define TNS_MAC_FILTER_MAX_SYS_PORTS	(MAX_SYS_PORTS - 1)
+//Maximum LMAC available
+#define TNS_MAX_INGRESS_GROUP	8
+#define TNS_MAX_VF	(TNS_MAC_FILTER_MAX_SYS_PORTS - TNS_MAX_INGRESS_GROUP)
+#define TNS_VLAN_FILTER_MAX_INDEX	256
+#define TNS_MAC_FILTER_MAX_INDEX	1536
+#define TNS_MAX_VLAN_PER_VF	16
+
+#define TNS_NULL_VIF		152
+#define TNS_BASE_BCAST_VIF	136
+#define TNS_BASE_MCAST_VIF	144
+#define TNS_FW_MAX_SIZE         1048576
+
+/* We are restricting each VF to register atmost 11 filter entries
+ * (including unicast & multicast)
+ */
+#define TNS_MAX_MAC_PER_VF	11
+
+#define FERR		0
+#define FDEBUG		1
+#define FINFO		2
+
+#define FILTER_DBG_GBL		FERR
+#define filter_dbg(dbg_lvl, fmt, args...) \
+	({ \
+	if ((dbg_lvl) <= FILTER_DBG_GBL) \
+		pr_info(fmt, ##args); \
+	})
+
+typedef u8 mac_addr_t[6];		///< User define type for Mac Address
+typedef u8 vlan_port_bitmap_t[32];
+
+enum {
+	TNS_NO_ERR = 0,
+
+	/* Error in indirect read watch out the status */
+	TNS_ERROR_INDIRECT_READ = 4,
+	/* Error in indirect write watch out the status */
+	TNS_ERROR_INDIRECT_WRITE = 5,
+	/* Data too large for Read/Write */
+	TNS_ERROR_DATA_TOO_LARGE = 6,
+	/* Invalid arguments supplied to the IOCTL */
+	TNS_ERROR_INVALID_ARG = 7,
+
+	TNS_ERR_MAC_FILTER_INVALID_ENTRY,
+	TNS_ERR_MAC_FILTER_TBL_READ,
+	TNS_ERR_MAC_FILTER_TBL_WRITE,
+	TNS_ERR_MAC_EVIF_TBL_READ,
+	TNS_ERR_MAC_EVIF_TBL_WRITE,
+
+	TNS_ERR_VLAN_FILTER_INVLAID_ENTRY,
+	TNS_ERR_VLAN_FILTER_TBL_READ,
+	TNS_ERR_VLAN_FILTER_TBL_WRITE,
+	TNS_ERR_VLAN_EVIF_TBL_READ,
+	TNS_ERR_VLAN_EVIF_TBL_WRITE,
+
+	TNS_ERR_PORT_CONFIG_TBL_READ,
+	TNS_ERR_PORT_CONFIG_TBL_WRITE,
+	TNS_ERR_PORT_CONFIG_INVALID_ENTRY,
+
+	TNS_ERR_DRIVER_READ,
+	TNS_ERR_DRIVER_WRITE,
+
+	TNS_ERR_WRONG_PORT_NUMBER,
+	TNS_ERR_INVALID_TBL_ID,
+	TNS_ERR_ENTRY_NOT_FOUND,
+	TNS_ERR_DUPLICATE_MAC,
+	TNS_ERR_MAX_LIMIT,
+
+	TNS_STATUS_NUM_ENTRIES
+};
+
+struct ing_grp_gblvif {
+	u32 ingress_grp;
+	u32 pf_vf;
+	u32 bcast_vif;
+	u32 mcast_vif;
+	u32 null_vif;
+	u32 is_valid; //Is this Ingress Group or LMAC is valid
+	u8 mcast_promis_grp[TNS_MAC_FILTER_MAX_SYS_PORTS];
+	u8 valid_mcast_promis_ports;
+};
+
+struct vf_register_s {
+	int filter_index[16];
+	u32 filter_count;
+	int vf_in_mcast_promis;
+	int vf_in_promis;
+	int vlan[TNS_MAX_VLAN_PER_VF];
+	u32 vlan_count;
+};
+
+union mac_filter_keymask_type_s {
+	u64 key_value;
+
+	struct {
+		u32	ingress_grp: 16;
+		mac_addr_t	mac_DA;
+	} s;
+};
+
+struct mac_filter_keymask_s {
+	u8 is_valid;
+	union mac_filter_keymask_type_s key_type;
+};
+
+union mac_filter_data_s {
+	u64 data;
+	struct {
+		u64 evif: 16;
+		u64 Reserved0 : 48;
+	} s;
+};
+
+struct mac_filter_entry {
+	struct mac_filter_keymask_s key;
+	struct mac_filter_keymask_s mask;
+	union mac_filter_data_s data;
+};
+
+union vlan_filter_keymask_type_s {
+	u64 key_value;
+
+	struct {
+		u32	ingress_grp: 16;
+		u32	vlan: 12;
+		u32	reserved: 4;
+		u32	reserved1;
+	} s;
+};
+
+struct vlan_filter_keymask_s {
+	u8 is_valid;
+	union vlan_filter_keymask_type_s key_type;
+};
+
+union vlan_filter_data_s {
+	u64 data;
+	struct {
+		u64 filter_idx: 16;
+		u64 Reserved0 : 48;
+	} s;
+};
+
+struct vlan_filter_entry {
+	struct vlan_filter_keymask_s key;
+	struct vlan_filter_keymask_s mask;
+	union vlan_filter_data_s data;
+};
+
+struct evif_entry {
+	u64	rsp_type: 2;
+	u64	truncate: 1;
+	u64	mtu_prf: 3;
+	u64	mirror_en: 1;
+	u64	q_mirror_en: 1;
+	u64	prt_bmap7_0: 8;
+	u64	rewrite_ptr0: 8;
+	u64	rewrite_ptr1: 8;
+	/* Byte 0 is data31_0[7:0] and byte 3 is data31_0[31:24] */
+	u64	data31_0: 32;
+	u64	insert_ptr0: 16;
+	u64	insert_ptr1: 16;
+	u64	insert_ptr2: 16;
+	u64	mre_ptr: 15;
+	u64	prt_bmap_8: 1;
+	u64	prt_bmap_72_9;
+	u64	prt_bmap_136_73;
+};
+
+struct itt_entry_s {
+	u32 rsvd0 : 30;
+	u32 pkt_dir : 1;
+	u32 is_admin_vlan_enabled : 1;
+	u32 reserved0 : 6;
+	u32 default_evif : 8;
+	u32 admin_vlan : 12;
+	u32 Reserved1 : 6;
+	u32 Reserved2[6];
+};
+
+static inline u64 TNS_TDMA_SST_ACC_RDATX(unsigned long param1)
+{
+	return 0x00000480ull + (param1 & 7) * 0x10ull;
+}
+
+static inline u64 TNS_TDMA_SST_ACC_WDATX(unsigned long param1)
+{
+	return 0x00000280ull + (param1 & 7) * 0x10ull;
+}
+
+union tns_tdma_sst_acc_cmd {
+	u64 u;
+	struct  tns_tdma_sst_acc_cmd_s {
+		u64 reserved_0_1	: 2;
+		u64 addr		: 30;
+		u64 size		: 4;
+		u64 op			: 1;
+		u64 go			: 1;
+		u64 reserved_38_63	: 26;
+	} s;
+};
+
+#define TDMA_SST_ACC_CMD 0x00000270ull
+
+union tns_tdma_sst_acc_stat_t {
+	u64 u;
+	struct  tns_tdma_sst_acc_stat_s {
+		u64 cmd_done		: 1;
+		u64 error		: 1;
+		u64 reserved_2_63	: 62;
+	} s;
+};
+
+#define TDMA_SST_ACC_STAT 0x00000470ull
+#define TDMA_NB_INT_STAT 0x01000110ull
+
+union tns_acc_data {
+	u64 u;
+	struct tns_acc_data_s {
+		u64 lower32 : 32;
+		u64 upper32 : 32;
+	} s;
+};
+
+union tns_tdma_config {
+	u64 u;
+	struct  tns_tdma_config_s {
+		u64 clk_ena		: 1;
+		u64 clk_2x_ena		: 1;
+		u64 reserved_2_3	: 2;
+		u64 csr_access_ena	: 1;
+		u64 reserved_5_7	: 3;
+		u64 bypass0_ena		: 1;
+		u64 bypass1_ena		: 1;
+		u64 reserved_10_63	: 54;
+	} s;
+};
+
+#define TNS_TDMA_CONFIG_OFFSET  0x00000200ull
+
+union tns_tdma_cap {
+	u64 u;
+	struct tns_tdma_cap_s {
+		u64 switch_capable	: 1;
+		u64 reserved_1_63	: 63;
+	} s;
+};
+
+#define TNS_TDMA_CAP_OFFSET 0x00000400ull
+#define TNS_RDMA_CONFIG_OFFSET 0x00001200ull
+
+union tns_tdma_lmacx_config {
+	u64 u;
+	struct tns_tdma_lmacx_config_s {
+		u64 fifo_cdts		: 14;
+		u64 reserved_14_63	: 50;
+	} s;
+};
+
+union _tns_sst_config {
+	u64 data;
+	struct {
+#ifdef __BIG_ENDIAN
+		u64 powerof2stride	: 1;
+		u64 run			: 11;
+		u64 reserved		: 14;
+		u64 req_type		: 2;
+		u64 word_cnt		: 4;
+		u64 byte_addr		: 32;
+#else
+		u64 byte_addr		: 32;
+		u64 word_cnt		: 4;
+		u64 req_type		: 2;
+		u64 reserved		: 14;
+		u64 run			: 11;
+		u64 powerof2stride	: 1;
+#endif
+	} cmd;
+	struct {
+#ifdef __BIG_ENDIAN
+		u64 do_not_copy		: 26;
+		u64 do_copy		: 38;
+#else
+		u64 do_copy		: 38;
+		u64 do_not_copy		: 26;
+#endif
+	} copy;
+	struct {
+#ifdef __BIG_ENDIAN
+		u64 magic		: 48;
+		u64 major_version_BCD	: 8;
+		u64 minor_version_BCD	: 8;
+#else
+		u64 minor_version_BCD	: 8;
+		u64 major_version_BCD	: 8;
+		u64 magic		: 48;
+#endif
+	} header;
+};
+
+static inline u64 TNS_TDMA_LMACX_CONFIG_OFFSET(unsigned long param1)
+			 __attribute__ ((pure, always_inline));
+static inline u64 TNS_TDMA_LMACX_CONFIG_OFFSET(unsigned long param1)
+{
+	return 0x00000300ull + (param1 & 7) * 0x10ull;
+}
+
+#define TNS_TDMA_RESET_CTL_OFFSET 0x00000210ull
+
+int read_register_indirect(u64 address, u8 size, u8 *kern_buffer);
+int write_register_indirect(u64 address, u8 size, u8 *kern_buffer);
+int tns_write_register_indirect(int node, u64 address, u8 size,
+				u8 *kern_buffer);
+int tns_read_register_indirect(int node, u64 address, u8 size,
+			       u8 *kern_buffer);
+u64 tns_read_register(u64 start, u64 offset);
+void tns_write_register(u64 start, u64 offset, u64 data);
+int tbl_write(int node, int tbl_id, int tbl_index, void *key, void *mask,
+	      void *data);
+int tbl_read(int node, int tbl_id, int tbl_index, void *key, void *mask,
+	     void *data);
+int invalidate_table_entry(int node, int tbl_id, int tbl_idx);
+int alloc_table_index(int node, int table_id, int *index);
+void free_table_index(int node, int table_id, int index);
+
+struct pf_vf_data {
+	int pf_id;
+	int num_vfs;
+	int lmac;
+	int sys_lmac;
+	int bgx_idx;
+};
+
+struct pf_vf_map_s {
+	bool valid;
+	int lmac_cnt;
+	struct pf_vf_data pf_vf[TNS_MAX_LMAC];
+};
+
+extern struct pf_vf_map_s pf_vf_map_data[MAX_NUMNODES];
+int tns_enable_mcast_promis(int node, int vf);
+int filter_tbl_lookup(int node, int tblid, void *entry, int *idx);
+
+#define MCAST_PROMIS(a, b, c) ingressgrp_gblvif[(a)][(b)].mcast_promis_grp[(c)]
+#define VALID_MCAST_PROMIS(a, b) \
+	ingressgrp_gblvif[(a)][(b)].valid_mcast_promis_ports
+
+#endif /*__PF_LOCALS__*/
diff --git a/drivers/net/ethernet/cavium/thunder/pf_vf.c b/drivers/net/ethernet/cavium/thunder/pf_vf.c
new file mode 100644
index 0000000..bc4f923
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/pf_vf.c
@@ -0,0 +1,207 @@
+/*
+ * Copyright (C) 2015 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ */
+
+#include "nic_reg.h"
+#include "nic.h"
+#include "pf_globals.h"
+#include "pf_locals.h"
+
+#define PFVF_DAT(gidx, lidx) \
+	pf_vf_map_data[gidx].pf_vf[lidx]
+
+struct pf_vf_map_s pf_vf_map_data[MAX_NUMNODES];
+
+void nic_init_pf_vf_mapping(void)
+{
+	int i;
+
+	for (i = 0 ; i < MAX_NUMNODES; i++) {
+		pf_vf_map_data[i].lmac_cnt = 0;
+		pf_vf_map_data[i].valid = false;
+	}
+}
+
+/* Based on available LMAC's we create physical group called ingress group
+ * Designate first VF as acted PF of this group, called PfVf interface.
+ */
+static inline void set_pf_vf_global_data(int node, int valid_vf_cnt)
+{
+	unsigned int bgx_map;
+	int bgx;
+	int lmac, lmac_cnt = 0;
+
+	if (pf_vf_map_data[node].valid)
+		return;
+
+	bgx_map = bgx_get_map(node);
+	for (bgx = 0; bgx < MAX_BGX_PER_CN88XX; bgx++)	{
+		if (!(bgx_map & (1 << bgx)))
+			continue;
+		pf_vf_map_data[node].valid = true;
+		lmac_cnt = bgx_get_lmac_count(node, bgx);
+
+		for (lmac = 0; lmac < lmac_cnt; lmac++)	{
+			int slc = lmac + pf_vf_map_data[node].lmac_cnt;
+
+			PFVF_DAT(node, slc).pf_id = (bgx * 64) + (lmac *
+								 valid_vf_cnt);
+			PFVF_DAT(node, slc).num_vfs = valid_vf_cnt;
+			PFVF_DAT(node, slc).lmac = lmac;
+			PFVF_DAT(node, slc).bgx_idx = bgx;
+			PFVF_DAT(node, slc).sys_lmac = bgx * MAX_LMAC_PER_BGX +
+						      lmac;
+		}
+		pf_vf_map_data[node].lmac_cnt += lmac_cnt;
+	}
+}
+
+/* We have 2 NIC pipes in each node.Each NIC pipe associated with BGX interface
+ * Each BGX contains atmost 4 LMACs (or PHY's) and supports 64 VF's
+ * Hardware doesn't have any physical PF, one of VF acts as PF.
+ */
+int nic_set_pf_vf_mapping(int node_id)
+{
+	unsigned int bgx_map;
+	int node = 0;
+	int bgx;
+	int lmac_cnt = 0, valid_vf_cnt = 64;
+
+	do {
+		bgx_map = bgx_get_map(node);
+		/* Calculate Maximum VF's in each physical port group */
+		for (bgx = 0; bgx < MAX_BGX_PER_CN88XX; bgx++) {
+			if (!(bgx_map & (1 << bgx)))
+				continue;
+			lmac_cnt = bgx_get_lmac_count(node, bgx);
+			//Maximum 64 VF's for each BGX
+			if (valid_vf_cnt > (64 / lmac_cnt))
+				valid_vf_cnt = (64 / lmac_cnt);
+		}
+	} while (++node < nr_node_ids);
+
+	nic_enable_valid_vf(valid_vf_cnt);
+	node = 0;
+	do {
+		set_pf_vf_global_data(node, valid_vf_cnt);
+	} while (++node < nr_node_ids);
+
+	return 0;
+}
+
+/* Find if VF is a acted PF */
+int is_pf(int node, int vf)
+{
+	int i;
+
+	/* Invalid Request, Init not done properly */
+	if (!pf_vf_map_data[node].valid)
+		return 0;
+
+	for (i = 0; i < pf_vf_map_data[node].lmac_cnt; i++)
+		if (vf == PFVF_DAT(node, i).pf_id)
+			return 1;
+
+	return 0;
+}
+
+/* Get the acted PF corresponding to this VF */
+int get_pf(int node, int vf)
+{
+	int i;
+
+	/* Invalid Request, Init not done properly */
+	if (!pf_vf_map_data[node].valid)
+		return 0;
+
+	for (i = 0; i < pf_vf_map_data[node].lmac_cnt; i++)
+		if ((vf >= PFVF_DAT(node, i).pf_id) &&
+		    (vf < (PFVF_DAT(node, i).pf_id +
+			   PFVF_DAT(node, i).num_vfs)))
+			return pf_vf_map_data[node].pf_vf[i].pf_id;
+
+	return -1;
+}
+
+/* Get the starting vf and ending vf number of the LMAC group */
+void get_vf_group(int node, int lmac, int *start_vf, int *end_vf)
+{
+	int i;
+
+	/* Invalid Request, Init not done properly */
+	if (!pf_vf_map_data[node].valid)
+		return;
+
+	for (i = 0; i < pf_vf_map_data[node].lmac_cnt; i++) {
+		if (lmac == (PFVF_DAT(node, i).sys_lmac)) {
+			*start_vf = PFVF_DAT(node, i).pf_id;
+			*end_vf = PFVF_DAT(node, i).pf_id +
+				  PFVF_DAT(node, i).num_vfs;
+			return;
+		}
+	}
+}
+
+/* Get the physical port # of the given vf */
+int vf_to_pport(int node, int vf)
+{
+	int i;
+
+	/* Invalid Request, Init not done properly */
+	if (!pf_vf_map_data[node].valid)
+		return 0;
+
+	for (i = 0; i < pf_vf_map_data[node].lmac_cnt; i++)
+		if ((vf >= PFVF_DAT(node, i).pf_id) &&
+		    (vf < (PFVF_DAT(node, i).pf_id +
+		     PFVF_DAT(node, i).num_vfs)))
+			return PFVF_DAT(node, i).sys_lmac;
+
+	return -1;
+}
+
+/* Get BGX # and LMAC # corresponding to VF */
+int get_bgx_id(int node, int vf, int *bgx_idx, int *lmac)
+{
+	int i;
+
+	/* Invalid Request, Init not done properly */
+	if (!pf_vf_map_data[node].valid)
+		return 1;
+
+	for (i = 0; i < pf_vf_map_data[node].lmac_cnt; i++) {
+		if ((vf >= PFVF_DAT(node, i).pf_id) &&
+		    (vf < (PFVF_DAT(node, i).pf_id +
+			   PFVF_DAT(node, i).num_vfs))) {
+			*bgx_idx = pf_vf_map_data[node].pf_vf[i].bgx_idx;
+			*lmac = pf_vf_map_data[node].pf_vf[i].lmac;
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/* Get BGX # and LMAC # corresponding to physical port */
+int phy_port_to_bgx_lmac(int node, int port, int *bgx, int *lmac)
+{
+	int i;
+
+	/* Invalid Request, Init not done properly */
+	if (!pf_vf_map_data[node].valid)
+		return 1;
+
+	for (i = 0; i < pf_vf_map_data[node].lmac_cnt; i++) {
+		if (port == (PFVF_DAT(node, i).sys_lmac)) {
+			*bgx = pf_vf_map_data[node].pf_vf[i].bgx_idx;
+			*lmac = pf_vf_map_data[node].pf_vf[i].lmac;
+			return 0;
+		}
+	}
+
+	return 1;
+}
-- 
1.8.3.1
