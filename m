From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 3/8 2.5] e1000 -  Fix MODULE_PARM, module_param and
 module_param_array usage
Date: Fri, 17 Sep 2004 02:57:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170231510.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000.h linux-2.5/drivers/net/e1000.new/e1000.h
--- linux-2.5/drivers/net/e1000/e1000.h	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000.h	2004-09-09 11:17:12.000000000 -0700
@@ -71,7 +71,6 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
-#include <linux/moduleparam.h>
 
 #define BAR_0		0
 #define BAR_1		1
diff -up linux-2.5/drivers/net/e1000/e1000_param.c linux-2.5/drivers/net/e1000.new/e1000_param.c
--- linux-2.5/drivers/net/e1000/e1000_param.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_param.c	2004-09-09 11:17:12.000000000 -0700
@@ -34,10 +34,16 @@
 
 #define E1000_MAX_NIC 32
 
-#define OPTION_UNSET    -1
+#define OPTION_UNSET   -1
 #define OPTION_DISABLED 0
 #define OPTION_ENABLED  1
 
+/* All parameters are treated the same, as an integer array of values.
+ * This macro just reduces the need to repeat the same declaration code
+ * over and over (plus this helps to avoid typo bugs).
+ */
+
+#define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
 /* Module Parameters are always initialized to -1, so that the driver
  * can tell the difference between no user specified value or the
  * user asking for the default value.
@@ -48,17 +49,11 @@
  * "Extensions to the C Language Family" of the GCC documentation.
  */
 
-#define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
-
-/* All parameters are treated the same, as an integer array of values.
- * This macro just reduces the need to repeat the same declaration code
- * over and over (plus this helps to avoid typo bugs).
- */
-
-#define E1000_PARAM(X, S) \
-static const int __devinitdata X[E1000_MAX_NIC + 1] = E1000_PARAM_INIT; \
-MODULE_PARM(X, "1-" __MODULE_STRING(E1000_MAX_NIC) "i"); \
-MODULE_PARM_DESC(X, S);
+#define E1000_PARAM(X, desc) \
+	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
+	static int num_##X = 0; \
+	module_param_array(X, int, num_##X, 0); \
+	MODULE_PARM_DESC(X, desc);
 
 /* Transmit Descriptor Count
  *
@@ -306,5 +312,9 @@ e1000_check_options(struct e1000_adapter
 		       "Warning: no configuration for board #%i\n", bd);
 		DPRINTK(PROBE, NOTICE, "Using defaults for all values\n");
 #ifndef module_param_array
-		bd = E1000_MAX_NIC;
 #endif
 	}
 
@@ -322,9 +327,14 @@ e1000_check_options(struct e1000_adapter
 		opt.arg.r.max = mac_type < e1000_82544 ?
 			E1000_MAX_TXD : E1000_MAX_82544_TXD;
 
-		tx_ring->count = TxDescriptors[bd];
-		e1000_validate_option(&tx_ring->count, &opt, adapter);
-		E1000_ROUNDUP(tx_ring->count, REQ_TX_DESCRIPTOR_MULTIPLE);
+		if (num_TxDescriptors > bd) {
+			tx_ring->count = TxDescriptors[bd];
+			e1000_validate_option(&tx_ring->count, &opt, adapter);
+			E1000_ROUNDUP(tx_ring->count, 
+						REQ_TX_DESCRIPTOR_MULTIPLE);
+		} else {
+			tx_ring->count = opt.def;
+		}
 	}
 	{ /* Receive Descriptor Count */
 		struct e1000_option opt = {
@@ -340,9 +349,14 @@ e1000_check_options(struct e1000_adapter
 		opt.arg.r.max = mac_type < e1000_82544 ? E1000_MAX_RXD :
 			E1000_MAX_82544_RXD;
 
-		rx_ring->count = RxDescriptors[bd];
-		e1000_validate_option(&rx_ring->count, &opt, adapter);
-		E1000_ROUNDUP(rx_ring->count, REQ_RX_DESCRIPTOR_MULTIPLE);
+		if (num_RxDescriptors > bd) {
+			rx_ring->count = RxDescriptors[bd];
+			e1000_validate_option(&rx_ring->count, &opt, adapter);
+			E1000_ROUNDUP(rx_ring->count, 
+						REQ_RX_DESCRIPTOR_MULTIPLE);
+		} else {
+			rx_ring->count = opt.def;
+		}
 	}
 	{ /* Checksum Offload Enable/Disable */
 		struct e1000_option opt = {
@@ -352,9 +365,13 @@ e1000_check_options(struct e1000_adapter
 			.def  = OPTION_ENABLED
 		};
 
-		int rx_csum = XsumRX[bd];
-		e1000_validate_option(&rx_csum, &opt, adapter);
-		adapter->rx_csum = rx_csum;
+		if (num_XsumRX > bd) {
+			int rx_csum = XsumRX[bd];
+			e1000_validate_option(&rx_csum, &opt, adapter);
+			adapter->rx_csum = rx_csum;
+		} else {
+			adapter->rx_csum = opt.def;
+		}
 	}
 	{ /* Flow Control */
 
@@ -374,9 +391,13 @@ e1000_check_options(struct e1000_adapter
 					 .p = fc_list }}
 		};
 
-		int fc = FlowControl[bd];
-		e1000_validate_option(&fc, &opt, adapter);
-		adapter->hw.fc = adapter->hw.original_fc = fc;
+		if (num_FlowControl > bd) {
+			int fc = FlowControl[bd];
+			e1000_validate_option(&fc, &opt, adapter);
+			adapter->hw.fc = adapter->hw.original_fc = fc;
+		} else {
+			adapter->hw.fc = opt.def;
+		}
 	}
 	{ /* Transmit Interrupt Delay */
 		struct e1000_option opt = {
@@ -388,8 +409,13 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_TXDELAY }}
 		};
 
