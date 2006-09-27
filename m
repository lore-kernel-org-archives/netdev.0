From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 13/23] e1000: gather hardware bit tweaks.
Date: Wed, 27 Sep 2006 13:12:07 -0700
Message-ID: <451ADB17.1070307@intel.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172901.4605.36283.stgit@gitlost.site> <451046CC.3050101@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54657 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1030749AbWI0UN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 16:13:59 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451046CC.3050101@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Several hardware bits were set all over the driver and have been
>> consolidated into a single function.
> 
>> diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
>> index 9422864..a143b49 100644
> 
> Overall this is a positive change.  However, NAK'd for two superficial 
> reasons:
> 
> 1) the comments are completely useless.  We can see from reading the 
> code what the comments tell us.  What the comments DON'T tell us are (a) 
> a description of the bit being set, and (b) why that bit is being set.
> 
> 2) the easy-for-humans-to-read notation for bit setting is
> 
>     (1 << n)
> 
> not a hex constant.

reworked and added a whole bunch of comments. Here's what goes into the queue instead:

the only part changed relative to my original submission is the new 
e1000_initialize_hardware_bits function.

Auke

---


e1000: gather hardware bit tweaks.

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Several hardware bits were set all over the driver and have been
consolidated into a single function.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

  drivers/net/e1000/e1000_hw.c   |  155 ++++++++++++++++++++++++++++++++++------
  drivers/net/e1000/e1000_hw.h   |    1
  drivers/net/e1000/e1000_main.c |   24 +++---
  3 files changed, 142 insertions(+), 38 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 6ec5cdd..dceaf5b 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -61,6 +61,7 @@ static int32_t e1000_id_led_init(struct
  static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32_t 
cnf_base_addr, uint32_t cnf_size);
  static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
  static void e1000_init_rx_addrs(struct e1000_hw *hw);
+static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
  static boolean_t e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
  static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
  static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
