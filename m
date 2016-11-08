From: Arnd Bergmann <arnd@arndb.de>
Subject: [net-next PATCH] amd-xgbe: use __maybe_unused to hide pm functions
Date: Tue,  8 Nov 2016 14:37:32 +0100
Message-ID: <20161108133802.1716319-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:53217 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbcKHNi1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 08:38:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The amd-xgbe ethernet driver hides its suspend/resume functions
in #ifdef CONFIG_PM, but uses SIMPLE_DEV_PM_OPS() to make the
reference conditional on CONFIG_PM_SLEEP, which results in a
warning when PM_SLEEP is not set but PM is:

drivers/net/ethernet/amd/xgbe/xgbe-platform.c:553:12: error: 'xgbe_platform_resume' defined but not used [-Werror=unused-function]
drivers/net/ethernet/amd/xgbe/xgbe-platform.c:533:12: error: 'xgbe_platform_suspend' defined but not used [-Werror=unused-function]

This removes the incorrect #ifdef and instead uses a __maybe_unused
annotation to let the compiler know it can silently drop
the function definition.

Fixes: bd8255d8ba35 ("amd-xgbe: Prepare for supporting PCI devices")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I originally submitted this when in March 2016, but the patch has not
yet made it upstream, and the file contents have moved around so
the old patch no longer applied so I'm resending the rebased version
now.
---
 drivers/net/ethernet/amd/xgbe/xgbe-platform.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-platform.c b/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
index 0edbcd523f8f..02daca817bb7 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
@@ -529,8 +529,7 @@ static int xgbe_platform_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
-static int xgbe_platform_suspend(struct device *dev)
+static int __maybe_unused xgbe_platform_suspend(struct device *dev)
 {
 	struct xgbe_prv_data *pdata = dev_get_drvdata(dev);
 	struct net_device *netdev = pdata->netdev;
@@ -550,7 +549,7 @@ static int xgbe_platform_suspend(struct device *dev)
 	return ret;
 }
 
-static int xgbe_platform_resume(struct device *dev)
+static int __maybe_unused xgbe_platform_resume(struct device *dev)
 {
 	struct xgbe_prv_data *pdata = dev_get_drvdata(dev);
 	struct net_device *netdev = pdata->netdev;
@@ -574,7 +573,6 @@ static int xgbe_platform_resume(struct device *dev)
 
 	return ret;
 }
-#endif /* CONFIG_PM */
 
 static const struct xgbe_version_data xgbe_v1 = {
 	.init_function_ptrs_phy_impl	= xgbe_init_function_ptrs_phy_v1,
-- 
2.9.0
