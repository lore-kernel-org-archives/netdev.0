From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 6/6] cxgb4: Use FW LDST cmd to access TP_PIO_{ADDR,DATA} register first
Date: Fri,  5 Jun 2015 14:24:52 +0530
Message-ID: <1433494492-7638-7-git-send-email-hariprasad@chelsio.com>
References: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15242 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753796AbbFEDlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 23:41:51 -0400
In-Reply-To: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TP_PIO_{ADDR,DATA} registers are are in conflict with the firmware's
use of these registers. Added a routine to access it through FW LDST
cmd.
Access all TP_PIO_{ADDR,DATA} register access through new routine if FW
is alive. If firmware is dead, than fall back to indirect access.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 102 +++++++++++++++++++-----
 2 files changed, 83 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3897e28..0e27f22 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4068,8 +4068,8 @@ static int adap_init0(struct adapter *adap)
 			     adap->params.b_wnd);
 	}
 	t4_init_sge_params(adap);
-	t4_init_tp_params(adap);
 	adap->flags |= FW_OK;
+	t4_init_tp_params(adap);
 	return 0;
 
 	/*
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index efd0aa1..b411098 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3633,6 +3633,40 @@ int t4_read_rss(struct adapter *adapter, u16 *map)
 }
 
 /**
+ *	t4_fw_tp_pio_rw - Access TP PIO through LDST
+ *	@adap: the adapter
+ *	@vals: where the indirect register values are stored/written
+ *	@nregs: how many indirect registers to read/write
+ *	@start_idx: index of first indirect register to read/write
+ *	@rw: Read (1) or Write (0)
+ *
+ *	Access TP PIO registers through LDST
+ */
+static void t4_fw_tp_pio_rw(struct adapter *adap, u32 *vals, unsigned int nregs,
+			    unsigned int start_index, unsigned int rw)
+{
+	int ret, i;
+	int cmd = FW_LDST_ADDRSPC_TP_PIO;
+	struct fw_ldst_cmd c;
+
+	for (i = 0 ; i < nregs; i++) {
+		memset(&c, 0, sizeof(c));
+		c.op_to_addrspace = cpu_to_be32(FW_CMD_OP_V(FW_LDST_CMD) |
+						FW_CMD_REQUEST_F |
+						(rw ? FW_CMD_READ_F :
+						      FW_CMD_WRITE_F) |
+						FW_LDST_CMD_ADDRSPACE_V(cmd));
+		c.cycles_to_len16 = cpu_to_be32(FW_LEN16(c));
+
+		c.u.addrval.addr = cpu_to_be32(start_index + i);
+		c.u.addrval.val  = rw ? 0 : cpu_to_be32(vals[i]);
+		ret = t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), &c);
+		if (!ret && rw)
+			vals[i] = be32_to_cpu(c.u.addrval.val);
+	}
+}
+
+/**
  *	t4_read_rss_key - read the global RSS key
  *	@adap: the adapter
  *	@key: 10-entry array holding the 320-bit RSS key
@@ -3641,8 +3675,11 @@ int t4_read_rss(struct adapter *adapter, u16 *map)
  */
 void t4_read_rss_key(struct adapter *adap, u32 *key)
 {
-	t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
-			 TP_RSS_SECRET_KEY0_A);
+	if (adap->flags & FW_OK)
+		t4_fw_tp_pio_rw(adap, key, 10, TP_RSS_SECRET_KEY0_A, 1);
+	else
+		t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
+				 TP_RSS_SECRET_KEY0_A);
 }
 
 /**
@@ -3668,8 +3705,11 @@ void t4_write_rss_key(struct adapter *adap, const u32 *key, int idx)
 	    (vrt & KEYEXTEND_F) && (KEYMODE_G(vrt) == 3))
 		rss_key_addr_cnt = 32;
 
-	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
-			  TP_RSS_SECRET_KEY0_A);
+	if (adap->flags & FW_OK)
+		t4_fw_tp_pio_rw(adap, (void *)key, 10, TP_RSS_SECRET_KEY0_A, 0);
+	else
+		t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
+				  TP_RSS_SECRET_KEY0_A);
 
 	if (idx >= 0 && idx < rss_key_addr_cnt) {
 		if (rss_key_addr_cnt > 16)
@@ -3694,8 +3734,12 @@ void t4_write_rss_key(struct adapter *adap, const u32 *key, int idx)
 void t4_read_rss_pf_config(struct adapter *adapter, unsigned int index,
 			   u32 *valp)
 {
-	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			 valp, 1, TP_RSS_PF0_CONFIG_A + index);
+	if (adapter->flags & FW_OK)
+		t4_fw_tp_pio_rw(adapter, valp, 1,
+				TP_RSS_PF0_CONFIG_A + index, 1);
+	else
+		t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+				 valp, 1, TP_RSS_PF0_CONFIG_A + index);
 }
 
 /**
@@ -3730,10 +3774,15 @@ void t4_read_rss_vf_config(struct adapter *adapter, unsigned int index,
 
 	/* Grab the VFL/VFH values ...
 	 */
