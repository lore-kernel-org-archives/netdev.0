From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/16] sfc: Hold the RTNL lock for more of the
 suspend/resume cycle
Date: Fri, 24 Aug 2012 20:51:10 +0100
Message-ID: <1345837870.2694.29.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56751 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758130Ab2HXTvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:51:13 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't think these PM functions can race with userland net device
operations, but it's much easier to reason about locking if state is
consistently guarded by the same lock.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 9f88ad8..e5f3a17 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2727,6 +2727,8 @@ static int efx_pm_freeze(struct device *dev)
 {
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 
+	rtnl_lock();
+
 	efx->state = STATE_UNINIT;
 
 	netif_device_detach(efx->net_dev);
@@ -2734,6 +2736,8 @@ static int efx_pm_freeze(struct device *dev)
 	efx_stop_all(efx);
 	efx_stop_interrupts(efx, false);
 
+	rtnl_unlock();
+
 	return 0;
 }
 
@@ -2741,6 +2745,8 @@ static int efx_pm_thaw(struct device *dev)
 {
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 
+	rtnl_lock();
+
 	efx_start_interrupts(efx, false);
 
 	mutex_lock(&efx->mac_lock);
@@ -2755,6 +2761,8 @@ static int efx_pm_thaw(struct device *dev)
 
 	efx->type->resume_wol(efx);
 
+	rtnl_unlock();
+
 	/* Reschedule any quenched resets scheduled during efx_pm_freeze() */
 	queue_work(reset_workqueue, &efx->reset_work);
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
