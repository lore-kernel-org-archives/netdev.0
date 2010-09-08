From: David Miller <davem@davemloft.net>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 07 Sep 2010 20:18:43 -0700 (PDT)
Message-ID: <20100907.201843.179933180.davem@davemloft.net>
References: <20100906.223010.173858342.davem@davemloft.net>
	<1283859552.2338.402.camel@edumazet-laptop>
	<alpine.DEB.2.00.1009071443510.26447@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, leandroal@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756253Ab0IHDSZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 23:18:25 -0400
In-Reply-To: <alpine.DEB.2.00.1009071443510.26447@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 7 Sep 2010 15:15:25 +0300 (EEST)

[ Alexey, problem is that when receiver's maximum window is miniscule
  (f.e. equal to MSS :-), we never send full MSS sized frames due to
  our sender size SWS implementation. ]

> On Tue, 7 Sep 2010, Eric Dumazet wrote:
>=20
>> Le lundi 06 septembre 2010 =E0 22:30 -0700, David Miller a =E9crit :
>>=20
>>=20
>> > The small 78 byte window is why the sending system is splitting up=
 the
>> > writes into smaller pieces.
>> >=20
>> > I presume that the system advertises exactly a 78 byte window beca=
use
>> > this is how large the commands are.  But this is an extremely fool=
ish
>> > and baroque thing to do, and it's why you are having problems.
>>=20
>> I am not sure why TSO added a "Bound mss with half of window"
>> requirement for tcp_sync_mss()
>=20
> I've thought it is more related on window behavior in general and=20
> much much older than TSO (it certainly seems to be old one).
>=20
> I guess we might run to some SWS issue if MSS < rwin < 2*MSS with you=
r=20
> patch that are avoided by the current approach?

Right, this clamping is part of RFC1122 silly window syndrome avoidance=
=2E

In ancient times we used to do this straight in sendmsg(), which had
the comment:

			/* We also need to worry about the window.  If
			 * window < 1/2 the maximum window we've seen
			 * from this host, don't use it.  This is
			 * sender side silly window prevention, as
			 * specified in RFC1122.  (Note that this is
			 * different than earlier versions of SWS
			 * prevention, e.g. RFC813.).  What we
			 * actually do is use the whole MSS.  Since
			 * the results in the right edge of the packet
			 * being outside the window, it will be queued
			 * for later rather than sent.
			 */

But in January 2000, Alexey Kuznetsov moved this logic into tcp_sync_ms=
s().
netdev-vger-2.6 commit is:

--------------------
commit 214d457eb454a70f0f373371de044403834d8042
Author: davem <davem>
Date:   Tue Jan 18 08:24:09 2000 +0000

    Merge in bug fixes and small enhancements
    from Alexey for the TCP/UDP softnet mega-merge
    from the other day.
--------------------

Well, what is the SWS sender rule?  RFC1122 states that we should send
data if (wher U =3D=3D usable window, D =3D=3D data queued up but not y=
et sent):

1) if a maximum-sized segment can be sent, i.e, if:

   min(D,U) >=3D Eff.snd.MSS;

2)  or if the data is pushed and all queued data can
    be sent now, i.e., if:

        [SND.NXT =3D SND.UNA and] PUSHED and D <=3D U

    (the bracketed condition is imposed by the Nagle
    algorithm);

3)  or if at least a fraction Fs of the maximum window
    can be sent, i.e., if:

    [SND.NXT =3D SND.UNA and]

    min(D.U) >=3D Fs * Max(SND.WND);

4)  or if data is PUSHed and the override timeout
    occurs.

The recommmended value for the "Fs" fraction is 1/2, so that's where
the "one-half" logic comes from.

The current code implements this by pre-chopping the MSS to
half the largest window we've seen advertised by the peer, f.e.
when doing sendmsg() packetization.  Packets are packetized
to this 1/2 MAX_WINDOW MSS, represented by mss_now.

Then the send path SWS logic will send any packet that is at least
"mss_now".

Effectively we try to implement test #1 and #3 above at the same
time by just making test #1 and chopping the Eff.snd.MSS by half
the largest receive window we've seen advertised by the peer.

This strategy seems to break down when the peer's MSS and the maximum
receive window we'll ever see from the peer are the same order of
magnitude.

It seems that the conditions above really need to be checked in the
right order, and because we try to combine a later test (case #3) with
an earlier test (case #1) we don't send a full sized frame in this
special scenerio.
