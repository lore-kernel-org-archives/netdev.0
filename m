From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Tue, 19 Jul 2011 20:19:04 -0400
Message-ID: <20110720001904.GA1992@neilslaptop.think-freely.org>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311105738.3113.11.camel@edumazet-laptop>
 <20110719202922.GA2352@minipsycho>
 <1311108107.3113.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54913 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab1GTATT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 20:19:19 -0400
Content-Disposition: inline
In-Reply-To: <1311108107.3113.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2011 at 10:41:47PM +0200, Eric Dumazet wrote:
> Le mardi 19 juillet 2011 =E0 22:29 +0200, Jiri Pirko a =E9crit :
>=20
> > You are right, but it may not cause panic, right? In case this patc=
h
> > would cause significant performance regression, how about to just f=
orbid
> > pktgen to run on soft-netdevs ?
> >=20
>=20
> Please do
>=20
You are correct Eric, this can cause a significant performance regressi=
on, but I
think that beats causing a panic or other unexpected behavior.  I read =
your
previous threads with others regarding fixing this with vlans, but I do=
n't think
its fair to just say 'its fast, but it might cause oopses'.=20

And its not sufficient to simply forbid soft drivers to make use of pkt=
gen, its
not just a soft driver problem, its systemic.  Any driver which assumes=
 that it
has exclusive access to an skb submitted for transmit is at risk from p=
ktgen in
its current implementation.  That of course as a subset includes all th=
e soft
drivers, but others are also suceptible.  As examples (some of which I =
noted in
the origional post) virtio_net uses the skb->cb to hold vnet header inf=
ormation
which will be corrupted on sucessive sends.  bnx2x linearizes skbs unde=
r certain
circumstances, which means pktgen, if it marshals a fragmented frame wi=
ll not
send a fragmented frame after the first iteration.  The PPP and Slip dr=
ivers
skb_push the skb to prepend a header to the frame on send, meaning suce=
ssive
uses, up until they get an skb_under_panic will get iteratively more ma=
lformed
frames on the wire as ppp headers get stacked on top of one another.  T=
hese are
ust a few of the examples I've found.

The long and the short of it in my mind, is that we have a fundamental
disconnect between driver asumptions and pktgen.  If its ok to submit s=
hared
skbs to drivers, then we need to augment drivers that modify skbs on tr=
ansmit to
clone the skb (likey not an efficient solution), or if its not ok to do=
 so, we
need to change pktgen to not behave that way.

> Note : a sysadmin has other ways to make a machine panic or reboot or
> halt...
Yes, predictable ways, that the sysadmin can see coming based on what t=
hey're
doing (i.e. no one should be shocked if they dd /dev/random to /dev/kme=
m and get
a hang or panic, or if they issue a sysrq-c, etc).  This case is differ=
ent.  A
sysadmin reasonably expects pktgen to send the frames they configure on=
 the
interface they specify.  While its arguably reasonable to forsee that i=
t may not
work with soft interfaces, pktgen just won't work with some hardware dr=
ivers (as
per the examples above).  And it won't always be an oops, it may be occ=
asional
random behvaior in the output data, and its highly dependent not just o=
n the use
of pktgen, but rather the specific command(s) issued.


I'm sensitive to the performance impact, but I would much rather see a =
lower
performing pktgen that doesn't randomly crash, and bring the performanc=
e back up
in a safe, reliable way.  To that end, I've been starting to think abou=
t
pre-allocating a ring buffer of skbs with a skb->users count biased up =
to
prevent driver freeing.  That way we could detect 'unused skb's' by a u=
ser count
that was at the bias level.  Thoughts?

Neil

>=20
>=20
>=20
>=20
