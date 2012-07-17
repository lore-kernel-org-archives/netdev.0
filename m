From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/10] sfc: Use dev_kfree_skb() in
 efx_end_loopback()
Date: Tue, 17 Jul 2012 19:06:55 +0100
Message-ID: <1342548415.2698.24.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49432 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756024Ab2GQSG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:06:59 -0400
In-Reply-To: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix CID 102619 in the Coverity report on Linux.

efx_end_loopback() iterates over an array of skb pointers of which
some may be null (if efx_begin_loopback() failed).  It should not use
dev_kfree_skb_irq(), which requires non-null pointers.  In practice
this is safe because it does not run in interrupt context and
therefore always ends up calling dev_kfree_skb(), which does allow
null pointers.  But we should make that explicit.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/selftest.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index de4c006..ccc428f 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -488,7 +488,7 @@ static int efx_end_loopback(struct efx_tx_queue *tx_queue,
 		skb = state->skbs[i];
 		if (skb && !skb_shared(skb))
 			++tx_done;
-		dev_kfree_skb_any(skb);
+		dev_kfree_skb(skb);
 	}
 
 	netif_tx_unlock_bh(efx->net_dev);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
