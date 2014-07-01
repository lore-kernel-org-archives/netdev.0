From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH v2] Use dev_port for the ID of a network device.
Date: Tue,  1 Jul 2014 10:12:24 -0300
Message-ID: <1404220344-12461-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:50255 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbaGANMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 09:12:31 -0400
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 1 Jul 2014 10:12:30 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id C3DF31DC005E
	for <netdev@vger.kernel.org>; Tue,  1 Jul 2014 09:12:26 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s61DCfKG4919438
	for <netdev@vger.kernel.org>; Tue, 1 Jul 2014 10:12:41 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s61DCQh3029023
	for <netdev@vger.kernel.org>; Tue, 1 Jul 2014 09:12:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For network devices on the same PCI function, dev_id should not be used,
since its purpose is for IPv6 support on interfaces with the same MAC
address.

The new dev_port sysfs attribute should be used instead of dev_id.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 NEWS                           |    5 +++++
 src/udev/udev-builtin-net_id.c |   18 +++++++++---------
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/NEWS b/NEWS
index 00727d1..f0c29d1 100644
--- a/NEWS
+++ b/NEWS
@@ -6,6 +6,11 @@ CHANGES WITH 215:
           system-level software to get access to input devices. It
           complements what is already done for "audio" and "video".
 
+        * udev built-in net_id uses dev_port sysfs attribute, introduced
+          in linux 3.15 instead of dev_id to distinguish between ports
+          of the same PCI function. dev_id should only be used for ports
+          using the same HW address, hence the need for dev_port.
+
 CHANGES WITH 214:
 
         * As an experimental feature, udev now tries to lock the
diff --git a/src/udev/udev-builtin-net_id.c b/src/udev/udev-builtin-net_id.c
index c80c30a..96ac21c 100644
--- a/src/udev/udev-builtin-net_id.c
+++ b/src/udev/udev-builtin-net_id.c
@@ -36,9 +36,9 @@
  *   b<number>                             -- BCMA bus core number
  *   ccw<name>                             -- CCW bus group name
  *   o<index>                              -- on-board device index number
- *   s<slot>[f<function>][d<dev_id>]       -- hotplug slot index number
+ *   s<slot>[f<function>][d<dev_port>]     -- hotplug slot index number
  *   x<MAC>                                -- MAC address
- *   [P<domain>]p<bus>s<slot>[f<function>][d<dev_id>]
+ *   [P<domain>]p<bus>s<slot>[f<function>][d<dev_port>]
  *                                         -- PCI geographical location
  *   [P<domain>]p<bus>s<slot>[f<function>][u<port>][..][c<config>][i<interface>]
  *                                         -- USB port number chain
@@ -172,7 +172,7 @@ out:
 
 static int dev_pci_slot(struct udev_device *dev, struct netnames *names) {
         struct udev *udev = udev_device_get_udev(names->pcidev);
-        unsigned domain, bus, slot, func, dev_id = 0;
+        unsigned domain, bus, slot, func, dev_port = 0;
         size_t l;
         char *s;
         const char *attr;
@@ -186,9 +186,9 @@ static int dev_pci_slot(struct udev_device *dev, struct netnames *names) {
                 return -ENOENT;
 
         /* kernel provided multi-device index */
-        attr = udev_device_get_sysattr_value(dev, "dev_id");
+        attr = udev_device_get_sysattr_value(dev, "dev_port");
         if (attr)
-                dev_id = strtol(attr, NULL, 16);
+                dev_port = strtol(attr, NULL, 10);
 
         /* compose a name based on the raw kernel's PCI bus, slot numbers */
         s = names->pci_path;
@@ -198,8 +198,8 @@ static int dev_pci_slot(struct udev_device *dev, struct netnames *names) {
         l = strpcpyf(&s, l, "p%ds%d", bus, slot);
         if (func > 0 || is_pci_multifunction(names->pcidev))
                 l = strpcpyf(&s, l, "f%d", func);
-        if (dev_id > 0)
-                l = strpcpyf(&s, l, "d%d", dev_id);
+        if (dev_port > 0)
+                l = strpcpyf(&s, l, "d%d", dev_port);
         if (l == 0)
                 names->pci_path[0] = '\0';
 
@@ -248,8 +248,8 @@ static int dev_pci_slot(struct udev_device *dev, struct netnames *names) {
                 l = strpcpyf(&s, l, "s%d", hotplug_slot);
                 if (func > 0 || is_pci_multifunction(names->pcidev))
                         l = strpcpyf(&s, l, "f%d", func);
-                if (dev_id > 0)
-                        l = strpcpyf(&s, l, "d%d", dev_id);
+                if (dev_port > 0)
+                        l = strpcpyf(&s, l, "d%d", dev_port);
                 if (l == 0)
                         names->pci_path[0] = '\0';
         }
-- 
1.7.1
