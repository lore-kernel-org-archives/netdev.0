From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Fri, 24 Jun 2016 09:31:12 -0700
Message-ID: <CALx6S341Pb-fq+trudZDOY3SpFzJvyqhrTGQd+7t0hDc3Jr_ig@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com> <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
 <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com> <058fd87e-4dbe-f80e-0606-508956f339a7@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hpe.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Bert Kenward <bkenward@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:34036 "EHLO
	mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbcFXQbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 12:31:15 -0400
Received: by mail-it0-f54.google.com with SMTP id g127so7871456ith.1
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 09:31:14 -0700 (PDT)
In-Reply-To: <058fd87e-4dbe-f80e-0606-508956f339a7@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 6:09 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 23/06/16 18:07, Alexander Duyck wrote:
>> I would prefer to see us extend LRO to support "close enough GRO"
>> instead of have us extend GRO to also include LRO.
> This reminds me of something I've been meaning to bring up (sorry for
> slightly OT, but it might turn out relevant after all).
> In sfc we have an (out-of-tree and likely staying that way) LRO that's
> entirely in software.  The only reason it exists is for users who want
> the 'permissive' merging behaviour of LRO, i.e. they don't need the
> guarantees of reversibility and by merging more stuff they can get
> slightly higher performance.
> I wonder if it would be a good idea for the GRO implementation to have
> some knobs to allow setting it to behave in this way.
> That would imply a scheme to define various GRO/SSR semantics, which
> then would also be a convenient interface for a driver to report the
> semantics of its hardware LRO if it has any.
> And it would make crystal clear that the difference between GRO and
> LRO is kernel vs hardware, rather than reversible vs not.
>
Ed,

Because you took this OT... ;-)

LRO/GRO is the one of the five common offloads that has no generic
analogue and requires protocol specific logic. For instance each
IP-over-foo encapsulation needs kernel code for GRO, device/driver
code for LRO. I think the answer here is to make both GRO and LRO to
be user programmable via BPF. That is, instead of needing to add code
or buy a new device to support every new protocol, we really just want
to write a program for it that runs in any environment. In the case of
LRO this becomes especially important since it resolves the "black
box" nature of LRO in devices, so design goals like ensuring LRO is
"close enough to GRO" become something we (the stack) have some
control over.

We've already moved GRO for to be a attribute of a UDP sockets, it is
not much of a stretch now to allow applications to define their own
GRO for their protocols (I'm thinking protocols like QUIC or TOU could
use this).

For programmable LRO I think the solution is to use XDP. For instance
protocol specific parsing would done by the BPF program to identify
the flows, and the infrastructure would provide the backend handling.
The advantage of XDP for this is that it is not platform specific, so
programmable LRO could be implemented in the driver (probably
leveraging existing LRO solution like sfc), or it could be implemented
implemented in HW using the exact same program (with HW support for
BPF/XDP). Since such a program allows arbitrary parsing and flow
lookup, we can match on specific n-tuples as needed to resolve the
UDP-encapsulation identification problem.

Tom

> -Ed
