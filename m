From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] Use dev_port for the ID of a network device.
Date: Mon, 30 Jun 2014 17:36:36 -0300
Message-ID: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: systemd-devel@lists.freedesktop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:33355 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbaF3Ugt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 16:36:49 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 30 Jun 2014 17:36:47 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id EA71135200A6
	for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 16:36:39 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5UKa8qP8519828
	for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 17:36:08 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5UKahPk013448
	for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 17:36:43 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For network devices on the same PCI function, dev_id should not be used,
since its purpose is for IPv6 support on interfaces with the same MAC
address.

The new dev_port sysfs attribute should be used when it is found. When
it is not, using dev_id might work.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 src/udev/udev-builtin-net_id.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/src/udev/udev-builtin-net_id.c b/src/udev/udev-builtin-net_id.c
index c80c30a..6de9c98 100644
--- a/src/udev/udev-builtin-net_id.c
+++ b/src/udev/udev-builtin-net_id.c
@@ -186,9 +186,14 @@ static int dev_pci_slot(struct udev_device *dev, struct netnames *names) {
                 return -ENOENT;
 
         /* kernel provided multi-device index */
-        attr = udev_device_get_sysattr_value(dev, "dev_id");
-        if (attr)
+        attr = udev_device_get_sysattr_value(dev, "dev_port");
+        if (attr) {
                 dev_id = strtol(attr, NULL, 16);
+        } else {
+                attr = udev_device_get_sysattr_value(dev, "dev_id");
+                if (attr)
+                        dev_id = strtol(attr, NULL, 16);
+        }
 
         /* compose a name based on the raw kernel's PCI bus, slot numbers */
         s = names->pci_path;
-- 
1.7.1
