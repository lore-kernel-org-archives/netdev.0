From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 3/3] NetXen: Added ethtool support for user level tools.
Date: Mon, 5 Feb 2007 07:40:49 -0800
Message-ID: <200702051540.l15Fenfw008692@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:11301 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750729AbXBEPky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 10:40:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Added ethtool support for user level firmware management utilities.

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---

 netxen_nic.h         |   17 ++-
 netxen_nic_ethtool.c |   96 +++++++++++++++---
 netxen_nic_init.c    |  267++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 361 insertions(+), 19 deletions(-)
    
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index d689476..741c64c 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,11 +63,14 @@ #include <asm/pgtable.h>
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "2"
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
 #define _NETXEN_NIC_LINUX_SUBVERSION 3
-#define NETXEN_NIC_LINUX_VERSIONID  "3.3.3" "-" NETXEN_NIC_BUILD_NO
+#define NETXEN_NIC_LINUX_VERSIONID  "3.3.3"
+
+#define NUM_FLASH_SECTORS (64)
+#define FLASH_SECTOR_SIZE (64 * 1024)
+#define FLASH_TOTAL_SIZE  (NUM_FLASH_SECTORS * FLASH_SECTOR_SIZE)
 
 #define RCV_DESC_RINGSIZE	\
 	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
@@ -85,6 +88,7 @@ #define NETXEN_NETDEV_STATUS		0x1
 #define NETXEN_RCV_PRODUCER_OFFSET	0
 #define NETXEN_RCV_PEG_DB_ID		2
 #define NETXEN_HOST_DUMMY_DMA_SIZE 1024
+#define FLASH_SUCCESS 0
 
 #define ADDR_IN_WINDOW1(off)	\
 	((off > NETXEN_CRB_PCIX_HOST2) && (off < NETXEN_CRB_MAX)) ? 1 : 0
@@ -1054,6 +1058,15 @@ void netxen_phantom_init(struct netxen_a
 void netxen_load_firmware(struct netxen_adapter *adapter);
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose);
 int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp);
+int netxen_rom_fast_read_words(struct netxen_adapter *adapter, int addr, 
+				u8 *bytes, size_t size);
+int netxen_rom_fast_write_words(struct netxen_adapter *adapter, int addr, 
+				u8 *bytes, size_t size);
+int netxen_flash_unlock(struct netxen_adapter *adapter);
+int netxen_backup_crbinit(struct netxen_adapter *adapter);
+int netxen_flash_erase_secondary(struct netxen_adapter *adapter);
+int netxen_flash_erase_primary(struct netxen_adapter *adapter);
+
 int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data);
 int netxen_rom_se(struct netxen_adapter *adapter, int addr);
 int netxen_do_rom_se(struct netxen_adapter *adapter, int addr);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 3404461..aa96140 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/types.h>
+#include <linux/delay.h>
 #include <asm/uaccess.h>
 #include <linux/pci.h>
 #include <asm/io.h>
@@ -94,17 +95,7 @@ #define NETXEN_MAX_EEPROM_LEN   1024
 
 static int netxen_nic_get_eeprom_len(struct net_device *dev)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
-	int n;
-
-	if ((netxen_rom_fast_read(adapter, 0, &n) == 0)
-	    && (n & NETXEN_ROM_ROUNDUP)) {
-		n &= ~NETXEN_ROM_ROUNDUP;
-		if (n < NETXEN_MAX_EEPROM_LEN)
-			return n;
-	}
-	return 0;
+	return FLASH_TOTAL_SIZE;
 }
 
 static void
@@ -440,18 +431,92 @@ netxen_nic_get_eeprom(struct net_device 
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
 	int offset;
+	int ret;
 
 	if (eeprom->len == 0)
 		return -EINVAL;
 
 	eeprom->magic = (port->pdev)->vendor | ((port->pdev)->device << 16);
-	for (offset = 0; offset < eeprom->len; offset++)
-		if (netxen_rom_fast_read
-		    (adapter, (8 * offset) + 8, (int *)eeprom->data) == -1)
-			return -EIO;
+	offset = eeprom->offset;
+
+	ret = netxen_rom_fast_read_words(adapter, offset, bytes, 
+						eeprom->len);
+	if (ret < 0)
+		return ret;
+
 	return 0;
 }
 
