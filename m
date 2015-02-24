From: Patrick McHardy <kaber@trash.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 10:42:33 +0000
Message-ID: <20150224104232.GK3713@acer.localdomain>
References: <20150223184904.GA24955@linux.vnet.ibm.com>
 <20150224085909.GC17306@casper.infradead.org>
 <54EC46AB.3030302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, alexei.starovoitov@gmail.com,
	herbert@gondor.apana.org.au, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	josh@joshtriplett.org, johunt@akamai.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43465 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbBXKmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 05:42:38 -0500
Content-Disposition: inline
In-Reply-To: <54EC46AB.3030302@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.02, Daniel Borkmann wrote:
> On 02/24/2015 09:59 AM, Thomas Graf wrote:
> >On 02/23/15 at 10:49am, Paul E. McKenney wrote:
> >>Hello!
> >>
> >>Alexei mentioned that there was some excitement a couple of weeks ago in
> >>Ottawa, something about the resizing taking forever when there were large
> >>numbers of concurrent additions.  One approach comes to mind:
> >
> >@Dave et al,
> >Just want to make sure we have the same level of understanding of
> >urgency for this. The only practical problem experienced so far is
> >loading n*1M entries into an nft_hash set which takes 3s for 4M
> >entries upon restore. A regular add is actually fine as it provides
> >a hint and sizes the table accordingly.
> 
> Btw, there is one remaining bug in nft that Josh Hunt found which
> should go into 3.20/4.0, it's not in -net tree, so it could have
> affected testing with nft. We're currently missing max_shift
> parameter in nft's rhashtable initialization.
> 
> This means that there will be _no_ expansions as rht_grow_above_75()
> will end up always returning false. It's not that dramatic when you
> have a proper hint provided, but when you start out small
> (NFT_HASH_ELEMENT_HINT = 3) and try to squeeze 1M entries into it,
> it might take a while.
> 
> Simplest fix would be, similarly as in other users:
> 
> diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
> index 61e6c40..47abdca 100644
> --- a/net/netfilter/nft_hash.c
> +++ b/net/netfilter/nft_hash.c
> @@ -192,6 +192,7 @@ static int nft_hash_init(const struct nft_set *set,
>  		.key_offset = offsetof(struct nft_hash_elem, key),
>  		.key_len = set->klen,
>  		.hashfn = jhash,
> +		.max_shift = 20, /* 1M */
>  		.grow_decision = rht_grow_above_75,
>  		.shrink_decision = rht_shrink_below_30,
>  	};
> 
> But I presume Josh wanted to resend his code ... or wait for nft
> folks to further review?

We're perfectly fine with that patch, although I'd say lets use a
slightly larger value (24) to cover what we know people are doing
using ipset.
