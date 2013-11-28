From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 2/3] cxgb4vf: added much cleaner implementation of is_t4()
Date: Thu, 28 Nov 2013 19:22:13 +0530
Message-ID: <1385646734-3576-3-git-send-email-hariprasad@chelsio.com>
References: <1385646734-3576-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17371 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab3K1O2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 09:28:08 -0500
In-Reply-To: <1385646734-3576-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  9 ++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |  1 -
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 15 ++++++++++----
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h | 24 ++++++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  4 ++--
 6 files changed, 39 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index a7d8189..0a8205d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1204,4 +1204,13 @@
 #define EDC_STRIDE_T5 (EDC_T51_BASE_ADDR - EDC_T50_BASE_ADDR)
 #define EDC_REG_T5(reg, idx) (reg + EDC_STRIDE_T5 * idx)
 
+#define A_PL_VF_REV 0x4
+#define A_PL_VF_WHOAMI 0x0
+#define A_PL_VF_REVISION 0x8
+
+#define S_CHIPID    4
+#define M_CHIPID    0xfU
+#define V_CHIPID(x) ((x) << S_CHIPID)
+#define G_CHIPID(x) (((x) >> S_CHIPID) & M_CHIPID)
+
 #endif /* __T4_REGS_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index be5c7ef..68eaa9c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -344,7 +344,6 @@ struct adapter {
 	unsigned long registered_device_map;
 	unsigned long open_device_map;
 	unsigned long flags;
-	enum chip_type chip;
 	struct adapter_params params;
 
 	/* queue and interrupt resources */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 5f90ec5..0899c09 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1064,7 +1064,7 @@ static inline unsigned int mk_adap_vers(const struct adapter *adapter)
 	/*
 	 * Chip version 4, revision 0x3f (cxgb4vf).
 	 */
-	return CHELSIO_CHIP_VERSION(adapter->chip) | (0x3f << 10);
+	return CHELSIO_CHIP_VERSION(adapter->params.chip) | (0x3f << 10);
 }
 
 /*
@@ -1551,9 +1551,13 @@ static void cxgb4vf_get_regs(struct net_device *dev,
 	reg_block_dump(adapter, regbuf,
 		       T4VF_MPS_BASE_ADDR + T4VF_MOD_MAP_MPS_FIRST,
 		       T4VF_MPS_BASE_ADDR + T4VF_MOD_MAP_MPS_LAST);
+
+	/* T5 adds new registers in the PL Register map.
+	 */
 	reg_block_dump(adapter, regbuf,
 		       T4VF_PL_BASE_ADDR + T4VF_MOD_MAP_PL_FIRST,
-		       T4VF_PL_BASE_ADDR + T4VF_MOD_MAP_PL_LAST);
+		       T4VF_PL_BASE_ADDR + (is_t4(adapter->params.chip)
+		       ? A_PL_VF_WHOAMI : A_PL_VF_REVISION));
 	reg_block_dump(adapter, regbuf,
 		       T4VF_CIM_BASE_ADDR + T4VF_MOD_MAP_CIM_FIRST,
 		       T4VF_CIM_BASE_ADDR + T4VF_MOD_MAP_CIM_LAST);
@@ -2087,6 +2091,7 @@ static int adap_init0(struct adapter *adapter)
 	unsigned int ethqsets;
 	int err;
 	u32 param, val = 0;
