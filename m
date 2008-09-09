From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/9] PCI: revise VPD access interface (rev3)
Date: Tue, 09 Sep 2008 11:20:42 -0700
Message-ID: <20080909182057.018705881@vyatta.com>
References: <20080909182040.246073057@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:37565 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754743AbYIIT3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 15:29:32 -0400
Content-Disposition: inline; filename=vpd-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change PCI VPD API which was only used by sysfs to something usable
in drivers. 
   * move iteration over multiple words to the low level
   * use conventional types for arguments
   * add exportable wrapper

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/pci/access.c    |  157 ++++++++++++++++++++++++++++++------------------
 drivers/pci/pci-sysfs.c |   38 ++---------
 drivers/pci/pci.h       |    6 -
 include/linux/pci.h     |    4 +
 4 files changed, 115 insertions(+), 90 deletions(-)

--- a/drivers/pci/access.c	2008-09-09 10:44:48.000000000 -0700
+++ b/drivers/pci/access.c	2008-09-09 11:00:09.000000000 -0700
@@ -66,6 +66,39 @@ EXPORT_SYMBOL(pci_bus_write_config_byte)
 EXPORT_SYMBOL(pci_bus_write_config_word);
 EXPORT_SYMBOL(pci_bus_write_config_dword);
 
+
+/**
+ * pci_read_vpd - Read one entry from Vital Product Data
+ * @dev:	pci device struct
+ * @pos:	offset in vpd space
+ * @count:	number of bytes to read
+ * @buf:	pointer to where to store result
+ *
+ */
+ssize_t pci_read_vpd(struct pci_dev *dev, loff_t pos, size_t count, void *buf)
+{
+	if (!dev->vpd || !dev->vpd->ops)
+		return -ENODEV;
+	return dev->vpd->ops->read(dev, pos, count, buf);
+}
+EXPORT_SYMBOL(pci_read_vpd);
+
+/**
+ * pci_write_vpd - Write entry to Vital Product Data
+ * @dev:	pci device struct
+ * @pos:	offset in vpd space
+ * @count:	number of bytes to read
+ * @val:	value to write
+ *
+ */
+ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void *buf)
+{
+	if (!dev->vpd || !dev->vpd->ops)
+		return -ENODEV;
+	return dev->vpd->ops->write(dev, pos, count, buf);
+}
+EXPORT_SYMBOL(pci_write_vpd);
+
 /*
  * The following routines are to prevent the user from accessing PCI config
  * space when it's unsafe to do so.  Some devices require this during BIST and
@@ -175,19 +208,17 @@ static int pci_vpd_pci22_wait(struct pci
 	}
 }
 
-static int pci_vpd_pci22_read(struct pci_dev *dev, int pos, int size,
-			      char *buf)
+static ssize_t pci_vpd_pci22_read(struct pci_dev *dev, loff_t pos, size_t count,
+				  void *arg)
 {
 	struct pci_vpd_pci22 *vpd =
 		container_of(dev->vpd, struct pci_vpd_pci22, base);
-	u32 val;
-	int ret = 0;
-	int begin, end, i;
+	int ret;
+	loff_t end = pos + count;
+	u8 *buf = arg;
 
-	if (pos < 0 || pos > vpd->base.len || size > vpd->base.len  - pos)
+	if (pos < 0 || pos > vpd->base.len || count > vpd->base.len - pos)
 		return -EINVAL;
-	if (size == 0)
-		return 0;
 
 	if (mutex_lock_killable(&vpd->lock))
 		return -EINTR;
@@ -195,73 +226,84 @@ static int pci_vpd_pci22_read(struct pci
 	ret = pci_vpd_pci22_wait(dev);
 	if (ret < 0)
 		goto out;
-	ret = pci_user_write_config_word(dev, vpd->cap + PCI_VPD_ADDR,
-					 pos & ~3);
-	if (ret < 0)
-		goto out;
 
-	vpd->busy = true;
-	vpd->flag = PCI_VPD_ADDR_F;
-	ret = pci_vpd_pci22_wait(dev);
-	if (ret < 0)
-		goto out;
-	ret = pci_user_read_config_dword(dev, vpd->cap + PCI_VPD_DATA,
-					 &val);
+	while (pos < end) {
+		u32 val;
+		unsigned int i, skip;
+
+		ret = pci_user_write_config_word(dev, vpd->cap + PCI_VPD_ADDR,
+						 pos & ~3);
+		if (ret < 0)
+			break;
+		vpd->busy = true;
+		vpd->flag = PCI_VPD_ADDR_F;
+		ret = pci_vpd_pci22_wait(dev);
+		if (ret < 0)
+			break;
+
+		ret = pci_user_read_config_dword(dev, vpd->cap + PCI_VPD_DATA, &val);
+		if (ret < 0)
+			break;
+
+		skip = pos & 3;
+		for (i = 0;  i < sizeof(u32); i++) {
+			if (i >= skip) {
+				*buf++ = val;
+				if (++pos == end)
+					break;
+			}
+			val >>= 8;
+		}
+	}
 out:
 	mutex_unlock(&vpd->lock);
-	if (ret < 0)
-		return ret;
-
-	/* Convert to bytes */
-	begin = pos & 3;
-	end = min(4, begin + size);
-	for (i = 0; i < end; ++i) {
-		if (i >= begin)
-			*buf++ = val;
-		val >>= 8;
-	}
-	return end - begin;
+	return ret ? ret : count;
 }
 
