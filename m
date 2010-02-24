From: jamal <hadi@cyberus.ca>
Subject: [RFC PATCH]xfrm: fix perpetual bundles
Date: Wed, 24 Feb 2010 08:19:24 -0500
Message-ID: <1267017564.3973.790.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-doxMAM1yhp2gNiPvWNsn"
Cc: kaber@trash.net, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f191.google.com ([209.85.216.191]:51966 "EHLO
	mail-px0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006Ab0BXNTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 08:19:30 -0500
Received: by pxi29 with SMTP id 29so2644696pxi.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 05:19:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-doxMAM1yhp2gNiPvWNsn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Apologies for the shotgun email but this has been perplexing me for
sometime and i am worried the the patch i have is a band-aid (although
it fixes the problem), so here's a long-winded description..

Essentially, it is possible to create a scenario where the
xfrm policy->bundles grows indefinitely. This can be observed
from grep xfrm_dst_cache /proc/slabinfo
You can see the number of objects growing correlated to the number
of pings i send.... So if i sent 1K pings this way then stopped, 
there would be 1K objects in xfrm_dst_cache. If i start and send
another ping, slab grows to 2K.. etc

To recreate this, make sure you have a proper matching SP and SA and
any recent kernel (I can reproduce this in net-next 2.6 before and after
the xfrm mark merge). Use an app like iputils::ping. Ping uses raw
socket, does a connect() once and then sendmsg() for each packet.
You also need the receiver of ping to setup proper ipsec rules
so you get a response.

1)In the connect() stage, in the slow path a route cache is
created with the rth->fl.fl4_src of 0.0.0.0...
==> policy->bundles is empty, so we do a lookup, fail, create
one.. (remember rth->fl.fl4_src of 0.0.0.0 at this stage and
thats what we end storing in the bundle/xdst for later comparison
instead of the skb's fl)

2)ping sends a packet (does a sendmsg) 
==> xfrm_find_bundle() ends up comparing skb's->fl (non-zero
fl->fl4_src) with what we stored from #1b. Fails.
==> we create a new bundle at attach the old one at the end of it.
...and now policy->bundles has two xdst entries

3) Repeat #2, and now we have 3 xdsts in policy bundles

4) Repeat #2, and now we have 4 xdsts in policy bundles..

5) Send 7 more pings and look at slabinfo and youll see
10 object all of which are active..

Essentially this seems to go on and on and i can cache a huge
number of xdsts..

Of course if i do a ping -I <srcaddr>, ping does a bind();
then no problem since the correct rth->fl.fl4_src shows up
from connect and all goes well.
My patch assumes that a fl4_src of 0.0.0.0 is a wildcard
since if you bind to INADDR_ANY thats what it would be.
Another way to solve this would be in #1 above to copy
the skb's->fl instead of the dst's.

cheers,
jamal

--=-doxMAM1yhp2gNiPvWNsn
Content-Disposition: attachment; filename="perp-xdst"
Content-Type: text/x-patch; name="perp-xdst"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 67107d6..8a58843 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -69,7 +69,8 @@ __xfrm4_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
-		    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
+		    (!xdst->u.rt.fl.fl4_src ||
+		     xdst->u.rt.fl.fl4_src == fl->fl4_src) &&
 		    xdst->u.rt.fl.fl4_tos == fl->fl4_tos &&
 		    xfrm_bundle_ok(policy, xdst, fl, AF_INET, 0)) {
 			dst_clone(dst);

--=-doxMAM1yhp2gNiPvWNsn--

