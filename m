From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Tue, 15 Oct 2013 10:33:48 +0200
Message-ID: <20131015083348.GW7660@secunet.com>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36025 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987Ab3JOIdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 04:33:51 -0400
Content-Disposition: inline
In-Reply-To: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 14, 2013 at 06:03:34PM +0200, Michal Kubecek wrote:
> In ipcomp_compress(), sortirq is enabled too early, allowing the
> per-cpu scratch buffer to be rewritten by ipcomp_decompress()
> (called on the same CPU in softirq context) between populating
> the buffer and copying the compressed data to the skb.
> 
> Add similar protection into ipcomp_decompress() as it can be
> called from process context as well (even if such scenario seems
> a bit artificial).
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  net/xfrm/xfrm_ipcomp.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
> index 2906d52..96946fb 100644
> --- a/net/xfrm/xfrm_ipcomp.c
> +++ b/net/xfrm/xfrm_ipcomp.c
> @@ -48,9 +48,11 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
>  	const int cpu = get_cpu();
>  	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
>  	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
> -	int err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
> +	int err;
>  	int len;
>  
> +	local_bh_disable();

Maybe we could disable the BHs before we fetch the percpu pointers.
Then we can use smp_processor_id() to get the cpu. With that we
could get rid of a (now useless) preempt_disable()/preempt_enable()
pair. Same could be done in ipcomp_compress().

Looks ok otherwise. Thanks!
