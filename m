From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: FW: Re: [PATCH v3 4/4] packet: Add pre-defragmentation support
 for ipv4
Date: Wed, 06 Jul 2011 17:18:09 +0200
Message-ID: <1309965489.2292.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1A61D8EA6755AF458F06EA669A4EC8182F05BCB0@JKLMAIL02.ixonos.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: =?ISO-8859-1?Q?Penttil=E4?= Mika <mika.penttila@ixonos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59864 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab1GFPSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 11:18:22 -0400
Received: by wyg8 with SMTP id 8so23563wyg.19
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 08:18:21 -0700 (PDT)
In-Reply-To: <1A61D8EA6755AF458F06EA669A4EC8182F05BCB0@JKLMAIL02.ixonos.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 juillet 2011 =C3=A0 14:06 +0000, Penttil=C3=A4 Mika a =C3=
=A9crit :
>=20
> > +static struct sk_buff *fanout_check_defrag(struct sk_buff *skb)
> > +{
> > +	const struct iphdr *iph;
> > +	u32 len;
> > +
> > +	if (skb->protocol !=3D htons(ETH_P_IP))
> > +		return skb;
> > +
> > +	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> > +		return skb;
> > +
> > +	iph =3D ip_hdr(skb);
> > +	if (iph->ihl < 5 || iph->version !=3D 4)
> > +		return skb;
> > +	if (!pskb_may_pull(skb, iph->ihl*4))
> > +		return skb;
> > +	iph =3D ip_hdr(skb);
> > +	len =3D ntohs(iph->tot_len);
> > +	if (skb->len < len || len < (iph->ihl * 4))
> > +		return skb;
> > +
> > +	if (ip_is_fragment(ip_hdr(skb))) {
> > +		skb =3D skb_clone(skb, GFP_ATOMIC);
>=20
> Isn't this leaking the original skb?

Yes, there are several problems here.

More fundamentally, there is a problem if two (or more) applications us=
e
=46ANOUT sockets.

Only one will get the defragmented packet.

We probably need to have separate frag lists, or adding/using skb->sk a=
s
a key.

Thanks


[PATCH] packet: fix a leak in fanout_check_defrag()

Reported-by: Penttil=C3=A4 Mika <mika.penttila@ixonos.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/packet/af_packet.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 41f0489..69238f6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -476,15 +476,20 @@ static struct sk_buff *fanout_check_defrag(struct=
 sk_buff *skb)
 		return skb;
=20
 	if (ip_is_fragment(ip_hdr(skb))) {
-		skb =3D skb_clone(skb, GFP_ATOMIC);
-		if (skb) {
-			if (pskb_trim_rcsum(skb, len))
-				return skb;
-			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-			if (ip_defrag(skb, IP_DEFRAG_AF_PACKET))
-				return NULL;
-			skb->rxhash =3D 0;
+		struct sk_buff *nskb =3D skb_clone(skb, GFP_ATOMIC);
+
+		if (!nskb)
+			return skb;
+		if (pskb_trim_rcsum(nskb, len)) {
+			kfree_skb(nskb);
+			return skb;
 		}
+		kfree_skb(skb);
+		skb =3D nskb;
+		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+		if (ip_defrag(skb, IP_DEFRAG_AF_PACKET))
+			return NULL;
+		skb->rxhash =3D 0;
 	}
 	return skb;
 }


