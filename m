From: David Miller <davem@davemloft.net>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 00:14:46 -0700 (PDT)
Message-ID: <20100415.001446.244372815.davem@davemloft.net>
References: <1271101251.16881.135.camel@edumazet-laptop>
	<m2m65634d661004121354ta0189542l80473b82911e43f4@mail.gmail.com>
	<1271142857.16881.193.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eparis@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50887
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752859Ab0DOHOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 03:14:41 -0400
In-Reply-To: <1271142857.16881.193.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Apr 2010 09:14:17 +0200

> [PATCH net-next-2.6] net: netif_rx() must disable preemption
> 
> Eric Paris reported netif_rx() is calling smp_processor_id() from
> preemptible context, in particular when caller is
> ip_dev_loopback_xmit().
> 
> RPS commit added this smp_processor_id() call, this patch makes sure
> preemption is disabled. rps_get_cpus() wants rcu_read_lock() anyway, we
> can dot it a bit earlier.
> 
> Reported-by: Eric Paris <eparis@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I've applied this with some coding style fixups.

Thanks!

--------------------
net: netif_rx() must disable preemption

Eric Paris reported netif_rx() is calling smp_processor_id() from
preemptible context, in particular when caller is
ip_dev_loopback_xmit().

RPS commit added this smp_processor_id() call, this patch makes sure
preemption is disabled. rps_get_cpus() wants rcu_read_lock() anyway, we
can dot it a bit earlier.

Reported-by: Eric Paris <eparis@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 876b111..e8041eb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2206,6 +2206,7 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 /*
  * get_rps_cpu is called from netif_receive_skb and returns the target
  * CPU from the RPS map of the receiving queue for a given skb.
+ * rcu_read_lock must be held on entry.
  */
 static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 {
@@ -2217,8 +2218,6 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 	u8 ip_proto;
 	u32 addr1, addr2, ports, ihl;
 
-	rcu_read_lock();
-
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
 		if (unlikely(index >= dev->num_rx_queues)) {
@@ -2296,7 +2295,6 @@ got_hash:
 	}
 
 done:
-	rcu_read_unlock();
 	return cpu;
 }
 
@@ -2392,7 +2390,7 @@ enqueue:
 
 int netif_rx(struct sk_buff *skb)
 {
-	int cpu;
+	int ret;
 
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -2402,14 +2400,21 @@ int netif_rx(struct sk_buff *skb)
 		net_timestamp(skb);
 
 #ifdef CONFIG_RPS
-	cpu = get_rps_cpu(skb->dev, skb);
-	if (cpu < 0)
-		cpu = smp_processor_id();
+	{
+		int cpu;
+
+		rcu_read_lock();
+		cpu = get_rps_cpu(skb->dev, skb);
+		if (cpu < 0)
+			cpu = smp_processor_id();
+		ret = enqueue_to_backlog(skb, cpu);
+		rcu_read_unlock();
+	}
 #else
-	cpu = smp_processor_id();
+	ret = enqueue_to_backlog(skb, get_cpu());
+	put_cpu();
 #endif
-
-	return enqueue_to_backlog(skb, cpu);
+	return ret;
 }
 EXPORT_SYMBOL(netif_rx);
 
-- 
1.7.0.4

