From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] sfc: Enable RX scatter for flows steered by RFS
Date: Tue, 23 Jul 2013 00:17:25 +0100
Message-ID: <1374535045.1635.57.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40229 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab3GVXRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 19:17:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Received packets are only scattered if this is enabled in both the
matching filter and the receiving queue.  This was not being done for
filters inserted for RFS, so any packet requiring more than a single
descriptor was dropped.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This should also go to stable for 3.10 only.

Ben.

 drivers/net/ethernet/sfc/filter.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index b74a60a..2a469b2 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -1209,7 +1209,9 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + 4 * ip->ihl + 4);
 	ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
 
-	efx_filter_init_rx(&spec, EFX_FILTER_PRI_HINT, 0, rxq_index);
+	efx_filter_init_rx(&spec, EFX_FILTER_PRI_HINT,
+			   efx->rx_scatter ? EFX_FILTER_FLAG_RX_SCATTER : 0,
+			   rxq_index);
 	rc = efx_filter_set_ipv4_full(&spec, ip->protocol,
 				      ip->daddr, ports[1], ip->saddr, ports[0]);
 	if (rc)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
