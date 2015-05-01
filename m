From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] pktgen: introduce 'rx' mode
Date: Thu, 30 Apr 2015 21:46:50 -0700
Message-ID: <1430455610.3711.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430443127-14408-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34695 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbbEAEqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 00:46:52 -0400
Received: by pacyx8 with SMTP id yx8so80822191pac.1
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 21:46:52 -0700 (PDT)
In-Reply-To: <1430443127-14408-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-30 at 18:18 -0700, Alexei Starovoitov wrote:

> +	if (pkt_dev->flags & F_DO_RX) {
> +		skb = pkt_dev->skb;
> +		local_bh_disable();
> +		atomic_add(burst, &skb->users);

this atomic_add() could be done before local_bh_disable()

> +		do {
> +			ret = netif_receive_skb(skb);
> +			if (ret == NET_RX_DROP)
> +				pkt_dev->errors++;
> +			pkt_dev->sofar++;
> +			pkt_dev->seq_num++;
> +			if (atomic_read(&skb->users) != burst) {
> +				/* skb was queued by rps/rfs or taps,
> +				 * so cannot reuse this skb
> +				 */
> +				atomic_sub(burst - 1, &skb->users);
> +				/* get out of the loop and wait
> +				 * until skb is consumed
> +				 */
> +				pkt_dev->last_ok = 1;
> +				pkt_dev->clone_skb = 0;
> +				break;

after a break; you don't need the 'else', and therefore can save one
tab/ indent level.

> +			} else {
> +				/* skb was 'freed' by stack, so clean few
> +				 * bits and reuse it
> +				 */
> +				skb->tc_verd = 0; /* reset reclass/redir ttl */

tc_verd needs CONFIG_NET_CLS_ACT

> +			}
> +		} while (--burst > 0);
> +		local_bh_enable();
> +		goto out;
> +	}
> +
>  	txq = skb_get_tx_queue(odev, pkt_dev->skb);
>  
>  	local_bh_disable();
> @@ -3403,6 +3447,7 @@ unlock:
>  

You could put the out: label here, and remove one local_bh_enable()
before "goto out;"

>  	local_bh_enable();
>  
> +out:
>  	/* If pkt_dev->count is zero, then run forever */
>  	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
>  		pktgen_wait_for_skb(pkt_dev);
