From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 1/2] sfc: Wait for MC reboot to complete before
 scheduling driver reset
Date: Sat, 21 Sep 2013 18:47:05 +0100
Message-ID: <1379785625.1681.22.camel@bwh-desktop.uk.level5networks.com>
References: <1379785504.1681.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19852 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab3IURrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 13:47:08 -0400
In-Reply-To: <1379785504.1681.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Scheduling a reset following an MC reboot event before waiting for
reboot to complete results in a race that can lead to a state where
must_realloc_vis is false in efx_ef10_fini_dmaq() but the VIs have
been destroyed during the MC reboot.

To avoid MC errors when trying to remove VIs that do not exist, wait
for the MC reboot to complete before scheduling the reset.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 128d7cd..73143ec 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -800,9 +800,6 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 	} else {
 		int count;
 
-		/* Nobody was waiting for an MCDI request, so trigger a reset */
-		efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
-
 		/* Consume the status word since efx_mcdi_rpc_finish() won't */
 		for (count = 0; count < MCDI_STATUS_DELAY_COUNT; ++count) {
 			if (efx_mcdi_poll_reboot(efx))
@@ -810,6 +807,9 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 			udelay(MCDI_STATUS_DELAY_US);
 		}
 		mcdi->new_epoch = true;
+
+		/* Nobody was waiting for an MCDI request, so trigger a reset */
+		efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
 	}
 
 	spin_unlock(&mcdi->iface_lock);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
