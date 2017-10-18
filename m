From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next V8 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion
 and allocation
Date: Wed, 18 Oct 2017 17:12:09 +0300
Message-ID: <20171018165207-mutt-send-email-mst@kernel.org>
References: <150814913767.1806.3470498528707259987.stgit@firesoul>
 <150814917905.1806.2745716159653488848.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        pavel.odintsov@gmail.com, Jason Wang <jasowang@redhat.com>,
        mchan@broadcom.com, John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com, ast@fiberby.dk,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751462AbdJROMR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 10:12:17 -0400
Content-Disposition: inline
In-Reply-To: <150814917905.1806.2745716159653488848.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 12:19:39PM +0200, Jesper Dangaard Brouer wrote:
> @@ -191,15 +280,45 @@ static int cpu_map_kthread_run(void *data)
>  	 * kthread_stop signal until queue is empty.
>  	 */
>  	while (!kthread_should_stop() || !__ptr_ring_empty(rcpu->queue)) {
> +		unsigned int processed = 0, drops = 0;
>  		struct xdp_pkt *xdp_pkt;
>  
> -		schedule();
> -		/* Do work */
> -		while ((xdp_pkt = ptr_ring_consume(rcpu->queue))) {
> -			/* For now just "refcnt-free" */
> -			page_frag_free(xdp_pkt);
> +		/* Release CPU reschedule checks */
> +		if (__ptr_ring_empty(rcpu->queue)) {


I suspect this is racy: if ring becomes non empty here and
you wake the task, next line will put it to sleep.
I think you want to reverse the order:

			__set_current_state(TASK_INTERRUPTIBLE);

	then check __ptr_ring_empty.

I note using the __ version means you can not resize the ring.
Hope you do not need to.

> +			__set_current_state(TASK_INTERRUPTIBLE);
> +			schedule();
> +		} else {
> +			cond_resched();
> +		}
> +		__set_current_state(TASK_RUNNING);
> +
> +		/* Process packets in rcpu->queue */
> +		local_bh_disable();
> +		/*
> +		 * The bpf_cpu_map_entry is single consumer, with this
> +		 * kthread CPU pinned. Lockless access to ptr_ring
> +		 * consume side valid as no-resize allowed of queue.
> +		 */
> +		while ((xdp_pkt = __ptr_ring_consume(rcpu->queue))) {
> +			struct sk_buff *skb;
> +			int ret;
> +
> +			skb = cpu_map_build_skb(rcpu, xdp_pkt);
> +			if (!skb) {
> +				page_frag_free(xdp_pkt);
> +				continue;
> +			}
> +
> +			/* Inject into network stack */
> +			ret = netif_receive_skb_core(skb);
> +			if (ret == NET_RX_DROP)
> +				drops++;
> +
> +			/* Limit BH-disable period */
> +			if (++processed == 8)
> +				break;
>  		}
> -		__set_current_state(TASK_INTERRUPTIBLE);
> +		local_bh_enable(); /* resched point, may call do_softirq() */
>  	}
>  	__set_current_state(TASK_RUNNING);
>  
> @@ -490,13 +609,6 @@ static int bq_flush_to_queue(struct bpf_cpu_map_entry *rcpu,
>  	return 0;
>  }
>  
> -/* Notice: Will change in later patch */
> -struct xdp_pkt {
> -	void *data;
> -	u16 len;
> -	u16 headroom;
> -};
> -
>  /* Runs under RCU-read-side, plus in softirq under NAPI protection.
>   * Thus, safe percpu variable access.
>   */
> @@ -524,17 +636,13 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
>  		    struct net_device *dev_rx)
>  {
>  	struct xdp_pkt *xdp_pkt;
> -	int headroom;
>  
> -	/* For now this is just used as a void pointer to data_hard_start.
> -	 * Followup patch will generalize this.
> -	 */
> -	xdp_pkt = xdp->data_hard_start;
> +	xdp_pkt = convert_to_xdp_pkt(xdp);
> +	if (!xdp_pkt)
> +		return -EOVERFLOW;
>  
> -	/* Fake writing into xdp_pkt->data to measure overhead */
> -	headroom = xdp->data - xdp->data_hard_start;
> -	if (headroom < sizeof(*xdp_pkt))
> -		xdp_pkt->data = xdp->data;
> +	/* Info needed when constructing SKB on remote CPU */
> +	xdp_pkt->dev_rx = dev_rx;
>  
>  	bq_enqueue(rcpu, xdp_pkt);
>  	return 0;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fcddccb6be41..36bb68f3a2c7 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4491,6 +4491,33 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
>  	return ret;
>  }
>  
> +/**
> + *	netif_receive_skb_core - special purpose version of netif_receive_skb
> + *	@skb: buffer to process
> + *
> + *	More direct receive version of netif_receive_skb().  It should
> + *	only be used by callers that have a need to skip RPS and Generic XDP.
> + *	Caller must also take care of handling if (page_is_)pfmemalloc.
> + *
> + *	This function may only be called from softirq context and interrupts
> + *	should be enabled.
> + *
> + *	Return values (usually ignored):
> + *	NET_RX_SUCCESS: no congestion
> + *	NET_RX_DROP: packet was dropped
> + */
> +int netif_receive_skb_core(struct sk_buff *skb)
> +{
> +	int ret;
> +
> +	rcu_read_lock();
> +	ret = __netif_receive_skb_core(skb, false);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(netif_receive_skb_core);
> +
>  static int __netif_receive_skb(struct sk_buff *skb)
>  {
>  	int ret;
