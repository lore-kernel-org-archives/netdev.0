From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS
	autoconfiguration
Date: Sun, 24 Jun 2007 22:17:31 -0400
Message-ID: <1182737851.16455.3.camel@xo-13-A4-25.localdomain>
References: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com>
	 <200706231625.44825@auguste.remlab.net>
	 <c6d9bea0706230747y79d39a6eh3c55de3a29cfb4d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813AbXFYCMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jun 2007 22:12:54 -0400
In-Reply-To: <c6d9bea0706230747y79d39a6eh3c55de3a29cfb4d1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-06-23 at 10:47 -0400, C. Scott Ananian wrote:
> R=C3=A9mi and Simon give my responses very eloquently.  Although you =
could
> have yet-another-network-daemon redundantly process RA messages, the
> kernel is doing it already and it makes sense to just push this
> information to userland using /proc and/or netlink.  Although parsing
> RA messages and processing expiry in userland looks barely-possible
> now, SeND support is really necessary for long-term IPv6 security, an=
d
> duplicating SeND functionality in userland would be a nightmare.
> Futher, the neighbor discover protocol involves Router Solicitation
> messages which elicit the Router Advertisement reply, and we really
> don't want userland sending redundant Router Solicitation messages
> around, just because the kernel doesn't want to tell it what Router
> Advertisements it received.  I considered storing the *complete*
> Router Advertisement messages received and pushing them unparsed to
> userland, just to get around the bogus "DNS in the kernel" politics
> (hint: it's not a resolver in the kernel, it's just nameserver
> addresses being stored).  Does anyone really suggest that this would
> be a better solution?
>=20
> The goal is to push the userland component into glibc, likely through
> a NSS resolver plugin.  Current glibc doesn't do any processing to
> determine when /etc/resolv.conf has changed, which is a problem for

The glibc guys rejected things like periodically stat()-ing resolv.conf=
=2E
The standard solution to this has been to push the responsibility for
noticing resolv.conf changes to _each_ _app_, which must periodically
call _res_init() to get glibc to re-read resolv.conf and notice any
changes.  This is what eg Mozilla/Firefox and other internet-type apps
do right now.

Or, run a caching nameserver and point resolv.conf to 127.0.0.1, or use
nss_lwres, which hopefully is in much better shape than it was a year o=
r
two ago (ie, actually respecting TTL and such).

Dan

> long-running applications.  Exporting RDNSS-in-RA via netlink message=
s
> (or by poll() on a /proc file as is done for /proc/<pid>/mounts, whic=
h
> was suggested in linux-kernel) is an elegant solution that (as R=C3=A9=
mi
> noted) cleanly handles interface up/down/reconfig, route expiration,
> and (eventually) the cryptographic neighbor discovery protocol withou=
t
> weaving a web of hairs from the kernel to the resolver.
>  --scott
>=20

