From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 07/26] e1000: Use module param array code
Date: Tue, 29 Aug 2006 09:44:29 -0700
Message-ID: <20060829164429.6872.84005.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:33802 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965082AbWH2QgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:16 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use module param array code to distinguish between defaults and user
specified values.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_param.c |  161 +++++++++++++++++++++++++++------------
 1 files changed, 110 insertions(+), 51 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 0ef4131..2128427 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -324,7 +324,6 @@ e1000_check_options(struct e1000_adapter
 		DPRINTK(PROBE, NOTICE,
 		       "Warning: no configuration for board #%i\n", bd);
 		DPRINTK(PROBE, NOTICE, "Using defaults for all values\n");
-		bd = E1000_MAX_NIC;
 	}
 
 	{ /* Transmit Descriptor Count */
@@ -342,9 +341,14 @@ e1000_check_options(struct e1000_adapter
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
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			tx_ring[i].count = tx_ring->count;
 	}
@@ -363,9 +367,14 @@ e1000_check_options(struct e1000_adapter
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
 		for (i = 0; i < adapter->num_rx_queues; i++)
 			rx_ring[i].count = rx_ring->count;
 	}
@@ -377,9 +386,13 @@ e1000_check_options(struct e1000_adapter
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
 
@@ -399,9 +412,13 @@ e1000_check_options(struct e1000_adapter
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
+			adapter->hw.fc = adapter->hw.original_fc = opt.def;
+		}
 	}
 	{ /* Transmit Interrupt Delay */
 		struct e1000_option opt = {
@@ -413,8 +430,13 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_TXDELAY }}
 		};
 
-		adapter->tx_int_delay = TxIntDelay[bd];
-		e1000_validate_option(&adapter->tx_int_delay, &opt, adapter);
+		if (num_TxIntDelay > bd) {
+			adapter->tx_int_delay = TxIntDelay[bd];
+			e1000_validate_option(&adapter->tx_int_delay, &opt,
+			                      adapter);
+		} else {
+			adapter->tx_int_delay = opt.def;
+		}
 	}
 	{ /* Transmit Absolute Interrupt Delay */
 		struct e1000_option opt = {
@@ -426,9 +448,13 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_TXABSDELAY }}
 		};
 
-		adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
-		e1000_validate_option(&adapter->tx_abs_int_delay, &opt,
-		                      adapter);
+		if (num_TxAbsIntDelay > bd) {
+			adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
+			e1000_validate_option(&adapter->tx_abs_int_delay, &opt,
+			                      adapter);
+		} else {
+			adapter->tx_abs_int_delay = opt.def;
+		}
 	}
 	{ /* Receive Interrupt Delay */
 		struct e1000_option opt = {
@@ -440,8 +466,13 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_RXDELAY }}
 		};
 
-		adapter->rx_int_delay = RxIntDelay[bd];
-		e1000_validate_option(&adapter->rx_int_delay, &opt, adapter);
+		if (num_RxIntDelay > bd) {
+			adapter->rx_int_delay = RxIntDelay[bd];
+			e1000_validate_option(&adapter->rx_int_delay, &opt,
+			                      adapter);
+		} else {
+			adapter->rx_int_delay = opt.def;
+		}
 	}
 	{ /* Receive Absolute Interrupt Delay */
 		struct e1000_option opt = {
@@ -453,9 +484,13 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_RXABSDELAY }}
 		};
 
-		adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
-		e1000_validate_option(&adapter->rx_abs_int_delay, &opt,
-		                      adapter);
+		if (num_RxAbsIntDelay > bd) {
+			adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
+			e1000_validate_option(&adapter->rx_abs_int_delay, &opt,
+			                      adapter);
+		} else {
+			adapter->rx_abs_int_delay = opt.def;
+		}
 	}
 	{ /* Interrupt Throttling Rate */
 		struct e1000_option opt = {
@@ -467,18 +502,24 @@ e1000_check_options(struct e1000_adapter
 					 .max = MAX_ITR }}
 		};
 
