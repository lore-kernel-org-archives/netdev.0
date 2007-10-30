From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 30 Oct 2007 14:45:44 -0400
Message-ID: <20071030184543.GA27335@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757187AbXJ3SqT@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fixes, and a new DM9601 USB NIC id.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/bfin_mac.c            |    2 -
 drivers/net/e1000/e1000.h         |    8 +++++++
 drivers/net/e1000/e1000_ethtool.c |   29 ++++++++++--------------
 drivers/net/e1000/e1000_hw.c      |    4 +-
 drivers/net/e1000/e1000_main.c    |    7 +----
 drivers/net/e1000/e1000_param.c   |   23 ++++++++++---------
 drivers/net/e1000e/82571.c        |    2 +-
 drivers/net/e1000e/ethtool.c      |    4 +-
 drivers/net/e1000e/param.c        |   35 +++++++++++++++--------------
 drivers/net/ixgb/ixgb.h           |    7 ++++++
 drivers/net/ixgb/ixgb_ethtool.c   |    7 +----
 drivers/net/ixgb/ixgb_hw.c        |    4 +-
 drivers/net/ixgb/ixgb_main.c      |   15 +++++-------
 drivers/net/ixgb/ixgb_param.c     |   43 +++++++++++++++++++------------------
 drivers/net/ixgbe/ixgbe.h         |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c   |    3 +-
 drivers/net/ixgbe/ixgbe_main.c    |    9 ++++---
 drivers/net/usb/dm9601.c          |    4 +++
 include/linux/mv643xx_eth.h       |    6 ++--
 19 files changed, 110 insertions(+), 104 deletions(-)

Auke Kok (1):
      ixgb: fix TX hangs under heavy load

Dale Farnsworth (1):
      mv643xx_eth: Fix MV643XX_ETH offsets used by Pegasos 2

Michael Hennerich (1):
      Blackfin EMAC driver: Fix Ethernet communication bug (dupliated and lost packets)

Peter Korsgaard (1):
      DM9601: Support for ADMtek ADM8515 NIC

Roel Kluin (1):
      e1000e: Fix typo ! &

