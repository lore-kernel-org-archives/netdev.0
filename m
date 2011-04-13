From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/4] [RFC rev2] virtio-net changes
Date: Wed, 13 Apr 2011 21:50:57 +0530
Message-ID: <OF5B3391B0.82132B9C-ON65257871.005987DF-65257871.00599AA5@in.ibm.com>
References: <20110405150826.20501.39679.sendpatchset@krkumar2.in.ibm.com> <20110405150852.20501.10500.sendpatchset@krkumar2.in.ibm.com> <878vvf0wkd.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, horms@verge.net.au,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:60957 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932947Ab1DMQSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 12:18:49 -0400
In-Reply-To: <878vvf0wkd.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

Thanks for your feedback. I agree with all the changes, and will
make it and resubmit next.

thanks,

- KK

Rusty Russell <rusty@rustcorp.com.au> wrote on 04/13/2011 06:58:02 AM:

> Rusty Russell <rusty@rustcorp.com.au>
> 04/13/2011 06:58 AM
>
> To
>
> Krishna Kumar2/India/IBM@IBMIN, davem@davemloft.net, mst@redhat.com
>
> cc
>
> eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
> horms@verge.net.au, avi@redhat.com, anthony@codemonkey.ws,
> kvm@vger.kernel.org, Krishna Kumar2/India/IBM@IBMIN
>
> Subject
>
> Re: [PATCH 2/4] [RFC rev2] virtio-net changes
>
> On Tue, 05 Apr 2011 20:38:52 +0530, Krishna Kumar <krkumar2@in.ibm.com>
wrote:
> > Implement mq virtio-net driver.
> >
> > Though struct virtio_net_config changes, it works with the old
> > qemu since the last element is not accessed unless qemu sets
> > VIRTIO_NET_F_MULTIQUEUE.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>
> Hi Krishna!
>
>     This change looks fairly solid, but I'd prefer it split into a few
> stages for clarity.
>
> The first patch should extract out the struct send_queue and struct
> receive_queue, even though there's still only one.  The second patch
> can then introduce VIRTIO_NET_F_MULTIQUEUE.
>
> You could split into more parts if that makes sense, but I'd prefer to
> see the mechanical changes separate from the feature addition.
>
> > -struct virtnet_info {
> > -   struct virtio_device *vdev;
> > -   struct virtqueue *rvq, *svq, *cvq;
> > -   struct net_device *dev;
> > +/* Internal representation of a send virtqueue */
> > +struct send_queue {
> > +   /* Virtqueue associated with this send _queue */
> > +   struct virtqueue *svq;
>
> You can simply call this vq now it's inside 'send_queue'.
>
> > +
> > +   /* TX: fragments + linear part + virtio header */
> > +   struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
>
> Similarly, this can just be sg.
>
> > +static void free_receive_bufs(struct virtnet_info *vi)
> > +{
> > +   int i;
> > +
> > +   for (i = 0; i < vi->numtxqs; i++) {
> > +      BUG_ON(vi->rq[i] == NULL);
> > +      while (vi->rq[i]->pages)
> > +         __free_pages(get_a_page(vi->rq[i], GFP_KERNEL), 0);
> > +   }
> > +}
>
> You can skip the BUG_ON(), since the next line will have the same effect.
>
> > +/* Free memory allocated for send and receive queues */
> > +static void free_rq_sq(struct virtnet_info *vi)
> > +{
> > +   int i;
> > +
> > +   if (vi->rq) {
> > +      for (i = 0; i < vi->numtxqs; i++)
> > +         kfree(vi->rq[i]);
> > +      kfree(vi->rq);
> > +   }
> > +
> > +   if (vi->sq) {
> > +      for (i = 0; i < vi->numtxqs; i++)
> > +         kfree(vi->sq[i]);
> > +      kfree(vi->sq);
> > +   }
>
> This looks weird, even though it's correct.
>
> I think we need a better name than numtxqs and shorter than
> num_queue_pairs.  Let's just use num_queues; sure, there are both tx and
> rq queues, but I still think it's pretty clear.
>
> > +   for (i = 0; i < vi->numtxqs; i++) {
> > +      struct virtqueue *svq = vi->sq[i]->svq;
> > +
> > +      while (1) {
> > +         buf = virtqueue_detach_unused_buf(svq);
> > +         if (!buf)
> > +            break;
> > +         dev_kfree_skb(buf);
> > +      }
> > +   }
>
> I know this isn't your code, but it's ugly :)
>
>         while ((buf = virtqueue_detach_unused_buf(svq)) != NULL)
>                 dev_kfree_skb(buf);
>
> > +   for (i = 0; i < vi->numtxqs; i++) {
> > +      struct virtqueue *rvq = vi->rq[i]->rvq;
> > +
> > +      while (1) {
> > +         buf = virtqueue_detach_unused_buf(rvq);
> > +         if (!buf)
> > +            break;
>
> Here too...
>
> > +#define MAX_DEVICE_NAME      16
>
> This isn't a good idea, see below.
>
> > +static int initialize_vqs(struct virtnet_info *vi, int numtxqs)
> > +{
> > +   vq_callback_t **callbacks;
> > +   struct virtqueue **vqs;
> > +   int i, err = -ENOMEM;
> > +   int totalvqs;
> > +   char **names;
>
> This whole routine is really messy.  How about doing find_vqs first,
> then have routines like setup_rxq(), setup_txq() and setup_controlq()
> would make this neater:
>
>         static int setup_rxq(struct send_queue *sq, char *name);
>
> Also, use kasprintf() instead of kmalloc & sprintf.
>
> > +#if 1
> > +   /* Allocate/initialize parameters for recv/send virtqueues */
>
> Why is this #if 1'd?
>
> I do prefer the #else method of doing two loops, myself (but use
> kasprintf).
>
> Cheers,
> Rusty.

