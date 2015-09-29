From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: Re: [PATCH v4 net-next 0/2] ipv4: Hash-based multipath routing
Date: Tue, 29 Sep 2015 13:29:24 +0200
Message-ID: <20150929132924.1e4b3108@pch.odense.ordbogen.com>
References: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
	<20150928.193355.515603960827814980.davem@davemloft.net>
	<20150928.195541.2230338616645241909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:60693 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964803AbbI2L30 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 07:29:26 -0400
In-Reply-To: <20150928.195541.2230338616645241909.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Sep 2015 19:55:41 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Mon, 28 Sep 2015 19:33:55 -0700 (PDT)
>=20
> > From: Peter N=C3=B8rlund <pch@ordbogen.com>
> > Date: Wed, 23 Sep 2015 21:49:35 +0200
> >=20
> >> When the routing cache was removed in 3.6, the IPv4 multipath
> >> algorithm changed from more or less being destination-based into
> >> being quasi-random per-packet scheduling. This increases the risk
> >> of out-of-order packets and makes it impossible to use multipath
> >> together with anycast services.
> >>=20
> >> This patch series replaces the old implementation with flow-based
> >> load balancing based on a hash over the source and destination
> >> addresses.
> >=20
> > This isn't perfect but it's a significant step in the right
> > direction. So I'm going to apply this to net-next now and we can
> > make incremental improvements upon it.
>=20
> Actually, I had to revert, this doesn't build:
>=20
> [davem@localhost net-next]$ make -s -j8
> Setup is 16876 bytes (padded to 16896 bytes).
> System is 10011 kB
> CRC 324f2811
> Kernel: arch/x86/boot/bzImage is ready  (#337)
> ERROR: "__ip_route_output_key_hash" [net/dccp/dccp_ipv4.ko] undefined=
!
> scripts/Makefile.modpost:90: recipe for target '__modpost' failed
> make[1]: *** [__modpost] Error 1
> Makefile:1095: recipe for target 'modules' failed
> make: *** [modules] Error 2

Sorry! I forgot to update the EXPORT_SYMBOL_GPL line.

In the meantime I've been doing some thinking (and measuring).
Considering that the broader goal is to make IPv6 and IPv4 behave as
identical as possible, it is probably not such a bad idea to just use
the flow dissector + modulo in the IPv4 code too - the patch will be
simpler than the current one.

I fear the performance impact of the flow dissector though - some of my
earlier measurements showed that it was 5-6 times slower than the
simple one I used. But maybe it is better to streamline the IPv4/IPv6
multipath first and then improve upon it afterward (make it work, make
it right, make it fast).

As for using L4 hashing with anycast, CloudFlare apparently does L4
hashing - they could have disabled it, but they didn't. Besides,
analysis of my own load balancers showed that only one in every
500,000,000 packets is fragmented. And even if I hit a fragmented
packet, it is only a problem if the packet hits the wrong load
balancer, and if that load balancer haven't been updated with the state
from another load balancer (that is, one of the very first packets). It
is still a possible scenario though - especially with large HTTP
cookies or file uploads. But apparently it is a common problem that IP
fragments gets dropped on the Internet, so I suspect that ECMP+Anycast
sites are just part of the pool of problematic sites for people with
fragments.

I'm still unsettled as to whether the ICMP handling belongs to the
kernel or not. The above breakage was in the ICMP-part of the
patchset, so judging from that, I guess it wasn't out of the question.
But in the "IPv4 and IPv6 should behave identical"-mindset, it probably
belongs to a separate, future patchset, adding ICMP handling to both
IPv4 and IPv6 - and it is actually more important for IPv6 than IPv4
since PMTUD cannot be disabled.

Best Regards,
  Peter N=C3=B8rlund
