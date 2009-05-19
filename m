From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] sch_teql: Use net_device internal stats
Date: Tue, 19 May 2009 07:43:09 +0200
Message-ID: <4A1246ED.3080203@cosmosbay.com>
References: <4A11391D.8060503@cosmosbay.com>	<20090518.151256.217066131.davem@davemloft.net>	<4A120C8B.80108@cosmosbay.com> <20090518.193438.158960584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39431 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbZESFnQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 01:43:16 -0400
In-Reply-To: <20090518.193438.158960584.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 19 May 2009 03:34:03 +0200
>=20
>> Looking again at teql_master_xmit(), I wonder if there is another
>> problem in it.
>>
>>     int subq =3D skb_get_queue_mapping(skb);
>>
>> But as a matter of fact, following code assumes subq is 0
>>
>> struct netdev_queue *slave_txq =3D netdev_get_tx_queue(slave, 0);
>> ...
>> if (__netif_subqueue_stopped(slave, subq) ||
>> ...
>>
>> Either we should set subq to 0, or call dev_pick_tx() to better
>> take into account multi queue slaves ?
>>
>> (As teqlN has one queue, I assume original dev_queue_xmit() will
>> set skb queue_mapping to 0 before entering teql_master_xmit(), but
>> maybe other paths could call teql_master_xmit() not through dev_queu=
e_xmit() ?
>>
>> Oh well, time for sleeping a bit...
>=20
> I was admittedly very hasty with the multiqueue conversion here.
> I'll take a closer look at this.

Thanks David

In the meantime, I did the master->stats removal for teqlN devices, for=
 net-next-2.6,
if you dont mind :)

[PATCH] sch_teql: Use net_device internal stats

We can slightly reduce size of teqlN structure, not duplicating stats s=
tructure
in teql_master but using stats field from net_device.stats for tx_error=
s and from=20
netdev_queue for tx_bytes/tx_packets/tx_dropped values.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/sched/sch_teql.c |   17 +++++------------
 1 files changed, 5 insertions(+), 12 deletions(-)
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 3b64182..428a5ef 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -58,7 +58,6 @@ struct teql_master
 	struct net_device *dev;
 	struct Qdisc *slaves;
 	struct list_head master_list;
-	struct net_device_stats stats;
 };
=20
 struct teql_sched_data
@@ -272,6 +271,7 @@ static inline int teql_resolve(struct sk_buff *skb,
 static int teql_master_xmit(struct sk_buff *skb, struct net_device *de=
v)
 {
 	struct teql_master *master =3D netdev_priv(dev);
+	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
 	struct Qdisc *start, *q;
 	int busy;
 	int nores;
@@ -311,8 +311,8 @@ restart:
 					__netif_tx_unlock(slave_txq);
 					master->slaves =3D NEXT_SLAVE(q);
 					netif_wake_queue(dev);
-					master->stats.tx_packets++;
-					master->stats.tx_bytes +=3D length;
+					txq->tx_packets++;
+					txq->tx_bytes +=3D length;
 					return 0;
 				}
 				__netif_tx_unlock(slave_txq);
@@ -339,10 +339,10 @@ restart:
 		netif_stop_queue(dev);
 		return 1;
 	}
-	master->stats.tx_errors++;
+	dev->stats.tx_errors++;
=20
 drop:
-	master->stats.tx_dropped++;
+	txq->tx_dropped++;
 	dev_kfree_skb(skb);
 	return 0;
 }
@@ -395,12 +395,6 @@ static int teql_master_close(struct net_device *de=
v)
 	return 0;
 }
=20
-static struct net_device_stats *teql_master_stats(struct net_device *d=
ev)
-{
-	struct teql_master *m =3D netdev_priv(dev);
-	return &m->stats;
-}
-
 static int teql_master_mtu(struct net_device *dev, int new_mtu)
 {
 	struct teql_master *m =3D netdev_priv(dev);
@@ -425,7 +419,6 @@ static const struct net_device_ops teql_netdev_ops =
=3D {
 	.ndo_open	=3D teql_master_open,
 	.ndo_stop	=3D teql_master_close,
 	.ndo_start_xmit	=3D teql_master_xmit,
-	.ndo_get_stats	=3D teql_master_stats,
 	.ndo_change_mtu	=3D teql_master_mtu,
 };
=20

