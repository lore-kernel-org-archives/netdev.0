From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/16] sfc: Keep disabled NICs quiescent during
 suspend/resume
Date: Fri, 24 Aug 2012 20:51:24 +0100
Message-ID: <1345837884.2694.30.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56760 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758130Ab2HXTv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:51:27 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we ignore and clear the disabled state.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   28 ++++++++++++++++------------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index e5f3a17..f02591b 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2729,12 +2729,14 @@ static int efx_pm_freeze(struct device *dev)
 
 	rtnl_lock();
 
-	efx->state = STATE_UNINIT;
+	if (efx->state != STATE_DISABLED) {
+		efx->state = STATE_UNINIT;
 
-	netif_device_detach(efx->net_dev);
+		netif_device_detach(efx->net_dev);
 
-	efx_stop_all(efx);
-	efx_stop_interrupts(efx, false);
+		efx_stop_all(efx);
+		efx_stop_interrupts(efx, false);
+	}
 
 	rtnl_unlock();
 
@@ -2747,19 +2749,21 @@ static int efx_pm_thaw(struct device *dev)
 
 	rtnl_lock();
 
-	efx_start_interrupts(efx, false);
+	if (efx->state != STATE_DISABLED) {
+		efx_start_interrupts(efx, false);
 
-	mutex_lock(&efx->mac_lock);
-	efx->phy_op->reconfigure(efx);
-	mutex_unlock(&efx->mac_lock);
+		mutex_lock(&efx->mac_lock);
+		efx->phy_op->reconfigure(efx);
+		mutex_unlock(&efx->mac_lock);
 
-	efx_start_all(efx);
+		efx_start_all(efx);
 
-	netif_device_attach(efx->net_dev);
+		netif_device_attach(efx->net_dev);
 
-	efx->state = STATE_READY;
+		efx->state = STATE_READY;
 
-	efx->type->resume_wol(efx);
+		efx->type->resume_wol(efx);
+	}
 
 	rtnl_unlock();
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
