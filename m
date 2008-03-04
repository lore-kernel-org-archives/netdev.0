From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] partial checksum and GSO support for tun/tap.
Date: Tue, 4 Mar 2008 12:02:16 +1100
Message-ID: <200803041202.17202.rusty@rustcorp.com.au>
References: <200801240107.38929.rusty@rustcorp.com.au> <200801240110.45178.rusty@rustcorp.com.au> <47ABEAF7.8020508@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.linux-foundation.org
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33152 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753495AbYCDBC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 20:02:59 -0500
In-Reply-To: <47ABEAF7.8020508@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 February 2008 16:39:03 Max Krasnyansky wrote:
> Rusty Russell wrote:
> > (Changes since last time: we how have explicit IFF_RECV_CSUM and
> > IFF_RECV_GSO bits, and some renaming of virtio_net hdr)
> >
> > We use the virtio_net_hdr: it is an ABI already and designed to
> > encapsulate such metadata as GSO and partial checksums.
> >
> > IFF_VIRTIO_HDR means you will write and read a 'struct virtio_net_hdr'
> > at the start of each packet.  You can always write packets with
> > partial checksum and gso to the tap device using this header.
> >
> > IFF_RECV_CSUM means you can handle reading packets with partial
> > checksums.  If IFF_RECV_GSO is also set, it means you can handle
> > reading (all types of) GSO packets.
> >
> > Note that there is no easy way to detect if these flags are supported:
> > see next patch.
>
> Again sorry for delay in replying. Here are my thoughts on this.
>
> I like the approach in general. Certainly the part that creates skbs out of
> the user-space pages looks good. And it's fits nicely into existing TUN
> driver model. However I actually wanted to change the model :). In
> particular I'm talking about "syscall per packet"
> After messing around with things like libe1000.sf.net I'd like to make
> TUN/TAP driver look more like modern nic's to the user-space. In other
> words I'm thinking about introducing RX and TX rings that the user-space
> can then mmap() and write/read packets descriptors to/from. That will saves
> the number of system calls that the user-space app needs to do. That by
> itself saves a lot of overhead, combined with the GSO it's be lightning
> fast.

The problem with this approach is that for what I'm doing, the packets aren't 
nicely arranged somewhere; they're in random process memory.

I thought about further abusing writev and readv to do multiple packets at 
once.  

> btw We had a long discussion with Eugeniy Polakov on mapping user-pages vs
> mmap()ing large kernel buffer and doing normal memcpy() (ie instead of
> copy_to/fromuser()) in the kernel. On small packets overhead of
> get_user_pages() eats up all the benefits. So we should think of some
> scheme that nicely combines the two. Kind of like "copy break" that latest
> net drivers do these days.

Yes, the threshold for copy should probably be set around 128 bytes.

> Also btw why call it VIRTIO ? For example I'm actually interested in
> speeding up tunning and general network apps. We have wireless basestation
> apps here that need to handle packets in user-space. Those kind things have
> nothing to with virtualization.

The structure is for virtio, I'm just borrowing it for tap because it's 
already there.  We could rename it and move it out to its own header, but if 
so we should do that before 2.6.25 is released.

Thanks!
Rusty.


>
> Max


