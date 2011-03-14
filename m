From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: fix transmission headers with frags=0
Date: Mon, 14 Mar 2011 14:56:17 +0100
Message-ID: <1300110977.3423.16.camel@edumazet-laptop>
References: <4D7E167E.2090807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>,
	Jens Laas <jens.laas@its.uu.se>,
	Voravit Tanyingyong <voravit@kth.se>
To: Daniel Turull <daniel.turull@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51578 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab1CNN4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 09:56:21 -0400
Received: by fxm17 with SMTP id 17so2911529fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 06:56:20 -0700 (PDT)
In-Reply-To: <4D7E167E.2090807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 14:22 +0100, Daniel Turull a =C3=A9crit :
> The headers of pktgen were incorrectly added in a pktgen packet
> without frags (frags=3D0). There was an offset in the pktgen headers.
>=20
> The cause was in reusing the pgh variable as a return variable in skb=
_put
> when adding the payload to the skb.
>=20
> A rename of the variable is done.
>=20
> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
> ---
> The PKTGEN magic (be9b e955) now starts in the correct offset.
> Before the patch, it was starting at the end of the packet (be9b)
>=20

not exactly, but offseted  +16 bytes
(sizeof(struct pktgen_hdr))

> Capture from tcpdump:
>=20
> before patch:
> 14:57:37.854812 IP 10.0.0.2.discard > 10.254.254.84.discard: UDP, len=
gth 18
> 	0x0000:  001b 2157 ed84 001b 215d 01d0 0800 4500
> 	0x0010:  002e 0004 0000 2011 8767 0a00 0002 0afe
> 	0x0020:  fe54 0009 0009 001a 0000 0000 0000 b072
> 	0x0030:  9102 00ea ffff 0010 0000 be9b
>=20
> after patch:
> 14:44:32.896048 IP 10.0.0.2.discard > 10.217.234.56.discard: UDP, len=
gth 18
> 	0x0000:  001b 2157 ed84 001b 215d 01d0 0800 4500
> 	0x0010:  002e 0000 0000 2011 9bac 0a00 0002 0ad9
> 	0x0020:  ea38 0009 0009 001a 0000 be9b e955 0000
> 	0x0030:  0001 4d7e 1b09 0005 5f23 af00
>=20
> ---
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index f0aec6c..5baa9d9 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2615,13 +2615,14 @@ static void pktgen_finalize_skb(struct pktgen=
_dev *pkt_dev, struct sk_buff *skb,
>  {
>  	struct timeval timestamp;
>  	struct pktgen_hdr *pgh;
> +	void *data;
> =20
>  	pgh =3D (struct pktgen_hdr *)skb_put(skb, sizeof(*pgh));
>  	datalen -=3D sizeof(*pgh);
> =20
>  	if (pkt_dev->nfrags <=3D 0) {
> -		pgh =3D (struct pktgen_hdr *)skb_put(skb, datalen);
> -		memset(pgh + 1, 0, datalen);
> +		data =3D skb_put(skb, datalen);
> +		memset(data + 1, 0, datalen);
>  	} else {
>  		int frags =3D pkt_dev->nfrags;
>  		int i, len;
> --

Good catch !

Hmm this patch is not correct, why memset(data + 1, ...) ?

Also, this patch is needed for net-next-2.6 only
(bug introduced by commit 26ad787962ef84677a48c560
(pktgen: speedup fragmented skbs)

I would avoid the "void *data;" declaration and just use following :

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f0aec6c..f727c83 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2620,7 +2620,7 @@ static void pktgen_finalize_skb(struct pktgen_dev=
 *pkt_dev, struct sk_buff *skb,
 	datalen -=3D sizeof(*pgh);
=20
 	if (pkt_dev->nfrags <=3D 0) {
-		pgh =3D (struct pktgen_hdr *)skb_put(skb, datalen);
+		skb_put(skb, datalen);
 		memset(pgh + 1, 0, datalen);
 	} else {
 		int frags =3D pkt_dev->nfrags;



or even :

		memset(skb_put(skb, datalen), 0, datalen);




