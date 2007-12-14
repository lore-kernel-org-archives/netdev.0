From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Dump the eeprom when a user encounters a bad checksum
Date: Fri, 14 Dec 2007 15:35:30 -0800
Message-ID: <20071214233530.27189.89810.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	john.ronciak@intel.com, jesse.brandeburg@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33325 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785AbXLNXfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 18:35:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To help supporting users with a bad eeprom checksum, dump the
eeprom info when such a situation is encountered by a user.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   90 +++++++++++++++++++++++++++++++++++-----
 1 files changed, 79 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index efd8c2d..2dab1a6 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -817,6 +817,69 @@ e1000_reset(struct e1000_adapter *adapter)
 }
 
 /**
+ *  Dump the eeprom for users having checksum issues
+ **/
+void e1000_dump_eeprom(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct ethtool_eeprom eeprom;
+	const struct ethtool_ops *ops = netdev->ethtool_ops;
+	u8 *data;
+	int i;
+	u16 csum_old, csum_new = 0;
+
+	eeprom.len = ops->get_eeprom_len(netdev);
+	eeprom.offset = 0;
+
+	data = kmalloc(eeprom.len, GFP_KERNEL);
+	if (!data) {
+		printk(KERN_ERR "Unable to allocate memory to dump EEPROM"
+		       " data\n");
+		return;
+	}
+
+	ops->get_eeprom(netdev, &eeprom, data);
+
+	csum_old = (data[EEPROM_CHECKSUM_REG * 2]) +
+		   (data[EEPROM_CHECKSUM_REG * 2 + 1] << 8);
+	for (i = 0; i < EEPROM_CHECKSUM_REG * 2; i += 2)
+		csum_new += data[i] + (data[i + 1] << 8);
+	csum_new = EEPROM_SUM - csum_new;
+
+	printk(KERN_ERR "/*********************/\n");
+	printk(KERN_ERR "Current EEPROM: 0x%04x\nCalculated    : 0x%04x\n",
+	       csum_old, csum_new);
+
+	printk(KERN_ERR "Offset   Values\n");
+	printk(KERN_ERR "======   ======\n");
+	for (i = 0; i < eeprom.len; i += 16)
+		printk(KERN_ERR "0x%04x   "
+		       "%02x %02x %02x %02x %02x %02x %02x %02x "
+		       "%02x %02x %02x %02x %02x %02x %02x %02x\n",
+		       i, data[i], data[i + 1], data[i + 2], data[i + 3],
+		       data[i + 4], data[i + 5], data[i + 6], data[i + 7],
+		       data[i + 8], data[i + 9], data[i + 10], data[i + 11],
+		       data[i + 12], data[i + 13], data[i + 14], data[i + 15]);
+
+	printk(KERN_ERR "Include this output when contacting your support "
+	       "provider.\n\nThis is not a software error! Something bad "
+	       "happened to your hardware or\nEEPROM image. Ignoring this "
+	       "problem could result in further problems,\npossibly loss "
+	       "of data, corruption or system hangs!\n\n");
+	printk(KERN_ERR "The MAC Address will be reset to 00:00:00:00:00:00, "
+	       "which is invalid\nand requires you to set the proper MAC "
+	       "address manually before continuing\nto enable this network "
+	       "device.\n\n");
+	printk(KERN_ERR "Please inspect the EEPROM dump and report the issue "
+	       "to your hardware vendor\nor Intel Customer Support: "
+	       "linux-nics@intel.com\n");
+
+	printk(KERN_ERR "/*********************/\n");
+
+	kfree(data);
+}
+
+/**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in e1000_pci_tbl
@@ -967,7 +1030,6 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* initialize eeprom parameters */
-
 	if (e1000_init_eeprom_params(&adapter->hw)) {
 		E1000_ERR("EEPROM initialization failed\n");
 		goto err_eeprom;
@@ -979,23 +1041,29 @@ e1000_probe(struct pci_dev *pdev,
 	e1000_reset_hw(&adapter->hw);
 
 	/* make sure the EEPROM is good */
-
 	if (e1000_validate_eeprom_checksum(&adapter->hw) < 0) {
 		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
-		goto err_eeprom;
+		e1000_dump_eeprom(adapter);
+		/*
+		 * set MAC address to all zeroes to invalidate and temporary
+		 * disable this device for the user. This blocks regular
+		 * traffic while still permitting ethtool ioctls from reaching
+		 * the hardware as well as allowing the user to run the
+		 * interface after manually setting a hw addr using
+		 * `ip set address`
+		 */
+		memset(adapter->hw.mac_addr, 0, netdev->addr_len);
+	} else {
+		/* copy the MAC address out of the EEPROM */
+		if (e1000_read_mac_addr(&adapter->hw))
+			DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
 	}
-
-	/* copy the MAC address out of the EEPROM */
-
-	if (e1000_read_mac_addr(&adapter->hw))
-		DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
+	/* don't block initalization here due to bad MAC address */
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->perm_addr))
 		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
-		goto err_eeprom;
-	}
 
 	e1000_get_bus_info(&adapter->hw);
 

