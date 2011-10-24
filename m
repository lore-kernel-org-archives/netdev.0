From: Dan Siemon <dan@coverfire.com>
Subject: Re: Flow classifier proto-dst and TOS (and proto-src)
Date: Sun, 23 Oct 2011 21:03:51 -0400
Message-ID: <1319418232.20602.16.camel@ganymede>
References: <1318697463.7169.21.camel@ganymede>
	 <1318831799.2500.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-OkBVF4QzgS4sEB1yziKq"
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.coverfire.com ([69.41.199.58]:51567 "EHLO
	alpha.coverfire.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab1JXBDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 21:03:54 -0400
In-Reply-To: <1318831799.2500.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OkBVF4QzgS4sEB1yziKq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-10-17 at 08:09 +0200, Eric Dumazet wrote:
> Le samedi 15 octobre 2011 =C3=A0 12:51 -0400, Dan Siemon a =C3=A9crit :
> > cls_flow.c: flow_get_proto_dst()
> >=20
> > The proto-dst key returns the destination port for UDP, TCP and a few
> > other protocols [see proto_ports_offset()]. For ICMP and IPIP it falls
> > back to:
> >=20
> > return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
> >=20
> > Since Linux maintains a dst_entry for each TOS value this causes the
> > returned value to be affected by the TOS which is unexpected and
> > probably broken.
>=20
> Hi Dan
>=20
> I think Patrick did this on purpose, because of of the lack of
> perturbation in cls_flow.c : If all these frames were mapped to a single
> flow, they might interfere with an other regular flow and hurt it.
>=20
> I dont qualify existing code as buggy. Its about fallback behavior
> anyway (I dont think its even documented)

Thanks for the review Eric.

Won't virtually all uses of proto-dst also use the dst key anyway? In
which case this fallback does nothing except make the TOS effect the
hash output because the dst will be the same and dst_entry would be the
same if it wasn't for the different TOS (by far the common case). I
don't see the value of the unintuitive behavior.

I'm not certain this is a problem but also note that including TOS will
mean that packets within a tunnel will be reordered if 'tos inherit' is
set on the tunnel and only the typical src,dst,proto,proto-src,proto-dst
is used. Again, probably not expected.

> If you have too many frames going to the fallback, then this classifier
> is probably not the one you should use ?

If you have significant traffic in tunnels then any 5-tuple approach is
going to present problems unless you look into the tunnel (like my other
patch :) )

> Hint : You can change your filter to use this classifier only on TCP/UDP
> trafic, and use another one on other protocols : Coupled to your qdisc
> rules, you even can limit to X percent the bandwidth allocated to this
> trafic
>=20
> We could argue that if TOS value of two packets is different, then
> packets belong to different flows as well. [ It seems we currently lack
> a FLOW_KEY_TOS : that could be a usefull addition ]



--=-OkBVF4QzgS4sEB1yziKq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCAAGBQJOpLl3AAoJEJKXGLoTP2w+tv0QAM2IrM9Wd0mgyUlIsWuBNsfo
tkve4+idHZJlElETlB4RA+0VNajwm518Q3l0afxpOzH9xrvrzD58Fr+SQQwC3/kW
VTp3rxtvvnDUKb41tkTXOvAHFEn5Rk8ceHVZveKR7gXZkh0Ns8XrZ2RBbI1PRWNR
h6nSrqpyeDDGKNzIlBDVeYCud/Xy4d5goRRTID1RqGgTt0T9kpZJosw5x1W6nC5l
jTt8b5bKztG89UsoQ06RisSGqFEDmqCjWYVnujz50jMqDn7FFKF91a9yp6FlvixG
0BlUDASMQG4E66gGAvNL+lcC9jDe6xqqr8N4tYuAeLs/JsMFdmdQrxERdK7X/euo
3uHlDVv6nvNStKbpghP08SJZ3OD15w8kqRtAF8DL+PBJd3TpngaIOHak49OXgBKX
97llB/ZYoe4gzOatYCxyUOZtlv9o18adfrW9Lsn7en2Hsp8+8vLj30mjrWwxUUcA
9BYNFaUBVR6vDIZRuVu46E1jpyjsbWaUslQdQt23JLzeY18IxXipGrxlp7KpCH1U
keOyQSrnOLuc+pxID6eRMmz7BY26c72tiN9iwiil4NCE3X682Q7vJ+bYZviSOEIF
qY3yi+Bf3fxBQ//JzEJQGtcuXKz42yez2tG5/fiVfpanJzCqw8C3NCwmxu467tVf
tl5z6Dl6B8OUgXFE70go
=iV2C
-----END PGP SIGNATURE-----

--=-OkBVF4QzgS4sEB1yziKq--
