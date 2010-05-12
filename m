From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/4] netxen: remove unnecessary size checks
Date: Wed, 12 May 2010 02:53:03 -0700
Message-ID: <1273657985-13405-3-git-send-email-amit.salecha@qlogic.com>
References: <1273657985-13405-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:7418 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755334Ab0ELJxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 05:53:09 -0400
In-Reply-To: <1273657985-13405-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

NX3031 have 64bit on card memory. Fix the limit check to
64MB and remove unnecessary 128bit read/write check.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hdr.h |    6 ----
 drivers/net/netxen/netxen_nic_hw.c  |   52 +++++-----------------------------
 2 files changed, 8 insertions(+), 50 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index d930068..d8bd73d 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -681,14 +681,8 @@ enum {
 #define MIU_TEST_AGT_ADDR_HI		(0x08)
 #define MIU_TEST_AGT_WRDATA_LO		(0x10)
 #define MIU_TEST_AGT_WRDATA_HI		(0x14)
-#define MIU_TEST_AGT_WRDATA_UPPER_LO	(0x20)
-#define MIU_TEST_AGT_WRDATA_UPPER_HI	(0x24)
-#define MIU_TEST_AGT_WRDATA(i)		(0x10+(0x10*((i)>>1))+(4*((i)&1)))
 #define MIU_TEST_AGT_RDDATA_LO		(0x18)
 #define MIU_TEST_AGT_RDDATA_HI		(0x1c)
-#define MIU_TEST_AGT_RDDATA_UPPER_LO	(0x28)
-#define MIU_TEST_AGT_RDDATA_UPPER_HI	(0x2c)
-#define MIU_TEST_AGT_RDDATA(i)		(0x18+(0x10*((i)>>1))+(4*((i)&1)))
 
 #define MIU_TEST_AGT_ADDR_MASK		0xfffffff8
 #define MIU_TEST_AGT_UPPER_ADDR(off)	(0)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 5e5fe2f..87bc910 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1621,9 +1621,8 @@ static int
 netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 		u64 off, u64 data)
 {
-	int i, j, ret;
+	int j, ret;
 	u32 temp, off8;
-	u64 stride;
 	void __iomem *mem_crb;
 
 	/* Only 64-bit aligned access */
@@ -1650,44 +1649,17 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 	return -EIO;
 
 correct:
-	stride = NX_IS_REVISION_P3P(adapter->ahw.revision_id) ? 16 : 8;
-
-	off8 = off & ~(stride-1);
+	off8 = off & 0xfffffff8;
 
 	spin_lock(&adapter->ahw.mem_lock);
 
 	writel(off8, (mem_crb + MIU_TEST_AGT_ADDR_LO));
 	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
 
-	i = 0;
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
-
-		if (j >= MAX_CTL_CHECK) {
-			ret = -EIO;
-			goto done;
-		}
-
-		i = (off & 0xf) ? 0 : 2;
-		writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i)),
-				mem_crb + MIU_TEST_AGT_WRDATA(i));
-		writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i+1)),
-				mem_crb + MIU_TEST_AGT_WRDATA(i+1));
-		i = (off & 0xf) ? 2 : 0;
-	}
-
 	writel(data & 0xffffffff,
-			mem_crb + MIU_TEST_AGT_WRDATA(i));
+			mem_crb + MIU_TEST_AGT_WRDATA_LO);
 	writel((data >> 32) & 0xffffffff,
-			mem_crb + MIU_TEST_AGT_WRDATA(i+1));
+			mem_crb + MIU_TEST_AGT_WRDATA_HI);
 
 	writel((TA_CTL_ENABLE | TA_CTL_WRITE), (mem_crb + TEST_AGT_CTRL));
 	writel((TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE),
@@ -1707,7 +1679,6 @@ correct:
 	} else
 		ret = 0;
 
-done:
 	spin_unlock(&adapter->ahw.mem_lock);
 
 	return ret;
@@ -1719,7 +1690,7 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 {
 	int j, ret;
 	u32 temp, off8;
-	u64 val, stride;
+	u64 val;
 	void __iomem *mem_crb;
 
 	/* Only 64-bit aligned access */
@@ -1748,9 +1719,7 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 	return -EIO;
 
 correct:
-	stride = NX_IS_REVISION_P3P(adapter->ahw.revision_id) ? 16 : 8;
-
-	off8 = off & ~(stride-1);
+	off8 = off & 0xfffffff8;
 
 	spin_lock(&adapter->ahw.mem_lock);
 
@@ -1771,13 +1740,8 @@ correct:
 					"failed to read through agent\n");
 		ret = -EIO;
 	} else {
-		off8 = MIU_TEST_AGT_RDDATA_LO;
-		if ((stride == 16) && (off & 0xf))
-			off8 = MIU_TEST_AGT_RDDATA_UPPER_LO;
-
-		temp = readl(mem_crb + off8 + 4);
-		val = (u64)temp << 32;
-		val |= readl(mem_crb + off8);
+		val = (u64)(readl(mem_crb + MIU_TEST_AGT_RDDATA_HI)) << 32;
+		val |= readl(mem_crb + MIU_TEST_AGT_RDDATA_LO);
 		*data = val;
 		ret = 0;
 	}
-- 
1.6.0.2

