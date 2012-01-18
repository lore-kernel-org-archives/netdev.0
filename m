From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bugzilla 42595
Date: Wed, 18 Jan 2012 14:44:09 +0100
Message-ID: <1326894249.2316.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F15D417.4050005@fud.no> <1326843827.2606.35.camel@edumazet-laptop>
	 <1326884311.2316.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36061 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757397Ab2ARNoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 08:44:13 -0500
Received: by wibhm6 with SMTP id hm6so2204670wib.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 05:44:12 -0800 (PST)
In-Reply-To: <1326884311.2316.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 11:58 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le mercredi 18 janvier 2012 =C3=A0 00:43 +0100, Eric Dumazet a =C3=A9=
crit :
> > Le mardi 17 janvier 2012 =C3=A0 21:03 +0100, Tore Anderson a =C3=A9=
crit :
> >=20
> > >=20
> > > 3) There seems to be a bug related to generating the TCP checksum=
 of
> > > SYN/ACK packets to destinations with the allfrag features set. I =
just
> > > submitted a bug report about this:
> > >=20
> > > https://bugzilla.kernel.org/show_bug.cgi?id=3D42595
> > >=20
> > > This makes the allfrag feature pretty much useless for me, as I c=
an only
> > > successfully establish a single TCP session from a client behind =
a <1280
> > > MTU link for the entire lifetime of the routing cache entry.
> > >=20
> >=20
> > It seems we dont handle skb ip_summed CHECKSUM_PARTIAL=20
> > in ip6_fragment() slow_path
>=20
>=20
> and many drivers dont handle the presence of a frag header.
>=20
> if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_TCP)
>=20
> I suspect we'll have to compute the checksum in software...
>=20

=46ollowing patch seems to help for me, please test it ;)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d97e071..92ea301 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -791,6 +791,10 @@ slow_path_clean:
 	}
=20
 slow_path:
+	if ((skb->ip_summed =3D=3D CHECKSUM_PARTIAL) &&
+	    skb_checksum_help(skb))
+		goto fail;
+
 	left =3D skb->len - hlen;		/* Space per frame */
 	ptr =3D hlen;			/* Where to start from */
=20
