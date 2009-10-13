From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 5/5] netxen: add sysfs entries for diag tools
Date: Tue, 13 Oct 2009 08:31:45 -0700
Message-ID: <1255447905-29805-6-git-send-email-dhananjay@netxen.com>
References: <1255447905-29805-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Narender Kumar <narender.kumar@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45727 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1759958AbZJMPcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 11:32:23 -0400
In-Reply-To: <1255447905-29805-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add sysfs entries to enable register and memory access
for diagnostic tools.

Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 +
 drivers/net/netxen/netxen_nic_main.c |  187 ++++++++++++++++++++++++++++++++++
 2 files changed, 188 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 1047609..1bdb8f4 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1089,6 +1089,7 @@ typedef struct {
 #define NETXEN_NIC_MSIX_ENABLED		0x04
 #define NETXEN_NIC_LRO_ENABLED		0x08
 #define NETXEN_NIC_BRIDGE_ENABLED       0X10
+#define NETXEN_NIC_DIAG_ENABLED		0x20
 #define NETXEN_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED))
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6ba1c72..5bc8520 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -73,6 +73,8 @@ static void netxen_nic_poll_controller(struct net_device *netdev);
 
 static void netxen_create_sysfs_entries(struct netxen_adapter *adapter);
 static void netxen_remove_sysfs_entries(struct netxen_adapter *adapter);
+static void netxen_create_diag_entries(struct netxen_adapter *adapter);
+static void netxen_remove_diag_entries(struct netxen_adapter *adapter);
 
 static int nx_decr_dev_ref_cnt(struct netxen_adapter *adapter);
 static int netxen_can_start_firmware(struct netxen_adapter *adapter);
@@ -1308,6 +1310,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
+	netxen_create_diag_entries(adapter);
+
 	return 0;
 
 err_out_disable_msi:
@@ -1360,6 +1364,8 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	netxen_teardown_intr(adapter);
 
+	netxen_remove_diag_entries(adapter);
+
 	netxen_cleanup_pci_map(adapter);
 
 	netxen_release_firmware(adapter);
@@ -2332,6 +2338,160 @@ static struct device_attribute dev_attr_bridged_mode = {
        .store = netxen_store_bridged_mode,
 };
 
+static ssize_t
+netxen_store_diag_mode(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct netxen_adapter *adapter = dev_get_drvdata(dev);
+	unsigned long new;
+
+	if (strict_strtoul(buf, 2, &new))
+		return -EINVAL;
+
+	if (!!new != !!(adapter->flags & NETXEN_NIC_DIAG_ENABLED))
+		adapter->flags ^= NETXEN_NIC_DIAG_ENABLED;
+
+	return len;
+}
+
+static ssize_t
+netxen_show_diag_mode(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct netxen_adapter *adapter = dev_get_drvdata(dev);
+
+	return sprintf(buf, "%d\n",
+			!!(adapter->flags & NETXEN_NIC_DIAG_ENABLED));
+}
+
+static struct device_attribute dev_attr_diag_mode = {
+	.attr = {.name = "diag_mode", .mode = (S_IRUGO | S_IWUSR)},
+	.show = netxen_show_diag_mode,
+	.store = netxen_store_diag_mode,
+};
+
+static int
+netxen_sysfs_validate_crb(struct netxen_adapter *adapter,
+		loff_t offset, size_t size)
+{
+	if (!(adapter->flags & NETXEN_NIC_DIAG_ENABLED))
+		return -EIO;
+
+	if ((size != 4) || (offset & 0x3))
+		return  -EINVAL;
+
+	if (offset < NETXEN_PCI_CRBSPACE)
+		return -EINVAL;
+
+	return 0;
+}
+
+static ssize_t
+netxen_sysfs_read_crb(struct kobject *kobj, struct bin_attribute *attr,
+		char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct netxen_adapter *adapter = dev_get_drvdata(dev);
+	u32 data;
+	int ret;
+
+	ret = netxen_sysfs_validate_crb(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	data = NXRD32(adapter, offset);
+	memcpy(buf, &data, size);
+	return size;
+}
+
+static ssize_t
+netxen_sysfs_write_crb(struct kobject *kobj, struct bin_attribute *attr,
+		char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct netxen_adapter *adapter = dev_get_drvdata(dev);
+	u32 data;
+	int ret;
+
+	ret = netxen_sysfs_validate_crb(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	memcpy(&data, buf, size);
+	NXWR32(adapter, offset, data);
+	return size;
+}
+
+static int
+netxen_sysfs_validate_mem(struct netxen_adapter *adapter,
+		loff_t offset, size_t size)
+{
+	if (!(adapter->flags & NETXEN_NIC_DIAG_ENABLED))
+		return -EIO;
+
+	if ((size != 8) || (offset & 0x7))
+		return  -EIO;
+
+	return 0;
+}
+
+static ssize_t
+netxen_sysfs_read_mem(struct kobject *kobj, struct bin_attribute *attr,
+		char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct netxen_adapter *adapter = dev_get_drvdata(dev);
+	u64 data;
+	int ret;
+
+	ret = netxen_sysfs_validate_mem(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	if (adapter->pci_mem_read(adapter, offset, &data))
+		return -EIO;
+
+	memcpy(buf, &data, size);
+
+	return size;
+}
+
+ssize_t netxen_sysfs_write_mem(struct kobject *kobj,
+		struct bin_attribute *attr, char *buf,
+		loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct netxen_adapter *adapter = dev_get_drvdata(dev);
+	u64 data;
+	int ret;
+
+	ret = netxen_sysfs_validate_mem(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	memcpy(&data, buf, size);
+
+	if (adapter->pci_mem_write(adapter, offset, data))
+		return -EIO;
+
+	return size;
+}
+
+
+static struct bin_attribute bin_attr_crb = {
+	.attr = {.name = "crb", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = netxen_sysfs_read_crb,
+	.write = netxen_sysfs_write_crb,
+};
+
+static struct bin_attribute bin_attr_mem = {
+	.attr = {.name = "mem", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = netxen_sysfs_read_mem,
+	.write = netxen_sysfs_write_mem,
+};
+
 static void
 netxen_create_sysfs_entries(struct netxen_adapter *adapter)
 {
@@ -2357,6 +2517,33 @@ netxen_remove_sysfs_entries(struct netxen_adapter *adapter)
 		device_remove_file(dev, &dev_attr_bridged_mode);
 }
 
+static void
+netxen_create_diag_entries(struct netxen_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct device *dev;
+
+	dev = &pdev->dev;
+	if (device_create_file(dev, &dev_attr_diag_mode))
+		dev_info(dev, "failed to create diag_mode sysfs entry\n");
+	if (device_create_bin_file(dev, &bin_attr_crb))
+		dev_info(dev, "failed to create crb sysfs entry\n");
+	if (device_create_bin_file(dev, &bin_attr_mem))
+		dev_info(dev, "failed to create mem sysfs entry\n");
+}
+
+
+static void
+netxen_remove_diag_entries(struct netxen_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct device *dev = &pdev->dev;
+
+	device_remove_file(dev, &dev_attr_diag_mode);
+	device_remove_bin_file(dev, &bin_attr_crb);
+	device_remove_bin_file(dev, &bin_attr_mem);
+}
+
 #ifdef CONFIG_INET
 
 #define is_netxen_netdev(dev) (dev->netdev_ops == &netxen_netdev_ops)
-- 
1.6.0.2

