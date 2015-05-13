From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: core: set and refine qdisc pkt len
 before tc_classify
Date: Wed, 13 May 2015 14:20:55 -0700
Message-ID: <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, fw@strlen.de, ast@plumgrid.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:35442 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933957AbbEMVU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:20:57 -0400
Received: by iebpz10 with SMTP id pz10so44415184ieb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 14:20:56 -0700 (PDT)
In-Reply-To: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 22:50 +0200, Daniel Borkmann wrote:
> From: Florian Westphal <fw@strlen.de>
> 
> Commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
> removed the call to qdisc_enqueue_root(). However, after this removal
> we no longer set qdisc pkt length, which this patch fixes. We make use
> of qdisc_pkt_len_init() from 1def9238d4aa ("net_sched: more precise
> pkt_len computation"), which was suggested as the current approach so
> far does not take into account when GRO builds up GSO packets.
> 
> Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  v1->v2:
>   - use qdisc_pkt_len_init() as suggested, thanks!
> 
>  net/core/dev.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 15e51a9..6e19521 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2787,8 +2787,8 @@ static void qdisc_pkt_len_init(struct sk_buff *skb)
>  
>  	qdisc_skb_cb(skb)->pkt_len = skb->len;
>  
> -	/* To get more precise estimation of bytes sent on wire,
> -	 * we add to pkt_len the headers size of all segments
> +	/* To get more precise estimation of bytes sent/received on
> +	 * wire, we add to pkt_len the headers size of all segments.
>  	 */
>  	if (shinfo->gso_size)  {
>  		unsigned int hdr_len;
> @@ -3541,9 +3541,11 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
>  		*pt_prev = NULL;
>  	}
>  
> -	qdisc_bstats_update_cpu(cl->q, skb);
> +	qdisc_pkt_len_init(skb);
>  	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
>  
> +	qdisc_bstats_update_cpu(cl->q, skb);
> +
>  	switch (tc_classify(skb, cl, &cl_res)) {
>  	case TC_ACT_OK:
>  	case TC_ACT_RECLASSIFY:

Is qdisc_pkt_len_init() still inlined, now it has 2 callers ?

People using policers on ingress are very often disabling GRO for
various historical reasons.

Since handle_ing() is very uncommon, I would prefer not slowing down tx
just so that GRO ~5% error in ingress is fixed.

I noticed you did not CC me, don't be afraid to include me next time one
of my commit is referred in a changelog ;)
