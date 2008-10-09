From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] virtio_net: Improve the recv buffer allocation
	scheme
Date: Thu, 9 Oct 2008 23:30:35 +0800
Message-ID: <20081009153035.GA21542@gondor.apana.org.au>
References: <1223494499-18732-1-git-send-email-markmc@redhat.com> <1223494499-18732-2-git-send-email-markmc@redhat.com> <200810091155.59731.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark McLoughlin <markmc@redhat.com>, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35682 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758446AbYJIPas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 11:30:48 -0400
Content-Disposition: inline
In-Reply-To: <200810091155.59731.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 11:55:59AM +1100, Rusty Russell wrote:
>
> There are three approaches we should investigate before adding YA feature.  
> Obviously, we can simply increase the number of ring entries.

That's not going to work so well as you need to increase the ring
size by MAX_SKB_FRAGS times to achieve the same level of effect.

Basically the current scheme is either going to suck at non-TSO
traffic or it's going to chew too much resources.

> Secondly, we can put the virtio_net_hdr at the head of the skb data (this is 
> also worth considering for xmit I think if we have headroom) and drop 
> MAX_SKB_FRAGS which contains a gratuitous +2.

That's fine but having skb->data in the ring still means two
different kinds of memory in there and it sucks when you only
have 1500-byte packets.

> Thirdly, we can try to coalesce contiguous buffers.  The page caching scheme 
> we have might help here, I don't know.  Maybe we should be explicitly trying 
> to allocate higher orders.

That's not really the key problem here.  The problem here is
that the scheme we're currently using in virtio-net is simply
broken when it comes to 1500-byte sized packets.  Most of the
entries on the ring buffer go to waste.

We need a scheme that handles both 1500-byte packets as well
as 64K-byte size ones, and without holding down 16M of memory
per guest.

> > The size of the logical buffer is
> > returned to the guest rather than the size of the individual smaller
> > buffers.
> 
> That's a virtio transport breakage: can you use the standard virtio mechanism, 
> just put the extended length or number of extra buffers inside the 
> virtio_net_hdr?

Sure that sounds reasonable.

> > Make use of this support by supplying single page receive buffers to
> > the host. On receive, we extract the virtio_net_hdr, copy 128 bytes of
> > the payload to the skb's linear data buffer and adjust the fragment
> > offset to point to the remaining data. This ensures proper alignment
> > and allows us to not use any paged data for small packets. If the
> > payload occupies multiple pages, we simply append those pages as
> > fragments and free the associated skbs.
> 
> > +		char *p = page_address(skb_shinfo(skb)->frags[0].page);
> ...
> > +		memcpy(hdr, p, sizeof(*hdr));
> > +		p += sizeof(*hdr);
> 
> I think you need kmap_atomic() here to access the page.  And yes, that will 
> effect performance :(

No we don't.  kmap would only be necessary for highmem which we
did not request.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
