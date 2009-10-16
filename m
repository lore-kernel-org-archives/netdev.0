From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 3/7] netxen: 128 memory controller support
Date: Thu, 15 Oct 2009 23:09:09 -0700
Message-ID: <1255673353-31797-4-git-send-email-dhananjay@netxen.com>
References: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@qlogic.com>,
	Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45938 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753750AbZJPGJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 02:09:50 -0400
In-Reply-To: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@qlogic.com>

Future revisions of the chip have 128 bit memory
transactions. Require drivers to implement rmw
in case of sub-128 bit accesses by driver. This
is mostly used by diagnostic tools.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hdr.h |    8 ++++-
 drivers/net/netxen/netxen_nic_hw.c  |   55 +++++++++++++++++++++++++++++-----
 2 files changed, 53 insertions(+), 10 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 3461350..d40fe33 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -678,10 +678,14 @@ enum {
 #define MIU_TEST_AGT_ADDR_HI		(0x08)
 #define MIU_TEST_AGT_WRDATA_LO		(0x10)
 #define MIU_TEST_AGT_WRDATA_HI		(0x14)
-#define MIU_TEST_AGT_WRDATA(i)		(0x10+(4*(i)))
+#define MIU_TEST_AGT_WRDATA_UPPER_LO	(0x20)
+#define MIU_TEST_AGT_WRDATA_UPPER_HI	(0x24)
+#define MIU_TEST_AGT_WRDATA(i)		(0x10+(0x10*((i)>>1))+(4*((i)&1)))
 #define MIU_TEST_AGT_RDDATA_LO		(0x18)
 #define MIU_TEST_AGT_RDDATA_HI		(0x1c)
-#define MIU_TEST_AGT_RDDATA(i)		(0x18+(4*(i)))
+#define MIU_TEST_AGT_RDDATA_UPPER_LO	(0x28)
+#define MIU_TEST_AGT_RDDATA_UPPER_HI	(0x2c)
+#define MIU_TEST_AGT_RDDATA(i)		(0x18+(0x10*((i)>>1))+(4*((i)&1)))
 
 #define MIU_TEST_AGT_ADDR_MASK		0xfffffff8
 #define MIU_TEST_AGT_UPPER_ADDR(off)	(0)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index d067bee..52a2f2d 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1569,8 +1569,9 @@ static int
 netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 		u64 off, u64 data)
 {
-	int j, ret;
+	int i, j, ret;
 	u32 temp, off8;
+	u64 stride;
 	void __iomem *mem_crb;
 
 	/* Only 64-bit aligned access */
@@ -1597,14 +1598,45 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 	return -EIO;
 
 correct:
-	off8 = off & MIU_TEST_AGT_ADDR_MASK;
+	stride = NX_IS_REVISION_P3P(adapter->ahw.revision_id) ? 16 : 8;
+
+	off8 = off & ~(stride-1);
 
 	spin_lock(&adapter->ahw.mem_lock);
 
 	writel(off8, (mem_crb + MIU_TEST_AGT_ADDR_LO));
 	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
-	writel(data & 0xffffffff, mem_crb + MIU_TEST_AGT_WRDATA_LO);
-	writel((data >> 32) & 0xffffffff, mem_crb + MIU_TEST_AGT_WRDATA_HI);
+
+	i = 0;
+	if (stride == 16) {
+		writel(TA_CTL_ENABLE, (mem_crb + TEST_AGT_CTRL));
+		writel((TA_CTL_START | TA_CTL_ENABLE),
+				(mem_crb + TEST_AGT_CTRL));
+
+		for (j = 0; j < MAX_CTL_CHECK; j++) {
+			temp = readl(mem_crb + TEST_AGT_CTRL);
+			if ((temp & TA_CTL_BUSY) == 0)
+				break;
+		}
+
+		if (j >= MAX_CTL_CHECK) {
+			ret = -EIO;
+			goto done;
+		}
+
+		i = (off & 0xf) ? 0 : 2;
+		writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i)),
+				mem_crb + MIU_TEST_AGT_WRDATA(i));
+		writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i+1)),
+				mem_crb + MIU_TEST_AGT_WRDATA(i+1));
+		i = (off & 0xf) ? 2 : 0;
+	}
+
+	writel(data & 0xffffffff,
+			mem_crb + MIU_TEST_AGT_WRDATA(i));
+	writel((data >> 32) & 0xffffffff,
+			mem_crb + MIU_TEST_AGT_WRDATA(i+1));
+
 	writel((TA_CTL_ENABLE | TA_CTL_WRITE), (mem_crb + TEST_AGT_CTRL));
 	writel((TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE),
 			(mem_crb + TEST_AGT_CTRL));
@@ -1623,6 +1655,7 @@ correct:
 	} else
 		ret = 0;
 
+done:
 	spin_unlock(&adapter->ahw.mem_lock);
 
 	return ret;
@@ -1634,7 +1667,7 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 {
 	int j, ret;
 	u32 temp, off8;
-	u64 val;
+	u64 val, stride;
 	void __iomem *mem_crb;
 
 	/* Only 64-bit aligned access */
@@ -1663,7 +1696,9 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 	return -EIO;
 
 correct:
-	off8 = off & MIU_TEST_AGT_ADDR_MASK;
+	stride = NX_IS_REVISION_P3P(adapter->ahw.revision_id) ? 16 : 8;
+
+	off8 = off & ~(stride-1);
 
 	spin_lock(&adapter->ahw.mem_lock);
 
@@ -1684,9 +1719,13 @@ correct:
 					"failed to read through agent\n");
 		ret = -EIO;
 	} else {
-		temp = readl(mem_crb + MIU_TEST_AGT_RDDATA_HI);
+		off8 = MIU_TEST_AGT_RDDATA_LO;
+		if ((stride == 16) && (off & 0xf))
+			off8 = MIU_TEST_AGT_RDDATA_UPPER_LO;
+
+		temp = readl(mem_crb + off8 + 4);
 		val = (u64)temp << 32;
-		val |= readl(mem_crb + MIU_TEST_AGT_RDDATA_LO);
+		val |= readl(mem_crb + off8);
 		*data = val;
 		ret = 0;
 	}
-- 
1.6.0.2

