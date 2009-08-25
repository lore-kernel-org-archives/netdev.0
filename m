From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 11:38:20 -0700
Message-ID: <1251225500.3169.38.camel@w-sridhar.beaverton.ibm.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>
	 <4A89C026.4030402@us.ibm.com>
	 <alpine.DEB.1.10.0908171642500.20399@gentwo.org>
	 <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
	 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908171848370.15956@gentwo.org>
	 <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908241334230.30487@gentwo.org>
	 <4A930DEF.5000008@gmail.com>
	 <alpine.DEB.1.10.0908250945460.5972@gentwo.org>
	 <4A93EB9B.5020600@gmail.com>
	 <alpine.DEB.1.10.0908250958540.28552@gentwo.org>
	 <4A9403F0.2060301@gmail.com>
	 <alpine.DEB.1.10.0908251135380.26329@gentwo.org> <4A940A10.60607@gmail.com>
	 <alpine.DEB.1.10.0908251203220.26329@gentwo.org>
	 <4A9410E9.6090602@gmail.com>
	 <alpine.DEB.1.10.0908251230430.26329@gentwo.org>
	 <4A9415F5.6020006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:33698 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755581AbZHYSii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 14:38:38 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7PIXVeb024195
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 12:33:31 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7PIcQxS226730
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 12:38:27 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7PIcMxI028161
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 12:38:22 -0600
In-Reply-To: <4A9415F5.6020006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-08-25 at 18:48 +0200, Eric Dumazet wrote:
> Christoph Lameter a =C3=A9crit :
> > On Tue, 25 Aug 2009, Eric Dumazet wrote:
> >=20
> >>> I read this just yesterday. IP_RECVERR means that the application=
 wants to
> >>> see details on each loss. We just want some counters that give us=
 accurate
> >>> statistics to gauge where packet loss is occurring. Applications =
are
> >>> usually not interested in tracking the fate of each packet.
> >> Yep,  but IP_RECVERR also has the side effect of letting kernel re=
turns -ENOBUFS error
> >> in sending and congestion, which was your initial point :)
> >=20
> > The initial point was that the SNMP counters are not updated if IP_=
RECVERR
> > is not set which is clearly a bug and your and my patch addresses t=
hat.
>=20
> Technically speaking, the send() syscall is in error. Frame is not se=
nt, so
> there is no drop at all. Like trying to send() from a bad user buffer=
, or write()
> to a too big file...
>=20
>=20
> >=20
> > Then Sridhar noted that there are other tx drop counters. qdisc cou=
nters
> > are also not updated. Wish we would maintain tx drops counters ther=
e as
> > well so that we can track down which NIC drops it.
> >=20
> > Then came the wishlist of UDP counters for tx drops and socket base=
d
> > tx_drop accounting for tuning and tracking down which app is sendin=
g
> > too fast .... ;-)
> >=20
> > The apps could be third party apps. Just need to be able to trouble=
shoot
> > packet loss.
> >=20
>=20
> Question is : should we just allow send() to return an error (-ENOBUF=
) regardless
> of IP_RECVERR being set or not ? I dont think it would be so bad afte=
r all.
> Most apps probably dont care, or already handle the error.

This patch would allow tracking drops at UDP level too via UDP_MIB_SNDB=
UFERRORS
that is incremented in udp_sendmsg(). Right now this happens only if IP=
_RECVERR
is set on the socket.

Ideally, it would be good to track the drops at qdisc, IP and UDP if a
packet is passed all the way to dev_queue_xmit() and then dropped.

Thanks
Sridhar


> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 7d08210..afae0cb 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1302,7 +1302,7 @@ int ip_push_pending_frames(struct sock *sk)
>  	err =3D ip_local_out(skb);
>  	if (err) {
>  		if (err > 0)
> -			err =3D inet->recverr ? net_xmit_errno(err) : 0;
> +			err =3D net_xmit_errno(err);
>  		if (err)
>  			goto error;
>  	}
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 87f8419..a7e5f93 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1526,7 +1526,7 @@ int ip6_push_pending_frames(struct sock *sk)
>  	err =3D ip6_local_out(skb);
>  	if (err) {
>  		if (err > 0)
> -			err =3D np->recverr ? net_xmit_errno(err) : 0;
> +			err =3D net_xmit_errno(err);
>  		if (err)
>  			goto error;
>  	}

