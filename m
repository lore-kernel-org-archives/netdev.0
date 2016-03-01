From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/5] cxgb4vf: Make sge init code more readable
Date: Tue,  1 Mar 2016 17:19:34 +0530
Message-ID: <1456832976-12840-4-git-send-email-hariprasad@chelsio.com>
References: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com, leedom@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:58531 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753350AbcCALqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:46:55 -0500
In-Reply-To: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a new function t4vf_fl_pkt_align() and use the same in SGE
initialization code to find out freelist packet alignment

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         | 40 ++--------------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  1 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 55 ++++++++++++++++++++++
 3 files changed, 59 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index ba6a4e3471f0..1ccd282949a5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2618,7 +2618,6 @@ int t4vf_sge_init(struct adapter *adapter)
 	u32 fl0 = sge_params->sge_fl_buffer_size[0];
 	u32 fl1 = sge_params->sge_fl_buffer_size[1];
 	struct sge *s = &adapter->sge;
-	unsigned int ingpadboundary, ingpackboundary, ingpad_shift;
 
 	/*
 	 * Start by vetting the basic SGE parameters which have been set up by
@@ -2630,7 +2629,8 @@ int t4vf_sge_init(struct adapter *adapter)
 			fl0, fl1);
 		return -EINVAL;
 	}
-	if ((sge_params->sge_control & RXPKTCPLMODE_F) == 0) {
+	if ((sge_params->sge_control & RXPKTCPLMODE_F) !=
+	    RXPKTCPLMODE_V(RXPKTCPLMODE_SPLIT_X)) {
 		dev_err(adapter->pdev_dev, "bad SGE CPL MODE\n");
 		return -EINVAL;
 	}
@@ -2643,41 +2643,7 @@ int t4vf_sge_init(struct adapter *adapter)
 	s->stat_len = ((sge_params->sge_control & EGRSTATUSPAGESIZE_F)
 			? 128 : 64);
 	s->pktshift = PKTSHIFT_G(sge_params->sge_control);
-
-	/* T4 uses a single control field to specify both the PCIe Padding and
-	 * Packing Boundary.  T5 introduced the ability to specify these
-	 * separately.  The actual Ingress Packet Data alignment boundary
-	 * within Packed Buffer Mode is the maximum of these two
-	 * specifications.  (Note that it makes no real practical sense to
-	 * have the Pading Boudary be larger than the Packing Boundary but you
-	 * could set the chip up that way and, in fact, legacy T4 code would
-	 * end doing this because it would initialize the Padding Boundary and
-	 * leave the Packing Boundary initialized to 0 (16 bytes).)
-	 * Padding Boundary values in T6 starts from 8B,
-	 * where as it is 32B for T4 and T5.
-	 */
-	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
-		ingpad_shift = INGPADBOUNDARY_SHIFT_X;
-	else
-		ingpad_shift = T6_INGPADBOUNDARY_SHIFT_X;
-
-	ingpadboundary = 1 << (INGPADBOUNDARY_G(sge_params->sge_control) +
-			       ingpad_shift);
-	if (is_t4(adapter->params.chip)) {
-		s->fl_align = ingpadboundary;
-	} else {
-		/* T5 has a different interpretation of one of the PCIe Packing
-		 * Boundary values.
-		 */
-		ingpackboundary = INGPACKBOUNDARY_G(sge_params->sge_control2);
-		if (ingpackboundary == INGPACKBOUNDARY_16B_X)
-			ingpackboundary = 16;
-		else
-			ingpackboundary = 1 << (ingpackboundary +
-						INGPACKBOUNDARY_SHIFT_X);
-
-		s->fl_align = max(ingpadboundary, ingpackboundary);
-	}
+	s->fl_align = t4vf_fl_pkt_align(adapter);
 
 	/* A FL with <= fl_starve_thres buffers is starving and a periodic
 	 * timer will attempt to refill it.  This needs to be larger than the
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 6ce302fe1a61..9b40a85cc1e4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -309,6 +309,7 @@ int t4vf_port_init(struct adapter *, int);
 int t4vf_fw_reset(struct adapter *);
 int t4vf_set_params(struct adapter *, unsigned int, const u32 *, const u32 *);
 
+int t4vf_fl_pkt_align(struct adapter *adapter);
 enum t4_bar2_qtype { T4_BAR2_QTYPE_EGRESS, T4_BAR2_QTYPE_INGRESS };
 int t4vf_bar2_sge_qregs(struct adapter *adapter,
 			unsigned int qid,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 54220117dcba..fed83d88fc4e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -418,6 +418,61 @@ int t4vf_set_params(struct adapter *adapter, unsigned int nparams,
 }
 
 /**
+ *	t4vf_fl_pkt_align - return the fl packet alignment
+ *	@adapter: the adapter
+ *
+ *	T4 has a single field to specify the packing and padding boundary.
+ *	T5 onwards has separate fields for this and hence the alignment for
+ *	next packet offset is maximum of these two.  And T6 changes the
+ *	Ingress Padding Boundary Shift, so it's all a mess and it's best
+ *	if we put this in low-level Common Code ...
+ *
+ */
+int t4vf_fl_pkt_align(struct adapter *adapter)
+{
+	u32 sge_control, sge_control2;
+	unsigned int ingpadboundary, ingpackboundary, fl_align, ingpad_shift;
+
+	sge_control = adapter->params.sge.sge_control;
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
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
+		ingpad_shift = INGPADBOUNDARY_SHIFT_X;
+	else
+		ingpad_shift = T6_INGPADBOUNDARY_SHIFT_X;
+
+	ingpadboundary = 1 << (INGPADBOUNDARY_G(sge_control) + ingpad_shift);
+
+	fl_align = ingpadboundary;
+	if (!is_t4(adapter->params.chip)) {
+		/* T5 has a different interpretation of one of the PCIe Packing
+		 * Boundary values.
+		 */
+		sge_control2 = adapter->params.sge.sge_control2;
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
  *	t4vf_bar2_sge_qregs - return BAR2 SGE Queue register information
  *	@adapter: the adapter
  *	@qid: the Queue ID
-- 
2.3.4
