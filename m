From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: skbuff: skb_under_panic warning in 3.10rc7+
Date: Mon, 1 Jul 2013 10:24:40 +0200
Message-ID: <20130701082440.GA3351@order.stressinduktion.org>
References: <20130630160246.GA24539@redhat.com> <20130630221322.GA27948@order.stressinduktion.org> <20130630232308.GC24483@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: gaofeng@cn.fujitsu.com
To: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:47270 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104Ab3GAIYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 04:24:41 -0400
Content-Disposition: inline
In-Reply-To: <20130630232308.GC24483@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 01, 2013 at 01:23:08AM +0200, Hannes Frederic Sowa wrote:
> I'll look at it again tomorrow.

[Cc Gao feng because of commit 0c1833797a5a6ec23ea9261d979aa18078720b74
("ipv6: fix incorrect ipsec fragment")]

Just a small update:

The following diff fixes the UDP_CORK case for me. I just traced the various
len variables and brought ip6_append_data_mtu in line with the initial
initialization when the first call to ip6_append_data happens.

I'll have to do more research on this and check if this correlates
somehow with Dave's report.

--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1097,7 +1097,9 @@ static void ip6_append_data_mtu(int *mtu,
                                int *maxfraglen,
                                unsigned int fragheaderlen,
                                struct sk_buff *skb,
-                               struct rt6_info *rt)
+                               struct rt6_info *rt,
+                               __u32 frag_size,
+                               bool pmtudisc)
 {
        if (!(rt->dst.flags & DST_XFRM_TUNNEL)) {
                if (skb == NULL) {
@@ -1109,7 +1111,9 @@ static void ip6_append_data_mtu(int *mtu,
                         * this fragment is not first, the headers
                         * space is regarded as data space.
                         */
-                       *mtu = dst_mtu(rt->dst.path);
+                       *mtu = pmtudisc ? rt->dst.dev->mtu : dst_mtu(rt->dst.path);
+                       if (frag_size && frag_size < *mtu)
+                               *mtu = frag_size;
                }
                *maxfraglen = ((*mtu - fragheaderlen) & ~7)
                              + fragheaderlen - sizeof(struct frag_hdr);
@@ -1287,7 +1291,8 @@ alloc_new_skb:
                        /* update mtu and maxfraglen if necessary */
                        if (skb == NULL || skb_prev == NULL)
                                ip6_append_data_mtu(&mtu, &maxfraglen,
-                                                   fragheaderlen, skb, rt);
+                                               fragheaderlen, skb, rt, np->frag_size,
+                                               np->pmtudisc == IPV6_PMTUDISC_PROBE);
 
                        skb_prev = skb;
 
