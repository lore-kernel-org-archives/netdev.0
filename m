From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Thu, 29 Jan 2009 10:25:46 +1030
Message-ID: <200901291025.46887.rusty@rustcorp.com.au>
References: <20090116211312.22836.34331.stgit@debian.lart> <200901282115.14083.rusty@rustcorp.com.au> <1233164908.7026.195.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36975 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759972AbZA1Xzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2009 18:55:54 -0500
In-Reply-To: <1233164908.7026.195.camel@lappy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 January 2009 04:18:28 Alex Williamson wrote:
> Hi Rusty,

Hi Alex,

   I've cc'd Herbert: he always has good thoughts about this kind of thing and I want to be sure you're getting a fair hearing.

> Here's what I believe to be the parameters around which I've designed
> the current interface:
> 
>      A. Receiving unwanted packets is a waste of resources.
>      B. Proprietary OSes may have dependencies on hardware filtering and
>         may not be able to handle unwanted packets.
>      C. Different guests may want different filter table sizes.
>      D. The guest can make better decisions than the host about what
>         packets are unwanted.

A general OS has to handle the "unwanted packets" case if the NIC's table isn't big enough.  A guest may want arbitrary filter table sizes, but you're not giving it to them anyway, so that argument is bogus too.

The host *has* to decide the max table size, the guest *doesn't*.  Your implementation is the worst of both worlds.  The host doesn't tell the guest what the limit is, but does fail it for exceeding it.  Your guest implementation limits itself arbitrarily, but you feel better because you've invoked yet-another party (the admin of the user box) to fix it!

And there's no evidence whatsoever that the guest can do anything rational if it hits the filtering limit that the host can't do.

> >From this, I derive that the guest needs to know the size of the filter
> table, needs to be able to specify the size of the filter table, and is
> in the best position to program the filter table.  A pseudo-infinite
> table violates the condition of not sending the guest unwanted packets.

I'm not aware of any OS which doesn't filter this anyway, but I'm not familiar with the Windows stack.  I'd be very surprised though, since multicast filtering is often implemented as a hash on the card.

> We could also go down the path of deciding what a "big enough" table is,
> and making it part of the ABI to avoid the alloc, but then we may have
> to revise the ABI if we underestimate (whereas the current limit is an
> implementation detail).

OK, say the host bonds a NIC directly to the virtio nic for the guest.  That NIC uses a hash to filter MAC addresses.  In your scheme, you have numerous problems:
(1) we've defined filtering to be perfect, so we need to filter in the host,
(2) the guest will stop giving us filtering information after 16 entries, and
    tell us to go into promisc mode, even though we could do better.

> Weaving in your comments from other parts of this series, would it help
> at all to distinguish EINVAL from ENOMEM for the alloc call?  Maybe the
> caller could make some kind of intelligent decision based on that (ex.
> unimplemented feature vs try something smaller).

None of the currently defined calls should fail.  Feature bits should guarantee the existence of features, and failure should be greeted with horror by the guest, which should then try to limp along.

So, this conversation has convinced me that the host should accept arbitrary filtering entries, and the guest should accept that it is best effort.

Cheers,
Rusty.
