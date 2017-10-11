From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] fm10k: mark PM functions as __maybe_unused
Date: Wed, 11 Oct 2017 15:58:22 +0200
Message-ID: <20171011135834.3628155-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Jacob Keller <jacob.e.keller@intel.com>,
        Ngai-Mint Kwan <ngai-mint.kwan@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A cleanup of the PM code left an incorrect #ifdef in place, leading
to a harmless build warning:

drivers/net/ethernet/intel/fm10k/fm10k_pci.c:2502:12: error: 'fm10k_suspend' defined but not used [-Werror=unused-function]
drivers/net/ethernet/intel/fm10k/fm10k_pci.c:2475:12: error: 'fm10k_resume' defined but not used [-Werror=unused-function]

It's easier to use __maybe_unused attributes here, since you
can't pick the wrong one.

Fixes: 8249c47c6ba4 ("fm10k: use generic PM hooks instead of legacy PCIe power hooks")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 1e9ae3197b17..52f8eb3c470e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2463,7 +2463,6 @@ static int fm10k_handle_resume(struct fm10k_intfc *interface)
 	return err;
 }
 
-#ifdef CONFIG_PM
 /**
  * fm10k_resume - Generic PM resume hook
  * @dev: generic device structure
@@ -2472,7 +2471,7 @@ static int fm10k_handle_resume(struct fm10k_intfc *interface)
  * suspend or hibernation. This function does not need to handle lower PCIe
  * device state as the stack takes care of that for us.
  **/
-static int fm10k_resume(struct device *dev)
+static int __maybe_unused fm10k_resume(struct device *dev)
 {
 	struct fm10k_intfc *interface = pci_get_drvdata(to_pci_dev(dev));
 	struct net_device *netdev = interface->netdev;
@@ -2499,7 +2498,7 @@ static int fm10k_resume(struct device *dev)
  * system suspend or hibernation. This function does not need to handle lower
  * PCIe device state as the stack takes care of that for us.
  **/
-static int fm10k_suspend(struct device *dev)
+static int __maybe_unused fm10k_suspend(struct device *dev)
 {
 	struct fm10k_intfc *interface = pci_get_drvdata(to_pci_dev(dev));
 	struct net_device *netdev = interface->netdev;
@@ -2511,8 +2510,6 @@ static int fm10k_suspend(struct device *dev)
 	return 0;
 }
 
-#endif /* CONFIG_PM */
-
 /**
  * fm10k_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
@@ -2643,11 +2640,9 @@ static struct pci_driver fm10k_driver = {
 	.id_table		= fm10k_pci_tbl,
 	.probe			= fm10k_probe,
 	.remove			= fm10k_remove,
-#ifdef CONFIG_PM
 	.driver = {
 		.pm		= &fm10k_pm_ops,
 	},
-#endif /* CONFIG_PM */
 	.sriov_configure	= fm10k_iov_configure,
 	.err_handler		= &fm10k_err_handler
 };
-- 
2.9.0
