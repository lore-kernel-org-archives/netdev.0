From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 5/9] sfc: warn if other functions have been reset
 by MCFW
Date: Tue, 21 Jul 2015 15:10:02 +0100
Message-ID: <55AE52BA.7060001@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:34260 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752106AbbGUONE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:13:04 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

When enabling the workaround for cascaded multicast filters, the MC
 can reset other functions if they have already inserted filters.
 In that case, the workaround has been enabled, but print an info
 message in the log recording that other functions had to be reset.

As other functions were reset, the MC will have incremented its boot
 count, so also increment the warm_boot_count on the function which
 enabled the workaround, as that function won't have received an MC
 reboot event and does not need to reset.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 2b93f63..18d6388 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2291,13 +2291,24 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 
 		if (implemented & MC_CMD_GET_WORKAROUNDS_OUT_BUG26807 &&
 		    !nic_data->workaround_26807) {
+			unsigned int flags;
+
 			rc = efx_mcdi_set_workaround(efx,
 						     MC_CMD_WORKAROUND_BUG26807,
-						     true, NULL);
-			if (!rc)
+						     true, &flags);
+
+			if (!rc) {
+				if (flags &
+				    1 << MC_CMD_WORKAROUND_EXT_OUT_FLR_DONE_LBN) {
+					netif_info(efx, drv, efx->net_dev,
+						   "other functions on NIC have been reset\n");
+					/* MC's boot count has incremented */
+					++nic_data->warm_boot_count;
+				}
 				nic_data->workaround_26807 = true;
-			else if (rc == -EPERM)
+			} else if (rc == -EPERM) {
 				rc = 0;
+			}
 		}
 	}
 
