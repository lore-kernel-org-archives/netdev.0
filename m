From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 00:41:36 -0700 (PDT)
Message-ID: <20100422.004136.151480121.davem@davemloft.net>
References: <1271921045.7895.4763.camel@edumazet-laptop>
	<20100422.002623.00784210.davem@davemloft.net>
	<1271921637.7895.4791.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47252
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750714Ab0DVHlc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 03:41:32 -0400
In-Reply-To: <1271921637.7895.4791.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Apr 2010 09:33:57 +0200

> Le jeudi 22 avril 2010 =E0 00:26 -0700, David Miller a =E9crit :
>> @@ -1865,6 +1865,7 @@ static int dev_gso_segment(struct sk_buff *skb=
)
>>  	int features =3D dev->features & ~(illegal_highdma(dev, skb) ?
>>  					 NETIF_F_SG : 0);
>> =20
>> +	skb_orphan_try(skb);
>>  	segs =3D skb_gso_segment(skb, features);
>> =20
>>  	/* Verifying header integrity only. */
>=20
> Yes, it seems better.
>=20
> What about the=20
>=20
> if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> 	skb_dst_drop(skb);
>=20
> This thing might also be moved before the split, since split probably
> clone all dst ?

Good catch, agreed.

diff --git a/net/core/dev.c b/net/core/dev.c
index 3ba774b..4f897e2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1851,6 +1851,17 @@ static void dev_gso_skb_destructor(struct sk_buf=
f *skb)
 		cb->destructor(skb);
 }
=20
+/*
+ * Try to orphan skb early, right before transmission by the device.
+ * We cannot orphan skb if tx timestamp is requested, since
+ * drivers need to call skb_tstamp_tx() to send the timestamp.
+ */
+static inline void skb_orphan_try(struct sk_buff *skb)
+{
+	if (!skb_tx(skb)->flags)
+		skb_orphan(skb);
+}
+
 /**
  *	dev_gso_segment - Perform emulated hardware segmentation on skb.
  *	@skb: buffer to segment
@@ -1865,6 +1876,7 @@ static int dev_gso_segment(struct sk_buff *skb)
 	int features =3D dev->features & ~(illegal_highdma(dev, skb) ?
 					 NETIF_F_SG : 0);
=20
+	skb_orphan_try(skb);
 	segs =3D skb_gso_segment(skb, features);
=20
 	/* Verifying header integrity only. */
@@ -1881,17 +1893,6 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
 }
=20
-/*
- * Try to orphan skb early, right before transmission by the device.
- * We cannot orphan skb if tx timestamp is requested, since
- * drivers need to call skb_tstamp_tx() to send the timestamp.
- */
-static inline void skb_orphan_try(struct sk_buff *skb)
-{
-	if (!skb_tx(skb)->flags)
-		skb_orphan(skb);
-}
-
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1902,13 +1903,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, str=
uct net_device *dev,
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
=20
-		if (netif_needs_gso(dev, skb)) {
-			if (unlikely(dev_gso_segment(skb)))
-				goto out_kfree_skb;
-			if (skb->next)
-				goto gso;
-		}
-
 		/*
 		 * If device doesnt need skb->dst, release it right now while
 		 * its hot in this cpu cache
@@ -1916,6 +1910,13 @@ int dev_hard_start_xmit(struct sk_buff *skb, str=
uct net_device *dev,
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(skb);
=20
+		if (netif_needs_gso(dev, skb)) {
+			if (unlikely(dev_gso_segment(skb)))
+				goto out_kfree_skb;
+			if (skb->next)
+				goto gso;
+		}
+
 		skb_orphan_try(skb);
 		rc =3D ops->ndo_start_xmit(skb, dev);
 		if (rc =3D=3D NETDEV_TX_OK)
