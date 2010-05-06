From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Consistent skb timestamping
Date: Thu, 06 May 2010 14:01:49 +0200
Message-ID: <1273147309.2357.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:40299 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423Ab0EFMCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 08:02:10 -0400
Received: by bwz19 with SMTP id 19so445970bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 05:02:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With RPS inclusion, skb timestamping is not consistent in RX path.

If netif_receive_skb() is used, its deferred after RPS dispatch.

If netif_rx() is used, its done before RPS dispatch.

This can give strange tcpdump timestamps results.

I think timestamping should be done as soon as possible in the receive
path, to get meaningful values (ie timestamps taken at the time packet
was delivered by NIC driver to our stack), even if NAPI already can
defer timestamping a bit (RPS can help to reduce the gap)

Remove timestamping from __netif_receive_skb, and add it to
netif_receive_skb(), before RPS.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 36d53be..3278003 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1454,7 +1454,7 @@ void net_disable_timestamp(void)
 }
 EXPORT_SYMBOL(net_disable_timestamp);
 
-static inline void net_timestamp(struct sk_buff *skb)
+static inline void net_timestamp_set(struct sk_buff *skb)
 {
 	if (atomic_read(&netstamp_needed))
 		__net_timestamp(skb);
@@ -1462,6 +1462,12 @@ static inline void net_timestamp(struct sk_buff *skb)
 		skb->tstamp.tv64 = 0;
 }
 
+static inline void net_timestamp_check(struct sk_buff *skb)
+{
+	if (!skb->tstamp.tv64 && atomic_read(&netstamp_needed))
+		__net_timestamp(skb);
+}
+
 /**
  * dev_forward_skb - loopback an skb to another netif
  *
@@ -1509,9 +1515,9 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 
 #ifdef CONFIG_NET_CLS_ACT
 	if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & AT_INGRESS)))
-		net_timestamp(skb);
+		net_timestamp_set(skb);
 #else
-	net_timestamp(skb);
+	net_timestamp_set(skb);
 #endif
 
 	rcu_read_lock();
@@ -2458,8 +2464,7 @@ int netif_rx(struct sk_buff *skb)
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
-	if (!skb->tstamp.tv64)
-		net_timestamp(skb);
+	net_timestamp_check(skb);
 
 #ifdef CONFIG_RPS
 	{
@@ -2780,9 +2785,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	int ret = NET_RX_DROP;
 	__be16 type;
 
-	if (!skb->tstamp.tv64)
-		net_timestamp(skb);
-
 	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
 		return NET_RX_SUCCESS;
 
@@ -2899,23 +2901,27 @@ out:
  */
 int netif_receive_skb(struct sk_buff *skb)
 {
+	net_timestamp_check(skb);
+
 #ifdef CONFIG_RPS
-	struct rps_dev_flow voidflow, *rflow = &voidflow;
-	int cpu, ret;
+	{
+		struct rps_dev_flow voidflow, *rflow = &voidflow;
+		int cpu, ret;
 
-	rcu_read_lock();
+		rcu_read_lock();
 
-	cpu = get_rps_cpu(skb->dev, skb, &rflow);
+		cpu = get_rps_cpu(skb->dev, skb, &rflow);
 
-	if (cpu >= 0) {
-		ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
-		rcu_read_unlock();
-	} else {
-		rcu_read_unlock();
-		ret = __netif_receive_skb(skb);
-	}
+		if (cpu >= 0) {
+			ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
+			rcu_read_unlock();
+		} else {
+			rcu_read_unlock();
+			ret = __netif_receive_skb(skb);
+		}
 
-	return ret;
+		return ret;
+	}
 #else
 	return __netif_receive_skb(skb);
 #endif


