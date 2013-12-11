From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 8/8] sfc: Poll for MCDI completion once before timeout
 occurs
Date: Wed, 11 Dec 2013 01:58:11 +0000
Message-ID: <1386727091.1516.246.camel@bwh-desktop.uk.level5networks.com>
References: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41050 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab3LKB6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:58:14 -0500
In-Reply-To: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Stonehouse <rstonehouse@solarflare.com>

There is an as-yet unexplained bug that sometimes prevents (or delays)
the driver seeing the completion event for a completed MCDI request on
the SFC9120.  The requested configuration change will have happened
but the driver assumes it to have failed, and this can result in
further failures.  We can mitigate this by polling for completion
after unsuccessfully waiting for an event.

Fixes: 8127d661e77f ('sfc: Add support for Solarflare SFC9100 family')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 9f26e46ee283..4b0bd8a1514d 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -630,6 +630,16 @@ int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 		rc = efx_mcdi_await_completion(efx);
 
 	if (rc != 0) {
+		netif_err(efx, hw, efx->net_dev,
+			  "MC command 0x%x inlen %d mode %d timed out\n",
+			  cmd, (int)inlen, mcdi->mode);
+
+		if (mcdi->mode == MCDI_MODE_EVENTS && efx_mcdi_poll_once(efx)) {
+			netif_err(efx, hw, efx->net_dev,
+				  "MCDI request was completed without an event\n");
+			rc = 0;
+		}
+
 		/* Close the race with efx_mcdi_ev_cpl() executing just too late
 		 * and completing a request we've just cancelled, by ensuring
 		 * that the seqno check therein fails.
@@ -638,11 +648,9 @@ int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 		++mcdi->seqno;
 		++mcdi->credits;
 		spin_unlock_bh(&mcdi->iface_lock);
+	}
 
-		netif_err(efx, hw, efx->net_dev,
-			  "MC command 0x%x inlen %d mode %d timed out\n",
-			  cmd, (int)inlen, mcdi->mode);
-	} else {
+	if (rc == 0) {
 		size_t hdr_len, data_len;
 
 		/* At the very least we need a memory barrier here to ensure

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
