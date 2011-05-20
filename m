From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH 14/18] virtio: add api for delayed callbacks
Date: Fri, 20 May 2011 17:13:29 +0930
Message-ID: <87liy1vmu6.fsf@rustcorp.com.au>
References: <cover.1304541918.git.mst@redhat.com>
	<64d47c628b3fdc0ac156aed4be182933d8bcc0db.1304541919.git.mst@redhat.com>
	<871v08h0vm.fsf@rustcorp.com.au>
	<20110515124818.GD24932@redhat.com>
	<87boz3dsoe.fsf@rustcorp.com.au>
	<20110519072412.GA31253@redhat.com>
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
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110519072412.GA31253-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Thu, 19 May 2011 10:24:12 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, May 16, 2011 at 04:43:21PM +0930, Rusty Russell wrote:
> > On Sun, 15 May 2011 15:48:18 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > On Mon, May 09, 2011 at 03:27:33PM +0930, Rusty Russell wrote:
> > > > On Wed, 4 May 2011 23:52:33 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > > Add an API that tells the other side that callbacks
> > > > > should be delayed until a lot of work has been done.
> > > > > Implement using the new used_event feature.
> > > > 
> > > > Since you're going to add a capacity query anyway, why not add the
> > > > threshold argument here?
> > > 
> > > I thought that if we keep the API kind of generic
> > > there might be more of a chance that future transports
> > > will be able to implement it. For example, with an
> > > old host we can't commit to a specific index.
> > 
> > No, it's always a hint anyway: you can be notified before the threshold
> > is reached.  But best make it explicit I think.
> > 
> > Cheers,
> > Rusty.
> 
> 
> I tried doing that and remembered the real reason I went for this API:
> 
> capacity is limited by descriptor table space, not
> used ring space: each entry in the used ring frees up multiple entries
> in the descriptor ring. Thus the ring can't provide
> callback after capacity is N: capacity is only available
> after we get bufs.

I think this indicates a problem, but I haven't reviewed your patches
except very cursorily.  I am slack...

> We could try and make the API pass in the number of freed bufs, however:
> - this is not really what virtio-net cares about (it cares about
>   capacity)

Yes, max sg elements and max requests are separate, though in the
current virtio implementation remaining sg <= remaining request slots.

That's why we currently feed back remaining descriptors to the driver,
not the number of request slots.

This implies that the thresholds should refer to descriptor numbers
(ie. wake me when there are this many descriptors freed), not the used
ring at all.  Which means we're barking up the wrong tree...

I think this needs more thought.

> - if the driver passes a number > number of outstanding bufs, it will
>   never get a callback. So to stay correct the driver will need to
>   track number of outstanding requests. The simpler API avoids that. 

I think the driver should simply say "wake me when you have this many
descriptors free".  And set it during initialization, rather than every
time.  The virtio_ring code should handle it from there.

Perhaps that can be done with the current technique, where the
virtio_ring makes an educated guess on when sufficient capacity will be
available...

Cheers,
Rusty.
