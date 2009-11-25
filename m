From: Simon Horman <horms@verge.net.au>
Subject: [rfc 3/3 v2] [E1000-devel] [rfc 4/4] igb: expose 82576 bandiwidth allocation
Date: Wed, 25 Nov 2009 17:32:16 +1100
Message-ID: <20091125063531.684341036@vergenet.net>
References: <20091125063213.203372240@vergenet.net>
Cc: Arnd Bergmann <arndbergmann@googlemail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33726 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbZKYGjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 01:39:32 -0500
Content-Disposition: inline; filename=igb-expose-82576-bandwidth-allocation-2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 82576 has support for bandwidth allocation to VFs.

Contrary to the documentation in the 82576 datasheet v2.41 this
appears to work as follows:

* The ratio supplied is always proportional to 1Gbit/s,
  regardless of if the link speed.
* The ratio supplied is an upper-bound on bandwidth available
  to the VF, not a minimun guarantee

This patch exposes bandwidth control to userspace through a simple
per-device (PF) sysfs file, bandwidth_allocation.

* The file contains a whitespace delimited list of values, one per VF.
* The first value corresponds to the first VF and so on.
* Valid values are integers from 0 to 1000
* A value of 0 indicates that bandwidth_allocation is disabled.
* Other values indicate the allocated bandwidth, in 1/1000ths of a gigabit/s

e.g. The following for a PF with 4 VFs allocates ~20Mbits/ to VF 1,
     ~100Mbit/s to VF 2, and leave the other 2 VFs with no allocation.

     echo "20 100 0 0" > /sys/class/net/eth3/device/bandwidth_allocation

This interface is intended to allow testing of the hardware feature.
There are ongoing discussions about how to expose this feature
to user-space in a more generic way.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
Thu, 05 Nov 2009 11:58:51 +1100
* Initial post

Wed, 25 Nov 2009 16:58:23 +1100
* Refresh for changes to proceeding patches in series
* Up-port to latest net-next

Index: net-next-2.6/drivers/net/igb/igb_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-11-25 17:05:44.000000000 +1100
+++ net-next-2.6/drivers/net/igb/igb_main.c	2009-11-25 17:06:51.000000000 +1100
@@ -47,6 +47,9 @@
 #ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
+#ifdef CONFIG_PCI_IOV
+#include <linux/ctype.h>
+#endif
 #include "igb.h"
 
 #define DRV_VERSION "2.1.0-k2"
@@ -157,6 +160,15 @@ static unsigned int max_vfs = 0;
 module_param(max_vfs, uint, 0);
 MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate "
                  "per physical function");
