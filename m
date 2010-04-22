From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 00:16:25 -0700 (PDT)
Message-ID: <20100422.001625.200862474.davem@davemloft.net>
References: <1271830116.7895.1316.camel@edumazet-laptop>
	<20100421.225625.177238009.davem@davemloft.net>
	<1271920233.7895.4723.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45853
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789Ab0DVHQU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 03:16:20 -0400
In-Reply-To: <1271920233.7895.4723.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Apr 2010 09:10:33 +0200

> Le mercredi 21 avril 2010 =E0 22:56 -0700, David Miller a =E9crit :
>=20
>> Right, I've applied this, thanks.
>>=20
>> What we should probably do instead is call and NULL out the
>> DEV_GSO_CB() destructor.  Right?
>=20
> Yes, probably, I'll take a look at this if you want.

It might look something like this:

diff --git a/net/core/dev.c b/net/core/dev.c
index 9bf1ccc..13241da 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1892,6 +1892,20 @@ static inline void skb_orphan_try(struct sk_buff=
 *skb)
 		skb_orphan(skb);
 }
=20
+/*
+ * GSO packets need to be handled specially because such packets
+ * hold the normal SKB destructor in a backup pointer.
+ */
+static inline void skb_orphan_try_gso(struct sk_buff *skb)
+{
+	if (!skb_tx(skb)->flags) {
+		if (DEV_GSO_CB(skb)->destructor)
+			DEV_GSO_CB(skb)->destructor(skb);
+		DEV_GSO_CB(skb)->destructor =3D NULL;
+		skb->sk =3D NULL;
+	}
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1937,6 +1951,7 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
=20
+		skb_orphan_try_gso(skb);
 		rc =3D ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc !=3D NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
