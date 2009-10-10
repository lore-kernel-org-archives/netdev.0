From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
 (v3)
Date: Sat, 10 Oct 2009 07:12:10 +0200
Message-ID: <4AD017AA.3060504@gmail.com>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <20091009235631.GA31501@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52284 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbZJJFM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 01:12:57 -0400
In-Reply-To: <20091009235631.GA31501@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Ok, take 3 with Erics new notes
>=20
> Change Notes:
>=20
> 1) Modified inlining of sock_recv_ts_and_drops to be more efficient
>=20
> 2) modify getsockopt for SO_RXQ_OVFL to gurantee only a 1 or 0 return
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
>=20
> Create a new socket level option to report number of queue overflows
>=20
> Recently I augmented the AF_PACKET protocol to report the number of f=
rames lost
> on the socket receive queue between any two enqueued frames.  This va=
lue was
> exported via a SOL_PACKET level cmsg.  AFter I completed that work it=
 was
> requested that this feature be generalized so that any datagram orien=
ted socket
> could make use of this option.  As such I've created this patch, It c=
reates a
> new SOL_SOCKET level option called SO_RXQ_OVFL, which when enabled ex=
ports a
> SOL_SOCKET level cmsg that reports the nubmer of times the sk_receive=
_queue
> overflowed between any two given frames.  It also augments the AF_PAC=
KET
> protocol to take advantage of this new feature (as it previously did =
not touch
> sk->sk_drops, which this patch uses to record the overflow count).  T=
ested
> successfully by me.
>=20
> Notes:

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -951,7 +951,7 @@ try_again:
>  		UDP_INC_STATS_USER(sock_net(sk),
>  				UDP_MIB_INDATAGRAMS, is_udplite);
> =20
> -	sock_recv_timestamp(msg, sk, skb);
> +	sock_recv_ts_and_drops(msg, sk, skb);
> =20
>  	/* Copy the address. */
>  	if (sin) {


As a followup to my patch about udp_poll(), I realize we dont atomic_in=
c(&sk->sk_drops)
in the event a packet is dropped because of a bad checksum.

I'll post a fixup once David reviewed previous patch

