From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 10/14] virtio_net: limit xmit polling
Date: Mon, 23 May 2011 14:19:00 +0300
Message-ID: <20110523111900.GB27212@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
	<aced8619c07018b5495f9ceb2c02d4fbf897a098.1305846412.git.mst@redhat.com>
	<877h9kvlps.fsf@rustcorp.com.au>
	<20110522121008.GA12155@redhat.com>
	<87boyutbjg.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87boyutbjg.fsf-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
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

On Mon, May 23, 2011 at 11:37:15AM +0930, Rusty Russell wrote:
> On Sun, 22 May 2011 15:10:08 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Sat, May 21, 2011 at 11:49:59AM +0930, Rusty Russell wrote:
> > > On Fri, 20 May 2011 02:11:56 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > Current code might introduce a lot of latency variation
> > > > if there are many pending bufs at the time we
> > > > attempt to transmit a new one. This is bad for
> > > > real-time applications and can't be good for TCP either.
> > > 
> > > Do we have more than speculation to back that up, BTW?
> > 
> > Need to dig this up: I thought we saw some reports of this on the list?
> 
> I think so too, but a reference needs to be here too.
> 
> It helps to have exact benchmarks on what's being tested, otherwise we
> risk unexpected interaction with the other optimization patches.
> 
> > > >  	struct sk_buff *skb;
> > > >  	unsigned int len;
> > > > -
> > > > -	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> > > > +	bool c;
> > > > +	int n;
> > > > +
> > > > +	/* We try to free up at least 2 skbs per one sent, so that we'll get
> > > > +	 * all of the memory back if they are used fast enough. */
> > > > +	for (n = 0;
> > > > +	     ((c = virtqueue_get_capacity(vi->svq) < capacity) || n < 2) &&
> > > > +	     ((skb = virtqueue_get_buf(vi->svq, &len)));
> > > > +	     ++n) {
> > > >  		pr_debug("Sent skb %p\n", skb);
> > > >  		vi->dev->stats.tx_bytes += skb->len;
> > > >  		vi->dev->stats.tx_packets++;
> > > >  		dev_kfree_skb_any(skb);
> > > >  	}
> > > > +	return !c;
> > > 
> > > This is for() abuse :)
> > > 
> > > Why is the capacity check in there at all?  Surely it's simpler to try
> > > to free 2 skbs each time around?
> > 
> > This is in case we can't use indirect: we want to free up
> > enough buffers for the following add_buf to succeed.
> 
> Sure, or we could just count the frags of the skb we're taking out,
> which would be accurate for both cases and far more intuitive.
> 
> ie. always try to free up twice as much as we're about to put in.
> 
> Can we hit problems with OOM?  Sure, but no worse than now...
> The problem is that this "virtqueue_get_capacity()" returns the worst
> case, not the normal case.  So using it is deceptive.
> 

Maybe just document this?

I still believe capacity really needs to be decided
at the virtqueue level, not in the driver.
E.g. with indirect each skb uses a single entry: freeing
1 small skb is always enough to have space for a large one.

I do understand how it seems a waste to leave direct space
in the ring while we might in practice have space
due to indirect. Didn't come up with a nice way to
solve this yet - but 'no worse than now :)'

> > I just wanted to localize the 2+MAX_SKB_FRAGS logic that tries to make
> > sure we have enough space in the buffer. Another way to do
> > that is with a define :).
> 
> To do this properly, we should really be using the actual number of sg
> elements needed, but we'd have to do most of xmit_skb beforehand so we
> know how many.
> 
> Cheers,
> Rusty.

Maybe I'm confused here.  The problem isn't the failing
add_buf for the given skb IIUC.  What we are trying to do here is stop
the queue *before xmit_skb fails*. We can't look at the
number of fragments in the current skb - the next one can be
much larger.  That's why we check capacity after xmit_skb,
not before it, right?

-- 
MST
