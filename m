From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipsec v2] xfrm: prevent ipcomp scratch buffer race
 condition
Date: Tue, 15 Oct 2013 15:44:29 -0700
Message-ID: <1381877069.2045.75.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131015083348.GW7660@secunet.com>
	 <20131015214030.B0D06E8A60@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:40329 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933522Ab3JOWob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 18:44:31 -0400
Received: by mail-pa0-f42.google.com with SMTP id kx10so90394pab.15
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 15:44:30 -0700 (PDT)
In-Reply-To: <20131015214030.B0D06E8A60@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-15 at 23:40 +0200, Michal Kubecek wrote:
> In ipcomp_compress(), sortirq is enabled too early, allowing the
> per-cpu scratch buffer to be rewritten by ipcomp_decompress()
> (called on the same CPU in softirq context) between populating
> the buffer and copying the compressed data to the skb.
> 
> Add similar protection into ipcomp_decompress() as it can be
> called from process context as well (even if such scenario seems
> a bit artificial).
> 
> v2: as pointed out by Steffen Klassert, if we also move the
> local_bh_disable() before reading the per-cpu pointers, we can
> get rid of get_cpu()/put_cpu().
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  net/xfrm/xfrm_ipcomp.c | 29 ++++++++++++++++++-----------
>  1 file changed, 18 insertions(+), 11 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
> index 2906d52..9fe4f42 100644
> --- a/net/xfrm/xfrm_ipcomp.c
> +++ b/net/xfrm/xfrm_ipcomp.c
> @@ -45,12 +45,17 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
>  	const int plen = skb->len;
>  	int dlen = IPCOMP_SCRATCH_SIZE;
>  	const u8 *start = skb->data;
> -	const int cpu = get_cpu();
> -	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
> -	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
> -	int err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
> +	struct crypto_comp *tfm;
> +	u8 *scratch;
> +	int cpu;
> +	int err;
>  	int len;
>  
> +	local_bh_disable();
> +	cpu = smp_processor_id();
> +	scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
> +	tfm = *per_cpu_ptr(ipcd->tfms, cpu);

Have you tried this_cpu_ptr() instead ?
