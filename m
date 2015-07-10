From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [RFC PATCH net-next] sctp: fix src address selection if using
 secondary addresses
Date: Fri, 10 Jul 2015 15:27:02 -0300
Message-ID: <20150710182702.GQ1841@localhost.localdomain>
References: <81786a31f7f143e1d229de9a9f909d5f83fa9bb2.1436279035.git.marcelo.leitner@gmail.com>
 <20150709165458.GA1855@localhost.localdomain>
 <27EB7D25-A947-4C75-B25B-03BFAD48EC64@fh-muenster.de>
 <20150710115305.GB1855@localhost.localdomain>
 <559FE640.5070008@gmail.com>
 <20150710161718.GP1841@localhost.localdomain>
 <559FFD6D.8090407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tuexen <tuexen@fh-muenster.de>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbbGJS1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 14:27:05 -0400
Content-Disposition: inline
In-Reply-To: <559FFD6D.8090407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 01:14:21PM -0400, Vlad Yasevich wrote:
> On 07/10/2015 12:17 PM, Marcelo Ricardo Leitner wrote:
> > On Fri, Jul 10, 2015 at 11:35:28AM -0400, Vlad Yasevich wrote:
> >> On 07/10/2015 07:53 AM, Marcelo Ricardo Leitner wrote:
> >>> On Thu, Jul 09, 2015 at 09:55:19PM +0200, Michael Tuexen wrote:
> >>>>> On 09 Jul 2015, at 18:54, Marcelo Ricardo Leitner <mleitner@redhat.com> wrote:
> >>>>>
> >>>>> Cc'ing Michael too.
> >>>> I'm not familiar with the Linux kernel code, so I can't comment on it.
> >>>> But making sure to use a source address belonging to the emitting
> >>>> interface makes sense for me.
> >>>>
> >>>> Best regards
> >>>> Michael
> >>>
> >>> That's pretty much what I was looking for, in case I missed something on
> >>> SCTP RFCs. 
> >>>
> >>
> >> Well, the RFCs do not really specify what the source address should be, and there
> > 
> > That's why I was afraid of having missed something ;)
> > 
> >> have been numerous times where I've seen weak host model in use on the wire
> >> even with a BSD peer.
> >>
> >> This also puts a very big nail through many suggestions we've had over the years
> >> to allow source based path multihoming in addition to destination based multihoming
> >> we currently support.
> >>
> >> It might be a good idea to make rp-filter like behavior best effort, and have
> >> the old behavior as fallback.  I am still trying to think up different scenarios
> >> where rp-filter behavior will cause things to fail prematurely...
> > 
> > The old behavior is like "if we don't have a src yet and can't find a
> > preferred src for this dst, use the 1st bound address". We can add it
> > but as I said, I'm afraid it is just doing wrong and not worth. If such
> > randomly src addressed packet is meant to be routed, the router will
> > likely drop it as it is seen as a spoof. And if it reaches the peer, it
> > will probably come back through a different path.
> > 
> > I'm tempted to say that current usual use cases are handled by the first
> > check on this function, which returns the preferred/primary address for
> > the interface and checks against bound addresses. Whenever you reach the
> > second check, it just allows you to use that 1st bound address that is
> > checked. I mean, I can't see use cases that we would be breaking with
> > this change. 
> 
> Yes,  the secondary check didn't amount to much, but we've kept it since 2.5
> days (when sctp was introduced).  I've made attempts over the years to
> try to make it stricter, but that never amounted to anything that worked well.
> 
> > 
> > But yeah, it impacts source based routing, and I'm not aware of previous
> > discussions on it. I'll try to dig some up but if possible, please share
> > some pointers on it.
> 
> It's been suggested a few times that we should support source based multihoming
> particularly for the case where one peer has only 1 address.
> We've always punted on this, but people still ask every now and then.

Ah okay, now I see it.
 
> I do have a question about the code though.. Have you tried with mutlipath routing
> enabled.  I see rp_filter checks have special code to handle that.  Seem like we
> might get false negatives in sctp.

In the sense of CONFIG_IP_ROUTE_MULTIPATH=y, yes, but just that. My
routes were simple ones, either 2 peers attaches to 2 local subnets, or
with a gateway in the middle (with 2 subnets on each side, but mapped
1-1, no crossing. Aka subnet1<->subnet2 and subnet3<->subnet4 while not
(subnet1<->subnet4 or subnet3<->subnet2).

Note that this is not rp_filter strictly speaking, as it's mirrored.
rp_filter needs to calculate all possible output routes (actually until
it finds a valid one) for finding one that would match the one used for
incoming. 

This check already has an output path, and it's calculating if such
input would be acceptable. We can't really expect/check for other hits
because it invalidates the chosen output path.

Hmmm... but we could support multipath in the output selection, ie in
the outputs of ip_route_output_key(), probably in another patch then?

  Marcelo