-	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			 vfl, 1, TP_RSS_VFL_CONFIG_A);
-	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			 vfh, 1, TP_RSS_VFH_CONFIG_A);
+	if (adapter->flags & FW_OK) {
+		t4_fw_tp_pio_rw(adapter, vfl, 1, TP_RSS_VFL_CONFIG_A, 1);
+		t4_fw_tp_pio_rw(adapter, vfh, 1, TP_RSS_VFH_CONFIG_A, 1);
+	} else {
+		t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+				 vfl, 1, TP_RSS_VFL_CONFIG_A);
+		t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+				 vfh, 1, TP_RSS_VFH_CONFIG_A);
+	}
 }
 
 /**
@@ -3746,8 +3795,11 @@ u32 t4_read_rss_pf_map(struct adapter *adapter)
 {
 	u32 pfmap;
 
-	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			 &pfmap, 1, TP_RSS_PF_MAP_A);
+	if (adapter->flags & FW_OK)
+		t4_fw_tp_pio_rw(adapter, &pfmap, 1, TP_RSS_PF_MAP_A, 1);
+	else
+		t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+				 &pfmap, 1, TP_RSS_PF_MAP_A);
 	return pfmap;
 }
 
@@ -3761,8 +3813,11 @@ u32 t4_read_rss_pf_mask(struct adapter *adapter)
 {
 	u32 pfmask;
 
-	t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			 &pfmask, 1, TP_RSS_PF_MSK_A);
+	if (adapter->flags & FW_OK)
+		t4_fw_tp_pio_rw(adapter, &pfmask, 1, TP_RSS_PF_MSK_A, 1);
+	else
+		t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+				 &pfmask, 1, TP_RSS_PF_MSK_A);
 	return pfmask;
 }
 
@@ -6137,12 +6192,19 @@ int t4_init_tp_params(struct adapter *adap)
 	/* Cache the adapter's Compressed Filter Mode and global Incress
 	 * Configuration.
 	 */
-	t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			 &adap->params.tp.vlan_pri_map, 1,
-			 TP_VLAN_PRI_MAP_A);
-	t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			 &adap->params.tp.ingress_config, 1,
-			 TP_INGRESS_CONFIG_A);
+	if (adap->flags & FW_OK) {
+		t4_fw_tp_pio_rw(adap, &adap->params.tp.vlan_pri_map, 1,
+				TP_VLAN_PRI_MAP_A, 1);
+		t4_fw_tp_pio_rw(adap, &adap->params.tp.ingress_config, 1,
+				TP_INGRESS_CONFIG_A, 1);
+	} else {
+		t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+				 &adap->params.tp.vlan_pri_map, 1,
+				 TP_VLAN_PRI_MAP_A);
+		t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
+				 &adap->params.tp.ingress_config, 1,
+				 TP_INGRESS_CONFIG_A);
+	}
 
 	/* Now that we have TP_VLAN_PRI_MAP cached, we can calculate the field
 	 * shift positions of several elements of the Compressed Filter Tuple
-- 
2.3.4
