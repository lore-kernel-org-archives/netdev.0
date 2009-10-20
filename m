From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ifb: should not use __dev_get_by_index() without locks
Date: Tue, 20 Oct 2009 14:35:50 +0200
Message-ID: <4ADDAEA6.2040903@gmail.com>
References: <4ADD3794.8030906@gmail.com>	<20091019.212018.79580287.davem@davemloft.net>	<4ADD3B5A.1080905@gmail.com> <20091019.212855.179405364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58823 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbZJTMft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 08:35:49 -0400
In-Reply-To: <20091019.212855.179405364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 20 Oct 2009 06:23:54 +0200
>=20
>> I wonder if the whole thing could use RCU somehow, since some
>> workloads hit this dev_base_lock rwlock pretty hard...
>=20
> True, but for now we'll put your fix in :-)

Here is another vulnerable point, needing following patch.

Thanks

[PATCH] ifb: should not use __dev_get_by_index() without locks

At this point (ri_tasklet()), RTNL or dev_base_lock are not held,
we must use dev_get_by_index() instead of __dev_get_by_index()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 801f088..030913f 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -98,12 +98,13 @@ static void ri_tasklet(unsigned long dev)
 		stats->tx_packets++;
 		stats->tx_bytes +=3Dskb->len;
=20
-		skb->dev =3D __dev_get_by_index(&init_net, skb->iif);
+		skb->dev =3D dev_get_by_index(&init_net, skb->iif);
 		if (!skb->dev) {
 			dev_kfree_skb(skb);
 			stats->tx_dropped++;
 			break;
 		}
+		dev_put(skb->dev);
 		skb->iif =3D _dev->ifindex;
=20
 		if (from & AT_EGRESS) {

