From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 6/11] make function our of setting media type
Date: Mon, 8 Sep 2003 20:14:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081944470.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Consolidate code and make function out of setting media type.

--------------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c	2003-08-22 17:01:40.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c	2003-09-08 09:13:11.000000000 -0700
@@ -249,6 +249,46 @@ e1000_set_mac_type(struct e1000_hw *hw)
 
     return E1000_SUCCESS;
 }
+
+/*****************************************************************************
+ * Set media type and TBI compatibility.
+ *
+ * hw - Struct containing variables accessed by shared code
+ * **************************************************************************/
+void
+e1000_set_media_type(struct e1000_hw *hw)
+{
+    uint32_t status;
+
+    DEBUGFUNC("e1000_set_media_type");
+
+    if(hw->mac_type != e1000_82543) {
+        /* tbi_compatibility is only valid on 82543 */
+        hw->tbi_compatibility_en = FALSE;
+    }
+
+    switch (hw->device_id) {
+    case E1000_DEV_ID_82545GM_SERDES:
+    case E1000_DEV_ID_82546GB_SERDES:
+        hw->media_type = e1000_media_type_internal_serdes;
+        break;
+    default:
+        if(hw->mac_type >= e1000_82543) {
+            status = E1000_READ_REG(hw, STATUS);
+            if(status & E1000_STATUS_TBIMODE) {
+                hw->media_type = e1000_media_type_fiber;
+                /* tbi_compatibility not valid on fiber */
+                hw->tbi_compatibility_en = FALSE;
+            } else {
+                hw->media_type = e1000_media_type_copper;
+            }
+        } else {
+            /* This is an 82542 (fiber only) */
+            hw->media_type = e1000_media_type_fiber;
+        }
+    }
+}
+
 /******************************************************************************
  * Reset the transmit and receive units; mask and clear all interrupts.
  *
@@ -404,7 +404,7 @@ e1000_reset_hw(struct e1000_hw *hw)
 int32_t
 e1000_init_hw(struct e1000_hw *hw)
 {
-    uint32_t ctrl, status;
+    uint32_t ctrl;
     uint32_t i;
     int32_t ret_val;
     uint16_t pcix_cmd_word;
@@ -421,25 +390,8 @@ e1000_init_hw(struct e1000_hw *hw)
         return ret_val;
     }
 
-    /* Set the Media Type and exit with error if it is not valid. */
-    if(hw->mac_type != e1000_82543) {
-        /* tbi_compatibility is only valid on 82543 */
-        hw->tbi_compatibility_en = FALSE;
-    }
-
-    if(hw->mac_type >= e1000_82543) {
-        status = E1000_READ_REG(hw, STATUS);
-        if(status & E1000_STATUS_TBIMODE) {
-            hw->media_type = e1000_media_type_fiber;
-            /* tbi_compatibility not valid on fiber */
-            hw->tbi_compatibility_en = FALSE;
-        } else {
-            hw->media_type = e1000_media_type_copper;
-        }
-    } else {
-        /* This is an 82542 (fiber only) */
-        hw->media_type = e1000_media_type_fiber;
-    }
+    /* Set the media type and TBI compatibility */
+    e1000_set_media_type(hw);
 
     /* Disabling VLAN filtering. */
     DEBUGOUT("Initializing the IEEE VLAN\n");
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_main.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_main.c	2003-08-22 16:54:23.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c	2003-09-08 09:13:11.000000000 -0700
@@ -625,18 +625,7 @@ e1000_sw_init(struct e1000_adapter *adap
 	   (hw->mac_type == e1000_82547_rev_2))
 		hw->phy_init_script = 1;
 
-	/* Media type - copper or fiber */
-
-	if(hw->mac_type >= e1000_82543) {
-		uint32_t status = E1000_READ_REG(hw, STATUS);
-
-		if(status & E1000_STATUS_TBIMODE)
-			hw->media_type = e1000_media_type_fiber;
-		else
-			hw->media_type = e1000_media_type_copper;
-	} else {
-		hw->media_type = e1000_media_type_fiber;
-	}
+	e1000_set_media_type(hw);
 
 	if(hw->mac_type < e1000_82543)
 		hw->report_tx_early = 0;
