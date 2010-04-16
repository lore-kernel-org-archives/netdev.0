From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Sat, 17 Apr 2010 00:18:22 +0200
Message-ID: <1271456302.16881.4559.camel@edumazet-laptop>
References: <20100415.020619.00349859.davem@davemloft.net>
	 <1271363432.16881.3080.camel@edumazet-laptop>
	 <1271364375.16881.3099.camel@edumazet-laptop>
	 <20100415.143321.200497785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:55680 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932646Ab0DPWS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 18:18:26 -0400
Received: by bwz25 with SMTP id 25so3687456bwz.28
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 15:18:25 -0700 (PDT)
In-Reply-To: <20100415.143321.200497785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 14:33 -0700, David Miller a =C3=A9crit :

> If it's not legal to skb_orphan() here then it would not be legal for
> the drivers to unconditionally skb_orphan(), which they do.
>=20
> So either your test is unnecessary, or we have a big existing problem
> :-)

I cooked following patch, introducing skb_orphan_try() helper, to
document all known exceptions.

I have a possible followup for this patch :

Orphaning skbs earlier could also make dev_kfree_skb_irq() faster.
Instead of queing skb into completion_queue and triggering
NET_TX_SOFTIRQ, we would directly free an orphaned skb ?



[PATCH net-next-2.6] net: Introduce skb_orphan_try()

Transmitted skb might be attached to a socket and a destructor, for
memory accounting purposes.

Traditionally, this destructor is called at tx completion time, when sk=
b
is freed.

When tx completion is performed by another cpu than the sender, this
forces some cache lines to change ownership. XPS was an attempt to give
tx completion to initial cpu.

David idea is to call destructor right before giving skb to device (cal=
l
to ndo_start_xmit()). Because device queues are usually small, orphanin=
g
skb before tx completion is not a big deal. Some drivers already do
this, we could do it in upper level.

There is one known exception to this early orphaning, called tx
timestamping. It needs to keep a reference to socket until device can
give a hardware or software timestamp.

This patch adds a skb_orphan_try() helper, to centralize all exceptions
to early orphaning in one spot, and use it in dev_hard_start_xmit().

"tbench 16" results on a Nehalem machine (2 X5570  @ 2.93GHz)
before: Throughput 4428.9 MB/sec 16 procs
after: Throughput 4448.14 MB/sec 16 procs

UDP should get even better results, its destructor being more complex,
since SOCK_USE_WRITE_QUEUE is not set (four atomic ops instead of one)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index e8041eb..acae5fe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1880,6 +1880,17 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
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
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1904,23 +1915,10 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(skb);
=20
+		skb_orphan_try(skb);
 		rc =3D ops->ndo_start_xmit(skb, dev);
 		if (rc =3D=3D NETDEV_TX_OK)
 			txq_trans_update(txq);
-		/*
-		 * TODO: if skb_orphan() was called by
-		 * dev->hard_start_xmit() (for example, the unmodified
-		 * igb driver does that; bnx2 doesn't), then
-		 * skb_tx_software_timestamp() will be unable to send
-		 * back the time stamp.
-		 *
-		 * How can this be prevented? Always create another
-		 * reference to the socket before calling
-		 * dev->hard_start_xmit()? Prevent that skb_orphan()
-		 * does anything in dev->hard_start_xmit() by clearing
-		 * the skb destructor before the call and restoring it
-		 * afterwards, then doing the skb_orphan() ourselves?
-		 */
 		return rc;
 	}
=20
@@ -1938,6 +1936,7 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
=20
+		skb_orphan_try(nskb);
 		rc =3D ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc !=3D NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)


