From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH] netfilter6: Skip extension headers when matching
 icmp6-type
Date: Thu, 30 Sep 2004 21:39:09 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409301239.i8UCdACm005816@toshiba.co.jp>
References: <20040930121620.GH19083@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: okir@suse.de
In-Reply-To: <20040930121620.GH19083@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thanks. and maybe current kernel has same problem in ip6t_multiport.c, too.
But I already sent a patch which fixes this problem to this ml.

See

https://lists.netfilter.org/pipermail/netfilter-devel/2004-September/016783.html

and 

https://lists.netfilter.org/pipermail/netfilter-devel/2004-September/016851.html

Regards,

-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>


From: Olaf Kirch <okir@suse.de>
Date: Thu, 30 Sep 2004 14:16:20 +0200

> 
> This patch fixes a bug in the ip6_tables code when matching ICMP type and
> code within ICMPv6 packets. The icmpv6 packet matcher expects the nexthdr
> to be ICMPv6 and does not deal with hop-by-hop headers etc.
> 
> Signed-off-by: Olaf Kirch <okir@suse.de>
> 
> Index: linux-2.6.8.nf/net/ipv6/netfilter/ip6_tables.c
> ===================================================================
> --- linux-2.6.8.nf.orig/net/ipv6/netfilter/ip6_tables.c	2004-08-26 13:22:35.000000000 +0200
> +++ linux-2.6.8.nf/net/ipv6/netfilter/ip6_tables.c	2004-09-30 14:07:51.000000000 +0200
> @@ -1751,10 +1751,23 @@
>  	   u_int16_t datalen,
>  	   int *hotdrop)
>  {
> -	const struct icmp6hdr *icmp = hdr;
> +	struct icmp6hdr icmph;
>  	const struct ip6t_icmp *icmpinfo = matchinfo;
> +	int hdroff;
> +	u8 nexthdr = skb->nh.ipv6h->nexthdr;
>  
> -	if (offset == 0 && datalen < 2) {
> +	/* Must not be a fragment. */
> +	if (offset)
> +		return 0;
> +
> +	hdroff = (u8*)(skb->nh.ipv6h+1) - skb->data;
> +	hdroff = ipv6_skip_exthdr(skb, hdroff, &nexthdr, skb->len - hdroff);
> +	if (hdroff < 0 || hdroff > skb->len || nexthdr != IPPROTO_ICMPV6) {
> +		*hotdrop = 1;
> +		return 0;
> +	}
> +
> +	if (skb_copy_bits(skb, hdroff, &icmph, sizeof(icmph)) < 0) {
>  		/* We've been asked to examine this packet, and we
>  		   can't.  Hence, no choice but to drop. */
>  		duprintf("Dropping evil ICMP tinygram.\n");
> @@ -1763,11 +1776,10 @@
>  	}
>  
>  	/* Must not be a fragment. */
> -	return !offset
> -		&& icmp6_type_code_match(icmpinfo->type,
> +	return icmp6_type_code_match(icmpinfo->type,
>  					icmpinfo->code[0],
>  					icmpinfo->code[1],
> -					icmp->icmp6_type, icmp->icmp6_code,
> +					icmph.icmp6_type, icmph.icmp6_code,
>  					!!(icmpinfo->invflags&IP6T_ICMP_INV));
>  }
>  
> -- 
> Olaf Kirch     | Things that make Monday morning interesting, #1:
> okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
> ---------------+ 
> 
> 
