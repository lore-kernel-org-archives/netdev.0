From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/22] sfc: Disable RSS when using SR-IOV and only
 1 RX queue on the PF
Date: Mon, 11 Mar 2013 19:55:23 +0000
Message-ID: <1363031723.2608.47.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16766 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636Ab3CKTz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:55:26 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Siena, VFs share RSS configuration with the PF.  We attempted to
support configurations where the PF only uses 1 RX queue and VFs use
multiple RX queues, by (1) setting up RSS for the number of RX queues
per VF (2) disabling RSS in the PF's RX default filters.

Unfortunately commit cd2d5b529cdb ('sfc: Add SR-IOV back-end support
for SFC9000 family') only included (1).  This is (2).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 0de8daf..61b4408 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -414,8 +414,12 @@ static void efx_filter_reset_rx_def(struct efx_nic *efx, unsigned filter_idx)
 	struct efx_filter_table *table = &state->table[EFX_FILTER_TABLE_RX_DEF];
 	struct efx_filter_spec *spec = &table->spec[filter_idx];
 
+	/* If there's only one channel then disable RSS for non VF
+	 * traffic, thereby allowing VFs to use RSS when the PF can't.
+	 */
 	efx_filter_init_rx(spec, EFX_FILTER_PRI_MANUAL,
-			   EFX_FILTER_FLAG_RX_RSS, 0);
+			   efx->n_rx_channels > 1 ? EFX_FILTER_FLAG_RX_RSS : 0,
+			   0);
 	spec->type = EFX_FILTER_UC_DEF + filter_idx;
 	table->used_bitmap[0] |= 1 << filter_idx;
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
