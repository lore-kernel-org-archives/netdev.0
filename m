From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 14 Oct 2010 14:34:01 +0530
Message-ID: <OFEC86A094.39835EBF-ON652577BC.002F9AAF-652577BC.003186B5@in.ibm.com>
References: <cover.1286372004.git.mst@redhat.com> <OF6C412DBC.EA03FC24-ON652577B9.00228DCA-652577B9.0028232D@in.ibm.com> <20101012170907.GA30613@redhat.com> <OFA7630B83.BFDFF71D-ON652577BC.0026D199-652577BC.002B9158@in.ibm.com> <20101014081723.GC11095@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101014081723.GC11095@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> "Michael S. Tsirkin" <mst@redhat.com>
> > > What other shared TX/RX locks are there?  In your setup, is the same
> > > macvtap socket structure used for RX and TX?  If yes this will create
> > > cacheline bounces as sk_wmem_alloc/sk_rmem_alloc share a cache line,
> > > there might also be contention on the lock in sk_sleep waitqueue.
> > > Anything else?
> >
> > The patch is not introducing any locking (both vhost and virtio-net).
> > The single stream drop is due to different vhost threads handling the
> > RX/TX traffic.
> >
> > I added a heuristic (fuzzy) to determine if more than one flow
> > is being used on the device, and if not, use vhost[0] for both
> > tx and rx (vhost_poll_queue figures this out before waking up
> > the suitable vhost thread).  Testing shows that single stream
> > performance is as good as the original code.
>
> ...
>
> > This approach works nicely for both single and multiple stream.
> > Does this look good?
> >
> > Thanks,
> >
> > - KK
>
> Yes, but I guess it depends on the heuristic :) What's the logic?

I define how recently a txq was used. If 0 or 1 txq's were used
recently, use vq[0] (which also handles rx). Otherwise, use
multiple txq (vq[1-n]). The code is:

/*
 * Algorithm for selecting vq:
 *
 * Condition                                    Return
 * RX vq                                        vq[0]
 * If all txqs unused                           vq[0]
 * If one txq used, and new txq is same         vq[0]
 * If one txq used, and new txq is different    vq[vq->qnum]
 * If > 1 txqs used                             vq[vq->qnum]
 *      Where "used" means the txq was used in the last 'n' jiffies.
 *
 * Note: locking is not required as an update race will only result in
 * a different worker being woken up.
 */
static inline struct vhost_virtqueue *vhost_find_vq(struct vhost_poll
*poll)
{
	if (poll->vq->qnum) {
		struct vhost_dev *dev = poll->vq->dev;
		struct vhost_virtqueue *vq = &dev->vqs[0];
		unsigned long max_time = jiffies - 5; /* Some macro needed */
		unsigned long *table = dev->jiffies;
		int i, used = 0;

		for (i = 0; i < dev->nvqs - 1; i++) {
			if (time_after_eq(table[i], max_time) && ++used > 1) {
				vq = poll->vq;
				break;
			}
		}
		table[poll->vq->qnum - 1] = jiffies;
		return vq;
	}

	/* RX is handled by the same worker thread */
	return poll->vq;
}

void vhost_poll_queue(struct vhost_poll *poll)
{
        struct vhost_virtqueue *vq = vhost_find_vq(poll);

        vhost_work_queue(vq, &poll->work);
}

Since poll batches packets, find_vq does not seem to add much
to the CPU utilization (or BW). I am sure that code can be
optimized much better.

The results I sent in my last mail were without your use_mm
patch, and the only tuning was to make vhost threads run on
only cpus 0-3 (though the performance is good even without
that). I will test it later today with the use_mm patch too.

Thanks,

- KK

