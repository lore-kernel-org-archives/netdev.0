From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2] ipv6: don't count addrconf generated routes against gc limit
Date: Sat, 7 Dec 2013 03:33:45 +0100
Message-ID: <20131207023345.GA16799@order.stressinduktion.org>
References: <20131206172556.GF26746@order.stressinduktion.org> <20131206.162124.1642753475890720004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, brett.ciphery@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37970 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700Ab3LGCdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 21:33:46 -0500
Content-Disposition: inline
In-Reply-To: <20131206.162124.1642753475890720004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brett Ciphery reported that new ipv6 addresses failed to get installed
because the addrconf generated dsts where counted against the dst gc
limit. We don't need to count those routes like we currently don't count
administratively added routes.

Because the max_addresses check enforces a limit on unbounded address
generation first in case someone plays with router advertisments, we
are still safe here.

Reported-by: Brett Ciphery <brett.ciphery@windriver.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

On Fri, Dec 06, 2013 at 04:21:24PM -0500, David Miller wrote:
> So basically, we only want to count routes that will have RTF_CACHE
> set on them.

Exactly.

> This warning in the net_warn_ratelimited() is no longer relevant, only
> hard memory allocation failures can result in this !rt condition.  So
> please respin this patch with that warning removed.

Sorry, I spinned the patch too fast after testing.

 net/ipv6/route.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ddb9d41..a0a48ac 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2166,12 +2166,10 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    bool anycast)
 {
 	struct net *net = dev_net(idev->dev);
-	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev, 0, NULL);
-
-	if (!rt) {
-		net_warn_ratelimited("Maximum number of routes reached, consider increasing route/max_size\n");
+	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev,
+					    DST_NOCOUNT, NULL);
+	if (!rt)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	in6_dev_hold(idev);
 
-- 
1.8.3.1
