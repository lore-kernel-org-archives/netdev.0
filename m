From: Narendra K <Narendra_K@dell.com>
Subject: [PATCH] Use firmware provided index to register a network interface
Date: Wed, 22 Sep 2010 13:31:38 -0500
Message-ID: <20100922183137.GA7607@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, charles_rose@dell.com,
	jordan_hargrave@dell.com, vijay_nijhawan@dell.com
To: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Here is another approach to address the issue of "eth0 does not always
map to the Integrated NIC Port 1 as denoted on server chassis label".
For more details please refer to the thread -
http://marc.info/?l=linux-netdev&m=128163454631618&w=3.

Patch makes use of the firmware provided index to derive ethN names.
That way the naming scheme adheres to the existing requirements of
ethN namespace and with IFNAMSIZ length.

Please find the patch here -

From: Narendra K <narendra_k@dell.com>
Subject: [PATCH] Use firmware provided index to register a network device

This patch uses the firmware provided index to derive the ethN name.
If the firmware provides an index for the corresponding pdev, the N
is derived from the index.

As an example, consider a PowerEdge R710 which has 4 BCM5709
Lan-On-Motherboard ports,1 Intel 82572EI port and 4 82575GB ports.
The system firmware communicates the order of the 4 Lan-On-Motherboard
ports by assigning indexes to each one of them. This is available to
the OS as the SMBIOS type 41 record(for onboard devices), in the field
'device type index'. It looks like below -

Handle 0x2900, DMI type 41, 11 bytes
Onboard Device
	Reference Designation: Embedded NIC 1
	Type: Ethernet
	Status: Enabled
	Type Instance: 1
	Bus Address: 0000:01:00.0

Handle 0x2901, DMI type 41, 11 bytes
Onboard Device
	Reference Designation: Embedded NIC 2
	Type: Ethernet
	Status: Enabled
	Type Instance: 2
	Bus Address: 0000:01:00.1

Handle 0x2902, DMI type 41, 11 bytes
Onboard Device
	Reference Designation: Embedded NIC 3
	Type: Ethernet
	Status: Enabled
	Type Instance: 3
	Bus Address: 0000:02:00.0

Handle 0x2903, DMI type 41, 11 bytes
Onboard Device
	Reference Designation: Embedded NIC 4
	Type: Ethernet
	Status: Enabled
	Type Instance: 4
	Bus Address: 0000:02:00.1

The OS can use this index to name the network interfaces as below.

Onboard devices -

Interface		Fwindex		Driver
Name
eth[fwindex - 1] =eth0	1		bnx2
eth[fwindex - 1] =eth1	2		bnx2
eth[fwindex - 1] =eth2	3		bnx2
eth[fwindex - 1] =eth3	4		bnx2

The add-in devices do not get any index and they will get names from
eth4 onwards.

Add-in interfaces -

eth4			e1000e
eth5			igb
eth6			igb
eth7			igb
eth8			igb

With this patch,

1. This patch adheres to the established ABI of ethN namespace with
IFNAMSIZ length and ensures that onboard network interfaces get
expected names at the first instance itself and avoids any renaming
later.

2. The 'eth0' of the OS always corresponds to the 'Gb1' as labeled on
the system chassis. There is determinism in the way Lan-On-Motherboard
ports get named.

3. The add-in devices will always be named from beyond what the
Lan-On-Motherboard names as show above. But there is no determinism
as to which add-in interface gets what ethN name.

Signed-off-by: Narendra K <narendra_k@dell.com>
---
 drivers/pci/pci-label.c   |    1 +
 drivers/pci/pci-sysfs.c   |    5 +++++
 include/linux/netdevice.h |    2 ++
 include/linux/pci.h       |    1 +
 net/core/dev.c            |   28 ++++++++++++++++++++++------
 5 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
index 90c0a72..8086268 100644
--- a/drivers/pci/pci-label.c
+++ b/drivers/pci/pci-label.c
@@ -55,6 +55,7 @@ find_smbios_instance_string(struct pci_dev *pdev, char *buf,
 							 "%s\n",
 							 dmi->name);
 			}
+			pdev->firmware_index = donboard->instance;
 			return strlen(dmi->name);
 		}
 	}
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index b5a7d9b..448ed9d 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -28,6 +28,7 @@
 #include "pci.h"
 
 static int sysfs_initialized;	/* = 0 */
