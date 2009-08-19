From: <Jordan_Hargrave@Dell.com>
Subject: PATCH: Network Device Naming mechanism and policy
Date: Wed, 19 Aug 2009 13:56:30 -0500
Message-ID: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE011CD964@ausx3mpc102.aus.amer.dell.com>
References: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE011CD92D@ausx3mpc102.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:55533 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbZHSTAs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 15:00:48 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is from an old discussion several months ago:
http://lkml.org/lkml/2009/3/24/357
http://lkml.org/lkml/2009/3/24/380

Basically the issue is that between a race in udev and PCI scan order the ethX IDs may not
be consistent between reboots.  The idea is to use a mechanism similar to how disks now can
be accessed by their LABEL/PATH/UUID instead of raw /dev/sdX ids.

example udev config:
SUBSYSTEM=="net", SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
SUBSYSTEM=="net", PROGRAM="/sbin/biosdevname -i %k --policy=all_names", SYMLINK+="net/by-chassis-id/%c"

The following patch will create a device node for network devices based off their ifindex;
udev can then use this device node for creating symlinks in /dev/net/xxxx similar to the
way that disks now use by-label and by-path symlinks.

Combining this with the biosdevname utility and patches to common network utilities,
it could be possible to access ethernet devices by their PCI path or BIOS Label.

eg. ifconfig Embedded_NIC_1

--- include/linux/major.h~	2009-07-30 18:34:47.000000000 -0400
+++ include/linux/major.h	2009-08-05 14:52:10.000000000 -0400
@@ -169,6 +169,7 @@
 #define IBM_FS3270_MAJOR	228
 
 #define VIOTAPE_MAJOR		230
+#define NETDEV_MAJOR		234
 
 #define BLOCK_EXT_MAJOR		259
 #define SCSI_OSD_MAJOR		260	/* open-osd's OSD scsi device */
--- net/core/net-sysfs.cx	2009-08-05 15:00:13.000000000 -0400
+++ net/core/net-sysfs.c	2009-08-05 15:01:20.000000000 -0400
@@ -11,6 +11,7 @@
 
 #include <linux/capability.h>
 #include <linux/kernel.h>
+#include <linux/major.h>
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <net/sock.h>
@@ -496,6 +497,7 @@ int netdev_register_kobject(struct net_d
 	dev->class = &net_class;
 	dev->platform_data = net;
 	dev->groups = groups;
+	dev->devt = MKDEV(NETDEV_MAJOR, net->ifindex);
 
 	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
 	dev_set_name(dev, "%s", net->name);


--jordan hargrave
Dell Enterprise Linux Engineering





