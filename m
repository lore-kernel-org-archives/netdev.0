From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 6/7] NetXen: Fixes for Power PC architecture
Date: Fri, 20 Apr 2007 07:56:42 -0700
Message-ID: <200704201456.l3KEugBp004581@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:16260 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1767128AbXDTO4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 10:56:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix PPC architecture specific bugs
Fixes some issues seen on Big endian machines.

Signed-off by: Milan Bag <mbag@netxen.com> 
Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic.h      |    6 +++---
 drivers/net/netxen/netxen_nic_hw.c   |    3 +--
 drivers/net/netxen/netxen_nic_init.c |    4 ++--
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 1e944d5..5095a3f 100644
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
index fba8790..2af5a9d 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1115,7 +1115,7 @@ void netxen_nic_flash_print(struct netxe
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	struct netxen_new_user_info user_info;
 	int i, addr = USER_START;
-	u32 *ptr32;
+	__le32 *ptr32;
 
 	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
 	if (board_info->magic != NETXEN_BDINFO_MAGIC) {
@@ -1141,7 +1141,6 @@ void netxen_nic_flash_print(struct netxe
 				       netxen_nic_driver_name);
 				return;
 			}
-			*ptr32 = le32_to_cpu(*ptr32);
 			ptr32++;
 			addr += sizeof(u32);
 		}
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index ca3d78b..b75998d 100644
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
