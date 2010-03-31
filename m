From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/8] qlcnic: update oncard memory size check
Date: Wed, 31 Mar 2010 05:03:41 -0700
Message-ID: <1270037026-9062-4-git-send-email-amit.salecha@qlogic.com>
References: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:61524 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757123Ab0CaMDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 08:03:48 -0400
In-Reply-To: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>

All QLogic converged NICs have 128-bit 128MB on card memory.
Fix the limit check from 64MB to 128MB and remove unnecessary
64-bit read/write checks.

Signed-off-by: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hdr.h |    2 +-
 drivers/net/qlcnic/qlcnic_hw.c  |   55 +++++++++++++++++----------------------
 2 files changed, 25 insertions(+), 32 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 25465a9..e9fb692 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -449,7 +449,7 @@ enum {
 #define QLCNIC_ADDR_OCM1	(0x0000000200400000ULL)
 #define QLCNIC_ADDR_OCM1_MAX	(0x00000002004fffffULL)
 #define QLCNIC_ADDR_QDR_NET	(0x0000000300000000ULL)
-#define QLCNIC_ADDR_QDR_NET_MAX_P3 (0x0000000303ffffffULL)
+#define QLCNIC_ADDR_QDR_NET_MAX (0x0000000307ffffffULL)
 
 /*
  *   Register offsets for MN
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index b977874..419f46e 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -963,7 +963,6 @@ qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
 {
 	int i, j, ret;
 	u32 temp, off8;
-	u64 stride;
 	void __iomem *mem_crb;
 
 	/* Only 64-bit aligned access */
@@ -972,7 +971,7 @@ qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
 
 	/* P3 onward, test agent base for MIU and SIU is same */
 	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
-				QLCNIC_ADDR_QDR_NET_MAX_P3)) {
+				QLCNIC_ADDR_QDR_NET_MAX)) {
 		mem_crb = qlcnic_get_ioaddr(adapter,
 				QLCNIC_CRB_QDR_NET+MIU_TEST_AGT_BASE);
 		goto correct;
@@ -990,9 +989,7 @@ qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
 	return -EIO;
 
 correct:
-	stride = QLCNIC_IS_REVISION_P3P(adapter->ahw.revision_id) ? 16 : 8;
-
-	off8 = off & ~(stride-1);
+	off8 = off & ~0xf;
 
 	mutex_lock(&adapter->ahw.mem_lock);
 
@@ -1000,30 +997,28 @@ correct:
 	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
 
 	i = 0;
-	if (stride == 16) {
-		writel(TA_CTL_ENABLE, (mem_crb + TEST_AGT_CTRL));
-		writel((TA_CTL_START | TA_CTL_ENABLE),
-				(mem_crb + TEST_AGT_CTRL));
-
-		for (j = 0; j < MAX_CTL_CHECK; j++) {
-			temp = readl(mem_crb + TEST_AGT_CTRL);
-			if ((temp & TA_CTL_BUSY) == 0)
-				break;
-		}
+	writel(TA_CTL_ENABLE, (mem_crb + TEST_AGT_CTRL));
+	writel((TA_CTL_START | TA_CTL_ENABLE),
+			(mem_crb + TEST_AGT_CTRL));
 
-		if (j >= MAX_CTL_CHECK) {
-			ret = -EIO;
-			goto done;
-		}
+	for (j = 0; j < MAX_CTL_CHECK; j++) {
+		temp = readl(mem_crb + TEST_AGT_CTRL);
+		if ((temp & TA_CTL_BUSY) == 0)
+			break;
+	}
 
-		i = (off & 0xf) ? 0 : 2;
-		writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i)),
-				mem_crb + MIU_TEST_AGT_WRDATA(i));
-		writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i+1)),
-				mem_crb + MIU_TEST_AGT_WRDATA(i+1));
-		i = (off & 0xf) ? 2 : 0;
+	if (j >= MAX_CTL_CHECK) {
+		ret = -EIO;
+		goto done;
 	}
 
+	i = (off & 0xf) ? 0 : 2;
+	writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i)),
+			mem_crb + MIU_TEST_AGT_WRDATA(i));
+	writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i+1)),
+			mem_crb + MIU_TEST_AGT_WRDATA(i+1));
+	i = (off & 0xf) ? 2 : 0;
+
 	writel(data & 0xffffffff,
 			mem_crb + MIU_TEST_AGT_WRDATA(i));
 	writel((data >> 32) & 0xffffffff,
@@ -1059,7 +1054,7 @@ qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
 {
 	int j, ret;
 	u32 temp, off8;
-	u64 val, stride;
+	u64 val;
 	void __iomem *mem_crb;
 
 	/* Only 64-bit aligned access */
@@ -1068,7 +1063,7 @@ qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
 
 	/* P3 onward, test agent base for MIU and SIU is same */
 	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
-				QLCNIC_ADDR_QDR_NET_MAX_P3)) {
+				QLCNIC_ADDR_QDR_NET_MAX)) {
 		mem_crb = qlcnic_get_ioaddr(adapter,
 				QLCNIC_CRB_QDR_NET+MIU_TEST_AGT_BASE);
 		goto correct;
@@ -1088,9 +1083,7 @@ qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
 	return -EIO;
 
 correct:
-	stride = QLCNIC_IS_REVISION_P3P(adapter->ahw.revision_id) ? 16 : 8;
-
-	off8 = off & ~(stride-1);
+	off8 = off & ~0xf;
 
 	mutex_lock(&adapter->ahw.mem_lock);
 
@@ -1112,7 +1105,7 @@ correct:
 		ret = -EIO;
 	} else {
 		off8 = MIU_TEST_AGT_RDDATA_LO;
-		if ((stride == 16) && (off & 0xf))
+		if (off & 0xf)
 			off8 = MIU_TEST_AGT_RDDATA_UPPER_LO;
 
 		temp = readl(mem_crb + off8 + 4);
-- 
1.6.0.2