-		adapter->itr = InterruptThrottleRate[bd];
-		switch (adapter->itr) {
-		case 0:
-			DPRINTK(PROBE, INFO, "%s turned off\n", opt.name);
-			break;
-		case 1:
-			DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
-				opt.name);
-			break;
-		default:
-			e1000_validate_option(&adapter->itr, &opt, adapter);
-			break;
+		if (num_InterruptThrottleRate > bd) {
+			adapter->itr = InterruptThrottleRate[bd];
+			switch (adapter->itr) {
+			case 0:
+				DPRINTK(PROBE, INFO, "%s turned off\n",
+				        opt.name);
+				break;
+			case 1:
+				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
+				        opt.name);
+				break;
+			default:
+				e1000_validate_option(&adapter->itr, &opt,
+				                      adapter);
+				break;
+			}
+		} else {
+			adapter->itr = opt.def;
 		}
 	}
 	{ /* Smart Power Down */
@@ -489,9 +530,13 @@ e1000_check_options(struct e1000_adapter
 			.def  = OPTION_DISABLED
 		};
 
-		int spd = SmartPowerDownEnable[bd];
-		e1000_validate_option(&spd, &opt, adapter);
-		adapter->smart_power_down = spd;
+		if (num_SmartPowerDownEnable > bd) {
+			int spd = SmartPowerDownEnable[bd];
+			e1000_validate_option(&spd, &opt, adapter);
+			adapter->smart_power_down = spd;
+		} else {
+			adapter->smart_power_down = opt.def;
+		}
 	}
 	{ /* Kumeran Lock Loss Workaround */
 		struct e1000_option opt = {
@@ -501,9 +546,13 @@ e1000_check_options(struct e1000_adapter
 			.def  = OPTION_ENABLED
 		};
 
+		if (num_KumeranLockLoss > bd) {
 			int kmrn_lock_loss = KumeranLockLoss[bd];
 			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
 			adapter->hw.kmrn_lock_loss_workaround_disabled = !kmrn_lock_loss;
+		} else {
+			adapter->hw.kmrn_lock_loss_workaround_disabled = !opt.def;
+		}
 	}
 
 	switch (adapter->hw.media_type) {
@@ -530,18 +579,17 @@ static void __devinit
 e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
-	bd = bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
-	if ((Speed[bd] != OPTION_UNSET)) {
+	if (num_Speed > bd) {
 		DPRINTK(PROBE, INFO, "Speed not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
 
-	if ((Duplex[bd] != OPTION_UNSET)) {
+	if (num_Duplex > bd) {
 		DPRINTK(PROBE, INFO, "Duplex not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
 
-	if ((AutoNeg[bd] != OPTION_UNSET) && (AutoNeg[bd] != 0x20)) {
+	if ((num_AutoNeg > bd) && (AutoNeg[bd] != 0x20)) {
 		DPRINTK(PROBE, INFO, "AutoNeg other than 1000/Full is "
 				 "not valid for fiber adapters, "
 				 "parameter ignored\n");
@@ -560,7 +608,6 @@ e1000_check_copper_options(struct e1000_
 {
 	int speed, dplx, an;
 	int bd = adapter->bd_number;
-	bd = bd > E1000_MAX_NIC ? E1000_MAX_NIC : bd;
 
 	{ /* Speed */
 		struct e1000_opt_list speed_list[] = {{          0, "" },
@@ -577,8 +624,12 @@ e1000_check_copper_options(struct e1000_
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
@@ -600,11 +651,15 @@ e1000_check_copper_options(struct e1000_
 			        "Speed/Duplex/AutoNeg parameter ignored.\n");
 			return;
 		}
-		dplx = Duplex[bd];
-		e1000_validate_option(&dplx, &opt, adapter);
+		if (num_Duplex > bd) {
+			dplx = Duplex[bd];
+			e1000_validate_option(&dplx, &opt, adapter);
+		} else {
+			dplx = opt.def;
+		}
 	}
 
-	if (AutoNeg[bd] != OPTION_UNSET && (speed != 0 || dplx != 0)) {
+	if ((num_AutoNeg > bd) && (speed != 0 || dplx != 0)) {
 		DPRINTK(PROBE, INFO,
 		       "AutoNeg specified along with Speed or Duplex, "
 		       "parameter ignored\n");
@@ -653,15 +708,19 @@ e1000_check_copper_options(struct e1000_
 					 .p = an_list }}
 		};
 
-		an = AutoNeg[bd];
-		e1000_validate_option(&an, &opt, adapter);
+		if (num_AutoNeg > bd) {
+			an = AutoNeg[bd];
+			e1000_validate_option(&an, &opt, adapter);
+		} else {
+			an = opt.def;
+		}
 		adapter->hw.autoneg_advertised = an;
 	}
 
 	switch (speed + dplx) {
 	case 0:
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		if (Speed[bd] != OPTION_UNSET || Duplex[bd] != OPTION_UNSET)
+		if ((num_Speed > bd) && (speed != 0 || dplx != 0))
 			DPRINTK(PROBE, INFO,
 			       "Speed and duplex autonegotiation enabled\n");
 		break;



---
Auke Kok <auke-jan.h.kok@intel.com>
