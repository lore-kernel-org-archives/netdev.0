From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 8 Aug 2006 10:57:31 +0200
Message-ID: <200608081057.32022.dada1@cosmosbay.com>
References: <44D75EF8.1070901@sw.ru> <20060807164842.GA3412@ms2.inr.ac.ru> <20060807.204214.68039839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:2207 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S932540AbWHHI5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 04:57:35 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060807.204214.68039839.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 August 2006 05:42, David Miller wrote:
> From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Date: Mon, 7 Aug 2006 20:48:42 +0400
>
> > The patch looks OK. But I am not sure too.
> >
> > To be honest, I do not understand the sense of HASH_HIGHMEM flag.
> > At the first sight, hash table eats low memory, objects hashed in this
> > table also eat low memory. Why is its size calculated from total memory?
> > But taking into account that this flag is used only by tcp.c and route.c,
> > both of which feed on low memory, I miss something important.
> >
> > Let's ask people on netdev.
>
> Is it not so hard to check history of the change to see where these
> things come from?  :-) If we study the output of command:
>
> 	git whatchanged net/core/route.c
>
> we quickly discover this GIT commit:
>
> 424c4b70cc4ff3930ee36a2ef7b204e4d704fd26
>
> [IPV4]: Use the fancy alloc_large_system_hash() function for route hash
> table
>
> - rt hash table allocated using alloc_large_system_hash() function.
>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> And it is clear that old code used num_physpages, which counts low
> memory only.  This shows clearly that Eric's usage of the HASH_HIGHMEM
> flag here is erroneous.  So we should remove it.

Yes probably.

If I recall well, I blindly copied code from net/ipv4/tcp.c (tcp ehash table 
allocation). I was not aware of this HASH_HIGHMEM part.

As the allocation of routes are SLAB_ATOMIC, while TCP sockets are allocated 
SLAB_KERNEL , it makes sense to size the route hash table accordingly to 
nr_kernel_pages instead of nr_all_pages

For TCP, an OOM is OK since sock_alloc_inode() should returns NULL and this 
should be handled fine.

I think we had discussion about being able to dynamically resize route hash 
table (or tcp hash table), using RCU. Did someone worked on this ?
For most current machines (ram size >= 1GB) , the default hash table sizes are 
just insane for 99% of uses.


>
> Look!  This thing even uses num_physpages in current code to compute
> the "scale" argument to alloc_large_system_hash() :)))
>
> > What's about routing cache size, it looks like it is another bug.
> > route.c should not force rt_max_size = 16*rt_hash_size.
> > I think it should consult available memory and to limit rt_max_size
> > to some reasonable value, even if hash size is too high.
>
> Sure.  This current setting of 16*rt_hash_size is meant to
> try to limit hash chain lengths I guess.  2.4.x does the same
> thing.  Note also that by basing it upon number of routing cache
> hash chains, it is effectively consulting available memory.
> This is why when hash table sizing is crap so it rt_max_size
> calculation.  Fix one and you fix them both :)
>
> Once the HASH_HIGHMEM flag is removed, assuming system has > 128K of
> memory, what we get is:
>
> 	hash_chains = lowmem / 128K
> 	rt_max_size = ((lowmem / 128K) * 16) == lowmem / 8K
>
> So we allow one routing cache entry for each 8K of lowmem we have :)
>
> So for now it is probably sufficient to just get rid of the
> HASH_HIGHMEM flag here.  Later we can try changing this multiplier
> of "16" to something like "8" or even "4".
