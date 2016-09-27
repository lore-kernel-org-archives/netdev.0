From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 4/4] net/sched: act_mirred: Implement
 ingress actions
Date: Tue, 27 Sep 2016 14:27:13 -0700
Message-ID: <1475011633.28155.68.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1475009975-30332-1-git-send-email-shmulik.ladkani@gmail.com>
         <1475009975-30332-5-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34988 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752336AbcI0V1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 17:27:15 -0400
Received: by mail-pf0-f194.google.com with SMTP id 6so1207658pfl.2
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 14:27:15 -0700 (PDT)
In-Reply-To: <1475009975-30332-5-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-27 at 23:59 +0300, Shmulik Ladkani wrote:
> Up until now, 'action mirred' supported only egress actions (either
> TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).
> 
> This patch implements the corresponding ingress actions
> TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.


> -		if (m->tcfm_mac_header_xmit)
> +	/* If action's target direction differs than filter's direction,
> +	 * and devices expect a mac header on xmit, then mac push/pull is
> +	 * needed.
> +	 */
> +	if (at != tcf_mirred_act_direction(m->tcfm_eaction) &&

Note that m->tcfm_eaction is read here.

> +	    m->tcfm_mac_header_xmit) {
> +		if (at & AT_EGRESS) {
> +			/* caught at egress, act ingress: pull mac */
> +			mac_len = skb_network_header(skb) - skb_mac_header(skb);
> +			skb_pull_rcsum(skb2, mac_len);
> +		} else {
> +			/* caught at ingress, act egress: push mac */
>  			skb_push_rcsum(skb2, skb->mac_len);
> +		}
>  	}
>  
>  	/* mirror is always swallowed */
> -	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
> +	if (tcf_mirred_is_act_redirect(m->tcfm_eaction))
>  		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
>  
>  	skb2->skb_iif = skb->dev->ifindex;
>  	skb2->dev = dev;
> -	err = dev_queue_xmit(skb2);

Note that m->tcfm_eaction is read another time here.

> +	if (tcf_mirred_act_direction(m->tcfm_eaction) & AT_EGRESS)
> +		err = dev_queue_xmit(skb2);
> +	else
> +		netif_receive_skb(skb2);
>  

Since this runs lockless, another cpu might change m->tcfm_eaction in
the middle, and you could call dev_queue_xmit(skb2) while the skb2 was
prepared for the opposite action.

I guess some drivers could crash, because they expect to find a MAC
header.

If not, a comment would be nice.

Thanks.
