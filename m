From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 00:02:23 +0200
Message-ID: <4A930DEF.5000008@gmail.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>  <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58035 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbZHXWC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 18:02:57 -0400
In-Reply-To: <alpine.DEB.1.10.0908241334230.30487@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Mon, 17 Aug 2009, Sridhar Samudrala wrote:
>=20
>> So it is possible that there is some other place in the stack where =
the packets
>> are gettting dropped but not counted.
>=20
> Such a deed occurs in ip_push_pending_frames():
>=20
>         /* Netfilter gets whole the not fragmented skb. */
>         err =3D ip_local_out(skb);
>         if (err) {
>                 if (err > 0)
>                         err =3D inet->recverr ? net_xmit_errno(err) :=
 0;
> 			^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>                 if (err)
>                         goto error;
>         }
>=20
> out:
>         ip_cork_release(inet);
>         return err;
>=20
> error:
>         IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
>         goto out;
>=20
>=20
> So if ip_local_out returns NET_XMIT_DROP then its simply going to be
> replaced by 0. Then we check err again and there is no error!!!!
>=20
> The statistics are only generated if IP_RECVERR is set.
>=20
> Could we move the increment of IPSTATS_MIB_OUTDISCARDS up so that it
> is incremented regardless of the setting of IP_RECVERR?
>=20
> F.e?
>=20
>=20
> Subject: Report TX drops
>=20
> Incrementing of TX drop counters currently does not work if errors fr=
om the
> network stack are suppressed (IP_RECVERR off). Increment the statisti=
cs
> independently of the setting of IP_RECVERR.
>=20
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
>=20
> ---
>  net/ipv4/ip_output.c |   19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
>=20
> Index: linux-2.6/net/ipv4/ip_output.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/net/ipv4/ip_output.c	2009-08-24 17:04:27.000000000=
 +0000
> +++ linux-2.6/net/ipv4/ip_output.c	2009-08-24 17:32:05.000000000 +000=
0
> @@ -1300,20 +1300,21 @@ int ip_push_pending_frames(struct sock *
>=20
>  	/* Netfilter gets whole the not fragmented skb. */
>  	err =3D ip_local_out(skb);
> -	if (err) {
> -		if (err > 0)
> -			err =3D inet->recverr ? net_xmit_errno(err) : 0;
> -		if (err)
> -			goto error;
> +	if (err > 0) {
> +		/* The packet was dropped by the network subsystem */
> +		IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
> +
> +		/*
> +		 * Errors are not passed on if the socket
> +		 * does not process errors (see IP_RECVERR).
> +		 * net_xmit_errno filters NET_XMIT_CN.
> +		 */
> +		err =3D inet->recverr ? net_xmit_errno(err) : 0;
>  	}
>=20
>  out:
>  	ip_cork_release(inet);
>  	return err;
> -
> -error:
> -	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
> -	goto out;
>  }
>=20
>  /*
>=20
>=20
>=20
>=20

NET_XMIT_CN strikes again :)

Well, if ip_local_out() returns a negative error (say -EPERM for exampl=
e),
 your patch disables OUTDISCARDS increments.

Maybe a simpler patch like this one ?

[PATCH] net: correctly updates OUTDISCARDS in ip_push_pending_frames()

ip_push_pending_frames() can fail to send a frame because of a congesti=
oned
device. In this case, we increment SNMP OUTDISCARDS only if user set
IP_RECVERR, which is not RFC conformant.

Only case where we should not update OUTDISCARDS is when
ip_local_output() return value is NET_XMIT_CN (meaning
skb was xmitted but future frames might be dropped)

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7d08210..27a5b79 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1301,19 +1301,15 @@ int ip_push_pending_frames(struct sock *sk)
 	/* Netfilter gets whole the not fragmented skb. */
 	err =3D ip_local_out(skb);
 	if (err) {
+		if (err !=3D NET_XMIT_CN)
+			IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
 		if (err > 0)
 			err =3D inet->recverr ? net_xmit_errno(err) : 0;
-		if (err)
-			goto error;
 	}
=20
 out:
 	ip_cork_release(inet);
 	return err;
-
-error:
-	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
-	goto out;
 }
=20
 /*
