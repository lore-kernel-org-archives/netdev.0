From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: SNAT --random & fully is not actually random for ips
Date: Mon, 28 Nov 2016 12:29:55 +0100
Message-ID: <20161128112955.GA1691@salvia>
References: <97a6a1c557f0f1e6d55d8d09b326f8b1@nuclearcat.com>
 <20161128110651.GA1024@salvia>
 <fb3151804cc3b2c57e69d1059b3417ee@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <fb3151804cc3b2c57e69d1059b3417ee@nuclearcat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 01:12:07PM +0200, Denys Fedoryshchenko wrote:
> On 2016-11-28 13:06, Pablo Neira Ayuso wrote:
> >Why does your patch reverts NF_NAT_RANGE_PROTO_RANDOM_FULLY?
>
> Ops, sorry i just did mistake with files, actually it is in reverse ( did
> this patch, and it worked properly with it, with random source ip).

Oh, I see 8)

> --- nf_nat_core.c	2016-11-21 09:11:59.000000000 +0000
> +++ nf_nat_core.c.new	2016-11-28 09:55:54.000000000 +0000
> @@ -282,9 +282,13 @@
>  	 * client coming from the same IP (some Internet Banking sites
>  	 * like this), even across reboots.
>  	 */
> -	j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / sizeof(u32),
> +	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY) {
> +	    j = prandom_u32();
> +	} else {
> +	    j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / sizeof(u32),
>  		   range->flags & NF_NAT_RANGE_PERSISTENT ?
>  			0 : (__force u32)tuple->dst.u3.all[max] ^ zone->id);
> +	}
> 
>  	full_range = false;
>  	for (i = 0; i <= max; i++) {
> 
> This is current situation, RANDOM_FULLY actually does prandom_u32 for source
> port only, but not for IP.
> IP kept as persistent and kind of predictable, because hash function based
> on source ip.
> 
> Sure i did tried to specify any combination of flags, but looking to
> "find_best_ips_proto" function, it wont have any effect.

IIRC the original intention on random-fully was to cover only ports.
Did you interpret from git history otherwise? Otherwise, safe
procedure is to add a new flag.
