From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] e1000e: default IntMode based on kernel config & available hardware support
Date: Wed, 25 Jan 2012 23:21:50 -0800
Message-ID: <1327562515-29664-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jin Qing <b24347@freescale.com>,
	Prabhakar Kushwaha <prabhakar@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63115 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601Ab2AZHWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 02:22:01 -0500
In-Reply-To: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Based on a patch from Prabhakar Kushwaha <prabhakar@freescale.com>, set
appropriate default interrupt mode dependent on whether CONFIG_PCI_MSI
is enabled in the kernel configuration and if the hardware supports
MSI-X.  Set the module parameter log message accordingly.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Jin Qing <b24347@freescale.com>
Cc: Prabhakar Kushwaha <prabhakar@freescale.com>
Cc: Jin Qing <b24347@freescale.com>
Cc: Kumar Gala <galak@kernel.crashing.org>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/param.c |   48 ++++++++++++++++++++++++----
 1 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 20e93b0..40664f5 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -113,11 +113,20 @@ E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
 #define MAX_ITR 100000
 #define MIN_ITR 100
 
-/* IntMode (Interrupt Mode)
+/*
+ * IntMode (Interrupt Mode)
+ *
+ * Valid Range: varies depending on kernel configuration & hardware support
+ *
+ * legacy=0, MSI=1, MSI-X=2
  *
- * Valid Range: 0 - 2
+ * When MSI/MSI-X support is enabled in kernel-
+ *   Default Value: 2 (MSI-X) when supported by hardware, 1 (MSI) otherwise
+ * When MSI/MSI-X support is not enabled in kernel-
+ *   Default Value: 0 (legacy)
  *
- * Default Value: 2 (MSI-X)
+ * When a mode is specified that is not allowed/supported, it will be
+ * demoted to the most advanced interrupt mode available.
  */
 E1000_PARAM(IntMode, "Interrupt Mode");
 #define MAX_INTMODE	2
@@ -388,12 +397,33 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		static struct e1000_option opt = {
 			.type = range_option,
 			.name = "Interrupt Mode",
-			.err  = "defaulting to 2 (MSI-X)",
-			.def  = E1000E_INT_MODE_MSIX,
-			.arg  = { .r = { .min = MIN_INTMODE,
-					 .max = MAX_INTMODE } }
+#ifndef CONFIG_PCI_MSI
+			.err  = "defaulting to 0 (legacy)",
+			.def  = E1000E_INT_MODE_LEGACY,
+			.arg  = { .r = { .min = 0,
+					 .max = 0 } }
+#endif
 		};
 
+#ifdef CONFIG_PCI_MSI
+		if (adapter->flags & FLAG_HAS_MSIX) {
+			opt.err = kstrdup("defaulting to 2 (MSI-X)",
+					  GFP_KERNEL);
+			opt.def = E1000E_INT_MODE_MSIX;
+			opt.arg.r.max = E1000E_INT_MODE_MSIX;
+		} else {
+			opt.err = kstrdup("defaulting to 1 (MSI)", GFP_KERNEL);
+			opt.def = E1000E_INT_MODE_MSI;
+			opt.arg.r.max = E1000E_INT_MODE_MSI;
+		}
+
+		if (!opt.err) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to allocate memory\n");
+			return;
+		}
+#endif
+
 		if (num_IntMode > bd) {
 			unsigned int int_mode = IntMode[bd];
 			e1000_validate_option(&int_mode, &opt, adapter);
@@ -401,6 +431,10 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		} else {
 			adapter->int_mode = opt.def;
 		}
+
+#ifdef CONFIG_PCI_MSI
+		kfree(opt.err);
+#endif
 	}
 	{ /* Smart Power Down */
 		static const struct e1000_option opt = {
-- 
1.7.7.6
