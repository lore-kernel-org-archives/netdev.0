From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC, PATCH 2/5]: netfilter+ipsec - output hooks
Date: Fri, 19 Mar 2004 21:59:39 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319105939.GA29066@gondor.apana.org.au>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CEEC.7070009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4059CEEC.7070009@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 18, 2004 at 05:31:40PM +0100, Patrick McHardy wrote:
> This patch adds new output-hooks. Packets with dst->xfrm != NULL
> traverse the POST_ROUTING hook before dst_output is called. The
> transformers mark the packets in the control buffer with a new flag
> IPSKB_XFRM_TRANSFORMED, these packets then traverse the LOCAL_OUT
> hook when they hit ip_output.

Thank you very much for your patches.  This is definitely the biggest
show stopper with the current IPsec stack.

I've just got a minor point about this one:

> @@ -119,12 +119,14 @@
>  /* This is gross, but inline doesn't cut it for avoiding the function
>     call in fast path: gcc doesn't inline (needs value tracking?). --RR */
>  #ifdef CONFIG_NETFILTER_DEBUG
> -#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
> - nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN)
> +#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		\
> +(!(cond)									\
> + ? (okfn)(skb) 								\
> + : nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN))

Any reason why this is written with a negated cond? I get confused by
double negations :)

>  #define NF_HOOK_THRESH nf_hook_slow
>  #else
> -#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
> -(list_empty(&nf_hooks[(pf)][(hook)])					\
> +#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		\
> +(!(cond) || list_empty(&nf_hooks[(pf)][(hook)])				\

Ditto, what about

((cond) && !list_empty(&nf_hooks[(pf)][(hook)) \
 ? nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN) \
 : (okfn)(skb))
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
