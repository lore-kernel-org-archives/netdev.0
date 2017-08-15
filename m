From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/2] mpls: add handlers
Date: Tue, 15 Aug 2017 11:37:45 +0200
Message-ID: <20170815093745.GC773745@eidolon>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com>
 <20170811123405.GY773745@eidolon>
 <CAJieiUiDN0pk2GDb2+jBQzbjdPTpckSm23SCFGZ9mRHWfQ1H4w@mail.gmail.com>
 <c6fc221b-c0fa-1dbc-d1e2-a746b722dcd7@6wind.com>
 <CAJieiUijsyWjzNL=oFaGxtuos367v0VrpSaEqwHvVacrk5hcTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amine Kherbouche <amine.kherbouche@6wind.com>,
        David Lamparter <equinox@diac24.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:35108 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752497AbdHOJhs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 05:37:48 -0400
Content-Disposition: inline
In-Reply-To: <CAJieiUijsyWjzNL=oFaGxtuos367v0VrpSaEqwHvVacrk5hcTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 12, 2017 at 08:29:18PM -0700, Roopa Prabhu wrote:
> On Sat, Aug 12, 2017 at 6:35 AM, Amine Kherbouche
> <amine.kherbouche@6wind.com> wrote:
> >
> >
> > On 11/08/2017 16:37, Roopa Prabhu wrote:
> >>
> >> On Fri, Aug 11, 2017 at 5:34 AM, David Lamparter <equinox@diac24.net>
> >> wrote:
> >>>
> >>> On Thu, Aug 10, 2017 at 10:28:36PM +0200, Amine Kherbouche wrote:
> >>>>
> >>>> Mpls handler allows creation/deletion of mpls routes without using
> >>>> rtnetlink. When an incoming mpls packet matches this route, the saved
> >>>> function handler is called.
> >>>
> >>> Since I originally authored this patch, I have come to believe that it
> >>> might be unneccessarily complicated.  It is unlikely that a lot of
> >>> different "handlers" will exist here;  the only things I can think of
> >>> are VPLS support and BIER-MPLS multicast replication.  I'm not saying
> >>> it's a bad idea, but, well, this was in the README that I gave to 6WIND
> >>> with this code:
> >>>
> >>> ...
> >>
> >> yes, I would also prefer just exporting the functions  and calling
> >> them directly instead of adding a
> >> handler layer. We can move to that later if it becomes necessary.
> >
> > I understand that the handler layer is an overhead (as said by David's
> > note), and I agree with the solution for exporting the mpls functions that
> > allows route creation/deletion, but how about forwarding the right mpls
> > packet to the right vpls device with the device ptr? I don't see
> > another way.
> 
> 
> hmm...ok, so you are adding a mpls route to get into vpls_rcv and you
> want this route to carry the vpls_rcv information. Ideally if you knew
> the route is pointing to a vpls device kind, you can directly call
> vpls_rcv.
> But, am not sure if a route is necessary here either.
> 
> It just seems like the vpls device information is duplicated in the
> mpls route per vpls dev. Wondering if we can skip the route part and
> always do a lookup on vpls-id/label in mpls_rcv to send it to a
> vpls_rcv if there is a match.  This will be the l2 handler for mpls.

I think the reverse is the better option, removing the vpls device
information and just going with the route table.  My approach to this
would be to add a new netlink route attribute "RTA_VPLS" which
identifies the vpls device, is stored in the route table, and provides
the device ptr needed here.
(The control word config should also be on the route.)

My reason for thinking this is that the VPLS code needs exactly the same
information as does a normal MPLS route:  it attaches to an incoming
label (decapsulating packets instead of forwarding them), and for TX it
does the same operation of looking up a nexthop (possibly with ECMP
support) and adding a label stack.  The code should, in fact, probably
reuse the TX path.

This also fits both an 1:1 and 1:n model pretty well.  Creating a VPLS
head-end netdevice doesn't even need any config.  It'd just work like:
- ip link add name vpls123 type vpls
- ip -f mpls route add \
        1234 \                              # incoming label for decap
        vpls vpls123 \                      # new attr: VPLS device
        as 2345 via inet 10.0.0.1 dev eth0  # outgoing label for encap

For a 1:n model, one would simply add multiple routes on the same vpls
device.


-David