@@ -716,6 +717,123 @@ e1000_reset_hw(struct e1000_hw *hw)
  }

  /******************************************************************************
+ *
+ * Initialize a number of hardware-dependent bits
+ *
+ * hw: Struct containing variables accessed by shared code
+ *
+ * This function contains hardware limitation workarounds for PCI-E adapters
+ *
+ *****************************************************************************/
+static void
+e1000_initialize_hardware_bits(struct e1000_hw *hw)
+{
+    if ((hw->mac_type >= e1000_82571) && (!hw->initialize_hw_bits_disable)) {
+        /* Settings common to all PCI-express silicon */
+        uint32_t reg_ctrl, reg_ctrl_ext;
+        uint32_t reg_tarc0, reg_tarc1;
+        uint32_t reg_tctl;
+        uint32_t reg_txdctl, reg_txdctl1;
+
+        /* link autonegotiation/sync workarounds */
+        reg_tarc0 = E1000_READ_REG(hw, TARC0);
+        reg_tarc0 &= ~((1 << 30)|(1 << 29)|(1 << 28)|(1 << 27));
+
+        /* Enable not-done TX descriptor counting */
+        reg_txdctl = E1000_READ_REG(hw, TXDCTL);
+        reg_txdctl |= E1000_TXDCTL_COUNT_DESC;
+        E1000_WRITE_REG(hw, TXDCTL, reg_txdctl);
+        reg_txdctl1 = E1000_READ_REG(hw, TXDCTL1);
+        reg_txdctl1 |= E1000_TXDCTL_COUNT_DESC;
+        E1000_WRITE_REG(hw, TXDCTL1, reg_txdctl1);
+
+        switch (hw->mac_type) {
+            case e1000_82571:
+            case e1000_82572:
+                /* Clear PHY TX compatible mode bits */
+                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                reg_tarc1 &= ~((1 << 30)|(1 << 29));
+
+                /* link autonegotiation/sync workarounds */
+                reg_tarc0 |= ((1 << 26)|(1 << 25)|(1 << 24)|(1 << 23));
+
+                /* TX ring control fixes */
+                reg_tarc1 |= ((1 << 26)|(1 << 25)|(1 << 24));
+
+                /* Multiple read bit is reversed polarity */
+                reg_tctl = E1000_READ_REG(hw, TCTL);
+                if (reg_tctl & E1000_TCTL_MULR)
+                    reg_tarc1 &= ~(1 << 28);
+                else
+                    reg_tarc1 |= (1 << 28);
+
+                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                break;
+            case e1000_82573:
+                reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+                reg_ctrl_ext &= ~(1 << 23);
+                reg_ctrl_ext |= (1 << 22);
+
+                /* TX byte count fix */
+                reg_ctrl = E1000_READ_REG(hw, CTRL);
+                reg_ctrl &= ~(1 << 29);
+
+                E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
+                E1000_WRITE_REG(hw, CTRL, reg_ctrl);
+                break;
+            case e1000_80003es2lan:
+                /* improve small packet performace for fiber/serdes */
+                if ((hw->media_type == e1000_media_type_fiber) ||
+                    (hw->media_type == e1000_media_type_internal_serdes)) {
+                    reg_tarc0 &= ~(1 << 20);
+                }
+
+                /* Multiple read bit is reversed polarity */
+                reg_tctl = E1000_READ_REG(hw, TCTL);
+                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                if (reg_tctl & E1000_TCTL_MULR)
+                    reg_tarc1 &= ~(1 << 28);
+                else
+                    reg_tarc1 |= (1 << 28);
+
+                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                break;
+            case e1000_ich8lan:
+                /* Reduce concurrent DMA requests to 3 from 4 */
+                if ((hw->revision_id < 3) ||
+                    ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
+                     (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))
+                    reg_tarc0 |= ((1 << 29)|(1 << 28));
+
+                reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+                reg_ctrl_ext |= (1 << 22);
+                E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
+
+                /* workaround TX hang with TSO=on */
+                reg_tarc0 |= ((1 << 27)|(1 << 26)|(1 << 24)|(1 << 23));
+
+                /* Multiple read bit is reversed polarity */
+                reg_tctl = E1000_READ_REG(hw, TCTL);
+                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                if (reg_tctl & E1000_TCTL_MULR)
+                    reg_tarc1 &= ~(1 << 28);
+                else
+                    reg_tarc1 |= (1 << 28);
+
+                /* workaround TX hang with TSO=on */
+                reg_tarc1 |= ((1 << 30)|(1 << 26)|(1 << 24));
+
+                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                break;
+            default:
+                break;
+        }
+
+        E1000_WRITE_REG(hw, TARC0, reg_tarc0);
+    }
+}
+
+/******************************************************************************
   * Performs basic configuration of the adapter.
   *
   * hw - Struct containing variables accessed by shared code
@@ -743,14 +861,13 @@ e1000_init_hw(struct e1000_hw *hw)
      DEBUGFUNC("e1000_init_hw");

      /* force full DMA clock frequency for 10/100 on ICH8 A0-B0 */
-    if (hw->mac_type == e1000_ich8lan) {
-        reg_data = E1000_READ_REG(hw, TARC0);
-        reg_data |= 0x30000000;
-        E1000_WRITE_REG(hw, TARC0, reg_data);
-
-        reg_data = E1000_READ_REG(hw, STATUS);
-        reg_data &= ~0x80000000;
-        E1000_WRITE_REG(hw, STATUS, reg_data);
+    if ((hw->mac_type == e1000_ich8lan) &&
+        ((hw->revision_id < 3) ||
+         ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
+          (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))) {
+            reg_data = E1000_READ_REG(hw, STATUS);
+            reg_data &= ~0x80000000;
+            E1000_WRITE_REG(hw, STATUS, reg_data);
      }

      /* Initialize Identification LED */
@@ -763,6 +880,9 @@ e1000_init_hw(struct e1000_hw *hw)
      /* Set the media type and TBI compatibility */
      e1000_set_media_type(hw);

+    /* Must be called after e1000_set_media_type because media_type is used */
+    e1000_initialize_hardware_bits(hw);
+
      /* Disabling VLAN filtering. */
      DEBUGOUT("Initializing the IEEE VLAN\n");
      /* VET hardcoded to standard value and VFTA removed in ICH8 LAN */
@@ -854,17 +974,6 @@ e1000_init_hw(struct e1000_hw *hw)
      if (hw->mac_type > e1000_82544) {
          ctrl = E1000_READ_REG(hw, TXDCTL);
          ctrl = (ctrl & ~E1000_TXDCTL_WTHRESH) | E1000_TXDCTL_FULL_TX_DESC_WB;
-        switch (hw->mac_type) {
-        default:
-            break;
-        case e1000_82571:
-        case e1000_82572:
-        case e1000_82573:
-        case e1000_ich8lan:
-        case e1000_80003es2lan:
-            ctrl |= E1000_TXDCTL_COUNT_DESC;
-            break;
-        }
          E1000_WRITE_REG(hw, TXDCTL, ctrl);
      }

@@ -902,8 +1011,6 @@ e1000_init_hw(struct e1000_hw *hw)
      case e1000_ich8lan:
          ctrl = E1000_READ_REG(hw, TXDCTL1);
          ctrl = (ctrl & ~E1000_TXDCTL_WTHRESH) | E1000_TXDCTL_FULL_TX_DESC_WB;
-        if (hw->mac_type >= e1000_82571)
-            ctrl |= E1000_TXDCTL_COUNT_DESC;
          E1000_WRITE_REG(hw, TXDCTL1, ctrl);
          break;
      }
