From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 09/21] e1000: rework module param code with uninitialized values
Date: Wed, 21 Jun 2006 22:20:25 -0700
Message-ID: <20060622052025.25497.98226.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:51208 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932804AbWFVFO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:27 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We can take uninitialized values into account which minimizes code
and allows us to simplify the parameter checking code greatly.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_param.c |  167 ++++++++++++++-------------------------
 1 files changed, 61 insertions(+), 106 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index a8d9295..bd6c040 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -45,6 +45,16 @@
  */
 
 #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
+/* Module Parameters are always initialized to -1, so that the driver
+ * can tell the difference between no user specified value or the
+ * user asking for the default value.
+ * The true default values are loaded in when e1000_check_options is called.
+ *
+ * This is a GCC extension to ANSI C.
+ * See the item "Labeled Elements in Initializers" in the section
+ * "Extensions to the C Language Family" of the GCC documentation.
+ */
+
 #define E1000_PARAM(X, desc) \
 	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
 	static int num_##X = 0; \
@@ -305,6 +315,7 @@ e1000_check_options(struct e1000_adapter
 		DPRINTK(PROBE, NOTICE,
 		       "Warning: no configuration for board #%i\n", bd);
 		DPRINTK(PROBE, NOTICE, "Using defaults for all values\n");
+		bd = E1000_MAX_NIC;
 	}
 
 	{ /* Transmit Descriptor Count */
@@ -322,14 +333,9 @@ e1000_check_options(struct e1000_adapter
 		opt.arg.r.max = mac_type < e1000_82544 ?
 			E1000_MAX_TXD : E1000_MAX_82544_TXD;
 
-		if (num_TxDescriptors > bd) {
-			tx_ring->count = TxDescriptors[bd];
-			e1000_validate_option(&tx_ring->count, &opt, adapter);
-			E1000_ROUNDUP(tx_ring->count,
-						REQ_TX_DESCRIPTOR_MULTIPLE);
-		} else {
-			tx_ring->count = opt.def;
-		}
+		tx_ring->count = TxDescriptors[bd];
+		e1000_validate_option(&tx_ring->count, &opt, adapter);
+		E1000_ROUNDUP(tx_ring->count, REQ_TX_DESCRIPTOR_MULTIPLE);
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			tx_ring[i].count = tx_ring->count;
 	}
@@ -348,14 +354,9 @@ e1000_check_options(struct e1000_adapter
 		opt.arg.r.max = mac_type < e1000_82544 ? E1000_MAX_RXD :
 			E1000_MAX_82544_RXD;
 
-		if (num_RxDescriptors > bd) {
-			rx_ring->count = RxDescriptors[bd];
-			e1000_validate_option(&rx_ring->count, &opt, adapter);
-			E1000_ROUNDUP(rx_ring->count,
-						REQ_RX_DESCRIPTOR_MULTIPLE);
-		} else {
-			rx_ring->count = opt.def;
-		}
+		rx_ring->count = RxDescriptors[bd];
+		e1000_validate_option(&rx_ring->count, &opt, adapter);
+		E1000_ROUNDUP(rx_ring->count, REQ_RX_DESCRIPTOR_MULTIPLE);
 		for (i = 0; i < adapter->num_rx_queues; i++)
 			rx_ring[i].count = rx_ring->count;
 	}
@@ -367,13 +368,9 @@ e1000_check_options(struct e1000_adapter
 			.def  = OPTION_ENABLED
 		};
 
-		if (num_XsumRX > bd) {
-			int rx_csum = XsumRX[bd];
-			e1000_validate_option(&rx_csum, &opt, adapter);
-			adapter->rx_csum = rx_csum;
-		} else {
-			adapter->rx_csum = opt.def;
-		}
+		int rx_csum = XsumRX[bd];
+		e1000_validate_option(&rx_csum, &opt, adapter);
+		adapter->rx_csum = rx_csum;
 	}
 	{ /* Flow Control */
 
@@ -393,13 +390,9 @@ e1000_check_options(struct e1000_adapter
 					 .p = fc_list }}
 		};
 
