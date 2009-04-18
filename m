From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loopback: packet drops accounting
Date: Sat, 18 Apr 2009 10:03:10 +0200
Message-ID: <49E9893E.90300@cosmosbay.com>
References: <49E78DE5.10104@hartkopp.net>	<20090417.013853.04495551.davem@davemloft.net>	<49E84459.1060507@cosmosbay.com> <20090417.015914.09817926.davem@davemloft.net> <49E84B99.1080502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52916 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbZDRIDT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 04:03:19 -0400
In-Reply-To: <49E84B99.1080502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Fri, 17 Apr 2009 10:56:57 +0200
>>
>>> We can in some situations drop packets in netif_rx()
>>>
>>> loopback driver does not report these (unlikely) drops to its stats=
,
>>> and incorrectly change packets/bytes counts.
>>>
>>> After this patch applied, "ifconfig lo" can reports these drops as =
in :
>>>
>>> # ifconfig lo
>>> lo        Link encap:Local Loopback
>>>           inet addr:127.0.0.1  Mask:255.0.0.0
>>>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>>>           RX packets:692562900 errors:0 dropped:0 overruns:0 frame:=
0
>>>           TX packets:692562900 errors:3228 dropped:3228 overruns:0 =
carrier:0
>>>           collisions:0 txqueuelen:0
>>>           RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.6 G=
iB)
>>>
>>> I chose to reflect those errors only in tx_dropped/tx_errors, and n=
ot mirror
>>> these errors in rx_dropped/rx_errors.
>>>
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> Well, logically the receive is what failed, not the transmit.
>>
>> I think it's therefore misleading to count it as a TX drop.
>>
>> Do you feel strongly about this?
>=20

Hi David

You were right :)

Considering that loopbak_xmit() calls eth_type_trans(skb, dev) and
this function already starts the RX handling of the packet (skb_pull(..=
=2E))

So, trying to make loopback_xmit() returns NETDEV_TX_BUSY is wrong too,
or too complex, because we would have to undo all changes that might
happened during failed xmit. This would be hard to maintain and
over-engineering at least, given that these drops are very unlikely.

So I resubmit my initial patch, changing the errors to be reported on t=
he
rx stats.

Thanks

[PATCH] loopback: packet drops accounting

We can in some situations drop packets in netif_rx()

loopback driver does not report these (unlikely) drops to its stats,
and incorrectly change packets/bytes counts.

After this patch applied, "ifconfig lo" can reports these drops as in :

# ifconfig lo
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:692562900 errors:3228 dropped:3228 overruns:0 fram=
e:0
          TX packets:692562900 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2865674174 (2.6 GiB)  TX bytes:2865674174 (2.6 GiB)

I initialy chose to reflect those errors only in tx_dropped/tx_errors, =
but David
convinced me that it was really RX errors, as loopback_xmit() really st=
arts
a RX process. (calling eth_type_trans() for example, that itself pulls =
the ethernet header)

These errors are accounted in rx_dropped/rx_errors.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 drivers/net/loopback.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b7d438a..a036296 100644
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
@@ -71,18 +72,22 @@ struct pcpu_lstats {
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
+	if (likely(netif_rx(skb) =3D=3D NET_RX_SUCCESS)) {
+		lb_stats->bytes +=3D len;
+		lb_stats->packets++;
+	} else
+		lb_stats->drops++;
=20
 	return 0;
 }
@@ -93,6 +98,7 @@ static struct net_device_stats *loopback_get_stats(st=
ruct net_device *dev)
 	struct net_device_stats *stats =3D &dev->stats;
 	unsigned long bytes =3D 0;
 	unsigned long packets =3D 0;
+	unsigned long drops =3D 0;
 	int i;
=20
 	pcpu_lstats =3D dev->ml_priv;
@@ -102,11 +108,14 @@ static struct net_device_stats *loopback_get_stat=
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
+	stats->rx_dropped =3D drops;
+	stats->rx_errors  =3D drops;
+	stats->rx_bytes   =3D bytes;
+	stats->tx_bytes   =3D bytes;
 	return stats;
 }
=20

