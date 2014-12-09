From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Tue, 09 Dec 2014 21:36:20 +0100
Message-ID: <2625472.GutY3xCvKT@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <3594382.qsqLZcX7yO@storm> <1418135209.14835.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:49007 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750723AbaLIUgX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 15:36:23 -0500
In-Reply-To: <1418135209.14835.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 9. Dezember 2014, 06:26:49 schrieb Eric Dumazet:
> On Tue, 2014-12-09 at 09:54 +0100, Thomas Jarosch wrote:
> > On Monday, 8. December 2014 23:20:42 Wolfgang Walter wrote:
> > > Am Freitag, 5. Dezember 2014, 05:26:25 schrieb Eric Dumazet:
> > > > On Fri, 2014-12-05 at 13:09 +0100, Wolfgang Walter wrote:
> > > > > Hello,
> > > > >=20
> > > > > as reverting this patch fixes this rather annoying problem: i=
s it
> > > > > dangerous to revert it as a workaround until the root cause i=
s
> > > > > found?
> > > >=20
> > > > Unfortunately no, this patch fixes a serious issue.
> > > >=20
> > > > We need to find the root cause of your problem instead of tryin=
g to
> > > > work
> > > > around it.
> > >=20
> > > I only wanted to use it as local workaround here.
> > >=20
> > >=20
> > > I looked a bit at at code. I'm not familiar with the network code=
,
> > > though
> > >=20
> > > :-).
> >=20
> > If it helps, I'm running the reverted patch on five production boxe=
s
> > hitherto without a hiccup. As far as I understood the original comm=
it
> > message, some packet counters might me wrong without it.
> >=20
> > @Eric: What could possibly go wrong(tm)? :)
>=20
> Crashes in TCP stack, because of packet count mismatches.
>=20
> The sk_can_gso() status is already tested in tcp_sendmsg() as a hint,
> since path behavior can dynamically be changed on existing flow :
>=20
> <start a TCP flow>
> ethtool -K eth0 tso off gso off
>=20
> In this case, core networking stack detects this and segments the
> packets _after_ TCP or IP stack, before they reach eth0.
>=20
> TCP stack does not have to know that something is changed right befor=
e
> giving a GSO packet to core networking stack, this would be racy by
> nature, as TCP does not know or control full path. Hopefully we do no=
t
> take RTNL for every packet we send in TCP !
>=20
> It seems XFRM triggers in a slow path something which is not correctl=
y
> handled.
>=20
> It is not correct to add a racy kludge in TCP fast path for this very
> unlikely case.
>=20
> I would disable TSO/GSO on xfrm, and problem should disappear.

How would that be done? I found no way to disable it especially for xfr=
m. I=20
disabled gso for the interface which serves the ipsec traffic but this =
does=20
not help. tcp still uses gso for the esp tunnel.

I put a view printk's in net/xfrm/xfrm_output.c and net/ipv4/tcp_output=
=2Ec. (I=20
try to understand where in the xfrm transformation gso is handeled).

What I can say yet is:

xfrm_output() is used with ipsec (esp) tunnel mode but at I never see g=
so=20
packets here. xfrm_output_gso() is never called.

Everytime tcp_set_skb_tso_segs() is called for a tcp connection over th=
e esp-
tunnel and it is a gso case then the tcp connection hangs. Those packet=
s=20
always have skb->len 1398 and mss_now is 1374. I see a call of xfrm_out=
put()=20
afterwards but for a packet of skb->len 52 (maybe ACK from other direct=
ion?).

As long as the tcp-connection over the ipsec-tunnel works and if I send=
 bulk=20
traffic xfrm_output() is called 3 times with packet skb->len 1426 and t=
hen one=20
time with 78 (maybe other direction?), don't know if that is of any int=
erest.


With non-ipsec-traffic gso works fine: in this case the skb->len() vari=
es a=20
lot and mss_now is always 1288.


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
