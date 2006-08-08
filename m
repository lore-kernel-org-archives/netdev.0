From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 08 Aug 2006 12:17:57 +0400
Message-ID: <44D848B5.5080004@sw.ru>
References: <44D75EF8.1070901@sw.ru>	<20060807164842.GA3412@ms2.inr.ac.ru> <20060807.204214.68039839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:51472 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S932572AbWHHIQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 04:16:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060807.204214.68039839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> we quickly discover this GIT commit:
> 
> 424c4b70cc4ff3930ee36a2ef7b204e4d704fd26
> 
> [IPV4]: Use the fancy alloc_large_system_hash() function for route hash table
> 
> - rt hash table allocated using alloc_large_system_hash() function.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> And it is clear that old code used num_physpages, which counts low
> memory only.  This shows clearly that Eric's usage of the HASH_HIGHMEM
> flag here is erroneous.  So we should remove it.
at least for i686 num_physpages includes highmem, so IMHO this bug was there for years:

./arch/i386/mm/init.c:
static void __init set_max_mapnr_init(void)
{
#ifdef CONFIG_HIGHMEM
        num_physpages = highend_pfn;
#else
        num_physpages = max_low_pfn;
#endif
}

> Look!  This thing even uses num_physpages in current code to compute
> the "scale" argument to alloc_large_system_hash() :)))
the same bug here? :) the good thing is that it only select scale 15 or 17.
no any other possible choice here :)))

>>What's about routing cache size, it looks like it is another bug.
>>route.c should not force rt_max_size = 16*rt_hash_size.
>>I think it should consult available memory and to limit rt_max_size
>>to some reasonable value, even if hash size is too high.
> 
> 
> Sure.  This current setting of 16*rt_hash_size is meant to
> try to limit hash chain lengths I guess.  2.4.x does the same
> thing.  Note also that by basing it upon number of routing cache
> hash chains, it is effectively consulting available memory.
> This is why when hash table sizing is crap so it rt_max_size
> calculation.  Fix one and you fix them both :)
imho chain lengh limitation to 16 is not that bad, but to avoid such "features"
probably should be fixed :)

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
should we remove it for TCP hashes?

Thanks,
Kirill
