From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] profile: Suppress warning about large allocations when
	profile=1 is specified
Date: Mon, 22 Jun 2009 14:00:15 -0300
Message-ID: <20090622170015.GC18558@ghostprotocols.net>
References: <200906162232.n5GMWRZe026963@imap1.linux-foundation.org> <20090616223649.719ea378.akpm@linux-foundation.org> <20090617111800.GA15261@elte.hu> <20090617113120.GA5061@elte.hu> <20090617113534.GA21276@elte.hu> <20090617121913.GC28529@csn.ul.ie> <20090620100932.GA5863@fancy-poultry.org> <20090620195000.GC10878@csn.ul.ie> <20090620214835.GA6528@fancy-poultry.org> <20090622113104.GD3981@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Heinz Diehl <htd@fancy-poultry.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	torvalds@linux-foundation.org, fengguang.wu@intel.com,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	DCCP Mailing List <dccp@vger.kernel.org>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: Mel Gorman <mel@csn.ul.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58008 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbZFVU1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2009 16:27:16 -0400
Content-Disposition: inline
In-Reply-To: <20090622113104.GD3981@csn.ul.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Jun 22, 2009 at 12:31:05PM +0100, Mel Gorman escreveu:
> On Sat, Jun 20, 2009 at 11:48:35PM +0200, Heinz Diehl wrote:
> > On 20.06.2009, Mel Gorman wrote: 
> > 
> > > I can't figure out from this trace where the problem is coming from. Can
> > > you post your .config and the full dmesg please?
> > 
> > Yes, of course. It's attached.
> > 
> 
> I have no idea why the stack trace is so badly managed but the problem appears
> to be in DCCP so can you try the patch below please? It applies on top of the
> profile=1 patch fix. If it works for you, I'll split out the patch properly
> into three separate patches and repost.
> 
> Some questions though
> 
> 1. Could DCCP use alloc_large_system_hash()?

Possibly. Ideally this should use whatever TCP is using now, as this
came more or less intact from there. IIRC it was not shared because TCP
used/uses alloc routines that were available only at boot time, DCCP
can't use it because it can be loaded as a module.

I'd say go with this patch and later, after FISL (this week) I'll look
at this again.

So, for the NOWARN bits:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Thanks,

- Arnaldo
 
> 2. Any idea why the stack trace for the warning was so useless?
> 
> ==== CUT HERE ====
> dccp: Suppress warning about large allocations from DCCP
> 
> The DCCP protocol tries to allocate some large hash tables during
> initialisation using the largest size possible. The allocator warns if
> the allocations are too large but the caller is able to handle
> allocation failure. This patch disables the warnings in the case DCCP
> requests too large an allocation.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  net/dccp/proto.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
> index 314a1b5..fd21676 100644
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -1066,7 +1066,7 @@ static int __init dccp_init(void)
>  		       (dccp_hashinfo.ehash_size - 1))
>  			dccp_hashinfo.ehash_size--;
>  		dccp_hashinfo.ehash = (struct inet_ehash_bucket *)
> -			__get_free_pages(GFP_ATOMIC, ehash_order);
> +			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, ehash_order);
>  	} while (!dccp_hashinfo.ehash && --ehash_order > 0);
>  
>  	if (!dccp_hashinfo.ehash) {
> @@ -1091,7 +1091,7 @@ static int __init dccp_init(void)
>  		    bhash_order > 0)
>  			continue;
>  		dccp_hashinfo.bhash = (struct inet_bind_hashbucket *)
> -			__get_free_pages(GFP_ATOMIC, bhash_order);
> +			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, bhash_order);
>  	} while (!dccp_hashinfo.bhash && --bhash_order >= 0);
>  
>  	if (!dccp_hashinfo.bhash) {
