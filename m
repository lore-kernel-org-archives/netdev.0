From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 2/2] tun: Add support for RFS on tun flows
Date: Thu, 02 Jan 2014 12:44:32 +0800
Message-ID: <52C4EEB0.8020408@redhat.com>
References: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com> <1387709672-21917-3-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbaABEoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 23:44:55 -0500
In-Reply-To: <1387709672-21917-3-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2013 06:54 PM, Zhi Yong Wu wrote:
> From: Tom Herbert <therbert@google.com>
>
> This patch adds support so that the rps_flow_tables (RFS) can be
> programmed using the tun flows which are already set up to track flows
> for the purposes of queue selection.
>
> On the receive path (corresponding to select_queue and tun_net_xmit) the
> rxhash is saved in the flow_entry.  The original code only does flow
> lookup in select_queue, so this patch adds a flow lookup in tun_net_xmit
> if num_queues == 1 (select_queue is not called from
> dev_queue_xmit->netdev_pick_tx in that case).
>
> The flow is recorded (processing CPU) in tun_flow_update (TX path), and
> reset when flow is deleted.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  drivers/net/tun.c |   37 +++++++++++++++++++++++++++++++++++--
>  1 files changed, 35 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index a17a701..3cf0457 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -152,6 +152,7 @@ struct tun_flow_entry {
>  	struct tun_struct *tun;
>  
>  	u32 rxhash;
> +	u32 rps_rxhash;
>  	int queue_index;
>  	unsigned long updated;
>  };
> @@ -220,6 +221,7 @@ static struct tun_flow_entry *tun_flow_create(struct tun_struct *tun,
>  			  rxhash, queue_index);
>  		e->updated = jiffies;
>  		e->rxhash = rxhash;
> +		e->rps_rxhash = 0;
>  		e->queue_index = queue_index;
>  		e->tun = tun;
>  		hlist_add_head_rcu(&e->hash_link, head);
> @@ -232,6 +234,7 @@ static void tun_flow_delete(struct tun_struct *tun, struct tun_flow_entry *e)
>  {
>  	tun_debug(KERN_INFO, tun, "delete flow: hash %u index %u\n",
>  		  e->rxhash, e->queue_index);
> +	sock_rps_reset_flow_hash(e->rps_rxhash);
>  	hlist_del_rcu(&e->hash_link);
>  	kfree_rcu(e, rcu);
>  	--tun->flow_count;
> @@ -325,6 +328,7 @@ static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
>  		/* TODO: keep queueing to old queue until it's empty? */
>  		e->queue_index = queue_index;
>  		e->updated = jiffies;
> +		sock_rps_record_flow_hash(e->rps_rxhash);
>  	} else {
>  		spin_lock_bh(&tun->lock);
>  		if (!tun_flow_find(head, rxhash) &&
> @@ -341,6 +345,18 @@ unlock:
>  	rcu_read_unlock();
>  }
>  
> +/**
> + * Save the hash received in the stack receive path and update the
> + * flow_hash table accordingly.
> + */
> +static inline void tun_flow_save_rps_rxhash(struct tun_flow_entry *e, u32 hash)
> +{
> +	if (unlikely(e->rps_rxhash != hash)) {
> +		sock_rps_reset_flow_hash(e->rps_rxhash);
> +		e->rps_rxhash = hash;
> +	}
> +}
> +
>  /* We try to identify a flow through its rxhash first. The reason that
>   * we do not check rxq no. is because some cards(e.g 82599), chooses
>   * the rxq based on the txq where the last packet of the flow comes. As
> @@ -361,9 +377,10 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>  	txq = skb_get_hash(skb);
>  	if (txq) {
>  		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
> -		if (e)
> +		if (e) {
>  			txq = e->queue_index;
> -		else
> +			tun_flow_save_rps_rxhash(e, txq);
> +		} else

This looks wrong, txq is the queue index here. We should do this before
txq = e->queue_index.

Did you test the patch? You can simply verify the basic function by
checking whether the rx softirq were done in the same cpu where vhost is
running.
>  			/* use multiply and shift instead of expensive divide */
>  			txq = ((u64)txq * numqueues) >> 32;
>  	} else if (likely(skb_rx_queue_recorded(skb))) {
> @@ -728,6 +745,22 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (txq >= tun->numqueues)
>  		goto drop;
>  
> +	if (tun->numqueues == 1) {
> +		/* Select queue was not called for the skbuff, so we extract the
> +		 * RPS hash and save it into the flow_table here.
> +		 */
> +		__u32 rxhash;
> +
> +		rxhash = skb_get_hash(skb);
> +		if (rxhash) {
> +			struct tun_flow_entry *e;
> +			e = tun_flow_find(&tun->flows[tun_hashfn(rxhash)],
> +					rxhash);
> +			if (e)
> +				tun_flow_save_rps_rxhash(e, rxhash);
> +		}
> +	}
> +
>  	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
>  
>  	BUG_ON(!tfile);
