From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loopback: better handling of packet drops
Date: Fri, 17 Apr 2009 12:33:33 +0200
Message-ID: <49E85AFD.6080407@cosmosbay.com>
References: <49E78DE5.10104@hartkopp.net>	<20090417.013853.04495551.davem@davemloft.net>	<49E84459.1060507@cosmosbay.com> <20090417.015914.09817926.davem@davemloft.net> <49E84B99.1080502@cosmosbay.com> <49E854A4.1010204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37225 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557AbZDQKdm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 06:33:42 -0400
In-Reply-To: <49E854A4.1010204@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Eric Dumazet a =E9crit :
>> David Miller a =E9crit :
>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>> Date: Fri, 17 Apr 2009 10:56:57 +0200
>>>
>>>> We can in some situations drop packets in netif_rx()
>>>>
>>>> loopback driver does not report these (unlikely) drops to its stat=
s,
>>>> and incorrectly change packets/bytes counts.
>>>>
>>>> After this patch applied, "ifconfig lo" can reports these drops as=
 in :
>>>>
>>>> # ifconfig lo
>>>> lo        Link encap:Local Loopback
>>>>           inet addr:127.0.0.1  Mask:255.0.0.0
>>>>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>>>>           RX packets:692562900 errors:0 dropped:0 overruns:0 frame=
:0
>>>>           TX packets:692562900 errors:3228 dropped:3228 overruns:0=
 carrier:0
>>>>           collisions:0 txqueuelen:0
>>>>           RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.6 =
GiB)
>>>>
>>>> I chose to reflect those errors only in tx_dropped/tx_errors, and =
not mirror
>>>> these errors in rx_dropped/rx_errors.
>>>>
>>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>> Well, logically the receive is what failed, not the transmit.
>>>
>>> I think it's therefore misleading to count it as a TX drop.
>>>
>>> Do you feel strongly about this?
>> Not at all, but my plan was to go a litle bit further, ie being able=
 to=20
>> return from loopback_xmit() with a non null value.
>>
>=20
> Something like this :

I just noticed NETDEV_TX_BUSY & NETDEV_TX_OK, so here is an updated ver=
sion
using these macros instead of 0 & 1

[PATCH] loopback: better handling of packet drops

We can in some situations drop packets in netif_rx()

loopback driver does not report these (unlikely) drops to its stats,
and incorrectly change packets/bytes counts. Also upper layers are
not warned of these transmit failures.

After this patch applied, "ifconfig lo" can reports these drops as in :

# ifconfig lo
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:692562900 errors:0 dropped:0 overruns:0 frame:0
          TX packets:692562900 errors:3228 dropped:3228 overruns:0 carr=
ier:0
          collisions:0 txqueuelen:0
          RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.6 GiB)

More over, loopback_xmit() can now return to its caller the indication =
that
packet was not transmitted for better queue management and error handli=
ng.

I chose to reflect those errors only in tx_dropped/tx_errors, and not m=
irror
them in rx_dropped/rx_errors.

Splitting netif_rx() with a helper function boosts tbench performance b=
y 1%,
because we can avoid two tests (about netpoll and timestamping)

Tested with /proc/sys/net/core/netdev_max_backlog set to 0, tbench
can run at full speed even with some 'losses' on loopback. No more
tcp stalls...

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 drivers/net/loopback.c    |   24 +++++++++---
 include/linux/netdevice.h |    1
 net/core/dev.c            |   68 +++++++++++++++++++++++-------------
 3 files changed, 62 insertions(+), 31 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b7d438a..101a3bc 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -62,6 +62,7 @@
 struct pcpu_lstats {
 	unsigned long packets;
 	unsigned long bytes;
+	unsigned long drops;
 };
=20
 /*
@@ -71,20 +72,25 @@ struct pcpu_lstats {
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct pcpu_lstats *pcpu_lstats, *lb_stats;
+	int len;
=20
 	skb_orphan(skb);
=20
-	skb->protocol =3D eth_type_trans(skb,dev);
+	skb->protocol =3D eth_type_trans(skb, dev);
=20
 	/* it's OK to use per_cpu_ptr() because BHs are off */
 	pcpu_lstats =3D dev->ml_priv;
 	lb_stats =3D per_cpu_ptr(pcpu_lstats, smp_processor_id());
-	lb_stats->bytes +=3D skb->len;
-	lb_stats->packets++;
=20
-	netif_rx(skb);
+	len =3D skb->len;
+	if (likely(__netif_rx(skb) =3D=3D NET_RX_SUCCESS)) {
+		lb_stats->bytes +=3D len;
+		lb_stats->packets++;
+		return NETDEV_TX_OK;
+	}
+	lb_stats->drops++;
=20
-	return 0;
+	return NETDEV_TX_BUSY;
 }