+static int
+netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			u8 * bytes)
+{
+	struct netxen_port *port = netdev_priv(dev);
+	struct netxen_adapter *adapter = port->adapter;
+	int offset = eeprom->offset;
+	static int flash_start;
+	static int ready_to_flash;
+	int ret;
+
+	if (flash_start == 0) {
+		ret = netxen_flash_unlock(adapter);
+		if (ret < 0) {
+			printk(KERN_ERR "%s: Flash unlock failed.\n",
+				netxen_nic_driver_name);
+			return ret;
+		}
+		printk(KERN_INFO "%s: flash unlocked. \n", 
+			netxen_nic_driver_name);
+		ret = netxen_flash_erase_secondary(adapter);
+		if (ret != FLASH_SUCCESS) {
+			printk(KERN_ERR "%s: Flash erase failed.\n", 
+				netxen_nic_driver_name);
+			return ret;
+		}
+		printk(KERN_INFO "%s: secondary flash erased successfully.\n", 
+			netxen_nic_driver_name);
+		flash_start = 1;
+		return 0;
+	}
+
+	if (offset == BOOTLD_START) {
+		ret = netxen_flash_erase_primary(adapter);
+		if (ret != FLASH_SUCCESS) {
+			printk(KERN_ERR "%s: Flash erase failed.\n", 
+				netxen_nic_driver_name);
+			return ret;
+		}
+
+		ret = netxen_rom_se(adapter, USER_START);
+		if (ret != FLASH_SUCCESS)
+			return ret;
+		ret = netxen_rom_se(adapter, FIXED_START);
+		if (ret != FLASH_SUCCESS)
+			return ret;
+
+		printk(KERN_INFO "%s: primary flash erased successfully\n", 
+			netxen_nic_driver_name);
+
+		ret = netxen_backup_crbinit(adapter);
+		if (ret != FLASH_SUCCESS) {
+			printk(KERN_ERR "%s: CRBinit backup failed.\n", 
+				netxen_nic_driver_name);
+			return ret;
+		}
+		printk(KERN_INFO "%s: CRBinit backup done.\n", 
+			netxen_nic_driver_name);
+		ready_to_flash = 1;
+	}
+
+	if (!ready_to_flash) {
+		printk(KERN_ERR "%s: Invalid write sequence, returning...\n",
+			netxen_nic_driver_name);
+		return -EINVAL;
+	}
+
+	return netxen_rom_fast_write_words(adapter, offset, bytes, eeprom->len);
+}
+
 static void
 netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 {
@@ -721,6 +786,7 @@ struct ethtool_ops netxen_nic_ethtool_op
 	.get_link = netxen_nic_get_link,
 	.get_eeprom_len = netxen_nic_get_eeprom_len,
 	.get_eeprom = netxen_nic_get_eeprom,
+	.set_eeprom = netxen_nic_set_eeprom,
 	.get_ringparam = netxen_nic_get_ringparam,
 	.get_pauseparam = netxen_nic_get_pauseparam,
 	.set_pauseparam = netxen_nic_set_pauseparam,
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 73c0c45..e7e2cc7 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -277,6 +277,7 @@ unsigned long netxen_decode_crb_addr(uns
 
 static long rom_max_timeout = 10000;
 static long rom_lock_timeout = 1000000;
+static long rom_write_timeout = 700;
 
 static inline int rom_lock(struct netxen_adapter *adapter)
 {
@@ -405,7 +406,7 @@ do_rom_fast_read(struct netxen_adapter *
 {
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
-	udelay(100);		/* prevent bursting on CRB */
+	udelay(70);		/* prevent bursting on CRB */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0xb);
 	if (netxen_wait_rom_done(adapter)) {
@@ -414,13 +415,46 @@ do_rom_fast_read(struct netxen_adapter *
 	}
 	/* reset abyte_cnt and dummy_byte_cnt */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
-	udelay(100);		/* prevent bursting on CRB */
+	udelay(70);		/* prevent bursting on CRB */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
 	*valp = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_ROM_RDATA);
 	return 0;
 }
 
+static inline int 
+do_rom_fast_read_words(struct netxen_adapter *adapter, int addr,
+			u8 *bytes, size_t size)
+{
+	int addridx;
+	int ret = 0;
+
+	for (addridx = addr; addridx < (addr + size); addridx += 4) {
+		ret = do_rom_fast_read(adapter, addridx, (int *)bytes);
+		if (ret != 0)
+			break;
+		bytes += 4;
+	}
+
+	return ret;
+}
+
+int
+netxen_rom_fast_read_words(struct netxen_adapter *adapter, int addr, 
+				u8 *bytes, size_t size)
+{
+	int ret;
+
+	ret = rom_lock(adapter);
+	if (ret < 0)
+		return ret;
+
+	ret = do_rom_fast_read_words(adapter, addr, bytes, size);
+
+	netxen_rom_unlock(adapter);
+	return ret;
+}
+
 int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 {
 	int ret;
@@ -444,6 +478,152 @@ int netxen_rom_fast_write(struct netxen_
 	netxen_rom_unlock(adapter);
 	return ret;
 }
+
+static inline int do_rom_fast_write_words(struct netxen_adapter *adapter, 
+						int addr, u8 *bytes, size_t size)
+{
+	int addridx = addr;
+	int ret = 0;
+
+	while (addridx < (addr + size)) {
+		int last_attempt = 0;
+		int timeout = 0;
+		int data;
+
+		data = *(u32*)bytes;
+
+		ret = do_rom_fast_write(adapter, addridx, data);
+		if (ret < 0)
+			return ret;
+			
+		while(1) {
+			int data1;
+
+			do_rom_fast_read(adapter, addridx, &data1);
+			if (data1 == data)
+				break;
+
+			if (timeout++ >= rom_write_timeout) {
+				if (last_attempt++ < 4) {
+					ret = do_rom_fast_write(adapter, 
+								addridx, data);
+					if (ret < 0)
+						return ret;
+				}
+				else {
+					printk(KERN_INFO "Data write did not "
+					   "succeed at address 0x%x\n", addridx);
+					break;
+				}
+			}
+		}
+
+		bytes += 4;
+		addridx += 4;
+	}
+
+	return ret;
+}
+
+int netxen_rom_fast_write_words(struct netxen_adapter *adapter, int addr, 
+					u8 *bytes, size_t size)
+{
+	int ret = 0;
+
+	ret = rom_lock(adapter);
+	if (ret < 0)
+		return ret;
+
+	ret = do_rom_fast_write_words(adapter, addr, bytes, size);
+	netxen_rom_unlock(adapter);
+
+	return ret;
+}
+
+int netxen_rom_wrsr(struct netxen_adapter *adapter, int data)
+{
+	int ret;
+
+	ret = netxen_rom_wren(adapter);
+	if (ret < 0)
+		return ret;
+
+	netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_ROM_WDATA, data);
+	netxen_crb_writelit_adapter(adapter, 
+					NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0x1);
+
+	ret = netxen_wait_rom_done(adapter);
+	if (ret < 0)
+		return ret;
+
+	return netxen_rom_wip_poll(adapter);
+}
+
+int netxen_rom_rdsr(struct netxen_adapter *adapter)
+{
+	int ret;
+
+	ret = rom_lock(adapter);
+	if (ret < 0)
+		return ret;
+
+	ret = netxen_do_rom_rdsr(adapter);
+	netxen_rom_unlock(adapter);
+	return ret;
+}
+
+int netxen_backup_crbinit(struct netxen_adapter *adapter)
+{
+	int ret = FLASH_SUCCESS;
+	int val;
+	char *buffer = kmalloc(FLASH_SECTOR_SIZE, GFP_KERNEL);
+
+	if (!buffer)
+		return -ENOMEM;	
+	/* unlock sector 63 */
+	val = netxen_rom_rdsr(adapter);
+	val = val & 0xe3;
+	ret = netxen_rom_wrsr(adapter, val);
+	if (ret != FLASH_SUCCESS)
+		goto out_kfree;
+
+	ret = netxen_rom_wip_poll(adapter);
+	if (ret != FLASH_SUCCESS)
+		goto out_kfree;
+
+	/* copy  sector 0 to sector 63 */
+	ret = netxen_rom_fast_read_words(adapter, CRBINIT_START, 
+						buffer, FLASH_SECTOR_SIZE);
+	if (ret != FLASH_SUCCESS)
+		goto out_kfree;
+
+	ret = netxen_rom_fast_write_words(adapter, FIXED_START, 
+						buffer, FLASH_SECTOR_SIZE);
+	if (ret != FLASH_SUCCESS)
+		goto out_kfree;
+
+	/* lock sector 63 */
+	val = netxen_rom_rdsr(adapter);
+	if (!(val & 0x8)) {
+		val |= (0x1 << 2);
+		/* lock sector 63 */
+		if (netxen_rom_wrsr(adapter, val) == 0) {
+			ret = netxen_rom_wip_poll(adapter);
+			if (ret != FLASH_SUCCESS)
+				goto out_kfree;
+
+			/* lock SR writes */
+			ret = netxen_rom_wip_poll(adapter);
+			if (ret != FLASH_SUCCESS)
+				goto out_kfree;
+		}
+	}
+
+out_kfree:
+	kfree(buffer);
+	return ret;
+}
+
 int netxen_do_rom_se(struct netxen_adapter *adapter, int addr)
 {
 	netxen_rom_wren(adapter);
@@ -458,6 +638,27 @@ int netxen_do_rom_se(struct netxen_adapt
 	return netxen_rom_wip_poll(adapter);
 }
 
+void check_erased_flash(struct netxen_adapter *adapter, int addr)
+{
+	int i;
+	int val;
+	int count = 0, erased_errors = 0;
+	int range;
+
+	range = (addr == USER_START) ? FIXED_START : addr + FLASH_SECTOR_SIZE;
+	
+	for (i = addr; i < range; i += 4) {
+		netxen_rom_fast_read(adapter, i, &val);
+		if (val != 0xffffffff)
+			erased_errors++;
+		count++;
+	}
+
+	if (erased_errors)
+		printk(KERN_INFO "0x%x out of 0x%x words fail to be erased "
+			"for sector address: %x\n", erased_errors, count, addr);
+}
+
 int netxen_rom_se(struct netxen_adapter *adapter, int addr)
 {
 	int ret = 0;
@@ -466,6 +667,68 @@ int netxen_rom_se(struct netxen_adapter 
 	}
 	ret = netxen_do_rom_se(adapter, addr);
 	netxen_rom_unlock(adapter);
+	msleep(30);
+	check_erased_flash(adapter, addr);
+
+	return ret;
+}
+
+int
+netxen_flash_erase_sections(struct netxen_adapter *adapter, int start, int end)
+{
+	int ret = FLASH_SUCCESS;
+	int i;
+
+	for (i = start; i < end; i++) {
+		ret = netxen_rom_se(adapter, i * FLASH_SECTOR_SIZE);
+		if (ret)
+			break;
+		ret = netxen_rom_wip_poll(adapter);
+		if (ret < 0)
+			return ret;
+	}
+
+	return ret;
+}
+
+int
+netxen_flash_erase_secondary(struct netxen_adapter *adapter)
+{
+	int ret = FLASH_SUCCESS;
+	int start, end;
+
+	start = SECONDARY_START / FLASH_SECTOR_SIZE;
+	end   = USER_START / FLASH_SECTOR_SIZE;
+	ret = netxen_flash_erase_sections(adapter, start, end);
+
+	return ret;
+}
+
+int
+netxen_flash_erase_primary(struct netxen_adapter *adapter)
+{
+	int ret = FLASH_SUCCESS;
+	int start, end;
+
+	start = PRIMARY_START / FLASH_SECTOR_SIZE;
+	end   = SECONDARY_START / FLASH_SECTOR_SIZE;
+	ret = netxen_flash_erase_sections(adapter, start, end);
+
+	return ret;
+}
+
+int netxen_flash_unlock(struct netxen_adapter *adapter)
+{
+	int ret = 0;
+
+	ret = netxen_rom_wrsr(adapter, 0);
+	if (ret < 0)
+		return ret;
+
+	ret = netxen_rom_wren(adapter);
+	if (ret < 0)
+		return ret;
+
 	return ret;
 }
 
