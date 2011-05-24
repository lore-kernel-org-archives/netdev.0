From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCHv2 10/14] virtio_net: limit xmit polling
Date: Tue, 24 May 2011 14:57:43 +0530
Message-ID: <OF69E520FD.340352AC-ON6525789A.003308A2-6525789A.0033F2DF@in.ibm.com>
References: <cover.1305846412.git.mst@redhat.com> <aced8619c07018b5495f9ceb2c02d4fbf897a098.1305846412.git.mst@redhat.com> <877h9kvlps.fsf@rustcorp.com.au> <20110522121008.GA12155@redhat.com> <87boyutbjg.fsf@rustcorp.com.au> <20110523111900.GB27212@redhat.com> <OFEED174CD.D3C9A726-ON6525789A.002661D5-6525789A.002B26ED@in.ibm.com> <20110524091255.GB16886@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Carsten Otte <cotte@de.ibm.com>, habanero@linux.vnet.ibm.com,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	kvm@vger.kernel.org, lguest@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org,
	linux390@de.ibm.com, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Shirley Ma <xma@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110524091255.GB16886@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/24/2011 02:42:55 PM:

> > > > To do this properly, we should really be using the actual number of
sg
> > > > elements needed, but we'd have to do most of xmit_skb beforehand so
we
> > > > know how many.
> > > >
> > > > Cheers,
> > > > Rusty.
> > >
> > > Maybe I'm confused here.  The problem isn't the failing
> > > add_buf for the given skb IIUC.  What we are trying to do here is
stop
> > > the queue *before xmit_skb fails*. We can't look at the
> > > number of fragments in the current skb - the next one can be
> > > much larger.  That's why we check capacity after xmit_skb,
> > > not before it, right?
> >
> > Maybe Rusty means it is a simpler model to free the amount
> > of space that this xmit needs. We will still fail anyway
> > at some time but it is unlikely, since earlier iteration
> > freed up atleast the space that it was going to use.
>
> Not sure I nderstand.  We can't know space is freed in the previous
> iteration as buffers might not have been used by then.

Yes, the first few iterations may not have freed up space, but
later ones should. The amount of free space should increase
from then on, especially since we try to free double of what
we consume.

> > The
> > code could become much simpler:
> >
> > start_xmit()
> > {
> > {
> >         num_sgs = get num_sgs for this skb;
> >
> >         /* Free enough pending old buffers to enable queueing this one
*/
> >         free_old_xmit_skbs(vi, num_sgs * 2);     /* ?? */
> >
> >         if (virtqueue_get_capacity() < num_sgs) {
> >                 netif_stop_queue(dev);
> >                 if (virtqueue_enable_cb_delayed(vi->svq) ||
> >                     free_old_xmit_skbs(vi, num_sgs)) {
> >                         /* Nothing freed up, or not enough freed up */
> >                         kfree_skb(skb);
> >                         return NETDEV_TX_OK;
>
> This packet drop is what we wanted to avoid.

Please see below on returning NETDEV_TX_BUSY.

>
> >                 }
> >                 netif_start_queue(dev);
> >                 virtqueue_disable_cb(vi->svq);
> >         }
> >
> >         /* xmit_skb cannot fail now, also pass 'num_sgs' */
> >         xmit_skb(vi, skb, num_sgs);
> >         virtqueue_kick(vi->svq);
> >
> >         skb_orphan(skb);
> >         nf_reset(skb);
> >
> >         return NETDEV_TX_OK;
> > }
> >
> > We could even return TX_BUSY since that makes the dequeue
> > code more efficient. See dev_dequeue_skb() - you can skip a
> > lot of code (and avoid taking locks) to check if the queue
> > is already stopped but that code runs only if you return
> > TX_BUSY in the earlier iteration.
> >
> > BTW, shouldn't the check in start_xmit be:
> >    if (likely(!free_old_xmit_skbs(vi, 2+MAX_SKB_FRAGS))) {
> >       ...
> >    }
> >
> > Thanks,
> >
> > - KK
>
> I thought we used to do basically this but other devices moved to a
> model where they stop *before* queueing fails, so we did too.

I am not sure of why it was changed, since returning TX_BUSY
seems more efficient IMHO. qdisc_restart() handles requeue'd
packets much better than a stopped queue, as a significant
part of this code is skipped if gso_skb is present (qdisc
will eventually start dropping packets when tx_queue_len is
exceeded anyway).

Thanks,

- KK

