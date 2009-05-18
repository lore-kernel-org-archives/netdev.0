From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: tx scalability works : trans_start
Date: Mon, 18 May 2009 09:21:31 +0200
Message-ID: <4A110C7B.4020407@cosmosbay.com>
References: <4A09D269.60703@cosmosbay.com> <20090517.205710.137526481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54268 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404AbZERHVg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 03:21:36 -0400
In-Reply-To: <20090517.205710.137526481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 12 May 2009 21:47:53 +0200
>=20
>> struct net_device trans_start field is a hot spot on SMP and high pe=
rformance
>> devices, particularly multi queues ones, because every transmitter d=
irties
>> it. Is main use is tx watchdog and bonding alive checks.
>>
>> But as most devices dont use NETIF_F_LLTX, we have to lock
>> a netdev_queue before calling their ndo_start_xmit(). So it makes
>> sense to move trans_start from net_device to netdev_queue. Its updat=
e
>> will occur on a already present (and in exclusive state) cache line,=
 for
>> free.
>>
>> We can do this transition smoothly. An old driver continue to
>> update dev->trans_start, while an updated one updates txq->trans_sta=
rt.
>>
>> Further patches could also put tx_bytes/tx_packets counters in=20
>> netdev_queue to avoid dirtying dev->stats (vlan device comes to mind=
)
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> I like this patch so I'm adding it to net-next-2.6
>=20
> But you can go one step further and untangle what is arguably
> a huge mess.  There is no reason for the driver to set
> ->trans_start.
>=20
> The driver gives us a success indication from ->hard_start_xmit()
> and we can use that to set txq->trans_start.
>=20
> Then you can kill the driver code that sets dev->trans_start and
> then kill the netdev struct member as well.
>=20
> Could you please do this work, thanks?

Indeed we can do this factorization, just have to take care of not addi=
ng
a new cache line miss on loopback device, as this one doesnt touch dev-=
>trans_start.

Adding the update in dev_hard_start_xmit() would cost two additional te=
sts...

if (rc =3D=3D NETDEV_TX_OK && dev->netdev_ops->ndo_tx_timeout)
	txq->trans_start =3D jiffies;

Relying on NETIF_F_LLTX is a litle bit odd, since some drivers would
have to set txq->trans_start themselves, but unfortunatly ndo_start_xmi=
t(skb, dev)
doesnt have txq as a third parameter. (we should add it, as high perfor=
mance drivers=20
have to recompute txq themselves). Ah, yes old drivers have one tx queu=
e so it is
cheap to get txq, never mind :)



What do you think ? (following patch as RFC only, not even booted)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cd547d0..fe301b0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1773,8 +1773,10 @@ static inline void netif_tx_unlock_bh(struct net=
_device *dev)
 	}						\
 }
=20
-#define HARD_TX_UNLOCK(dev, txq) {			\
+#define HARD_TX_UNLOCK(dev, txq, update_trans) {	\
 	if ((dev->features & NETIF_F_LLTX) =3D=3D 0) {	\
+		if (update_trans)			\
+			txq->trans_start =3D jiffies;	\
 		__netif_tx_unlock(txq);			\
 	}						\
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 14dd725..f71a69d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1879,11 +1879,11 @@ gso:
 			if (!netif_tx_queue_stopped(txq)) {
 				rc =3D 0;
 				if (!dev_hard_start_xmit(skb, dev, txq)) {
-					HARD_TX_UNLOCK(dev, txq);
+					HARD_TX_UNLOCK(dev, txq, 1);
 					goto out;
 				}
 			}
-			HARD_TX_UNLOCK(dev, txq);
+			HARD_TX_UNLOCK(dev, txq, 0);
 			if (net_ratelimit())
 				printk(KERN_CRIT "Virtual device %s asks to "
 				       "queue packet!\n", dev->name);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 27d0381..2f69420 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -145,7 +145,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	if (!netif_tx_queue_stopped(txq) &&
 	    !netif_tx_queue_frozen(txq))
 		ret =3D dev_hard_start_xmit(skb, dev, txq);
-	HARD_TX_UNLOCK(dev, txq);
+	HARD_TX_UNLOCK(dev, txq, ret =3D=3D NETDEV_TX_OK);
=20
 	spin_lock(root_lock);
=20

