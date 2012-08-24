From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/16] sfc: Hold RTNL lock (only) when calling
 efx_stop_interrupts()
Date: Fri, 24 Aug 2012 20:51:41 +0100
Message-ID: <1345837901.2694.31.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56768 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932254Ab2HXTvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:51:44 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interrupt state should be consistently guarded by the RTNL lock once
the net device is registered.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index f02591b..629029e 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2164,9 +2164,9 @@ void efx_reset_down(struct efx_nic *efx, enum reset_type method)
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	efx_stop_all(efx);
-	mutex_lock(&efx->mac_lock);
-
 	efx_stop_interrupts(efx, false);
+
+	mutex_lock(&efx->mac_lock);
 	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE)
 		efx->phy_op->fini(efx);
 	efx->type->fini(efx);
@@ -2492,11 +2492,11 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	rtnl_lock();
 	efx->state = STATE_UNINIT;
 	dev_close(efx->net_dev);
+	efx_stop_interrupts(efx, false);
 
 	/* Allow any queued efx_resets() to complete */
 	rtnl_unlock();
 
-	efx_stop_interrupts(efx, false);
 	efx_sriov_fini(efx);
 	efx_unregister_netdev(efx);
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
