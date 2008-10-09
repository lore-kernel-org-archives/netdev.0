From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: Improve the recv buffer allocation
	scheme
Date: Thu, 09 Oct 2008 18:40:13 +0100
Message-ID: <1223574013.13792.23.camel@blaa>
References: <1223494499-18732-1-git-send-email-markmc@redhat.com>
	 <1223494499-18732-2-git-send-email-markmc@redhat.com>
	 <200810091155.59731.rusty@rustcorp.com.au>
	 <20081009153035.GA21542@gondor.apana.org.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56180 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754733AbYJIRlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 13:41:15 -0400
In-Reply-To: <20081009153035.GA21542@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-09 at 23:30 +0800, Herbert Xu wrote: 
> On Thu, Oct 09, 2008 at 11:55:59AM +1100, Rusty Russell wrote:
> >
> > There are three approaches we should investigate before adding YA feature.  
> > Obviously, we can simply increase the number of ring entries.
> 
> That's not going to work so well as you need to increase the ring
> size by MAX_SKB_FRAGS times to achieve the same level of effect.
> 
> Basically the current scheme is either going to suck at non-TSO
> traffic or it's going to chew too much resources.

Yeah ... to put some numbers on it, assume we have a 256 entry ring now.

Currently, with GSO enabled in the host the guest will fill this with 12
buffer heads with 20 buffers per head (a 10 byte buffer, an MTU sized
buffer and 18 page sized buffers).

That means we allocate ~900k for receive buffers, 12k for the ring, fail
to use 16 ring entries and the ring ends up with a capacity of 12
packets. In the case of MTU sized packets from an off-host source,
that's a huge amount of overhead for ~17k of data.

If we wanted to match the packet capacity that Herbert's suggestion
enables (i.e. 256 packets), we'd need to bump the ring size to 4k
entries (assuming we reduce it to 19 entries per packet). This would
mean we'd need to allocate ~200k for the ring and ~18M in receive
buffers. Again, assuming MTU sized packets, that's massive overhead for
~400k of data.

> > Secondly, we can put the virtio_net_hdr at the head of the skb data (this is 
> > also worth considering for xmit I think if we have headroom) and drop 
> > MAX_SKB_FRAGS which contains a gratuitous +2.
> 
> That's fine but having skb->data in the ring still means two
> different kinds of memory in there and it sucks when you only
> have 1500-byte packets.

Also, including virtio_net_hdr in the data buffer would need another
feature flag. Rightly or wrongly, KVM's implementation requires
virtio_net_hdr to be the first buffer:

    if (elem.in_num < 1 || elem.in_sg[0].iov_len != sizeof(*hdr)) {
        fprintf(stderr, "virtio-net header not in first element\n");
        exit(1);
    }

i.e. it's part of the ABI ... at least as KVM sees it :-)

> > > The size of the logical buffer is
> > > returned to the guest rather than the size of the individual smaller
> > > buffers.
> > 
> > That's a virtio transport breakage: can you use the standard virtio mechanism, 
> > just put the extended length or number of extra buffers inside the 
> > virtio_net_hdr?
> 
> Sure that sounds reasonable.


I'll give that a shot.

Cheers,
Mark.

