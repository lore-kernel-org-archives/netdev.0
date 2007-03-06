From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Mon, 05 Mar 2007 23:23:29 -0800 (PST)
Message-ID: <20070305.232329.95506510.davem@davemloft.net>
References: <20070305.202632.74752497.davem@davemloft.net>
	<45ED14E6.7090109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert.olsson@its.uu.se, npiggin@suse.de
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932739AbXCFHXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 02:23:33 -0500
In-Reply-To: <45ED14E6.7090109@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 06 Mar 2007 08:14:46 +0100

> I wonder... are you sure this has no relation with the size of rt_hash_locks / 
> RT_HASH_LOCK_SZ ?
> One entry must have the same lock in the two tables when resizing is in flight.
> #define MIN_RTHASH_SHIFT LOG2(RT_HASH_LOCK_SZ)

Good point.

> > +static struct rt_hash_bucket *rthash_alloc(unsigned int sz)
> > +{
> > +	struct rt_hash_bucket *n;
> > +
> > +	if (sz <= PAGE_SIZE)
> > +		n = kmalloc(sz, GFP_KERNEL);
> > +	else if (hashdist)
> > +		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
> > +	else
> > +		n = (struct rt_hash_bucket *)
> > +			__get_free_pages(GFP_KERNEL, get_order(sz));
> 
> I dont feel well with this.
> Maybe we could try a __get_free_pages(), and in case of failure, fallback to 
> vmalloc(). Then keep a flag to be able to free memory correctly. Anyway, if 
> (get_order(sz)>=MAX_ORDER) we know __get_free_pages() will fail.

We have to use vmalloc() for the hashdist case so that the pages
are spread out properly on NUMA systems.  That's exactly what the
large system hash allocator is going to do on bootup anyways.

Look, either both are right or both are wrong.  I'm just following
protocol above and you'll note the PRECISE same logic exists in other
dynamically growing hash table implementations such as
net/xfrm/xfrm_hash.c

> Could you add const qualifiers to 'struct rt_hash *' in prototypes where 
> appropriate ?

Sure, no problem.

> Maybe that for small tables (less than PAGE_SIZE/2), we could embed them in 
> 'struct rt_hash'

Not worth the pain nor the in-kernel-image-space it would chew up,
in my opinion.

After you visit a handful of web sites you'll get beyond that
threshold.

> Could we group all static vars at the begining of this file, so that we 
> clearly see where we should place them, to avoid false sharing.

Sure.

> > +
> > +static void rt_hash_resize(unsigned int new_shift)

Damn, please don't quote such huge portions of a patch without any
comments, this has to go out to several thousand recipients you know
:-/
