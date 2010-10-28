From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [Just for fun] loopback: avoid softirq on most transmits
Date: Thu, 28 Oct 2010 21:48:46 +0200
Message-ID: <1288295326.2711.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47262 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604Ab0J1Tsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 15:48:50 -0400
Received: by wwe15 with SMTP id 15so2415890wwe.1
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 12:48:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the introduction of xmit_recursion percpu variable, its pretty
cheap to check our recursion level in loopback transmit, and avoid
raising softirq.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
tbench faster by 4%, sorry I couldnt resist...

 drivers/net/loopback.c    |   13 +++++++++++--
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |    2 +-
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 2d9663a..5bd73c0 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -74,7 +74,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 				 struct net_device *dev)
 {
 	struct pcpu_lstats *lb_stats;
-	int len;
+	int len, res;
 
 	skb_orphan(skb);
 
@@ -84,7 +84,16 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	lb_stats = this_cpu_ptr(dev->lstats);
 
 	len = skb->len;
-	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
+
+	/*
+	 * avoid raising softirq if our recursion level is low
+	 */
+	if (likely(__this_cpu_read(xmit_recursion) <= 2))
+		res = netif_receive_skb(skb);
+	else
+		res = netif_rx(skb);
+
+	if (likely(res == NET_RX_SUCCESS)) {
 		u64_stats_update_begin(&lb_stats->syncp);
 		lb_stats->bytes += len;
 		lb_stats->packets++;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 072652d..918330b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1741,6 +1741,9 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
+
+DECLARE_PER_CPU(int, xmit_recursion);
+
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 35dfb83..aadf09b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2208,7 +2208,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	return rc;
 }
 
-static DEFINE_PER_CPU(int, xmit_recursion);
+DEFINE_PER_CPU(int, xmit_recursion);
 #define RECURSION_LIMIT 10
 
 /**


