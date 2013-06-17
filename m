From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/3] netfilter: xt_TCPOPTSTRIP: don't use tcp_hdr()
Date: Mon, 17 Jun 2013 23:30:45 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306172316120.1564@ja.ssi.bg>
References: <1371497679-14314-1-git-send-email-pablo@netfilter.org> <1371497679-14314-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1371497679-14314-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 17 Jun 2013, Pablo Neira Ayuso wrote:

> In (bc6bcb5 netfilter: xt_TCPOPTSTRIP: fix possible mangling beyond
> packet boundary), the use of tcp_hdr was introduced. However, we
> cannot assume that skb->transport_header is set for non-local packets.

	It is hidden also in tcp_hdrlen() which is used here.

> Cc: Florian Westphal <fw@strlen.de>
> Reported-by: Phil Oester <kernel@linuxace.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/netfilter/xt_TCPOPTSTRIP.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTSTRIP.c
> index 1eb1a44..b68fa19 100644
> --- a/net/netfilter/xt_TCPOPTSTRIP.c
> +++ b/net/netfilter/xt_TCPOPTSTRIP.c
> @@ -48,11 +48,13 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
>  		return NF_DROP;
>  
>  	len = skb->len - tcphoff;
> -	if (len < (int)sizeof(struct tcphdr) ||
> -	    tcp_hdr(skb)->doff * 4 > len)
> +	if (len < (int)sizeof(struct tcphdr))
>  		return NF_DROP;
>  
>  	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
> +	if (tcph->doff * 4 > len)

	We can save tcph->doff * 4 in a var and use it
instead of tcp_hdrlen.

	BTW, optlen() touches opt[offset+1] unsafely
when i == tcp_hdrlen(skb) - 1.

> +		return NF_DROP;
> +
>  	opt  = (u_int8_t *)tcph;
>  
>  	/*
> -- 
> 1.7.10.4

Regards

--
Julian Anastasov <ja@ssi.bg>
