From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] virtio-net: fix page refcnt leaking when fail to
	allocate frag skb
Date: Tue, 19 Nov 2013 13:36:36 -0800
Message-ID: <1384896996.8604.120.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384848307-7217-1-git-send-email-jasowang@redhat.com>
	<1384869828.8604.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119204909.GA15004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131119204909.GA15004@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-11-19 at 22:49 +0200, Michael S. Tsirkin wrote:
> On Tue, Nov 19, 2013 at 06:03:48AM -0800, Eric Dumazet wrote:
> > On Tue, 2013-11-19 at 16:05 +0800, Jason Wang wrote:
> > > We need to drop the refcnt of page when we fail to allocate an skb for frag
> > > list, otherwise it will be leaked. The bug was introduced by commit
> > > 2613af0ed18a11d5c566a81f9a6510b73180660a ("virtio_net: migrate mergeable rx
> > > buffers to page frag allocators").
> > > 
> > > Cc: Michael Dalton <mwdalton@google.com>
> > > Cc: Eric Dumazet <edumazet@google.com>
> > > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > > Cc: Michael S. Tsirkin <mst@redhat.com>
> > > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > > ---
> > > The patch was needed for 3.12 stable.
> > 
> > Good catch, but if we return from receive_mergeable() in the 'middle'
> > of the frags we would need for the current skb, who will
> > call the virtqueue_get_buf() to flush the remaining frags ?
> > 
> > Don't we also need to call virtqueue_get_buf() like 
> > 
> > while (--num_buf) {
> >     buf = virtqueue_get_buf(rq->vq, &len);
> >     if (!buf)
> >         break;
> >     put_page(virt_to_head_page(buf));
> > }
> > 
> > ?
> > 
> > 
> 
> 
> Let me explain what worries me in your suggestion:
> 
>                         struct sk_buff *nskb = alloc_skb(0, GFP_ATOMIC);
>                         if (unlikely(!nskb)) {
>                                 head_skb->dev->stats.rx_dropped++;
>                                 return -ENOMEM;
>                         }
> 
> is this the failure case we are talking about?

I thought Jason patch was about this, no ?

> 
> I think this is a symprom of a larger problem
> introduced by 2613af0ed18a11d5c566a81f9a6510b73180660a,
> namely that we now need to allocate memory in the
> middle of processing a packet.
> 
> 
> I think discarding a completely valid and well-formed
> packet from the receive queue because we are unable
> to allocate new memory with GFP_ATOMIC
> for future packets is not a good idea.

How is it different with NIC processing in RX path ?

> 
> It certainly violates the principle of least surprize:
> when one sees host pass packet to guest, one expects
> the packet to get into the networking stack, not get
> dropped by the driver internally.
> Guest stack can do with the packet what it sees fit.
> 
> We actually wake up a thread if we can't fill up the queue,
> that will fill it up in GFP_KERNEL context.
> 
> So I think we should find a way to pre-allocate if necessary and avoid
> error paths where allocating new memory is a required to avoid drops.
> 

Really, under ATOMIC context, there is no way you can avoid dropping
packets if you cannot allocate memory. If you cannot allocate sk_buff
(256 bytes !!), you wont be able to allocate the 1500+ bytes to hold the
payload of next packets anyway. 

Same problem on a real NIC.

Under memory pressure we _do_ packet drops.
Nobody really complained.

Sure, you can add yet another cache of pre-allocated skbs and pay the
price of managing yet another cache layer, but still need to trop
packets under stress.

Pre-allocating skb on real NIC has a performance cost, because we clear
sk_buff way ahead of time. By the time skb is finally received, cpu has
to bring back into its cache memory cache lines.
