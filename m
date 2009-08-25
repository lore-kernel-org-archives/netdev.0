From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 18:48:53 +0200
Message-ID: <4A9415F5.6020006@gmail.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>  <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com> <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org> <4A9403F0.2060301@gmail.com> <alpine.DEB.1.10.0908251135380.26329@gentwo.org> <4A940A10.60607@gmail.com> <alpine.DEB.1.10.0908251203220.26329@gentwo.org> <4A9410E9.6090602@gmail.com> <
 alpine.DEB.1.10.0908251230430.26329@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39198 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbZHYQtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 12:49:05 -0400
In-Reply-To: <alpine.DEB.1.10.0908251230430.26329@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 25 Aug 2009, Eric Dumazet wrote:
>=20
>>> I read this just yesterday. IP_RECVERR means that the application w=
ants to
>>> see details on each loss. We just want some counters that give us a=
ccurate
>>> statistics to gauge where packet loss is occurring. Applications ar=
e
>>> usually not interested in tracking the fate of each packet.
>> Yep,  but IP_RECVERR also has the side effect of letting kernel retu=
rns -ENOBUFS error
>> in sending and congestion, which was your initial point :)
>=20
> The initial point was that the SNMP counters are not updated if IP_RE=
CVERR
> is not set which is clearly a bug and your and my patch addresses tha=
t.

Technically speaking, the send() syscall is in error. Frame is not sent=
, so
there is no drop at all. Like trying to send() from a bad user buffer, =
or write()
to a too big file...


>=20
> Then Sridhar noted that there are other tx drop counters. qdisc count=
ers
> are also not updated. Wish we would maintain tx drops counters there =
as
> well so that we can track down which NIC drops it.
>=20
> Then came the wishlist of UDP counters for tx drops and socket based
> tx_drop accounting for tuning and tracking down which app is sending
> too fast .... ;-)
>=20
> The apps could be third party apps. Just need to be able to troublesh=
oot
> packet loss.
>=20

Question is : should we just allow send() to return an error (-ENOBUF) =
regardless
of IP_RECVERR being set or not ? I dont think it would be so bad after =
all.
Most apps probably dont care, or already handle the error.

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7d08210..afae0cb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1302,7 +1302,7 @@ int ip_push_pending_frames(struct sock *sk)
 	err =3D ip_local_out(skb);
 	if (err) {
 		if (err > 0)
-			err =3D inet->recverr ? net_xmit_errno(err) : 0;
+			err =3D net_xmit_errno(err);
 		if (err)
 			goto error;
 	}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 87f8419..a7e5f93 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1526,7 +1526,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	err =3D ip6_local_out(skb);
 	if (err) {
 		if (err > 0)
-			err =3D np->recverr ? net_xmit_errno(err) : 0;
+			err =3D net_xmit_errno(err);
 		if (err)
 			goto error;
 	}
