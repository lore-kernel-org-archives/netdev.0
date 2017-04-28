From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v6 3/5] rxrpc: check return value of skb_to_sgvec always
Date: Fri, 28 Apr 2017 13:41:31 +0200
Message-ID: <20170428114131.GA31833@bistromath.localdomain>
References: <20170425155215.4835-1-Jason@zx2c4.com>
 <20170425184734.26563-1-Jason@zx2c4.com>
 <20170425184734.26563-3-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David.Laight@aculab.com, kernel-hardening@lists.openwall.com,
	davem@davemloft.net
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-7618-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <20170425184734.26563-3-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

2017-04-25, 20:47:32 +0200, Jason A. Donenfeld wrote:
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> ---
>  net/rxrpc/rxkad.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
> index 4374e7b9c7bf..dcf46c9c3ece 100644
> --- a/net/rxrpc/rxkad.c
> +++ b/net/rxrpc/rxkad.c
[...]
> @@ -429,7 +432,8 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
>  	}
>  

Adding a few more lines of context:

	sg = _sg;
	if (unlikely(nsg > 4)) {
		sg = kmalloc(sizeof(*sg) * nsg, GFP_NOIO);
		if (!sg)
			goto nomem;
	}

>  	sg_init_table(sg, nsg);
> -	skb_to_sgvec(skb, sg, offset, len);
> +	if (unlikely(skb_to_sgvec(skb, sg, offset, len) < 0))
> +		goto nomem;

You're leaking sg when nsg > 4, you'll need to add this:

	if (sg != _sg)
		kfree(sg);



BTW, when you resubmit, please Cc: the maintainers of the files you're
changing for each patch, so that they can review this stuff. And send
patch 1 to all of them, otherwise they might be surprised that we even
need <0 checking after calls to skb_to_sgvec.

You might also want to add a cover letter.

-- 
Sabrina
