From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next V4 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion
 and allocation
Date: Thu, 05 Oct 2017 12:22:43 +0200
Message-ID: <59D607F3.6090306@iogearbox.net>
References: <150711858281.9499.7767364427831352921.stgit@firesoul> <150711863521.9499.3702385818650624585.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39701 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751430AbdJEKWs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:22:48 -0400
In-Reply-To: <150711863521.9499.3702385818650624585.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2017 02:03 PM, Jesper Dangaard Brouer wrote:
[...]
>   static int cpu_map_kthread_run(void *data)
>   {
>   	struct bpf_cpu_map_entry *rcpu = data;
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
> +		if (__ptr_ring_empty(rcpu->queue)) {
> +			schedule();
> +		} else {
> +			cond_resched();
> +		}
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

Don't we need to hold RCU read lock for above netif_receive_skb_core()?

> +			if (ret == NET_RX_DROP)
> +				drops++;
> +
> +			/* Limit BH-disable period */
> +			if (++processed == 8)
> +				break;
>   		}
> +		local_bh_enable(); /* resched point, may call do_softirq() */
> +
>   		__set_current_state(TASK_INTERRUPTIBLE);
>   	}
>   	put_cpu_map_entry(rcpu);
> @@ -463,13 +582,6 @@ static int bq_flush_to_queue(struct bpf_cpu_map_entry *rcpu,