-static int pci_vpd_pci22_write(struct pci_dev *dev, int pos, int size,
-			       const char *buf)
+static ssize_t pci_vpd_pci22_write(struct pci_dev *dev, loff_t pos, size_t count,
+				   const void *arg)
 {
 	struct pci_vpd_pci22 *vpd =
 		container_of(dev->vpd, struct pci_vpd_pci22, base);
-	u32 val;
+	const u8 *buf = arg;
+	loff_t end = pos + count;
 	int ret = 0;
 
-	if (pos < 0 || pos > vpd->base.len || pos & 3 ||
-	    size > vpd->base.len - pos || size < 4)
+	if (pos > vpd->base.len || pos & 3)
 		return -EINVAL;
 
-	val = (u8) *buf++;
-	val |= ((u8) *buf++) << 8;
-	val |= ((u8) *buf++) << 16;
-	val |= ((u32)(u8) *buf++) << 24;
-
 	if (mutex_lock_killable(&vpd->lock))
 		return -EINTR;
+
 	ret = pci_vpd_pci22_wait(dev);
 	if (ret < 0)
 		goto out;
-	ret = pci_user_write_config_dword(dev, vpd->cap + PCI_VPD_DATA,
-					  val);
-	if (ret < 0)
-		goto out;
-	ret = pci_user_write_config_word(dev, vpd->cap + PCI_VPD_ADDR,
-					 pos | PCI_VPD_ADDR_F);
-	if (ret < 0)
-		goto out;
-	vpd->busy = true;
-	vpd->flag = 0;
-	ret = pci_vpd_pci22_wait(dev);
+
+	while (pos < end) {
+		u32 val;
+
+		val = *buf++;
+		val |= *buf++ << 8;
+		val |= *buf++ << 16;
+		val |= *buf++ << 24;
+
+		ret = pci_user_write_config_dword(dev, vpd->cap + PCI_VPD_DATA, val);
+		if (ret < 0)
+			break;
+		ret = pci_user_write_config_word(dev, vpd->cap + PCI_VPD_ADDR,
+						 pos | PCI_VPD_ADDR_F);
+		if (ret < 0)
+			break;
+
+		vpd->busy = true;
+		vpd->flag = 0;
+		ret = pci_vpd_pci22_wait(dev);
+
+		pos += sizeof(u32);
+	}
 out:
 	mutex_unlock(&vpd->lock);
-	if (ret < 0)
-		return ret;
-
-	return 4;
+	return ret ? ret : count;
 }
 
 static void pci_vpd_pci22_release(struct pci_dev *dev)
@@ -269,7 +311,7 @@ static void pci_vpd_pci22_release(struct
 	kfree(container_of(dev->vpd, struct pci_vpd_pci22, base));
 }
 
