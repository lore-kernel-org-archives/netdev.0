From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC 3/3] virtio_net: limit xmit polling
Date: Thu, 2 Jun 2011 16:34:25 +0300
Message-ID: <20110602133425.GJ7141@redhat.com>
References: <cover.1306921434.git.mst@redhat.com>
	<1ec8eec325839ecf2eac9930a230361e7956047c.1306921434.git.mst@redhat.com>
	<87pqmwj3am.fsf@rustcorp.com.au>
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
In-Reply-To: <87pqmwj3am.fsf-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
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

On Thu, Jun 02, 2011 at 01:24:57PM +0930, Rusty Russell wrote:
> On Wed, 1 Jun 2011 12:50:03 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > Current code might introduce a lot of latency variation
> > if there are many pending bufs at the time we
> > attempt to transmit a new one. This is bad for
> > real-time applications and can't be good for TCP either.
> > 
> > Free up just enough to both clean up all buffers
> > eventually and to be able to xmit the next packet.
> 
> OK, I found this quite confusing to read.
> 
> > -	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> > +	while ((r = virtqueue_min_capacity(vi->svq) < MAX_SKB_FRAGS + 2) ||
> > +	       min_skbs-- > 0) {
> > +		skb = virtqueue_get_buf(vi->svq, &len);
> > +		if (unlikely(!skb))
> > +			break;
> >  		pr_debug("Sent skb %p\n", skb);
> >  		vi->dev->stats.tx_bytes += skb->len;
> >  		vi->dev->stats.tx_packets++;
> >  		dev_kfree_skb_any(skb);
> >  	}
> > +	return r;
> >  }
> 
> Gah... what a horrible loop.
> 
> Basically, this patch makes hard-to-read code worse, and we should try
> to make it better.
> 
> Currently, xmit *can* fail when an xmit interrupt wakes the queue, but
> the packet(s) xmitted didn't free up enough space for the new packet.
> With indirect buffers this only happens if we hit OOM (and thus go to
> direct buffers).
> 
> We could solve this by only waking the queue in skb_xmit_done if the
> capacity is >= 2 + MAX_SKB_FRAGS.  But can we do it without a race?

I don't think so.

> If not, then I'd really prefer to see this, because I think it's clearer:
> 
>         // Try to free 2 buffers for every 1 xmit, to stay ahead.
>         free_old_buffers(2)
> 
>         if (!add_buf()) {
>                 // Screw latency, free them all.
>                 free_old_buffers(UINT_MAX)
>                 // OK, this can happen if we are using direct buffers,
>                 // and the xmit interrupt woke us but the packets
>                 // xmitted were smaller than this one.  Rare though.
>                 if (!add_buf())
>                         Whinge and stop queue, maybe loop.
>         }
> 
>         if (capacity < 2 + MAX_SKB_FRAGS) {
>                 // We don't have enough for the next packet?  Try
>                 // freeing more.
>                 free_old_buffers(UINT_MAX);
>                 if (capacity < 2 + MAX_SKB_FRAGS) {
>                         Stop queue, maybe loop.
>         }
> 
> The current code makes my head hurt :(
> 
> Thoughts?
> Rusty.

OK, I have something very similar, but I still dislike the screw the
latency part: this path is exactly what the IBM guys seem to hit.  So I
created two functions: one tries to free a constant number and another
one up to capacity. I'll post that now.


-- 
MST
