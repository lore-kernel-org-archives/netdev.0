From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 02 Sep 2010 12:41:45 +0200
Message-ID: <1283424105.2454.311.camel@edumazet-laptop>
References: <20100830.095012.233695092.davem@davemloft.net>
	 <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local>
	 <20100901.145151.93454549.davem@davemloft.net>
	 <20100902083327.GA6246@ff.dom.local>
	 <1283419909.2454.137.camel@edumazet-laptop>
	 <20100902095502.GA8775@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65086 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab0IBKlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 06:41:50 -0400
Received: by wwj40 with SMTP id 40so637974wwj.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 03:41:48 -0700 (PDT)
In-Reply-To: <20100902095502.GA8775@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 09:55 +0000, Jarek Poplawski a =C3=A9=
crit :

>=20
> Exactly, but there is no "a single napi --> device mapping". And sky2
> uses the same model. So, there is only a question of cost of this tes=
t,
> and a question of probability of gro errors on collisions without suc=
h
> a test in normal use. (And if gro can never do such errors for other
> reasons?)

Two vlans might carry packets in different domains, with a clash of IP
space and TCP flows. Even with a probability of 0.000000001%, we cannot
ever merge two packets of different domains. Really !

napi->dev is not used in GRO path, as mentioned earlier,
but in napi_get_frags(), while not needed.

To make this very clear, I suggest following patch :

[PATCH net-next-2.6] gro: remove use of napi->dev

Only use of napi->dev in GRO stack is the one found in napi_get_frags()

We can remove it and use a plain dev_alloc_skb() call.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d8c43e7..607057a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3248,9 +3248,11 @@ struct sk_buff *napi_get_frags(struct napi_struc=
t *napi)
 	struct sk_buff *skb =3D napi->skb;
=20
 	if (!skb) {
-		skb =3D netdev_alloc_skb_ip_align(napi->dev, GRO_MAX_HEAD);
-		if (skb)
+		skb =3D dev_alloc_skb(GRO_MAX_HEAD + NET_IP_ALIGN);
+		if (skb) {
+			skb_reserve(skb, NET_IP_ALIGN);
 			napi->skb =3D skb;
+		}
 	}
 	return skb;
 }


