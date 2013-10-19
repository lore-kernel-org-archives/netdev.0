From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path discovery oddities - flushing the routing cache resolves
Date: Sat, 19 Oct 2013 10:42:25 +0200
Message-ID: <20131019084225.GA31333@order.stressinduktion.org>
References: <525E6B03.1040409@blub.net> <20131016154841.GC18135@order.stressinduktion.org> <525FC1C4.3070605@blub.net> <20131018030440.GI18135@order.stressinduktion.org> <5260D8DE.30303@blub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, sgunderson@bigfoot.com
To: Valentijn Sessink <valentyn@blub.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44471 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab3JSIm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 04:42:27 -0400
Content-Disposition: inline
In-Reply-To: <5260D8DE.30303@blub.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 18, 2013 at 08:44:46AM +0200, Valentijn Sessink wrote:
> On 18-10-13 05:04, Hannes Frederic Sowa wrote:
> > Thanks, I needed this to verify I am on the right track replicating this.
> > 2001:1af8:ff03:3:219:66ff:fe26:6dd is the other end of the connection, I
> > guess?
> 
> Yes, the working connection (first example) is from
> 2001:1af8:ff03:3:219:66ff:fe26:6dd. The non-working connection should
> have an MTU of 1280 on the 2001:7b8:1529:: subnet connections (those are
> tunneled, with the tunnel restricting the MTU).

I got access to a nice test box yesterday where I could brute force the
problem in parallel (it was a PITA). This is what I found:

This first patch solves the problem of a complete lockdown of all sockets
towards one ipv6 destination. This can happen if we recheck the ipv6 fib
(expiration is ok) and we get back a rt6_info where we apply the new metrics
information on. After the check the dst entry expires and we do a relookup.
We try to insert the same routing information into the fib which results only
in a call to rt6_clean_expires. Because we don't reset the dst.expires value a
later update of mtu information won't update the expiration time because of
the strange semantics in rt6_update_expires. This patch should fix this.

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 6738f34..3932633 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -164,6 +164,7 @@ static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 
 static inline void rt6_clean_expires(struct rt6_info *rt)
 {
+	rt->dst.expires = 0;
 	rt->rt6i_flags &= ~RTF_EXPIRES;
 }

The second patch resolves the problem that the socket keeps hanging on
outdated mtu information which gets invalidated just after processing. We
need to relookup the destination entry in case the socket expires. This
helps a socket to free the cached dst before applying the mtu information
to an already expired dst which will be reinserted (see above, it will
only call rt6_clean_expires on the dst_entry). This is normally not a
problem, but in the process of the creation of the cloned dst_entry we
end up copying the metric information from the non-DST_CACHEd route to
the dst_entry (ip6_rt_copy/dst_copy_metrics). Because the information are
held in inetpeer storage and the key for the expired dst and the new dst
have the same key we overwrite the metrics store which currently is in
use by two rt6_infos. So we just invalidate the newly installed metrics
information and will use the interface mtu just after the PACKET_TOO_BIG
notification, which leads to hangs of the connection. A flush of the
cached routing entries causes relookups, so this a workaround.

This patch should fix this:

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c3130ff..7629022 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1064,10 +1064,13 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))
 		return NULL;
 
-	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
-		return dst;
+	if (!rt->rt6i_node && (rt->rt6i_node->fn_sernum != cookie))
+		return NULL;
 
-	return NULL;
+	if (rt6_check_expired(rt))
+		return NULL;
+
+	return dst;
 }
 
 static struct dst_entry *ip6_negative_advice(struct dst_entry *dst)


I had the patches in test for a few hours on some VMs where I could normally
reproduce this issue within 5 minutes. They are for testing only and I don't
know if they resolve all issues. I also have to check why rt6_update_expires
has such strange expiration update logic.

Steinar and Valentijn could you give them a test drive?

Greetings,

  Hannes
