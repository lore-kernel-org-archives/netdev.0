From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 2/5 2.4] e1000 - Fix MODULE_PARM, module_param and
 module_param_array usage
Date: Fri, 17 Sep 2004 02:55:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170218100.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_param.c linux-2.4/drivers/net/e1000.new/e1000_param.c
--- linux-2.4/drivers/net/e1000/e1000_param.c	2004-09-16 23:06:05.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_param.c	2004-09-16 23:06:07.000000000 -0700
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
@@ -48,17 +54,10 @@
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
+	static const int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
+	MODULE_PARM(X, "1-" __MODULE_STRING(E1000_MAX_NIC) "i"); \
+	MODULE_PARM_DESC(X, desc);
 
 /* Transmit Descriptor Count
  *
@@ -212,7 +211,7 @@ E1000_PARAM(InterruptThrottleRate, "Inte
 #define MAX_TXABSDELAY            0xFFFF
 #define MIN_TXABSDELAY                 0
 
-#define DEFAULT_ITR                 8000
+#define DEFAULT_ITR                    1
 #define MAX_ITR                   100000
 #define MIN_ITR                      100
 
@@ -235,7 +234,7 @@ struct e1000_option {
 
 static int __devinit
 e1000_validate_option(int *value, struct e1000_option *opt,
-	struct e1000_adapter *adapter)
+		struct e1000_adapter *adapter)
 {
 	if(*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -256,7 +255,7 @@ e1000_validate_option(int *value, struct
 	case range_option:
 		if(*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
 			DPRINTK(PROBE, INFO,
-				"%s set to %i\n", opt->name, *value);
+					"%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
@@ -322,9 +321,10 @@ e1000_check_options(struct e1000_adapter
 		opt.arg.r.max = mac_type < e1000_82544 ?
 			E1000_MAX_TXD : E1000_MAX_82544_TXD;
 
-		tx_ring->count = TxDescriptors[bd];
-		e1000_validate_option(&tx_ring->count, &opt, adapter);
-		E1000_ROUNDUP(tx_ring->count, REQ_TX_DESCRIPTOR_MULTIPLE);
+			tx_ring->count = TxDescriptors[bd];
+			e1000_validate_option(&tx_ring->count, &opt, adapter);
+			E1000_ROUNDUP(tx_ring->count, 
+						REQ_TX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Descriptor Count */
 		struct e1000_option opt = {
@@ -340,9 +340,10 @@ e1000_check_options(struct e1000_adapter
 		opt.arg.r.max = mac_type < e1000_82544 ? E1000_MAX_RXD :
 			E1000_MAX_82544_RXD;
 
-		rx_ring->count = RxDescriptors[bd];
-		e1000_validate_option(&rx_ring->count, &opt, adapter);
-		E1000_ROUNDUP(rx_ring->count, REQ_RX_DESCRIPTOR_MULTIPLE);
+			rx_ring->count = RxDescriptors[bd];
+			e1000_validate_option(&rx_ring->count, &opt, adapter);
+			E1000_ROUNDUP(rx_ring->count, 
+						REQ_RX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Checksum Offload Enable/Disable */
 		struct e1000_option opt = {
@@ -352,9 +353,9 @@ e1000_check_options(struct e1000_adapter
 			.def  = OPTION_ENABLED
 		};
 
-		int rx_csum = XsumRX[bd];
-		e1000_validate_option(&rx_csum, &opt, adapter);
-		adapter->rx_csum = rx_csum;
+			int rx_csum = XsumRX[bd];
+			e1000_validate_option(&rx_csum, &opt, adapter);
+			adapter->rx_csum = rx_csum;
 	}
 	{ /* Flow Control */
 
@@ -374,9 +375,9 @@ e1000_check_options(struct e1000_adapter
 					 .p = fc_list }}
 		};
 
-		int fc = FlowControl[bd];
-		e1000_validate_option(&fc, &opt, adapter);
-		adapter->hw.fc = adapter->hw.original_fc = fc;
+			int fc = FlowControl[bd];
+			e1000_validate_option(&fc, &opt, adapter);
+			adapter->hw.fc = adapter->hw.original_fc = fc;
 	}
 	{ /* Transmit Interrupt Delay */
 		struct e1000_option opt = {
@@ -388,8 +389,9 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_TXDELAY }}
 		};
 
-		adapter->tx_int_delay = TxIntDelay[bd];
-		e1000_validate_option(&adapter->tx_int_delay, &opt, adapter);
+			adapter->tx_int_delay = TxIntDelay[bd];
+			e1000_validate_option(&adapter->tx_int_delay, &opt, 
+								adapter);
 	}
 	{ /* Transmit Absolute Interrupt Delay */
 		struct e1000_option opt = {
@@ -401,8 +403,9 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_TXABSDELAY }}
 		};
 
-		adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
-		e1000_validate_option(&adapter->tx_abs_int_delay, &opt, adapter);
+			adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
+			e1000_validate_option(&adapter->tx_abs_int_delay, &opt, 
+								adapter);
 	}
 	{ /* Receive Interrupt Delay */
 		struct e1000_option opt = {
@@ -414,8 +417,9 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_RXDELAY }}
 		};
 
-		adapter->rx_int_delay = RxIntDelay[bd];
-		e1000_validate_option(&adapter->rx_int_delay, &opt, adapter);
+			adapter->rx_int_delay = RxIntDelay[bd];
+			e1000_validate_option(&adapter->rx_int_delay, &opt, 
+								adapter);
 	}
 	{ /* Receive Absolute Interrupt Delay */
 		struct e1000_option opt = {
@@ -427,8 +431,9 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_RXABSDELAY }}
 		};
 
