From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [PATCH 10/10] chelesio: transmit locking (plus bug fix).
Date: Sun, 3 Dec 2006 11:45:09 +0100
Message-ID: <5cac192f0612030245j434db528sd7bc755408827cf7@mail.gmail.com>
References: <20061202003612.573260000@osdl.org>
	 <20061202003707.873200000@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:35953 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S935736AbWLCKpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 05:45:11 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4063227nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 02:45:09 -0800 (PST)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20061202003707.873200000@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

On 12/2/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> If transmit lock is contended on, then push return code back
> and retry at higher level.

Looking at qdisc_restart, it seems to me that the NETDEV_TX_LOCKED
return code must only be used if the device features LLTX. With your
patch, if q->lock is already grabbed, qdisc_restart is going to
requeue skb without going through the collision section of
qdisc_restart.



>
> Bugfix: If buffer is reallocated because of lack of headroom
> and the send is blocked, then drop packet. This is necessary
> because caller would end up requeuing a freed skb.
>
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
> ---
>  drivers/net/chelsio/sge.c |   19 +++++++++++++++----
>  1 file changed, 15 insertions(+), 4 deletions(-)
>
> --- chelsio.orig/drivers/net/chelsio/sge.c
> +++ chelsio/drivers/net/chelsio/sge.c
> @@ -1778,7 +1778,9 @@ static int t1_sge_tx(struct sk_buff *skb
>         struct cmdQ *q = &sge->cmdQ[qid];
>         unsigned int credits, pidx, genbit, count, use_sched_skb = 0;
>
> -       spin_lock(&q->lock);
> +       if (!spin_trylock(&q->lock))
> +               return NETDEV_TX_LOCKED;
> +
>         reclaim_completed_tx(sge, q);
>
>         pidx = q->pidx;
> @@ -1887,6 +1889,8 @@ int t1_start_xmit(struct sk_buff *skb, s
>         struct sge *sge = adapter->sge;
>         struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port], smp_processor_id());
>         struct cpl_tx_pkt *cpl;
> +       struct sk_buff *orig_skb = skb;
> +       int ret;
>
>         if (skb->protocol == htons(ETH_P_CPL5))
>                 goto send;
> @@ -1930,8 +1934,6 @@ int t1_start_xmit(struct sk_buff *skb, s
>                  * Complain when this happens but try to fix things up.
>                  */
>                 if (unlikely(skb_headroom(skb) < dev->hard_header_len - ETH_HLEN)) {
> -                       struct sk_buff *orig_skb = skb;
> -
>                         pr_debug("%s: headroom %d header_len %d\n", dev->name,
>                                  skb_headroom(skb), dev->hard_header_len);
>
> @@ -1991,7 +1993,16 @@ int t1_start_xmit(struct sk_buff *skb, s
>  send:
>         st->tx_packets++;
>         dev->trans_start = jiffies;
> -       return t1_sge_tx(skb, adapter, 0, dev);
> +       ret = t1_sge_tx(skb, adapter, 0, dev);
> +
> +       /* If transmit busy, and we reallocated skb's due to headroom limit,
> +        * then silently discard to avoid leak.
> +        */
> +       if (unlikely(ret != NETDEV_TX_OK && skb != orig_skb)) {
> +               dev_kfree_skb_any(skb);
> +               ret = NETDEV_TX_OK;
> +       }
> +       return ret;
>  }
>
>  /*
>
> --
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Eric
