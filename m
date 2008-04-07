From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] fib_trie: memory waste solutions
Date: Mon, 07 Apr 2008 18:46:29 +0200
Message-ID: <47FA4FE5.5010500@cosmosbay.com>
References: <20080401172702.094c0700@extreme>	<47F33D42.9080302@cosmosbay.com>	<47F39998.8040605@cosmosbay.com>	<20080402110335.66b04181@extreme>	<47F3E031.1030806@cosmosbay.com> <20080404090257.2ec38b0c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:63029 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbYDGQqr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 12:46:47 -0400
In-Reply-To: <20080404090257.2ec38b0c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Eric wisely pointed out that for larger sizes of nodes, the
> current allocation in fib_trie wastes lots of memory.  For a sample
> of routes extracted from the bugzilla bug the largest node grows
> to 2M bytes on 64 bit system. This leads to 2044K of wasted memory.
>
> There are two possible solutions (see attached). One uses vmalloc()
> rather than alloc_pages, but has to add complexity on freeing.
> The other adds a layer of indirection to the tnode lookup.
>
> Both have been tested on net-2.6.26 with the huge route table.
> I slightly prefer the vmalloc version, but both work fine.
>
>  =20
> ---------------------------------------------------------------------=
---
>
> IPV4: fib_trie use vmalloc for large tnodes
>
> Use vmalloc rather than alloc_pages to avoid wasting memory.
> The problem is that tnode structure has a power of 2 sized array,
> plus a header. So the current code wastes almost half the memory
> allocated because it always needs the next bigger size to hold
> that small header.
>
> This is similar to an earlier patch by Eric, but instead of a list
> and lock, I used a workqueue to handle the fact that vfree can't
> be done in interrupt context.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
>  net/ipv4/fib_trie.c |   25 +++++++++++++++----------
>  1 file changed, 15 insertions(+), 10 deletions(-)
>
> --- a/net/ipv4/fib_trie.c	2008-04-04 08:57:01.000000000 -0700
> +++ b/net/ipv4/fib_trie.c	2008-04-04 08:57:03.000000000 -0700
> @@ -122,7 +122,10 @@ struct tnode {
>  	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
>  	unsigned int full_children;	/* KEYLENGTH bits needed */
>  	unsigned int empty_children;	/* KEYLENGTH bits needed */
> -	struct rcu_head rcu;
> +	union {
> +		struct rcu_head rcu;
> +		struct work_struct work;
> +	};
>  	struct node *child[0];
>  =20
Hum...

I prefer my patch Stephen, as your version enlarges every tnode with an=
=20
embedded "struct work_struct" which can be larger than a "struct rcu_he=
ad"

And as your 2nd patch doesnt use vmalloc() at all, we only can gain one=
=20
order for the max bits in root node (19 instead of 18) :
We will hit the 'bug' again in a couple of months, or if router memory=20
is somehow fragmented.





