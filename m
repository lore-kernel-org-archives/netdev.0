From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Wed, 10 Dec 2014 19:34:49 +0100
Message-ID: <6700748.kZ07xrNvHX@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <2625472.GutY3xCvKT@h2o.as.studentenwerk.mhn.de> <1418161219.27198.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:59918 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932479AbaLJSew convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 13:34:52 -0500
In-Reply-To: <1418161219.27198.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 9. Dezember 2014, 13:40:19 schrieb Eric Dumazet:
> On Tue, 2014-12-09 at 21:36 +0100, Wolfgang Walter wrote:
> > How would that be done? I found no way to disable it especially for=
 xfrm.
> > I
> > disabled gso for the interface which serves the ipsec traffic but t=
his
> > does
> > not help. tcp still uses gso for the esp tunnel.
> >=20
> > I put a view printk's in net/xfrm/xfrm_output.c and net/ipv4/tcp_ou=
tput.c.
> > (I try to understand where in the xfrm transformation gso is handel=
ed).
> >=20
> > What I can say yet is:
> >=20
> > xfrm_output() is used with ipsec (esp) tunnel mode but at I never s=
ee gso
> > packets here. xfrm_output_gso() is never called.
> >=20
> > Everytime tcp_set_skb_tso_segs() is called for a tcp connection ove=
r the
> > esp- tunnel and it is a gso case then the tcp connection hangs. Tho=
se
> > packets always have skb->len 1398 and mss_now is 1374. I see a call=
 of
> > xfrm_output() afterwards but for a packet of skb->len 52 (maybe ACK=
 from
> > other direction?).
> >=20
> > As long as the tcp-connection over the ipsec-tunnel works and if I =
send
> > bulk traffic xfrm_output() is called 3 times with packet skb->len 1=
426
> > and then one time with 78 (maybe other direction?), don't know if t=
hat is
> > of any interest.
> >=20
> >=20
> > With non-ipsec-traffic gso works fine: in this case the skb->len() =
varies
> > a
> > lot and mss_now is always 1288.
>=20
> Presumably something happens so that sk_can_gso() returns false.
>=20
> But apparently, this happens _after_ tcp_sendmsg(), ie a bit too late=
=2E
>=20
> Note that after https://patchwork.ozlabs.org/patch/418506/ is applied=
,
> fix would simply be :
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index
> 9a56b2000c3f374fb95aedada3327447816a9512..678ef8393680dc781445c5f1217=
19ea8e
> a7bb7c1 100644 --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1585,6 +1585,8 @@ void sk_setup_caps(struct sock *sk, struct dst_=
entry
> *dst) sk->sk_gso_max_size =3D dst->dev->gso_max_size;
>  			sk->sk_gso_max_segs =3D dst->dev->gso_max_segs;
>  		}
> +	} else {
> +		sk->sk_gso_max_segs =3D 1;
>  	}
>  }
>  EXPORT_SYMBOL_GPL(sk_setup_caps);

Ok. I tried that. I backported https://patchwork.ozlabs.org/patch/41850=
6/ to=20
3.14.26 and then applied this patch. Still hangs. At that stage sk_can_=
gso(sk)=20
is true. The reason is that the interface of *dst in sk_setup_caps() is=
 the=20
interface which serves the ipsec traffic.

There is a difference, though. If I disable gso for the interface which=
 serves=20
the ipsec traffic then the hang disappears now. This seems to be becaus=
e of=20
the patch above: sk_can_gso(sk) in sk_setup_caps then returns false and=
 the ne=20
else branch is taken. So there may be a hidden bug in the non-gso case.

Back to xfrm case with hang:

I see: a call of sk_setup_caps() which takes the path
		sk->sk_route_caps |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
		...

So gso is on. When the hang happens sk_setup_caps is called from	=09
inet_sk_rebuild_header(). Now the path

		sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;

is taken as dst->header_len is now non zero.

This is the reason why later calls of sk_can_gso() return false.

I'll try to change the above patch to

@@ -1585,6 +1585,8 @@ void sk_setup_caps(struct sock *sk, struct dst_en=
try
*dst) sk->sk_gso_max_size =3D dst->dev->gso_max_size;
 			sk->sk_gso_max_segs =3D dst->dev->gso_max_segs;
 		}
	}
+   if (sk_can_gso(sk)) {
+		sk->sk_gso_max_segs =3D 1;
 	}
 }
 EXPORT_SYMBOL_GPL(sk_setup_caps);

so that the case that GSO is disabled because of dst->header_len !=3D 0=
 sets=20
sk_gso_max_segs, too.



Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
