From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 07/12] sky2: add support for read/write of EEPROM
Date: Mon, 09 Jul 2007 15:33:39 -0700
Message-ID: <20070709223453.418635581@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60710 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755956AbXGIWhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:37:24 -0400
Content-Disposition: inline; filename=sky2-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add get/set eeprom support for sky2.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |  140 +++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 115 insertions(+), 25 deletions(-)

--- a/drivers/net/sky2.c	2007-07-09 15:30:10.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:12.000000000 -0700
@@ -77,6 +77,9 @@
 #define NAPI_WEIGHT		64
 #define PHY_RETRIES		1000
 
+#define SKY2_EEPROM_MAGIC	0x9955aabb
+
+
 #define RING_NEXT(x,s)	(((x)+1) & ((s)-1))
 
 static const u32 default_msg =
@@ -3429,34 +3432,121 @@ static int sky2_set_tso(struct net_devic
 	return ethtool_op_set_tso(dev, data);
 }
 
+static int sky2_get_eeprom_len(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	u16 reg2;
+
+	reg2 = sky2_pci_read32(sky2->hw, PCI_DEV_REG2);
+	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
+}
+
+static u32 sky2_vpd_read(struct sky2_hw *hw, int cap, u16 offset)
+{
+	sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
+
+	while (!(sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F))
+			cpu_relax();
+	return sky2_pci_read32(hw, cap + PCI_VPD_DATA);
+}
+
+static void sky2_vpd_write(struct sky2_hw *hw, int cap, u16 offset, u32 val)
+{
+	sky2_pci_write32(hw, cap + PCI_VPD_DATA, val);
+	sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
+	do {
+		cpu_relax();
+	} while (sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F);
+}
+
+static int sky2_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			   u8 *data)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	int cap = pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
+	int length = eeprom->len;
+	u16 offset = eeprom->offset;
+
+	if (!cap)
+		return -EINVAL;
+
+	eeprom->magic = SKY2_EEPROM_MAGIC;
+
+	while (length > 0) {
+		u32 val = sky2_vpd_read(sky2->hw, cap, offset);
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
+static int sky2_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			   u8 *data)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	int cap = pci_find_capability(sky2->hw->pdev, PCI_CAP_ID_VPD);
+	int length = eeprom->len;
+	u16 offset = eeprom->offset;
+
+	if (!cap)
+		return -EINVAL;
+
+	if (eeprom->magic != SKY2_EEPROM_MAGIC)
+		return -EINVAL;
+
+	while (length > 0) {
+		u32 val;
+		int n = min_t(int, length, sizeof(val));
+
+		if (n < sizeof(val))
+			val = sky2_vpd_read(sky2->hw, cap, offset);
+		memcpy(&val, data, n);
+
+		sky2_vpd_write(sky2->hw, cap, offset, val);
+
+		length -= n;
+		data += n;
+		offset += n;
+	}
+	return 0;
+}
+
+
 static const struct ethtool_ops sky2_ethtool_ops = {
-	.get_settings = sky2_get_settings,
-	.set_settings = sky2_set_settings,
-	.get_drvinfo  = sky2_get_drvinfo,
-	.get_wol      = sky2_get_wol,
-	.set_wol      = sky2_set_wol,
-	.get_msglevel = sky2_get_msglevel,
-	.set_msglevel = sky2_set_msglevel,
-	.nway_reset   = sky2_nway_reset,
-	.get_regs_len = sky2_get_regs_len,
-	.get_regs = sky2_get_regs,
-	.get_link = ethtool_op_get_link,
-	.get_sg = ethtool_op_get_sg,
-	.set_sg = ethtool_op_set_sg,
-	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = sky2_set_tx_csum,
-	.get_tso = ethtool_op_get_tso,
-	.set_tso = sky2_set_tso,
-	.get_rx_csum = sky2_get_rx_csum,
-	.set_rx_csum = sky2_set_rx_csum,
-	.get_strings = sky2_get_strings,
-	.get_coalesce = sky2_get_coalesce,
-	.set_coalesce = sky2_set_coalesce,
-	.get_ringparam = sky2_get_ringparam,
-	.set_ringparam = sky2_set_ringparam,
+	.get_settings	= sky2_get_settings,
+	.set_settings	= sky2_set_settings,
+	.get_drvinfo	= sky2_get_drvinfo,
+	.get_wol	= sky2_get_wol,
+	.set_wol	= sky2_set_wol,
+	.get_msglevel	= sky2_get_msglevel,
+	.set_msglevel	= sky2_set_msglevel,
+	.nway_reset	= sky2_nway_reset,
+	.get_regs_len	= sky2_get_regs_len,
+	.get_regs	= sky2_get_regs,
+	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= sky2_get_eeprom_len,
+	.get_eeprom	= sky2_get_eeprom,
+	.set_eeprom	= sky2_set_eeprom,
+	.get_sg 	= ethtool_op_get_sg,
+	.set_sg 	= ethtool_op_set_sg,
+	.get_tx_csum	= ethtool_op_get_tx_csum,
+	.set_tx_csum	= sky2_set_tx_csum,
+	.get_tso	= ethtool_op_get_tso,
+	.set_tso	= sky2_set_tso,
+	.get_rx_csum	= sky2_get_rx_csum,
+	.set_rx_csum	= sky2_set_rx_csum,
+	.get_strings	= sky2_get_strings,
+	.get_coalesce	= sky2_get_coalesce,
+	.set_coalesce	= sky2_set_coalesce,
+	.get_ringparam	= sky2_get_ringparam,
+	.set_ringparam	= sky2_set_ringparam,
 	.get_pauseparam = sky2_get_pauseparam,
 	.set_pauseparam = sky2_set_pauseparam,
-	.phys_id = sky2_phys_id,
+	.phys_id	= sky2_phys_id,
 	.get_stats_count = sky2_get_stats_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
 	.get_perm_addr	= ethtool_op_get_perm_addr,

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

