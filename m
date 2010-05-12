From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/4] netxen: handle queue manager access
Date: Wed, 12 May 2010 02:53:05 -0700
Message-ID: <1273657985-13405-5-git-send-email-amit.salecha@qlogic.com>
References: <1273657985-13405-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22228 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753447Ab0ELJxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 05:53:08 -0400
In-Reply-To: <1273657985-13405-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the access by tools for hardware queue engine and handle it
separately than other block registers, otherwise incorrect data
is returned.

Support for only NX3031 based cards.

Acked-by: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h      |    5 ++++
 drivers/net/netxen/netxen_nic_hw.c   |   25 +++++++++++++++++--
 drivers/net/netxen/netxen_nic_main.c |   44 +++++++++++++++++++++++++++------
 3 files changed, 63 insertions(+), 11 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 174ac8e..ffa1b9c 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -95,6 +95,9 @@
 #define ADDR_IN_WINDOW1(off)	\
 	((off > NETXEN_CRB_PCIX_HOST2) && (off < NETXEN_CRB_MAX)) ? 1 : 0
 
+#define ADDR_IN_RANGE(addr, low, high)	\
+	(((addr) < (high)) && ((addr) >= (low)))
+
 /*
  * normalize a 64MB crb address to 32MB PCI window
  * To use NETXEN_CRB_NORMALIZE, window _must_ be set to 1
@@ -1352,6 +1355,8 @@ int netxen_config_rss(struct netxen_adapter *adapter, int enable);
 int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int cmd);
 int netxen_linkevent_request(struct netxen_adapter *adapter, int enable);
 void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup);
+void netxen_pci_camqm_read_2M(struct netxen_adapter *, u64, u64 *);
+void netxen_pci_camqm_write_2M(struct netxen_adapter *, u64, u64);
 
 int nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index be63988..5c496f8 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -62,9 +62,6 @@ static inline void writeq(u64 val, void __iomem *addr)
 }
 #endif
 
-#define ADDR_IN_RANGE(addr, low, high)	\
-	(((addr) < (high)) && ((addr) >= (low)))
-
 #define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
 	((adapter)->ahw.pci_base0 + (off))
 #define PCI_OFFSET_SECOND_RANGE(adapter, off)   \
@@ -1448,6 +1445,28 @@ unlock:
 	return ret;
 }
 
+void
+netxen_pci_camqm_read_2M(struct netxen_adapter *adapter, u64 off, u64 *data)
+{
+	void __iomem *addr = adapter->ahw.pci_base0 +
+		NETXEN_PCI_CAMQM_2M_BASE + (off - NETXEN_PCI_CAMQM);
+
+	spin_lock(&adapter->ahw.mem_lock);
+	*data = readq(addr);
+	spin_unlock(&adapter->ahw.mem_lock);
+}
+
+void
+netxen_pci_camqm_write_2M(struct netxen_adapter *adapter, u64 off, u64 data)
+{
+	void __iomem *addr = adapter->ahw.pci_base0 +
+		NETXEN_PCI_CAMQM_2M_BASE + (off - NETXEN_PCI_CAMQM);
+
+	spin_lock(&adapter->ahw.mem_lock);
+	writeq(data, addr);
+	spin_unlock(&adapter->ahw.mem_lock);
+}
+
 #define MAX_CTL_CHECK   1000
 
 static int
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b665b42..692e672 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2537,14 +2537,24 @@ static int
 netxen_sysfs_validate_crb(struct netxen_adapter *adapter,
 		loff_t offset, size_t size)
 {
+	size_t crb_size = 4;
+
 	if (!(adapter->flags & NETXEN_NIC_DIAG_ENABLED))
 		return -EIO;
 
-	if ((size != 4) || (offset & 0x3))
-		return  -EINVAL;
+	if (offset < NETXEN_PCI_CRBSPACE) {
+		if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+			return -EINVAL;
 
-	if (offset < NETXEN_PCI_CRBSPACE)
-		return -EINVAL;
+		if (ADDR_IN_RANGE(offset, NETXEN_PCI_CAMQM,
+						NETXEN_PCI_CAMQM_2M_END))
+			crb_size = 8;
+		else
+			return -EINVAL;
+	}
+
+	if ((size != crb_size) || (offset & (crb_size-1)))
+		return  -EINVAL;
 
 	return 0;
 }
@@ -2556,14 +2566,23 @@ netxen_sysfs_read_crb(struct kobject *kobj, struct bin_attribute *attr,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct netxen_adapter *adapter = dev_get_drvdata(dev);
 	u32 data;
+	u64 qmdata;
 	int ret;
 
 	ret = netxen_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
 		return ret;
 
-	data = NXRD32(adapter, offset);
-	memcpy(buf, &data, size);
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id) &&
+		ADDR_IN_RANGE(offset, NETXEN_PCI_CAMQM,
+					NETXEN_PCI_CAMQM_2M_END)) {
+		netxen_pci_camqm_read_2M(adapter, offset, &qmdata);
+		memcpy(buf, &qmdata, size);
+	} else {
+		data = NXRD32(adapter, offset);
+		memcpy(buf, &data, size);
+	}
+
 	return size;
 }
 
@@ -2574,14 +2593,23 @@ netxen_sysfs_write_crb(struct kobject *kobj, struct bin_attribute *attr,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct netxen_adapter *adapter = dev_get_drvdata(dev);
 	u32 data;
+	u64 qmdata;
 	int ret;
 
 	ret = netxen_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
 		return ret;
 
-	memcpy(&data, buf, size);
-	NXWR32(adapter, offset, data);
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id) &&
+		ADDR_IN_RANGE(offset, NETXEN_PCI_CAMQM,
+					NETXEN_PCI_CAMQM_2M_END)) {
+		memcpy(&qmdata, buf, size);
+		netxen_pci_camqm_write_2M(adapter, offset, qmdata);
+	} else {
+		memcpy(&data, buf, size);
+		NXWR32(adapter, offset, data);
+	}
+
 	return size;
 }
 
-- 
1.6.0.2

