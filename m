From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC v2] ptr_ring: add ptr_ring_unconsume
Date: Tue, 9 May 2017 16:26:53 +0300
Message-ID: <20170509162622-mutt-send-email-mst@kernel.org>
References: <1493049492-3229-1-git-send-email-mst@redhat.com>
 <ce6e1816-e3e0-4e6b-b017-05cfc54a0170@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ce6e1816-e3e0-4e6b-b017-05cfc54a0170@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2017 at 05:09:42PM +0800, Jason Wang wrote:
> 
> 
> On 2017年04月25日 00:01, Michael S. Tsirkin wrote:
> > Applications that consume a batch of entries in one go
> > can benefit from ability to return some of them back
> > into the ring.
> > 
> > Add an API for that - assuming there's space. If there's no space
> > naturally can't do this and have to drop entries, but this implies ring
> > is full so we'd likely drop some anyway.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> > 
> > Jason, if you add this and unconsume the outstanding packets
> > on backend disconnect, vhost close and reset, I think
> > we should apply your patch even if we don't yet know 100%
> > why it helps.
> > 
> > changes from v1:
> > - fix up coding style issues reported by Sergei Shtylyov
> > 
> > 
> >   include/linux/ptr_ring.h | 56 ++++++++++++++++++++++++++++++++++++++++++++++++
> >   1 file changed, 56 insertions(+)
> > 
> > diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
> > index 783e7f5..902afc2 100644
> > --- a/include/linux/ptr_ring.h
> > +++ b/include/linux/ptr_ring.h
> > @@ -457,6 +457,62 @@ static inline int ptr_ring_init(struct ptr_ring *r, int size, gfp_t gfp)
> >   	return 0;
> >   }
> > +/*
> > + * Return entries into ring. Destroy entries that don't fit.
> > + *
> > + * Note: this is expected to be a rare slow path operation.
> > + *
> > + * Note: producer lock is nested within consumer lock, so if you
> > + * resize you must make sure all uses nest correctly.
> > + * In particular if you consume ring in interrupt or BH context, you must
> > + * disable interrupts/BH when doing so.
> > + */
> > +static inline void ptr_ring_unconsume(struct ptr_ring *r, void **batch, int n,
> > +				      void (*destroy)(void *))
> > +{
> > +	unsigned long flags;
> > +	int head;
> > +
> > +	spin_lock_irqsave(&r->consumer_lock, flags);
> > +	spin_lock(&r->producer_lock);
> > +
> > +	if (!r->size)
> > +		goto done;
> > +
> > +	/*
> > +	 * Clean out buffered entries (for simplicity). This way following code
> > +	 * can test entries for NULL and if not assume they are valid.
> > +	 */
> > +	head = r->consumer_head - 1;
> > +	while (likely(head >= r->consumer_tail))
> > +		r->queue[head--] = NULL;
> > +	r->consumer_tail = r->consumer_head;
> > +
> > +	/*
> > +	 * Go over entries in batch, start moving head back and copy entries.
> > +	 * Stop when we run into previously unconsumed entries.
> > +	 */
> > +	while (n--) {
> > +		head = r->consumer_head - 1;
> > +		if (head < 0)
> > +			head = r->size - 1;
> > +		if (r->queue[head]) {
> > +			/* This batch entry will have to be destroyed. */
> > +			++n;
> > +			goto done;
> > +		}
> > +		r->queue[head] = batch[n];
> > +		r->consumer_tail = r->consumer_head = head;
> 
> Looks like something wrong here (bad page state reported), uncomment the
> above while() solving the issue. But after staring it for a while I didn't
> find anything interesting, maybe you have some idea on this?
> 
> Thanks
> 
> 
> > +	}
> > +
> > +done:
> > +	/* Destroy all entries left in the batch. */
> > +	while (n--)
> > +		destroy(batch[n]);
> > +	spin_unlock(&r->producer_lock);
> > +	spin_unlock_irqrestore(&r->consumer_lock, flags);
> > +}
> > +
> >   static inline void **__ptr_ring_swap_queue(struct ptr_ring *r, void **queue,
> >   					   int size, gfp_t gfp,
> >   					   void (*destroy)(void *))

What's our plan here? I can't delay pull request much longer.
