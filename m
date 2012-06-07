From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) V2] stmmac: fix driver built w/ w/o both pci and platf modules
Date: Thu,  7 Jun 2012 14:48:42 +0200
Message-ID: <1339073322-23093-1-git-send-email-peppe.cavallaro@st.com>
References: <1339062803-24273-1-git-send-email-peppe.cavallaro@st.com>
Cc: wfg@linux.intel.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:49429 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755800Ab2FGMsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 08:48:54 -0400
In-Reply-To: <1339062803-24273-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit ba27ec66ffeb78cbf fixes the Kconfig of the
driver when built as module allowing to select/unselect
the PCI and Platform modules that are not anymore mutually
exclusive. This patch fixes and guarantees that the driver
builds on all the platforms w/ w/o PCI and when select/unselect
the two stmmac supports. In case of there are some problems
on both the configuration and the pci/pltf registration the
module_init will fail.

v2: set the CONFIG_STMMAC_PLATFORM enabled by default.
I've just noticed that this can actually help on
some configurations that don't enable any STMMAC
options by default (e.g. SPEAr).

Reported-by: Fengguang Wu <wfg@linux.intel.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   60 ++++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   23 +++++----
 3 files changed, 72 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 0076f77..9f44827 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -15,6 +15,7 @@ if STMMAC_ETH
 config STMMAC_PLATFORM
 	bool "STMMAC Platform bus support"
 	depends on STMMAC_ETH
+	default y
 	---help---
 	  This selects the platform specific bus support for
 	  the stmmac device driver. This is the driver used
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 6d07ba2..e8afe7b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -26,6 +26,7 @@
 #include <linux/clk.h>
 #include <linux/stmmac.h>
 #include <linux/phy.h>
+#include <linux/pci.h>
 #include "common.h"
 #ifdef CONFIG_STMMAC_TIMER
 #include "stmmac_timer.h"
@@ -95,8 +96,6 @@ extern int stmmac_mdio_register(struct net_device *ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
-extern struct pci_driver stmmac_pci_driver;
-extern struct platform_driver stmmac_pltfr_driver;
 int stmmac_freeze(struct net_device *ndev);
 int stmmac_restore(struct net_device *ndev);
 int stmmac_resume(struct net_device *ndev);
@@ -144,3 +143,60 @@ static inline int stmmac_clk_get(struct stmmac_priv *priv)
 	return 0;
 }
 #endif /* CONFIG_HAVE_CLK */
+
+
+#ifdef CONFIG_STMMAC_PLATFORM
+extern struct platform_driver stmmac_pltfr_driver;
+static inline int stmmac_register_platform(void)
+{
+	int err;
+
+	err = platform_driver_register(&stmmac_pltfr_driver);
+	if (err)
+		pr_err("stmmac: failed to register the platform driver\n");
+
+	return err;
+}
+static inline void stmmac_unregister_platform(void)
+{
+	platform_driver_register(&stmmac_pltfr_driver);
+}
+#else
+static inline int stmmac_register_platform(void)
+{
+	pr_err("stmmac: do not register the platf driver\n");
+
+	return -EINVAL;
+}
+static inline void stmmac_unregister_platform(void)
+{
+}
+#endif /* CONFIG_STMMAC_PLATFORM */
+
+#ifdef CONFIG_STMMAC_PCI
+extern struct pci_driver stmmac_pci_driver;
+static inline int stmmac_register_pci(void)
+{
+	int err;
+
+	err = pci_register_driver(&stmmac_pci_driver);
+	if (err)
+		pr_err("stmmac: failed to register the PCI driver\n");
+
+	return err;
+}
+static inline void stmmac_unregister_pci(void)
+{
+	pci_unregister_driver(&stmmac_pci_driver);
+}
+#else
+static inline int stmmac_register_pci(void)
+{
+	pr_err("stmmac: do not register the PCI driver\n");
+
+	return -EINVAL;
+}
+static inline void stmmac_unregister_pci(void)
+{
+}
+#endif /* CONFIG_STMMAC_PCI */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3638569..51b3b68 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -42,7 +42,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
 #include <linux/prefetch.h>
-#include <linux/pci.h>
 #ifdef CONFIG_STMMAC_DEBUG_FS
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
@@ -2094,25 +2093,29 @@ int stmmac_restore(struct net_device *ndev)
 }
 #endif /* CONFIG_PM */
 
+/* Driver can be configured w/ and w/ both PCI and Platf drivers
+ * depending on the configuration selected.
+ */
 static int __init stmmac_init(void)
 {
-	int err = 0;
+	int err_plt = 0;
+	int err_pci = 0;
 
-	err = platform_driver_register(&stmmac_pltfr_driver);
+	err_plt = stmmac_register_platform();
+	err_pci = stmmac_register_pci();
 
-	if (!err) {
-		err = pci_register_driver(&stmmac_pci_driver);
-		if (err)
-			platform_driver_unregister(&stmmac_pltfr_driver);
+	if ((err_pci) && (err_plt)) {
+		pr_err("stmmac: driver registration failed\n");
+		return -EINVAL;
 	}
 
-	return err;
+	return 0;
 }
 
 static void __exit stmmac_exit(void)
 {
-	pci_unregister_driver(&stmmac_pci_driver);
-	platform_driver_unregister(&stmmac_pltfr_driver);
+	stmmac_unregister_platform();
+	stmmac_unregister_pci();
 }
 
 module_init(stmmac_init);
-- 
1.7.4.4
