From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next 00/14] gtp: Additional feature support
Date: Wed, 20 Sep 2017 17:34:23 +0200
Message-ID: <086d4920-17cf-d439-1773-32167f267f5e@tpip.net>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919124352.l4k67ygb6xt4eloq@nataraja>
 <CALx6S35n-V3d00SyV=Lz97KPq=CSCmOaerXpFBYSknKtdiwYug@mail.gmail.com>
 <20170919231947.bt4am3els3p26l6p@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@quantonium.net>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Harald Welte <laforge@gnumonks.org>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:51928 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751732AbdITPe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 11:34:27 -0400
In-Reply-To: <20170919231947.bt4am3els3p26l6p@nataraja>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Harald,

On 20/09/17 01:19, Harald Welte wrote:
> Hi Tom,
> 
> On Tue, Sep 19, 2017 at 08:59:28AM -0700, Tom Herbert wrote:
>> On Tue, Sep 19, 2017 at 5:43 AM, Harald Welte <laforge@gnumonks.org>
>> wrote:
>>> On Mon, Sep 18, 2017 at 05:38:50PM -0700, Tom Herbert wrote:
>>>>    - IPv6 support
>>>
>>> see my detailed comments in other mails.  It's unfortunately only
>>> support for the already "deprecated" IPv6-only PDP contexts, not the
>>> more modern v4v6 type.  In order to interoperate with old and new
>>> approach, all three cases (v4, v6 and v4v6) should be supported from
>>> one code base.
>>>
>> It sounds like something that can be subsequently added.
> 
> Not entirely, at least on the netlink (and any other configuration
> interface) you will have to reflect this from the very beginning.  You
> have to have an explicit PDP type and cannot rely on the address type to
> specify the type of PDP context.  Whatever interfaces are introduced
> now will have to remain compatible to any future change.
> 
> My strategy to avoid any such possible 'road blocks' from being
> introduced would be to simply add v4v6 and v6 support in one go.  The
> differences are marginal (having both an IPv6 prefix and a v4 address in
> parallel, rather than mutually exclusive only).
> 
>> Do you have a reference to the spec?
> 
> See http://osmocom.org/issues/2418#note-7 which lists Section 11.2.1.3.2
> of 3GPP TS 29.061 in combination with RFC3314, RFC7066, RFC6459 and
> 3GPP TS 23.060 9.2.1 as well as a summary of my understanding of it some
> months ago.
> 
>>>>    - Configurable networking interfaces so that GTP kernel can be
>>>>    used and tested without needing GSN network emulation (i.e. no
>>>>    user space daemon needed).
>>>
>>> We have some pretty decent userspace utilities for configuring the
>>> GTP interfaces and tunnels in the libgtpnl repository, but if it
>>> helps people to have another way of configuration, I won't be
>>> against it.
>>>
>> AFAIK those userspace utilities don't support IPv6.
> 
> Of course not [yet]. libgtpnl and the command line tools have been
> implemented specifically for the in-kernel GTP driver, and you have to
> make sure to add related support on both the kernel and the userspace
> side (libgtpnl). So there's little point in adding features on either
> side before the other side.  There would be no way to test...
> 
>> Being able to configure GTP like any other encapsulation will
>> facilitate development of IPv6 and other features.
> 
> That may very well be the case, but adding "IPv6 support" to kernel GTP
> in a way that is not in line with the existing userspace libraries and
> control-plane implementations means that you're developing those
> features in an artificial environment that doesn't resemble real 3GPP
> interoperable networks out there.
> 
> As indicated, I'm not against adding additional interfaces, but we have
> to make sure that we add IPv6 support (or any new feature support) to at
> least libgtpnl, and to make sure we test interoperability with existing
> 3GPP network equipment such as real IPv6 capable phones and SGSNs.
> 
>>> I'm not sure if this is a useful feature.  GTP is used only in
>>> operator-controlled networks and only on standard ports.  It's not
>>> possible to negotiate any non-standard ports on the signaling plane
>>> either.
>>>
>> Bear in mind that we're not required to do everything the GTP spec
>> says.
> 
> Yes, we are, at least as long as it affects interoperability with other
> implemetations out there.
> 
> GTP uses well-known port numbers on *both* sides of the tunnel, and you
> cannot deviate from that.

Actually, the well-known port is only mandatory for the receiving side.
The sending side can choose any port it wishes as long as it is prepared
to receive possible error indication on the well-known port.

Of course, it makes the implementation simple to use only one port, but 
for scalability it might be a good idea to support per PDP context 
sending ports.

