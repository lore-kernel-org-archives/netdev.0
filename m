From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] netxen: reduce stack usage of netxen_nic_flash_print
Date: Tue, 22 Apr 2008 11:48:35 -0700
Message-ID: <1208890115.24124.3.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.190]:57087 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933AbYDVSsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 14:48:11 -0400
Received: by rn-out-0910.google.com with SMTP id e11so874393rng.17
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 11:48:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't need to keep a struct netxen_new_user_info on the stack
when we only are interested in printing the serial_num.  Change
to only reading the serial_num.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/netxen/netxen_nic_hw.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 05748ca..af73564 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1132,8 +1132,8 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
-	struct netxen_new_user_info user_info;
-	int i, addr = NETXEN_USER_START;
+	char serial_num[32];
+	int i, addr;
 	__le32 *ptr32;
 
 	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
@@ -1150,10 +1150,10 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 		valid = 0;
 	}
 	if (valid) {
-		ptr32 = (u32 *) & user_info;
-		for (i = 0;
-		     i < sizeof(struct netxen_new_user_info) / sizeof(u32);
-		     i++) {
+		ptr32 = (u32 *)&serial_num;
+		addr = NETXEN_USER_START +
+		       offsetof(struct netxen_new_user_info, serial_num);
+		for (i = 0; i < 8; i++) {
 			if (netxen_rom_fast_read(adapter, addr, ptr32) == -1) {
 				printk("%s: ERROR reading %s board userarea.\n",
 				       netxen_nic_driver_name,
@@ -1163,10 +1163,11 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 			ptr32++;
 			addr += sizeof(u32);
 		}
+
 		get_brd_name_by_type(board_info->board_type, brd_name);
 
 		printk("NetXen %s Board S/N %s  Chip id 0x%x\n",
-		       brd_name, user_info.serial_num, board_info->chip_id);
+		       brd_name, serial_num, board_info->chip_id);
 
 		printk("NetXen %s Board #%d, Chip id 0x%x\n",
 		       board_info->board_type == 0x0b ? "XGB" : "GBE",
-- 
1.5.5.144.g3e42



