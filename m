From: Joseph Golio <golio@vieo.com>
Subject: Re: [Fwd: IPoIB]
Date: Thu, 06 Jun 2002 14:59:50 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CFFBF36.2BF8B884@vieo.com>
References: <Pine.GSO.4.05.10206062126130.19900-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jeff young <jsy@vieo.com>,
   gary klesk <gklesk@vieo.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
List-Id: netdev.vger.kernel.org

Thomas 'Dent' Mirlacher wrote:

> --snip/snip
>
> > The more I dig into this, the more I figure out that the
> > problem is larger than I though. Not only do I need to increase the size of a
> > hardware address, I also need to provide a new interface service routine to
> > allow the device driver to lookup/translate a portion of the hardware address
> > and return more information that needs to go into the ARP cache.
> >
> > Specifically, the IETF IPoIB group has defined an Infiniband hardware
> > address to have 1 byte of reserved, 3 bytes of Queue Pair Number (QPN) and
> > 16 bytes of Global Identifier (GID). Unfortunately, in order to build the
> > hardware header in packets to send, another piece of information is needed
> > -- that being the Local
> > Identifier (LID). If the LID is kept in the ARP cache, then it will be readily
> > available from "arp_find()" at the time of transmission.
>
> > If we don't do that, we would have to
> > have a separate table and mechanism in the driver to map from
> > QPN/GID ===> LID.
> > I would rather not do that if I didn't have to. It seems fundamental
> > (at least to me) that everything one needs to build the hardware header
> > (at least everything that is related
> > specifically to the destination) should be stored in the ARP cache.
>
> you can already do that, since you will save everything in the arp
> cache which is the size of dev->addr_len. - did i miss the point?

Either you missed the point, I didn't make the point, or I'm missing something...
:-)

Let me try this again. The IETF has defined the hardware address as having 2
fields.
The QPN and GID. Unfortunately, we need a 3rd item to build the headers. The LID.
The LID can be gotten by IBTA methods once we know the GID. So, implementations
that follow the IETF spec will be setting their local hardware address to their own

GID and some QPN. So, when I send out an ARP request and get back an ARP reply,
it will have QPN and GID. So, what get's stored in my local ARP cache, if I don't
do
anything to the ARP code, is simply the QPN/GID value. When I go to send a packet,
I will call arp_find() and get back the QPN/GID. What I really need is the LID. SO,

either I would have to translate QPN/GID to LID at that time (NOT GOOD), or, back
when the ARP reply came in, the ARP code could look at the arp_hrd and see if it's
 (32) ARPHRD_INFINIBAND and if it is, call an interface service routine to
suplement
the ARP info before storing it in the cache. I know, it's not pretty, but I'm
really struggling
here. If I were to do this in the driver, I would have to have some way of knowing
that the
ARP had completed so that I could then go out and translate the GID to LID and
stuff it
into a private driver lookup table (hashed probably). Not real crazy about that
idea...

Joe

>
>
> cheers,
>
>         tm
>
> --
> in some way i do, and in some way i don't.