+	unsigned int chipid;
 
 	/*
 	 * Wait for the device to become ready before proceeding ...
@@ -2114,12 +2119,14 @@ static int adap_init0(struct adapter *adapter)
 		return err;
 	}
 
+	adapter->params.chip = 0;
 	switch (adapter->pdev->device >> 12) {
 	case CHELSIO_T4:
-		adapter->chip = CHELSIO_CHIP_CODE(CHELSIO_T4, 0);
+		adapter->params.chip = CHELSIO_CHIP_CODE(CHELSIO_T4, 0);
 		break;
 	case CHELSIO_T5:
-		adapter->chip = CHELSIO_CHIP_CODE(CHELSIO_T5, 0);
+		chipid = G_REV(t4_read_reg(adapter, A_PL_VF_REV));
+		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, chipid);
 		break;
 	}
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 8475c4c..0a89963 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -537,7 +537,7 @@ static inline void ring_fl_db(struct adapter *adapter, struct sge_fl *fl)
 	 */
 	if (fl->pend_cred >= FL_PER_EQ_UNIT) {
 		val = PIDX(fl->pend_cred / FL_PER_EQ_UNIT);
-		if (!is_t4(adapter->chip))
+		if (!is_t4(adapter->params.chip))
 			val |= DBTYPE(1);
 		wmb();
 		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 53cbfed..6136245 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -39,21 +39,28 @@
 #include "../cxgb4/t4fw_api.h"
 
 #define CHELSIO_CHIP_CODE(version, revision) (((version) << 4) | (revision))
-#define CHELSIO_CHIP_VERSION(code) ((code) >> 4)
+#define CHELSIO_CHIP_VERSION(code) (((code) >> 4) & 0xf)
 #define CHELSIO_CHIP_RELEASE(code) ((code) & 0xf)
 
+/* All T4 and later chips have their PCI-E Device IDs encoded as 0xVFPP where:
+ *
+ *   V  = "4" for T4; "5" for T5, etc. or
+ *      = "a" for T4 FPGA; "b" for T4 FPGA, etc.
+ *   F  = "0" for PF 0..3; "4".."7" for PF4..7; and "8" for VFs
+ *   PP = adapter product designation
+ */
 #define CHELSIO_T4		0x4
 #define CHELSIO_T5		0x5
 
 enum chip_type {
-	T4_A1 = CHELSIO_CHIP_CODE(CHELSIO_T4, 0),
-	T4_A2 = CHELSIO_CHIP_CODE(CHELSIO_T4, 1),
-	T4_A3 = CHELSIO_CHIP_CODE(CHELSIO_T4, 2),
+	T4_A1 = CHELSIO_CHIP_CODE(CHELSIO_T4, 1),
+	T4_A2 = CHELSIO_CHIP_CODE(CHELSIO_T4, 2),
 	T4_FIRST_REV	= T4_A1,
-	T4_LAST_REV	= T4_A3,
+	T4_LAST_REV	= T4_A2,
 
-	T5_A1 = CHELSIO_CHIP_CODE(CHELSIO_T5, 0),
-	T5_FIRST_REV	= T5_A1,
+	T5_A0 = CHELSIO_CHIP_CODE(CHELSIO_T5, 0),
+	T5_A1 = CHELSIO_CHIP_CODE(CHELSIO_T5, 1),
+	T5_FIRST_REV	= T5_A0,
 	T5_LAST_REV	= T5_A1,
 };
 
@@ -203,6 +210,7 @@ struct adapter_params {
 	struct vpd_params vpd;		/* Vital Product Data */
 	struct rss_params rss;		/* Receive Side Scaling */
 	struct vf_resources vfres;	/* Virtual Function Resource limits */
+	enum chip_type chip;		/* chip code */
 	u8 nports;			/* # of Ethernet "ports" */
 };
 
@@ -253,7 +261,7 @@ static inline int t4vf_wr_mbox_ns(struct adapter *adapter, const void *cmd,
 
 static inline int is_t4(enum chip_type chip)
 {
-	return (chip >= T4_FIRST_REV && chip <= T4_LAST_REV);
+	return CHELSIO_CHIP_VERSION(chip) == CHELSIO_T4;
 }
 
 int t4vf_wait_dev_ready(struct adapter *);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 9f96dc3..d958c44 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -1027,7 +1027,7 @@ int t4vf_alloc_mac_filt(struct adapter *adapter, unsigned int viid, bool free,
 	unsigned nfilters = 0;
 	unsigned int rem = naddr;
 	struct fw_vi_mac_cmd cmd, rpl;
-	unsigned int max_naddr = is_t4(adapter->chip) ?
+	unsigned int max_naddr = is_t4(adapter->params.chip) ?
 				 NUM_MPS_CLS_SRAM_L_INSTANCES :
 				 NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
 
@@ -1121,7 +1121,7 @@ int t4vf_change_mac(struct adapter *adapter, unsigned int viid,
 	struct fw_vi_mac_exact *p = &cmd.u.exact[0];
 	size_t len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
 					     u.exact[1]), 16);
-	unsigned int max_naddr = is_t4(adapter->chip) ?
+	unsigned int max_naddr = is_t4(adapter->params.chip) ?
 				 NUM_MPS_CLS_SRAM_L_INSTANCES :
 				 NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
 
-- 
1.8.0
