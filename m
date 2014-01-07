From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Fix namespace collision issue.
Date: Tue,  7 Jan 2014 16:58:07 +0530
Message-ID: <1389094088-6261-2-git-send-email-hariprasad@chelsio.com>
References: <1389094088-6261-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23781 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaAGLfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 06:35:53 -0500
In-Reply-To: <1389094088-6261-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |   4 --
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 100 ++++++++++++++---------------
 2 files changed, 50 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b97e35c..0d5b365 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -918,9 +918,6 @@ static inline int t4_wr_mbox_ns(struct adapter *adap, int mbox, const void *cmd,
 void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
 		       unsigned int data_reg, const u32 *vals,
 		       unsigned int nregs, unsigned int start_idx);
-void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
-		      unsigned int data_reg, u32 *vals, unsigned int nregs,
-		      unsigned int start_idx);
 
 struct fw_filter_wr;
 
@@ -945,7 +942,6 @@ int t4_prep_fw(struct adapter *adap, struct fw_info *fw_info,
 	       struct fw_hdr *card_fw, enum dev_state state, int *reset);
 int t4_prep_adapter(struct adapter *adapter);
 int t4_init_tp_params(struct adapter *adap);
-int t4_filter_field_shift(const struct adapter *adap, int filter_sel);
 int t4_port_init(struct adapter *adap, int mbox, int pf, int vf);
 void t4_fatal_err(struct adapter *adapter);
 int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index a396475..45bb037 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -111,7 +111,7 @@ void t4_set_reg_field(struct adapter *adapter, unsigned int addr, u32 mask,
  *	Reads registers that are accessed indirectly through an address/data
  *	register pair.
  */
-void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
+static void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
 			     unsigned int data_reg, u32 *vals,
 			     unsigned int nregs, unsigned int start_idx)
 {
@@ -3683,54 +3683,6 @@ int t4_prep_adapter(struct adapter *adapter)
 }
 
 /**
- *      t4_init_tp_params - initialize adap->params.tp
- *      @adap: the adapter
- *
- *      Initialize various fields of the adapter's TP Parameters structure.
- */
-int t4_init_tp_params(struct adapter *adap)
-{
-	int chan;
-	u32 v;
-
-	v = t4_read_reg(adap, TP_TIMER_RESOLUTION);
-	adap->params.tp.tre = TIMERRESOLUTION_GET(v);
-	adap->params.tp.dack_re = DELAYEDACKRESOLUTION_GET(v);
-
-	/* MODQ_REQ_MAP defaults to setting queues 0-3 to chan 0-3 */
-	for (chan = 0; chan < NCHAN; chan++)
-		adap->params.tp.tx_modq[chan] = chan;
-
-	/* Cache the adapter's Compressed Filter Mode and global Incress
-	 * Configuration.
-	 */
-	t4_read_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
-			 &adap->params.tp.vlan_pri_map, 1,
-			 TP_VLAN_PRI_MAP);
-	t4_read_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
-			 &adap->params.tp.ingress_config, 1,
-			 TP_INGRESS_CONFIG);
-
-	/* Now that we have TP_VLAN_PRI_MAP cached, we can calculate the field
-	 * shift positions of several elements of the Compressed Filter Tuple
-	 * for this adapter which we need frequently ...
-	 */
-	adap->params.tp.vlan_shift = t4_filter_field_shift(adap, F_VLAN);
-	adap->params.tp.vnic_shift = t4_filter_field_shift(adap, F_VNIC_ID);
-	adap->params.tp.port_shift = t4_filter_field_shift(adap, F_PORT);
-	adap->params.tp.protocol_shift = t4_filter_field_shift(adap,
-							       F_PROTOCOL);
-
-	/* If TP_INGRESS_CONFIG.VNID == 0, then TP_VLAN_PRI_MAP.VNIC_ID
-	 * represents the presense of an Outer VLAN instead of a VNIC ID.
-	 */
-	if ((adap->params.tp.ingress_config & F_VNIC) == 0)
-		adap->params.tp.vnic_shift = -1;
-
-	return 0;
-}
-
-/**
  *      t4_filter_field_shift - calculate filter field shift
  *      @adap: the adapter
  *      @filter_sel: the desired field (from TP_VLAN_PRI_MAP bits)
@@ -3739,7 +3691,7 @@ int t4_init_tp_params(struct adapter *adap)
  *      Filter Tuple.  The filter field is specified via its selection bit
  *      within TP_VLAN_PRI_MAL (filter mode).  E.g. F_VLAN.
  */
-int t4_filter_field_shift(const struct adapter *adap, int filter_sel)
+static int t4_filter_field_shift(const struct adapter *adap, int filter_sel)
 {
 	unsigned int filter_mode = adap->params.tp.vlan_pri_map;
 	unsigned int sel;
@@ -3785,6 +3737,54 @@ int t4_filter_field_shift(const struct adapter *adap, int filter_sel)
 	return field_shift;
 }
 
+/**
+ *      t4_init_tp_params - initialize adap->params.tp
+ *      @adap: the adapter
+ *
+ *      Initialize various fields of the adapter's TP Parameters structure.
+ */
+int t4_init_tp_params(struct adapter *adap)
+{
+	int chan;
+	u32 v;
+
+	v = t4_read_reg(adap, TP_TIMER_RESOLUTION);
+	adap->params.tp.tre = TIMERRESOLUTION_GET(v);
+	adap->params.tp.dack_re = DELAYEDACKRESOLUTION_GET(v);
+
+	/* MODQ_REQ_MAP defaults to setting queues 0-3 to chan 0-3 */
+	for (chan = 0; chan < NCHAN; chan++)
+		adap->params.tp.tx_modq[chan] = chan;
+
+	/* Cache the adapter's Compressed Filter Mode and global Incress
+	 * Configuration.
+	 */
+	t4_read_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+			 &adap->params.tp.vlan_pri_map, 1,
+			 TP_VLAN_PRI_MAP);
+	t4_read_indirect(adap, TP_PIO_ADDR, TP_PIO_DATA,
+			 &adap->params.tp.ingress_config, 1,
+			 TP_INGRESS_CONFIG);
+
+	/* Now that we have TP_VLAN_PRI_MAP cached, we can calculate the field
+	 * shift positions of several elements of the Compressed Filter Tuple
+	 * for this adapter which we need frequently ...
+	 */
+	adap->params.tp.vlan_shift = t4_filter_field_shift(adap, F_VLAN);
+	adap->params.tp.vnic_shift = t4_filter_field_shift(adap, F_VNIC_ID);
+	adap->params.tp.port_shift = t4_filter_field_shift(adap, F_PORT);
+	adap->params.tp.protocol_shift = t4_filter_field_shift(adap,
+							       F_PROTOCOL);
+
+	/* If TP_INGRESS_CONFIG.VNID == 0, then TP_VLAN_PRI_MAP.VNIC_ID
+	 * represents the presense of an Outer VLAN instead of a VNIC ID.
+	 */
+	if ((adap->params.tp.ingress_config & F_VNIC) == 0)
+		adap->params.tp.vnic_shift = -1;
+
+	return 0;
+}
+
 int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 {
 	u8 addr[6];
-- 
1.8.0
