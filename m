From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPSEC: tunnel breakage with out-of-order IPv4 fragments
Date: Tue, 15 Jul 2014 11:16:13 +0200
Message-ID: <20140715091613.GD6633@secunet.com>
References: <CAGugRbVWyTM2J0Fyw1Cq1byqfjZBy_EFLSShqVdzxYZmmUWK_g@mail.gmail.com>
 <20140711110035.GB6633@secunet.com>
 <CAGugRbWPOyWLrdiTqtScWi2JTKeyEEjOLRvDUqx20SG7uXifLw@mail.gmail.com>
 <20140714093345.GC6633@secunet.com>
 <CAGugRbWL8Orkobwt4FENyswLsm1jWLBMdr-WJ6mCBhVn-xGwXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44760 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757540AbaGOJQW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 05:16:22 -0400
Content-Disposition: inline
In-Reply-To: <CAGugRbWL8Orkobwt4FENyswLsm1jWLBMdr-WJ6mCBhVn-xGwXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 07:52:23AM -0400, Karl Heiss wrote:
> On Mon, Jul 14, 2014 at 5:33 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> >
> > Your tcpdump looks interesting. Is it possible that all your
> > fragmented packets have the id field set to 'id 0'? This should
> > be only the case if the DF flag is set on that packet, but this
> > is apparently not the case here. If all the fragmented packets
> > have id 0, it is not possible to determine the correct fragment
> > chain. If only one fragment gets lost, all further packets might
> > be reassembled wrong.
> >
> 
> Yes, all fragments have 'id 0'.
> 
> > When looking at the code, is seems that sctp sets the DF flag
> > on packets as the default. The IPsec encapsulation code copies
> > the DF bit from the inner header and sets 'id 0' in this case.
> > A first guess would be that someone removes the DF flag after
> > the IPsec encapsulation.
> >
> > Is the DF flag set on your inner sctp packets?
> >
> 
> Yes, the inner packets have DF set, but the outer do not.

So we need to find where the DF flag disappears.

I tried to reproduce your issue with the current net tree,
but I was not able to do so.

With the plain net tree, all packets have the DF flag set
(sctp and esp), no fragments.

With the net tree and commit c08751c851b78514f6ec5 reverted,
I have some packets with the DF flag and some without. The
packets without the DF flag got fragmented after IPsec
processing. But even in this case, the ESP packet has the
DF flag set whenever the inner sctp packet has it set.
And also, the DF flag is set whenever a packet has 'id 0'.
The fragmented packets never have the 'id 0'.

Can you describe your usecase more precisely? Do you use
any additional tunnel like ipip/gre etc. or packet mangling?
