From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 1/7] net: Add skb_get_hash_perturb
Date: Wed, 29 Apr 2015 09:59:47 +0200
Message-ID: <20150429075947.GB30392@breakpoint.cc>
References: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
 <1430281661-2271966-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36126 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031044AbbD2H7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 03:59:53 -0400
Content-Disposition: inline
In-Reply-To: <1430281661-2271966-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> This is used to get the skb->hash and then perturb it for a local use.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/linux/skbuff.h | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 66e374d..b706889 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -17,6 +17,7 @@
>  #include <linux/kernel.h>
>  #include <linux/kmemcheck.h>
>  #include <linux/compiler.h>
> +#include <linux/jhash.h>
>  #include <linux/time.h>
>  #include <linux/bug.h>
>  #include <linux/cache.h>
> @@ -927,6 +928,20 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
>  	return skb->hash;
>  }
>  
> +static inline __u32 skb_get_hash_perturb(struct sk_buff *skb,
> +					 u32 perturb)
> +{
> +	u32 hash = skb_get_hash(skb);
> +
> +	if (likely(hash)) {
> +		hash = jhash_1word((__force __u32) hash, perturb);

Whats this perturb for?

perturb is supposed to make sure that if you have

flow1, flow2 where hash(flow1, perturb) == hash(flow2, perturb)
the collision will be temporary and go away once perturb changes.

If you perturb after hashing, such collision is permanent.

So I think this either should flow_dissect + hash in software,
or just use skb_get_hash without perturb.
