From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 01/11] ixgbe: Add FCoE Storage MAC Address support
Date: Sun, 17 May 2009 15:32:25 -0700
Message-ID: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:54392 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754743AbZEQWcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 18:32:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch implements the Storage Address entrypoint from the net device.
It will read the SAN MAC addresses from the EEPROM of the 82599 hardware,
and make them available to the FCoE stack through the net device.

Also, add/del the SAN MAC address to the netdev dev_addr_list via the
kernel api dev_addr_add()/dev_addr_del() when there is a valid SAN MAC
supported by the HW.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   73 +++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c  |   48 ++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_type.h  |    5 +++
 3 files changed, 126 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 23be4db..6bc964f 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -819,6 +819,9 @@ s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 	/* Store the permanent mac address */
 	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
+	/* Store the permanent SAN mac address */
+	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
+
 reset_hw_out:
 	return status;
 }
@@ -1294,6 +1297,75 @@ s32 ixgbe_get_device_caps_82599(struct ixgbe_hw *hw, u16 *device_caps)
 	return 0;
 }
 
+/**
+ *  ixgbe_get_san_mac_addr_offset_82599 - SAN MAC address offset for 82599
+ *  @hw: pointer to hardware structure
+ *  @san_mac_offset: SAN MAC address offset
+ *
+ *  This function will read the EEPROM location for the SAN MAC address
+ *  pointer, and returns the value at that location.  This is used in both
+ *  get and set mac_addr routines.
+ **/
+s32 ixgbe_get_san_mac_addr_offset_82599(struct ixgbe_hw *hw,
+                                        u16 *san_mac_offset)
+{
+	/*
+	 * First read the EEPROM pointer to see if the MAC addresses are
+	 * available.
+	 */
+	hw->eeprom.ops.read(hw, IXGBE_SAN_MAC_ADDR_PTR, san_mac_offset);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_get_san_mac_addr_82599 - SAN MAC address retrieval for 82599
+ *  @hw: pointer to hardware structure
+ *  @san_mac_addr: SAN MAC address
+ *
+ *  Reads the SAN MAC address from the EEPROM, if it's available.  This is
+ *  per-port, so set_lan_id() must be called before reading the addresses.
+ *  set_lan_id() is called by identify_sfp(), but this cannot be relied
+ *  upon for non-SFP connections, so we must call it here.
+ **/
+s32 ixgbe_get_san_mac_addr_82599(struct ixgbe_hw *hw, u8 *san_mac_addr)
+{
+	u16 san_mac_data, san_mac_offset;
+	u8 i;
+
+	/*
+	 * First read the EEPROM pointer to see if the MAC addresses are
+	 * available.  If they're not, no point in calling set_lan_id() here.
+	 */
+	ixgbe_get_san_mac_addr_offset_82599(hw, &san_mac_offset);
+
+	if ((san_mac_offset == 0) || (san_mac_offset == 0xFFFF)) {
+		/*
+		 * No addresses available in this EEPROM.  It's not an
+		 * error though, so just wipe the local address and return.
+		 */
+		for (i = 0; i < 6; i++)
+			san_mac_addr[i] = 0xFF;
+
+		goto san_mac_addr_out;
+	}
+
+	/* make sure we know which port we need to program */
+	hw->mac.ops.set_lan_id(hw);
+	/* apply the port offset to the address offset */
+	(hw->bus.func) ? (san_mac_offset += IXGBE_SAN_MAC_ADDR_PORT1_OFFSET) :
+	                 (san_mac_offset += IXGBE_SAN_MAC_ADDR_PORT0_OFFSET);
+	for (i = 0; i < 3; i++) {
+		hw->eeprom.ops.read(hw, san_mac_offset, &san_mac_data);
+		san_mac_addr[i * 2] = (u8)(san_mac_data);
+		san_mac_addr[i * 2 + 1] = (u8)(san_mac_data >> 8);
+		san_mac_offset++;
+	}
+
+san_mac_addr_out:
+	return 0;
+}
+
 static struct ixgbe_mac_operations mac_ops_82599 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_82599,
@@ -1303,6 +1375,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.get_supported_physical_layer = &ixgbe_get_supported_physical_layer_82599,
 	.enable_rx_dma          = &ixgbe_enable_rx_dma_82599,
 	.get_mac_addr           = &ixgbe_get_mac_addr_generic,
+	.get_san_mac_addr       = &ixgbe_get_san_mac_addr_82599,
 	.get_device_caps        = &ixgbe_get_device_caps_82599,
 	.stop_adapter           = &ixgbe_stop_adapter_generic,
 	.get_bus_info           = &ixgbe_get_bus_info_generic,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d69a052..fe0ac8b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4799,6 +4799,48 @@ static int ixgbe_ioctl(struct net_device *netdev, struct ifreq *req, int cmd)
 	return mdio_mii_ioctl(&adapter->hw.phy.mdio, if_mii(req), cmd);
 }
 
