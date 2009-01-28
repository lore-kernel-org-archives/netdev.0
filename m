From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Wed, 28 Jan 2009 10:48:28 -0700
Message-ID: <1233164908.7026.195.camel@lappy>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <200901271300.30330.rusty@rustcorp.com.au>
	 <1233027482.7148.42.camel@2710p.home>
	 <200901282115.14083.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:29582 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbZA1Rrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 12:47:53 -0500
In-Reply-To: <200901282115.14083.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

On Wed, 2009-01-28 at 21:15 +1030, Rusty Russell wrote:
> On Tuesday 27 January 2009 14:08:02 Alex Williamson wrote:
> > Hi Rusty,
> > 
> > On Tue, 2009-01-27 at 13:00 +1030, Rusty Russell wrote:
> > > On Saturday 17 January 2009 07:43:34 Alex Williamson wrote:
> > > > As with most real hardware, unicast addresses have priority in
> > > 
> > > > the filter table so we can avoid enabling full promiscuous
> > > 
> > > > until both unicast and multicast address overflow.
> > > 
> > > Why not pretend to have infinite, and have the host turn promisc on
> > > when *it*
> > > 
> > > decides? Skip the alloc call, and just use a feature bit like
> > > everything else?
> > 
> > I suppose it's just a matter of where do you want to add the smarts and
> > the tune-ability.  Since we can't actually have an infinite table and an
> > array implementation seems to make sense from an efficiency standpoint,
> > it needs to be defined by someone to be a fixed size before we start
> > using it.  I was hoping the guest driver might have a better idea how it
> > plans to use the filter table and that there'd be some benefit to having
> > that handshake happen between the driver and the backend.  The module
> > parameter fell out of this and seems rather convenient.
> > 
> > I could pursue this is you like, but I'm not sure of the benefit,
> > particularly if we want to give the user some control of the size of the
> > actual table.  Thoughts?  Thanks for the comments,
> 
> I don't think the either-or case is real.  Say the user decides they
> want a table of 1000000 entries.  And the backend says "no way, I have
> a 16 array"?  Currently you get nothing.

Ok, I think I see what you're getting at.  Linux can handle that, but
other OSes may not...

> I guess your qemu code does dynamic allocation.  But I'm sure you put
> a limit in there, right? :)

Right, it allocates the table only when the alloc call is made.  The
limit is currently what will fit in a host page size, which is perhaps a
little arbitrary, but I had some FUD about multi-page sg lists.  The
resulting 682 entry (on 4k) limit seemed sufficiently large.

> We don't want some complex negotiation, and I don't think the guest
> has any more clue than the host, nor can do much about it.

For a typical Linux guest, I agree, and I would guess that most users
won't know or care about the module option to specify the size, nor
should qemu ever balk at allocating the default size Linux requests.
However, I also know of a more embedded, proprietary OS that lives in a
fairly rigid network environment and does have a specific number of
entries they're looking for.  Other OSes might have different numbers.

Here's what I believe to be the parameters around which I've designed
the current interface:

     A. Receiving unwanted packets is a waste of resources.
     B. Proprietary OSes may have dependencies on hardware filtering and
        may not be able to handle unwanted packets.
     C. Different guests may want different filter table sizes.
     D. The guest can make better decisions than the host about what
        packets are unwanted.

>From this, I derive that the guest needs to know the size of the filter
table, needs to be able to specify the size of the filter table, and is
in the best position to program the filter table.  A pseudo-infinite
table violates the condition of not sending the guest unwanted packets.
We could also go down the path of deciding what a "big enough" table is,
and making it part of the ABI to avoid the alloc, but then we may have
to revise the ABI if we underestimate (whereas the current limit is an
implementation detail).

Weaving in your comments from other parts of this series, would it help
at all to distinguish EINVAL from ENOMEM for the alloc call?  Maybe the
caller could make some kind of intelligent decision based on that (ex.
unimplemented feature vs try something smaller).  Thanks for the
comments,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

