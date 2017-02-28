From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 1/3] amd-xgbe: Stop the PHY before releasing
 interrupts
Date: Tue, 28 Feb 2017 15:02:51 -0600
Message-ID: <20170228210251.32166.39747.stgit@tlendack-t1.amdoffice.net>
References: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0053.outbound.protection.outlook.com ([104.47.40.53]:62642
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751793AbdB1VVE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 16:21:04 -0500
In-Reply-To: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some configurations require the use of the hardware's MDIO support to
communicate with external PHYs. The MDIO commands indicate completion
through the device interrupt. When bringing down the device the interrupts
were released before stopping the external PHY, resulting in MDIO command
timeouts. Move the stopping of the PHY to before the releasing of the
interrupts.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 3aa457c..248f60d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1131,12 +1131,12 @@ static void xgbe_stop(struct xgbe_prv_data *pdata)
 	hw_if->disable_tx(pdata);
 	hw_if->disable_rx(pdata);
 
+	phy_if->phy_stop(pdata);
+
 	xgbe_free_irqs(pdata);
 
 	xgbe_napi_disable(pdata, 1);
 
-	phy_if->phy_stop(pdata);
-
 	hw_if->exit(pdata);
 
 	channel = pdata->channel;
