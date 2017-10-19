From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V8 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion
 and allocation
Date: Thu, 19 Oct 2017 12:10:51 +0200
Message-ID: <20171019121051.2117c062@redhat.com>
References: <150814913767.1806.3470498528707259987.stgit@firesoul>
        <150814917905.1806.2745716159653488848.stgit@firesoul>
        <20171018165207-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        pavel.odintsov@gmail.com, Jason Wang <jasowang@redhat.com>,
        mchan@broadcom.com, John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com, ast@fiberby.dk,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751898AbdJSKLC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 06:11:02 -0400
In-Reply-To: <20171018165207-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Oct 2017 17:12:09 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Mon, Oct 16, 2017 at 12:19:39PM +0200, Jesper Dangaard Brouer wrote:
> > @@ -191,15 +280,45 @@ static int cpu_map_kthread_run(void *data)
> >  	 * kthread_stop signal until queue is empty.
> >  	 */
> >  	while (!kthread_should_stop() || !__ptr_ring_empty(rcpu->queue)) {
> > +		unsigned int processed = 0, drops = 0;
> >  		struct xdp_pkt *xdp_pkt;
> >  
> > -		schedule();
> > -		/* Do work */
> > -		while ((xdp_pkt = ptr_ring_consume(rcpu->queue))) {
> > -			/* For now just "refcnt-free" */
> > -			page_frag_free(xdp_pkt);
> > +		/* Release CPU reschedule checks */
> > +		if (__ptr_ring_empty(rcpu->queue)) {  
> 
> 
> I suspect this is racy: if ring becomes non empty here and
> you wake the task, next line will put it to sleep.
> I think you want to reverse the order:
> 
> 			__set_current_state(TASK_INTERRUPTIBLE);
> 
> 	then check __ptr_ring_empty.

I'll look into this.

The window will be minimal, as __cpu_map_flush() after the last packets
enqueue will call wake_up_process(rcpu->kthread).  But I guess there is
still small race possible.  Worst case, a packet could be stuck in the
queue until a new packet arrive.  Thanks for spotting this.


> I note using the __ version means you can not resize the ring.
> Hope you do not need to.

Resize is not supported.  If user change the queue size, a new ptr_ring
and kthread is created, and logic assured the old ptr_ring and kthread
flush packets appropriately (this is tested with the --stress-mode).

 
> > +			__set_current_state(TASK_INTERRUPTIBLE);
> > +			schedule();
> > +		} else {
> > +			cond_resched();
> > +		}
> > +		__set_current_state(TASK_RUNNING);
> > +
> > +		/* Process packets in rcpu->queue */
> > +		local_bh_disable();
> > +		/*
> > +		 * The bpf_cpu_map_entry is single consumer, with this
> > +		 * kthread CPU pinned. Lockless access to ptr_ring
> > +		 * consume side valid as no-resize allowed of queue.
> > +		 */
> > +		while ((xdp_pkt = __ptr_ring_consume(rcpu->queue))) {
> > +			struct sk_buff *skb;
> > +			int ret;
> > +
> > +			skb = cpu_map_build_skb(rcpu, xdp_pkt);
> > +			if (!skb) {
> > +				page_frag_free(xdp_pkt);
> > +				continue;
> > +			}
> > +
> > +			/* Inject into network stack */
> > +			ret = netif_receive_skb_core(skb);
> > +			if (ret == NET_RX_DROP)
> > +				drops++;
> > +
> > +			/* Limit BH-disable period */
> > +			if (++processed == 8)
> > +				break;
> >  		}
> > -		__set_current_state(TASK_INTERRUPTIBLE);
> > +		local_bh_enable(); /* resched point, may call do_softirq() */
> >  	}
> >  	__set_current_state(TASK_RUNNING);
> >


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
