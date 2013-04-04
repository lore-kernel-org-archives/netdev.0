From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: fix registration order of driver and DCA nofitication
Date: Wed,  3 Apr 2013 19:50:54 -0700
Message-ID: <1365043854-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <jakub.kicinski@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	stable <stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52385 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932610Ab3DDCvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Apr 2013 22:51:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@intel.com>

ixgbe_notify_dca cannot be called before driver registration
because it expects driver's klist_devices to be allocated and
initialized. While on it make sure debugfs files are removed
when registration fails.

Cc: stable <stable@vger.kernel.org>
Signed-off-by: Jakub Kicinski <jakub.kicinski@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index db5611a..79f4a26 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7922,12 +7922,19 @@ static int __init ixgbe_init_module(void)
 	ixgbe_dbg_init();
 #endif /* CONFIG_DEBUG_FS */
 
+	ret = pci_register_driver(&ixgbe_driver);
+	if (ret) {
+#ifdef CONFIG_DEBUG_FS
+		ixgbe_dbg_exit();
+#endif /* CONFIG_DEBUG_FS */
+		return ret;
+	}
+
 #ifdef CONFIG_IXGBE_DCA
 	dca_register_notify(&dca_notifier);
 #endif
 
-	ret = pci_register_driver(&ixgbe_driver);
-	return ret;
+	return 0;
 }
 
 module_init(ixgbe_init_module);
-- 
1.7.11.7
