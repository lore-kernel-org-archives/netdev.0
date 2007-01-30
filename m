From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2/2] NetXen: Firmware crb init changes
Date: Tue, 30 Jan 2007 07:27:33 -0800
Message-ID: <200701301527.l0UFRXBK005946@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:21289 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965604AbXA3P1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 10:27:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: firmware crb init changes.

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---

 netxen_nic.h      |    2 +-
 netxen_nic_init.c |   12 +++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f188b59..9964f56 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,7 +63,7 @@ #include <asm/pgtable.h>
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "3"
+#define NETXEN_NIC_BUILD_NO     "4"
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
 #define _NETXEN_NIC_LINUX_SUBVERSION 3
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 069436f..cdbaf1d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -110,6 +110,7 @@ static void crb_addr_transform_setup(voi
 	crb_addr_transform(CAM);
 	crb_addr_transform(C2C1);
 	crb_addr_transform(C2C0);
+	crb_addr_transform(SMB);
 }
 
 int netxen_init_firmware(struct netxen_adapter *adapter)
@@ -803,9 +804,13 @@ int netxen_pinit_from_rom(struct netxen_
 		}
 		for (i = 0; i < n; i++) {
 
-			off =
-			    netxen_decode_crb_addr((unsigned long)buf[i].addr) +
-			    NETXEN_PCI_CRBSPACE;
+			off = netxen_decode_crb_addr((unsigned long)buf[i].addr);
+			if (off == NETXEN_ADDR_ERROR) {
+				printk(KERN_ERR"CRB init value out of range %lx\n",
+					buf[i].addr);
+				continue;
+			}
+			off += NETXEN_PCI_CRBSPACE;
 			/* skipping cold reboot MAGIC */
 			if (off == NETXEN_CAM_RAM(0x1fc))
 				continue;
@@ -922,6 +927,7 @@ void netxen_phantom_init(struct netxen_a
 	int loops = 0;
 
 	if (!pegtune_val) {
+		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 		while (val != PHAN_INITIALIZE_COMPLETE && loops < 200000) {
 			udelay(100);
 			schedule();
