From: David Miller <davem@davemloft.net>
Subject: Re: NULL dereference in econet AUN-over-UDP receive
Date: Wed, 08 Dec 2010 18:02:15 -0800 (PST)
Message-ID: <20101208.180215.193709862.davem@davemloft.net>
References: <20101209003015.GA27906@ksplice.com>
	<1291858667.2795.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nelhage@ksplice.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753412Ab0LICBs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 21:01:48 -0500
In-Reply-To: <1291858667.2795.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Dec 2010 02:37:47 +0100

> Le mercredi 08 d=E9cembre 2010 =E0 19:30 -0500, Nelson Elhage a =E9cr=
it :
>> While testing one of my econet reproducers on a patched kernel, I tr=
iggered a
>> NULL pointer dereference in the econet AUN-over-UDP receive path. Up=
on further
>> investigation, I now suspect that this code path hasn't worked at al=
l in years.
>>=20
>> A copy of the oops is below for your reference, but here's my analys=
is:
>>=20
>> When aun_data_available receives a data packet (ah->code =3D=3D 2), =
it calls
>> aun_incoming to process the skb. The start of aun_incoming looks lik=
e:
>>=20
>> static void aun_incoming(struct sk_buff *skb, struct aunhdr *ah, siz=
e_t len)
>> {
>> 	struct iphdr *ip =3D ip_hdr(skb);
>> 	unsigned char stn =3D ntohl(ip->saddr) & 0xff;
>> 	struct sock *sk =3D NULL;
>> 	struct sk_buff *newskb;
>> ---> 	struct ec_device *edev =3D skb->dev->ec_ptr;   =20
>>=20
>=20
> This can be changed to use skb_dst(skb)->dev instead
>=20
> struct dst *dst =3D skb_dst(skb);
>=20
> if (dst) {
> 	dev =3D dst->dev;
> 	...
> }

Nelson please test if this patch fixes your crash:

econet: Fix crash in aun_incoming().

Unconditional use of skb->dev won't work here,
try to fetch the econet device via skb_dst()->dev
instead.

Suggested by Eric Dumazet.

Reported-by: Nelson Elhage <nelhage@ksplice.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index f180371..15dcc1a 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -851,9 +851,13 @@ static void aun_incoming(struct sk_buff *skb, stru=
ct aunhdr *ah, size_t len)
 {
 	struct iphdr *ip =3D ip_hdr(skb);
 	unsigned char stn =3D ntohl(ip->saddr) & 0xff;
+	struct dst_entry *dst =3D skb_dst(skb);
+	struct ec_device *edev =3D NULL;
 	struct sock *sk =3D NULL;
 	struct sk_buff *newskb;
-	struct ec_device *edev =3D skb->dev->ec_ptr;
+
+	if (dst)
+		edev =3D dst->dev->ec_ptr;
=20
 	if (! edev)
 		goto bad;
