From: <Narendra_K@Dell.com>
Subject: [PATCH V2] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 07:23:35 -0700
Message-ID: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <Matt_Domsch@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Vijay_Nijhawan@Dell.com>, <Charles_Rose@Dell.com>
To: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:61921 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787Ab0JGO2V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 10:28:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

V1 -> V2:

This patch addresses the scenario of buggy firmware/BIOS tables. The
patch introduces a command line parameter 'no_netfwindex', passing which
firmware provided index will not be used to derive 'eth' names. By
default, firmware index will be used and the parameter can be used to
work around buggy firmware/BIOS tables.

Please find the patch below.

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

Passing 'no_netfwindex' command line parameter would result in
firmware index not being used to derive the names as described above.

Signed-off-by: Narendra K <narendra_k@dell.com>
---
 Documentation/kernel-parameters.txt |    6 +++++
 drivers/pci/pci-label.c             |    1 +
 drivers/pci/pci-sysfs.c             |    5 ++++
 include/linux/netdevice.h           |    2 +
 include/linux/pci.h                 |    1 +
 net/core/dev.c                      |   42 ++++++++++++++++++++++++++++++-----
 6 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 3cdb4d8..73edbc0 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1529,6 +1529,12 @@ and is between 256 and 4096 characters. It is defined in the file
 			This usage is only documented in each driver source
 			file if at all.
 
+	no_netfwindex	[NET] Do not use firmware index to derive ethN names
+			Names for onboard network interfaces are derived from
+			the firmware provided index for these devices. Using
+			this parameter would result in firmware index not being
+			used to derive ethN names.
+
 	nf_conntrack.acct=
 			[NETFILTER] Enable connection tracking flow accounting
 			0 to disable accounting
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
index 1ae6543..f7982c4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -853,9 +853,18 @@ int dev_valid_name(const char *name)
 }
 EXPORT_SYMBOL(dev_valid_name);
 
+int netdev_use_fwindex = 1;
+
+static int __init netdev_use_fwindex_to_register(char *str)
+{
+	netdev_use_fwindex = 0;
+	return 0;
+}
+early_param("no_netfwindex", netdev_use_fwindex_to_register);
+
 /**
  *	__dev_alloc_name - allocate a name for a device
- *	@net: network namespace to allocate the device name in
+ *	@dev:  device
  *	@name: name format string
  *	@buf:  scratch buffer and result name string
  *
@@ -868,13 +877,15 @@ EXPORT_SYMBOL(dev_valid_name);
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
@@ -886,15 +897,36 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
 
+		if (likely(netdev_use_fwindex)) {
+			pdev = to_pci_dev(dev->dev.parent);
+			if (pdev && pdev->firmware_index) {
+				snprintf(buf, IFNAMSIZ, name,
+					 pdev->firmware_index - 1);
+				return pdev->firmware_index - 1;
+			}
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
+		if (likely(netdev_use_fwindex)) {
+			for (i = 0; i < pci_netdevs_with_fwindex; i++)
+				set_bit(i, inuse);
+		} else
+			pci_netdevs_with_fwindex = 0;
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
@@ -936,12 +968,10 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
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

-- 
With regards,
Narendra K
