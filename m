From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] vlan: remove ndo_select_queue() logic
Date: Thu, 11 Nov 2010 20:42:45 +0100
Message-ID: <1289504565.17691.1710.camel@edumazet-laptop>
References: <1289468520.17691.1018.camel@edumazet-laptop>
	 <AANLkTikBkUNfrfSZkoVd1xzisD3jgg5kVUUZC45gNpde@mail.gmail.com>
	 <1289497978.17691.1582.camel@edumazet-laptop>
	 <AANLkTik-b5jYgN9e2cgYQvW1V3kuHem2x6wDpw4_=GJJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36567 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754636Ab0KKTmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 14:42:49 -0500
Received: by eye27 with SMTP id 27so1407032eye.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 11:42:48 -0800 (PST)
In-Reply-To: <AANLkTik-b5jYgN9e2cgYQvW1V3kuHem2x6wDpw4_=GJJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 novembre 2010 =C3=A0 10:56 -0800, Jesse Gross a =C3=A9crit =
:
> On Thu, Nov 11, 2010 at 9:52 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:

> Before Tom's patch, a warning will be generated if a single queue vla=
n
> device is stacked on top of a multiqueue physical device that
> implements ndo_select_queue().  After Tom's patch, we avoid the
> warning so vlan_dev_select_queue() is merely dead code.  Either way,
> what's the benefit in keeping it?
>=20
> >
> >
> > This logicaly is a second cleanup patch I believe.
>=20
> I'm not arguing against your patch, I just think it should go a step =
further.

Sure ! Here is the thing ;)

Thanks

[PATCH] vlan: remove ndo_select_queue() logic

Now vlan are lockless, we dont need special ndo_select_queue() logic.
dev_pick_tx() will do the multiqueue stuff on the real device transmit.

Suggested-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan_dev.c |   71 +----------------------------------------
 1 files changed, 3 insertions(+), 68 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 3a67483..99d6910 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -390,14 +390,6 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmi=
t(struct sk_buff *skb,
 	return ret;
 }
=20
-static u16 vlan_dev_select_queue(struct net_device *dev, struct sk_buf=
f *skb)
-{
-	struct net_device *rdev =3D vlan_dev_info(dev)->real_dev;
-	const struct net_device_ops *ops =3D rdev->netdev_ops;
-
-	return ops->ndo_select_queue(rdev, skb);
-}
-
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
 	/* TODO: gotta make sure the underlying layer can handle it,
@@ -726,8 +718,7 @@ static const struct header_ops vlan_header_ops =3D =
{
 	.parse	 =3D eth_header_parse,
 };
=20
-static const struct net_device_ops vlan_netdev_ops, vlan_netdev_accel_=
ops,
-		    vlan_netdev_ops_sq, vlan_netdev_accel_ops_sq;
+static const struct net_device_ops vlan_netdev_ops, vlan_netdev_accel_=
ops;
=20
 static int vlan_dev_init(struct net_device *dev)
 {
@@ -763,17 +754,11 @@ static int vlan_dev_init(struct net_device *dev)
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      =3D real_dev->header_ops;
 		dev->hard_header_len =3D real_dev->hard_header_len;
-		if (real_dev->netdev_ops->ndo_select_queue)
-			dev->netdev_ops =3D &vlan_netdev_accel_ops_sq;
-		else
-			dev->netdev_ops =3D &vlan_netdev_accel_ops;
+		dev->netdev_ops =3D &vlan_netdev_accel_ops;
 	} else {
 		dev->header_ops      =3D &vlan_header_ops;
 		dev->hard_header_len =3D real_dev->hard_header_len + VLAN_HLEN;
-		if (real_dev->netdev_ops->ndo_select_queue)
-			dev->netdev_ops =3D &vlan_netdev_ops_sq;
-		else
-			dev->netdev_ops =3D &vlan_netdev_ops;
+		dev->netdev_ops =3D &vlan_netdev_ops;
 	}
=20
 	if (is_vlan_dev(real_dev))
@@ -944,56 +929,6 @@ static const struct net_device_ops vlan_netdev_acc=
el_ops =3D {
 #endif
 };
=20
-static const struct net_device_ops vlan_netdev_ops_sq =3D {
-	.ndo_select_queue	=3D vlan_dev_select_queue,
-	.ndo_change_mtu		=3D vlan_dev_change_mtu,
-	.ndo_init		=3D vlan_dev_init,
-	.ndo_uninit		=3D vlan_dev_uninit,
-	.ndo_open		=3D vlan_dev_open,
-	.ndo_stop		=3D vlan_dev_stop,
-	.ndo_start_xmit =3D  vlan_dev_hard_start_xmit,
-	.ndo_validate_addr	=3D eth_validate_addr,
-	.ndo_set_mac_address	=3D vlan_dev_set_mac_address,
-	.ndo_set_rx_mode	=3D vlan_dev_set_rx_mode,
-	.ndo_set_multicast_list	=3D vlan_dev_set_rx_mode,
-	.ndo_change_rx_flags	=3D vlan_dev_change_rx_flags,
-	.ndo_do_ioctl		=3D vlan_dev_ioctl,
-	.ndo_neigh_setup	=3D vlan_dev_neigh_setup,
-	.ndo_get_stats64	=3D vlan_dev_get_stats64,
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
-	.ndo_fcoe_ddp_setup	=3D vlan_dev_fcoe_ddp_setup,
-	.ndo_fcoe_ddp_done	=3D vlan_dev_fcoe_ddp_done,
-	.ndo_fcoe_enable	=3D vlan_dev_fcoe_enable,
-	.ndo_fcoe_disable	=3D vlan_dev_fcoe_disable,
-	.ndo_fcoe_get_wwn	=3D vlan_dev_fcoe_get_wwn,
-#endif
-};
-
-static const struct net_device_ops vlan_netdev_accel_ops_sq =3D {
-	.ndo_select_queue	=3D vlan_dev_select_queue,
-	.ndo_change_mtu		=3D vlan_dev_change_mtu,
-	.ndo_init		=3D vlan_dev_init,
-	.ndo_uninit		=3D vlan_dev_uninit,
-	.ndo_open		=3D vlan_dev_open,
-	.ndo_stop		=3D vlan_dev_stop,
-	.ndo_start_xmit =3D  vlan_dev_hwaccel_hard_start_xmit,
-	.ndo_validate_addr	=3D eth_validate_addr,
-	.ndo_set_mac_address	=3D vlan_dev_set_mac_address,
-	.ndo_set_rx_mode	=3D vlan_dev_set_rx_mode,
-	.ndo_set_multicast_list	=3D vlan_dev_set_rx_mode,
-	.ndo_change_rx_flags	=3D vlan_dev_change_rx_flags,
-	.ndo_do_ioctl		=3D vlan_dev_ioctl,
-	.ndo_neigh_setup	=3D vlan_dev_neigh_setup,
-	.ndo_get_stats64	=3D vlan_dev_get_stats64,
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
-	.ndo_fcoe_ddp_setup	=3D vlan_dev_fcoe_ddp_setup,
-	.ndo_fcoe_ddp_done	=3D vlan_dev_fcoe_ddp_done,
-	.ndo_fcoe_enable	=3D vlan_dev_fcoe_enable,
-	.ndo_fcoe_disable	=3D vlan_dev_fcoe_disable,
-	.ndo_fcoe_get_wwn	=3D vlan_dev_fcoe_get_wwn,
-#endif
-};
-
 void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);


