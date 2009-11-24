From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 17/17] sfc: Log interrupt and reset type names, not numbers
Date: Tue, 24 Nov 2009 02:08:17 +0000
Message-ID: <1259028497.14645.37.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34966 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932127AbZKXCIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:08:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define name tables for these enumerations in a similar way as for
loopback.  Move the loopback name table together with them.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   51 +++++++++++++++++++++++++++++++++++++++--
 drivers/net/sfc/enum.h       |    6 -----
 drivers/net/sfc/ethtool.c    |   15 +-----------
 drivers/net/sfc/falcon.c     |    2 +-
 drivers/net/sfc/net_driver.h |   19 ++++++++++++++-
 drivers/net/sfc/selftest.c   |    4 +-
 6 files changed, 69 insertions(+), 28 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index cb78995..4787faa 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -25,6 +25,50 @@
 #include "mdio_10g.h"
 #include "falcon.h"
 
+/**************************************************************************
+ *
+ * Type name strings
+ *
+ **************************************************************************
+ */
+
+/* Loopback mode names (see LOOPBACK_MODE()) */
+const unsigned int efx_loopback_mode_max = LOOPBACK_MAX;
+const char *efx_loopback_mode_names[] = {
+	[LOOPBACK_NONE]		= "NONE",
+	[LOOPBACK_GMAC]		= "GMAC",
+	[LOOPBACK_XGMII]	= "XGMII",
+	[LOOPBACK_XGXS]		= "XGXS",
+	[LOOPBACK_XAUI]  	= "XAUI",
+	[LOOPBACK_GPHY]		= "GPHY",
+	[LOOPBACK_PHYXS]	= "PHYXS",
+	[LOOPBACK_PCS]	 	= "PCS",
+	[LOOPBACK_PMAPMD] 	= "PMA/PMD",
+	[LOOPBACK_NETWORK]	= "NETWORK",
+};
+
+/* Interrupt mode names (see INT_MODE())) */
+const unsigned int efx_interrupt_mode_max = EFX_INT_MODE_MAX;
+const char *efx_interrupt_mode_names[] = {
+	[EFX_INT_MODE_MSIX]   = "MSI-X",
+	[EFX_INT_MODE_MSI]    = "MSI",
+	[EFX_INT_MODE_LEGACY] = "legacy",
+};
+
+const unsigned int efx_reset_type_max = RESET_TYPE_MAX;
+const char *efx_reset_type_names[] = {
+	[RESET_TYPE_INVISIBLE]     = "INVISIBLE",
+	[RESET_TYPE_ALL]           = "ALL",
+	[RESET_TYPE_WORLD]         = "WORLD",
+	[RESET_TYPE_DISABLE]       = "DISABLE",
+	[RESET_TYPE_TX_WATCHDOG]   = "TX_WATCHDOG",
+	[RESET_TYPE_INT_ERROR]     = "INT_ERROR",
+	[RESET_TYPE_RX_RECOVERY]   = "RX_RECOVERY",
+	[RESET_TYPE_RX_DESC_FETCH] = "RX_DESC_FETCH",
+	[RESET_TYPE_TX_DESC_FETCH] = "TX_DESC_FETCH",
+	[RESET_TYPE_TX_SKIP]       = "TX_SKIP",
+};
+
 #define EFX_MAX_MTU (9 * 1024)
 
 /* RX slow fill workqueue. If memory allocation fails in the fast path,
@@ -1772,7 +1816,7 @@ static int efx_reset(struct efx_nic *efx)
 		goto out_unlock;
 	}
 
-	EFX_INFO(efx, "resetting (%d)\n", method);
+	EFX_INFO(efx, "resetting (%s)\n", RESET_TYPE(method));
 
 	efx_reset_down(efx, method, &ecmd);
 
@@ -1851,9 +1895,10 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 	}
 
 	if (method != type)
-		EFX_LOG(efx, "scheduling reset (%d:%d)\n", type, method);
+		EFX_LOG(efx, "scheduling %s reset for %s\n",
+			RESET_TYPE(method), RESET_TYPE(type));
 	else
-		EFX_LOG(efx, "scheduling reset (%d)\n", method);
+		EFX_LOG(efx, "scheduling %s reset\n", RESET_TYPE(method));
 
 	efx->reset_pending = method;
 
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index 60cbc6e..fcd14b7 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -40,12 +40,6 @@ enum efx_loopback_mode {
 
 #define LOOPBACK_TEST_MAX LOOPBACK_PMAPMD
 
-extern const char *efx_loopback_mode_names[];
-#define LOOPBACK_MODE_NAME(mode)			\
-	STRING_TABLE_LOOKUP(mode, efx_loopback_mode)
-#define LOOPBACK_MODE(efx)				\
-	LOOPBACK_MODE_NAME(efx->loopback_mode)
-
 /* These loopbacks occur within the controller */
 #define LOOPBACKS_INTERNAL ((1 << LOOPBACK_GMAC) |     \
 			    (1 << LOOPBACK_XGMII)|     \
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index e8afd78..d8915b9 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -20,19 +20,6 @@
 #include "spi.h"
 #include "mdio_10g.h"
 
