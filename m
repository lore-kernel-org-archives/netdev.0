From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 3/5] amd-xgbe: Call netif_napi_del on ndo_stop
 operation
Date: Wed, 2 Jul 2014 13:04:40 -0500
Message-ID: <20140702180440.14996.76357.stgit@tlendack-t1.amdoffice.net>
References: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0238.outbound.protection.outlook.com ([207.46.163.238]:46786
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757294AbaGBSEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 14:04:44 -0400
In-Reply-To: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the napi context is added using netif_napi_add each time
the ndo_open operation is called.  However, there is not a
corresponding netif_napi_del call during the ndo_stop operation. If
the device ndo_open operation was called more than once an infinite
loop occurs during module unload.  Add a call to netif_napi_del during
the ndo_stop operation.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 72dd611..b5fdf66 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -412,9 +412,12 @@ static void xgbe_napi_enable(struct xgbe_prv_data *pdata, unsigned int add)
 	napi_enable(&pdata->napi);
 }
 
-static void xgbe_napi_disable(struct xgbe_prv_data *pdata)
+static void xgbe_napi_disable(struct xgbe_prv_data *pdata, unsigned int del)
 {
 	napi_disable(&pdata->napi);
+
+	if (del)
+		netif_napi_del(&pdata->napi);
 }
 
 void xgbe_init_tx_coalesce(struct xgbe_prv_data *pdata)
@@ -518,7 +521,7 @@ int xgbe_powerdown(struct net_device *netdev, unsigned int caller)
 		netif_device_detach(netdev);
 
 	netif_tx_stop_all_queues(netdev);
-	xgbe_napi_disable(pdata);
+	xgbe_napi_disable(pdata, 0);
 
 	/* Powerdown Tx/Rx */
 	hw_if->powerdown_tx(pdata);
@@ -607,7 +610,7 @@ static void xgbe_stop(struct xgbe_prv_data *pdata)
 	phy_stop(pdata->phydev);
 
 	netif_tx_stop_all_queues(netdev);
-	xgbe_napi_disable(pdata);
+	xgbe_napi_disable(pdata, 1);
 
 	xgbe_stop_tx_timers(pdata);
 