-		adapter->tx_int_delay = TxIntDelay[bd];
-		e1000_validate_option(&adapter->tx_int_delay, &opt, adapter);
+		if (num_TxIntDelay > bd) {
+			adapter->tx_int_delay = TxIntDelay[bd];
+			e1000_validate_option(&adapter->tx_int_delay, &opt, 
+								adapter);
+		} else {
+			adapter->tx_int_delay = opt.def;
+		}
 	}
 	{ /* Transmit Absolute Interrupt Delay */
 		struct e1000_option opt = {
@@ -401,8 +426,13 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_TXABSDELAY }}
 		};
 
-		adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
-		e1000_validate_option(&adapter->tx_abs_int_delay, &opt, adapter);
+		if (num_TxAbsIntDelay > bd) {
+			adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
+			e1000_validate_option(&adapter->tx_abs_int_delay, &opt, 
+								adapter);
+		} else {
+			adapter->tx_abs_int_delay = opt.def;
+		}
 	}
 	{ /* Receive Interrupt Delay */
 		struct e1000_option opt = {
@@ -414,8 +443,13 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_RXDELAY }}
 		};
 
-		adapter->rx_int_delay = RxIntDelay[bd];
-		e1000_validate_option(&adapter->rx_int_delay, &opt, adapter);
+		if (num_RxIntDelay > bd) {
+			adapter->rx_int_delay = RxIntDelay[bd];
+			e1000_validate_option(&adapter->rx_int_delay, &opt, 
+								adapter);
+		} else {
+			adapter->rx_int_delay = opt.def;
+		}
 	}
 	{ /* Receive Absolute Interrupt Delay */
 		struct e1000_option opt = {
@@ -427,8 +460,13 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_RXABSDELAY }}
 		};
 
-		adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
-		e1000_validate_option(&adapter->rx_abs_int_delay, &opt, adapter);
+		if (num_RxAbsIntDelay > bd) {
+			adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
+			e1000_validate_option(&adapter->rx_abs_int_delay, &opt, 
+								adapter);
+		} else {
+			adapter->rx_abs_int_delay = opt.def;
+		}
 	}
 	{ /* Interrupt Throttling Rate */
 		struct e1000_option opt = {
@@ -440,20 +477,27 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_ITR }}
 		};
 
