From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] act_ife: Add support for machines with
 hard_header_len != mac_len
Date: Thu, 22 Sep 2016 18:39:33 -0400
Message-ID: <9850b403-34b2-4a4a-7d50-8e935f3f35a2@mojatatu.com>
References: <1474462453-37668-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Yotam Gigi <yotamg@mellanox.com>, davem@davemloft.net,
        netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36037 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758192AbcIVWjf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 18:39:35 -0400
Received: by mail-it0-f68.google.com with SMTP id n143so5773224ita.3
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 15:39:35 -0700 (PDT)
In-Reply-To: <1474462453-37668-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-21 08:54 AM, Yotam Gigi wrote:
> Without that fix, the following could occur:
>  - On encode ingress, the total amount of skb_pushes (in lines 751 and
>    753) was more than specified in cow.
>  - On machines with hard_header_len > mac_len, the packet format was not

Just curious: What hardware would this be?


> Fixes: ef6980b6becb ("net sched: introduce IFE action")
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> ---
>  net/sched/act_ife.c | 34 +++++++++++++++++++++++++---------
>  1 file changed, 25 insertions(+), 9 deletions(-)
>
> diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
> index e87cd81..27b19ca 100644
> --- a/net/sched/act_ife.c
> +++ b/net/sched/act_ife.c
> @@ -708,11 +708,13 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
>  	   where ORIGDATA = original ethernet header ...
>  	 */
>  	u16 metalen = ife_get_sz(skb, ife);
> -	int hdrm = metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
> -	unsigned int skboff = skb->dev->hard_header_len;
>  	u32 at = G_TC_AT(skb->tc_verd);
> -	int new_len = skb->len + hdrm;
>  	bool exceed_mtu = false;
> +	unsigned int skboff;
> +	int total_push;
> +	int reserve;
> +	int new_len;
> +	int hdrm;
>  	int err;
>
>  	if (at & AT_EGRESS) {
> @@ -724,6 +726,22 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
>  	bstats_update(&ife->tcf_bstats, skb);
>  	tcf_lastuse_update(&ife->tcf_tm);
>
> +	if (at & AT_EGRESS) {
> +		/* on egress, reserve space for hard_header_len instead of
> +		 * mac_len
> +		 */
> +		skb_reset_mac_len(skb);

The skb_reset_mac_len() above is unneeded.

> +		hdrm = metalen + skb->mac_len + IFE_METAHDRLEN;

Can you move this line outside of the if? It appears on the else
so factoring it out is useful.

> +		total_push = hdrm;
> +		reserve = metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
> +	} else {
> +		/* on ingress, push mac_len as it already get parsed from tc */
> +		hdrm = metalen + skb->mac_len + IFE_METAHDRLEN;
> +		total_push = hdrm + skb->mac_len;
> +		reserve = total_push;
> +	}
> +	new_len =  skb->len + hdrm;
> +
>  	if (!metalen) {		/* no metadata to send */
>  		/* abuse overlimits to count when we allow packet
>  		 * with no metadata
> @@ -742,19 +760,17 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
>
>  	iethh = eth_hdr(skb);
>
> -	err = skb_cow_head(skb, hdrm);
> +	err = skb_cow_head(skb, reserve);
>  	if (unlikely(err)) {
>  		ife->tcf_qstats.drops++;
>  		spin_unlock(&ife->tcf_lock);
>  		return TC_ACT_SHOT;
>  	}
>
> -	if (!(at & AT_EGRESS))
> -		skb_push(skb, skb->dev->hard_header_len);
> -
> -	__skb_push(skb, hdrm);
> +	__skb_push(skb, total_push);
>  	memcpy(skb->data, iethh, skb->mac_len);
>  	skb_reset_mac_header(skb);
> +	skboff += skb->mac_len;

Above looks dangerous. Did the compiler not warn?
Maybe init skboff to skb->mac_len at the top.

Otherwise the ingress bits look good. Thanks!

Please fix above and resend with:
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
