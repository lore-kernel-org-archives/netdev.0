From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/7] skge: eeprom support
Date: Tue, 16 Oct 2007 12:15:53 -0700
Message-ID: <20071016191734.122065342@linux-foundation.org>
References: <20071016191548.447710749@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46597 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934758AbXJPTTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:19:39 -0400
Content-Disposition: inline; filename=skge-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ability to read/write EEPROM

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |   98 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/skge.h |    6 ++-
 2 files changed, 102 insertions(+), 2 deletions(-)

--- a/drivers/net/skge.c	2007-10-16 11:23:14.000000000 -0700
+++ b/drivers/net/skge.c	2007-10-16 11:23:17.000000000 -0700
@@ -59,6 +59,9 @@
 #define BLINK_MS		250
 #define LINK_HZ			HZ
 
+#define SKGE_EEPROM_MAGIC	0x9933aabb
+
+
 MODULE_DESCRIPTION("SysKonnect Gigabit Ethernet driver");
 MODULE_AUTHOR("Stephen Hemminger <shemminger@linux-foundation.org>");
 MODULE_LICENSE("GPL");
@@ -798,6 +801,98 @@ static int skge_phys_id(struct net_devic
 	return 0;
 }
 
+static int skge_get_eeprom_len(struct net_device *dev)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	u32 reg2;
+
+	pci_read_config_dword(skge->hw->pdev, PCI_DEV_REG2, &reg2);
+	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
+}
+
+static u32 skge_vpd_read(struct pci_dev *pdev, int cap, u16 offset)
+{
+	u32 val;
+
+	pci_write_config_word(pdev, cap + PCI_VPD_ADDR, offset);
+
+	do {
+		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
+	} while (!(offset & PCI_VPD_ADDR_F));
+
+	pci_read_config_dword(pdev, cap + PCI_VPD_DATA, &val);
+	return val;
+}
+
+static void skge_vpd_write(struct pci_dev *pdev, int cap, u16 offset, u32 val)
+{
+	pci_write_config_dword(pdev, cap + PCI_VPD_DATA, val);
+	pci_write_config_word(pdev, cap + PCI_VPD_ADDR,
+			      offset | PCI_VPD_ADDR_F);
+
+	do {
+		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
+	} while (offset & PCI_VPD_ADDR_F);
+}
+
+static int skge_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			   u8 *data)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	struct pci_dev *pdev = skge->hw->pdev;
+	int cap = pci_find_capability(pdev, PCI_CAP_ID_VPD);
+	int length = eeprom->len;
+	u16 offset = eeprom->offset;
+
+	if (!cap)
+		return -EINVAL;
+
+	eeprom->magic = SKGE_EEPROM_MAGIC;
+
+	while (length > 0) {
+		u32 val = skge_vpd_read(pdev, cap, offset);
+		int n = min_t(int, length, sizeof(val));
+
+		memcpy(data, &val, n);
+		length -= n;
+		data += n;
+		offset += n;
+	}
+	return 0;
+}
+
+static int skge_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			   u8 *data)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	struct pci_dev *pdev = skge->hw->pdev;
+	int cap = pci_find_capability(pdev, PCI_CAP_ID_VPD);
+	int length = eeprom->len;
+	u16 offset = eeprom->offset;
+
+	if (!cap)
+		return -EINVAL;
+
+	if (eeprom->magic != SKGE_EEPROM_MAGIC)
+		return -EINVAL;
+
+	while (length > 0) {
+		u32 val;
+		int n = min_t(int, length, sizeof(val));
+
+		if (n < sizeof(val))
+			val = skge_vpd_read(pdev, cap, offset);
+		memcpy(&val, data, n);
+
+		skge_vpd_write(pdev, cap, offset, val);
+
+		length -= n;
+		data += n;
+		offset += n;
+	}
+	return 0;
+}
+
 static const struct ethtool_ops skge_ethtool_ops = {
 	.get_settings	= skge_get_settings,
 	.set_settings	= skge_set_settings,
@@ -810,6 +905,9 @@ static const struct ethtool_ops skge_eth
 	.set_msglevel	= skge_set_msglevel,
 	.nway_reset	= skge_nway_reset,
 	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= skge_get_eeprom_len,
+	.get_eeprom	= skge_get_eeprom,
+	.set_eeprom	= skge_set_eeprom,
 	.get_ringparam	= skge_get_ring_param,
 	.set_ringparam	= skge_set_ring_param,
 	.get_pauseparam = skge_get_pauseparam,
--- a/drivers/net/skge.h	2007-10-16 11:23:14.000000000 -0700
+++ b/drivers/net/skge.h	2007-10-16 11:23:17.000000000 -0700
@@ -1,5 +1,5 @@
 /*
- * Definitions for the new Marvell Yukon / SysKonenct driver.
+ * Definitions for the new Marvell Yukon / SysKonnect driver.
  */
 #ifndef _SKGE_H
 #define _SKGE_H
@@ -8,8 +8,10 @@
 #define PCI_DEV_REG1	0x40
 #define  PCI_PHY_COMA	0x8000000
 #define  PCI_VIO	0x2000000
+
 #define PCI_DEV_REG2	0x44
-#define  PCI_REV_DESC	 0x4
+#define  PCI_VPD_ROM_SZ	7L<<14	/* VPD ROM size 0=256, 1=512, ... */
+#define  PCI_REV_DESC	1<<2	/* Reverse Descriptor bytes */
 
 #define PCI_STATUS_ERROR_BITS (PCI_STATUS_DETECTED_PARITY | \
 			       PCI_STATUS_SIG_SYSTEM_ERROR | \

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