-		adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
-		e1000_validate_option(&adapter->rx_abs_int_delay, &opt, adapter);
+			adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
+			e1000_validate_option(&adapter->rx_abs_int_delay, &opt, 
+								adapter);
 	}
 	{ /* Interrupt Throttling Rate */
 		struct e1000_option opt = {
@@ -440,22 +445,24 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_ITR }}
 		};
 
-		adapter->itr = InterruptThrottleRate[bd];
-		switch(adapter->itr) {
-		case -1:
-			adapter->itr = 1;
-			break;
-		case 0:
-			DPRINTK(PROBE, INFO, "%s turned off\n", opt.name);
-			break;
-		case 1:
-			DPRINTK(PROBE, INFO,
-				"%s set to dynamic mode\n", opt.name);
-			break;
-		default:
-			e1000_validate_option(&adapter->itr, &opt, adapter);
-			break;
-		}
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
 	}
 
 	switch(adapter->hw.media_type) {
@@ -483,18 +490,20 @@ e1000_check_fiber_options(struct e1000_a
 {
 	int bd = adapter->bd_number;
 	bd = bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
-
 	if((Speed[bd] != OPTION_UNSET)) {
 		DPRINTK(PROBE, INFO, "Speed not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
+
 	if((Duplex[bd] != OPTION_UNSET)) {
 		DPRINTK(PROBE, INFO, "Duplex not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
+
 	if((AutoNeg[bd] != OPTION_UNSET) && (AutoNeg[bd] != 0x20)) {
-		DPRINTK(PROBE, INFO, "AutoNeg other than Full/1000 is "
-		       "not valid for fiber adapters, parameter ignored\n");
+		DPRINTK(PROBE, INFO, "AutoNeg other than 1000/Full is "
+				 "not valid for fiber adapters, "
+				 "parameter ignored\n");
 	}
 }
 
@@ -527,8 +536,8 @@ e1000_check_copper_options(struct e1000_
 					 .p = speed_list }}
 		};
 
-		speed = Speed[bd];
-		e1000_validate_option(&speed, &opt, adapter);
+			speed = Speed[bd];
+			e1000_validate_option(&speed, &opt, adapter);
 	}
 	{ /* Duplex */
 		struct e1000_opt_list dplx_list[] = {{           0, "" },
@@ -544,8 +553,8 @@ e1000_check_copper_options(struct e1000_
 					 .p = dplx_list }}
 		};
 
-		dplx = Duplex[bd];
-		e1000_validate_option(&dplx, &opt, adapter);
+			dplx = Duplex[bd];
+			e1000_validate_option(&dplx, &opt, adapter);
 	}
 
 	if(AutoNeg[bd] != OPTION_UNSET && (speed != 0 || dplx != 0)) {
@@ -611,24 +620,24 @@ e1000_check_copper_options(struct e1000_
 		break;
 	case HALF_DUPLEX:
 		DPRINTK(PROBE, INFO, "Half Duplex specified without Speed\n");
-		DPRINTK(PROBE, INFO,
-			"Using Autonegotiation at Half Duplex only\n");
+		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+			"Half Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 		                                 ADVERTISE_100_HALF;
 		break;
 	case FULL_DUPLEX:
 		DPRINTK(PROBE, INFO, "Full Duplex specified without Speed\n");
-		DPRINTK(PROBE, INFO,
-			"Using Autonegotiation at Full Duplex only\n");
+		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+			"Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_FULL |
 		                                 ADVERTISE_100_FULL |
 		                                 ADVERTISE_1000_FULL;
 		break;
 	case SPEED_10:
-		DPRINTK(PROBE, INFO,
-			"10 Mbps Speed specified without Duplex\n");
+		DPRINTK(PROBE, INFO, "10 Mbps Speed specified "
+			"without Duplex\n");
 		DPRINTK(PROBE, INFO, "Using Autonegotiation at 10 Mbps only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
@@ -647,10 +656,10 @@ e1000_check_copper_options(struct e1000_
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100:
-		DPRINTK(PROBE, INFO,
-			"100 Mbps Speed specified without Duplex\n");
-		DPRINTK(PROBE, INFO,
-			"Using Autonegotiation at 100 Mbps only\n");
+		DPRINTK(PROBE, INFO, "100 Mbps Speed specified "
+			"without Duplex\n");
+		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
+			"100 Mbps only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_100_HALF |
 		                                 ADVERTISE_100_FULL;
@@ -668,10 +677,11 @@ e1000_check_copper_options(struct e1000_
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_1000:
+		DPRINTK(PROBE, INFO, "1000 Mbps Speed specified without "
+			"Duplex\n");
 		DPRINTK(PROBE, INFO,
-			"1000 Mbps Speed specified without Duplex\n");
-		DPRINTK(PROBE, INFO,
-		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
+			"Using Autonegotiation at 1000 Mbps "
+			"Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
@@ -679,7 +689,8 @@ e1000_check_copper_options(struct e1000_
 		DPRINTK(PROBE, INFO,
 			"Half Duplex is not supported at 1000 Mbps\n");
 		DPRINTK(PROBE, INFO,
-		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
+			"Using Autonegotiation at 1000 Mbps "
+			"Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
@@ -696,8 +707,8 @@ e1000_check_copper_options(struct e1000_
 	/* Speed, AutoNeg and MDI/MDI-X must all play nice */
 	if (e1000_validate_mdi_setting(&(adapter->hw)) < 0) {
 		DPRINTK(PROBE, INFO,
-		       "Speed, AutoNeg and MDI-X specifications are "
-		       "incompatible. Setting MDI-X to a compatible value.\n");
+			"Speed, AutoNeg and MDI-X specifications are "
+			"incompatible. Setting MDI-X to a compatible value.\n");
 	}
 }
 