-const char *efx_loopback_mode_names[] = {
-	[LOOPBACK_NONE]		= "NONE",
-	[LOOPBACK_GMAC]		= "GMAC",
-	[LOOPBACK_XGMII]	= "XGMII",
-	[LOOPBACK_XGXS]		= "XGXS",
-	[LOOPBACK_XAUI] 	= "XAUI",
-	[LOOPBACK_GPHY]		= "GPHY",
-	[LOOPBACK_PHYXS]	= "PHYXS",
-	[LOOPBACK_PCS]	 	= "PCS",
-	[LOOPBACK_PMAPMD]	= "PMA/PMD",
-	[LOOPBACK_NETWORK]	= "NETWORK",
-};
-
 struct ethtool_string {
 	char name[ETH_GSTRING_LEN];
 };
@@ -290,7 +277,7 @@ static void efx_fill_test(unsigned int test_index,
 #define EFX_TX_QUEUE_NAME(_tx_queue) "txq%d", _tx_queue->queue
 #define EFX_RX_QUEUE_NAME(_rx_queue) "rxq%d", _rx_queue->queue
 #define EFX_LOOPBACK_NAME(_mode, _counter)			\
-	"loopback.%s." _counter, LOOPBACK_MODE_NAME(mode)
+	"loopback.%s." _counter, STRING_TABLE_LOOKUP(_mode, efx_loopback_mode)
 
 /**
  * efx_fill_loopback_test - fill in a block of loopback self-test entries
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 6eee4b7..41a321b 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2485,7 +2485,7 @@ int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 	efx_oword_t glb_ctl_reg_ker;
 	int rc;
 
-	EFX_LOG(efx, "performing hardware reset (%d)\n", method);
+	EFX_LOG(efx, "performing %s hardware reset\n", RESET_TYPE(method));
 
 	/* Initiate device reset */
 	if (method == RESET_TYPE_WORLD) {
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index f2df324..ac808d5 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -394,8 +394,23 @@ enum efx_led_mode {
 	EFX_LED_DEFAULT	= 2
 };
 
-#define STRING_TABLE_LOOKUP(val, member)	\
-	member ## _names[val]
+#define STRING_TABLE_LOOKUP(val, member) \
+	((val) < member ## _max) ? member ## _names[val] : "(invalid)"
+
+extern const char *efx_loopback_mode_names[];
+extern const unsigned int efx_loopback_mode_max;
+#define LOOPBACK_MODE(efx) \
+	STRING_TABLE_LOOKUP((efx)->loopback_mode, efx_loopback_mode)
+
+extern const char *efx_interrupt_mode_names[];
+extern const unsigned int efx_interrupt_mode_max;
+#define INT_MODE(efx) \
+	STRING_TABLE_LOOKUP(efx->interrupt_mode, efx_interrupt_mode)
+
+extern const char *efx_reset_type_names[];
+extern const unsigned int efx_reset_type_max;
+#define RESET_TYPE(type) \
+	STRING_TABLE_LOOKUP(type, efx_reset_type)
 
 enum efx_int_mode {
 	/* Be careful if altering to correct macro below */
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index afac1cc..63ff295 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -175,8 +175,8 @@ static int efx_test_interrupts(struct efx_nic *efx,
 	return -ETIMEDOUT;
 
  success:
-	EFX_LOG(efx, "test interrupt (mode %d) seen on CPU%d\n",
-		efx->interrupt_mode, efx->last_irq_cpu);
+	EFX_LOG(efx, "%s test interrupt seen on CPU%d\n", INT_MODE(efx),
+		efx->last_irq_cpu);
 	tests->interrupt = 1;
 	return 0;
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

