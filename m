From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Thu, 25 Feb 2010 11:40:29 +0100
Message-ID: <20100225104029.GB3927@gauss.dd.secunet.de>
References: <1267017564.3973.790.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:60359 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753519Ab0BYLBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 06:01:43 -0500
Content-Disposition: inline
In-Reply-To: <1267017564.3973.790.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2010 at 08:19:24AM -0500, jamal wrote:
> 
> 1)In the connect() stage, in the slow path a route cache is
> created with the rth->fl.fl4_src of 0.0.0.0...
> ==> policy->bundles is empty, so we do a lookup, fail, create
> one.. (remember rth->fl.fl4_src of 0.0.0.0 at this stage and
> thats what we end storing in the bundle/xdst for later comparison
> instead of the skb's fl)
> 
> 2)ping sends a packet (does a sendmsg) 
> ==> xfrm_find_bundle() ends up comparing skb's->fl (non-zero
> fl->fl4_src) with what we stored from #1b. Fails.
> ==> we create a new bundle at attach the old one at the end of it.
> ...and now policy->bundles has two xdst entries
> 
> 3) Repeat #2, and now we have 3 xdsts in policy bundles
> 
> 4) Repeat #2, and now we have 4 xdsts in policy bundles..
> 
> 5) Send 7 more pings and look at slabinfo and youll see
> 10 object all of which are active..
> 
> Essentially this seems to go on and on and i can cache a huge
> number of xdsts..
> 

Do you have CONFIG_XFRM_SUB_POLICY enabled?

I observed the same behaviour recently when I had CONFIG_XFRM_SUB_POLICY
enabled. The problem in my case is, that we do a route lookup based on a flow
with a source address of 0.0.0.0 in ip_route_output_flow() if we send a ping
packet. Then we update the flow's source address based on the routing
informations we got from __ip_route_output_key(). Now the actual flow does
not match the the flow information in the routing table anymore. As a result,
we generate a new xfrm bundle entry with every ping packet, as you pointed out.

I solved this by rerunning __ip_route_output_key() if we change the source or
destination address of the flow (patch below). I have not send the patch so
far because I'm not that familiar with the routing code and I'm still not sure
whether this is the right way to fix it, so I wanted to do some further
analysis first.

Interestingly this does not happen if CONFIG_XFRM_SUB_POLICY is disabled.

When ping is started, it opens a udp socket. This triggers a xfrm_lookup()
and a xfrm bundle entry is generated. In the standard case, the flow of the
ping packets matching the flow informations from the bundle entry generated 
by the opening of the udp socket, because we don't care for the upper layer
flow information here. Unlike the standard case, if CONFIG_XFRM_SUB_POLICY is
enabled we do upper layer information matching with flow_cache_uli_match().
Now the flow of the ping packets does, of course, not match the flow
informations of the bundle entry and we generate a new bundle entry with
every packet...


---
 net/ipv4/route.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d62b05d..3bf0b89 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2778,15 +2778,26 @@ int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
 			 struct sock *sk, int flags)
 {
 	int err;
+	int update_route = 0;
 
 	if ((err = __ip_route_output_key(net, rp, flp)) != 0)
 		return err;
 
 	if (flp->proto) {
-		if (!flp->fl4_src)
+		if (!flp->fl4_src) {
 			flp->fl4_src = (*rp)->rt_src;
-		if (!flp->fl4_dst)
+			update_route = 1;
+		}
+		if (!flp->fl4_dst) {
 			flp->fl4_dst = (*rp)->rt_dst;
+			update_route = 1;
+		}
+		if (update_route) {
+			dst_release(&(*rp)->u.dst);
+			if ((err = __ip_route_output_key(net, rp, flp)) != 0)
+				return err;
+		}
+
 		err = __xfrm_lookup(net, (struct dst_entry **)rp, flp, sk,
 				    flags ? XFRM_LOOKUP_WAIT : 0);
 		if (err == -EREMOTE)
-- 
1.5.6.5

