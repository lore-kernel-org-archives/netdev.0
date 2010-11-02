From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: Fix queue full check
Date: Tue, 2 Nov 2010 18:17:30 +0200
Message-ID: <20101102161730.GA32311@redhat.com>
References: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com>
 <201010292017.25099.rusty@rustcorp.com.au>
 <OF30574F6E.113EC5F4-ON652577CB.0037DAB5-652577CB.003BACE8@in.ibm.com>
 <201010292158.40411.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, yvugenfi@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517Ab0KBQRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Nov 2010 12:17:42 -0400
Content-Disposition: inline
In-Reply-To: <201010292158.40411.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 09:58:40PM +1030, Rusty Russell wrote:
> On Fri, 29 Oct 2010 09:25:09 pm Krishna Kumar2 wrote:
> > Rusty Russell <rusty@rustcorp.com.au> wrote on 10/29/2010 03:17:24 PM:
> > 
> > > > Oct 17 10:22:40 localhost kernel: net eth0: Unexpected TX queue
> > failure: -28
> > > > Oct 17 10:28:22 localhost kernel: net eth0: Unexpected TX queue
> > failure: -28
> > > > Oct 17 10:35:58 localhost kernel: net eth0: Unexpected TX queue
> > failure: -28
> > > > Oct 17 10:41:06 localhost kernel: net eth0: Unexpected TX queue
> > failure: -28
> > > >
> > > > I initially changed the check from -ENOMEM to -ENOSPC, but
> > > > virtqueue_add_buf can return only -ENOSPC when it doesn't have
> > > > space for new request.  Patch removes redundant checks but
> > > > displays the failure errno.
> > > >
> > > > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > > > ---
> > > >  drivers/net/virtio_net.c |   15 ++++-----------
> > > >  1 file changed, 4 insertions(+), 11 deletions(-)
> > > >
> > > > diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
> > > > --- org/drivers/net/virtio_net.c   2010-10-11 10:20:02.000000000 +0530
> > > > +++ new/drivers/net/virtio_net.c   2010-10-21 17:37:45.000000000 +0530
> > > > @@ -570,17 +570,10 @@ static netdev_tx_t start_xmit(struct sk_
> > > >
> > > >     /* This can happen with OOM and indirect buffers. */
> > > >     if (unlikely(capacity < 0)) {
> > > > -      if (net_ratelimit()) {
> > > > -         if (likely(capacity == -ENOMEM)) {
> > > > -            dev_warn(&dev->dev,
> > > > -                "TX queue failure: out of memory\n");
> > > > -         } else {
> > > > -            dev->stats.tx_fifo_errors++;
> > > > -            dev_warn(&dev->dev,
> > > > -                "Unexpected TX queue failure: %d\n",
> > > > -                capacity);
> > > > -         }
> > > > -      }
> > > > +      if (net_ratelimit())
> > > > +         dev_warn(&dev->dev,
> > > > +             "TX queue failure (%d): out of memory\n",
> > > > +             capacity);
> > >
> > > Hold on... you were getting -ENOSPC, which shouldn't happen.  What makes
> > you
> > > think it's out of memory?
> > 
> > virtqueue_add_buf_gfp returns only -ENOSPC on failure, whether
> > direct or indirect descriptors are used, so isn't -ENOSPC
> > "expected"? (vring_add_indirect returns -ENOMEM on memory
> > failure, but that is masked out and we go direct which is
> > the failure point).
> 
> Ah, OK, gotchya.
> I'm not even sure the fallback to linear makes sense; if we're failing
> kmallocs we should probably just return -ENOMEM.  Would mean we can
> tell the difference between "out of space" (which should never happen
> since we stop the queue when we have < 2+MAX_SKB_FRAGS slots left)
> and this case.
> 
> Michael, what do you think?
> 
> Thanks,
> Rusty.

Let's make sure I understand the issue: we use indirect buffers
so we assume there's still a lot of place in the ring, then
allocation for the indirect fails and so we return -ENOSPC?

So first, I agree it's a bug.  But I am not sure killing the fallback
is such a good idea: recovering from add buf failure is hard
generally, we should try to accomodate if we can. Let's just fix
the return code for now?

And generally, we should be smarter: as long as the ring is almost
empty, and s/g list is short, it is a waste to use indirect buffers.
BTW we have had a FIXME there for a long while, I think Yan suggested
increasing that threshold to 3. Yan?

Further, maybe preallocating some memory for the indirect buffers might
be a good idea.

In short, lots of good ideas, let's start with the minimal patch that is
a good 2.6.37 candidate too. How about the following (untested)?

virtio: fix add_buf return code for OOM

add_buff returned ENOSPC on out of memory: this is a bug
as at leats virtio-net expects ENOMEM and handles it
specially. Fix that.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 1475ed6..0a89098 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -165,7 +165,7 @@ int virtqueue_add_buf_gfp(struct virtqueue *_vq,
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
 	unsigned int i, avail, uninitialized_var(prev);
-	int head;
+	int head = -ENOSPC;
 
 	START_USE(vq);
 
@@ -191,7 +191,7 @@ int virtqueue_add_buf_gfp(struct virtqueue *_vq,
 		if (out)
 			vq->notify(&vq->vq);
 		END_USE(vq);
-		return -ENOSPC;
+		return head;
 	}
 
 	/* We're about to use some buffers from the free list. */
-- 
MST
