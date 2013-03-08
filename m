From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Fri, 8 Mar 2013 14:04:33 +0100
Message-ID: <20130308130433.GB28531@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51243 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933875Ab3CHNEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 08:04:34 -0500
Content-Disposition: inline
In-Reply-To: <20130308055718.GA28531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 06:57:18AM +0100, Hannes Frederic Sowa wrote:
> On Thu, Mar 07, 2013 at 10:42:11PM +0100, Hannes Frederic Sowa wrote:
> > ipv6_addr_hash can yield the exact same hash value for countless ip
> > addresses from one /64 subnet. Let's make it a bit harder to create a
> > long list of reassembly queues in the hash table by using a stronger hash.
> > 
> > I spotted this just by looking at the source and did not verify if it
> > is really the case, so this patch has RFC status. But the jhash change
> > should not really hurt anyway. This patch is only compile tested.
> 
> Hmpf, I haven't seen Eric's change(279e9f2: ipv6: optimize
> inet6_hash_frag()) and tried to compare a v3.8 against a net-next
> kernel. At a first sight, it seems in some kind of denial of service
> scenario the relative amount of time spend in inet_frag_find increased,
> but I will do more comparable benchmarks later today (could be also
> because of other changes). I just wanted to let you know that I will do
> more research on this one and that you shouldn't apply this patch for now.
> 
> I also noticed that this function is also used by netfilter in the
> forwarding path. Perhaps a jenkins hash on the destination address would
> be better, too. Perhaps a netfilter specific hash function could also
> be used.

Getting benchmarks on my box is actually pretty hairy without burning
it down. :)

Generating a flow of fragmented packets with frag_id set to zero and ipv6
addresses which generate the same ipv6_addr_hash I gathered this from a debug
printk in inet6_hash_frag (current version from net-next):

[   25.992202] FRAG6: hash -635286572
[   25.992218] FRAG6: hash -635286572
[   25.992237] FRAG6: hash -635286572
[   25.992253] FRAG6: hash -635286572
[   25.992273] FRAG6: hash -635286572
[   25.992289] FRAG6: hash -635286572
[   25.992309] FRAG6: hash -635286572
[   25.992327] FRAG6: hash -635286572
[   25.992347] FRAG6: hash -635286572
[   25.992363] FRAG6: hash -635286572
[   25.992382] FRAG6: hash -635286572
[   25.992398] FRAG6: hash -635286572

With the patches reverted:

[   39.770790] FRAG6: hash 1323153854
[   39.773691] FRAG6: hash 1323153854
[   39.776413] FRAG6: hash 977187067
[   39.778782] FRAG6: hash 977187067
[   39.781298] FRAG6: hash -1226453562
[   39.784043] FRAG6: hash -1226453562
[   39.786443] FRAG6: hash -923346920
[   39.789431] FRAG6: hash -923346920
[   39.792205] FRAG6: hash 282862966
[   39.794918] FRAG6: hash 282862966
[   39.797749] FRAG6: hash -1059175404
[   39.800054] FRAG6: hash -1059175404
[   39.802904] FRAG6: hash -1085381868

It is pretty simple to generate a source of different addresses that yield to
the same hash value.

So I am in favour to revert the optimization changes in 279e9f2. It seems that
even ipv6_addr_jhash is not strong enough when used in the forwarding path for
reassembly, because of the xor of the most significant 32 bits of the address.

Quick test program is here: https://gist.github.com/hannes/5116331

Ok if I send a patch later to revert this change? What do you think about
increasing the size of the fragmentation queue hash table INETFRAGS_HASHSZ,
too?

Thanks,

  Hannes
