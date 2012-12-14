From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH 07/12] stmmac: fix platform driver unregistering
Date: Fri, 14 Dec 2012 15:02:51 +0400
Message-ID: <20121214110251.11019.9914.stgit@zurg>
References: <20121214110229.11019.63713.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121214110229.11019.63713.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes platform device drivers unregistering and adds proper error
handing on module loading.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   22 +++++++++++----------
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 023a4fb..b05df89 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -127,14 +127,14 @@ static inline int stmmac_register_platform(void)
 }
 static inline void stmmac_unregister_platform(void)
 {
-	platform_driver_register(&stmmac_pltfr_driver);
+	platform_driver_unregister(&stmmac_pltfr_driver);
 }
 #else
 static inline int stmmac_register_platform(void)
 {
 	pr_debug("stmmac: do not register the platf driver\n");
 
-	return -EINVAL;
+	return 0;
 }
 static inline void stmmac_unregister_platform(void)
 {
@@ -162,7 +162,7 @@ static inline int stmmac_register_pci(void)
 {
 	pr_debug("stmmac: do not register the PCI driver\n");
 
-	return -EINVAL;
+	return 0;
 }
 static inline void stmmac_unregister_pci(void)
 {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 542edbc..f07c061 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2194,18 +2194,20 @@ int stmmac_restore(struct net_device *ndev)
  */
 static int __init stmmac_init(void)
 {
-	int err_plt = 0;
-	int err_pci = 0;
-
-	err_plt = stmmac_register_platform();
-	err_pci = stmmac_register_pci();
-
-	if ((err_pci) && (err_plt)) {
-		pr_err("stmmac: driver registration failed\n");
-		return -EINVAL;
-	}
+	int ret;
 
+	ret = stmmac_register_platform();
+	if (ret)
+		goto err;
+	ret = stmmac_register_pci();
+	if (ret)
+		goto err_pci;
 	return 0;
+err_pci:
+	stmmac_unregister_platform();
+err:
+	pr_err("stmmac: driver registration failed\n");
+	return ret;
 }
 
 static void __exit stmmac_exit(void)
