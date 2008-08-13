From: David Miller <davem@davemloft.net>
Subject: Re: OOPS, ip -f inet6 route get fec0::1,
 linux-2.6.26,ip6_route_output, rt6_fill_node+0x175
Date: Wed, 13 Aug 2008 02:01:12 -0700 (PDT)
Message-ID: <20080813.020112.193705451.davem@davemloft.net>
References: <20080811110335.GA29407@kernel.sg>
	<9F6ACAE02B6DD040A1E259977622CFDB0335994F@oslexcp1.eu.tandberg.int>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eugeneteo@kernel.sg, brian.haley@hp.com, adobriyan@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: john.gumb@tandberg.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754161AbYHMJBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 05:01:11 -0400
In-Reply-To: <9F6ACAE02B6DD040A1E259977622CFDB0335994F@oslexcp1.eu.tandberg.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John Gumb" <john.gumb@tandberg.com>
Date: Tue, 12 Aug 2008 11:11:47 +0200

> I've enclosed patch from Eugene just so we all know which patch we're
> talking about. It 'works' according to the following definition:
> 
> a) Fixed OOPS
> b) runs overnight in our test network. This run doesn't do much specific
> ipv6 testing - but clearly what's there is catching stuff :-;

While Eugene's patch seems mostly fine, it's a bit over the top
to cure this OOPS and get backported to -stable I think.

So I've applied Brian's patch, as below, because we have many
other reports that it fixes the crash too.

I'd appreciate it if you'd test Brian's patch as well as you
tested Eugene's as this is what will go into the tree for the
time being.

We can reinvestigate Eugene's patch, but one thing I don't like
about it is that it adds this silly NULL check when that is
totally unnecessary in the vast majority of these call sites.

Yes yes, I'll submit this to stable too before someone bugs me
about that again.  I'll first let this sit and get tested for
a few days before I do that submission so don't panic if you
don't see it for a few days.

commit 5e0115e500fe9dd2ca11e6f92db9123204f1327a
Author: Brian Haley <brian.haley@hp.com>
Date:   Wed Aug 13 01:58:57 2008 -0700

    ipv6: Fix OOPS, ip -f inet6 route get fec0::1, linux-2.6.26, ip6_route_output, rt6_fill_node+0x175
    
    Alexey Dobriyan wrote:
    > On Thu, Aug 07, 2008 at 07:00:56PM +0200, John Gumb wrote:
    >> Scenario: no ipv6 default route set.
    >
    >> # ip -f inet6 route get fec0::1
    >>
    >> BUG: unable to handle kernel NULL pointer dereference at 00000000
    >> IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
    >> EIP is at rt6_fill_node+0x175/0x3b0
    >
    > 0xffffffff80424dd3 is in rt6_fill_node (net/ipv6/route.c:2191).
    > 2186                    } else
    > 2187    #endif
    > 2188                            NLA_PUT_U32(skb, RTA_IIF, iif);
    > 2189            } else if (dst) {
    > 2190                    struct in6_addr saddr_buf;
    > 2191      ====>         if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
    >					       ^^^^^^^^^^^^^^^^^^^^^^^^
    >											NULL
    >
    > 2192                                           dst, 0, &saddr_buf) == 0)
    > 2193                            NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
    > 2194            }
    
    The commit that changed this can't be reverted easily, but the patch
    below works for me.
    
    Fix NULL de-reference in rt6_fill_node() when there's no IPv6 input
    device present in the dst entry.
    
    Signed-off-by: Brian Haley <brian.haley@hp.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5a3e87e..41b165f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2187,8 +2187,9 @@ static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 #endif
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
+		struct inet6_dev *idev = ip6_dst_idev(&rt->u.dst);
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
+		if (ipv6_dev_get_saddr(idev ? idev->dev : NULL,
 				       dst, 0, &saddr_buf) == 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
