From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] virtio_net: Improve the recv buffer allocation scheme
Date: Thu, 16 Oct 2008 15:43:38 +1100
Message-ID: <200810161543.39812.rusty@rustcorp.com.au>
References: <1223494499-18732-1-git-send-email-markmc@redhat.com> <200810091155.59731.rusty@rustcorp.com.au> <20081009153035.GA21542@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	Anthony Liguori <aliguori@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56252 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbYJPEoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 00:44:10 -0400
In-Reply-To: <20081009153035.GA21542@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 10 October 2008 02:30:35 Herbert Xu wrote:
> On Thu, Oct 09, 2008 at 11:55:59AM +1100, Rusty Russell wrote:
> > Secondly, we can put the virtio_net_hdr at the head of the skb data (this
> > is also worth considering for xmit I think if we have headroom) and drop
> > MAX_SKB_FRAGS which contains a gratuitous +2.
>
> That's fine but having skb->data in the ring still means two
> different kinds of memory in there and it sucks when you only
> have 1500-byte packets.

No, you really want to do this for 1500 byte packets since it increases the 
effective space in the ring.  Unfortunately, Mark points out that kvm assumes 
the header is standalone: Anthony and I discussed this a while back and 
decided it *wasn't* a good assumption.

TODO: YA feature bit...

> We need a scheme that handles both 1500-byte packets as well
> as 64K-byte size ones, and without holding down 16M of memory
> per guest.

Ah, thanks for that.  It's not so much ring entries, as guest memory you're 
trying to save.  That makes much more sense.

> > > +		char *p = page_address(skb_shinfo(skb)->frags[0].page);
> >
> > ...
> >
> > > +		memcpy(hdr, p, sizeof(*hdr));
> > > +		p += sizeof(*hdr);
> >
> > I think you need kmap_atomic() here to access the page.  And yes, that
> > will effect performance :(
>
> No we don't.  kmap would only be necessary for highmem which we
> did not request.

Good point.  Could you humor me with a comment to that effect?  Prevents me 
making the same mistake again.

Thanks!
Rusty.
PS.  Laptop broke, was MIA for a week.  Working overtime now.
