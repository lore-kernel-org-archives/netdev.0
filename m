From: Jeremy Jackson <jerj@coplanar.net>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
 2.6.24?
Date: Fri, 13 Feb 2009 12:02:35 -0500
Message-ID: <1234544555.28913.451.camel@ragnarok>
References: <20090111212303.GA8612@outpost.ds9a.nl>
	 <175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com>
	 <20090111224541.GA10848@outpost.ds9a.nl>
	 <20090111225427.GA7004@ioremap.net>
	 <20090111230824.GB10848@outpost.ds9a.nl>
	 <20090111231859.GA8309@ioremap.net>
	 <20090111235001.536a858d.billfink@mindspring.com>
	 <Pine.LNX.4.64.0901121111420.24748@wrl-59.cs.helsinki.fi>
	 <20090113003108.72860b5c.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, Evgeniy Polyakov <zbr@ioremap.net>,
	bert hubert <bert.hubert@netherlabs.nl>,
	"H. Willstrand" <h.willstrand@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:39567 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbZBMUof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 15:44:35 -0500
In-Reply-To: <20090113003108.72860b5c.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-13 at 00:31 -0500, Bill Fink wrote:
> On Mon, 12 Jan 2009, Ilpo J=C3=A4rvinen wrote:
>=20
> > On Sun, 11 Jan 2009, Bill Fink wrote:
> >=20
> > > On Mon, 12 Jan 2009, Evgeniy Polyakov wrote:
> > >=20
> > > > On Mon, Jan 12, 2009 at 12:08:24AM +0100, bert hubert (bert.hub=
ert@netherlabs.nl) wrote:
> > > > > I fully understand. Sometimes I have to talk to stupid device=
s though. What

An excellent article on this subject:

http://ds9a.nl/the-ultimate-so_linger-page-or-why-is-my-tcp-not-reliabl=
e.txt

"Luckily, it turns out that Linux keeps track of the amount of
unacknowledged
data, which can be queried using the SIOCOUTQ ioctl(). Once we see this
number hit 0, we can be reasonably sure our data reached at least the
remote
operating system."

is this the same as the TCP_INFO getsockopt() ?

if you follow the progression from write(socket_fd, ) ... the data sits
in
the socket buffer, and SIOCOUTQ is initially zero.  If the connection
started with a zero window,
it could sit like that for a while (sometimes called a "tarpit ?).  But=
,
you should still see the data in your socket buffer, yes?

So, I think you want to make sure your socket write buffer is empty
(converted to unacked data), *then* make sure your unacked data is 0.

	write(sock, buffer, 1000000);             // returns 1000000
	shutdown(sock, SHUT_WR);
	now wait for SIOCOUTQ to hit 0.

if window is 0, shutdown() would wait until show device sets window > 0
again, or forever on a tarpitted connection.  Either way, when if/when
it finishes, you know all data was transmitted, now wait for all of it
to be ACKed with SIOCOUTQ.


> > > > > I do find is the TCP_INFO ioctl, which offers this field in s=
truct tcp_info:
> > > > >=20
> > > > >         __u32   tcpi_unacked;
> > > > >=20
> > > > > Which comes from:
> > > > >=20
> > > > > struct tcp_sock {
> > > > > ...
> > > > >         u32     packets_out;    /* Packets which are "in flig=
ht"        */
> > > > > ...
> > > > > }
> > > > >=20
> > > > > If this becomes 0, perhaps this might tell me everything I se=
nt was acked?
> > > >=20
> > > > 0 means that there are noin-flight packets, which is effectivel=
y number
> > > > of unacked packets. So if your application waits for this field=
 to
> > > > become zero, it will wait for all sent packets to be acked.
> > >=20
> > > I use this type of strategy in nuttcp, and it seems to work fine.
> > > I have a loop with a small delay and a check of tcpi_unacked, and
> > > break out of the loop if tcpi_unacked becomes 0 or a defined time=
out
> > > period has passed.
> >=20
> > Checking tcpi_unacked alone won't be reliable. The peer might be sl=
ow=20
> > enough to advertize zero window for a short period of time and duri=
ng=20
> > that period you would have packets_out zero...
>=20
> I'll keep this in mind for the future, although it doesn't seem to
> be a significant issue in practice.  I use this scheme to try and
> account for the tcpi_total_retrans for the data stream, so if this
> corner case was hit, it would mean an under reporting of the total
> TCP retransmissions for the nuttcp test.
>=20
> If I understand you correctly, to hit this corner case, just after
> the final TCP write, there would have to be no packets in flight
> together with a zero TCP window.  To make it more bullet-proof, I
> guess after seeing a zero tcpi_unacked, an additional small delay
> should be performed, and then rechecking for a zero tcpi_unacked.
> I don't see anything else obvious (to me anyway) in the tcp_info
> that would be particularly helpful in handling this.

--=20
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

