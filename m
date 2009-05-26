From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: txq_trans_update() helper
Date: Tue, 26 May 2009 07:57:01 +0200
Message-ID: <4A1B84AD.1040707@gmail.com>
References: <4A110C7B.4020407@cosmosbay.com>	<20090518.151152.76033192.davem@davemloft.net>	<4A1B8007.1000703@gmail.com> <20090525.223827.256643479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41766 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbZEZF5D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 01:57:03 -0400
In-Reply-To: <20090525.223827.256643479.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 26 May 2009 07:37:11 +0200
>=20
>> @@ -302,8 +302,11 @@ static void netpoll_send_skb(struct netpoll *np=
, struct sk_buff *skb)
>>  		for (tries =3D jiffies_to_usecs(1)/USEC_PER_POLL;
>>  		     tries > 0; --tries) {
>>  			if (__netif_tx_trylock(txq)) {
>> -				if (!netif_tx_queue_stopped(txq))
>> +				if (!netif_tx_queue_stopped(txq)) {
>>  					status =3D ops->ndo_start_xmit(skb, dev);
>> +					if (status =3D=3D NETDEV_TX_OK)
>> +						txq_trans_update(txq);
>> +					}
>=20
> Closing brace here has strange indentation, which doesn't match
> the statement of the openning brace.
>=20
> Please fix this, thanks.

Oops you are right, this is a leftover.

[PATCH] net: txq_trans_update() helper

We would like to get rid of netdev->trans_start =3D jiffies; that about=
 all net
drivers have to use in their start_xmit() function, and use txq->trans_=
start
instead.

This can be done generically in core network, as suggested by David.

Some devices, (particularly loopback) dont need trans_start update, bec=
ause
they dont have transmit watchdog. We could add a new device flag, or re=
ly
on fact that txq->tran_start can be updated is txq->xmit_lock_owner is
different than -1. Use a helper function to hide our choice.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    6 ++++++
 net/core/dev.c            |    3 +++
 net/core/netpoll.c        |    5 ++++-
 net/core/pktgen.c         |    1 +
 net/sched/sch_teql.c      |    1 +
 5 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8574e7..a6aa468 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1712,6 +1712,12 @@ static inline void __netif_tx_unlock_bh(struct n=
etdev_queue *txq)
 	spin_unlock_bh(&txq->_xmit_lock);
 }
=20
+static inline void txq_trans_update(struct netdev_queue *txq)
+{
+	if (txq->xmit_lock_owner !=3D -1)
+		txq->trans_start =3D jiffies;
+}
+
 /**
  *	netif_tx_lock - grab network device transmit lock
  *	@dev: network device
diff --git a/net/core/dev.c b/net/core/dev.c
index 3942266..29fa4a1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1698,6 +1698,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 			skb->dst =3D NULL;
 		}
 		rc =3D ops->ndo_start_xmit(skb, dev);
+		if (rc =3D=3D 0)
+			txq_trans_update(txq);
 		/*
 		 * TODO: if skb_orphan() was called by
 		 * dev->hard_start_xmit() (for example, the unmodified
@@ -1727,6 +1729,7 @@ gso:
 			skb->next =3D nskb;
 			return rc;
 		}
+		txq_trans_update(txq);
 		if (unlikely(netif_tx_queue_stopped(txq) && skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 67b4f3e..35850e6 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -302,8 +302,11 @@ static void netpoll_send_skb(struct netpoll *np, s=
truct sk_buff *skb)
 		for (tries =3D jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
-				if (!netif_tx_queue_stopped(txq))
+				if (!netif_tx_queue_stopped(txq)) {
 					status =3D ops->ndo_start_xmit(skb, dev);
+					if (status =3D=3D NETDEV_TX_OK)
+						txq_trans_update(txq);
+				}
 				__netif_tx_unlock(txq);
=20
 				if (status =3D=3D NETDEV_TX_OK)
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 0666a82..b8ccd3c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3438,6 +3438,7 @@ static __inline__ void pktgen_xmit(struct pktgen_=
dev *pkt_dev)
 	      retry_now:
 		ret =3D (*xmit)(pkt_dev->skb, odev);
 		if (likely(ret =3D=3D NETDEV_TX_OK)) {
+			txq_trans_update(txq);
 			pkt_dev->last_ok =3D 1;
 			pkt_dev->sofar++;
 			pkt_dev->seq_num++;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 428a5ef..a886496 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -308,6 +308,7 @@ restart:
 				if (!netif_tx_queue_stopped(slave_txq) &&
 				    !netif_tx_queue_frozen(slave_txq) &&
 				    slave_ops->ndo_start_xmit(skb, slave) =3D=3D 0) {
+					txq_trans_update(slave_txq);
 					__netif_tx_unlock(slave_txq);
 					master->slaves =3D NEXT_SLAVE(q);
 					netif_wake_queue(dev);

