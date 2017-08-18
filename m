From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 03/14] amd-xgbe: Be sure driver shuts down
 cleanly on module removal
Date: Thu, 17 Aug 2017 19:02:30 -0500
Message-ID: <20170818000230.10005.19944.stgit@tlendack-t1.amdoffice.net>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0072.outbound.protection.outlook.com ([104.47.36.72]:13088
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753836AbdHRACg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 20:02:36 -0400
In-Reply-To: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes when the driver is being unloaded while the devices are still
up the driver can issue errors.  This is based on timing and the double
invocation of some routines.  The phy_exit() call needs to be run after
the network device has been closed and unregistered from the system.
Also, the phy_exit() does not need to invoke phy_stop() since that will
be called as part of the device closing, so remove that call.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    4 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |    2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 500147d..53a425c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -458,6 +458,8 @@ void xgbe_deconfig_netdev(struct xgbe_prv_data *pdata)
 	if (IS_REACHABLE(CONFIG_PTP_1588_CLOCK))
 		xgbe_ptp_unregister(pdata);
 
+	unregister_netdev(netdev);
+
 	pdata->phy_if.phy_exit(pdata);
 
 	flush_workqueue(pdata->an_workqueue);
@@ -465,8 +467,6 @@ void xgbe_deconfig_netdev(struct xgbe_prv_data *pdata)
 
 	flush_workqueue(pdata->dev_workqueue);
 	destroy_workqueue(pdata->dev_workqueue);
-
-	unregister_netdev(netdev);
 }
 
 static int __init xgbe_mod_init(void)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 2222bbf8..2409202 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -1533,8 +1533,6 @@ static int xgbe_phy_best_advertised_speed(struct xgbe_prv_data *pdata)
 
 static void xgbe_phy_exit(struct xgbe_prv_data *pdata)
 {
-	xgbe_phy_stop(pdata);
-
 	pdata->phy_if.phy_impl.exit(pdata);
 }
 
