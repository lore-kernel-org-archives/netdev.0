From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 3/5] bpf: cpumap xdp_buff to skb conversion and
 allocation
Date: Fri, 29 Sep 2017 01:21:01 +0200
Message-ID: <59CD83DD.4060603@iogearbox.net>
References: <150660339205.2808.7084136789768233829.stgit@firesoul> <150660343811.2808.7680200486950101509.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56696 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750857AbdI1XVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 19:21:03 -0400
In-Reply-To: <150660343811.2808.7680200486950101509.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2017 02:57 PM, Jesper Dangaard Brouer wrote:
[...]
> +/* Convert xdp_buff to xdp_pkt */
> +static struct xdp_pkt *convert_to_xdp_pkt(struct xdp_buff *xdp)
> +{
> +	struct xdp_pkt *xdp_pkt;
> +	int headroom;
> +
> +	/* Assure headroom is available for storing info */
> +	headroom = xdp->data - xdp->data_hard_start;
> +	if (headroom < sizeof(*xdp_pkt))
> +		return NULL;
> +
> +	/* Store info in top of packet */
> +	xdp_pkt = xdp->data_hard_start;

(You'd also need to handle data_meta here if set, and for below
cpu_map_build_skb(), e.g. headroom is data_meta-data_hard_start.)

> +	xdp_pkt->data = xdp->data;
> +	xdp_pkt->len  = xdp->data_end - xdp->data;
> +	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);
> +
> +	return xdp_pkt;
> +}
> +
> +static struct sk_buff *cpu_map_build_skb(struct bpf_cpu_map_entry *rcpu,
> +					 struct xdp_pkt *xdp_pkt)
> +{
> +	unsigned int frame_size;
> +	void *pkt_data_start;
> +	struct sk_buff *skb;
> +
> +	/* build_skb need to place skb_shared_info after SKB end, and
> +	 * also want to know the memory "truesize".  Thus, need to
[...]
>   static int cpu_map_kthread_run(void *data)
>   {
> +	const unsigned long busy_poll_jiffies = usecs_to_jiffies(2000);
> +	unsigned long time_limit = jiffies + busy_poll_jiffies;
>   	struct bpf_cpu_map_entry *rcpu = data;
> +	unsigned int empty_cnt = 0;
>
>   	set_current_state(TASK_INTERRUPTIBLE);
>   	while (!kthread_should_stop()) {
> +		unsigned int processed = 0, drops = 0;
>   		struct xdp_pkt *xdp_pkt;
>
> -		schedule();
> -		/* Do work */
> -		while ((xdp_pkt = ptr_ring_consume(rcpu->queue))) {
> -			/* For now just "refcnt-free" */
> -			page_frag_free(xdp_pkt);
> +		/* Release CPU reschedule checks */
> +		if ((time_after_eq(jiffies, time_limit) || empty_cnt > 25) &&
> +		    __ptr_ring_empty(rcpu->queue)) {
> +			empty_cnt++;
> +			schedule();
> +			time_limit = jiffies + busy_poll_jiffies;
> +			WARN_ON(smp_processor_id() != rcpu->cpu);
> +		} else {
> +			cond_resched();
>   		}
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
> +			/* Allow busy polling again */
> +			empty_cnt = 0;
> +
> +			skb = cpu_map_build_skb(rcpu, xdp_pkt);
> +			if (!skb) {
> +				page_frag_free(xdp_pkt);
> +				continue;
> +			}
> +
> +			/* Inject into network stack */
> +			ret = netif_receive_skb(skb);

Have you looked into whether it's feasible to reuse GRO
engine here as well?

> +			if (ret == NET_RX_DROP)
> +				drops++;
> +
> +			/* Limit BH-disable period */
> +			if (++processed == 8)
> +				break;
> +		}
> +		local_bh_enable();
> +
>   		__set_current_state(TASK_INTERRUPTIBLE);
>   	}
>   	put_cpu_map_entry(rcpu);
[...]