Stephen Hemminger (4):
      e1000e: fix sparse warnings
      ixgb: fix sparse warnings
      e1000: sparse warnings fixes
      ixgbe: minor sparse fixes

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 53fe7de..084acfd 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -371,7 +371,6 @@ static void bf537_adjust_link(struct net_device *dev)
 		if (phydev->speed != lp->old_speed) {
 #if defined(CONFIG_BFIN_MAC_RMII)
 			u32 opmode = bfin_read_EMAC_OPMODE();
-			bf537mac_disable();
 			switch (phydev->speed) {
 			case 10:
 				opmode |= RMII_10;
@@ -386,7 +385,6 @@ static void bf537_adjust_link(struct net_device *dev)
 				break;
 			}
 			bfin_write_EMAC_OPMODE(opmode);
-			bf537mac_enable();
 #endif
 
 			new_state = 1;
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 781ed99..3b84028 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -351,4 +351,12 @@ enum e1000_state_t {
 	__E1000_DOWN
 };
 
+extern char e1000_driver_name[];
+extern const char e1000_driver_version[];
+
+extern void e1000_power_up_phy(struct e1000_adapter *);
+extern void e1000_set_ethtool_ops(struct net_device *netdev);
+extern void e1000_check_options(struct e1000_adapter *adapter);
+
+
 #endif /* _E1000_H_ */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 6c9a643..667f18b 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -32,9 +32,6 @@
 
 #include <asm/uaccess.h>
 
-extern char e1000_driver_name[];
-extern char e1000_driver_version[];
-
 extern int e1000_up(struct e1000_adapter *adapter);
 extern void e1000_down(struct e1000_adapter *adapter);
 extern void e1000_reinit_locked(struct e1000_adapter *adapter);
@@ -733,16 +730,16 @@ err_setup:
 
 #define REG_PATTERN_TEST(R, M, W)                                              \
 {                                                                              \
-	uint32_t pat, value;                                                   \
-	uint32_t test[] =                                                      \
+	uint32_t pat, val;                                                     \
+	const uint32_t test[] = 					       \
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};              \
-	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {              \
+	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {           	       \
 		E1000_WRITE_REG(&adapter->hw, R, (test[pat] & W));             \
-		value = E1000_READ_REG(&adapter->hw, R);                       \
-		if (value != (test[pat] & W & M)) {                             \
+		val = E1000_READ_REG(&adapter->hw, R);                         \
+		if (val != (test[pat] & W & M)) {                              \
 			DPRINTK(DRV, ERR, "pattern test reg %04X failed: got " \
 			        "0x%08X expected 0x%08X\n",                    \
-			        E1000_##R, value, (test[pat] & W & M));        \
+			        E1000_##R, val, (test[pat] & W & M));          \
 			*data = (adapter->hw.mac_type < e1000_82543) ?         \
 				E1000_82542_##R : E1000_##R;                   \
 			return 1;                                              \
@@ -752,12 +749,12 @@ err_setup:
 
 #define REG_SET_AND_CHECK(R, M, W)                                             \
 {                                                                              \
-	uint32_t value;                                                        \
+	uint32_t val;                                                          \
 	E1000_WRITE_REG(&adapter->hw, R, W & M);                               \
-	value = E1000_READ_REG(&adapter->hw, R);                               \
-	if ((W & M) != (value & M)) {                                          \
+	val = E1000_READ_REG(&adapter->hw, R);                                 \
+	if ((W & M) != (val & M)) {                                            \
 		DPRINTK(DRV, ERR, "set/check reg %04X test failed: got 0x%08X "\
-		        "expected 0x%08X\n", E1000_##R, (value & M), (W & M)); \
+		        "expected 0x%08X\n", E1000_##R, (val & M), (W & M));   \
 		*data = (adapter->hw.mac_type < e1000_82543) ?                 \
 			E1000_82542_##R : E1000_##R;                           \
 		return 1;                                                      \
@@ -1621,8 +1618,6 @@ e1000_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
-extern void e1000_power_up_phy(struct e1000_adapter *);
-
 static void
 e1000_diag_test(struct net_device *netdev,
 		   struct ethtool_test *eth_test, uint64_t *data)
@@ -1859,8 +1854,8 @@ e1000_phys_id(struct net_device *netdev, uint32_t data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
-		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
+	if (!data)
+		data = INT_MAX;
 
 	if (adapter->hw.mac_type < e1000_82571) {
 		if (!adapter->blink_timer.function) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 8fa0fe4..7c6888c 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -8607,7 +8607,7 @@ e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
 
     DEBUGFUNC("e1000_read_ich8_data");
 
-    if (size < 1  || size > 2 || data == 0x0 ||
+    if (size < 1  || size > 2 || data == NULL ||
         index > ICH_FLASH_LINEAR_ADDR_MASK)
         return error;
 
@@ -8841,7 +8841,7 @@ e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data)
  * amount of NVM used in each bank is a *minimum* of 4 KBytes, but in fact the
  * bank size may be 4, 8 or 64 KBytes
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank)
 {
     union ich8_hws_flash_status hsfsts;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f1ce348..72deff0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -37,8 +37,8 @@ static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
 #define DRIVERNAPI "-NAPI"
 #endif
 #define DRV_VERSION "7.3.20-k2"DRIVERNAPI
-char e1000_driver_version[] = DRV_VERSION;
-static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
+const char e1000_driver_version[] = DRV_VERSION;
+static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
  *
@@ -188,7 +188,6 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			   int cmd);
-void e1000_set_ethtool_ops(struct net_device *netdev);
 static void e1000_enter_82542_rst(struct e1000_adapter *adapter);
 static void e1000_leave_82542_rst(struct e1000_adapter *adapter);
 static void e1000_tx_timeout(struct net_device *dev);
@@ -213,8 +212,6 @@ static void e1000_shutdown(struct pci_dev *pdev);
 static void e1000_netpoll (struct net_device *netdev);
 #endif
 
-extern void e1000_check_options(struct e1000_adapter *adapter);
-
 #define COPYBREAK_DEFAULT 256
 static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
 module_param(copybreak, uint, 0644);
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index f485874..e6565ce 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -46,7 +46,7 @@
 #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
 #define E1000_PARAM(X, desc) \
 	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
-	static int num_##X = 0; \
+	static unsigned int num_##X; \
 	module_param_array_named(X, X, int, &num_##X, 0); \
 	MODULE_PARM_DESC(X, desc);
 
@@ -198,9 +198,9 @@ E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
 
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
-	char *name;
-	char *err;
-	int  def;
+	const char *name;
+	const char *err;
+	int def;
 	union {
 		struct { /* range_option info */
 			int min;
@@ -214,8 +214,9 @@ struct e1000_option {
 };
 
 static int __devinit
-e1000_validate_option(int *value, struct e1000_option *opt,
-		struct e1000_adapter *adapter)
+e1000_validate_option(unsigned int *value,
+		      const struct e1000_option *opt,
+		      struct e1000_adapter *adapter)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -348,7 +349,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_XsumRX > bd) {
-			int rx_csum = XsumRX[bd];
+			unsigned int rx_csum = XsumRX[bd];
 			e1000_validate_option(&rx_csum, &opt, adapter);
 			adapter->rx_csum = rx_csum;
 		} else {
@@ -374,7 +375,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_FlowControl > bd) {
-			int fc = FlowControl[bd];
+			unsigned int fc = FlowControl[bd];
 			e1000_validate_option(&fc, &opt, adapter);
 			adapter->hw.fc = adapter->hw.original_fc = fc;
 		} else {
@@ -506,7 +507,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_SmartPowerDownEnable > bd) {
-			int spd = SmartPowerDownEnable[bd];
+			unsigned int spd = SmartPowerDownEnable[bd];
 			e1000_validate_option(&spd, &opt, adapter);
 			adapter->smart_power_down = spd;
 		} else {
@@ -522,7 +523,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_KumeranLockLoss > bd) {
-			int kmrn_lock_loss = KumeranLockLoss[bd];
+			unsigned int kmrn_lock_loss = KumeranLockLoss[bd];
 			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
 			adapter->hw.kmrn_lock_loss_workaround_disabled = !kmrn_lock_loss;
 		} else {
@@ -581,7 +582,7 @@ e1000_check_fiber_options(struct e1000_adapter *adapter)
 static void __devinit
 e1000_check_copper_options(struct e1000_adapter *adapter)
 {
-	int speed, dplx, an;
+	unsigned int speed, dplx, an;
 	int bd = adapter->bd_number;
 
 	{ /* Speed */
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index cf70522..14141a5 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -283,7 +283,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
 			adapter->flags &= ~FLAG_HAS_WOL;
 		/* quad ports only support WoL on port A */
 		if (adapter->flags & FLAG_IS_QUAD_PORT &&
-		    (!adapter->flags & FLAG_IS_QUAD_PORT_A))
+		    (!(adapter->flags & FLAG_IS_QUAD_PORT_A)))
 			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 0666e62..6a39784 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1680,8 +1680,8 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
-		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
+	if (!data)
+		data = INT_MAX;
 
 	if (adapter->hw.phy.type == e1000_phy_ife) {
 		if (!adapter->blink_timer.function) {
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index e4e655e..3327892 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -52,10 +52,11 @@ MODULE_PARM_DESC(copybreak,
  */
 
 #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
-#define E1000_PARAM(X, desc) \
-	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
-	static int num_##X; \
-	module_param_array_named(X, X, int, &num_##X, 0); \
+#define E1000_PARAM(X, desc)					\
+	static int __devinitdata X[E1000_MAX_NIC+1]		\
+		= E1000_PARAM_INIT;				\
+	static unsigned int num_##X;				\
+	module_param_array_named(X, X, int, &num_##X, 0);	\
 	MODULE_PARM_DESC(X, desc);
 
 
@@ -124,9 +125,9 @@ E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
 
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
-	char *name;
-	char *err;
-	int  def;
+	const char *name;
+	const char *err;
+	int def;
 	union {
 		struct { /* range_option info */
 			int min;
@@ -139,8 +140,8 @@ struct e1000_option {
 	} arg;
 };
 
-static int __devinit e1000_validate_option(int *value,
-					   struct e1000_option *opt,
+static int __devinit e1000_validate_option(unsigned int *value,
+					   const struct e1000_option *opt,
 					   struct e1000_adapter *adapter)
 {
 	if (*value == OPTION_UNSET) {
@@ -213,7 +214,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 	}
 
 	{ /* Transmit Interrupt Delay */
-		struct e1000_option opt = {
+		const struct e1000_option opt = {
 			.type = range_option,
 			.name = "Transmit Interrupt Delay",
 			.err  = "using default of "
@@ -232,7 +233,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Transmit Absolute Interrupt Delay */
-		struct e1000_option opt = {
+		const struct e1000_option opt = {
 			.type = range_option,
 			.name = "Transmit Absolute Interrupt Delay",
 			.err  = "using default of "
@@ -277,7 +278,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Receive Absolute Interrupt Delay */
-		struct e1000_option opt = {
+		const struct e1000_option opt = {
 			.type = range_option,
 			.name = "Receive Absolute Interrupt Delay",
 			.err  = "using default of "
@@ -296,7 +297,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Interrupt Throttling Rate */
-		struct e1000_option opt = {
+		const struct e1000_option opt = {
 			.type = range_option,
 			.name = "Interrupt Throttling Rate (ints/sec)",
 			.err  = "using default of "
@@ -344,7 +345,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Smart Power Down */
-		struct e1000_option opt = {
+		const struct e1000_option opt = {
 			.type = enable_option,
 			.name = "PHY Smart Power Down",
 			.err  = "defaulting to Disabled",
@@ -352,7 +353,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_SmartPowerDownEnable > bd) {
-			int spd = SmartPowerDownEnable[bd];
+			unsigned int spd = SmartPowerDownEnable[bd];
 			e1000_validate_option(&spd, &opt, adapter);
 			if ((adapter->flags & FLAG_HAS_SMART_POWER_DOWN)
 			    && spd)
@@ -360,7 +361,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Kumeran Lock Loss Workaround */
-		struct e1000_option opt = {
+		const struct e1000_option opt = {
 			.type = enable_option,
 			.name = "Kumeran Lock Loss Workaround",
 			.err  = "defaulting to Enabled",
@@ -368,7 +369,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_KumeranLockLoss > bd) {
-			int kmrn_lock_loss = KumeranLockLoss[bd];
+			unsigned int kmrn_lock_loss = KumeranLockLoss[bd];
 			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
 			if (hw->mac.type == e1000_ich8lan)
 				e1000e_set_kmrn_lock_loss_workaround_ich8lan(hw,
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
index d444de5..3021234 100644
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
 
@@ -1324,8 +1321,8 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 			/* Workaround for premature desc write-backs
 			 * in TSO mode.  Append 4-byte sentinel desc */
-			if (unlikely(mss && !nr_frags && size == len
-			             && size > 8))
+			if (unlikely(mss && (f == (nr_frags - 1))
+				     && size == len && size > 8))
 				size -= 4;
 
 			buffer_info->length = size;
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
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index c160a7d..bc51432 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -244,7 +244,7 @@ extern struct ixgbe_info ixgbe_82598EB_info;
 extern struct ixgbe_info ixgbe_82598AT_info;
 
 extern char ixgbe_driver_name[];
-extern char ixgbe_driver_version[];
+extern const char ixgbe_driver_version[];
 
 extern int ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 00ee201..4d64673 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -30,8 +30,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 
-#include "ixgbe_type.h"
-#include "ixgbe_common.h"
+#include "ixgbe.h"
 #include "ixgbe_phy.h"
 
 #define IXGBE_82598_MAX_TX_QUEUES 32
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b75f1c6..00bc525 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -45,12 +45,13 @@
 #include "ixgbe_common.h"
 
 char ixgbe_driver_name[] = "ixgbe";
-static char ixgbe_driver_string[] =
-			"Intel(R) 10 Gigabit PCI Express Network Driver";
+static const char ixgbe_driver_string[] =
+	"Intel(R) 10 Gigabit PCI Express Network Driver";
 
 #define DRV_VERSION "1.1.18"
-char ixgbe_driver_version[] = DRV_VERSION;
-static char ixgbe_copyright[] = "Copyright (c) 1999-2007 Intel Corporation.";
+const char ixgbe_driver_version[] = DRV_VERSION;
+static const char ixgbe_copyright[] =
+	 "Copyright (c) 1999-2007 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598AF]			= &ixgbe_82598AF_info,
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index a2de32f..2c68573 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -586,6 +586,10 @@ static const struct usb_device_id products[] = {
 	 USB_DEVICE(0x0a46, 0x0268),	/* ShanTou ST268 USB NIC */
 	 .driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	 USB_DEVICE(0x0a46, 0x8515),	/* ADMtek ADM8515 USB NIC */
+	 .driver_info = (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
 
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 8df230a..30e11aa 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -8,9 +8,9 @@
 #define MV643XX_ETH_NAME		"mv643xx_eth"
 #define MV643XX_ETH_SHARED_REGS		0x2000
 #define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
-#define MV643XX_ETH_BAR_4	0x220
-#define MV643XX_ETH_SIZE_REG_4	0x224
-#define MV643XX_ETH_BASE_ADDR_ENABLE_REG	0x0290
+#define MV643XX_ETH_BAR_4		0x2220
+#define MV643XX_ETH_SIZE_REG_4		0x2224
+#define MV643XX_ETH_BASE_ADDR_ENABLE_REG	0x2290
 
 struct mv643xx_eth_platform_data {
 	int		port_number;
