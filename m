From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/13] sfc: Reset driver's MAC stats after MC
 reboot seen
Date: Sat, 1 Dec 2012 04:43:13 +0000
Message-ID: <1354336993.2640.48.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26177 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab2LAEnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:43:16 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the MC reboots then the stats it reports to us will have been
reset.  We need to reset ours to get efx_update_diff_stat() working
properly.

(Ideally we would maintain stats across the reboot, but as this should
only happen immediately after a firmware upgrade it's not really worth
the trouble.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index e1967fb..3ef71a0 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -207,7 +207,9 @@ out:
 	return 0;
 }
 
-/* Test and clear MC-rebooted flag for this port/function */
+/* Test and clear MC-rebooted flag for this port/function; reset
+ * software state as necessary.
+ */
 int efx_mcdi_poll_reboot(struct efx_nic *efx)
 {
 	unsigned int addr = FR_CZ_MC_TREG_SMEM + MCDI_STATUS(efx);
@@ -223,6 +225,11 @@ int efx_mcdi_poll_reboot(struct efx_nic *efx)
 	if (value == 0)
 		return 0;
 
+	/* MAC statistics have been cleared on the NIC; clear our copy
+	 * so that efx_update_diff_stat() can continue to work.
+	 */
+	memset(&efx->mac_stats, 0, sizeof(efx->mac_stats));
+
 	EFX_ZERO_DWORD(reg);
 	efx_writed(efx, &reg, addr);
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
