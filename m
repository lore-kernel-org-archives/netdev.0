From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ethtool: change ethtool_set_gro() to use
 ethtool_op_get_rx_csum
Date: Thu, 16 Sep 2010 10:11:03 +0200
Message-ID: <1284624663.3352.9.camel@edumazet-laptop>
References: <20100915181616.578fcd37@nehalam>
	 <20100915.225146.35823170.davem@davemloft.net>
	 <20100915232125.4430a421@nehalam>
	 <20100915.233851.85414928.davem@davemloft.net>
	 <1284619376.2462.95.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bphilips@suse.de,
	e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53884 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab0IPILI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 04:11:08 -0400
Received: by wyf22 with SMTP id 22so1093903wyf.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 01:11:07 -0700 (PDT)
In-Reply-To: <1284619376.2462.95.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 septembre 2010 =C3=A0 08:43 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le mercredi 15 septembre 2010 =C3=A0 23:38 -0700, David Miller a =C3=A9=
crit :
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Wed, 15 Sep 2010 23:21:25 -0700
> >=20
> > > I think it is more complex than that. GRO is tied to NAPI,
> > > and bridge/bond don't use NAPI directly. They use netif_rx() for =
receiving
> > > because layered drivers can't directly up call because of possibl=
e
> > > issues with stack depth.=20
> > >=20
> > > To get GRO working for netif_rx case,
> > > the logic in process_backlog would have to change.
> > > But this queue is processing packets from multiple devices so
> > > it is not clear if GRO could be used.
> >=20
> > Bonding's un-layering on RX is done in the normal netif_receive_skb=
()
> > control flow.
> >=20
> > And bridging only uses netif_rx for multicast replication.
>=20
> Yes, bonding case should be easy, I'll take a look today.
>=20

[PATCH] ethtool: change ethtool_set_gro() to use ethtool_op_get_rx_csum

To be able to switch on GRO on a device, ethtool_set_gro() checks this
device provides a get_rx_csum() method.

Some devices dont provide this method, while they do support RX
checksumming.

This patch allows bonding to support GRO :

ethtool -K bond0 gro on

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/ethtool.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 7a85367..8c8c6d4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1175,8 +1175,11 @@ static int ethtool_set_gro(struct net_device *de=
v, char __user *useraddr)
 		return -EFAULT;
=20
 	if (edata.data) {
-		if (!dev->ethtool_ops->get_rx_csum ||
-		    !dev->ethtool_ops->get_rx_csum(dev))
+		u32 rxcsum =3D dev->ethtool_ops->get_rx_csum ?
+				dev->ethtool_ops->get_rx_csum(dev) :
+				ethtool_op_get_rx_csum(dev);
+
+		if (!rxcsum)
 			return -EINVAL;
 		dev->features |=3D NETIF_F_GRO;
 	} else