+int pci_netdevs_with_fwindex;
 
 /* show configuration fields */
 #define pci_config_attr(field, format_string)				\
@@ -1167,6 +1168,10 @@ int __must_check pci_create_sysfs_dev_files (struct pci_dev *pdev)
 
 	pci_create_firmware_label_files(pdev);
 
+	if (pdev->firmware_index && (pdev->class >> 16) ==
+						PCI_BASE_CLASS_NETWORK)
+		pci_netdevs_with_fwindex++;
+
 	return 0;
 
 err_vga_file:
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 46c36ff..4398dcf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1080,6 +1080,8 @@ struct net_device {
 
 #define	NETDEV_ALIGN		32
 
+extern int pci_netdevs_with_fwindex;
+
 static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
diff --git a/include/linux/pci.h b/include/linux/pci.h
index b1d1795..90113bb 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -243,6 +243,7 @@ struct pci_dev {
 	unsigned short	subsystem_vendor;
 	unsigned short	subsystem_device;
 	unsigned int	class;		/* 3 bytes: (base,sub,prog-if) */
+	unsigned int	firmware_index; /* Firmware provided index */
 	u8		revision;	/* PCI revision, low byte of class word */
 	u8		hdr_type;	/* PCI header type (`multi' flag masked out) */
 	u8		pcie_cap;	/* PCI-E capability offset */
diff --git a/net/core/dev.c b/net/core/dev.c
index 1ae6543..b177ccc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -855,7 +855,7 @@ EXPORT_SYMBOL(dev_valid_name);
 
 /**
  *	__dev_alloc_name - allocate a name for a device
- *	@net: network namespace to allocate the device name in
+ *	@dev:  device
  *	@name: name format string
  *	@buf:  scratch buffer and result name string
  *
@@ -868,13 +868,15 @@ EXPORT_SYMBOL(dev_valid_name);
  *	Returns the number of the unit assigned or a negative errno code.
  */
 
-static int __dev_alloc_name(struct net *net, const char *name, char *buf)
+static int __dev_alloc_name(struct net_device *dev, const char *name, char *buf)
 {
 	int i = 0;
 	const char *p;
 	const int max_netdevices = 8*PAGE_SIZE;
 	unsigned long *inuse;
 	struct net_device *d;
+	struct net *net;
+	struct pci_dev *pdev;
 
 	p = strnchr(name, IFNAMSIZ-1, '%');
 	if (p) {
@@ -886,15 +888,31 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
 
+		pdev = to_pci_dev(dev->dev.parent);
+		if (pdev && pdev->firmware_index) {
+			snprintf(buf, IFNAMSIZ, name,
+				 pdev->firmware_index - 1);
+			return pdev->firmware_index - 1;
+		}
+
 		/* Use one page as a bit array of possible slots */
 		inuse = (unsigned long *) get_zeroed_page(GFP_ATOMIC);
 		if (!inuse)
 			return -ENOMEM;
 
+		/* Reserve 0 to < pci_netdevs_with_fwindex for integrated
+		 * ports with fwindex and allocate from pci_netdevs_with_fwindex
+		 * onwards for add-in devices
+		 */
+		for (i = 0; i < pci_netdevs_with_fwindex; i++)
+			set_bit(i, inuse);
+
+		net = dev_net(dev);
+
 		for_each_netdev(net, d) {
 			if (!sscanf(d->name, name, &i))
 				continue;
-			if (i < 0 || i >= max_netdevices)
+			if (i < pci_netdevs_with_fwindex || i >= max_netdevices)
 				continue;
 
 			/*  avoid cases where sscanf is not exact inverse of printf */
@@ -936,12 +954,10 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 int dev_alloc_name(struct net_device *dev, const char *name)
 {
 	char buf[IFNAMSIZ];
-	struct net *net;
 	int ret;
 
 	BUG_ON(!dev_net(dev));
-	net = dev_net(dev);
-	ret = __dev_alloc_name(net, name, buf);
+	ret = __dev_alloc_name(dev, name, buf);
 	if (ret >= 0)
 		strlcpy(dev->name, buf, IFNAMSIZ);
 	return ret;
-- 
1.7.0.1

With regards,
Narendra K
