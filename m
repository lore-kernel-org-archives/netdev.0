From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 5/11] add ethtool flow control support
Date: Mon, 8 Sep 2003 20:14:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081942300.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Add ethtool flow control support

---------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_ethtool.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_ethtool.c	2003-08-22 16:55:33.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_ethtool.c	2003-09-08 09:13:10.000000000 -0700
@@ -190,6 +190,55 @@ e1000_ethtool_sset(struct e1000_adapter 
 	return 0;
 }
 
+static int
+e1000_ethtool_gpause(struct e1000_adapter *adapter,
+                     struct ethtool_pauseparam *epause)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	
+	epause->autoneg = 
+		(adapter->fc_autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
+	
+	if(hw->fc == e1000_fc_rx_pause)
+		epause->rx_pause = 1;
+	else if(hw->fc == e1000_fc_tx_pause)
+		epause->tx_pause = 1;
+	else if(hw->fc == e1000_fc_full) {
+		epause->rx_pause = 1;
+		epause->tx_pause = 1;
+	}
+	
+	return 0;
+}
+
+static int
+e1000_ethtool_spause(struct e1000_adapter *adapter,
+                     struct ethtool_pauseparam *epause)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	
+	adapter->fc_autoneg = epause->autoneg;
+
+	if(epause->rx_pause && epause->tx_pause)
+		hw->fc = e1000_fc_full;
+	else if(epause->rx_pause && !epause->tx_pause)
+		hw->fc = e1000_fc_rx_pause;
+	else if(!epause->rx_pause && epause->tx_pause)
+		hw->fc = e1000_fc_tx_pause;
+	else if(!epause->rx_pause && !epause->tx_pause)
+		hw->fc = e1000_fc_none;
+
+	hw->original_fc = hw->fc;
+
+	if(netif_running(adapter->netdev)) {
+		e1000_down(adapter);
+		e1000_up(adapter);
+	} else
+		e1000_reset(adapter);
+	
+	return 0;
+}
+
 static void
 e1000_ethtool_gdrvinfo(struct e1000_adapter *adapter,
                        struct ethtool_drvinfo *drvinfo)
@@ -1449,6 +1498,19 @@ err_geeprom_ioctl:
 		addr += offsetof(struct ethtool_eeprom, data);
 		return e1000_ethtool_seeprom(adapter, &eeprom, addr);
 	}
