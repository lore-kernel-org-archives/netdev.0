From: akepner@sgi.com
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 8 Aug 2006 13:37:10 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0608081316330.2452@localhost.localdomain>
References: <44D75EF8.1070901@sw.ru> <20060807164842.GA3412@ms2.inr.ac.ru>
 <20060807.204214.68039839.davem@davemloft.net> <200608080711.06788.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:34243 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S964911AbWHHUq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 16:46:56 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200608080711.06788.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Aug 2006, Andi Kleen wrote:

>
> The hash sizing code needs far more tweaks. iirc it can still allocate
> several GB hash tables on large memory systems (i've seen that once in 
> the boot log  of a 2TB system).  Even on smaller systems it is usually 
> too much.

Yes. Linear growth with memory is not a good algorithm for
sizing hashes on a machine with ~TB... SGI has recommended
booting with "thash_entries=2097152", but that's often much
bigger than needed, too.

>
> IMHO there needs to be a maximum size (maybe related to the sum of
> caches of all CPUs in the system?)
>
> Best would be to fix this for all large system hashes together.

How about using an algorithm like this: up to a certain "size"
(memory size, cache size,...), scale the hash tables linearly; 
but for larger sizes, scale logarithmically (or approximately
logarithmically)

Code that implements this is below. (It's not perfect, but mostly
works. Just trying to get the idea across....) "struct hash_sizer"
has fields that fix the linear/logarithmic crossover point. And
size_system_hash() recommends the number of hash table entries
based the amount of memory.


#include <stdio.h>

unsigned long nr_all_pages;
#define PAGE_SHIFT 12
#define PAGE_SIZE (1UL << PAGE_SHIFT)

static int 
long_log2 (unsigned long x)
{
 	int r = 0;
 	for (x >>= 1; x > 0; x >>= 1)
 		r++;
 	return r;
}

/*
  * scale linearly 64Kibuckets/GiByte up to 1 GiByte,
  * and (sort of) logarithmically thereafter
  */
struct hash_sizer {
 	unsigned long buckets; /* power of 2 */
 	unsigned long bytes;   /* multiple of PAGE_SIZE */
} tcp_hash_sizer = {
 	(1UL << 16), /* 64 Kibuckets */
 	(1UL << 30)  /* GiByte */
};

unsigned long 
size_system_hash (struct hash_sizer *hs) 
{
 	unsigned long size;
 	unsigned long long slog;
 	unsigned long scale, tmp;
 	int log2, i = 0;

 	if ( nr_all_pages < (hs->bytes/PAGE_SIZE)) {
 		/* linear scaling */
 		unsigned long long tmp = nr_all_pages;
 		tmp *= hs->buckets;
 		tmp /= (hs->bytes/PAGE_SIZE);
 		return (unsigned long)tmp;
 	}

 	/* logarithmic scaling */
 	log2 = long_log2(nr_all_pages);
 	scale  = (1 << log2);

 	slog = log2 * scale;

 	tmp = nr_all_pages;
 	tmp &= ~(1 << log2);

 	while (tmp) {

 		i++;
 		tmp <<= 1;
 		if (tmp & (1 << log2))
 			slog += (scale / (1 << i));
 	}

 	/* slog/scale is approximately log2(nr_all_pages)
 	 */

 	size = (hs->buckets * slog)/scale;
 	size -= hs->buckets * (long_log2(hs->bytes) - PAGE_SHIFT);
 	size += hs->buckets;

 	return size;

}

int 
main(void) 
{

 	unsigned long hash_size;

 	printf("# nr_all_pages memory_size [bytes] hash_size\n");

 	for (nr_all_pages = 1; nr_all_pages < (1UL << 26);
 		//nr_all_pages <<= 1) {
 		nr_all_pages += 7919) {

 		hash_size = size_system_hash(&tcp_hash_sizer);
 		printf("  %lu          %llu                %lu\n",
 			nr_all_pages,
 			(unsigned long long)(nr_all_pages)*PAGE_SIZE,
 			hash_size);
 	}

 	return 0;
}


-- 
Arthur


