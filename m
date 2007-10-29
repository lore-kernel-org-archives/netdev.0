From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/4] e1000e: fix sparse warnings
Date: Mon, 29 Oct 2007 10:46:05 -0700
Message-ID: <20071029174605.25245.15294.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36119 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753971AbXJ2Rx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 13:53:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Fix sparse warnings from e1000e driver in net-2.6.24.

Added a sparse fix for module param arrays which can have int values
but only the array index needs to be unsigned. --Auke

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |    4 ++--
 drivers/net/e1000e/param.c   |   35 ++++++++++++++++++-----------------
 2 files changed, 20 insertions(+), 19 deletions(-)

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
