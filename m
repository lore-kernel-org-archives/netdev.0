From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: PROBLEM: MTU of ipsec tunnel drops continuously until traffic
 stops
Date: Mon, 4 Jul 2016 13:12:02 +0200
Message-ID: <20160704111202.GI12335@gauss.secunet.com>
References: <1467598059395.19100@alliedtelesis.co.nz>
 <1467604370799.64629@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39940 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444AbcGDLMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 07:12:07 -0400
Content-Disposition: inline
In-Reply-To: <1467604370799.64629@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 04, 2016 at 03:52:50AM +0000, Matt Bennett wrote:
> *Resending as plain text so the mailing list accepts it.. Sorry Steff=
en and Herbert*
>=20
> =E2=80=8BHi,
>=20
> During long run testing of an ipsec tunnel over a PPP link it was fou=
nd that occasionally traffic would stop flowing over the tunnel. Eventu=
ally the traffic would start again, however using the command "ip route=
 flush cache"=C2=A0causes=C2=A0traffic to start flowing  again immediat=
ely.
>=20
> Note, I am=C2=A0using a 4.4.6 based kernel, however I see no major di=
fferences between 4.4.6 and 4.4.14 (current=C2=A0LTS) in any of the cod=
e I am debugging.=C2=A0I  have manually debugged the code as far as I c=
an, however I don't know the code well enough to make further progress.=
=C2=A0What I have uncovered is outlined below:
>=20
> By pinging the other end of the tunnel when the traffic stops flowing=
 I get messages like the following:
>=20
> 10-AR4050#ping 172.16.0.5
> PING 172.16.0.5 (172.16.0.5) 56(84) bytes of data.
> From 172.16.0.6 icmp_seq=3D1 Frag needed and DF set (mtu =3D 46)
> From 172.16.0.6 icmp_seq=3D2 Frag needed and DF set (mtu =3D 46)
>=20
> but this is weird considering (note the mtu values):
>=20
> [root@10-AR4050 /flash]# ip link
> 16778240: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1492 qd=
isc htb state UP mode DEFAULT group default qlen 3
> =C2=A0 =C2=A0 link/ppp=C2=A0
> 14: tunnel64@NONE: <POINTOPOINT,MULTICAST,UP,LOWER_UP> mtu 1200 qdisc=
 htb state UNKNOWN mode DEFAULT group default qlen=C2=A01
> =C2=A0 =C2=A0 link/ipip 203.0.113.10 peer 203.0.113.5
>=20
> The code that generates the ICMP_FRAG_NEEDED packet is vti_xmit()=C2=A0=
(ip_vti.c)=C2=A0where there is a check of skb length against the mtu of=
 dst entry. Since the mtu is lower than the packet (debug shows the mtu=
 is=C2=A046 as expected from the ping output) the ICMP  error is genera=
ted.

Semms like you use vti tunnels. Is tunnel64@NONE a vti device, and
if so did you set the mtu to 1200?

Not sure if it is related to your problem, but there was a recent
fix for vti pmtu handling. It was commit d6af1a31 ("vti: Add pmtu
handling to vti_xmit.") Do you have this on your branch?

>=20
> Digging further I find that when the issue occurs the mtu value is be=
ing updated in what appears to be an error case in xfrm_bundle_ok (xfrm=
_policy.c). Specifically the block of code:
>=20
> if (likely(!last))
>         return 1;
>=20
> is not hit meaning there is a difference between the cached mtu value=
 and the value just calculated. I then see this code being hit continuo=
usly and each time the mtu keeps getting lowered. i.e. (I don't know if=
 the drop by 80 bytes is significant)
>=20
> 1200
> 1118
> 1038
> 958
> 878
>  ....
> 46

I remember that we had a similar problem with IPsec when no
vti was used some years ago...

Unfortunately, today is my last office day before my vacation,
so no fix from me for the next two weeks.
