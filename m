From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/9] cxgb4/cxgb4vf: Update Ingress padding boundary values for T6 adapter
Date: Wed, 23 Dec 2015 22:47:13 +0530
Message-ID: <1450891039-17196-4-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38197 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933023AbbLWRQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:16:02 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingress padding boundary values got changed for T6.
    T5: 0=32B 1=64B 2=128B 3=256B 4=512B 5=1024B 6=2048B 7=4096B
    T6: 0=8B  1=16B 2=32B  3=64B  4=128B 5=128B  6=256B  7=512B

Updating the driver to set the correct boundary values in SGE_CONTROL to
32B.
Also, need to take care of this fl alignment change when calculating the
next packet offset.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h     |  1 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c       | 33 +-------------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c     | 62 +++++++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h |  3 ++
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c     | 11 ++++-
 5 files changed, 76 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index eab57cf..5c193a5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1256,6 +1256,7 @@ int t4_phy_fw_ver(struct adapter *adap, int *phy_fw_ver);
 int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op);
 int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 		  const u8 *fw_data, unsigned int size, int force);
+int t4_fl_pkt_align(struct adapter *adap);
 unsigned int t4_flash_cfg_addr(struct adapter *adapter);
 int t4_check_fw_version(struct adapter *adap);
 int t4_get_fw_version(struct adapter *adapter, u32 *vers);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 5e3ffa7..099b946 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -3173,8 +3173,7 @@ static int t4_sge_init_soft(struct adapter *adap)
 int t4_sge_init(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
-	u32 sge_control, sge_control2, sge_conm_ctrl;
-	unsigned int ingpadboundary, ingpackboundary;
+	u32 sge_control, sge_conm_ctrl;
 	int ret, egress_threshold;
 
 	/*
@@ -3185,35 +3184,7 @@ int t4_sge_init(struct adapter *adap)
 	s->pktshift = PKTSHIFT_G(sge_control);
 	s->stat_len = (sge_control & EGRSTATUSPAGESIZE_F) ? 128 : 64;
 
-	/* T4 uses a single control field to specify both the PCIe Padding and
-	 * Packing Boundary.  T5 introduced the ability to specify these
-	 * separately.  The actual Ingress Packet Data alignment boundary
-	 * within Packed Buffer Mode is the maximum of these two
-	 * specifications.  (Note that it makes no real practical sense to
-	 * have the Pading Boudary be larger than the Packing Boundary but you
-	 * could set the chip up that way and, in fact, legacy T4 code would
-	 * end doing this because it would initialize the Padding Boundary and
-	 * leave the Packing Boundary initialized to 0 (16 bytes).)
-	 */
-	ingpadboundary = 1 << (INGPADBOUNDARY_G(sge_control) +
-			       INGPADBOUNDARY_SHIFT_X);
-	if (is_t4(adap->params.chip)) {
-		s->fl_align = ingpadboundary;
-	} else {
-		/* T5 has a different interpretation of one of the PCIe Packing
-		 * Boundary values.
-		 */
-		sge_control2 = t4_read_reg(adap, SGE_CONTROL2_A);
-		ingpackboundary = INGPACKBOUNDARY_G(sge_control2);
-		if (ingpackboundary == INGPACKBOUNDARY_16B_X)
-			ingpackboundary = 16;
-		else
-			ingpackboundary = 1 << (ingpackboundary +
-						INGPACKBOUNDARY_SHIFT_X);
-
-		s->fl_align = max(ingpadboundary, ingpackboundary);
-	}
-
+	s->fl_align = t4_fl_pkt_align(adap);
 	ret = t4_sge_init_soft(adap);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 5266011..42754c0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -6097,6 +6097,59 @@ int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 }
 
 /**
+ *	t4_fl_pkt_align - return the fl packet alignment
+ *	@adap: the adapter
+ *
+ *	T4 has a single field to specify the packing and padding boundary.
+ *	T5 onwards has separate fields for this and hence the alignment for
+ *	next packet offset is maximum of these two.
+ *
+ */
+int t4_fl_pkt_align(struct adapter *adap)
+{
+	u32 sge_control, sge_control2;
+	unsigned int ingpadboundary, ingpackboundary, fl_align, ingpad_shift;
+
+	sge_control = t4_read_reg(adap, SGE_CONTROL_A);
+
+	/* T4 uses a single control field to specify both the PCIe Padding and
+	 * Packing Boundary.  T5 introduced the ability to specify these
+	 * separately.  The actual Ingress Packet Data alignment boundary
+	 * within Packed Buffer Mode is the maximum of these two
+	 * specifications.  (Note that it makes no real practical sense to
+	 * have the Pading Boudary be larger than the Packing Boundary but you
+	 * could set the chip up that way and, in fact, legacy T4 code would
+	 * end doing this because it would initialize the Padding Boundary and
+	 * leave the Packing Boundary initialized to 0 (16 bytes).)
+	 * Padding Boundary values in T6 starts from 8B,
+	 * where as it is 32B for T4 and T5.
+	 */
+	if (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5)
+		ingpad_shift = INGPADBOUNDARY_SHIFT_X;
+	else
+		ingpad_shift = T6_INGPADBOUNDARY_SHIFT_X;
+
+	ingpadboundary = 1 << (INGPADBOUNDARY_G(sge_control) + ingpad_shift);
+
+	fl_align = ingpadboundary;
+	if (!is_t4(adap->params.chip)) {
+		/* T5 has a weird interpretation of one of the PCIe Packing
+		 * Boundary values.  No idea why ...
+		 */
+		sge_control2 = t4_read_reg(adap, SGE_CONTROL2_A);
+		ingpackboundary = INGPACKBOUNDARY_G(sge_control2);
+		if (ingpackboundary == INGPACKBOUNDARY_16B_X)
+			ingpackboundary = 16;
+		else
+			ingpackboundary = 1 << (ingpackboundary +
+						INGPACKBOUNDARY_SHIFT_X);
+
+		fl_align = max(ingpadboundary, ingpackboundary);
+	}
+	return fl_align;
+}
+
+/**
  *	t4_fixup_host_params - fix up host-dependent parameters
  *	@adap: the adapter
  *	@page_size: the host's Base Page Size
@@ -6114,6 +6167,7 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 	unsigned int stat_len = cache_line_size > 64 ? 128 : 64;
 	unsigned int fl_align = cache_line_size < 32 ? 32 : cache_line_size;
 	unsigned int fl_align_log = fls(fl_align) - 1;
+	unsigned int ingpad;
 
 	t4_write_reg(adap, SGE_HOST_PAGE_SIZE_A,
 		     HOSTPAGESIZEPF0_V(sge_hps) |
@@ -6161,10 +6215,16 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 			fl_align = 64;
 			fl_align_log = 6;
 		}
+
+		if (is_t5(adap->params.chip))
+			ingpad = INGPCIEBOUNDARY_32B_X;
+		else
+			ingpad = T6_INGPADBOUNDARY_32B_X;
+
 		t4_set_reg_field(adap, SGE_CONTROL_A,
 				 INGPADBOUNDARY_V(INGPADBOUNDARY_M) |
 				 EGRSTATUSPAGESIZE_F,
-				 INGPADBOUNDARY_V(INGPCIEBOUNDARY_32B_X) |
+				 INGPADBOUNDARY_V(ingpad) |
 				 EGRSTATUSPAGESIZE_V(stat_len != 64));
 		t4_set_reg_field(adap, SGE_CONTROL2_A,
 				 INGPACKBOUNDARY_V(INGPACKBOUNDARY_M),
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index 7bdee3b..a5231fa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -53,6 +53,9 @@
 
 #define INGPADBOUNDARY_SHIFT_X		5
 
+#define T6_INGPADBOUNDARY_SHIFT_X	3
+#define T6_INGPADBOUNDARY_32B_X		2
+
 /* CONTROL2 register */
 #define INGPACKBOUNDARY_SHIFT_X		5
 #define INGPACKBOUNDARY_16B_X		0
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index fa3786a..6528231 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2607,7 +2607,7 @@ int t4vf_sge_init(struct adapter *adapter)
 	u32 fl0 = sge_params->sge_fl_buffer_size[0];
 	u32 fl1 = sge_params->sge_fl_buffer_size[1];
 	struct sge *s = &adapter->sge;
-	unsigned int ingpadboundary, ingpackboundary;
+	unsigned int ingpadboundary, ingpackboundary, ingpad_shift;
 
 	/*
 	 * Start by vetting the basic SGE parameters which have been set up by
@@ -2642,9 +2642,16 @@ int t4vf_sge_init(struct adapter *adapter)
 	 * could set the chip up that way and, in fact, legacy T4 code would
 	 * end doing this because it would initialize the Padding Boundary and
 	 * leave the Packing Boundary initialized to 0 (16 bytes).)
+	 * Padding Boundary values in T6 starts from 8B,
+	 * where as it is 32B for T4 and T5.
 	 */
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
+		ingpad_shift = INGPADBOUNDARY_SHIFT_X;
+	else
+		ingpad_shift = T6_INGPADBOUNDARY_SHIFT_X;
+
 	ingpadboundary = 1 << (INGPADBOUNDARY_G(sge_params->sge_control) +
-			       INGPADBOUNDARY_SHIFT_X);
+			       ingpad_shift);
 	if (is_t4(adapter->params.chip)) {
 		s->fl_align = ingpadboundary;
 	} else {
-- 
2.3.4
