From: ganesh.venkatesan@intel.com
Subject: [PATCH 1/12 2.5] e1000 - ethtool support (register dump, interrupt
 test, cleanup)
Date: Thu, 29 Jul 2004 08:31:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290754570.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_ethtool.c linux-2.5/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.5/drivers/net/e1000/e1000_ethtool.c	2004-07-28 21:50:08.576475768 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_ethtool.c	2004-07-28 21:50:09.395351280 -0700
@@ -88,9 +88,9 @@ static const struct e1000_stats e1000_gs
 	{ "rx_flow_control_xoff", E1000_STAT(stats.xoffrxc) },
 	{ "tx_flow_control_xon", E1000_STAT(stats.xontxc) },
 	{ "tx_flow_control_xoff", E1000_STAT(stats.xofftxc) },
+	{ "rx_long_byte_count", E1000_STAT(stats.gorcl) },
 	{ "rx_csum_offload_good", E1000_STAT(hw_csum_good) },
-        { "rx_csum_offload_errors", E1000_STAT(hw_csum_err) },
-	{ "rx_long_byte_count", E1000_STAT(stats.gorcl) }
+	{ "rx_csum_offload_errors", E1000_STAT(hw_csum_err) }
 };
 #define E1000_STATS_LEN	\
 	sizeof(e1000_gstrings_stats) / sizeof(struct e1000_stats)
@@ -170,7 +170,8 @@ e1000_get_settings(struct net_device *ne
 		ecmd->duplex = -1;
 	}
 
-	ecmd->autoneg = (hw->autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
+	ecmd->autoneg = ((hw->media_type == e1000_media_type_fiber) ||
+			 hw->autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -192,6 +193,7 @@ e1000_set_settings(struct net_device *ne
 
 	if(netif_running(adapter->netdev)) {
 		e1000_down(adapter);
+		e1000_reset(adapter);
 		e1000_up(adapter);
 	} else
 		e1000_reset(adapter);
@@ -199,12 +201,13 @@ e1000_set_settings(struct net_device *ne
 	return 0;
 }
 
-static void 
+static void
 e1000_get_pauseparam(struct net_device *netdev,
-                    struct ethtool_pauseparam *pause)
+                     struct ethtool_pauseparam *pause)
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	struct e1000_hw *hw = &adapter->hw;
+
 	pause->autoneg = 
 		(adapter->fc_autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
 	
@@ -218,9 +221,9 @@ e1000_get_pauseparam(struct net_device *
 	}
 }
 
-static int 
+static int
 e1000_set_pauseparam(struct net_device *netdev,
-                    struct ethtool_pauseparam *pause)
+                     struct ethtool_pauseparam *pause)
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	struct e1000_hw *hw = &adapter->hw;
@@ -271,7 +274,7 @@ e1000_set_rx_csum(struct net_device *net
 		e1000_reset(adapter);
 	return 0;
 }
-
+	
 static uint32_t
 e1000_get_tx_csum(struct net_device *netdev)
 {
@@ -337,7 +340,7 @@ e1000_get_regs_len(struct net_device *ne
 
 static void
 e1000_get_regs(struct net_device *netdev,
-                    struct ethtool_regs *regs, void *p)
+	       struct ethtool_regs *regs, void *p)
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	struct e1000_hw *hw = &adapter->hw;
@@ -418,6 +421,10 @@ e1000_get_regs(struct net_device *netdev
 	e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data);
 	regs_buff[24] = (uint32_t)phy_data;  /* phy local receiver status */
 	regs_buff[25] = regs_buff[24];  /* phy remote receiver status */
+	if(hw->mac_type >= e1000_82540 &&
+	   hw->media_type == e1000_media_type_copper) {
+		regs_buff[26] = E1000_READ_REG(hw, MANC);
+	}
 }
 
 static int
@@ -438,7 +445,7 @@ e1000_get_eeprom(struct net_device *netd
 	int ret_val = 0;
 	uint16_t i;
 
-	if(eeprom->len == 0) 
+	if(eeprom->len == 0)
 		return -EINVAL;
 
 	eeprom->magic = hw->vendor_id | (hw->device_id << 16);
@@ -446,9 +453,9 @@ e1000_get_eeprom(struct net_device *netd
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(uint16_t) * 
+	eeprom_buff = kmalloc(sizeof(uint16_t) *
 			(last_word - first_word + 1), GFP_KERNEL);
-	if (!eeprom_buff)
+	if(!eeprom_buff)
 		return -ENOMEM;
 
 	if(hw->eeprom.type == e1000_eeprom_spi)
@@ -466,9 +473,8 @@ e1000_get_eeprom(struct net_device *netd
 	for (i = 0; i < last_word - first_word + 1; i++)
 		le16_to_cpus(&eeprom_buff[i]);
 
-
-	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset%2), 
-				eeprom->len);
+	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset & 1),
+			eeprom->len);
 	kfree(eeprom_buff);
 
 	return ret_val;
