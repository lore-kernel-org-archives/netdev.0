From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000: fix stack size
Date: Wed, 27 Aug 2008 01:14:46 -0700
Message-ID: <20080827081446.9269.19136.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:19546 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbYH0IOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 04:14:48 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2533946rvb.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 01:14:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

Here's the patch. It shrinks the stack from 1152 bytes to 192 bytes (the
first version, that only did the e1000_option part, got it down to 600
bytes). About half comes from not using multiple "e1000_option"
structures, the other half comes from turning the "e1000_opt_list[]"
arrays into "static const" instead, so that gcc doesn't copy them onto the
stack.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Reveiewed-by: Auke Kok <auke-jan.h.kok@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_param.c |   81 ++++++++++++++++++++++-----------------
 1 files changed, 45 insertions(+), 36 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index b9f90a5..213437d 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -208,7 +208,7 @@ struct e1000_option {
 		} r;
 		struct { /* list_option info */
 			int nr;
-			struct e1000_opt_list { int i; char *str; } *p;
+			const struct e1000_opt_list { int i; char *str; } *p;
 		} l;
 	} arg;
 };
@@ -242,7 +242,7 @@ static int __devinit e1000_validate_option(unsigned int *value,
 		break;
 	case list_option: {
 		int i;
-		struct e1000_opt_list *ent;
+		const struct e1000_opt_list *ent;
 
 		for (i = 0; i < opt->arg.l.nr; i++) {
 			ent = &opt->arg.l.p[i];
@@ -279,7 +279,9 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter);
 
 void __devinit e1000_check_options(struct e1000_adapter *adapter)
 {
+	struct e1000_option opt;
 	int bd = adapter->bd_number;
+
 	if (bd >= E1000_MAX_NIC) {
 		DPRINTK(PROBE, NOTICE,
 		       "Warning: no configuration for board #%i\n", bd);
@@ -287,19 +289,21 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 	}
 
 	{ /* Transmit Descriptor Count */
-		struct e1000_option opt = {
+		struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+		int i;
+		e1000_mac_type mac_type = adapter->hw.mac_type;
+
+		opt = (struct e1000_option) {
 			.type = range_option,
 			.name = "Transmit Descriptors",
 			.err  = "using default of "
 				__MODULE_STRING(E1000_DEFAULT_TXD),
 			.def  = E1000_DEFAULT_TXD,
-			.arg  = { .r = { .min = E1000_MIN_TXD }}
+			.arg  = { .r = {
+				.min = E1000_MIN_TXD,
+				.max = mac_type < e1000_82544 ? E1000_MAX_TXD : E1000_MAX_82544_TXD
+				}}
 		};
-		struct e1000_tx_ring *tx_ring = adapter->tx_ring;
-		int i;
-		e1000_mac_type mac_type = adapter->hw.mac_type;
-		opt.arg.r.max = mac_type < e1000_82544 ?
-			E1000_MAX_TXD : E1000_MAX_82544_TXD;
 
 		if (num_TxDescriptors > bd) {
 			tx_ring->count = TxDescriptors[bd];
@@ -313,19 +317,21 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 			tx_ring[i].count = tx_ring->count;
 	}
 	{ /* Receive Descriptor Count */
-		struct e1000_option opt = {
+		struct e1000_rx_ring *rx_ring = adapter->rx_ring;
+		int i;
+		e1000_mac_type mac_type = adapter->hw.mac_type;
+
+		opt = (struct e1000_option) {
 			.type = range_option,
 			.name = "Receive Descriptors",
 			.err  = "using default of "
 				__MODULE_STRING(E1000_DEFAULT_RXD),
 			.def  = E1000_DEFAULT_RXD,
-			.arg  = { .r = { .min = E1000_MIN_RXD }}
+			.arg  = { .r = {
+				.min = E1000_MIN_RXD,
+				.max = mac_type < e1000_82544 ? E1000_MAX_RXD : E1000_MAX_82544_RXD
+			}}
 		};
-		struct e1000_rx_ring *rx_ring = adapter->rx_ring;
-		int i;
-		e1000_mac_type mac_type = adapter->hw.mac_type;
-		opt.arg.r.max = mac_type < e1000_82544 ? E1000_MAX_RXD :
-			E1000_MAX_82544_RXD;
 
 		if (num_RxDescriptors > bd) {
 			rx_ring->count = RxDescriptors[bd];
@@ -339,7 +345,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 			rx_ring[i].count = rx_ring->count;
 	}
 	{ /* Checksum Offload Enable/Disable */
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = enable_option,
 			.name = "Checksum Offload",
 			.err  = "defaulting to Enabled",
@@ -363,7 +369,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 			 { E1000_FC_FULL,    "Flow Control Enabled" },
 			 { E1000_FC_DEFAULT, "Flow Control Hardware Default" }};
 
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = list_option,
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
@@ -381,7 +387,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Transmit Interrupt Delay */
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = range_option,
 			.name = "Transmit Interrupt Delay",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TIDV),
@@ -399,7 +405,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Transmit Absolute Interrupt Delay */
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = range_option,
 			.name = "Transmit Absolute Interrupt Delay",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TADV),
@@ -417,7 +423,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Receive Interrupt Delay */
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = range_option,
 			.name = "Receive Interrupt Delay",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RDTR),
@@ -435,7 +441,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Receive Absolute Interrupt Delay */
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = range_option,
 			.name = "Receive Absolute Interrupt Delay",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RADV),
@@ -453,7 +459,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Interrupt Throttling Rate */
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = range_option,
 			.name = "Interrupt Throttling Rate (ints/sec)",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_ITR),
@@ -497,7 +503,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Smart Power Down */
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = enable_option,
 			.name = "PHY Smart Power Down",
 			.err  = "defaulting to Disabled",
@@ -513,7 +519,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Kumeran Lock Loss Workaround */
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = enable_option,
 			.name = "Kumeran Lock Loss Workaround",
 			.err  = "defaulting to Enabled",
@@ -578,16 +584,18 @@ static void __devinit e1000_check_fiber_options(struct e1000_adapter *adapter)
 
 static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
 {
+	struct e1000_option opt;
 	unsigned int speed, dplx, an;
 	int bd = adapter->bd_number;
 
 	{ /* Speed */
-		struct e1000_opt_list speed_list[] = {{          0, "" },
-						      {   SPEED_10, "" },
-						      {  SPEED_100, "" },
-						      { SPEED_1000, "" }};
+		static const struct e1000_opt_list speed_list[] = {
+			{          0, "" },
+			{   SPEED_10, "" },
+			{  SPEED_100, "" },
+			{ SPEED_1000, "" }};
 
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = list_option,
 			.name = "Speed",
 			.err  = "parameter ignored",
@@ -604,11 +612,12 @@ static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Duplex */
-		struct e1000_opt_list dplx_list[] = {{           0, "" },
-						     { HALF_DUPLEX, "" },
-						     { FULL_DUPLEX, "" }};
+		static const struct e1000_opt_list dplx_list[] = {
+			{           0, "" },
+			{ HALF_DUPLEX, "" },
+			{ FULL_DUPLEX, "" }};
 
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = list_option,
 			.name = "Duplex",
 			.err  = "parameter ignored",
@@ -637,7 +646,7 @@ static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
 		       "parameter ignored\n");
 		adapter->hw.autoneg_advertised = AUTONEG_ADV_DEFAULT;
 	} else { /* Autoneg */
-		struct e1000_opt_list an_list[] =
+		static const struct e1000_opt_list an_list[] =
 			#define AA "AutoNeg advertising "
 			{{ 0x01, AA "10/HD" },
 			 { 0x02, AA "10/FD" },
@@ -671,7 +680,7 @@ static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
 			 { 0x2e, AA "1000/FD, 100/FD, 100/HD, 10/FD" },
 			 { 0x2f, AA "1000/FD, 100/FD, 100/HD, 10/FD, 10/HD" }};
 
-		struct e1000_option opt = {
+		opt = (struct e1000_option) {
 			.type = list_option,
 			.name = "AutoNeg",
 			.err  = "parameter ignored",

