From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 6/8 2.5] e1000 - Polarity reversal workaround for 10F/10H
 links
Date: Fri, 17 Sep 2004 02:58:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170236370.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_hw.c linux-2.5/drivers/net/e1000.new/e1000_hw.c
--- linux-2.5/drivers/net/e1000/e1000_hw.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_hw.c	2004-09-09 11:17:12.000000000 -0700
@@ -65,6 +65,7 @@ static void e1000_release_eeprom(struct 
 static void e1000_standby_eeprom(struct e1000_hw *hw);
 static int32_t e1000_id_led_init(struct e1000_hw * hw);
 static int32_t e1000_set_vco_speed(struct e1000_hw *hw);
+static int32_t e1000_polarity_reversal_workaround(struct e1000_hw *hw);
 static int32_t e1000_set_phy_mode(struct e1000_hw *hw);
 
 /* IGP cable length table */
@@ -1594,6 +1595,15 @@ e1000_phy_force_speed_duplex(struct e100
         ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
         if(ret_val)
             return ret_val;
+
+        if((hw->mac_type == e1000_82544 || hw->mac_type == e1000_82543) &&
+           (!hw->autoneg) &&
+           (hw->forced_speed_duplex == e1000_10_full ||
+            hw->forced_speed_duplex == e1000_10_half)) {
+            ret_val = e1000_polarity_reversal_workaround(hw);
+            if(ret_val)
+                return ret_val;
+        }
     }
     return E1000_SUCCESS;
 }
@@ -1983,6 +1993,7 @@ e1000_check_for_link(struct e1000_hw *hw
     uint32_t ctrl;
     uint32_t status;
     uint32_t rctl;
+    uint32_t icr;
     uint32_t signal = 0;
     int32_t ret_val;
     uint16_t phy_data;
@@ -2032,6 +2043,25 @@ e1000_check_for_link(struct e1000_hw *hw
              * link-up */
             e1000_check_downshift(hw);
 
+            /* If we are on 82544 or 82543 silicon and speed/duplex
+             * are forced to 10H or 10F, then we will implement the polarity
+             * reversal workaround.  We disable interrupts first, and upon
+             * returning, place the devices interrupt state to its previous
+             * value except for the link status change interrupt which will
+             * happen due to the execution of this workaround.
+             */
+
+            if((hw->mac_type == e1000_82544 || hw->mac_type == e1000_82543) &&
+               (!hw->autoneg) &&
+               (hw->forced_speed_duplex == e1000_10_full ||
+                hw->forced_speed_duplex == e1000_10_half)) {
+                E1000_WRITE_REG(hw, IMC, 0xffffffff);
+                ret_val = e1000_polarity_reversal_workaround(hw);
+                icr = E1000_READ_REG(hw, ICR);
+                E1000_WRITE_REG(hw, ICS, (icr & ~E1000_ICS_LSC));
+                E1000_WRITE_REG(hw, IMS, IMS_ENABLE_MASK);
+            }
+
         } else {
             /* No link detected */
             e1000_config_dsp_after_link_change(hw, FALSE);
@@ -5216,3 +5246,88 @@ e1000_enable_mng_pass_thru(struct e1000_
     return FALSE;
 }
 
+static int32_t
+e1000_polarity_reversal_workaround(struct e1000_hw *hw)
+{
+    int32_t ret_val;
+    uint16_t mii_status_reg;
+    uint16_t i;
+
+    /* Polarity reversal workaround for forced 10F/10H links. */
+
+    /* Disable the transmitter on the PHY */
+
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0019);
+    if(ret_val)
+        return ret_val;
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xFFFF);
+    if(ret_val)
+        return ret_val;
+
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0000);
+    if(ret_val)
+        return ret_val;
+
+    /* This loop will early-out if the NO link condition has been met. */
+    for(i = PHY_FORCE_TIME; i > 0; i--) {
+        /* Read the MII Status Register and wait for Link Status bit
+         * to be clear.
+         */
+
+        ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg);
+        if(ret_val)
+            return ret_val;
+
+        ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg);
+        if(ret_val)
+            return ret_val;
+
+        if((mii_status_reg & ~MII_SR_LINK_STATUS) == 0) break;
+        msec_delay_irq(100);
+    }
+
+    /* Recommended delay time after link has been lost */
+    msec_delay_irq(1000);
+
+    /* Now we will re-enable th transmitter on the PHY */
+
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0019);
+    if(ret_val)
+        return ret_val;
+    msec_delay_irq(50);
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xFFF0);
+    if(ret_val)
+        return ret_val;
+    msec_delay_irq(50);
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xFF00);
+    if(ret_val)
+        return ret_val;
+    msec_delay_irq(50);
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, 0x0000);
+    if(ret_val)
+        return ret_val;
+
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0000);
+    if(ret_val)
+        return ret_val;
+
+    /* This loop will early-out if the link condition has been met. */
+    for(i = PHY_FORCE_TIME; i > 0; i--) {
+        /* Read the MII Status Register and wait for Link Status bit
+         * to be set.
+         */
+
+        ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg);
+        if(ret_val)
+            return ret_val;
+
+        ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg);
+        if(ret_val)
+            return ret_val;
+
+        if(mii_status_reg & MII_SR_LINK_STATUS) break;
+        msec_delay_irq(100);
+    }
+    return E1000_SUCCESS;
+}
+
diff -up linux-2.5/drivers/net/e1000/e1000_osdep.h linux-2.5/drivers/net/e1000.new/e1000_osdep.h
--- linux-2.5/drivers/net/e1000/e1000_osdep.h	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_osdep.h	2004-09-09 11:17:12.000000000 -0700
@@ -49,6 +49,12 @@
 				set_current_state(TASK_UNINTERRUPTIBLE); \
 				schedule_timeout((x * HZ)/1000 + 2); \
 			} } while(0)
+/* Some workarounds require millisecond delays and are run during interrupt
+ * context.  Most notably, when establishing link, the phy may need tweaking
+ * but cannot process phy register reads/writes faster than millisecond
+ * intervals...and we establish link due to a "link status change" interrupt.
+ */
+#define msec_delay_irq(x) mdelay(x)
 #endif
 
 #define PCI_COMMAND_REGISTER   PCI_COMMAND
