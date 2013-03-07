From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] e1000e: fix accessing to suspended device
Date: Thu,  7 Mar 2013 03:15:25 -0800
Message-ID: <1362654925-26088-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362654925-26088-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5166 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756638Ab3CGLPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:15:38 -0500
In-Reply-To: <1362654925-26088-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@openvz.org>

This patch fixes some annoying messages like 'Error reading PHY register' and
'Hardware Erorr' and saves several seconds on reboot.

Cc: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Tested-by: Borislav Petkov <bp@suse.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 13 +++++++++++++
 drivers/net/ethernet/intel/e1000e/netdev.c  |  2 ++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 2c18137..f91a8f3 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -36,6 +36,7 @@
 #include <linux/delay.h>
 #include <linux/vmalloc.h>
 #include <linux/mdio.h>
+#include <linux/pm_runtime.h>
 
 #include "e1000.h"
 
@@ -2229,7 +2230,19 @@ static int e1000e_get_ts_info(struct net_device *netdev,
 	return 0;
 }
 
+static int e1000e_ethtool_begin(struct net_device *netdev)
+{
+	return pm_runtime_get_sync(netdev->dev.parent);
+}
+
+static void e1000e_ethtool_complete(struct net_device *netdev)
+{
+	pm_runtime_put_sync(netdev->dev.parent);
+}
+
 static const struct ethtool_ops e1000_ethtool_ops = {
+	.begin			= e1000e_ethtool_begin,
+	.complete		= e1000e_ethtool_complete,
 	.get_settings		= e1000_get_settings,
 	.set_settings		= e1000_set_settings,
 	.get_drvinfo		= e1000_get_drvinfo,
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2954cc7..948b86ff 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4663,6 +4663,7 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 	    (adapter->hw.phy.media_type == e1000_media_type_copper)) {
 		int ret_val;
 
+		pm_runtime_get_sync(&adapter->pdev->dev);
 		ret_val = e1e_rphy(hw, MII_BMCR, &phy->bmcr);
 		ret_val |= e1e_rphy(hw, MII_BMSR, &phy->bmsr);
 		ret_val |= e1e_rphy(hw, MII_ADVERTISE, &phy->advertise);
@@ -4673,6 +4674,7 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 		ret_val |= e1e_rphy(hw, MII_ESTATUS, &phy->estatus);
 		if (ret_val)
 			e_warn("Error reading PHY register\n");
+		pm_runtime_put_sync(&adapter->pdev->dev);
 	} else {
 		/* Do not read PHY registers if link is not up
 		 * Set values to typical power-on defaults
-- 
1.7.11.7