@@ -520,6 +526,7 @@ e1000_set_eeprom(struct net_device *netd
 		le16_to_cpus(&eeprom_buff[i]);
 
 	memcpy(ptr, bytes, eeprom->len);
+
 	for (i = 0; i < last_word - first_word + 1; i++)
 		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
 
@@ -575,17 +582,16 @@ static int 
 e1000_set_ringparam(struct net_device *netdev,
                     struct ethtool_ringparam *ring)
 {
-	int err;
 	struct e1000_adapter *adapter = netdev->priv;
 	e1000_mac_type mac_type = adapter->hw.mac_type;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
 	struct e1000_desc_ring *rxdr = &adapter->rx_ring;
-	struct e1000_desc_ring tx_old, tx_new;
-	struct e1000_desc_ring rx_old, rx_new;
+	struct e1000_desc_ring tx_old, tx_new, rx_old, rx_new;
+	int err;
 
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
-	
+
 	if(netif_running(adapter->netdev))
 		e1000_down(adapter);
 
@@ -600,15 +606,15 @@ e1000_set_ringparam(struct net_device *n
 	E1000_ROUNDUP(txdr->count, REQ_TX_DESCRIPTOR_MULTIPLE); 
 
 	if(netif_running(adapter->netdev)) {
-		/* try to get new resources before deleting old */
+		/* Try to get new resources before deleting old */
 		if((err = e1000_setup_rx_resources(adapter)))
 			goto err_setup_rx;
 		if((err = e1000_setup_tx_resources(adapter)))
 			goto err_setup_tx;
 
 		/* save the new, restore the old in order to free it,
-		 * then restore the new back again */	
-	
+		 * then restore the new back again */
+
 		rx_new = adapter->rx_ring;
 		tx_new = adapter->tx_ring;
 		adapter->rx_ring = rx_old;
@@ -620,6 +626,7 @@ e1000_set_ringparam(struct net_device *n
 		if((err = e1000_up(adapter)))
 			return err;
 	}
+
 	return 0;
 err_setup_tx:
 	e1000_free_rx_resources(adapter);
@@ -766,13 +773,15 @@ static int
 e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint32_t icr, mask, i=0;
+ 	uint32_t icr, mask, i=0, shared_int = TRUE;
+ 	uint32_t irq = adapter->pdev->irq;
 
 	*data = 0;
 
 	/* Hook up test interrupt handler just for this test */
-	if(request_irq(adapter->pdev->irq, &e1000_test_intr, SA_SHIRQ,
-	   netdev->name, netdev)) {
+ 	if(!request_irq(irq, &e1000_test_intr, 0, netdev->name, netdev)) {
+ 		shared_int = FALSE;
+ 	} else if(request_irq(irq, &e1000_test_intr, SA_SHIRQ, netdev->name, netdev)){
 		*data = 1;
 		return -1;
 	}
@@ -802,20 +811,22 @@ e1000_intr_test(struct e1000_adapter *ad
 		/* Interrupt to test */
 		mask = 1 << i;
 
-		/* Disable the interrupt to be reported in
-		 * the cause register and then force the same
-		 * interrupt and see if one gets posted.  If
-		 * an interrupt was posted to the bus, the
-		 * test failed.
-		 */
-		adapter->test_icr = 0;
-		E1000_WRITE_REG(&adapter->hw, IMC, mask);
-		E1000_WRITE_REG(&adapter->hw, ICS, mask);
-		msec_delay(10);
-
-		if(adapter->test_icr & mask) {
-			*data = 3;
-			break;
+ 		if(!shared_int) {
+ 			/* Disable the interrupt to be reported in
+ 			 * the cause register and then force the same
+ 			 * interrupt and see if one gets posted.  If
+ 			 * an interrupt was posted to the bus, the
+ 			 * test failed.
+ 			 */
+ 			adapter->test_icr = 0;
+ 			E1000_WRITE_REG(&adapter->hw, IMC, mask);
+ 			E1000_WRITE_REG(&adapter->hw, ICS, mask);
+ 			msec_delay(10);
+ 
+ 			if(adapter->test_icr & mask) {
+ 				*data = 3;
+ 				break;
+ 			}
 		}
 
 		/* Enable the interrupt to be reported in
@@ -834,20 +845,22 @@ e1000_intr_test(struct e1000_adapter *ad
 			break;
 		}
 
-		/* Disable the other interrupts to be reported in
-		 * the cause register and then force the other
-		 * interrupts and see if any get posted.  If
-		 * an interrupt was posted to the bus, the
-		 * test failed.
-		 */
-		adapter->test_icr = 0;
-		E1000_WRITE_REG(&adapter->hw, IMC, ~mask);
-		E1000_WRITE_REG(&adapter->hw, ICS, ~mask);
-		msec_delay(10);
+ 		if(!shared_int) {
+			/* Disable the other interrupts to be reported in
+			 * the cause register and then force the other
+			 * interrupts and see if any get posted.  If
+			 * an interrupt was posted to the bus, the
+			 * test failed.
+			 */
+			adapter->test_icr = 0;
+			E1000_WRITE_REG(&adapter->hw, IMC, ~mask);
+			E1000_WRITE_REG(&adapter->hw, ICS, ~mask);
+			msec_delay(10);
 
-		if(adapter->test_icr) {
-			*data = 5;
-			break;
+			if(adapter->test_icr) {
+				*data = 5;
+				break;
+			}
 		}
 	}
 
@@ -856,7 +869,7 @@ e1000_intr_test(struct e1000_adapter *ad
 	msec_delay(10);
 
 	/* Unhook test interrupt handler */
-	free_irq(adapter->pdev->irq, netdev);
+	free_irq(irq, netdev);
 
 	return *data;
 }
@@ -1021,7 +1034,7 @@ e1000_setup_desc_rings(struct e1000_adap
 
 	return 0;
 
-      err_nomem:
+err_nomem:
 	e1000_free_desc_rings(adapter);
 	return ret_val;
 }
@@ -1357,7 +1370,7 @@ e1000_diag_test_count(struct net_device 
 }
 
 static void
-e1000_diag_test(struct net_device *netdev, 
+e1000_diag_test(struct net_device *netdev,
 		   struct ethtool_test *eth_test, uint64_t *data)
 {
 	struct e1000_adapter *adapter = netdev->priv;
@@ -1368,7 +1381,7 @@ e1000_diag_test(struct net_device *netde
 
 		/* save speed, duplex, autoneg settings */
 		uint16_t autoneg_advertised = adapter->hw.autoneg_advertised;
-    		uint8_t forced_speed_duplex = adapter->hw.forced_speed_duplex;
+		uint8_t forced_speed_duplex = adapter->hw.forced_speed_duplex;
 		uint8_t autoneg = adapter->hw.autoneg;
 
 		/* Link test performed before hardware reset so autoneg doesn't
@@ -1396,10 +1409,11 @@ e1000_diag_test(struct net_device *netde
 		if(e1000_loopback_test(adapter, &data[3]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		/* restore Autoneg/speed/duplex settings */
+		/* restore speed, duplex, autoneg settings */
 		adapter->hw.autoneg_advertised = autoneg_advertised;
-    		adapter->hw.forced_speed_duplex = forced_speed_duplex;
-    		adapter->hw.autoneg = autoneg;
+		adapter->hw.forced_speed_duplex = forced_speed_duplex;
+		adapter->hw.autoneg = autoneg;
+
 		e1000_reset(adapter);
 		if(if_running)
 			e1000_up(adapter);
@@ -1427,6 +1441,7 @@ e1000_get_wol(struct net_device *netdev,
 	case E1000_DEV_ID_82543GC_FIBER:
 	case E1000_DEV_ID_82543GC_COPPER:
 	case E1000_DEV_ID_82544EI_FIBER:
+	case E1000_DEV_ID_82546EB_QUAD_COPPER:
 		wol->supported = 0;
 		wol->wolopts   = 0;
 		return;
@@ -1469,6 +1484,7 @@ e1000_set_wol(struct net_device *netdev,
 	case E1000_DEV_ID_82543GC_FIBER:
 	case E1000_DEV_ID_82543GC_COPPER:
 	case E1000_DEV_ID_82544EI_FIBER:
+	case E1000_DEV_ID_82546EB_QUAD_COPPER:
 		return wol->wolopts ? -EOPNOTSUPP : 0;
 
 	case E1000_DEV_ID_82546EB_FIBER:
@@ -1571,8 +1587,8 @@ e1000_get_ethtool_stats(struct net_devic
 	e1000_update_stats(adapter);
 	for(i = 0; i < E1000_STATS_LEN; i++) {
 		char *p = (char *)adapter+e1000_gstrings_stats[i].stat_offset;	
-		data[i] = (e1000_gstrings_stats[i].sizeof_stat == sizeof(uint64_t)) 
-			? *(uint64_t *)p : *(uint32_t *)p;
+		data[i] = (e1000_gstrings_stats[i].sizeof_stat == 
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
 	}
 }
 
