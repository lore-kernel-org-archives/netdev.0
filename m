From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 6/7] NetXen: Fixes for Power PC architecture
Date: Fri, 13 Apr 2007 08:42:57 -0700
Message-ID: <200704131542.l3DFgvsv002650@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:3494 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754059AbXDMPm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 11:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Configurable interrupts on PPC architecture
This patch will add support to add command line argument to specify
the interrupt type on a PPC machine. Fixes some issues seen on Big endian
machines.

Signed-off by: Milan Bag <mbag@netxen.com> 
Acked-by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic.h      |    6 +++---
 drivers/net/netxen/netxen_nic_hw.c   |    2 +-
 drivers/net/netxen/netxen_nic_init.c |    4 ++--
 drivers/net/netxen/netxen_nic_main.c |    6 ++++++
 4 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 3549c7c..7ba2383 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -64,9 +64,9 @@ #include <asm/pgtable.h>
 #include "netxen_nic_hw.h"
 
 #define _NETXEN_NIC_LINUX_MAJOR 3
-#define _NETXEN_NIC_LINUX_MINOR 3
-#define _NETXEN_NIC_LINUX_SUBVERSION 3
-#define NETXEN_NIC_LINUX_VERSIONID  "3.3.3"
+#define _NETXEN_NIC_LINUX_MINOR 4
+#define _NETXEN_NIC_LINUX_SUBVERSION 2
+#define NETXEN_NIC_LINUX_VERSIONID  "3.4.2"
 
 #define NUM_FLASH_SECTORS (64)
 #define FLASH_SECTOR_SIZE (64 * 1024)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 3195fa5..4206125 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1141,7 +1141,7 @@ void netxen_nic_flash_print(struct netxe
 				       netxen_nic_driver_name);
 				return;
 			}
-			*ptr32 = le32_to_cpu(*ptr32);
+			*ptr32 = cpu_to_le32(*ptr32);
 			ptr32++;
 			addr += sizeof(u32);
 		}
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 3c68eea..3e2b541 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -439,6 +439,7 @@ do_rom_fast_read_words(struct netxen_ada
 		ret = do_rom_fast_read(adapter, addridx, (int *)bytes);
 		if (ret != 0)
 			break;
+		*(int *)bytes = cpu_to_le32(*(int *)bytes);
 		bytes += 4;
 	}
 
@@ -496,8 +497,7 @@ static inline int do_rom_fast_write_word
 		int timeout = 0;
 		int data;
 
-		data = *(u32*)bytes;
-
+		data = le32_to_cpu((*(u32*)bytes));
 		ret = do_rom_fast_write(adapter, addridx, data);
 		if (ret < 0)
 			return ret;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1739308..18521a4 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -51,6 +51,12 @@ module_param(nx_ppc_msi_enable, int, 064
 MODULE_PARM_DESC(nx_ppc_msi_enable, "NetXen PPC MSI enable value");
 #endif /* CONFIG_PPC */
 
+#ifdef CONFIG_PPC
+static int nx_ppc_msi_enable = 0;      /* by default donot enable msi */
+module_param(nx_ppc_msi_enable, int, 0644);
+MODULE_PARM_DESC(nx_ppc_msi_enable, "NetXen PPC MSI enable value");
+#endif /* CONFIG_PPC */
+
 char netxen_nic_driver_name[] = "netxen-nic";
 static char netxen_nic_driver_string[] = "NetXen Network Driver version "
     NETXEN_NIC_LINUX_VERSIONID;
