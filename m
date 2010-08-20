From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] irda: fix a race in irlan_eth_xmit()
Date: Fri, 20 Aug 2010 11:51:33 +0200
Message-ID: <1282297893.2484.14.camel@edumazet-laptop>
References: <1282127083.2194.45.camel@edumazet-laptop>
	 <20100819.004202.84378290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46391 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab0HTJvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 05:51:39 -0400
Received: by wyb32 with SMTP id 32so3388718wyb.19
        for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 02:51:37 -0700 (PDT)
In-Reply-To: <20100819.004202.84378290.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 ao=C3=BBt 2010 =C3=A0 00:42 -0700, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 18 Aug 2010 12:24:43 +0200
>=20
> > After skb is queued, its illegal to dereference it.
> >=20
> > Cache skb->len into a temporary variable.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks.

Thanks David

On top of this patch (that you added in net-2.6 if I understood well), =
I
cooked following one, for net-next-2.6 this time.

[PATCH net-next-2.6] irda: use net_device_stats from struct net_device

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in the irlan_cb struct.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/irda/irlan_common.h |    1=20
 net/irda/irlan/irlan_eth.c      |   32 ++++++++----------------------
 2 files changed, 9 insertions(+), 24 deletions(-)

diff --git a/include/net/irda/irlan_common.h b/include/net/irda/irlan_c=
ommon.h
index 73cacb3..0af8b8d 100644
--- a/include/net/irda/irlan_common.h
+++ b/include/net/irda/irlan_common.h
@@ -171,7 +171,6 @@ struct irlan_cb {
 	int    magic;
 	struct list_head  dev_list;
 	struct net_device *dev;        /* Ethernet device structure*/
-	struct net_device_stats stats;
=20
 	__u32 saddr;               /* Source device address */
 	__u32 daddr;               /* Destination device address */
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 5bb8353..8ee1ff6 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -45,13 +45,11 @@ static int  irlan_eth_close(struct net_device *dev)=
;
 static netdev_tx_t  irlan_eth_xmit(struct sk_buff *skb,
 					 struct net_device *dev);
 static void irlan_eth_set_multicast_list( struct net_device *dev);
-static struct net_device_stats *irlan_eth_get_stats(struct net_device =
*dev);
=20
 static const struct net_device_ops irlan_eth_netdev_ops =3D {
 	.ndo_open               =3D irlan_eth_open,
 	.ndo_stop               =3D irlan_eth_close,
 	.ndo_start_xmit    	=3D irlan_eth_xmit,
-	.ndo_get_stats	        =3D irlan_eth_get_stats,
 	.ndo_set_multicast_list =3D irlan_eth_set_multicast_list,
 	.ndo_change_mtu		=3D eth_change_mtu,
 	.ndo_validate_addr	=3D eth_validate_addr,
@@ -208,10 +206,10 @@ static netdev_tx_t irlan_eth_xmit(struct sk_buff =
*skb,
 		 * tried :-) DB
 		 */
 		/* irttp_data_request already free the packet */
-		self->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 	} else {
-		self->stats.tx_packets++;
-		self->stats.tx_bytes +=3D len;
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes +=3D len;
 	}
=20
 	return NETDEV_TX_OK;
@@ -226,15 +224,16 @@ static netdev_tx_t irlan_eth_xmit(struct sk_buff =
*skb,
 int irlan_eth_receive(void *instance, void *sap, struct sk_buff *skb)
 {
 	struct irlan_cb *self =3D instance;
+	struct net_device *dev =3D self->dev;
=20
 	if (skb =3D=3D NULL) {
-		++self->stats.rx_dropped;
+		dev->stats.rx_dropped++;
 		return 0;
 	}
 	if (skb->len < ETH_HLEN) {
 		IRDA_DEBUG(0, "%s() : IrLAN frame too short (%d)\n",
 			   __func__, skb->len);
-		++self->stats.rx_dropped;
+		dev->stats.rx_dropped++;
 		dev_kfree_skb(skb);
 		return 0;
 	}
@@ -244,10 +243,10 @@ int irlan_eth_receive(void *instance, void *sap, =
struct sk_buff *skb)
 	 * might have been previously set by the low level IrDA network
 	 * device driver
 	 */
-	skb->protocol =3D eth_type_trans(skb, self->dev); /* Remove eth heade=
r */
+	skb->protocol =3D eth_type_trans(skb, dev); /* Remove eth header */
=20
-	self->stats.rx_packets++;
-	self->stats.rx_bytes +=3D skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes +=3D skb->len;
=20
 	netif_rx(skb);   /* Eat it! */
=20
@@ -348,16 +347,3 @@ static void irlan_eth_set_multicast_list(struct ne=
t_device *dev)
 	else
 		irlan_set_broadcast_filter(self, FALSE);
 }
-
-/*
- * Function irlan_get_stats (dev)
- *
- *    Get the current statistics for this device
- *
- */
-static struct net_device_stats *irlan_eth_get_stats(struct net_device =
*dev)
-{
-	struct irlan_cb *self =3D netdev_priv(dev);
-
-	return &self->stats;
-}


