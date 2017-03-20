From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Update IngPad and IngPack values
Date: Mon, 20 Mar 2017 14:22:38 +0530
Message-ID: <1489999958-4682-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Arjun Vynipadath <arjun@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:48961 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753179AbdCTIxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 04:53:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun Vynipadath <arjun@chelsio.com>

We are using the smallest padding boundary (8 bytes), which isn't
smaller than the Memory Controller Read/Write Size

We get best performance in 100G when the Packing Boundary is a multiple
of the Maximum Payload Size. Its related to inefficient chopping of DMA
packets by PCIe, that causes more overhead on bus. So driver is helping
by making the starting address alignment to be MPS size.

We will try to determine PCIE MaxPayloadSize capabiltiy  and set
IngPackBoundary based on this value. If cache line size is greater than
MPS or determinig MPS fails, we will use cache line size to determine
IngPackBoundary(as before).

Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c     | 75 +++++++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h |  4 ++
 2 files changed, 60 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 87000cd..0de8eb7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -6369,7 +6369,6 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 	unsigned int stat_len = cache_line_size > 64 ? 128 : 64;
 	unsigned int fl_align = cache_line_size < 32 ? 32 : cache_line_size;
 	unsigned int fl_align_log = fls(fl_align) - 1;
-	unsigned int ingpad;
 
 	t4_write_reg(adap, SGE_HOST_PAGE_SIZE_A,
 		     HOSTPAGESIZEPF0_V(sge_hps) |
@@ -6389,6 +6388,10 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 						  INGPADBOUNDARY_SHIFT_X) |
 				 EGRSTATUSPAGESIZE_V(stat_len != 64));
 	} else {
+		unsigned int pack_align;
+		unsigned int ingpad, ingpack;
+		unsigned int pcie_cap;
+
 		/* T5 introduced the separation of the Free List Padding and
 		 * Packing Boundaries.  Thus, we can select a smaller Padding
 		 * Boundary to avoid uselessly chewing up PCIe Link and Memory
@@ -6401,27 +6404,62 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 		 * Size (the minimum unit of transfer to/from Memory).  If we
 		 * have a Padding Boundary which is smaller than the Memory
 		 * Line Size, that'll involve a Read-Modify-Write cycle on the
-		 * Memory Controller which is never good.  For T5 the smallest
-		 * Padding Boundary which we can select is 32 bytes which is
-		 * larger than any known Memory Controller Line Size so we'll
-		 * use that.
-		 *
-		 * T5 has a different interpretation of the "0" value for the
-		 * Packing Boundary.  This corresponds to 16 bytes instead of
-		 * the expected 32 bytes.  We never have a Packing Boundary
-		 * less than 32 bytes so we can't use that special value but
-		 * on the other hand, if we wanted 32 bytes, the best we can
-		 * really do is 64 bytes.
-		*/
-		if (fl_align <= 32) {
+		 * Memory Controller which is never good.
+		 */
+
+		/* We want the Packing Boundary to be based on the Cache Line
+		 * Size in order to help avoid False Sharing performance
+		 * issues between CPUs, etc.  We also want the Packing
+		 * Boundary to incorporate the PCI-E Maximum Payload Size.  We
+		 * get best performance when the Packing Boundary is a
+		 * multiple of the Maximum Payload Size.
+		 */
+		pack_align = fl_align;
+		pcie_cap = pci_find_capability(adap->pdev, PCI_CAP_ID_EXP);
+		if (pcie_cap) {
+			unsigned int mps, mps_log;
+			u16 devctl;
+
+			/* The PCIe Device Control Maximum Payload Size field
+			 * [bits 7:5] encodes sizes as powers of 2 starting at
+			 * 128 bytes.
+			 */
+			pci_read_config_word(adap->pdev,
+					     pcie_cap + PCI_EXP_DEVCTL,
+					     &devctl);
+			mps_log = ((devctl & PCI_EXP_DEVCTL_PAYLOAD) >> 5) + 7;
+			mps = 1 << mps_log;
+			if (mps > pack_align)
+				pack_align = mps;
+		}
+
+		/* N.B. T5/T6 have a crazy special interpretation of the "0"
+		 * value for the Packing Boundary.  This corresponds to 16
+		 * bytes instead of the expected 32 bytes.  So if we want 32
+		 * bytes, the best we can really do is 64 bytes ...
+		 */
+		if (pack_align <= 16) {
+			ingpack = INGPACKBOUNDARY_16B_X;
+			fl_align = 16;
+		} else if (pack_align == 32) {
+			ingpack = INGPACKBOUNDARY_64B_X;
 			fl_align = 64;
-			fl_align_log = 6;
+		} else {
+			unsigned int pack_align_log = fls(pack_align) - 1;
+
+			ingpack = pack_align_log - INGPACKBOUNDARY_SHIFT_X;
+			fl_align = pack_align;
 		}
 
+		/* Use the smallest Ingress Padding which isn't smaller than
+		 * the Memory Controller Read/Write Size.  We'll take that as
+		 * being 8 bytes since we don't know of any system with a
+		 * wider Memory Controller Bus Width.
+		 */
 		if (is_t5(adap->params.chip))
-			ingpad = INGPCIEBOUNDARY_32B_X;
+			ingpad = INGPADBOUNDARY_32B_X;
 		else
-			ingpad = T6_INGPADBOUNDARY_32B_X;
+			ingpad = T6_INGPADBOUNDARY_8B_X;
 
 		t4_set_reg_field(adap, SGE_CONTROL_A,
 				 INGPADBOUNDARY_V(INGPADBOUNDARY_M) |
@@ -6430,8 +6468,7 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 				 EGRSTATUSPAGESIZE_V(stat_len != 64));
 		t4_set_reg_field(adap, SGE_CONTROL2_A,
 				 INGPACKBOUNDARY_V(INGPACKBOUNDARY_M),
-				 INGPACKBOUNDARY_V(fl_align_log -
-						   INGPACKBOUNDARY_SHIFT_X));
+				 INGPACKBOUNDARY_V(ingpack));
 	}
 	/*
 	 * Adjust various SGE Free List Host Buffer Sizes.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index 36cf307..f6558cb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -54,11 +54,15 @@
 #define INGPADBOUNDARY_SHIFT_X		5
 
 #define T6_INGPADBOUNDARY_SHIFT_X	3
+#define T6_INGPADBOUNDARY_8B_X		0
 #define T6_INGPADBOUNDARY_32B_X		2
 
+#define INGPADBOUNDARY_32B_X		0
+
 /* CONTROL2 register */
 #define INGPACKBOUNDARY_SHIFT_X		5
 #define INGPACKBOUNDARY_16B_X		0
+#define INGPACKBOUNDARY_64B_X		1
 
 /* GTS register */
 #define SGE_TIMERREGS			6
-- 
2.1.0
