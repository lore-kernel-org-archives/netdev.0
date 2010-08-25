From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Wed, 25 Aug 2010 17:03:23 -0500
Message-ID: <20100825220323.GA12671@auslistsprd01.us.dell.com>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com> <20100812141240.417949e2@s6510> <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com> <20100818144124.33a72453@nehalam> <20100819213314.GA26135@auslistsprd01.us.dell.com> <20100819145308.0fa08522@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com, linux-pci@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:4819 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0HYWDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 18:03:38 -0400
Content-Disposition: inline
In-Reply-To: <20100819145308.0fa08522@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 19, 2010 at 02:53:08PM -0700, Stephen Hemminger wrote:
> On Thu, 19 Aug 2010 16:33:14 -0500
> Matt Domsch <Matt_Domsch@Dell.com> wrote:
> 
> > On Wed, Aug 18, 2010 at 02:41:24PM -0700, Stephen Hemminger wrote:
> > > The netdev_alias_to_kernelname should only happen after normal lookup failed.
> > 
> > Stephen, can you enlighten me as to the "right" way to do interface
> > name lookups?  While I can still find examples of parsing
> > /proc/net/dev, or globbing /sys/class/net/*, I expect these aren't the
> > preferred method anymore.  Your own iproute2 suite uses RTM_GETLINK
> > netlink calls, though for the seeming simple case of "give me a list of all
> > interfaces", your path through there is far more capable (and
> > complex) than I would hope to need.
> 
> There is no magic right way. We have to support multiple interfaces.
> I am really concerned that all this alias stuff will turn into a
> disaster when there are 10,000 interfaces (Vlans).  The kernel has
> lots of tables and hashes to handle this but if the utilities
> are doing a dumb scan of all names it will not work.

We can remove the dumb scan of names if we expose the labels in a
second way.  For consideration of the approach:


>From 86b8ab8d24df722073d1118659c1eb269c5d9dd7 Mon Sep 17 00:00:00 2001
From: Matt Domsch <Matt_Domsch@dell.com>
Date: Wed, 25 Aug 2010 15:31:01 -0500
Subject: [PATCH] create /sys/firmware/pci for firmware-exposed label lookup

libnetdevname needs to be able to look up a (PCI) device by label.  It
currently does this by glob()ing /sys/class/net/*/device/label to find
all network interfaces that have a PCI device label exposed.  There can
be arbitrarily many network interfaces, making this a very expensive
operation.

This patch creates a new directory /sys/firmware/pci. This directory
contains symlinks, named for the PCI device labels that are exposed in
the 'label' file of each PCI device already.  Here is an example on a
Dell PowerEdge R610 server:

$ ls -l /sys/firmware/pci/
total 0
lrwxrwxrwx. 1 root root 0 2010-08-25 15:28 Embedded NIC 1 -> ../../devices/pci0000:00/0000:00:01.0/0000:01:00.0/
lrwxrwxrwx. 1 root root 0 2010-08-25 15:28 Embedded NIC 2 -> ../../devices/pci0000:00/0000:00:01.0/0000:01:00.1/
lrwxrwxrwx. 1 root root 0 2010-08-25 15:28 Embedded NIC 3 -> ../../devices/pci0000:00/0000:00:03.0/0000:02:00.0/
lrwxrwxrwx. 1 root root 0 2010-08-25 15:28 Embedded NIC 4 -> ../../devices/pci0000:00/0000:00:03.0/0000:02:00.1/
lrwxrwxrwx. 1 root root 0 2010-08-25 15:28 Embedded Video -> ../../devices/pci0000:00/0000:00:1e.0/0000:09:03.0/
lrwxrwxrwx. 1 root root 0 2010-08-25 15:28 Integrated SAS -> ../../devices/pci0000:00/0000:00:1c.0/0000:03:00.0/

$ cat /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/label
Embedded NIC 1

Using this, libnetdevname can remove it's glob() call, and instead can
look up the PCI device corresponding to a given label directly.  It
can then find the network interface name for that PCI device by
looking in the net/ directory of that device.

This makes no attempt to deal with SMBIOS that reports the same label
for two different PCI devices (if such were to exist).

Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>
---
 drivers/pci/pci-label.c |   66 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
index 111500e..a48eedb 100644
--- a/drivers/pci/pci-label.c
+++ b/drivers/pci/pci-label.c
@@ -19,6 +19,7 @@
 #include <linux/pci_ids.h>
 #include <linux/module.h>
 #include <linux/device.h>
+#include <linux/string.h>
 #include "pci.h"
 
 enum smbios_attr_enum {
@@ -131,13 +132,78 @@ pci_remove_smbiosname_file(struct pci_dev *pdev)
 	sysfs_remove_group(&pdev->dev.kobj, &smbios_attr_group);
 }
 
+static struct kobject *pci_label_kobj;
+
+static int pci_label_kobj_init(void)
+{
+	pci_label_kobj = kobject_create_and_add("pci", firmware_kobj);
+	if (pci_label_kobj == NULL)
+		return -ENOMEM;
+	return 0;
+}
+
+static int
+pci_create_smbios_label_symlink(struct pci_dev *pdev)
+{
+	char *label, *p;
+	mode_t mode;
+	int ret=-ENOMEM;
+
+	if (!pdev)
+		return -ENODEV;
+	if (pci_label_kobj == NULL)
+		if (pci_label_kobj_init())
+			return -ENOMEM;
+	label = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (label == NULL)
+		return -ENOMEM;
+	mode = find_smbios_instance_string(pdev, label, SMBIOS_ATTR_LABEL_SHOW);
+	if (mode == 0) {
+		ret = -ENODEV;
+		goto out_free;
+	}
+	p = strim(label);
+	ret = sysfs_create_link_nowarn(pci_label_kobj, &pdev->dev.kobj, p);
+out_free:
+	kfree(label);
+	return ret;
+}
+
+static void
+pci_delete_smbios_label_symlink(struct pci_dev *pdev)
+{
+	char *label, *p;
+	mode_t mode;
+
+	if (!pdev)
+		return;
+	if (pci_label_kobj == NULL)
+		return;
+	label = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (label == NULL)
+		return;
+	mode = find_smbios_instance_string(pdev, label, SMBIOS_ATTR_LABEL_SHOW);
+	if (mode == 0) {
+		goto out_free;
+	}
+	p = strim(label);
+	sysfs_delete_link(pci_label_kobj, &pdev->dev.kobj, p);
+
+out_free:
+	kfree(label);
+}
+
+
 void pci_create_firmware_label_files(struct pci_dev *pdev)
 {
 	if (!pci_create_smbiosname_file(pdev))
 		;
+	if (!pci_create_smbios_label_symlink(pdev))
+		;
 }
 
 void pci_remove_firmware_label_files(struct pci_dev *pdev)
 {
 	pci_remove_smbiosname_file(pdev);
+	pci_delete_smbios_label_symlink(pdev);
 }
-- 
1.7.1.1




-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