@@ -1143,11 +1250,11 @@ e1000_setup_fiber_serdes_link(struct e10
      if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572)
          E1000_WRITE_REG(hw, SCTL, E1000_DISABLE_SERDES_LOOPBACK);

-    /* On adapters with a MAC newer than 82544, SW Defineable pin 1 will be
+    /* On adapters with a MAC newer than 82544, SWDP 1 will be
       * set when the optics detect a signal. On older adapters, it will be
       * cleared when there is a signal.  This applies to fiber media only.
-     * If we're on serdes media, adjust the output amplitude to value set in
-     * the EEPROM.
+     * If we're on serdes media, adjust the output amplitude to value
+     * set in the EEPROM.
       */
      ctrl = E1000_READ_REG(hw, CTRL);
      if (hw->media_type == e1000_media_type_fiber)
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 113344e..b9364b5 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1440,6 +1440,7 @@ struct e1000_hw {
      boolean_t tbi_compatibility_on;
      boolean_t laa_is_present;
      boolean_t phy_reset_disable;
+    boolean_t initialize_hw_bits_disable;
      boolean_t fc_send_xon;
      boolean_t fc_strict_ieee;
      boolean_t report_tx_early;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index e8a7608..aaadb2b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -573,6 +573,9 @@ void
  e1000_reset(struct e1000_adapter *adapter)
  {
  	uint32_t pba, manc;
+#ifdef DISABLE_MULR
+	uint32_t tctl;
+#endif
  	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;

  	/* Repartition Pba for greater than 9k mtu
@@ -639,6 +642,12 @@ e1000_reset(struct e1000_adapter *adapte
  	e1000_reset_hw(&adapter->hw);
  	if (adapter->hw.mac_type >= e1000_82544)
  		E1000_WRITE_REG(&adapter->hw, WUC, 0);
+#ifdef DISABLE_MULR
+	/* disable Multiple Reads in Transmit Control Register for debugging */
+	tctl = E1000_READ_REG(hw, TCTL);
+	E1000_WRITE_REG(hw, TCTL, tctl & ~E1000_TCTL_MULR);
+
+#endif
  	if (e1000_init_hw(&adapter->hw))
  		DPRINTK(PROBE, ERR, "Hardware Error\n");
  	e1000_update_mng_vlan(adapter);
@@ -1517,27 +1526,14 @@ e1000_configure_tx(struct e1000_adapter
  	/* Program the Transmit Control Register */

  	tctl = E1000_READ_REG(hw, TCTL);
-
  	tctl &= ~E1000_TCTL_CT;
  	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
  		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);

-#ifdef DISABLE_MULR
-	/* disable Multiple Reads for debugging */
-	tctl &= ~E1000_TCTL_MULR;
-#endif
-
  	if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572) {
  		tarc = E1000_READ_REG(hw, TARC0);
-		tarc |= ((1 << 25) | (1 << 21));
+		tarc |= (1 << 21);
  		E1000_WRITE_REG(hw, TARC0, tarc);
-		tarc = E1000_READ_REG(hw, TARC1);
-		tarc |= (1 << 25);
-		if (tctl & E1000_TCTL_MULR)
-			tarc &= ~(1 << 28);
-		else
-			tarc |= (1 << 28);
-		E1000_WRITE_REG(hw, TARC1, tarc);
  	} else if (hw->mac_type == e1000_80003es2lan) {
  		tarc = E1000_READ_REG(hw, TARC0);
  		tarc |= 1;
