From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPSEC: tunnel breakage with out-of-order IPv4 fragments
Date: Wed, 16 Jul 2014 12:59:16 +0200
Message-ID: <20140716105916.GA5540@secunet.com>
References: <CAGugRbVWyTM2J0Fyw1Cq1byqfjZBy_EFLSShqVdzxYZmmUWK_g@mail.gmail.com>
 <20140711110035.GB6633@secunet.com>
 <CAGugRbWPOyWLrdiTqtScWi2JTKeyEEjOLRvDUqx20SG7uXifLw@mail.gmail.com>
 <20140714093345.GC6633@secunet.com>
 <CAGugRbWL8Orkobwt4FENyswLsm1jWLBMdr-WJ6mCBhVn-xGwXw@mail.gmail.com>
 <20140715091613.GD6633@secunet.com>
 <CAGugRbXgAqO_qJRemfaYMM6+WE+nRnfU0LK3DkpBpSOwOkcD0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35931 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756860AbaGPK7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 06:59:25 -0400
Content-Disposition: inline
In-Reply-To: <CAGugRbXgAqO_qJRemfaYMM6+WE+nRnfU0LK3DkpBpSOwOkcD0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 08:13:01AM -0400, Karl Heiss wrote:
> On Tue, Jul 15, 2014 at 5:16 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > On Mon, Jul 14, 2014 at 07:52:23AM -0400, Karl Heiss wrote:
> >> On Mon, Jul 14, 2014 at 5:33 AM, Steffen Klassert
> >> <steffen.klassert@secunet.com> wrote:
> >> >
> >> > Your tcpdump looks interesting. Is it possible that all your
> >> > fragmented packets have the id field set to 'id 0'? This should
> >> > be only the case if the DF flag is set on that packet, but this
> >> > is apparently not the case here. If all the fragmented packets
> >> > have id 0, it is not possible to determine the correct fragment
> >> > chain. If only one fragment gets lost, all further packets might
> >> > be reassembled wrong.
> >> >
> >>
> >> Yes, all fragments have 'id 0'.
> >>
> >> > When looking at the code, is seems that sctp sets the DF flag
> >> > on packets as the default. The IPsec encapsulation code copies
> >> > the DF bit from the inner header and sets 'id 0' in this case.
> >> > A first guess would be that someone removes the DF flag after
> >> > the IPsec encapsulation.
> >> >
> >> > Is the DF flag set on your inner sctp packets?
> >> >
> >>
> >> Yes, the inner packets have DF set, but the outer do not.
> >
> > So we need to find where the DF flag disappears.
> 
> I feel like we may be focusing on two different things.  I am more
> interested in figuring out why the receive side does not handle these
> packets gracefully.  I would assume that the missing/reordered
> fragments may not get reassembled correctly and would be dropped,
> which is OK.  However, it is when this event occurs and then every
> subsequent, correctly ordered, fragmented packet is dropped that I am
> concerned about.  While the sender may be in a broken state, the
> receiver should be consistent with receive behavior, agreed?

Ugh. No, not at all. The sender causes these problems on the receive
side by using 'id 0' on all fragments. The id field is used to
determine which fragments belong to which packet. The id must
be unique for each fragmented packet. I.e. all fragments of a
given packet must have the same id, fragments of other packets
must have different id values. If all fragmented packets have
the same id, they get reassembled in the order they arrive.
Say the second fragment of packet A gets lost, then the first
fragment of Packet A is reassembled with the second fragment
of packet B and so on. This leads to authentication failures
as you observe it.

> 
> >
> > Can you describe your usecase more precisely? Do you use
> > any additional tunnel like ipip/gre etc. or packet mangling?
> 
> I apologize, I did leave out one critical bit of information in that
> the sender is based on a RHEL 6.5 kernel with a backported 3.4.75 SCTP
> stack.  As for other mangling or anything else, the case is as
> straightforward as originally described.  I will try and see if I can
> find which combination of commits need to be removed to allow this
> case on the sending side.  I didn't think to elaborate on the sending
> side as I was solely concentrating on the receive aspect :(

Please try with unpatched kernels from kernel.org on the sender and
the receiver.
