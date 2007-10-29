From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/4] ixgb: fix sparse warnings
Date: Mon, 29 Oct 2007 10:46:13 -0700
Message-ID: <20071029174613.25245.96769.stgit@localhost.localdomain>
References: <20071029174605.25245.15294.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55483 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754981AbXJ2Rrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 13:47:31 -0400
In-Reply-To: <20071029174605.25245.15294.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Fix sparse warnings in ixgb driver for net-2.6.24.

Added a sparse fix for invalid declaration using non-constant value
in ixgb_set_multi. Added a fix for the module param array index
and allows int params in the array. --Auke

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h         |    7 ++++++
 drivers/net/ixgb/ixgb_ethtool.c |    7 ++----
 drivers/net/ixgb/ixgb_hw.c      |    4 ++--
 drivers/net/ixgb/ixgb_main.c    |   11 ++++------
 drivers/net/ixgb/ixgb_param.c   |   43 ++++++++++++++++++++-------------------
 5 files changed, 37 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 1eee889..3d2e721 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -196,4 +196,11 @@ struct ixgb_adapter {
 	uint32_t alloc_rx_buff_failed;
 	boolean_t have_msi;
 };
+
+/* Exported from other modules */
+extern void ixgb_check_options(struct ixgb_adapter *adapter);
+extern void ixgb_set_ethtool_ops(struct net_device *netdev);
+extern char ixgb_driver_name[];
+extern const char ixgb_driver_version[];
+
 #endif /* _IXGB_H_ */
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index fddd584..a267dd8 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -32,9 +32,6 @@
 
 #include <asm/uaccess.h>
 
-extern char ixgb_driver_name[];
-extern char ixgb_driver_version[];
-
 extern int ixgb_up(struct ixgb_adapter *adapter);
 extern void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
 extern void ixgb_reset(struct ixgb_adapter *adapter);
