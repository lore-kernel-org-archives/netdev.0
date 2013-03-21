From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Wed, 20 Mar 2013 21:52:33 -0700
Message-ID: <1363841553.3333.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:44055 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab3CUEwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 00:52:37 -0400
Received: by mail-pb0-f52.google.com with SMTP id ma3so1931714pbc.39
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 21:52:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

GRE TSO support doesn't increment the ID in the inner IP header.

Remove the ID check in inet_gro_receive() so that GRO can properly
aggregate GRE encapsulated TCP packets, instead of forcing
a flush for every packet.

Testing the IP ID is not really needed anyway for proper GRO operation.

We can use more readable (and faster) code to access tot_len and
frag_off fields.

Tested on a bnx2x setup after commit a848ade408b6b
(bnx2x: add CSUM and TSO support for encapsulation protocols)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dmitry Kravkov <dmitry@broadcom.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv4/af_inet.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9e5882c..302a47e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1355,7 +1355,6 @@ static struct sk_buff **inet_gro_receive(struct s=
k_buff **head,
 	const struct iphdr *iph;
 	unsigned int hlen;
 	unsigned int off;
-	unsigned int id;
 	int flush =3D 1;
 	int proto;
=20
@@ -1381,9 +1380,9 @@ static struct sk_buff **inet_gro_receive(struct s=
k_buff **head,
 	if (unlikely(ip_fast_csum((u8 *)iph, 5)))
 		goto out_unlock;
=20
-	id =3D ntohl(*(__be32 *)&iph->id);
-	flush =3D (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id ^ IP=
_DF));
-	id >>=3D 16;
+	flush =3D ntohs(iph->tot_len) ^ skb_gro_len(skb);
+
+	flush |=3D (__force u16)iph->frag_off ^ htons(IP_DF);
=20
 	for (p =3D *head; p; p =3D p->next) {
 		struct iphdr *iph2;
@@ -1400,11 +1399,9 @@ static struct sk_buff **inet_gro_receive(struct =
sk_buff **head,
 			continue;
 		}
=20
-		/* All fields must match except length and checksum. */
 		NAPI_GRO_CB(p)->flush |=3D
 			(iph->ttl ^ iph2->ttl) |
-			(iph->tos ^ iph2->tos) |
-			((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
+			(iph->tos ^ iph2->tos);
=20
 		NAPI_GRO_CB(p)->flush |=3D flush;
 	}
