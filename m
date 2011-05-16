From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH 09/18] virtio: use avail_event index
Date: Mon, 16 May 2011 16:42:21 +0930
Message-ID: <87ei3zdsq2.fsf@rustcorp.com.au>
References: <cover.1304541918.git.mst@redhat.com>
	<8bba6a0a8eee17e741c5155b04ff1b1c9f34bf94.1304541919.git.mst@redhat.com>
	<874o54h4rt.fsf@rustcorp.com.au>
	<20110515135541.GF24932@redhat.com>
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
In-Reply-To: <20110515135541.GF24932-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Sun, 15 May 2011 16:55:41 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, May 09, 2011 at 02:03:26PM +0930, Rusty Russell wrote:
> > On Wed, 4 May 2011 23:51:47 +0300, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > Use the new avail_event feature to reduce the number
> > > of exits from the guest.
> > 
> > Figures here would be nice :)
> 
> You mean ASCII art in comments?

I mean benchmarks of some kind.

> 
> > > @@ -228,6 +237,12 @@ add_head:
> > >  	 * new available array entries. */
> > >  	virtio_wmb();
> > >  	vq->vring.avail->idx++;
> > > +	/* If the driver never bothers to kick in a very long while,
> > > +	 * avail index might wrap around. If that happens, invalidate
> > > +	 * kicked_avail index we stored. TODO: make sure all drivers
> > > +	 * kick at least once in 2^16 and remove this. */
> > > +	if (unlikely(vq->vring.avail->idx == vq->kicked_avail))
> > > +		vq->kicked_avail_valid = true;
> > 
> > If they don't, they're already buggy.  Simply do:
> >         WARN_ON(vq->vring.avail->idx == vq->kicked_avail);
> 
> Hmm, but does it say that somewhere?

AFAICT it's a corollary of:
1) You have a finite ring of size <= 2^16.
2) You need to kick the other side once you've done some work.

> > > @@ -482,6 +517,8 @@ void vring_transport_features(struct virtio_device *vdev)
> > >  			break;
> > >  		case VIRTIO_RING_F_USED_EVENT_IDX:
> > >  			break;
> > > +		case VIRTIO_RING_F_AVAIL_EVENT_IDX:
> > > +			break;
> > >  		default:
> > >  			/* We don't understand this bit. */
> > >  			clear_bit(i, vdev->features);
> > 
> > Does this belong in a prior patch?
> > 
> > Thanks,
> > Rusty.
> 
> Well if we don't support the feature in the ring we should not
> ack the feature, right?

Ah, you're right.

Thanks,
Rusty.