@@ -639,8 +636,8 @@ ixgb_phys_id(struct net_device *netdev, uint32_t data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	if(!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
-		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
+	if (!data)
+		data = INT_MAX;
 
 	if(!adapter->blink_timer.function) {
 		init_timer(&adapter->blink_timer);
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index ecbf458..2c6367a 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -1174,7 +1174,7 @@ mac_addr_valid(uint8_t *mac_addr)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-boolean_t
+static boolean_t
 ixgb_link_reset(struct ixgb_hw *hw)
 {
 	boolean_t link_status = FALSE;
@@ -1205,7 +1205,7 @@ ixgb_link_reset(struct ixgb_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void
+static void
 ixgb_optics_reset(struct ixgb_hw *hw)
 {
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index d444de5..e564335 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -37,8 +37,8 @@ static char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
 #define DRIVERNAPI "-NAPI"
 #endif
 #define DRV_VERSION		"1.0.126-k2"DRIVERNAPI
-char ixgb_driver_version[] = DRV_VERSION;
-static char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
+const char ixgb_driver_version[] = DRV_VERSION;
+static const char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
  *
@@ -104,7 +104,6 @@ static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
 #endif
 static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter);
-void ixgb_set_ethtool_ops(struct net_device *netdev);
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct work_struct *work);
 static void ixgb_vlan_rx_register(struct net_device *netdev,
@@ -123,9 +122,6 @@ static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
 static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev);
 static void ixgb_io_resume (struct pci_dev *pdev);
 
-/* Exported from other modules */
-extern void ixgb_check_options(struct ixgb_adapter *adapter);
-
 static struct pci_error_handlers ixgb_err_handler = {
 	.error_detected = ixgb_io_error_detected,
 	.slot_reset = ixgb_io_slot_reset,
@@ -1085,7 +1081,8 @@ ixgb_set_multi(struct net_device *netdev)
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
-		uint8_t mta[netdev->mc_count * IXGB_ETH_LENGTH_OF_ADDRESS];
+		uint8_t mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
+			    IXGB_ETH_LENGTH_OF_ADDRESS];
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 5d5ddab..865d14d 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -44,10 +44,11 @@
  */
 
 #define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
-#define IXGB_PARAM(X, desc) \
-	static int __devinitdata X[IXGB_MAX_NIC+1] = IXGB_PARAM_INIT; \
-	static int num_##X = 0; \
-	module_param_array_named(X, X, int, &num_##X, 0); \
+#define IXGB_PARAM(X, desc)					\
+	static int __devinitdata X[IXGB_MAX_NIC+1]		\
+		= IXGB_PARAM_INIT;				\
+	static unsigned int num_##X = 0;			\
+	module_param_array_named(X, X, int, &num_##X, 0);	\
 	MODULE_PARM_DESC(X, desc);
 
 /* Transmit Descriptor Count
@@ -178,8 +179,8 @@ IXGB_PARAM(IntDelayEnable, "Transmit Interrupt Delay Enable");
 
 struct ixgb_option {
 	enum { enable_option, range_option, list_option } type;
-	char *name;
-	char *err;
+	const char *name;
+	const char *err;
 	int def;
 	union {
 		struct {	/* range_option info */
@@ -197,7 +198,7 @@ struct ixgb_option {
 };
 
 static int __devinit
-ixgb_validate_option(int *value, struct ixgb_option *opt)
+ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 {
 	if(*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -266,7 +267,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 	}
 
 	{ /* Transmit Descriptor Count */
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Descriptors",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TXD),
@@ -285,7 +286,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		tx_ring->count = ALIGN(tx_ring->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Descriptor Count */
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Descriptors",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RXD),
@@ -304,7 +305,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		rx_ring->count = ALIGN(rx_ring->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Checksum Offload Enable */
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Receive Checksum Offload",
 			.err  = "defaulting to Enabled",
@@ -312,7 +313,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		};
 
 		if(num_XsumRX > bd) {
-			int rx_csum = XsumRX[bd];
+			unsigned int rx_csum = XsumRX[bd];
 			ixgb_validate_option(&rx_csum, &opt);
 			adapter->rx_csum = rx_csum;
 		} else {
@@ -328,7 +329,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			 { ixgb_fc_full,	"Flow Control Enabled" },
 			 { ixgb_fc_default, "Flow Control Hardware Default" }};
 
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = list_option,
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
@@ -338,7 +339,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		};
 
 		if(num_FlowControl > bd) {
-			int fc = FlowControl[bd];
+			unsigned int fc = FlowControl[bd];
 			ixgb_validate_option(&fc, &opt);
 			adapter->hw.fc.type = fc;
 		} else {
@@ -346,7 +347,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		}
 	}
 	{ /* Receive Flow Control High Threshold */
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control High Threshold",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_FCRTH),
@@ -366,7 +367,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 				"Ignoring RxFCHighThresh when no RxFC\n");
 	}
 	{ /* Receive Flow Control Low Threshold */
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control Low Threshold",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_FCRTL),
@@ -386,7 +387,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 				"Ignoring RxFCLowThresh when no RxFC\n");
 	}
 	{ /* Flow Control Pause Time Request*/
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Flow Control Pause Time Request",
 			.err  = "using default of "__MODULE_STRING(DEFAULT_FCPAUSE),
@@ -396,7 +397,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		};
 
 		if(num_FCReqTimeout > bd) {
-			int pause_time = FCReqTimeout[bd];
+			unsigned int pause_time = FCReqTimeout[bd];
 			ixgb_validate_option(&pause_time, &opt);
 			adapter->hw.fc.pause_time = pause_time;
 		} else {
@@ -419,7 +420,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		}
 	}
 	{ /* Receive Interrupt Delay */
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Interrupt Delay",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RDTR),
@@ -436,7 +437,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		}
 	}
 	{ /* Transmit Interrupt Delay */
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Interrupt Delay",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TIDV),
@@ -454,7 +455,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 	}
 
 	{ /* Transmit Interrupt Delay Enable */
-		struct ixgb_option opt = {
+		const struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Tx Interrupt Delay Enable",
 			.err  = "defaulting to Enabled",
@@ -462,7 +463,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		};
 
 		if(num_IntDelayEnable > bd) {
-			int ide = IntDelayEnable[bd];
+			unsigned int ide = IntDelayEnable[bd];
 			ixgb_validate_option(&ide, &opt);
 			adapter->tx_int_delay_enable = ide;
 		} else {