-		if (num_FlowControl > bd) {
-			int fc = FlowControl[bd];
-			e1000_validate_option(&fc, &opt, adapter);
-			adapter->hw.fc = adapter->hw.original_fc = fc;
-		} else {
-			adapter->hw.fc = adapter->hw.original_fc = opt.def;
-		}
+		int fc = FlowControl[bd];
+		e1000_validate_option(&fc, &opt, adapter);
+		adapter->hw.fc = adapter->hw.original_fc = fc;
 	}
 	{ /* Transmit Interrupt Delay */
 		struct e1000_option opt = {
@@ -411,13 +404,8 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_TXDELAY }}
 		};
 
-		if (num_TxIntDelay > bd) {
-			adapter->tx_int_delay = TxIntDelay[bd];
-			e1000_validate_option(&adapter->tx_int_delay, &opt,
-								adapter);
-		} else {
-			adapter->tx_int_delay = opt.def;
-		}
+		adapter->tx_int_delay = TxIntDelay[bd];
+		e1000_validate_option(&adapter->tx_int_delay, &opt, adapter);
 	}
 	{ /* Transmit Absolute Interrupt Delay */
 		struct e1000_option opt = {
@@ -429,13 +417,9 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_TXABSDELAY }}
 		};
 
-		if (num_TxAbsIntDelay > bd) {
-			adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
-			e1000_validate_option(&adapter->tx_abs_int_delay, &opt,
-								adapter);
-		} else {
-			adapter->tx_abs_int_delay = opt.def;
-		}
+		adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
+		e1000_validate_option(&adapter->tx_abs_int_delay, &opt,
+		                      adapter);
 	}
 	{ /* Receive Interrupt Delay */
 		struct e1000_option opt = {
@@ -447,13 +431,8 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_RXDELAY }}
 		};
 
-		if (num_RxIntDelay > bd) {
-			adapter->rx_int_delay = RxIntDelay[bd];
-			e1000_validate_option(&adapter->rx_int_delay, &opt,
-								adapter);
-		} else {
-			adapter->rx_int_delay = opt.def;
-		}
+		adapter->rx_int_delay = RxIntDelay[bd];
+		e1000_validate_option(&adapter->rx_int_delay, &opt, adapter);
 	}
 	{ /* Receive Absolute Interrupt Delay */
 		struct e1000_option opt = {
@@ -465,13 +444,9 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_RXABSDELAY }}
 		};
 
-		if (num_RxAbsIntDelay > bd) {
-			adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
-			e1000_validate_option(&adapter->rx_abs_int_delay, &opt,
-								adapter);
-		} else {
-			adapter->rx_abs_int_delay = opt.def;
-		}
+		adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
+		e1000_validate_option(&adapter->rx_abs_int_delay, &opt,
+		                      adapter);
 	}
 	{ /* Interrupt Throttling Rate */
 		struct e1000_option opt = {
@@ -483,24 +458,18 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_ITR }}
 		};
 