=20
 static struct net_device_stats *loopback_get_stats(struct net_device *=
dev)
@@ -93,6 +99,7 @@ static struct net_device_stats *loopback_get_stats(st=
ruct net_device *dev)
 	struct net_device_stats *stats =3D &dev->stats;
 	unsigned long bytes =3D 0;
 	unsigned long packets =3D 0;
+	unsigned long drops =3D 0;
 	int i;
=20
 	pcpu_lstats =3D dev->ml_priv;
@@ -102,11 +109,14 @@ static struct net_device_stats *loopback_get_stat=
s(struct net_device *dev)
 		lb_stats =3D per_cpu_ptr(pcpu_lstats, i);
 		bytes   +=3D lb_stats->bytes;
 		packets +=3D lb_stats->packets;
+		drops   +=3D lb_stats->drops;
 	}
 	stats->rx_packets =3D packets;
 	stats->tx_packets =3D packets;
-	stats->rx_bytes =3D bytes;
-	stats->tx_bytes =3D bytes;
+	stats->tx_dropped =3D drops;
+	stats->tx_errors  =3D drops;
+	stats->rx_bytes   =3D bytes;
+	stats->tx_bytes   =3D bytes;
 	return stats;
 }
=20
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..c60e250 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1430,6 +1430,7 @@ extern void dev_kfree_skb_irq(struct sk_buff *skb=
);
 extern void dev_kfree_skb_any(struct sk_buff *skb);
=20
 #define HAVE_NETIF_RX 1
+extern int		__netif_rx(struct sk_buff *skb);
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
diff --git a/net/core/dev.c b/net/core/dev.c
index 343883f..8ae3f19 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1909,6 +1909,44 @@ int weight_p __read_mostly =3D 64;            /*=
 old backlog weight */
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };
=20
=20
+/*
+ * helper function called from netif_rx() or loopback_xmit()
+ */
+int __netif_rx(struct sk_buff *skb)
+{
+	struct softnet_data *queue;
+	unsigned long flags;
+
+	/*
+	 * The code is rearranged so that the path is the most
+	 * short when CPU is congested, but is still operating.
+	 */
+	local_irq_save(flags);
+	queue =3D &__get_cpu_var(softnet_data);
+
+	__get_cpu_var(netdev_rx_stat).total++;
+	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
+		if (queue->input_pkt_queue.qlen) {
+enqueue:
+			__skb_queue_tail(&queue->input_pkt_queue, skb);
+			local_irq_restore(flags);
+			return NET_RX_SUCCESS;
+		}
+
+		napi_schedule(&queue->backlog);
+		goto enqueue;
+	}
+
+	__get_cpu_var(netdev_rx_stat).dropped++;
+	local_irq_restore(flags);
+	/*
+	 * Dont free skb here.
+	 * netif_rx() will call kfree_skb(skb)
+	 * loopback_xmit() will not free it but return an error to its caller
+	 */
+	return NET_RX_DROP;
+}
+
 /**
  *	netif_rx	-	post buffer to the network code
  *	@skb: buffer to post
@@ -1928,6 +1966,7 @@ int netif_rx(struct sk_buff *skb)
 {
 	struct softnet_data *queue;
 	unsigned long flags;
+	int ret;
=20
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -1936,32 +1975,14 @@ int netif_rx(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
=20
-	/*
-	 * The code is rearranged so that the path is the most
-	 * short when CPU is congested, but is still operating.
-	 */
-	local_irq_save(flags);
-	queue =3D &__get_cpu_var(softnet_data);
-
-	__get_cpu_var(netdev_rx_stat).total++;
-	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
-		if (queue->input_pkt_queue.qlen) {
-enqueue:
-			__skb_queue_tail(&queue->input_pkt_queue, skb);
-			local_irq_restore(flags);
-			return NET_RX_SUCCESS;
-		}
-
-		napi_schedule(&queue->backlog);
-		goto enqueue;
-	}
+	ret =3D __netif_rx(skb);
=20
-	__get_cpu_var(netdev_rx_stat).dropped++;
-	local_irq_restore(flags);
+	if (unlikely(ret =3D=3D NET_RX_DROP))
+		kfree_skb(skb);
=20
-	kfree_skb(skb);
-	return NET_RX_DROP;
+	return ret;
 }
+EXPORT_SYMBOL(netif_rx);
=20
 int netif_rx_ni(struct sk_buff *skb)
 {
@@ -5307,7 +5328,6 @@ EXPORT_SYMBOL(netdev_boot_setup_check);
 EXPORT_SYMBOL(netdev_set_master);
 EXPORT_SYMBOL(netdev_state_change);
 EXPORT_SYMBOL(netif_receive_skb);
-EXPORT_SYMBOL(netif_rx);
 EXPORT_SYMBOL(register_gifconf);
 EXPORT_SYMBOL(register_netdevice);
 EXPORT_SYMBOL(register_netdevice_notifier);

