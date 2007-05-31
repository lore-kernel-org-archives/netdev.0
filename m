From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers are removed
Date: Thu, 31 May 2007 14:50:35 +0200
Message-ID: <200705311450.36492@nienna>
References: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli> <200705301138.29582@nienna> <Pine.LNX.4.58.0705310239240.3745@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	horms@verge.net.au, jkrzyszt@tis.icnet.pl, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:3104 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbXEaMuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 08:50:40 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 0BF41B5596
	for <netdev@vger.kernel.org>; Thu, 31 May 2007 14:50:38 +0200 (CEST)
In-Reply-To: <Pine.LNX.4.58.0705310239240.3745@u.domain.uli>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

On Thursday 31 May 2007 02:21, Julian Anastasov wrote:
> >   I've posted a few patches making omitting this check possible
> > selectively back in March. Do those changes look acceptable?
> >
> >   http://marc.info/?l=linux-netdev&m=117310979823297&w=3
> 	Also, i'm not sure if FLOWI_FLAG_TRANSPARENT should cause
> different values for flags to be cached many times. Users without this
> flag get EINVAL when fl4_src is not configured, other failures are not
> cached too. And as fl4_src is considered in both cases (both kinds of
> callers get same path on success) we don't need changes except in
> ip_route_output_slow()? By this way I hope we can avoid any possible
> forking of cache entries just by different flags.

  Indeed, for output it probably does not matter, I've removed the flags
check from the flow index compare routine.

> 	Then we can use some more generic name, only for the flowi flag,
> eg. FLOWI_FLAG_ANYSRC or something better?

  You're right, _TRANSPARENT was a bad idea. I'm not very good at
choosing names.

  So what about this one?



Loosen source address check on IPv4 output

From: KOVACS Krisztian <hidden@balabit.hu>

ip_route_output() contains a check to make sure that no flows with
non-local source IP addresses are routed. This obviously makes using
such addresses impossible.

This patch introduces a flowi flag which makes omitting this check
possible. The new flag provides a way of handling transparent and
non-transparent connections differently.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
---

 include/net/flow.h |    1 +
 net/ipv4/route.c   |   47 +++++++++++++++++++++++++----------------------
 2 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index f3cc1f8..1bfc0dc 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -49,6 +49,7 @@ struct flowi {
 	__u8	proto;
 	__u8	flags;
 #define FLOWI_FLAG_MULTIPATHOLDROUTE 0x01
+#define FLOWI_FLAG_ANYSRC 0x02
 	union {
 		struct {
 			__be16	sport;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8603cfb..88d0a79 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2396,7 +2396,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 
 		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 		dev_out = ip_dev_find(oldflp->fl4_src);
-		if (dev_out == NULL)
+		if (dev_out == NULL && !(oldflp->flags & FLOWI_FLAG_ANYSRC))
 			goto out;
 
 		/* I removed check for oif == dev_out->oif here.
@@ -2407,29 +2407,32 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 		      of another iface. --ANK
 		 */
 
-		if (oldflp->oif == 0
-		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
-			/* Special hack: user can direct multicasts
-			   and limited broadcast via necessary interface
-			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
-			   This hack is not just for fun, it allows
-			   vic,vat and friends to work.
-			   They bind socket to loopback, set ttl to zero
-			   and expect that it will work.
-			   From the viewpoint of routing cache they are broken,
-			   because we are not allowed to build multicast path
-			   with loopback source addr (look, routing cache
-			   cannot know, that ttl is zero, so that packet
-			   will not leave this host and route is valid).
-			   Luckily, this hack is good workaround.
-			 */
+		if (dev_out) {
+			if (oldflp->oif == 0
+			    && (MULTICAST(oldflp->fl4_dst)
+				|| oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+				/* Special hack: user can direct multicasts
+				   and limited broadcast via necessary interface
+				   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
+				   This hack is not just for fun, it allows
+				   vic,vat and friends to work.
+				   They bind socket to loopback, set ttl to zero
+				   and expect that it will work.
+				   From the viewpoint of routing cache they are broken,
+				   because we are not allowed to build multicast path
+				   with loopback source addr (look, routing cache
+				   cannot know, that ttl is zero, so that packet
+				   will not leave this host and route is valid).
+				   Luckily, this hack is good workaround.
+				*/
+
+				fl.oif = dev_out->ifindex;
+				goto make_route;
+			}
 
-			fl.oif = dev_out->ifindex;
-			goto make_route;
-		}
-		if (dev_out)
 			dev_put(dev_out);
-		dev_out = NULL;
+			dev_out = NULL;
+		}
 	}
 
 
