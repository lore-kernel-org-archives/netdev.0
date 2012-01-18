From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Wed, 18 Jan 2012 15:06:09 +0100
Message-ID: <1326895569.2316.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F15D417.4050005@fud.no> <1326831948.2606.2.camel@edumazet-laptop>
	 <00f1ef555b452980aae95eb3028072f8@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60897 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757529Ab2AROGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 09:06:14 -0500
Received: by bkas6 with SMTP id s6so2789165bka.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 06:06:12 -0800 (PST)
In-Reply-To: <00f1ef555b452980aae95eb3028072f8@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 13:42 +0100, Tore Anderson a =C3=A9c=
rit :
> * Eric Dumazet
>=20
> > Could you please test following patch ?
>=20
> Hi,
>=20
> It seems to work fine, now all the outgoing packets that includes a
> Fragmentation header all are "atomic" or "non-fragmented" fragments,
> i.e., that they both have Offset=3D0 and More Fragments=3D0.
>=20
> I'm uploaded a tcpdump showing the traffic with the patch here:
>=20
> https://bugzilla.kernel.org/attachment.cgi?id=3D72106
>=20
> Best regards,


Seems good, thanks !

Now I wonder if some RFC can allow us to send small frames without a
frag header, since this frag header forces us to perform tx checksum in
software.=20

I guess 576 should be safe ?

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d97e071..14cb938 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -153,7 +153,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 static int ip6_finish_output(struct sk_buff *skb)
 {
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
-	    dst_allfrag(skb_dst(skb)))
+	    (skb->len > 576 && dst_allfrag(skb_dst(skb))))
 		return ip6_fragment(skb, ip6_finish_output2);
 	else
 		return ip6_finish_output2(skb);
