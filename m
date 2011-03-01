From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/3] [RFC] Changes for MQ virtio-net
Date: Tue, 1 Mar 2011 21:32:56 +0530
Message-ID: <OF2E9005A4.28D2C8A6-ON65257846.0054C7BB-65257846.00580600@in.ibm.com>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com> <20110228063437.24908.29435.sendpatchset@krkumar2.in.ibm.com> <20110228094320.GB28006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, horms@verge.net.au,
	kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110228094320.GB28006@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 02/28/2011 03:13:20 PM:

Thank you once again for your feedback on both these patches.
I will send the qemu patch tomorrow. I will also send the next
version incorporating these suggestions once we finalize some
minor points.

> Overall looks good.
> The numtxqs meaning the number of rx queues needs some cleanup.
> init/cleanup routines need more symmetry.
> Error handling on setup also seems slightly buggy or at least
asymmetrical.
> Finally, this will use up a large number of MSI vectors,
> while TX interrupts mostly stay unused.
>
> Some comments below.
>
> > +/* Maximum number of individual RX/TX queues supported */
> > +#define VIRTIO_MAX_TXQS		 		 16
> > +
>
> This also does not seem to belong in the header.

Both virtio-net and vhost need some check to make sure very
high values are not passed by userspace. Is this not required?

> > +#define VIRTIO_NET_F_NUMTXQS		 21		 /* Device supports multiple
TX queue */
>
> VIRTIO_NET_F_MULTIQUEUE ?

Yes, that's a better name.

