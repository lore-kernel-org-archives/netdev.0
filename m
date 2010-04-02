From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv1 NEXT 2/9] qlcnic: handle queue manager access
Date: Thu,  1 Apr 2010 22:01:29 -0700
Message-ID: <1270184496-18985-3-git-send-email-amit.salecha@qlogic.com>
References: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5770 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753652Ab0DBFBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 01:01:38 -0400
In-Reply-To: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>

Check the access by tools for hardware queue engine and handle it
separately than other block registers, otherwise incorrect data
is returned.

Signed-off-by: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    5 +++++
 drivers/net/qlcnic/qlcnic_hdr.h  |    3 ++-
 drivers/net/qlcnic/qlcnic_hw.c   |   25 ++++++++++++++++++++++---
 drivers/net/qlcnic/qlcnic_main.c |   35 +++++++++++++++++++++++++++--------
 4 files changed, 56 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 0da94b2..8a3446d 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -994,6 +994,11 @@ u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off);
 int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *, ulong off, u32 data);
 int qlcnic_pci_mem_write_2M(struct qlcnic_adapter *, u64 off, u64 data);
 int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *, u64 off, u64 *data);
+void qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *, u64, u64 *);
+void qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *, u64, u64);
+
+#define ADDR_IN_RANGE(addr, low, high)	\
+	(((addr) < (high)) && ((addr) >= (low)))
 
 #define QLCRD32(adapter, off) \
 	(qlcnic_hw_read_wx_2M(adapter, off))
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 0469f84..25465a9 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -435,9 +435,10 @@ enum {
 #define QLCNIC_PCI_MS_2M	(0x80000)
 #define QLCNIC_PCI_OCM0_2M	(0x000c0000UL)
 #define QLCNIC_PCI_CRBSPACE	(0x06000000UL)
+#define QLCNIC_PCI_CAMQM	(0x04800000UL)
+#define QLCNIC_PCI_CAMQM_END	(0x04800800UL)
 #define QLCNIC_PCI_2MB_SIZE	(0x00200000UL)
 #define QLCNIC_PCI_CAMQM_2M_BASE	(0x000ff800UL)
-#define QLCNIC_PCI_CAMQM_2M_END 	(0x04800800UL)
 
 #define QLCNIC_CRB_CAM	QLCNIC_PCI_CRB_WINDOW(QLCNIC_HW_PX_MAP_CRB_CAM)
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index da00e16..b977874 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -53,9 +53,6 @@ static inline void writeq(u64 val, void __iomem *addr)
 }
 #endif
 
-#define ADDR_IN_RANGE(addr, low, high)	\
-	(((addr) < (high)) && ((addr) >= (low)))
-
 #define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
 	((adapter)->ahw.pci_base0 + (off))
 
@@ -936,6 +933,28 @@ unlock:
 	return ret;
 }
 
+void
+qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
+{
+	void __iomem *addr = adapter->ahw.pci_base0 +
+		QLCNIC_PCI_CAMQM_2M_BASE + (off - QLCNIC_PCI_CAMQM);
+
+	mutex_lock(&adapter->ahw.mem_lock);
+	*data = readq(addr);
+	mutex_unlock(&adapter->ahw.mem_lock);
+}
+
+void
+qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *adapter, u64 off, u64 data)
+{
+	void __iomem *addr = adapter->ahw.pci_base0 +
+		QLCNIC_PCI_CAMQM_2M_BASE + (off - QLCNIC_PCI_CAMQM);
+
+	mutex_lock(&adapter->ahw.mem_lock);
+	writeq(data, addr);
+	mutex_unlock(&adapter->ahw.mem_lock);
+}
+
 #define MAX_CTL_CHECK   1000
 
 int
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index fc72156..a234622 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2386,14 +2386,21 @@ static int
 qlcnic_sysfs_validate_crb(struct qlcnic_adapter *adapter,
 		loff_t offset, size_t size)
 {
+	size_t crb_size = 4;
+
 	if (!(adapter->flags & QLCNIC_DIAG_ENABLED))
 		return -EIO;
 
-	if ((size != 4) || (offset & 0x3))
-		return  -EINVAL;
+	if (offset < QLCNIC_PCI_CRBSPACE) {
+		if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM,
+					QLCNIC_PCI_CAMQM_END))
+			crb_size = 8;
+		else
+			return -EINVAL;
+	}
 
-	if (offset < QLCNIC_PCI_CRBSPACE)
-		return -EINVAL;
+	if ((size != crb_size) || (offset & (crb_size-1)))
+		return  -EINVAL;
 
 	return 0;
 }
@@ -2405,14 +2412,20 @@ qlcnic_sysfs_read_crb(struct kobject *kobj, struct bin_attribute *attr,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	u32 data;
+	u64 qmdata;
 	int ret;
 
 	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
 		return ret;
 
-	data = QLCRD32(adapter, offset);
-	memcpy(buf, &data, size);
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
+		memcpy(buf, &qmdata, size);
+	} else {
+		data = QLCRD32(adapter, offset);
+		memcpy(buf, &data, size);
+	}
 	return size;
 }
 
@@ -2423,14 +2436,20 @@ qlcnic_sysfs_write_crb(struct kobject *kobj, struct bin_attribute *attr,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	u32 data;
+	u64 qmdata;
 	int ret;
 
 	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
 		return ret;
 
-	memcpy(&data, buf, size);
-	QLCWR32(adapter, offset, data);
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		memcpy(&qmdata, buf, size);
+		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
+	} else {
+		memcpy(&data, buf, size);
+		QLCWR32(adapter, offset, data);
+	}
 	return size;
 }
 
-- 
1.6.0.2