-static struct pci_vpd_ops pci_vpd_pci22_ops = {
+static const struct pci_vpd_ops pci_vpd_pci22_ops = {
 	.read = pci_vpd_pci22_read,
 	.write = pci_vpd_pci22_write,
 	.release = pci_vpd_pci22_release,
--- a/drivers/pci/pci.h	2008-09-09 10:08:39.000000000 -0700
+++ b/drivers/pci/pci.h	2008-09-09 10:54:34.000000000 -0700
@@ -44,14 +44,14 @@ extern int pci_user_write_config_word(st
 extern int pci_user_write_config_dword(struct pci_dev *dev, int where, u32 val);
 
 struct pci_vpd_ops {
-	int (*read)(struct pci_dev *dev, int pos, int size, char *buf);
-	int (*write)(struct pci_dev *dev, int pos, int size, const char *buf);
+	ssize_t (*read)(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
+	ssize_t (*write)(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
 	void (*release)(struct pci_dev *dev);
 };
 
 struct pci_vpd {
 	unsigned int len;
-	struct pci_vpd_ops *ops;
+	const struct pci_vpd_ops *ops;
 	struct bin_attribute *attr; /* descriptor for sysfs VPD entry */
 };
 
--- a/drivers/pci/pci-sysfs.c	2008-09-09 10:08:39.000000000 -0700
+++ b/drivers/pci/pci-sysfs.c	2008-09-09 10:45:51.000000000 -0700
@@ -360,55 +360,33 @@ pci_write_config(struct kobject *kobj, s
 }
 
 static ssize_t
-pci_read_vpd(struct kobject *kobj, struct bin_attribute *bin_attr,
-	     char *buf, loff_t off, size_t count)
+read_vpd_attr(struct kobject *kobj, struct bin_attribute *bin_attr,
+	      char *buf, loff_t off, size_t count)
 {
 	struct pci_dev *dev =
 		to_pci_dev(container_of(kobj, struct device, kobj));
-	int end;
-	int ret;
 
 	if (off > bin_attr->size)
 		count = 0;
 	else if (count > bin_attr->size - off)
 		count = bin_attr->size - off;
-	end = off + count;
 
-	while (off < end) {
-		ret = dev->vpd->ops->read(dev, off, end - off, buf);
-		if (ret < 0)
-			return ret;
-		buf += ret;
-		off += ret;
-	}
-
-	return count;
+	return pci_read_vpd(dev, off, count, buf);
 }
 
 static ssize_t
-pci_write_vpd(struct kobject *kobj, struct bin_attribute *bin_attr,
-	      char *buf, loff_t off, size_t count)
+write_vpd_attr(struct kobject *kobj, struct bin_attribute *bin_attr,
+	       char *buf, loff_t off, size_t count)
 {
 	struct pci_dev *dev =
 		to_pci_dev(container_of(kobj, struct device, kobj));
-	int end;
-	int ret;
 
 	if (off > bin_attr->size)
 		count = 0;
 	else if (count > bin_attr->size - off)
 		count = bin_attr->size - off;
-	end = off + count;
-
-	while (off < end) {
-		ret = dev->vpd->ops->write(dev, off, end - off, buf);
-		if (ret < 0)
-			return ret;
-		buf += ret;
-		off += ret;
-	}
 
-	return count;
+	return pci_write_vpd(dev, off, count, buf);
 }
 
 #ifdef HAVE_PCI_LEGACY
@@ -739,8 +717,8 @@ int __must_check pci_create_sysfs_dev_fi
 			attr->size = pdev->vpd->len;
 			attr->attr.name = "vpd";
 			attr->attr.mode = S_IRUSR | S_IWUSR;
-			attr->read = pci_read_vpd;
-			attr->write = pci_write_vpd;
+			attr->read = read_vpd_attr;
+			attr->write = write_vpd_attr;
 			retval = sysfs_create_bin_file(&pdev->dev.kobj, attr);
 			if (retval)
 				goto err_vpd;
--- a/include/linux/pci.h	2008-09-09 10:08:39.000000000 -0700
+++ b/include/linux/pci.h	2008-09-09 11:01:07.000000000 -0700
@@ -650,6 +650,10 @@ int pci_back_from_sleep(struct pci_dev *
 /* Functions for PCI Hotplug drivers to use */
 int pci_bus_find_capability(struct pci_bus *bus, unsigned int devfn, int cap);
 
+/* Vital product data routines */
+ssize_t pci_read_vpd(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
+ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
+
 /* Helper functions for low-level code (drivers/pci/setup-[bus,res].c) */
 void pci_bus_assign_resources(struct pci_bus *bus);
 void pci_bus_size_bridges(struct pci_bus *bus);

-- 

