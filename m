From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 10/14] virtio_net: limit xmit polling
Date: Sat, 28 May 2011 23:02:04 +0300
Message-ID: <20110528200204.GB7046@redhat.com>
References: <cover.1305846412.git.mst@redhat.com>
	<aced8619c07018b5495f9ceb2c02d4fbf897a098.1305846412.git.mst@redhat.com>
	<877h9kvlps.fsf@rustcorp.com.au>
	<20110522121008.GA12155@redhat.com>
	<87boyutbjg.fsf@rustcorp.com.au>
	<20110523111900.GB27212@redhat.com>
	<8739k3k1fb.fsf@rustcorp.com.au>
	<20110525060759.GC26352@redhat.com>
	<87vcwyjg2w.fsf@rustcorp.com.au>
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
In-Reply-To: <87vcwyjg2w.fsf-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
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

On Thu, May 26, 2011 at 12:58:23PM +0930, Rusty Russell wrote:
> On Wed, 25 May 2011 09:07:59 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Wed, May 25, 2011 at 11:05:04AM +0930, Rusty Russell wrote:
> > Hmm I'm not sure I got it, need to think about this.
> > I'd like to go back and document how my design was supposed to work.
> > This really should have been in commit log or even a comment.
> > I thought we need a min, not a max.
> > We start with this:
> > 
> > 	while ((c = (virtqueue_get_capacity(vq) < 2 + MAX_SKB_FRAGS) &&
> > 		(skb = get_buf)))
> > 		kfree_skb(skb);
> > 	return !c;
> > 
> > This is clean and simple, right? And it's exactly asking for what we need.
> 
> No, I started from the other direction:
> 
>         for (i = 0; i < 2; i++) {
>                 skb = get_buf();
>                 if (!skb)
>                         break;
>                 kfree_skb(skb);
>         }
> 
> ie. free two packets for every one we're about to add.  For steady state
> that would work really well.

Sure, with indirect buffers, but if we
don't use indirect (and we discussed switching indirect off
dynamically in the past) this becomes harder to
be sure about. I think I understand why but
does not a simple capacity check make it more obvious?

>  Then we hit the case where the ring
> seems full after we do the add: at that point, screw latency, and just
> try to free all the buffers we can.

I see. But the code currently does this:

	for(..)
		get_buf
	add_buf
	if (capacity < max_sk_frags+2) {
		if (!enable_cb)
			for(..)
				get_buf
	}


In other words the second get_buf is only called
in the unlikely case of race condition.

So we'll need to add *another* call to get_buf.
Is it just me or is this becoming messy?

I was also be worried that we are adding more
"modes" to the code: high and low latency
depending on different speeds between host and guest,
which would be hard to trigger and test.
That's why I tried hard to make the code behave the
same all the time and free up just a bit more than
the minimum necessary.

> > on the normal path min == 2 so we're low latency but we keep ahead on
> > average. min == 0 for the "we're out of capacity, we may have to stop
> > the queue".
> > 
> > Does the above make sense at all?
> 
> It makes sense, but I think it's a classic case where incremental
> improvements aren't as good as starting from scratch.
> 
> Cheers,
> Rusty.

The only difference on good path seems an extra capacity check,
so I don't expect the difference will be testable, do you?

-- 
MST
