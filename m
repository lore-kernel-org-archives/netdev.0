From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 9/9] skge: remove VPD eeprom
Date: Tue, 09 Sep 2008 11:20:49 -0700
Message-ID: <20080909182057.634382071@vyatta.com>
References: <20080909182040.246073057@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:37565 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238AbYIIT3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 15:29:25 -0400
Content-Disposition: inline; filename=skge-no-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VPD is not really the firmware EEPROM.
Programming the VPD through the ethtool interface doesn't work
(doesn't really change firmware). Now that the interesting bits are
available through the debug interface and raw data is available through sysfs,
the old interface can go.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/skge.c	2008-09-09 11:19:33.000000000 -0700
+++ b/drivers/net/skge.c	2008-09-09 11:19:34.000000000 -0700
@@ -61,9 +61,6 @@
 #define BLINK_MS		250
 #define LINK_HZ			HZ
 
-#define SKGE_EEPROM_MAGIC	0x9933aabb
-
-
 MODULE_DESCRIPTION("SysKonnect Gigabit Ethernet driver");
 MODULE_AUTHOR("Stephen Hemminger <shemminger@linux-foundation.org>");
 MODULE_LICENSE("GPL");
@@ -803,98 +800,6 @@ static int skge_phys_id(struct net_devic
 	return 0;
 }
 
-static int skge_get_eeprom_len(struct net_device *dev)
-{
-	struct skge_port *skge = netdev_priv(dev);
-	u32 reg2;
-
-	pci_read_config_dword(skge->hw->pdev, PCI_DEV_REG2, &reg2);
-	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
-}
-
-static u32 skge_vpd_read(struct pci_dev *pdev, int cap, u16 offset)
-{
-	u32 val;
-
-	pci_write_config_word(pdev, cap + PCI_VPD_ADDR, offset);
-
-	do {
-		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
-	} while (!(offset & PCI_VPD_ADDR_F));
-
-	pci_read_config_dword(pdev, cap + PCI_VPD_DATA, &val);
-	return val;
-}
-
-static void skge_vpd_write(struct pci_dev *pdev, int cap, u16 offset, u32 val)
-{
-	pci_write_config_dword(pdev, cap + PCI_VPD_DATA, val);
-	pci_write_config_word(pdev, cap + PCI_VPD_ADDR,
-			      offset | PCI_VPD_ADDR_F);
-
-	do {
-		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
-	} while (offset & PCI_VPD_ADDR_F);
-}
-
-static int skge_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
-			   u8 *data)
-{
-	struct skge_port *skge = netdev_priv(dev);
-	struct pci_dev *pdev = skge->hw->pdev;
-	int cap = pci_find_capability(pdev, PCI_CAP_ID_VPD);
-	int length = eeprom->len;
-	u16 offset = eeprom->offset;
-
-	if (!cap)
-		return -EINVAL;
-
-	eeprom->magic = SKGE_EEPROM_MAGIC;
-
-	while (length > 0) {
-		u32 val = skge_vpd_read(pdev, cap, offset);
-		int n = min_t(int, length, sizeof(val));
-
-		memcpy(data, &val, n);
-		length -= n;
-		data += n;
-		offset += n;
-	}
-	return 0;
-}
-
-static int skge_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
-			   u8 *data)
-{
-	struct skge_port *skge = netdev_priv(dev);
-	struct pci_dev *pdev = skge->hw->pdev;
-	int cap = pci_find_capability(pdev, PCI_CAP_ID_VPD);
-	int length = eeprom->len;
-	u16 offset = eeprom->offset;
-
-	if (!cap)
-		return -EINVAL;
-
-	if (eeprom->magic != SKGE_EEPROM_MAGIC)
-		return -EINVAL;
-
-	while (length > 0) {
-		u32 val;
-		int n = min_t(int, length, sizeof(val));
-
-		if (n < sizeof(val))
-			val = skge_vpd_read(pdev, cap, offset);
-		memcpy(&val, data, n);
-
-		skge_vpd_write(pdev, cap, offset, val);
-
-		length -= n;
-		data += n;
-		offset += n;
-	}
-	return 0;
-}
-
 static const struct ethtool_ops skge_ethtool_ops = {
 	.get_settings	= skge_get_settings,
 	.set_settings	= skge_set_settings,
@@ -907,9 +812,6 @@ static const struct ethtool_ops skge_eth
 	.set_msglevel	= skge_set_msglevel,
 	.nway_reset	= skge_nway_reset,
 	.get_link	= ethtool_op_get_link,
-	.get_eeprom_len	= skge_get_eeprom_len,
-	.get_eeprom	= skge_get_eeprom,
-	.set_eeprom	= skge_set_eeprom,
 	.get_ringparam	= skge_get_ring_param,
 	.set_ringparam	= skge_set_ring_param,
 	.get_pauseparam = skge_get_pauseparam,

-- 