-		adapter->itr = InterruptThrottleRate[bd];
-		switch(adapter->itr) {
-		case -1:
+		if (num_InterruptThrottleRate > bd) {
+			adapter->itr = InterruptThrottleRate[bd];
+			switch(adapter->itr) {
+			case -1:
+				adapter->itr = 1;
+				break;
+			case 0:
+				DPRINTK(PROBE, INFO, "%s turned off\n", 
+					opt.name);
+				break;
+			case 1:
+				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n", 
+					opt.name);
+				break;
+			default:
+				e1000_validate_option(&adapter->itr, &opt, 
+					adapter);
+				break;
+			}
+		} else {
 			adapter->itr = 1;
-			break;
-		case 0:
-			DPRINTK(PROBE, INFO, "%s turned off\n", opt.name);
-			break;
-		case 1:
-			DPRINTK(PROBE, INFO, "%s set to dynamic mode\n", opt.name);
-			break;
-		default:
-			e1000_validate_option(&adapter->itr, &opt, adapter);
-			break;
 		}
 	}
 
@@ -481,17 +522,19 @@ static void __devinit
 e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
- 	bd = bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
-
- 	if((Speed[bd] != OPTION_UNSET)) {
+	if(num_Speed > bd) {
 		DPRINTK(PROBE, INFO, "Speed not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
- 	if((Duplex[bd] != OPTION_UNSET)) {
+	if(num_Duplex > bd) {
 		DPRINTK(PROBE, INFO, "Duplex not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
- 	if((AutoNeg[bd] != OPTION_UNSET) && (AutoNeg[bd] != 0x20)) {
+	if((num_AutoNeg > bd) && (AutoNeg[bd] != 0x20)) {
 		DPRINTK(PROBE, INFO, "AutoNeg other than 1000/Full is "
 				 "not valid for fiber adapters, "
 				 "parameter ignored\n");
@@ -510,7 +562,7 @@ e1000_check_copper_options(struct e1000_
 {
 	int speed, dplx;
 	int bd = adapter->bd_number;
- 	bd = bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
 
 	{ /* Speed */
 		struct e1000_opt_list speed_list[] = {{          0, "" },
@@ -527,8 +581,12 @@ e1000_check_copper_options(struct e1000_
 					 .p = speed_list }}
 		};
 
-		speed = Speed[bd];
-		e1000_validate_option(&speed, &opt, adapter);
+		if (num_Speed > bd) {
+			speed = Speed[bd];
+			e1000_validate_option(&speed, &opt, adapter);
+		} else {
+			speed = opt.def;
+		}
 	}
 	{ /* Duplex */
 		struct e1000_opt_list dplx_list[] = {{           0, "" },
@@ -544,11 +602,16 @@ e1000_check_copper_options(struct e1000_
 					 .p = dplx_list }}
 		};
 
-		dplx = Duplex[bd];
-		e1000_validate_option(&dplx, &opt, adapter);
+		if (num_Duplex > bd) {
+			dplx = Duplex[bd];
+			e1000_validate_option(&dplx, &opt, adapter);
+		} else {
+			dplx = opt.def;
+		}
 	}
 
+	if((num_AutoNeg > bd) && (speed != 0 || dplx != 0)) {
- 	if(AutoNeg[bd] != OPTION_UNSET && (speed != 0 || dplx != 0)) {
 		DPRINTK(PROBE, INFO,
 		       "AutoNeg specified along with Speed or Duplex, "
 		       "parameter ignored\n");
@@ -605,6 +670,7 @@ e1000_check_copper_options(struct e1000_
 	switch (speed + dplx) {
 	case 0:
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		if((num_Speed > bd) && (speed != 0 || dplx != 0))
- 		if(Speed[bd] != OPTION_UNSET || Duplex[bd] != OPTION_UNSET)
 			DPRINTK(PROBE, INFO,
 			       "Speed and duplex autonegotiation enabled\n");
 		break;
