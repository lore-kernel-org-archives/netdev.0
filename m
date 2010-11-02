From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Tue, 02 Nov 2010 08:30:57 +0100
Message-ID: <1288683057.2660.154.camel@edumazet-laptop>
References: <20101101122920.GB10052@verge.net.au>
	 <1288616372.2660.101.camel@edumazet-laptop>
	 <20101102020625.GA22724@verge.net.au>
	 <1288673622.2660.147.camel@edumazet-laptop>
	 <20101102070308.GA19924@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35497 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756832Ab0KBHbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 03:31:06 -0400
Received: by wwe15 with SMTP id 15so7023709wwe.1
        for <netdev@vger.kernel.org>; Tue, 02 Nov 2010 00:31:05 -0700 (PDT)
In-Reply-To: <20101102070308.GA19924@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 02 novembre 2010 =C3=A0 16:03 +0900, Simon Horman a =C3=A9crit=
 :
> On Tue, Nov 02, 2010 at 05:53:42AM +0100, Eric Dumazet wrote:
> > Le mardi 02 novembre 2010 =C3=A0 11:06 +0900, Simon Horman a =C3=A9=
crit :
> >=20
> > > Thanks for the explanation.
> > > I'm not entirely sure how much of a problem this is in practice.
> >=20
> > Maybe for virtual devices (tunnels, bonding, ...), it would make se=
nse
> > to delay the orphaning up to the real device.
>=20
> That was my initial thought. Could you give me some guidance
> on how that might be done so I can try and make a patch to test?
>=20
> > But if the socket send buffer is very large, it would defeat the fl=
ow
> > control any way...
>=20
> I'm primarily concerned about a situation where
> UDP packets are sent as fast as possible, indefinitely.
> And in that scenario, I think it would need to be a rather large buff=
er.
>=20

Please try following patch, thanks.

 drivers/net/bonding/bond_main.c |    1 +
 include/linux/if.h              |    3 +++
 net/core/dev.c                  |    5 +++--
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index bdb68a6..325931e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4714,6 +4714,7 @@ static void bond_setup(struct net_device *bond_de=
v)
 	bond_dev->flags |=3D IFF_MASTER|IFF_MULTICAST;
 	bond_dev->priv_flags |=3D IFF_BONDING;
 	bond_dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
+	bond_dev->priv_flags &=3D ~IFF_EARLY_ORPHAN;
=20
 	if (bond->params.arp_interval)
 		bond_dev->priv_flags |=3D IFF_MASTER_ARPMON;
diff --git a/include/linux/if.h b/include/linux/if.h
index 1239599..7499a99 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -77,6 +77,9 @@
 #define IFF_BRIDGE_PORT	0x8000		/* device used as bridge port */
 #define IFF_OVS_DATAPATH	0x10000	/* device used as Open vSwitch
 					 * datapath port */
+#define IFF_EARLY_ORPHAN	0x20000 /* early orphan skbs in
+					 * dev_hard_start_xmit()
+					 */
=20
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/net/core/dev.c b/net/core/dev.c
index 35dfb83..eabf94d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2005,7 +2005,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(skb);
=20
-		skb_orphan_try(skb);
+		if (dev->priv_flags & IFF_EARLY_ORPHAN)
+			skb_orphan_try(skb);
=20
 		if (vlan_tx_tag_present(skb) &&
 		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
@@ -5590,7 +5591,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
-	dev->priv_flags =3D IFF_XMIT_DST_RELEASE;
+	dev->priv_flags =3D IFF_XMIT_DST_RELEASE | IFF_EARLY_ORPHAN ;
 	setup(dev);
 	strcpy(dev->name, name);
 	return dev;


