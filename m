From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Dump the eeprom when a user encounters a bad checksum
Date: Mon, 17 Dec 2007 13:50:23 -0800
Message-ID: <20071217215023.26270.62396.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	randy.dunlap@oracle.com, joe@perches.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17818 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758224AbXLQWGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 17:06:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To help supporting users with a bad eeprom checksum, dump the
eeprom info when such a situation is encountered by a user.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   85 +++++++++++++++++++++++++++++++++++-----
 1 files changed, 74 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index efd8c2d..aac55be 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -817,6 +817,64 @@ e1000_reset(struct e1000_adapter *adapter)
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
+	printk(KERN_ERR "Current EEPROM Checksum : 0x%04x\n", csum_old);
+	printk(KERN_ERR "Calculated              : 0x%04x\n", csum_new);
+
+	printk(KERN_ERR "Offset    Values\n");
+	printk(KERN_ERR "========  ======\n");
+	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 16, 1, data, 128, 0);
+
+	printk(KERN_ERR "Include this output when contacting your support "
+	       "provider.\n");
+	printk(KERN_ERR "This is not a software error! Something bad "
+	       "happened to your hardware or\n");
+	printk(KERN_ERR "EEPROM image. Ignoring this "
+	       "problem could result in further problems,\n");
+	printk(KERN_ERR "possibly loss of data, corruption or system hangs!\n");
+	printk(KERN_ERR "The MAC Address will be reset to 00:00:00:00:00:00, "
+	       "which is invalid\n");
+	printk(KERN_ERR "and requires you to set the proper MAC "
+	       "address manually before continuing\n");
+	printk(KERN_ERR "to enable this network device.\n");
+	printk(KERN_ERR "Please inspect the EEPROM dump and report the issue "
+	       "to your hardware vendor\n");
+	printk(KERN_ERR "or Intel Customer Support: linux-nics@intel.com\n");
+	printk(KERN_ERR "/*********************/\n");
+
+	kfree(data);
+}
+
+/**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in e1000_pci_tbl
@@ -967,7 +1025,6 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* initialize eeprom parameters */
-
 	if (e1000_init_eeprom_params(&adapter->hw)) {
 		E1000_ERR("EEPROM initialization failed\n");
 		goto err_eeprom;
@@ -979,23 +1036,29 @@ e1000_probe(struct pci_dev *pdev,
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
 

