From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 5/7] sfc: Fix assertions in efx_filter_rfs()
Date: Thu, 14 Jul 2011 02:17:39 +0100
Message-ID: <1310606259.2756.28.camel@bwh-desktop>
References: <1310606090.2756.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11288 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094Ab1GNBRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:17:42 -0400
In-Reply-To: <1310606090.2756.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is intended to assert (when DEBUG is defined) that the
skb header area includes the header fields it's looking at, which RFS
should already have pulled.  But it uses pskb_may_pull(), which will
attempt to pull more data if necesary.  It must instead compare
skb_headlen() with the required length.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/filter.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 054f0a3..2b9636f 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -657,11 +657,11 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 		return -EPROTONOSUPPORT;
 
 	/* RFS must validate the IP header length before calling us */
-	EFX_BUG_ON_PARANOID(!pskb_may_pull(skb, nhoff + sizeof(*ip)));
+	EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + sizeof(*ip));
 	ip = (const struct iphdr *)(skb->data + nhoff);
 	if (ip_is_fragment(ip))
 		return -EPROTONOSUPPORT;
-	EFX_BUG_ON_PARANOID(!pskb_may_pull(skb, nhoff + 4 * ip->ihl + 4));
+	EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + 4 * ip->ihl + 4);
 	ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
 
 	efx_filter_init_rx(&spec, EFX_FILTER_PRI_HINT, 0, rxq_index);
-- 
1.7.4.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

