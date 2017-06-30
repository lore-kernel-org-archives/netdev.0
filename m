From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: convert three more cases to kvmalloc
Date: Fri, 30 Jun 2017 09:21:43 +0200
Message-ID: <20170630072142.GA19931@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1706282317480.11892@file01.intranet.prod.int.rdu2.redhat.com>
 <20170629071046.GA31603@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706292205110.21823@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Vlastimil Babka <vbabka@suse.cz>,
	Andreas Dilger <adilger@dilger.ca>,
	John Hubbard <jhubbard@nvidia.com>,
	David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1706292205110.21823@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu 29-06-17 22:13:26, Mikulas Patocka wrote:
> 
> 
> On Thu, 29 Jun 2017, Michal Hocko wrote:
[...]
> > > Index: linux-2.6/kernel/bpf/syscall.c
> > > ===================================================================
> > > --- linux-2.6.orig/kernel/bpf/syscall.c
> > > +++ linux-2.6/kernel/bpf/syscall.c
> > > @@ -58,16 +58,7 @@ void *bpf_map_area_alloc(size_t size)
> > >  	 * trigger under memory pressure as we really just want to
> > >  	 * fail instead.
> > >  	 */
> > > -	const gfp_t flags = __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO;
> > > -	void *area;
> > > -
> > > -	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> > > -		area = kmalloc(size, GFP_USER | flags);
> > > -		if (area != NULL)
> > > -			return area;
> > > -	}
> > > -
> > > -	return __vmalloc(size, GFP_KERNEL | flags, PAGE_KERNEL);
> > > +	return kvmalloc(size, GFP_USER | __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO);
> > 
> > kvzalloc without additional flags would be more appropriate.
> > __GFP_NORETRY is explicitly documented as non-supported
> 
> How is __GFP_NORETRY non-supported?

Because its semantic cannot be guaranteed throughout the alloaction
stack. vmalloc will ignore it e.g. for page table allocations.

> > and NOWARN wouldn't be applied everywhere in the vmalloc path.
> 
> __GFP_NORETRY and __GFP_NOWARN wouldn't be applied in the page-table 
> allocation and they would be applied in the page allocation - that seems 
> acceptable.

This is rather muddy semantic to me. Both page table and the page is an
order-0 allocation. Page table allocations are much less likely but I've
explicitly documented that explicit __GFP_NORETRY is unsupported. Slab
allocation is already __GFP_NORETRY (unless you specify
__GFP_RETRY_MAYFAIL in the current mmotm tree).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
