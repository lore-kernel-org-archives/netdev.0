From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 11/11] act_police: remove <=mtu check for
 gso skbs
Date: Tue, 12 Feb 2013 08:40:50 -0800
Message-ID: <1360687250.6884.6.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-12-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:38462 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758698Ab3BLQkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 11:40:55 -0500
Received: by mail-da0-f53.google.com with SMTP id w3so99302dad.40
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 08:40:54 -0800 (PST)
In-Reply-To: <1360663929-1023-12-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 11:12 +0100, Jiri Pirko wrote:
> This check made bigger packets incorrectly dropped. Remove this
> limitation for gso skbs.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/sched/act_police.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/act_police.c b/net/sched/act_police.c
> index 823463a..2dba297 100644
> --- a/net/sched/act_police.c
> +++ b/net/sched/act_police.c
> @@ -325,7 +325,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
>  		return police->tcf_action;
>  	}
>  
> -	if (qdisc_pkt_len(skb) <= police->tcfp_mtu) {
> +	if (qdisc_pkt_len(skb) <= police->tcfp_mtu || skb_is_gso(skb)) {
>  		if (!police->rate_present) {
>  			spin_unlock(&police->tcf_lock);
>  			return police->tcfp_result;
> @@ -336,7 +336,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
>  			     police->tcfp_burst);
>  		if (police->peak_present) {
>  			ptoks = toks + police->tcfp_ptoks;
> -			if (ptoks > police->tcfp_mtu_ptoks)
> +			if (ptoks > police->tcfp_mtu_ptoks && !skb_is_gso(skb))
>  				ptoks = police->tcfp_mtu_ptoks;
>  			ptoks -= (s64) psched_l2t_ns(&police->peak,
>  						     qdisc_pkt_len(skb));


Same remark here : This chunks looks wrong to me.
