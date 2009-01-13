From: Bill Fink <billfink@mindspring.com>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
 2.6.24?
Date: Tue, 13 Jan 2009 00:31:08 -0500
Message-ID: <20090113003108.72860b5c.billfink@mindspring.com>
References: <20090111212303.GA8612@outpost.ds9a.nl>
	<175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com>
	<20090111224541.GA10848@outpost.ds9a.nl>
	<20090111225427.GA7004@ioremap.net>
	<20090111230824.GB10848@outpost.ds9a.nl>
	<20090111231859.GA8309@ioremap.net>
	<20090111235001.536a858d.billfink@mindspring.com>
	<Pine.LNX.4.64.0901121111420.24748@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	bert hubert <bert.hubert@netherlabs.nl>,
	"H. Willstrand" <h.willstrand@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q? "Ilpo_J=E4rvinen" ?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:51199 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752203AbZAMFbT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 00:31:19 -0500
In-Reply-To: <Pine.LNX.4.64.0901121111420.24748@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jan 2009, Ilpo J=E4rvinen wrote:

> On Sun, 11 Jan 2009, Bill Fink wrote:
>=20
> > On Mon, 12 Jan 2009, Evgeniy Polyakov wrote:
> >=20
> > > On Mon, Jan 12, 2009 at 12:08:24AM +0100, bert hubert (bert.huber=
t@netherlabs.nl) wrote:
> > > > I fully understand. Sometimes I have to talk to stupid devices =
though. What
> > > > I do find is the TCP_INFO ioctl, which offers this field in str=
uct tcp_info:
> > > >=20
> > > >         __u32   tcpi_unacked;
> > > >=20
> > > > Which comes from:
> > > >=20
> > > > struct tcp_sock {
> > > > ...
> > > >         u32     packets_out;    /* Packets which are "in flight=
"        */
> > > > ...
> > > > }
> > > >=20
> > > > If this becomes 0, perhaps this might tell me everything I sent=
 was acked?
> > >=20
> > > 0 means that there are noin-flight packets, which is effectively =
number
> > > of unacked packets. So if your application waits for this field t=
o
> > > become zero, it will wait for all sent packets to be acked.
> >=20
> > I use this type of strategy in nuttcp, and it seems to work fine.
> > I have a loop with a small delay and a check of tcpi_unacked, and
> > break out of the loop if tcpi_unacked becomes 0 or a defined timeou=
t
> > period has passed.
>=20
> Checking tcpi_unacked alone won't be reliable. The peer might be slow=
=20
> enough to advertize zero window for a short period of time and during=
=20
> that period you would have packets_out zero...

I'll keep this in mind for the future, although it doesn't seem to
be a significant issue in practice.  I use this scheme to try and
account for the tcpi_total_retrans for the data stream, so if this
corner case was hit, it would mean an under reporting of the total
TCP retransmissions for the nuttcp test.

If I understand you correctly, to hit this corner case, just after
the final TCP write, there would have to be no packets in flight
together with a zero TCP window.  To make it more bullet-proof, I
guess after seeing a zero tcpi_unacked, an additional small delay
should be performed, and then rechecking for a zero tcpi_unacked.
I don't see anything else obvious (to me anyway) in the tcp_info
that would be particularly helpful in handling this.

						-Thanks

						-Bill
