From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 10/14] virtio_net: limit xmit polling
Date: Tue, 24 May 2011 14:29:39 +0300
Message-ID: <20110524112901.GB17087@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
	<aced8619c07018b5495f9ceb2c02d4fbf897a098.1305846412.git.mst@redhat.com>
	<877h9kvlps.fsf@rustcorp.com.au>
	<20110522121008.GA12155@redhat.com>
	<87boyutbjg.fsf@rustcorp.com.au>
	<20110523111900.GB27212@redhat.com>
	<OFEED174CD.D3C9A726-ON6525789A.002661D5-6525789A.002B26ED@in.ibm.com>
	<20110524091255.GB16886@redhat.com>
	<OF69E520FD.340352AC-ON6525789A.003308A2-6525789A.0033F2DF@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <OF69E520FD.340352AC-ON6525789A.003308A2-6525789A.0033F2DF-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2011 at 02:57:43PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote on 05/24/2011 02:42:55 PM:
> 
> > > > > To do this properly, we should really be using the actual number of
> sg
> > > > > elements needed, but we'd have to do most of xmit_skb beforehand so
> we
> > > > > know how many.
> > > > >
> > > > > Cheers,
> > > > > Rusty.
> > > >
> > > > Maybe I'm confused here.  The problem isn't the failing
> > > > add_buf for the given skb IIUC.  What we are trying to do here is
> stop
> > > > the queue *before xmit_skb fails*. We can't look at the
> > > > number of fragments in the current skb - the next one can be
> > > > much larger.  That's why we check capacity after xmit_skb,
> > > > not before it, right?
> > >
> > > Maybe Rusty means it is a simpler model to free the amount
> > > of space that this xmit needs. We will still fail anyway
> > > at some time but it is unlikely, since earlier iteration
> > > freed up atleast the space that it was going to use.
> >
> > Not sure I nderstand.  We can't know space is freed in the previous
> > iteration as buffers might not have been used by then.
> 
> Yes, the first few iterations may not have freed up space, but
> later ones should. The amount of free space should increase
> from then on, especially since we try to free double of what
> we consume.

Hmm. This is only an upper limit on the # of entries in the queue.
Assume that vq size is 4 and we transmit 4 enties without
getting anything in the used ring. The next transmit will fail.

So I don't really see why it's unlikely that we reach the packet
drop code with your patch.

> > > The
> > > code could become much simpler:
> > >
> > > start_xmit()
> > > {
> > > {
> > >         num_sgs = get num_sgs for this skb;
> > >
> > >         /* Free enough pending old buffers to enable queueing this one
> */
> > >         free_old_xmit_skbs(vi, num_sgs * 2);     /* ?? */
> > >
> > >         if (virtqueue_get_capacity() < num_sgs) {
> > >                 netif_stop_queue(dev);
> > >                 if (virtqueue_enable_cb_delayed(vi->svq) ||
> > >                     free_old_xmit_skbs(vi, num_sgs)) {
> > >                         /* Nothing freed up, or not enough freed up */
> > >                         kfree_skb(skb);
> > >                         return NETDEV_TX_OK;
> >
> > This packet drop is what we wanted to avoid.
> 
> Please see below on returning NETDEV_TX_BUSY.
> 
> >
> > >                 }
> > >                 netif_start_queue(dev);
> > >                 virtqueue_disable_cb(vi->svq);
> > >         }
> > >
> > >         /* xmit_skb cannot fail now, also pass 'num_sgs' */
> > >         xmit_skb(vi, skb, num_sgs);
> > >         virtqueue_kick(vi->svq);
> > >
> > >         skb_orphan(skb);
> > >         nf_reset(skb);
> > >
> > >         return NETDEV_TX_OK;
> > > }
> > >
> > > We could even return TX_BUSY since that makes the dequeue
> > > code more efficient. See dev_dequeue_skb() - you can skip a
> > > lot of code (and avoid taking locks) to check if the queue
> > > is already stopped but that code runs only if you return
> > > TX_BUSY in the earlier iteration.
> > >
> > > BTW, shouldn't the check in start_xmit be:
> > >    if (likely(!free_old_xmit_skbs(vi, 2+MAX_SKB_FRAGS))) {
> > >       ...
> > >    }
> > >
> > > Thanks,
> > >
> > > - KK
> >
> > I thought we used to do basically this but other devices moved to a
> > model where they stop *before* queueing fails, so we did too.
> 
> I am not sure of why it was changed, since returning TX_BUSY
> seems more efficient IMHO.
> qdisc_restart() handles requeue'd
> packets much better than a stopped queue, as a significant
> part of this code is skipped if gso_skb is present

I think this is the argument:
http://www.mail-archive.com/virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org/msg06364.html


> (qdisc
> will eventually start dropping packets when tx_queue_len is
> exceeded anyway).
> 
> Thanks,
> 
> - KK

tx_queue_len is a pretty large buffer so maybe no.
I think the packet drops from the scheduler queue can also be
done intelligently (e.g. with CHOKe) which should
work better than dropping a random packet?

-- 
MST
