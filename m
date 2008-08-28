From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] sky2: EEPROM read/write bug fixes
Date: Wed, 27 Aug 2008 20:46:26 -0700
Message-ID: <20080827204626.4b65862f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57342 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755171AbYH1Dsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 23:48:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup and harden the routines accessing the EEPROM.
  1. Prevent spin forever waiting for the TWSI bus
  2. Fix write eeprom to write full words rather than only 16 bits 
    Luckly the vendor doesn't provide EEPROM in Linux format so it must never
    have been used.
  3. Don't allow partial eeprom writes, not needed, not safe.

These are non-urgent bug fixes.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2008-08-27 19:15:52.000000000 -0700
+++ b/drivers/net/sky2.c	2008-08-27 19:21:13.000000000 -0700
@@ -3732,27 +3732,63 @@ static int sky2_get_eeprom_len(struct ne
 	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
 }
 
-static u32 sky2_vpd_read(struct sky2_hw *hw, int cap, u16 offset)
+static int sky2_vpd_wait(const struct sky2_hw *hw, int cap, u16 busy)
 {
-	u32 val;
+	unsigned long start = jiffies;
 
-	sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
+	while ( (sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F) == busy) {
+		/* Can take up to 10.6 ms for write */
+		if (time_after(jiffies, start + HZ/4)) {
+			dev_err(&hw->pdev->dev, PFX "VPD cycle timed out");
+			return -ETIMEDOUT;
+		}
+		mdelay(1);
+	}
+
+	return 0;
+}
 
-	do {
-		offset = sky2_pci_read16(hw, cap + PCI_VPD_ADDR);
-	} while (!(offset & PCI_VPD_ADDR_F));
+static int sky2_vpd_read(struct sky2_hw *hw, int cap, void *data,
+			 u16 offset, size_t length)
+{
+	int rc = 0;
 
-	val = sky2_pci_read32(hw, cap + PCI_VPD_DATA);
-	return val;
+	while (length > 0) {
+		u32 val;
+
+		sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
+		rc = sky2_vpd_wait(hw, cap, 0);
+		if (rc)
+			break;
+
+		val = sky2_pci_read32(hw, cap + PCI_VPD_DATA);
+
+		memcpy(data, &val, min(sizeof(val), length));
+		offset += sizeof(u32);
+		data += sizeof(u32);
+		length -= sizeof(u32);
+	}
+
+	return rc;
 }
 
-static void sky2_vpd_write(struct sky2_hw *hw, int cap, u16 offset, u32 val)
+static int sky2_vpd_write(struct sky2_hw *hw, int cap, const void *data,
+			  u16 offset, unsigned int length)
 {
-	sky2_pci_write16(hw, cap + PCI_VPD_DATA, val);
-	sky2_pci_write32(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
-	do {
-		offset = sky2_pci_read16(hw, cap + PCI_VPD_ADDR);
-	} while (offset & PCI_VPD_ADDR_F);
+	unsigned int i;
+	int rc = 0;
+
+	for (i = 0; i < length; i += sizeof(u32)) {
+		u32 val = *(u32 *)(data + i);
+
+		sky2_pci_write32(hw, cap + PCI_VPD_DATA, val);
+		sky2_pci_write32(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
+
+		rc = sky2_vpd_wait(hw, cap, PCI_VPD_ADDR_F);
+		if (rc)
+			break;
+	}
+	return rc;
 }
 
 static int sky2_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
@@ -3760,24 +3796,13 @@ static int sky2_get_eeprom(struct net_de
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	int cap = pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
-	int length = eeprom->len;
-	u16 offset = eeprom->offset;
 
 	if (!cap)
 		return -EINVAL;
 
 	eeprom->magic = SKY2_EEPROM_MAGIC;
 
-	while (length > 0) {
-		u32 val = sky2_vpd_read(sky2->hw, cap, offset);
-		int n = min_t(int, length, sizeof(val));
-
-		memcpy(data, &val, n);
-		length -= n;
-		data += n;
-		offset += n;
-	}
-	return 0;
+	return sky2_vpd_read(sky2->hw, cap, data, eeprom->offset, eeprom->len);
 }
 
 static int sky2_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
@@ -3785,8 +3810,6 @@ static int sky2_set_eeprom(struct net_de
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	int cap = pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
-	int length = eeprom->len;
-	u16 offset = eeprom->offset;
 
 	if (!cap)
 		return -EINVAL;
@@ -3794,21 +3817,11 @@ static int sky2_set_eeprom(struct net_de
 	if (eeprom->magic != SKY2_EEPROM_MAGIC)
 		return -EINVAL;
 
-	while (length > 0) {
-		u32 val;
-		int n = min_t(int, length, sizeof(val));
-
-		if (n < sizeof(val))
-			val = sky2_vpd_read(sky2->hw, cap, offset);
-		memcpy(&val, data, n);
-
-		sky2_vpd_write(sky2->hw, cap, offset, val);
+	/* Partial writes not supported */
+	if ((eeprom->offset & 3) || (eeprom->len & 3))
+		return -EINVAL;
 
-		length -= n;
-		data += n;
-		offset += n;
-	}
-	return 0;
+	return sky2_vpd_write(sky2->hw, cap, data, eeprom->offset, eeprom->len);
 }
 
 
