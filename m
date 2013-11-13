From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Tue, 12 Nov 2013 23:40:58 -0800
Message-ID: <1384328458.28458.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
	<1384294885-6444-4-git-send-email-mwdalton@google.com>
	<528325DC.3050801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S.
	Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <528325DC.3050801@redhat.com>
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

On Wed, 2013-11-13 at 15:10 +0800, Jason Wang wrote:

> There's one concern with EWMA. How well does it handle multiple streams
> each with different packet size? E.g there may be two flows, one with
> 256 bytes each packet another is 64K.  Looks like it can result we
> allocate PAGE_SIZE buffer for 256 (which is bad since the
> payload/truesize is low) bytes or 1500+ for 64K buffer (which is ok
> since we can do coalescing).

It's hard to predict the future ;)

256 bytes frames consume 2.5 KB anyway on a traditional NIC.
If it was a concern, we would have it already.

If you receive a mix of big and small frames, there is no win.

> > +	if (page) {
> > +		est_buffer_len = page_private(page);
> > +		if (est_buffer_len > len) {
> > +			u32 truesize_delta = est_buffer_len - len;
> > +
> > +			curr_skb->truesize += truesize_delta;
> > +			if (curr_skb != head_skb)
> > +				head_skb->truesize += truesize_delta;
> > +		}
> 
> Is there a chance that est_buffer_len was smaller than or equal with len?

Yes, and in this case we do not really care, see below.

> > +	}
> > +	ewma_add(&rq->mrg_avg_pkt_len, head_skb->len);
> >  	return 0;
> >  }
> >  
> > @@ -382,16 +404,21 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
> >  		skb_trim(skb, len);
> >  	} else if (vi->mergeable_rx_bufs) {
> >  		struct page *page = virt_to_head_page(buf);
> > -		int truesize = max_t(int, len, MERGE_BUFFER_LEN);
> > +		/* Use an initial truesize of 'len' bytes for page_to_skb --
> > +		 * receive_mergeable will fixup the truesize of the last page
> > +		 * frag if the packet is non-linear (> GOOD_COPY_LEN bytes).
> > +		 */
> >  		skb = page_to_skb(rq, page,
> >  				  (char *)buf - (char *)page_address(page),
> > -				  len, truesize);
> > +				  len, len);
> >  		if (unlikely(!skb)) {
> >  			dev->stats.rx_dropped++;
> >  			put_page(page);
> >  			return;
> >  		}
> > -		if (receive_mergeable(rq, skb)) {
> > +		if (!skb_is_nonlinear(skb))
> > +			page = NULL;
> > +		if (receive_mergeable(rq, skb, page)) {
> >  			dev_kfree_skb(skb);
> >  			return;
> >  		}
> > @@ -540,24 +567,29 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
> >  static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
> >  {
> >  	struct virtnet_info *vi = rq->vq->vdev->priv;
> > +	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> >  	struct page_frag *alloc_frag;
> >  	char *buf;
> > -	int err, len, hole;
> > +	int err, hole;
> > +	u32 buflen;
> >  
> > +	buflen = hdr_len + clamp_t(u32, ewma_read(&rq->mrg_avg_pkt_len),
> > +				   GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
> > +	buflen = ALIGN(buflen, L1_CACHE_BYTES);
> >  	alloc_frag = (gfp & __GFP_WAIT) ? &vi->sleep_frag : &rq->atomic_frag;
> > -	if (unlikely(!skb_page_frag_refill(MERGE_BUFFER_LEN, alloc_frag, gfp)))
> > +	if (unlikely(!skb_page_frag_refill(buflen, alloc_frag, gfp)))
> >  		return -ENOMEM;
> >  	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
> >  	get_page(alloc_frag->page);
> > -	len = MERGE_BUFFER_LEN;
> > -	alloc_frag->offset += len;
> > +	alloc_frag->offset += buflen;
> > +	set_page_private(alloc_frag->page, buflen);
> 
> Not sure this is accurate, since buflen may change and several frags may
> share a single page. So the est_buffer_len we get in receive_mergeable()
> may not be the correct value.

skb->truesize has to be reasonably accurate. 

For example, fast clone storage is not accounted for in TCP skbs stored
in socket write queues. Thats ~256 bytes per skb of 'missing'
accounting.

This is about 10% error when TSO/GSO is off.

With this EWMA using a factor of 64, the potential error will be much
less than 10%.

Small frames tend to be consumed quite fast (ACK messages, small UDP
frames) in most cases.