+/**
+ * ixgbe_add_sanmac_netdev - Add the SAN MAC address to the corresponding
+ * netdev->dev_addr_list
+ * @netdev: network interface device structure
+ *
+ * Returns non-zero on failure
+ **/
+static int ixgbe_add_sanmac_netdev(struct net_device *dev)
+{
+	int err = 0;
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_mac_info *mac = &adapter->hw.mac;
+
+	if (is_valid_ether_addr(mac->san_addr)) {
+		rtnl_lock();
+		err = dev_addr_add(dev, mac->san_addr, NETDEV_HW_ADDR_T_SAN);
+		rtnl_unlock();
+	}
+	return err;
+}
+
+/**
+ * ixgbe_del_sanmac_netdev - Removes the SAN MAC address to the corresponding
+ * netdev->dev_addr_list
+ * @netdev: network interface device structure
+ *
+ * Returns non-zero on failure
+ **/
+static int ixgbe_del_sanmac_netdev(struct net_device *dev)
+{
+	int err = 0;
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_mac_info *mac = &adapter->hw.mac;
+
+	if (is_valid_ether_addr(mac->san_addr)) {
+		rtnl_lock();
+		err = dev_addr_del(dev, mac->san_addr, NETDEV_HW_ADDR_T_SAN);
+		rtnl_unlock();
+	}
+	return err;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
@@ -5159,6 +5201,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		ixgbe_setup_dca(adapter);
 	}
 #endif
+	/* add san mac addr to netdev */
+	ixgbe_add_sanmac_netdev(netdev);
 
 	dev_info(&pdev->dev, "Intel(R) 10 Gigabit Network Connection\n");
 	cards_found++;
@@ -5229,6 +5273,10 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 		ixgbe_cleanup_fcoe(adapter);
 
 #endif /* IXGBE_FCOE */
+
+	/* remove the added san mac */
+	ixgbe_del_sanmac_netdev(netdev);
+
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 38f835d..cb73b30 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1439,6 +1439,7 @@
 #define IXGBE_PBANUM0_PTR       0x15
 #define IXGBE_PBANUM1_PTR       0x16
 #define IXGBE_DEVICE_CAPS       0x2C
+#define IXGBE_SAN_MAC_ADDR_PTR  0x28
 #define IXGBE_PCIE_MSIX_82599_CAPS  0x72
 #define IXGBE_PCIE_MSIX_82598_CAPS  0x62
 
@@ -1482,6 +1483,8 @@
 #define IXGBE_EERD_ATTEMPTS 100000
 #endif
 
+#define IXGBE_SAN_MAC_ADDR_PORT0_OFFSET  0x0
+#define IXGBE_SAN_MAC_ADDR_PORT1_OFFSET  0x3
 #define IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP  0x1
 #define IXGBE_DEVICE_CAPS_FCOE_OFFLOADS  0x2
 
@@ -2189,6 +2192,7 @@ struct ixgbe_mac_operations {
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
 	u32 (*get_supported_physical_layer)(struct ixgbe_hw *);
 	s32 (*get_mac_addr)(struct ixgbe_hw *, u8 *);
+	s32 (*get_san_mac_addr)(struct ixgbe_hw *, u8 *);
 	s32 (*get_device_caps)(struct ixgbe_hw *, u16 *);
 	s32 (*stop_adapter)(struct ixgbe_hw *);
 	s32 (*get_bus_info)(struct ixgbe_hw *);
@@ -2263,6 +2267,7 @@ struct ixgbe_mac_info {
 	enum ixgbe_mac_type             type;
 	u8                              addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
 	u8                              perm_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
+	u8                              san_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
 	s32                             mc_filter_type;
 	u32                             mcft_size;
 	u32                             vft_size;

