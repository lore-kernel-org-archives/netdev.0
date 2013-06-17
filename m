From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 3/3] netfilter: xt_TCPMSS: Fix missing fragmentation
 handling
Date: Tue, 18 Jun 2013 00:03:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306172349470.1564@ja.ssi.bg>
References: <1371497679-14314-1-git-send-email-pablo@netfilter.org> <1371497679-14314-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1371497679-14314-4-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 17 Jun 2013, Pablo Neira Ayuso wrote:

> From: Phil Oester <kernel@linuxace.com>
> 
> Similar to commit bc6bcb59 ("netfilter: xt_TCPOPTSTRIP: fix
> possible mangling beyond packet boundary"), add safe fragment
> handling to xt_TCPMSS.
> 
> Signed-off-by: Phil Oester <kernel@linuxace.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/netfilter/xt_TCPMSS.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
> index 6640a22..7011c71 100644
> --- a/net/netfilter/xt_TCPMSS.c
> +++ b/net/netfilter/xt_TCPMSS.c
> @@ -57,6 +57,10 @@ tcpmss_mangle_packet(struct sk_buff *skb,
>  	u16 newmss;
>  	u8 *opt;
>  
> +	/* This is a fragment, no TCP header is available */
> +	if (par->fragoff != 0)
> +		return XT_CONTINUE;
> +
>  	if (!skb_make_writable(skb, skb->len))
>  		return -1;

	This function needs the same check:

	...

+	if (tcplen < (int)sizeof(struct tcphdr))
+		return -1;
+
	/* Header cannot be larger than the packet */
	if (tcplen < tcph->doff*4)
		return -1;

	but 'tcplen' should be changed to 'int' for
this to work.

	Here we have the same optlen() problem but
I guess in both patches we always have something allocated
after the last byte in header (struct skb_shared_inf),
so crash is not possible.

Regards

--
Julian Anastasov <ja@ssi.bg>
