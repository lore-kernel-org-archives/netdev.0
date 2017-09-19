From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 00/14] gtp: Additional feature support
Date: Tue, 19 Sep 2017 20:43:52 +0800
Message-ID: <20170919124352.l4k67ygb6xt4eloq@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:45615 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbdISMoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:44:12 -0400
Content-Disposition: inline
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

first of all, thanks a lot for your patch series.  It makes me happy to
see contributions on the GTP code :)

On Mon, Sep 18, 2017 at 05:38:50PM -0700, Tom Herbert wrote:
>   - IPv6 support

see my detailed comments in other mails.  It's unfortunately only
support for the already "deprecated" IPv6-only PDP contexts, not the
more modern v4v6 type.  In order to interoperate with old and new
approach, all three cases (v4, v6 and v4v6) should be supported from one
code base.

>   - Configurable networking interfaces so that GTP kernel can be used
>   and tested without needing GSN network emulation (i.e. no user space
>   daemon needed).

We have some pretty decent userspace utilities for configuring the GTP
interfaces and tunnels in the libgtpnl repository, but if it helps
people to have another way of configuration, I won't be against it.

What we have to keep in mind is that the current model of 1:1 mapping of
a "UDP socket' to a GTP netdevice is conceptually broken and needs to be
refactored soon (without breaking backwards compatibility).  See related
earlier discussions with patches submitted by Andreas Schultz.

Summary:

In real-world GGSNs you often want to host multiple virtual GGSNs on a
single GGSN (= UDP socket).  Each virtual GGSN terminates into one
external PDN (packet data network), which can be a private corporate vpn
or any other IP network, with no routing between those networks.

Naively one would assume you "simply" run another virtual GGSN
instance on another IP address, and then differentiate like that.

However, the problem is that adding a new GGSN IP address will require
manual configuration changes at each of your roaming partners (easily
hundreds of operators!) and hence it is avoided at all cost due to the
related long schedule, requirement for interop testing with each of them,
etc.

So what you do in reality at operators is that you operate many of those
virtual GGSNs on the same IP:Port combination (and hence UDP socket),
which means you have PDP contexts for vGGSN A which terminate on e.g.
gtp0 and PDP contexts for vGGSN B on gtp1, and so on.  The decision
which gtp-device a given PDP context is a member is made by the GTP-C
instance.  In the kenel we'll have to decouple net-devices from sockets.

So whatever new configuration mechanism or architectural changes we
introduce, we need to make sure that those will accomodate the "new
model" rather than introducing further dependencies for which we will
have to maintain backwards compatibility workaronds later on.

>   - Port numbers are configurable

I'm not sure if this is a useful feature.  GTP is used only in
operator-controlled networks and only on standard ports.  It's not
possible to negotiate any non-standard ports on the signaling plane
either.

>   - Addition of a dst_cache in the GTP structure and other cleanup

looks fine to me.

>   - GSO,GRO
>   - Control of zero UDP checksums

[...]

> Additionally, this patch set also includes a couple of general support
> capabilities:
> 
>   - A facility that allows application specific GSO callbacks
>   - Common functions to get a route fo for an IP tunnel

This is where the "core netdev" folks will have to comment.  I'm too
remote from mainline kernel development these days and will focus on
reviewing the GTP specific bits of your patch series.

> For IPv6 support, the mobile subscriber needs to allow IPv6 addresses,
> and the remote enpoint can be IPv6.

Minor correction: The mobile subscriber specifically requests a PDP Type
when establishing the PDP context via Session Management related
signaling from MS/UE to SGSN.  The SGSN simply translates this to GTP
and then forwards it to the GGSN.  So it's acutally not "allow" but
"specifically request".

> Configured the matrix of IPv4/IPv6 mobile subscriber, IPv4/IPv6 remote
> peer, and GTP version 0 and 1 (eight combinations). Observed
> connectivity and proper GSO/GRO. Also, tested VXLAN for
> regression.

I presume those tests were done with manually configured GTP-devices and
PDP contexts to the (patched) kernel GTP module?  If so, I would like to
strongly suggest interop testing with a different implementation, such
as real phones on the MS/UE side and e.g. OsmoSGSN.  That would,
however, of course mean that the netlink related bits would have to be
added to libgtpnl and OsmoGGSN (or ergw) so that you have a daemon for
the control plane.

For IPv6 (and v4v6) PDP contexts there is quite a bit of extra headache
related to the way how router solicitation/advertisements are modified
in the 3GPP world.

The address allocation in v4 is simple:
* MS/UE requests dynamic or fixed IPv4 address via EUA IE of PDP context
  activation
* GGSN responds with IPv4 address in EUA of Activate PDP context
  response (and then uses netlink to tell the kernel about that
  IPv4 address)

In v6 or the v6 portion of v4v6 it works differently:
* MS/UE requests dynamic or fixed IPv4 address in EUA IE of PDP context
  activation
* GGSN responds with an IPv6 address, but that address is *not* used
  for communication, but simply used as an "interface identifier" to
  build a link-local address.
* MS then uses router solicitation using that link-local address
* GGSN responds with router advertisement, allocating a single /64
  prefix, from which the MS then generates a fully-qualified IPv6
  source address for communication.

How did you envision this to be done with the v6 support you just added?
At the very least, the /64 prefix matching would have to be implemented
so that in fact all addresses within that /64 prefix are matched +
encapsulated for a given PDP context in the downlink (to phone)
direction.

Also, I think the responsibility for the router advertisements would be
in the kernel, too.  Otherwise, a GTP-C userspace implementation would
have to inject packets into the user plane (which is otherwise handled
completely inside the kernel).  Injecting packets would mean that in caes
GTP sequence numbers are used, that userspace implementation would have
to alter the sequence numbers of the kernel gtp.ko code using netlink,
but therre would  be race conditions, ...

The router advertisements and neighbor advertisements basically have the
semantics of one link per PDP context.  Each of them is a point-to-point
link, and it's not one router advertisement that's sent to all of the
PDP contexts on that gtp-device.

I know it all sucks.  I'm still happy to see somebody tackling v6
support in gtp.c :)

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
