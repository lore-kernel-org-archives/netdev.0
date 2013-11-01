From: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Subject: [RFC PATCH 2/2] ipv6: don't use routing cache for inexact matchings
Date: Fri, 1 Nov 2013 18:21:41 +0100
Message-ID: <DFD1E072-5112-4FFD-9BD7-525A2CE2D34B@telecom-bretagne.eu>
References: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zproxy210.enst-bretagne.fr ([192.108.117.8]:49143 "EHLO
	zproxy210.enst-bretagne.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752063Ab3KARaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 13:30:11 -0400
In-Reply-To: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On route selection, make the cache to be used only when the flow
output interface corresponds to the next hop interface. This
fixes problems for IPv6 hosts in multi-interfaces setup.

When a packet is sent through an interface, the RTF_CACHE entry
is created based on a specific flow information (e.g. with
fl6->flowi6_oif set to a specific value). If another packet is
sent with a different flow information than the first one, the
RTF_CACHE entry is used regardless of flow information, even if
this information would make the route selection algorithm to
select a different route.

By ignoring RTF_CACHE entries for which rt6_check_dev() fails,
we ensure consistency of the route selection algorithm.

Signed-off-by: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
---
 net/ipv6/route.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f54e3a1..65ce3d9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -595,7 +595,8 @@ static int rt6_score_route(struct rt6_info *rt, int oif,
 	int m;
 
 	m = rt6_check_dev(rt, oif);
-	if (!m && (strict & RT6_LOOKUP_F_IFACE))
+	if (!m &&
+	    ((strict & RT6_LOOKUP_F_IFACE) || (rt->rt6i_flags & RTF_CACHE)))
 		return RT6_NUD_FAIL_HARD;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	m |= IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;
-- 
1.7.9.5
