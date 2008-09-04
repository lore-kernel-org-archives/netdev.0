From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/4] sky2: remove VPD eeprom
Date: Thu, 04 Sep 2008 13:56:43 -0700
Message-ID: <20080904205719.068563221@vyatta.com>
References: <20080904205636.130211321@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline; filename=sky2-no-eeprom.patch
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The VPD is not really the firmware EEPROM. The real EEPROM is behind
an SPI interface, that maybe supported in later version.
Programming the VPD through the ethtool interface doesn't work
(doesn't really change firmware). Now that the interesting bits are
available through the debug interface and raw data is available through sysfs,
the old interface can go.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2008-09-04 11:49:12.000000000 -0700
+++ b/drivers/net/sky2.c	2008-09-04 11:49:28.000000000 -0700
@@ -75,8 +75,6 @@
 #define NAPI_WEIGHT		64
 #define PHY_RETRIES		1000
 
-#define SKY2_EEPROM_MAGIC	0x9955aabb
-
 
 #define RING_NEXT(x,s)	(((x)+1) & ((s)-1))
 
@@ -3722,109 +3720,6 @@ static int sky2_set_tso(struct net_devic
 	return ethtool_op_set_tso(dev, data);
 }
 
-static int sky2_get_eeprom_len(struct net_device *dev)
-{
-	struct sky2_port *sky2 = netdev_priv(dev);
-	struct sky2_hw *hw = sky2->hw;
-	u16 reg2;
-
-	reg2 = sky2_pci_read16(hw, PCI_DEV_REG2);
-	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
-}
-
-static int sky2_vpd_wait(const struct sky2_hw *hw, int cap, u16 busy)
-{
-	unsigned long start = jiffies;
-
-	while ( (sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F) == busy) {
-		/* Can take up to 10.6 ms for write */
-		if (time_after(jiffies, start + HZ/4)) {
-			dev_err(&hw->pdev->dev, PFX "VPD cycle timed out");
-			return -ETIMEDOUT;
-		}
-		mdelay(1);
-	}
-
-	return 0;
-}
-
-static int sky2_vpd_read(struct sky2_hw *hw, int cap, void *data,
-			 u16 offset, size_t length)
-{
-	int rc = 0;
-
-	while (length > 0) {
-		u32 val;
-
-		sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
-		rc = sky2_vpd_wait(hw, cap, 0);
-		if (rc)
-			break;
-
-		val = sky2_pci_read32(hw, cap + PCI_VPD_DATA);
-
-		memcpy(data, &val, min(sizeof(val), length));
-		offset += sizeof(u32);
-		data += sizeof(u32);
-		length -= sizeof(u32);
-	}
-
-	return rc;
-}
-
-static int sky2_vpd_write(struct sky2_hw *hw, int cap, const void *data,
-			  u16 offset, unsigned int length)
-{
-	unsigned int i;
-	int rc = 0;
-
-	for (i = 0; i < length; i += sizeof(u32)) {
-		u32 val = *(u32 *)(data + i);
-
-		sky2_pci_write32(hw, cap + PCI_VPD_DATA, val);
-		sky2_pci_write32(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
-
-		rc = sky2_vpd_wait(hw, cap, PCI_VPD_ADDR_F);
-		if (rc)
-			break;
-	}
-	return rc;
-}
-
-static int sky2_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
-			   u8 *data)
-{
-	struct sky2_port *sky2 = netdev_priv(dev);
-	int cap = pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
-
-	if (!cap)
-		return -EINVAL;
-
-	eeprom->magic = SKY2_EEPROM_MAGIC;
-
-	return sky2_vpd_read(sky2->hw, cap, data, eeprom->offset, eeprom->len);
-}
-
-static int sky2_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
-			   u8 *data)
-{
-	struct sky2_port *sky2 = netdev_priv(dev);
-	int cap = pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
-
-	if (!cap)
-		return -EINVAL;
-
-	if (eeprom->magic != SKY2_EEPROM_MAGIC)
-		return -EINVAL;
-
-	/* Partial writes not supported */
-	if ((eeprom->offset & 3) || (eeprom->len & 3))
-		return -EINVAL;
-
-	return sky2_vpd_write(sky2->hw, cap, data, eeprom->offset, eeprom->len);
-}
-
-
 static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_settings	= sky2_get_settings,
 	.set_settings	= sky2_set_settings,
@@ -3837,9 +3732,6 @@ static const struct ethtool_ops sky2_eth
 	.get_regs_len	= sky2_get_regs_len,
 	.get_regs	= sky2_get_regs,
 	.get_link	= ethtool_op_get_link,
-	.get_eeprom_len	= sky2_get_eeprom_len,
-	.get_eeprom	= sky2_get_eeprom,
-	.set_eeprom	= sky2_set_eeprom,
 	.get_sg		= ethtool_op_get_sg,
 	.set_sg 	= ethtool_op_set_sg,
 	.get_tx_csum	= ethtool_op_get_tx_csum,

-- 
