From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Wed, 9 Mar 2011 22:28:39 +0100
Message-ID: <20110309212839.GA1367@xanadu.blop.info>
References: <il4vur$3ka$1@dough.gmane.org>
 <20110308111011.GA27967@xanadu.blop.info>
 <4D764AAC.30302@ncsu.edu>
 <20110308.114346.48506864.davem@davemloft.net>
 <20110308152103.714f5f05@nehalam>
 <4D76D851.4050600@ncsu.edu>
 <20110309065319.GA23740@xanadu.blop.info>
 <20110309095659.1373c296@s6510>
 <20110309182505.GA25272@xanadu.blop.info>
 <20110309115630.5aba9314@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Injong Rhee <rhee@ncsu.edu>, David Miller <davem@davemloft.net>,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	sangtae.ha@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:33806 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752897Ab1CIV1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 16:27:49 -0500
Content-Disposition: inline
In-Reply-To: <20110309115630.5aba9314@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/11 at 11:56 -0800, Stephen Hemminger wrote:
> On Wed, 9 Mar 2011 19:25:05 +0100
> Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:
>=20
> > On 09/03/11 at 09:56 -0800, Stephen Hemminger wrote:
> > > On Wed, 9 Mar 2011 07:53:19 +0100
> > > Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:
> > >=20
> > > > On 08/03/11 at 20:30 -0500, Injong Rhee wrote:
> > > > > Now, both tools can be wrong. But that is not catastrophic si=
nce
> > > > > congestion avoidance can kick in to save the day. In a pipe w=
here no
> > > > > other flows are competing, then exiting slow start too early =
can
> > > > > slow things down as the window can be still too small. But th=
at is
> > > > > in fact when delays are most reliable. So those tests that sa=
y bad
> > > > > performance with hystart are in fact, where hystart is suppos=
ed to
> > > > > perform well.
> > > >=20
> > > > Hi,
> > > >=20
> > > > In my setup, there is no congestion at all (except the buffer b=
loat).
> > > > Without Hystart, transferring 8 Gb of data takes 9s, with CUBIC=
 exiting
> > > > slow start at ~2000 packets.
> > > > With Hystart, transferring 8 Gb of data takes 19s, with CUBIC e=
xiting
> > > > slow start at ~20 packets.
> > > > I don't think that this is "hystart performing well". We could =
just as
> > > > well remove slow start completely, and only do congestion avoid=
ance,
> > > > then.
> > > >=20
> > > > While I see the value in Hystart, it's clear that there are som=
e flaws
> > > > in the current implementation. It probably makes sense to disab=
le
> > > > hystart by default until those problems are fixed.
> > >=20
> > > What is the speed and RTT time of your network?
> > > I think you maybe blaming hystart for other issues in the network=
=2E
> >=20
> > What kind of issues?
> >=20
> > Host1 is connected through a gigabit ethernet LAN to Router1
> > Host2 is connected through a gigabit ethernet LAN to Router2
> > Router1 and Router2 are connected through an experimentation networ=
k at
> > 10 Gb/s
> > RTT between Host1 and Host2 is 11.3ms.
> > The network is not congested.
> >=20
> > (I can provide access to the testbed if someone wants to do further
> > testing)
>=20
> Your backbone is faster than the LAN, interesting.
> Could you check packet stats to see where packet drop is occuring?
> It could be that routers don't have enough buffering to take packet
> trains from 10G network and pace them out to 1G network.

I don't have access to the routers to check the packet counts here.
However, according to "netstat -s" on the sender(s), no retransmissions
are occuring, whether hystart is enabled or not: the host can just send
data at the network rate without experiencing congestion anywhere. Also=
,
it is unlikely that transient congestion in the backbone is an issue
according to the monitoring tools I have access to.

(Replying to your other mail as well)
> By my calculations (1G * 11.3ms) gives BDP of 941 packets which means
> CUBIC would ideally exit slow start at 900 or so packets. Old CUBIC
> slowstrart of 2000 packets means there is huge overshoot which means
> large packet loss burst which would cause a large CPU load on receive=
r
> processing SACK.

Since the network capacity is higher or equal to the network capacity o=
n
the host, there's no reason why losses would occur if there's no
congestion caused by other traffic, right?

> I assume you haven't done anything that would disable RFC1323
> support like turn off window scaling or tcp timestamps.

No, nothing strange that could cause different results.

I've tried to exclude hardware problems by using different parts of the
testbed (see map at
https://www.grid5000.fr/mediawiki/images/Renater5-g5k.jpg).  I used
machines in rennes, lille, lyon and grenoble today (using different
hardware). My original testing was done between rennes and nancy. The
same symptoms appear everywhere, in both directions, and disappear when
disabling hystart.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
