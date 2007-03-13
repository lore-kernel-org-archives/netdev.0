From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 2/2] NetXen: Fix softlockup seen during hardware access
Date: Tue, 13 Mar 2007 04:15:06 -0800
Message-ID: <200703131215.l2DCF649009009@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:8596 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965721AbXCMMPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 08:15:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: This will fix a softlock seen on some machines.
The reason was too much time was spent waiting for hardware access
to go through.

Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic.h         |    1 +
 drivers/net/netxen/netxen_nic_ethtool.c |    1 +
 drivers/net/netxen/netxen_nic_init.c    |   11 +++++++++--
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 81742e4..dd8ce35 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -232,6 +232,7 @@ #define get_index_range(index,length,cou
 #define MPORT_SINGLE_FUNCTION_MODE 0x1111
 
 extern unsigned long long netxen_dma_mask;
+extern unsigned long last_schedule_time;
 
 /*
  * NetXen host-peg signal message structure
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 986ef98..ee1b5a2 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -462,6 +462,7 @@ netxen_nic_set_eeprom(struct net_device 
 		}
 		printk(KERN_INFO "%s: flash unlocked. \n", 
 			netxen_nic_driver_name);
+		last_schedule_time = jiffies;
 		ret = netxen_flash_erase_secondary(adapter);
 		if (ret != FLASH_SUCCESS) {
 			printk(KERN_ERR "%s: Flash erase failed.\n", 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 586d32b..229aa1c 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -42,6 +42,8 @@ struct crb_addr_pair {
 	u32 data;
 };
 
+unsigned long last_schedule_time;
+
 #define NETXEN_MAX_CRB_XFORM 60
 static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
 #define NETXEN_ADDR_ERROR (0xffffffff)
@@ -404,9 +406,14 @@ static inline int do_rom_fast_write(stru
 static inline int
 do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 {
+	if (jiffies > (last_schedule_time + (8 * HZ))) {
+		last_schedule_time = jiffies;
+		schedule();
+	}
+
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
-	udelay(70);		/* prevent bursting on CRB */
+	udelay(100);		/* prevent bursting on CRB */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0xb);
 	if (netxen_wait_rom_done(adapter)) {
@@ -415,7 +422,7 @@ do_rom_fast_read(struct netxen_adapter *
 	}
 	/* reset abyte_cnt and dummy_byte_cnt */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
-	udelay(70);		/* prevent bursting on CRB */
+	udelay(100);		/* prevent bursting on CRB */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
 	*valp = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_ROM_RDATA);
