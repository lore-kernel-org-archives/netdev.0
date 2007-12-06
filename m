From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TCP event tracking via netlink...
Date: Thu, 6 Dec 2007 09:23:12 -0800
Message-ID: <20071206092312.79a83208@freepuppy.rosehill>
References: <20071205.053031.87154402.davem@davemloft.net>
	<Pine.LNX.4.64.0712051533050.3119@kivilampi-30.cs.helsinki.fi>
	<20071206.023346.256200942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50097 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbXLFRYS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 12:24:18 -0500
In-Reply-To: <20071206.023346.256200942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Dec 2007 02:33:46 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: "Ilpo_J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 6 Dec 2007 01:18:28 +0200 (EET)
>=20
> > On Wed, 5 Dec 2007, David Miller wrote:
> >=20
> > > I assume you're using something like carefully crafted printk's,
> > > kprobes, or even ad-hoc statistic counters.  That's what I used t=
o do
> > > :-)
> >=20
> > No, that's not at all what I do :-). I usually look time-seq graphs=
=20
> > expect for the cases when I just find things out by reading code (o=
r
> > by just thinking of it).
>=20
> Can you briefly detail what graph tools and command lines
> you are using?
>=20
> The last time I did graphing to analyze things, the tools
> were hit-or-miss.
>=20
> > Much of the info is available in tcpdump already, it's just hard to=
 read=20
> > without graphing it first because there are some many overlapping t=
hings=20
> > to track in two-dimensional space.
> >=20
> > ...But yes, I have to admit that couple of problems come to my mind
> > where having some variable from tcp_sock would have made the proble=
m
> > more obvious.
>=20
> The most important are the cwnd and ssthresh, which you could guess
> using graphs but it is important to know on a packet to packet
> basis why we might have sent a packet or not because this has
> rippling effects down the rest of the RTT.
>=20
> > Not sure what is the benefit of having distributions with it becaus=
e=20
> > those people hardly report problems anyway to here, they're just to=
o=20
> > happy with TCP performance unless we print something to their logs,
> > which implies that we must setup a *_ON() condition :-(.
>=20
> That may be true, but if we could integrate the information with
> tcpdumps, we could gather internal state using tools the user
> already has available.
>=20
> Imagine if tcpdump printed out:
>=20
> 02:26:14.865805 IP $SRC > $DEST: . 11226:12686(1460) ack 0 win 108
> 	ss_thresh: 129 cwnd: 133 packets_out: 132
>=20
> or something like that.
>=20
> > Some problems are simply such that things cannot be accurately veri=
fied=20
> > without high processing overhead until it's far too late (eg skb bi=
ts vs=20
> > *_out counters). Maybe we should start to build an expensive state=20
> > validator as well which would automatically check invariants of the=
 write=20
> > queue and tcp_sock in a straight forward, unoptimized manner? That =
would=20
> > definately do a lot of work for us, just ask people to turn it on a=
nd it=20
> > spits out everything that went wrong :-) (unless they really depend=
 on=20
> > very high-speed things and are therefore unhappy if we scan thousan=
ds of=20
> > packets unnecessarily per ACK :-)). ...Early enough! ...That would =
work=20
> > also for distros but there's always human judgement needed to decid=
e=20
> > whether the bug reporter will be happy when his TCP processing does=
 no=20
> > longer scale ;-).
>=20
> I think it's useful as a TCP_DEBUG config option or similar, sure.
>=20
> But sometimes the algorithms are working as designed, it's just that
> they provide poor pipe utilization and CWND analysis embedded inside
> of a tcpdump would be one way to see that as well as determine the
> flaw in the algorithm.
>=20
> > ...Hopefully you found any of my comments useful.
>=20
> Very much so, thanks.
>=20
> I put together a sample implementation anyways just to show the idea,
> against net-2.6.25 below.
>=20
> It is untested since I didn't write the userland app yet to see that
> proper things get logged.  Basically you could run a daemon that
> writes per-connection traces into files based upon the incoming
> netlink events.  Later, using the binary pcap file and these traces,
> you can piece together traces like the above using the timestamps
> etc. to match up pcap packets to ones from the TCP logger.
>=20
> The userland tools could do analysis and print pre-cooked state diff
> logs, like "this ACK raised CWND by one" or whatever else you wanted
> to know.
>=20
> It's nice that an expert like you can look at graphs and understand,
> but we'd like to create more experts and besides reading code one
> way to become an expert is to be able to extrace live real data
> from the kernel's working state and try to understand how things
> got that way.  This information is permanently lost currently.


Tools and scripts for testing that generate graphs are at:
	git://git.kernel.org/pub/scm/tcptest/tcptest