+	case ETHTOOL_GPAUSEPARAM: {
+		struct ethtool_pauseparam epause = {ETHTOOL_GPAUSEPARAM};
+		e1000_ethtool_gpause(adapter, &epause);
+		if(copy_to_user(addr, &epause, sizeof(epause)))
+			return -EFAULT;
+		return 0;
+	}
+	case ETHTOOL_SPAUSEPARAM: {
+		struct ethtool_pauseparam epause;
+		if(copy_from_user(&epause, addr, sizeof(epause)))
+			return -EFAULT;
+		return e1000_ethtool_spause(adapter, &epause);
+	}
 	case ETHTOOL_GSTATS: {
 		struct {
 			struct ethtool_stats eth_stats;
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000.h linux-2.6.0-test4/drivers/net/e1000.new/e1000.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000.h	2003-08-22 16:50:56.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000.h	2003-09-08 09:13:16.000000000 -0700
@@ -180,6 +180,7 @@ struct e1000_adapter {
 	spinlock_t stats_lock;
 	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
+    	uint8_t fc_autoneg;
 
 	struct timer_list blink_timer;
 	unsigned long led_status;
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c	2003-08-22 17:01:40.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c	2003-09-08 09:13:11.000000000 -0700
@@ -39,7 +39,6 @@
 static int32_t e1000_adjust_serdes_amplitude(struct e1000_hw *hw);
 static int32_t e1000_phy_force_speed_duplex(struct e1000_hw *hw);
 static int32_t e1000_config_mac_to_phy(struct e1000_hw *hw);
-static int32_t e1000_force_mac_fc(struct e1000_hw *hw);
 static void e1000_raise_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
 static void e1000_lower_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
 static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, uint32_t data, uint16_t count);
@@ -1629,7 +1629,7 @@ e1000_config_mac_to_phy(struct e1000_hw 
  * by the PHY rather than the MAC. Software must also configure these
  * bits when link is forced on a fiber connection.
  *****************************************************************************/
-static int32_t
+int32_t
 e1000_force_mac_fc(struct e1000_hw *hw)
 {
     uint32_t ctrl;
@@ -1682,7 +1681,7 @@ e1000_force_mac_fc(struct e1000_hw *hw)
         ctrl &= (~E1000_CTRL_TFCE);
 
     E1000_WRITE_REG(hw, CTRL, ctrl);
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.h linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.h	2003-08-22 16:58:59.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.h	2003-09-08 09:13:16.000000000 -0700
@@ -264,6 +264,7 @@ int32_t e1000_phy_setup_autoneg(struct e
 int32_t e1000_check_for_link(struct e1000_hw *hw);
 int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, uint16_t * speed, uint16_t * duplex);
 int32_t e1000_wait_autoneg(struct e1000_hw *hw);
+int32_t e1000_force_mac_fc(struct e1000_hw *hw);
 
 /* PHY */
 int32_t e1000_read_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t *phy_data);
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_param.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_param.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_param.c	2003-08-22 16:57:59.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_param.c	2003-09-08 09:13:12.000000000 -0700
@@ -140,7 +140,7 @@ E1000_PARAM(FlowControl, "Flow Control s
  * Valid Range: 0, 1
  *  - 0 - disables all checksum offload
  *  - 1 - enables receive IP/TCP/UDP checksum offload
- *        on 82543 based NICs
+ *        on 82543 and newer -based NICs
  *
  * Default Value: 1
  */
@@ -602,7 +602,7 @@ e1000_check_copper_options(struct e1000_
 
 	switch (speed + dplx) {
 	case 0:
-		adapter->hw.autoneg = 1;
+		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		if(Speed[bd] != OPTION_UNSET || Duplex[bd] != OPTION_UNSET)
 			printk(KERN_INFO
 			       "Speed and duplex autonegotiation enabled\n");
@@ -610,14 +610,14 @@ e1000_check_copper_options(struct e1000_
 	case HALF_DUPLEX:
 		printk(KERN_INFO "Half Duplex specified without Speed\n");
 		printk(KERN_INFO "Using Autonegotiation at Half Duplex only\n");
-		adapter->hw.autoneg = 1;
+		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 		                                 ADVERTISE_100_HALF;
 		break;
 	case FULL_DUPLEX:
 		printk(KERN_INFO "Full Duplex specified without Speed\n");
 		printk(KERN_INFO "Using Autonegotiation at Full Duplex only\n");
-		adapter->hw.autoneg = 1;
+		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_FULL |
 		                                 ADVERTISE_100_FULL |
 		                                 ADVERTISE_1000_FULL;
@@ -625,38 +625,38 @@ e1000_check_copper_options(struct e1000_
 	case SPEED_10:
 		printk(KERN_INFO "10 Mbps Speed specified without Duplex\n");
 		printk(KERN_INFO "Using Autonegotiation at 10 Mbps only\n");
-		adapter->hw.autoneg = 1;
+		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 		                                 ADVERTISE_10_FULL;
 		break;
 	case SPEED_10 + HALF_DUPLEX:
 		printk(KERN_INFO "Forcing to 10 Mbps Half Duplex\n");
-		adapter->hw.autoneg = 0;
+		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_10_half;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_10 + FULL_DUPLEX:
 		printk(KERN_INFO "Forcing to 10 Mbps Full Duplex\n");
-		adapter->hw.autoneg = 0;
+		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_10_full;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100:
 		printk(KERN_INFO "100 Mbps Speed specified without Duplex\n");
 		printk(KERN_INFO "Using Autonegotiation at 100 Mbps only\n");
-		adapter->hw.autoneg = 1;
+		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_100_HALF |
 		                                 ADVERTISE_100_FULL;
 		break;
 	case SPEED_100 + HALF_DUPLEX:
 		printk(KERN_INFO "Forcing to 100 Mbps Half Duplex\n");
-		adapter->hw.autoneg = 0;
+		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_100_half;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100 + FULL_DUPLEX:
 		printk(KERN_INFO "Forcing to 100 Mbps Full Duplex\n");
-		adapter->hw.autoneg = 0;
+		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_100_full;
 		adapter->hw.autoneg_advertised = 0;
 		break;
@@ -664,20 +664,20 @@ e1000_check_copper_options(struct e1000_
 		printk(KERN_INFO "1000 Mbps Speed specified without Duplex\n");
 		printk(KERN_INFO
 		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
-		adapter->hw.autoneg = 1;
+		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
 	case SPEED_1000 + HALF_DUPLEX:
 		printk(KERN_INFO "Half Duplex is not supported at 1000 Mbps\n");
 		printk(KERN_INFO
 		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
-		adapter->hw.autoneg = 1;
+		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
 	case SPEED_1000 + FULL_DUPLEX:
 		printk(KERN_INFO
 		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
-		adapter->hw.autoneg = 1;
+		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
 	default:
