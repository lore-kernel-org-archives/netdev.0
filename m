From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 8/9] ixgb: Support for 2.6.x style module parameters
Date: Thu, 6 Jan 2005 17:26:26 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061555280.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_param.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_param.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_param.c	2005-01-05 18:01:29.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_param.c	2005-01-05 18:01:31.000000000 -0800
@@ -38,27 +38,17 @@
 #define OPTION_DISABLED 0
 #define OPTION_ENABLED  1
 
-/* Module Parameters are always initialized to -1, so that the driver
- * can tell the difference between no user specified value or the
- * user asking for the default value.
- * The true default values are loaded in when ixgb_check_options is called.
- *
- * This is a GCC extension to ANSI C.
- * See the item "Labeled Elements in Initializers" in the section
- * "Extensions to the C Language Family" of the GCC documentation.
- */
-
-#define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
-
 /* All parameters are treated the same, as an integer array of values.
  * This macro just reduces the need to repeat the same declaration code
  * over and over (plus this helps to avoid typo bugs).
  */
 
-#define IXGB_PARAM(X, S) \
-static const int __devinitdata X[IXGB_MAX_NIC + 1] = IXGB_PARAM_INIT; \
-MODULE_PARM(X, "1-" __MODULE_STRING(IXGB_MAX_NIC) "i"); \
-MODULE_PARM_DESC(X, S);
+#define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
+#define IXGB_PARAM(X, desc) \
+	static int __devinitdata X[IXGB_MAX_NIC+1] = IXGB_PARAM_INIT; \
+	static int num_##X = 0; \
+	module_param_array_named(X, X, int, &num_##X, 0); \
+	MODULE_PARM_DESC(X, desc);
 
 /* Transmit Descriptor Count
  *
@@ -275,7 +265,6 @@ ixgb_check_options(struct ixgb_adapter *
 		printk(KERN_NOTICE
 			   "Warning: no configuration for board #%i\n", bd);
 		printk(KERN_NOTICE "Using defaults for all values\n");
-		bd = IXGB_MAX_NIC;
 	}
 
 	{ /* Transmit Descriptor Count */
@@ -289,8 +278,12 @@ ixgb_check_options(struct ixgb_adapter *
 		};
 		struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 
-		tx_ring->count = TxDescriptors[bd];
-		ixgb_validate_option(&tx_ring->count, &opt);
+		if (num_TxDescriptors > bd) {
+			tx_ring->count = TxDescriptors[bd];
+			ixgb_validate_option(&tx_ring->count, &opt);
+		} else {
+			tx_ring->count = opt.def;
+		}
 		IXGB_ROUNDUP(tx_ring->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Descriptor Count */
@@ -304,8 +297,12 @@ ixgb_check_options(struct ixgb_adapter *
 		};
 		struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 
-		rx_ring->count = RxDescriptors[bd];
-		ixgb_validate_option(&rx_ring->count, &opt);
+		if (num_RxDescriptors > bd) {
+			rx_ring->count = RxDescriptors[bd];
+			ixgb_validate_option(&rx_ring->count, &opt);
+		} else {
+			rx_ring->count = opt.def;
+		}
 		IXGB_ROUNDUP(rx_ring->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Checksum Offload Enable */
@@ -316,9 +313,13 @@ ixgb_check_options(struct ixgb_adapter *
 			.def  = OPTION_ENABLED
 		};
 
-		int rx_csum = XsumRX[bd];
-		ixgb_validate_option(&rx_csum, &opt);
-		adapter->rx_csum = rx_csum;
+		if (num_XsumRX > bd) {
+			int rx_csum = XsumRX[bd];
+			ixgb_validate_option(&rx_csum, &opt);
+			adapter->rx_csum = rx_csum;
+		} else {
+			adapter->rx_csum = opt.def;
+		}
 	}
 	{ /* Flow Control */
 
@@ -338,23 +339,30 @@ ixgb_check_options(struct ixgb_adapter *
 					 .p = fc_list }}
 		};
 
-		int fc = FlowControl[bd];
-		ixgb_validate_option(&fc, &opt);
-		adapter->hw.fc.type = fc;
+		if (num_FlowControl > bd) {
+			int fc = FlowControl[bd];
+			ixgb_validate_option(&fc, &opt);
+			adapter->hw.fc.type = fc;
+		} else {
+			adapter->hw.fc.type = opt.def;
+		}
 	}
 	{ /* Receive Flow Control High Threshold */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control High Threshold",
-			.err =
-			    "using default of " __MODULE_STRING(DEFAULT_FCRTH),
-			.def = DEFAULT_FCRTH,
-			.arg = {.r = {.min = MIN_FCRTH,
-				      .max = MAX_FCRTH}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_FCRTH),
+			.def  = DEFAULT_FCRTH,
+			.arg  = { .r = { .min = MIN_FCRTH,
+					 .max = MAX_FCRTH}}
 		};
 
-		adapter->hw.fc.high_water = RxFCHighThresh[bd];
-		ixgb_validate_option(&adapter->hw.fc.high_water, &opt);
+		if (num_RxFCHighThresh > bd) {
+			adapter->hw.fc.high_water = RxFCHighThresh[bd];
+			ixgb_validate_option(&adapter->hw.fc.high_water, &opt);
+		} else {
+			adapter->hw.fc.high_water = opt.def;
+		}
 		if ( !(adapter->hw.fc.type & ixgb_fc_rx_pause) )
 			printk (KERN_INFO 
 				"Ignoring RxFCHighThresh when no RxFC\n");
