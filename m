From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 1/4] flow control updates
Date: Thu, 25 Sep 2003 22:46:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309252242400.6939-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* handle ethtool force flow control
* correctly set flow control hi/low watermarks based on size of Rx FIFO
  area.  The size can change if doing Jumbo Frames or, in the case of 
  82547, is smaller to start with.
* was not properly forcing flow control settings to fc_none if using
  strict IEEE flow control override.

---------------

diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_ethtool.c net-drivers-2.5/drivers/net/e1000.mod/e1000_ethtool.c
--- net-drivers-2.5/drivers/net/e1000/e1000_ethtool.c	2003-09-24 21:16:04.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_ethtool.c	2003-09-24 21:18:26.000000000 -0700
@@ -230,11 +230,15 @@ e1000_ethtool_spause(struct e1000_adapte
 
 	hw->original_fc = hw->fc;
 
-	if(netif_running(adapter->netdev)) {
-		e1000_down(adapter);
-		e1000_up(adapter);
-	} else
-		e1000_reset(adapter);
+	if(adapter->fc_autoneg == AUTONEG_ENABLE) {
+		if(netif_running(adapter->netdev)) {
+			e1000_down(adapter);
+			e1000_up(adapter);
+		} else
+			e1000_reset(adapter);
+	}
+	else
+		return e1000_force_mac_fc(hw);
 	
 	return 0;
 }
diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000.h net-drivers-2.5/drivers/net/e1000.mod/e1000.h
--- net-drivers-2.5/drivers/net/e1000/e1000.h	2003-09-24 21:16:04.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000.h	2003-09-24 21:18:34.000000000 -0700
@@ -107,11 +107,11 @@ struct e1000_adapter;
 #define E1000_TX_HEAD_ADDR_SHIFT 7
 #define E1000_PBA_TX_MASK 0xFFFF0000
 
-/* Flow Control High-Watermark: 43464 bytes */
-#define E1000_FC_HIGH_THRESH 0xA9C8
+/* Flow Control High-Watermark: 5688 bytes below Rx FIFO size */
+#define E1000_FC_HIGH_DIFF 0x1638
 
-/* Flow Control Low-Watermark: 43456 bytes */
-#define E1000_FC_LOW_THRESH 0xA9C0
+/* Flow Control Low-Watermark: 5696 bytes below Rx FIFO size */
+#define E1000_FC_LOW_DIFF 0x1640
 
 /* Flow Control Pause Time: 858 usec */
 #define E1000_FC_PAUSE_TIME 0x0680
diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_hw.c net-drivers-2.5/drivers/net/e1000.mod/e1000_hw.c
--- net-drivers-2.5/drivers/net/e1000/e1000_hw.c	2003-09-24 21:16:04.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_hw.c	2003-09-24 21:19:21.000000000 -0700
@@ -1865,11 +1865,12 @@ e1000_config_fc_after_link_up(struct e10
              * be asked to delay transmission of packets than asking
              * our link partner to pause transmission of frames.
              */
-            else if(hw->original_fc == e1000_fc_none ||
-                    hw->original_fc == e1000_fc_tx_pause) {
+            else if((hw->original_fc == e1000_fc_none ||
+                     hw->original_fc == e1000_fc_tx_pause) ||
+                    hw->fc_strict_ieee) {
                 hw->fc = e1000_fc_none;
                 DEBUGOUT("Flow Control = NONE.\r\n");
-            } else if(!hw->fc_strict_ieee) {
+            } else {
                 hw->fc = e1000_fc_rx_pause;
                 DEBUGOUT("Flow Control = RX PAUSE frames only.\r\n");
             }
diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_main.c net-drivers-2.5/drivers/net/e1000.mod/e1000_main.c
--- net-drivers-2.5/drivers/net/e1000/e1000_main.c	2003-09-24 21:16:04.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_main.c	2003-09-24 21:20:12.000000000 -0700
@@ -318,7 +318,13 @@ e1000_reset(struct e1000_adapter *adapte
 	}
 	E1000_WRITE_REG(&adapter->hw, PBA, pba);
 
+	/* flow control settings */
+	adapter->hw.fc_high_water = pba - E1000_FC_HIGH_DIFF;
+	adapter->hw.fc_low_water = pba - E1000_FC_LOW_DIFF;
+	adapter->hw.fc_pause_time = E1000_FC_PAUSE_TIME;
+	adapter->hw.fc_send_xon = 1;
 	adapter->hw.fc = adapter->hw.original_fc;
+
 	e1000_reset_hw(&adapter->hw);
 	if(adapter->hw.mac_type >= e1000_82544)
 		E1000_WRITE_REG(&adapter->hw, WUC, 0);
@@ -621,13 +627,6 @@ e1000_sw_init(struct e1000_adapter *adap
 
 	e1000_init_eeprom_params(hw);
 
-	/* flow control settings */
-
-	hw->fc_high_water = E1000_FC_HIGH_THRESH;
-	hw->fc_low_water = E1000_FC_LOW_THRESH;
-	hw->fc_pause_time = E1000_FC_PAUSE_TIME;
-	hw->fc_send_xon = 1;
-
 	if((hw->mac_type == e1000_82541) ||
 	   (hw->mac_type == e1000_82547) ||
 	   (hw->mac_type == e1000_82541_rev_2) ||
