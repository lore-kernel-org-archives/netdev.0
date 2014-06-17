From: Dan Williams <dcbw@redhat.com>
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Tue, 17 Jun 2014 17:34:31 -0500
Message-ID: <1403044471.16272.20.camel@dcbw.local>
References: <53A0B617.6070600@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966286AbaFQWed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2014 18:34:33 -0400
In-Reply-To: <53A0B617.6070600@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-17 at 14:41 -0700, Ben Greear wrote:
> I'm trying to understand how DHCP for ipv6 is supposed to work.
> 
> I am able to get a global-scope address and prefix from
> dhclient, but dhclient is not providing a gateway address.

That's because it doesn't; DHCPv6 isn't supposed to be used standalone
for global IPv6 connectivity.  That's what router advertisements are
for.  The normal flow is this:

1) your router advertisement provides your prefix, prefix length (eg
subnet mask), and default gateway/router

2) your prefix gets combined with your local Interface Identifier (often
your MAC address or a hashed version of your MAC, or delivered via PPP,
or hashed InfiniBand port GUID, or GRE tunnel address, etc) to provide
your global IPv6 address.  See
net/ipv6/addrconf.c::ipv6_generate_eui64().

3) the RA can also provide search domains, DNS servers, routes, MTU,
etc.

4) if there's anything else your administrator really wants to use DHCP
for (NTP servers, etc) then they set the M (Managed) or O (Other Config)
bits in the router advertisement.

5) In both cases, that requests that the client run DHCPv6; in M mode
you do get a lease from the DHCP server and that address becomes
preferred, in the O case no lease is obtained but other options can be
delivered

6) In all cases, the default gateways (and their respective priorities)
are always delivered by Router Advertisements; there can be multiple
default gateways in the broadcast domain for redundancy, and the network
administrator sets their relative priority.

> I see the dhclient interface doing a Router Solicitation, but
> I don't see any answers.
> 
> Are we supposed to run radvd or something like that as well?

Yes.  If you're not using static addressing, then you must run radvd to
deliver router advertisements to your network.  See 'man radvd.conf' for
more information on configuring the additional options that DHCP used to
be used for (RDNSS, DNSSL, AdvLinkMTU, route, etc).

> Or is there some other automated magic that is supposed to
> find the default gateway?

Router Advertisements via radvd.  You probably want to evaluate whether
you really need DHCPv6 at all, since RA can deliver most of the options
that people use DHCP for.

Dan