@@ -363,15 +371,18 @@ ixgb_check_options(struct ixgb_adapter *
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control Low Threshold",
-			.err =
-			    "using default of " __MODULE_STRING(DEFAULT_FCRTL),
-			.def = DEFAULT_FCRTL,
-			.arg = {.r = {.min = MIN_FCRTL,
-				      .max = MAX_FCRTL}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_FCRTL),
+			.def  = DEFAULT_FCRTL,
+			.arg  = { .r = { .min = MIN_FCRTL,
+					 .max = MAX_FCRTL}}
 		};
 
-		adapter->hw.fc.low_water = RxFCLowThresh[bd];
-		ixgb_validate_option(&adapter->hw.fc.low_water, &opt);
+		if (num_RxFCLowThresh > bd) {
+			adapter->hw.fc.low_water = RxFCLowThresh[bd];
+			ixgb_validate_option(&adapter->hw.fc.low_water, &opt);
+		} else {
+			adapter->hw.fc.low_water = opt.def;
+		}
 		if ( !(adapter->hw.fc.type & ixgb_fc_rx_pause) )
 			printk (KERN_INFO 
 				"Ignoring RxFCLowThresh when no RxFC\n");
@@ -380,21 +391,22 @@ ixgb_check_options(struct ixgb_adapter *
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Flow Control Pause Time Request",
-			.err =
-			    "using default of "
-			    __MODULE_STRING(DEFAULT_FCPAUSE),
-			.def = DEFAULT_FCPAUSE,
-			.arg = {.r = {.min = MIN_FCPAUSE,
-				      .max = MAX_FCPAUSE}}
+			.err  = "using default of "__MODULE_STRING(DEFAULT_FCPAUSE),
+			.def  = DEFAULT_FCPAUSE,
+			.arg = { .r = { .min = MIN_FCPAUSE,
+					.max = MAX_FCPAUSE}}
 		};
 
-		int pause_time = FCReqTimeout[bd];
-
-		ixgb_validate_option(&pause_time, &opt);
+		if (num_FCReqTimeout > bd) {
+			int pause_time = FCReqTimeout[bd];
+			ixgb_validate_option(&pause_time, &opt);
+			adapter->hw.fc.pause_time = pause_time;
+		} else {
+			adapter->hw.fc.pause_time = opt.def;
+		}
 		if ( !(adapter->hw.fc.type & ixgb_fc_rx_pause) )
 			printk (KERN_INFO 
 				"Ignoring FCReqTimeout when no RxFC\n");
-		adapter->hw.fc.pause_time = pause_time;
 	}
 	/* high low and spacing check for rx flow control thresholds */
 	if (adapter->hw.fc.type & ixgb_fc_rx_pause) {
@@ -412,28 +424,35 @@ ixgb_check_options(struct ixgb_adapter *
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Interrupt Delay",
-			.err = "using default of " __MODULE_STRING(DEFAULT_RDTR),
-			.def = DEFAULT_RDTR,
-			.arg = { .r = { .min = MIN_RDTR,
+			.err  = "using default of " __MODULE_STRING(DEFAULT_RDTR),
+			.def  = DEFAULT_RDTR,
+			.arg  = { .r = { .min = MIN_RDTR,
 					 .max = MAX_RDTR}}
 		};
 
-		adapter->rx_int_delay = RxIntDelay[bd];
-		ixgb_validate_option(&adapter->rx_int_delay, &opt);
-	}
+		if (num_RxIntDelay > bd) {
+			adapter->rx_int_delay = RxIntDelay[bd];
+			ixgb_validate_option(&adapter->rx_int_delay, &opt);
+		} else {
+			adapter->rx_int_delay = opt.def;
+		}
 	}
 	{ /* Transmit Interrupt Delay */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Interrupt Delay",
-			.err = "using default of " __MODULE_STRING(DEFAULT_TIDV),
-			.def = DEFAULT_TIDV,
-			.arg = { .r = { .min = MIN_TIDV,
+			.err  = "using default of " __MODULE_STRING(DEFAULT_TIDV),
+			.def  = DEFAULT_TIDV,
+			.arg  = { .r = { .min = MIN_TIDV,
 					 .max = MAX_TIDV}}
 		};
 
-		adapter->tx_int_delay = TxIntDelay[bd];
-		ixgb_validate_option(&adapter->tx_int_delay, &opt);
+		if (num_TxIntDelay > bd) {
+			adapter->tx_int_delay = TxIntDelay[bd];
+			ixgb_validate_option(&adapter->tx_int_delay, &opt);
+		} else {
+			adapter->tx_int_delay = opt.def;
+		}
 	}
 
 	{ /* Transmit Interrupt Delay Enable */
@@ -443,9 +462,14 @@ ixgb_check_options(struct ixgb_adapter *
 			.err  = "defaulting to Enabled",
 			.def  = OPTION_ENABLED
 		};
-		int ide = IntDelayEnable[bd];
 
-		ixgb_validate_option(&ide, &opt);
-		adapter->tx_int_delay_enable = ide;
+		if (num_IntDelayEnable > bd) {
+			int ide = IntDelayEnable[bd];
+			ixgb_validate_option(&ide, &opt);
+			adapter->tx_int_delay_enable = ide;
+		} else {
+			adapter->tx_int_delay_enable = opt.def;
+		}
 	}
 }
+
