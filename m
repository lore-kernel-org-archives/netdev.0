From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/11] sfc: Allow filter removal only with exactly
 matching priority
Date: Mon, 16 Dec 2013 21:33:02 +0000
Message-ID: <1387229582.1799.48.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8623 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982Ab3LPVdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:33:06 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently a higher priority client can remove a lower priority
client's filter with equal match-expression.  This might happen if (a)
the higher priority client has a double-free bug, or (b) another
client with sufficient priority replaced and then removed an equal
filter, allowing the low priority client to insert an equal filter.

In neither case does it actually make sense to carry out the removal;
we should say the filter doesn't exist, as the filter currently
present is not the one that the high-priority client is referring to.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c  | 2 +-
 drivers/net/ethernet/sfc/farch.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 2adc8e45461b..155602c500d5 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2563,7 +2563,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 		goto out_unlock;
 	}
 
-	if (spec->priority > priority) {
+	if (spec->priority != priority) {
 		rc = -ENOENT;
 		goto out_unlock;
 	}
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 378d6b968c4c..eed0741c2497 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -2543,7 +2543,7 @@ static int efx_farch_filter_remove(struct efx_nic *efx,
 	struct efx_farch_filter_spec *spec = &table->spec[filter_idx];
 
 	if (!test_bit(filter_idx, table->used_bitmap) ||
-	    spec->priority > priority)
+	    spec->priority != priority)
 		return -ENOENT;
 
 	if (spec->flags & EFX_FILTER_FLAG_RX_OVER_AUTO) {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
