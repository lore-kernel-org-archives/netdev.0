From: Jeb Cramer <cramerj@intel.com>
Subject: [PATCH 1/1 2.4] e1000 management reset fix
Date: 15 Jun 2004 21:41:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087360890.12233.11.camel@mini>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Resetting the adapter blew away management settings.  So we save the
important bits before performing a reset.

-------------------------------------------------------


diff -Nuarp
--- A/drivers/net/e1000/e1000.h
+++ B/drivers/net/e1000/e1000.h
@@ -197,6 +197,7 @@ struct e1000_adapter {
 	uint32_t part_num;
 	uint32_t wol;
 	uint32_t smartspeed;
+	uint32_t en_mng_pt;
 	uint16_t link_speed;
 	uint16_t link_duplex;
 	spinlock_t stats_lock;
diff -Nuarp
--- A/drivers/net/e1000/e1000_hw.c
+++ B/drivers/net/e1000/e1000_hw.c
@@ -265,6 +265,17 @@ e1000_set_mac_type(struct e1000_hw *hw)
         return -E1000_ERR_MAC_TYPE;
     }
 
+    switch(hw->mac_type) {
+    case e1000_82541:
+    case e1000_82547:
+    case e1000_82541_rev_2:
+    case e1000_82547_rev_2:
+        hw->asf_firmware_present = TRUE;
+        break;
+    default:
+        break;
+    }
+
     return E1000_SUCCESS;
 }
 
@@ -5189,3 +5200,27 @@ e1000_set_vco_speed(struct e1000_hw *hw)
     return E1000_SUCCESS;
 }
 
+/******************************************************************************
+ * Verifies the hardware needs to allow ARPs to be processed by the host
+ *
+ * hw - Struct containing variables accessed by shared code
+ *
+ * returns: - TRUE/FALSE
+ *
+ *****************************************************************************/
+uint32_t
+e1000_enable_mng_pass_thru(struct e1000_hw *hw)
+{
+    uint32_t manc;
+
+    if (hw->asf_firmware_present) {
+        manc = E1000_READ_REG(hw, MANC);
+
+        if (!(manc & E1000_MANC_RCV_TCO_EN) ||
+            !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
+            return FALSE;
+        if ((manc & E1000_MANC_SMBUS_EN) && !(manc & E1000_MANC_ASF_EN))
+            return TRUE;
+    }
+    return FALSE;
+}
diff -Nuarp
--- A/drivers/net/e1000/e1000_hw.h
+++ B/drivers/net/e1000/e1000_hw.h
@@ -307,6 +307,7 @@ int32_t e1000_led_off(struct e1000_hw *h
 /* Adaptive IFS Functions */
 
 /* Everything else */
+uint32_t e1000_enable_mng_pass_thru(struct e1000_hw *hw);
 void e1000_clear_hw_cntrs(struct e1000_hw *hw);
 void e1000_reset_adaptive(struct e1000_hw *hw);
 void e1000_update_adaptive(struct e1000_hw *hw);
@@ -983,6 +984,7 @@ struct e1000_hw {
     e1000_ms_type master_slave;
     e1000_ms_type original_master_slave;
     e1000_ffe_config ffe_config_state;
+    uint32_t asf_firmware_present;
     unsigned long io_base;
     uint32_t phy_id;
     uint32_t phy_revision;
diff -Nuarp
--- A/drivers/net/e1000/e1000_main.c
+++ B/drivers/net/e1000/e1000_main.c
@@ -299,7 +299,7 @@ e1000_down(struct e1000_adapter *adapter
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
-	uint32_t pba;
+	uint32_t pba, manc;
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
 	 */
@@ -341,6 +341,12 @@ e1000_reset(struct e1000_adapter *adapte
 
 	e1000_reset_adaptive(&adapter->hw);
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
+
+	if(adapter->en_mng_pt) {
+		manc = E1000_READ_REG(&adapter->hw, MANC);
+		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
+		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+	}
 }
 
 /**
@@ -483,6 +489,8 @@ e1000_probe(struct pci_dev *pdev,
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
+
 	/* before reading the EEPROM, reset the controller to 
 	 * put the device in a known good starting state */
 	