+
+static ssize_t igb_set_bandwidth_allocation(struct device *,
+					    struct device_attribute *,
+					    const char *, size_t);
+static ssize_t igb_show_bandwidth_allocation(struct device *,
+					     struct device_attribute *,
+					     char *);
+DEVICE_ATTR(bandwidth_allocation, S_IRUGO | S_IWUSR,
+	    igb_show_bandwidth_allocation, igb_set_bandwidth_allocation);
 #endif /* CONFIG_PCI_IOV */
 
 static pci_ers_result_t igb_io_error_detected(struct pci_dev *,
@@ -1771,6 +1783,19 @@ static void __devinit igb_init_vf(struct
 	if (pci_enable_sriov(pdev, adapter->vfs_allocated_count))
 		goto err_free;
 
+	if (device_create_file(&pdev->dev, &dev_attr_bandwidth_allocation))
+		goto err_sriov;
+
+	adapter->bandwidth_allocation = kcalloc(adapter->vfs_allocated_count,
+						sizeof(unsigned int),
+						GFP_KERNEL);
+	if (!adapter->bandwidth_allocation)
+		goto err_file;
+	memset(adapter->bandwidth_allocation,
+	       adapter->vfs_allocated_count * sizeof(unsigned int), 0);
+
+	spin_lock_init(&adapter->bandwidth_allocation_lock);
+
 	dev_info(&pdev->dev, "%d vfs allocated\n",
 		 adapter->vfs_allocated_count);
 	for (i = 0; i < adapter->vfs_allocated_count; i++) {
@@ -1779,6 +1804,10 @@ static void __devinit igb_init_vf(struct
 	}
 
 	return;
+err_file:
+	device_remove_file(&pdev->dev, &dev_attr_bandwidth_allocation);
+err_sriov:
+	pci_disable_sriov(pdev);
 err_free:
 	kfree(adapter->vf_data);
 err_zero:
@@ -1903,6 +1932,7 @@ static void igb_init_hw_timer(struct igb
 static void igb_cleanup_vf(struct igb_adapter * adapter)
 {
 #ifdef CONFIG_PCI_IOV
+	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (!adapter->vf_data)
@@ -1919,6 +1949,9 @@ static void igb_cleanup_vf(struct igb_ad
 	wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
 	msleep(100);
 	dev_info(&adapter->pdev->dev, "IOV Disabled\n");
+
+	device_remove_file(&pdev->dev, &dev_attr_bandwidth_allocation);
+	kfree(adapter->bandwidth_allocation);
 #endif
 }
 
@@ -2227,6 +2260,123 @@ void igb_configure_tx_ring(struct igb_ad
 	wr32(E1000_TXDCTL(reg_idx), txdctl);
 }
 
+#ifdef CONFIG_PCI_IOV
+static void igb_disable_bandwidth_allocation_vf(struct e1000_hw *hw, int vf)
+{
+	wr32(E1000_VMBASEL, vf);
+	wr32(E1000_VMBAC, 0);
+}
+
+static void igb_disable_bandwidth_allocation(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
+
+	for (i = 0; i < adapter->vfs_allocated_count; i++)
+		igb_disable_bandwidth_allocation_vf(hw, i);
+}
+
+static void igb_enable_bandwidth_allocation_vf(struct e1000_hw *hw, int vf,
+					       unsigned int allocation)
+{
+	u32 rq;
+
+	/* Allocation is expressed as 1000ths of link speed [+]
+	 *
+	 * rq is calcualted as 1 / (allocation / 1000) = 1000 / allocation
+	 *
+	 * E1000_VMBAC_RF_INT_SHIFT and E1000_VMBAC_RF_MASK are used
+	 * to marshal the result into the desired format: 23 bits of
+	 * which 14 are to the right of the decimal point.
+	 *
+	 * [+] According to the the 82576 v2.41 datasheet rq should
+	 *     be a ratio of the link speed, however, empirically
+	 *     it appears to always be a ration of to 1Gbit/s,
+	 *     even when the link is 100Mbit/s.
+	 */
+	rq = ((1000 << E1000_VMBAC_RF_INT_SHIFT) / allocation) &
+	     E1000_VMBAC_RF_MASK;
+
+	wr32(E1000_VMBASEL, vf);
+	wr32(E1000_VMBAC, rq|E1000_VMBAC_RC_ENA);
+}
+
+static void igb_enable_bandwidth_allocation(struct igb_adapter *adapter)
+{
+	u32 i, reg;
+	struct e1000_hw *hw = &adapter->hw;
+
+	/* Only enable bandwidth_allocation if it has been set
+	 * and the link speed is 100Mbit/s or 1Gbit/s */
+	if (!adapter->bandwidth_allocation ||
+	    (adapter->link_speed != SPEED_100 &&
+	     adapter->link_speed != SPEED_1000)) {
+		igb_disable_bandwidth_allocation(adapter);
+		return;
+	}
+
+	for (i = 0; i < adapter->vfs_allocated_count; i++) {
+		wr32(E1000_VMBASEL, i);
+		if (adapter->bandwidth_allocation[i])
+			igb_enable_bandwidth_allocation_vf(hw, i,
+					adapter->bandwidth_allocation[i]);
+		else
+			igb_disable_bandwidth_allocation_vf(hw, i);
+
+		/* XXX:
+		 *
+		 * The 82576 datasheet, section 4.5.11.1.5.1 "Configuring Tx
+		 * Bandwidth to VMs" states that the desired setting is:
+		 * VMBAMMW.MMW_SIZE = 16 * MSS
+		 *
+		 * But isn't  MSS a property of skbs that are using tso
+		 * rather than adapters?
+		 *
+		 * If so, should we use the maximum value here? */
+		/* XXX: Should this go inside or outside the for loop ? */
+		reg = 64 * 16;
+		wr32(E1000_VMBAMMW, reg);
+	}
+}
+#endif
+
+static void igb_check_bandwidth_allocation(struct igb_adapter *adapter)
+{
+#ifdef CONFIG_PCI_IOV
+	u32 vmbacs;
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (!adapter->vf_data)
+		return;
+
+	/* The 82576 datasheet, section 4.5.11.1.5.2 "Link Speed Change
+	 * Procedure" describes the sequence below. However the
+	 * SPEED_CHG never seems to be set.
+	 */
+	vmbacs = rd32(E1000_VMBACS);
+	if (vmbacs & E1000_VMBACS_SPEED_CHG) {
+		/* XXX: Never seem to get here */
+		int err = 0;
+
+		if (vmbacs & E1000_VMBACS_VMBA_SET) {
+			igb_disable_bandwidth_allocation(adapter);
+			err = 1;
+		}
+
+		vmbacs &= ~E1000_VMBACS_SPEED_CHG;
+		wr32(E1000_VMBACS, vmbacs);
+
+		if (err)
+			return;
+	}
+
+	spin_lock(&adapter->bandwidth_allocation_lock);
+	igb_enable_bandwidth_allocation(adapter);
+	spin_unlock(&adapter->bandwidth_allocation_lock);
+#endif
+	return;
+}
+
 /**
  * igb_configure_tx - Configure transmit Unit after Reset
  * @adapter: board private structure
@@ -3111,6 +3261,8 @@ static void igb_watchdog_task(struct wor
 				break;
 			}
 
+			igb_check_bandwidth_allocation(adapter);
+
 			netif_carrier_on(netdev);
 
 			igb_ping_all_vfs(adapter);
@@ -6010,4 +6162,101 @@ static void igb_vmm_control(struct igb_a
 	}
 }
 
+#ifdef CONFIG_PCI_IOV
+static ssize_t igb_show_bandwidth_allocation(struct device *dev,
+					     struct device_attribute *attr,
+					     char *buf)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	int i;
+
+	if (!adapter->vf_data)
+		return -ENOENT;
+
+	*buf = '\0';
+	for (i = 0; i < adapter->vfs_allocated_count; i++) {
+		if (i > 0)
+			strcat(buf, " ");
+		sprintf(buf + strlen(buf), "%i",
+			adapter->bandwidth_allocation[i]);
+	}
+	strcat(buf, "\n");
+
+	return strlen(buf);
+}
+
+static unsigned long igb_strtoul(const char *cp, char **endp, unsigned int base)
+{
+	const char *orig = cp;
+	unsigned long x;
+
+	while (isspace(*cp))
+		cp++;
+
+	x = simple_strtoul(cp, endp, base);
+	if (cp == *endp)
+		*endp = (char *)orig;
+
+	return x;
+}
+
+static ssize_t igb_set_bandwidth_allocation(struct device *dev,
+					    struct device_attribute *attr,
+					    const char *buf, size_t count)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	int i;
+	size_t len;
+	ssize_t status = -ENOENT;
+	unsigned int *new, total;
+	unsigned long x;
+	const char *p;
+	char *next_p;
+
+	if (!adapter->vf_data)
+		return -ENOENT;
+
+	len = adapter->vfs_allocated_count * sizeof(unsigned int);
+
+	new = kmalloc(len, GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	p = buf;
+	total = 0;
+	for (i = 0; i < adapter->vfs_allocated_count; i++) {
+		x = igb_strtoul(p, &next_p, 10);
+		if (p == next_p) {
+			dev_err(dev, "not enough values\n");
+			goto err;
+		}
+		if (x > 1000) {
+			dev_err(dev, "value is too large\n");
+			goto err;
+		}
+		new[i] = x;
+		total += x;
+		p = next_p;
+	}
+
+	/* Check for trailing rubbish */
+	igb_strtoul(p, &next_p, 10);
+	if (p != next_p) {
+		dev_err(dev, "trailing rubbish\n");
+		goto err;
+	}
+
+	spin_lock(&adapter->bandwidth_allocation_lock);
+	memcpy(adapter->bandwidth_allocation, new, len);
+	igb_enable_bandwidth_allocation(adapter);
+	spin_unlock(&adapter->bandwidth_allocation_lock);
+
+	status = count;
+err:
+	kfree(new);
+	return status;
+}
+#endif /* CONFIG_PCI_IOV */
 /* igb_main.c */
Index: net-next-2.6/drivers/net/igb/e1000_regs.h
===================================================================
--- net-next-2.6.orig/drivers/net/igb/e1000_regs.h	2009-11-25 16:59:19.000000000 +1100
+++ net-next-2.6/drivers/net/igb/e1000_regs.h	2009-11-25 17:06:51.000000000 +1100
@@ -311,6 +311,16 @@
 #define E1000_VLVF(_n)         (0x05D00 + (4 * (_n))) /* VLAN Virtual Machine
                                                        * Filter - RW */
 
+/* Tx Bandwidth Allocation to VM Registers */
+#define E1000_VMBACS	0x03600 /* VM Bandwidth Allocation
+				 * Control & Status - RW */
+#define E1000_VMBAMMW	0x03670 /* VM Bandwidth Allocation
+				 * Max Memory Window - RW */
+#define E1000_VMBASEL	0x03604 /* VM Bandwidth Allocation
+				 * Select - RW */
+#define E1000_VMBAC	0x03608 /* VM Bandwidth Allocation
+				 * Config - RW */
+
 #define wr32(reg, value) (writel(value, hw->hw_addr + reg))
 #define rd32(reg) (readl(hw->hw_addr + reg))
 #define wrfl() ((void)rd32(E1000_STATUS))
Index: net-next-2.6/drivers/net/igb/e1000_defines.h
===================================================================
--- net-next-2.6.orig/drivers/net/igb/e1000_defines.h	2009-11-25 16:59:18.000000000 +1100
+++ net-next-2.6/drivers/net/igb/e1000_defines.h	2009-11-25 17:06:51.000000000 +1100
@@ -724,4 +724,13 @@
 #define E1000_PCIEMISC_LX_DECISION      0x00000080 /* Lx power decision based
                                                       on DMA coal */
 
+/* VM Bandwidth Allocation Control & Status */
+#define E1000_VMBACS_VMBA_SET		0x00001000
+#define E1000_VMBACS_SPEED_CHG		0x80000000
+
+/* VM Bandwidth Allocation Config */
+#define E1000_VMBAC_RF_INT_SHIFT	14
+#define E1000_VMBAC_RF_MASK		((1<<23)-1)	/* RF_DEC and RF_INT */
+#define E1000_VMBAC_RC_ENA		0x80000000
+
 #endif
Index: net-next-2.6/drivers/net/igb/igb.h
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb.h	2009-11-25 16:59:19.000000000 +1100
+++ net-next-2.6/drivers/net/igb/igb.h	2009-11-25 17:06:51.000000000 +1100
@@ -312,6 +312,10 @@ struct igb_adapter {
 	unsigned int vfs_allocated_count;
 	struct vf_data_storage *vf_data;
 	u32 rss_queues;
+#ifdef CONFIG_PCI_IOV
+	unsigned int *bandwidth_allocation;
+	spinlock_t bandwidth_allocation_lock;
+#endif
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)

