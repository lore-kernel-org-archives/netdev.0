From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH 1/1 net-next]: s2io: Fix log messages using dev->name
Date: Tue, 26 Aug 2008 11:18:22 -0300
Message-ID: <48B410AE.2040802@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Lorandi <rafaello@br.ibm.com>
To: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:51208 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758458AbYHZOTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:19:11 -0400
Received: from mailhub1.br.ibm.com (unknown [9.18.232.109])
	by igw3.br.ibm.com (Postfix) with ESMTP id 438A2390154
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 10:58:40 -0300 (BRST)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7QEIoC61953812
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 11:19:04 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7QEIg5L028463
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 11:18:42 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

s2io driver is printing dev->name before its assignment (by
dev_alloc_name()), so "eth%d" is printed instead of "eth0", "eth1", etc=
=2E
Here is an example gotten from dmesg:=20

eth%d: Enabling MSIX failed
eth%d: MSI-X requested but failed to enable

This patch calls dev_alloc_name() earlier, before any message being
printed, hence dev->name is translated from "eth%d" to "eth0", for
example, and all those prints become correct.=20

Signed-off-by: Breno Leit=C3=A3o <leitao@linux.vnet.ibm.com>
---

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a2b0730..42a860d 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7796,6 +7796,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct=
 pci_device_id *pre)
 		return -ENODEV;
 	}
=20
+	ret =3D dev_alloc_name(dev, dev->name);
+	if (ret < 0)
+		goto dev_alloc_failed;
+
 	pci_set_master(pdev);
 	pci_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -8223,6 +8227,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct =
pci_device_id *pre)
       bar0_remap_failed:
       mem_alloc_failed:
 	free_shared_mem(sp);
+      dev_alloc_failed:
 	pci_disable_device(pdev);
 	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
