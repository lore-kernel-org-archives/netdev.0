From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Fri, 8 Apr 2016 21:05:17 +0200
Message-ID: <20160408210517.5e4e49d1@redhat.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
	<20160408123614.2a15a346@redhat.com>
	<20160408143340.10e5b1d0@redhat.com>
	<20160408170159.GC28353@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758763AbcDHTF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 15:05:26 -0400
In-Reply-To: <20160408170159.GC28353@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Apr 2016 10:02:00 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> On Fri, Apr 08, 2016 at 02:33:40PM +0200, Jesper Dangaard Brouer wrote:
> > 
> > On Fri, 8 Apr 2016 12:36:14 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >   
> > > > +/* user return codes for PHYS_DEV prog type */
> > > > +enum bpf_phys_dev_action {
> > > > +	BPF_PHYS_DEV_DROP,
> > > > +	BPF_PHYS_DEV_OK,
> > > > +};    
> > > 
> > > I can imagine these extra return codes:
> > > 
> > >  BPF_PHYS_DEV_MODIFIED,   /* Packet page/payload modified */
> > >  BPF_PHYS_DEV_STOLEN,     /* E.g. forward use-case */
> > >  BPF_PHYS_DEV_SHARED,     /* Queue for async processing, e.g. tcpdump use-case */
> > > 
> > > The "STOLEN" and "SHARED" use-cases require some refcnt manipulations,
> > > which we can look at when we get that far...  
> > 
> > I want to point out something which is quite FUNDAMENTAL, for
> > understanding these return codes (and network stack).
> > 
> > 
> > At driver RX time, the network stack basically have two ways of
> > building an SKB, which is send up the stack.
> > 
> > Option-A (fastest): The packet page is writable. The SKB can be
> > allocated and skb->data/head can point directly to the page.  And
> > we place/write skb_shared_info in the end/tail-room. (This is done by
> > calling build_skb()).
> > 
> > Option-B (slower): The packet page is read-only.  The SKB cannot point
> > skb->data/head directly to the page, because skb_shared_info need to be
> > written into skb->end (slightly hidden via skb_shinfo() casting).  To
> > get around this, a separate piece of memory is allocated (speedup by
> > __alloc_page_frag) for pointing skb->data/head, so skb_shared_info can
> > be written. (This is done when calling netdev/napi_alloc_skb()).
> >   Drivers then need to copy over packet headers, and assign + adjust
> > skb_shinfo(skb)->frags[0] offset to skip copied headers.
> > 
> > 
> > Unfortunately most drivers use option-B.  Due to cost of calling the
> > page allocator.  It is only slightly most expensive to get a larger
> > compound page from the page allocator, which then can be partitioned into
> > page-fragments, thus amortizing the page alloc cost.  Unfortunately the
> > cost is added later, when constructing the SKB.
> >  Another reason for option-B, is that archs with expensive IOMMU
> > requirements (like PowerPC), don't need to dma_unmap on every packet,
> > but only on the compound page level.
> > 
> > Side-note: Most drivers have a "copy-break" optimization.  Especially
> > for option-B, when copying header data anyhow. For small packet, one
> > might as well free (or recycle) the RX page, if header size fits into
> > the newly allocated memory (for skb_shared_info).
> > 
> > 
> > For the early filter drop (DDoS use-case), it does not matter that the
> > packet-page is read-only.
> > 
> > BUT for the future XDP (eXpress Data Path) use-case it does matter.  If
> > we ever want to see speeds comparable to DPDK, then drivers to
> > need to implement option-A, as this allow forwarding at the packet-page
> > level.
> > 
> > I hope, my future page-pool facility can remove/hide the cost calling
> > the page allocator.
> >   
> Can't wait! This will open up a lot of doors.
>

If you talk about the page-pool, then it is just once piece of the
puzzle, not the silver bullet ;-)

> > 
> > Back to the return codes, thus:
> > -------------------------------
> > BPF_PHYS_DEV_SHARED requires driver use option-B, when constructing
> > the SKB, and treat packet data as read-only.
> > 
> > BPF_PHYS_DEV_MODIFIED requires driver to provide a writable packet-page.  
>
> I understand the driver/hw requirement, but the codes themselves I think
> need some tweaking.

I'm very open to changing these return codes. I'm just trying to open
up the discussion.


> For instance, if the packet is both modified and forwarded, should
> the flags be ORed together? 

I didn't see these as bit-flags. I assumed that if you want to forward
the packet, then you need to steal it (BPF_PHYS_DEV_STOLEN) and cannot
return it to the stack.

I'm open to changing this to bit-flags, BUT we just have to take care
not to introduce too many things we need to check, due to performance
issues.


> Or is the need for this return code made obsolete if the driver knows
> ahead of time via struct bpf_prog flags that the prog intends to
> modify the packet, and can set up the page accordingly?

Yes, maybe we can drop the modified (BPF_PHYS_DEV_MODIFIED) return code.
I was just thinking this could be used to indicate if the checksum
would need to be recalculated.  If the usual checksum people don't
care, we should drop this indication.

Think about it performance wise... if we know the program _can_ modify
(but don't know if it did so), then we would have mark the SKB to the
stack as the checksum needed to be recalculated, always...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
