From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.6 PATCH] ipvs - properly handle non-linear skbs
Date: Mon, 6 Oct 2003 13:23:16 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310061225190.2558-100000@l>
References: <20031006000225.AF7642C0A7@lists.samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, Wensong Zhang <wensong@linux-vs.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20031006000225.AF7642C0A7@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 6 Oct 2003, Rusty Russell wrote:

> 	I diffed our two patches.  Is see you still use iph temp vars:
> fair enough: I removed mine after some subtle bugs (although it does
> make the code a bit uglier).
>
> Looks really good.  Could you just clarify a couple of things for me please?
>
> @@ -527,10 +528,7 @@ struct ip_vs_conn {
>  	struct ip_vs_dest       *dest;          /* real server */
>  	atomic_t                in_pkts;        /* incoming packet counter */
>
> -	/* packet transmitter for different forwarding methods.  If it
> -	   mangles the packet, it must return NF_DROP or NF_STOLEN, otherwise
> -	   this must be changed to a sk_buff **.
> -	 */
> +	/* packet transmitter for different forwarding methods */
>  	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
>  			   struct ip_vs_protocol *pp);
>
> This comment is still true: the skb pointer from the caller is
> useless, so xmit *must* return NF_DROP or NF_STOLEN.  I thought about
> making it return void and the callers always return NF_STOLEN, but
> there was enough change already.  You might want to put a comment in
> there.

	My merging mistake, your comment is valid. In this way is
better, sometimes we want to return NF_STOLEN, sometimes NF_DROP.
But it is true that it can be only NF_STOLEN. I made some changes
to return NF_DROP if possible, may be someone wants to log later
these packets as dropped ones.

> ip_vs_make_skb_writable(): how is this different from
> skb_ip_make_writable(), except you have to maintain it yourself?  The
> advantage of the general one is that Dave looks after it for us 8)

	The main difference is that we should not call skb_copy
for cloned skbs, this is a waste of CPU for allocating new skb.
May be you will change skb_ip_make_writable :)

> In ip_vs_out_icmp():
>
>  	/* Is the embedded protocol header present? */
>  	if (unlikely(ciph.frag_off & __constant_htons(IP_OFFSET) &&
> -		     /* FIXME: Remove minhlen, and surely dont_defrag
> -		      * test is backwards? --RR */
>  		     (pp->minhlen || pp->dont_defrag)))
>  		return NF_ACCEPT;
>
> If the protocol says "don't defrag" they never see fragmented packets.

	The semantic is: Do not defrag for me, I do not care for my
protocol header, you can give me fragmented skbs. This is true for now
for AH and ESP because we treat these protocols like slave ones, i.e.
UDP 500->500 is a master connection and we forward AH/ESP according
to the main connection ignoring any protocol headers and payloads.
But I'm not sure how that will change in the feature.

> AFAICT, minhlen and dont_defrag are now the same everywhere (minhlen
> is not respected: protocols are expected to catch skb_copy_bits
> failing on their own, and they do).  Perhaps drop minhlen altogether,
> and just keep dont_defrag?

	Yes, I forgot it. We have to remove minhlen and minhlen_icmp.
It must be: && pp->dont_defrag

> Hey, thanks for doing the hard work for me!

	np, tonight I'll cleanup these things and may be other
missed ones.

> Cheers,
> Rusty.
> --
>   Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

Regards

--
Julian Anastasov <ja@ssi.bg>
