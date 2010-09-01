From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] skge: add GRO support
Date: Wed, 01 Sep 2010 06:25:32 +0200
Message-ID: <1283315132.2198.67.camel@edumazet-laptop>
References: <1283293956.2198.46.camel@edumazet-laptop>
	 <20100831183105.03b0f2bc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59356 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab0IAEZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 00:25:42 -0400
Received: by wyb35 with SMTP id 35so8741648wyb.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 21:25:41 -0700 (PDT)
In-Reply-To: <20100831183105.03b0f2bc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 ao=C3=BBt 2010 =C3=A0 18:31 -0700, Stephen Hemminger a =C3=A9=
crit :
> On Wed, 01 Sep 2010 00:32:36 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > @@ -3193,7 +3192,7 @@ static int skge_poll(struct napi_struct *napi=
, int to_do)
> >  		unsigned long flags;
> > =20
> >  		spin_lock_irqsave(&hw->hw_lock, flags);
> > -		__napi_complete(napi);
> > +		napi_complete(napi);
>=20
> This adds a redundant irq_save/irq_restore in the packet
> receive path.
>=20
> In the case of skge, since the both ports share a single
> IRQ mask register, the lock is there to make sure that updates
> to the mask register doesn't race between NAPI finishing
> on one port and IRQ on other port changing same IRQ mask register.
>=20
>=20

We need to napi_gro_flush(), while IRQ are on, and napi_gro_flush() is
static to net/core/dev.c

Thanks !

[PATCH net-next-2.6 v2] skge: add GRO support

- napi_gro_flush() is exported from net/core/dev.c, to avoid
  an irq_save/irq_restore in the packet receive path.
- use napi_gro_receive() instead of netif_receive_skb()
- use napi_gro_flush() before calling __napi_complete()
- turn on NETIF_F_GRO by default
- Tested on a Marvell 88E8001 Gigabit NIC

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/skge.c        |    5 +++--
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |    3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 40e5c46..a8a6358 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3178,8 +3178,7 @@ static int skge_poll(struct napi_struct *napi, in=
t to_do)
=20
 		skb =3D skge_rx_get(dev, e, control, rd->status, rd->csum2);
 		if (likely(skb)) {
-			netif_receive_skb(skb);
-
+			napi_gro_receive(napi, skb);
 			++work_done;
 		}
 	}
@@ -3192,6 +3191,7 @@ static int skge_poll(struct napi_struct *napi, in=
t to_do)
 	if (work_done < to_do) {
 		unsigned long flags;
=20
+		napi_gro_flush(napi);
 		spin_lock_irqsave(&hw->hw_lock, flags);
 		__napi_complete(napi);
 		hw->intr_mask |=3D napimask[skge->port];
@@ -3849,6 +3849,7 @@ static struct net_device *skge_devinit(struct skg=
e_hw *hw, int port,
 		dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG;
 		skge->rx_csum =3D 1;
 	}
+	dev->features |=3D NETIF_F_GRO;
=20
 	/* read the mac address */
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port*8, ETH_ALEN);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0cf9448..fb31b5f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1695,6 +1695,7 @@ extern gro_result_t	dev_gro_receive(struct napi_s=
truct *napi,
 extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff *=
skb);
 extern gro_result_t	napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
+extern void		napi_gro_flush(struct napi_struct *napi);
 extern void		napi_reuse_skb(struct napi_struct *napi,
 				       struct sk_buff *skb);
 extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
diff --git a/net/core/dev.c b/net/core/dev.c
index 63bd20a..d8c43e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3063,7 +3063,7 @@ out:
 	return netif_receive_skb(skb);
 }
=20
-static void napi_gro_flush(struct napi_struct *napi)
+inline void napi_gro_flush(struct napi_struct *napi)
 {
 	struct sk_buff *skb, *next;
=20
@@ -3076,6 +3076,7 @@ static void napi_gro_flush(struct napi_struct *na=
pi)
 	napi->gro_count =3D 0;
 	napi->gro_list =3D NULL;
 }
+EXPORT_SYMBOL(napi_gro_flush);
=20
 enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_bu=
ff *skb)
 {


