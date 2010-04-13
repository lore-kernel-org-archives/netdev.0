From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Tue, 13 Apr 2010 09:14:17 +0200
Message-ID: <1271142857.16881.193.camel@edumazet-laptop>
References: <1271100042.9831.20.camel@localhost>
	 <1271101251.16881.135.camel@edumazet-laptop>
	 <m2m65634d661004121354ta0189542l80473b82911e43f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Paris <eparis@redhat.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:55363 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab0DMHOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 03:14:25 -0400
Received: by bwz19 with SMTP id 19so141531bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 00:14:23 -0700 (PDT)
In-Reply-To: <m2m65634d661004121354ta0189542l80473b82911e43f4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 13:54 -0700, Tom Herbert a =C3=A9crit :

> Would it be better to disable preemption in netif_rx?  Also note that
> with RFS we would be taking rcu_read_lock in netif_rx anyway and that
> could cover all the instances of smp_processor_id().
>=20

Ok that makes sense.

What do you think applying a small fix before RFS integration, it is
better to have smaller patches anyway :)

[PATCH net-next-2.6] net: netif_rx() must disable preemption

Eric Paris reported netif_rx() is calling smp_processor_id() from
preemptible context, in particular when caller is
ip_dev_loopback_xmit().

RPS commit added this smp_processor_id() call, this patch makes sure
preemption is disabled. rps_get_cpus() wants rcu_read_lock() anyway, we
can dot it a bit earlier.

Reported-by: Eric Paris <eparis@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a10a216..a96ea6a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2206,6 +2206,7 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_s=
tat) =3D { 0, };
 /*
  * get_rps_cpu is called from netif_receive_skb and returns the target
  * CPU from the RPS map of the receiving queue for a given skb.
+ * rcu_read_lock must be held on entry.
  */
 static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 {
@@ -2217,8 +2218,6 @@ static int get_rps_cpu(struct net_device *dev, st=
ruct sk_buff *skb)
 	u8 ip_proto;
 	u32 addr1, addr2, ports, ihl;
=20
-	rcu_read_lock();
-
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index =3D skb_get_rx_queue(skb);
 		if (unlikely(index >=3D dev->num_rx_queues)) {
@@ -2296,7 +2295,6 @@ got_hash:
 	}
=20
 done:
-	rcu_read_unlock();
 	return cpu;
 }
=20
@@ -2392,7 +2390,7 @@ enqueue:
=20
 int netif_rx(struct sk_buff *skb)
 {
-	int cpu;
+	int ret;
=20
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -2402,14 +2400,21 @@ int netif_rx(struct sk_buff *skb)
 		net_timestamp(skb);
=20
 #ifdef CONFIG_RPS
+	{
+	int cpu;
+
+	rcu_read_lock();
 	cpu =3D get_rps_cpu(skb->dev, skb);
 	if (cpu < 0)
 		cpu =3D smp_processor_id();
+	ret =3D enqueue_to_backlog(skb, cpu);
+	rcu_read_unlock();
+	}
 #else
-	cpu =3D smp_processor_id();
+	ret =3D enqueue_to_backlog(skb, get_cpu());
+	put_cpu();
 #endif
-
-	return enqueue_to_backlog(skb, cpu);
+	return ret;
 }
 EXPORT_SYMBOL(netif_rx);
=20