Regards
Andreas

> There's no point in having all kinds of feetures in the GTP user plane
> which are not interoperable with other implementations, and which are
> completely outside of the information model / architecture of GTP.
> 
> In the real world, GTP-U is only used in combination with GTP-C.  And in
> GTP-C you can only negotiate the IP address of both sides of GTP-U, and
> not the port number information.  As a result, the port numbers are
> static on both sides.
> 
>> My impression is GTP designers probably didn't think in terms of
>> getting best performance. But we can ;-)
> 
> I think it's wasted efforts if it's about "random udp ports" as no
> standards-compliant implementation out there with which you will have to
> interoperate will be able to support it.
> 
> GTP is used between home and roaming operator.  If you want to introduce
> changes to how it works, you will have to have control over both sides
> of the implementation of both the GTP-C and the GTP-u plane, which is
> very unlikely and rather the exception in the hundreds of operators you
> interoperate with.  Also keep in mind that there often are various
> "middleboxes" that will suddenly have to reflect your changes.  That
> starts from packet filters at various locations in the operator networks
> and/or roaming hubs, down to GTP hubs and others.
> 
> My opinion is: Non-standard GTP ports are not going to happen.
> 
>> I also brought up open_ggsn. ggsn to sgsn.
> 
> That's good to hear.  For both v4 and v6 PDP contexts?  Whcih phones
> did you use for testing?  Particularly given how convolved the address
> allocation is (see below), I'm surprised it would work.
> 
>>> For IPv6 (and v4v6) PDP contexts there is quite a bit of extra headache
>>> related to the way how router solicitation/advertisements are modified
>>> in the 3GPP world.
>>>
>>> The address allocation in v4 is simple:
>>> * MS/UE requests dynamic or fixed IPv4 address via EUA IE of PDP context
>>>    activation
>>> * GGSN responds with IPv4 address in EUA of Activate PDP context
>>>    response (and then uses netlink to tell the kernel about that
>>>    IPv4 address)
>>>
>>> In v6 or the v6 portion of v4v6 it works differently:
>>> * MS/UE requests dynamic or fixed IPv4 address in EUA IE of PDP context
>>>    activation
>>> * GGSN responds with an IPv6 address, but that address is *not* used
>>>    for communication, but simply used as an "interface identifier" to
>>>    build a link-local address.
>>> * MS then uses router solicitation using that link-local address
>>> * GGSN responds with router advertisement, allocating a single /64
>>>    prefix, from which the MS then generates a fully-qualified IPv6
>>>    source address for communication.
>>>
>>> How did you envision this to be done with the v6 support you just added?
>>> At the very least, the /64 prefix matching would have to be implemented
>>> so that in fact all addresses within that /64 prefix are matched +
>>> encapsulated for a given PDP context in the downlink (to phone)
>>> direction.
>>>
>>> [...]
>> I would hope all the above you're describing is mostly control plane
>> matters.
> 
> It is not.  The control plane is GTP-C and runs on different UDP ports
> (at least for GTPv1/v2).  The user plane is GTP-U and is what's done in
> the kernel.  And by its very nature, IPv6 router
> solicitations/advertisements (as well as neighbor
> solicitations/advertisements) are part of the user plane and thus
> handled in GTP-U.
> 
>> At least a good design decouples data palne and control
>> plane. I know that GTP is a bit convoluted in this regard.
> 
> The problem is that IPv6 has never been specified properly for
> point-to-point links.  There's no decent PPP specs for IPv6.  So the
> 3GPP folks had to try to be as close as possible to the existing
> (broadcast) link layer model to facilitate existing IPv6 implemetations
> to work over 3GPP bearers.  That's why they kept whatever possible to
> re-use in terms of neighbor/router discovery.
> 
> So the problem is now: Unless you handle GTP-U *entirely* in the kernel
> (including router + neighbor advertisement/solicitation), you will have
> a "split GTP-U" plane between kernel and userspace.  And in that context
> the question is who owns the sequence numbers, how will you avoid race
> conditions, ... - my simple suggestion is thus to keep with the current
> split and do everything GTP-U related inside the kernel and everything
> GTP-C related in userspace.
> 
> I think there has to be a clear plan/architecture on how to implement
> those bits in terms of the kernel/userspace split, and at least a proof
> of concept implementation that we can show works with some real phones
> out there - otherwise there's no point in having IPv6 support that works
> well with some custom tools.
> 
> Regards,
> 	Harald
> 