-		if (num_InterruptThrottleRate > bd) {
-			adapter->itr = InterruptThrottleRate[bd];
-			switch (adapter->itr) {
-			case 0:
-				DPRINTK(PROBE, INFO, "%s turned off\n",
-					opt.name);
-				break;
-			case 1:
-				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
-					opt.name);
-				break;
-			default:
-				e1000_validate_option(&adapter->itr, &opt,
-					adapter);
-				break;
-			}
-		} else {
-			adapter->itr = opt.def;
+		adapter->itr = InterruptThrottleRate[bd];
+		switch (adapter->itr) {
+		case 0:
+			DPRINTK(PROBE, INFO, "%s turned off\n", opt.name);
+			break;
+		case 1:
+			DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
+				opt.name);
+			break;
+		default:
+			e1000_validate_option(&adapter->itr, &opt, adapter);
+			break;
 		}
 	}
 	{ /* Smart Power Down */
@@ -511,13 +480,9 @@ e1000_check_options(struct e1000_adapter
 			.def  = OPTION_DISABLED
 		};
 
-		if (num_SmartPowerDownEnable > bd) {
-			int spd = SmartPowerDownEnable[bd];
-			e1000_validate_option(&spd, &opt, adapter);
-			adapter->smart_power_down = spd;
-		} else {
-			adapter->smart_power_down = opt.def;
-		}
+		int spd = SmartPowerDownEnable[bd];
+		e1000_validate_option(&spd, &opt, adapter);
+		adapter->smart_power_down = spd;
 	}
 
 	switch (adapter->hw.media_type) {
@@ -544,17 +509,18 @@ static void __devinit
 e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
-	if (num_Speed > bd) {
+	bd = bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
+	if ((Speed[bd] != OPTION_UNSET)) {
 		DPRINTK(PROBE, INFO, "Speed not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
 
-	if (num_Duplex > bd) {
+	if ((Duplex[bd] != OPTION_UNSET)) {
 		DPRINTK(PROBE, INFO, "Duplex not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
 
-	if ((num_AutoNeg > bd) && (AutoNeg[bd] != 0x20)) {
+	if ((AutoNeg[bd] != OPTION_UNSET) && (AutoNeg[bd] != 0x20)) {
 		DPRINTK(PROBE, INFO, "AutoNeg other than 1000/Full is "
 				 "not valid for fiber adapters, "
 				 "parameter ignored\n");
@@ -573,6 +539,7 @@ e1000_check_copper_options(struct e1000_
 {
 	int speed, dplx, an;
 	int bd = adapter->bd_number;
+	bd = bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
 
 	{ /* Speed */
 		struct e1000_opt_list speed_list[] = {{          0, "" },
@@ -589,12 +556,8 @@ e1000_check_copper_options(struct e1000_
 					 .p = speed_list }}
 		};
 
-		if (num_Speed > bd) {
-			speed = Speed[bd];
-			e1000_validate_option(&speed, &opt, adapter);
-		} else {
-			speed = opt.def;
-		}
+		speed = Speed[bd];
+		e1000_validate_option(&speed, &opt, adapter);
 	}
 	{ /* Duplex */
 		struct e1000_opt_list dplx_list[] = {{           0, "" },
@@ -616,15 +579,11 @@ e1000_check_copper_options(struct e1000_
 			        "Speed/Duplex/AutoNeg parameter ignored.\n");
 			return;
 		}
-		if (num_Duplex > bd) {
-			dplx = Duplex[bd];
-			e1000_validate_option(&dplx, &opt, adapter);
-		} else {
-			dplx = opt.def;
-		}
+		dplx = Duplex[bd];
+		e1000_validate_option(&dplx, &opt, adapter);
 	}
 
-	if ((num_AutoNeg > bd) && (speed != 0 || dplx != 0)) {
+	if (AutoNeg[bd] != OPTION_UNSET && (speed != 0 || dplx != 0)) {
 		DPRINTK(PROBE, INFO,
 		       "AutoNeg specified along with Speed or Duplex, "
 		       "parameter ignored\n");
@@ -673,19 +632,15 @@ e1000_check_copper_options(struct e1000_
 					 .p = an_list }}
 		};
 
-		if (num_AutoNeg > bd) {
-			an = AutoNeg[bd];
-			e1000_validate_option(&an, &opt, adapter);
-		} else {
-			an = opt.def;
-		}
+		an = AutoNeg[bd];
+		e1000_validate_option(&an, &opt, adapter);
 		adapter->hw.autoneg_advertised = an;
 	}
 
 	switch (speed + dplx) {
 	case 0:
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		if ((num_Speed > bd) && (speed != 0 || dplx != 0))
+		if (Speed[bd] != OPTION_UNSET || Duplex[bd] != OPTION_UNSET)
 			DPRINTK(PROBE, INFO,
 			       "Speed and duplex autonegotiation enabled\n");
 		break;



--
Auke Kok <auke-jan.h.kok@intel.com>