> > @@ -34,6 +38,8 @@ struct virtio_net_config {
> >  		 __u8 mac[6];
> >  		 /* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
> >  		 __u16 status;
> > +		 /* number of RX/TX queues */
> > +		 __u16 numtxqs;
>
> The interface here is a bit ugly:
> - this is really both # of tx and rx queues but called numtxqs
> - there's a hardcoded max value
> - 0 is assumed to be same as 1
> - assumptions above are undocumented.
>
> One way to address this could be num_queue_pairs, and something like
> 		 /* The actual number of TX and RX queues is num_queue_pairs +
1 each. */
> 		 __u16 num_queue_pairs;
> (and tweak code to match).
>
> Alternatively, have separate registers for the number of tx and rx
queues.

OK, so virtio_net_config has num_queue_pairs, and this gets converted to
numtxqs in virtnet_info?

> > +struct virtnet_info {
> > +		 struct send_queue **sq;
> > +		 struct receive_queue **rq;
> > +
> > +		 /* read-mostly variables */
> > +		 int numtxqs ____cacheline_aligned_in_smp;
>
> Why do you think this alignment is a win?

Actually this code was from the earlier patchset (MQ TX only) where
the layout was different. Now rq and sq are allocated as follows:
	vi->sq = kzalloc(numtxqs * sizeof(*vi->sq), GFP_KERNEL);
	for (i = 0; i < numtxqs; i++) {
		vi->sq[i] = kzalloc(sizeof(*vi->sq[i]), GFP_KERNEL);
Since the two pointers becomes read-only during use, there is no cache
line dirty'ing.  I will remove this directive.

> > +/*
> > + * Note for 'qnum' below:
> > + *		 first 'numtxqs' vqs are RX, next 'numtxqs' vqs are TX.
> > + */
>
> Another option to consider is to have them RX,TX,RX,TX:
> this way vq->queue_index / 2 gives you the
> queue pair number, no need to read numtxqs. On the other hand, it makes
the
> #RX==#TX assumption even more entrenched.

OK. I was following how many drivers were allocating RX and TX's
together - eg ixgbe_adapter has tx_ring and rx_ring arrays; bnx2
has rx_buf_ring and tx_buf_ring arrays, etc. Also, vhost has some
code that processes tx first before rx (e.g. vhost_net_stop/flush),
so this approach seemed helpful. I am OK either way, what do you
suggest?

> > +		 err = vi->vdev->config->find_vqs(vi->vdev, totalvqs, vqs,
callbacks,
> > +		 		 		 		 		  (const char
**)names);
> > +		 if (err)
> > +		 		 goto free_params;
> > +
>
> This would use up quite a lot of vectors. However,
> tx interrupt is, in fact, slow path. So, assuming we don't have
> enough vectors to use per vq, I think it's a good idea to
> support reducing MSI vector usage by mapping all TX VQs to the same
vector
> and separate vectors for RX.
> The hypervisor actually allows this, but we don't have an API at the
virtio
> level to pass that info to virtio pci ATM.
> Any idea what a good API to use would be?

Yes, it is a waste to have these vectors for tx ints. I initially
thought of adding a flag to virtio_device to pass to vp_find_vqs,
but it won't work, so a new API is needed. I can work with you on
this in the background if you like.

> > +		 for (i = 0; i < numtxqs; i++) {
> > +		 		 vi->rq[i]->rvq = vqs[i];
> > +		 		 vi->sq[i]->svq = vqs[i + numtxqs];
>
> This logic is spread all over. We need some kind of macro to
> get queue number of vq number and back.

Will add this.

> > +		 if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
> > +		 		 vi->cvq = vqs[i + numtxqs];
> > +
> > +		 		 if (virtio_has_feature(vi->vdev,
VIRTIO_NET_F_CTRL_VLAN))
> > +		 		 		 vi->dev->features |=
NETIF_F_HW_VLAN_FILTER;
>
> This bit does not seem to belong in initialize_vqs.

I will move it back to probe.

> > +		 err = virtio_config_val(vdev, VIRTIO_NET_F_NUMTXQS,
> > +		 		 		 		 offsetof(struct
virtio_net_config, numtxqs),
> > +		 		 		 		 &numtxqs);
> > +
> > +		 /* We need atleast one txq */
> > +		 if (err || !numtxqs)
> > +		 		 numtxqs = 1;
>
> err is okay, but should we just fail on illegal values?
> Or change the semantics:
>	n = 0;
>	err = virtio_config_val(vdev, VIRTIO_NET_F_NUMTXQS,
>				offsetof(struct virtio_net_config, numtxqs),
>				&n);
>	numtxq = n + 1;

Will this be better:
	int num_queue_pairs = 2;
	int numtxqs;

	err = virtio_config_val(vdev, VIRTIO_NET_F_MULTIQUEUE,
				offsetof(struct virtio_net_config,
					 num_queue_pairs), &num_queue_pairs);
	<ignore error, if any>
	numtxqs = num_queue_pairs / 2;

> > +		 if (numtxqs > VIRTIO_MAX_TXQS)
> > +		 		 return -EINVAL;
>
> Do we strictly need this?
> I think we should just use whatever hardware has,
> or alternatively somehow ignore the unused queues
> (easy for tx, not sure about rx).

vq's are matched between qemu, virtio-net and vhost. Isn't some check
required that userspace has not passed a bad value?

> > +		 		 if (vi->rq[i]->num == 0) {
> > +		 		 		 err = -ENOMEM;
> > +		 		 		 goto free_recv_bufs;
> > +		 		 }
> >  		 }
> If this fails for vq > 0, you have to detach bufs.

Right, will fix this.

> >  free_vqs:
> > +		 for (i = 0; i < numtxqs; i++)
> > +		 		 cancel_delayed_work_sync(&vi->rq[i]->refill);
> >  		 vdev->config->del_vqs(vdev);
> > -free:
> > +		 free_rq_sq(vi);
>
> If we have a wrapper to init all vqs, pls add a wrapper to clean up
> all vqs as well.

Will add that.

> > +		 for (i = 0; i < vi->numtxqs; i++) {
> > +		 		 struct virtqueue *rvq = vi->rq[i]->rvq;
> > +
> > +		 		 while (1) {
> > +		 		 		 buf = virtqueue_detach_unused_buf
(rvq);
> > +		 		 		 if (!buf)
> > +		 		 		 		 break;
> > +		 		 		 if (vi->mergeable_rx_bufs || vi->
big_packets)
> > +		 		 		 		 give_pages(vi->rq[i],
buf);
> > +		 		 		 else
> > +		 		 		 		 dev_kfree_skb(buf);
> > +		 		 		 --vi->rq[i]->num;
> > +		 		 }
> > +		 		 BUG_ON(vi->rq[i]->num != 0);
> >  		 }
> > -		 BUG_ON(vi->num != 0);
> > +
> > +		 free_rq_sq(vi);
>
>
> This looks wrong here. This function should detach
> and free all bufs, not internal malloc stuff.

That is being done by free_receive_buf after free_unused_bufs()
returns. I hope this addresses your point.

> I think we should have free_unused_bufs that handles
> a single queue, and call it in a loop.

OK, so define free_unused_bufs() as:

static void free_unused_bufs(struct virtnet_info *vi, struct virtqueue
*svq,
			     struct virtqueue *rvq)
{
	/* Use svq and rvq with the remaining code unchanged */
}

Thanks,

- KK

