From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/5] ipv4: Don't use the cached pmtu informations for input
 routes
Date: Wed, 23 Nov 2011 13:14:50 +0100
Message-ID: <20111123121450.GE6348@secunet.com>
References: <20111123121213.GA6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53469 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754918Ab1KWMOy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 07:14:54 -0500
Content-Disposition: inline
In-Reply-To: <20111123121213.GA6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pmtu informations on the inetpeer are visible for output and
input routes. On packet forwarding, we might propagate a learned
pmtu to the sender. As we update the pmtu informations of the
inetpeer on demand, the original sender of the forwarded packets
might never notice when the pmtu to that inetpeer increases.
So use the mtu of the outgoing device on packet forwarding instead
of the pmtu to the final destination.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 11d1b20..fb47c8f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1816,15 +1816,15 @@ static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
 
 static unsigned int ipv4_mtu(const struct dst_entry *dst)
 {
+	const struct rtable *rt = (const struct rtable *) dst;
 	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
 
-	if (mtu)
+	if (mtu && rt_is_output_route(rt))
 		return mtu;
 
 	mtu = dst->dev->mtu;
 
 	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
-		const struct rtable *rt = (const struct rtable *) dst;
 
 		if (rt->rt_gateway != rt->rt_dst && mtu > 576)
 			mtu = 576;
-- 
1.7.0.4
