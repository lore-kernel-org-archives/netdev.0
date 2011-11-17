From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: use jump_label to shortcut RPS if not setup
Date: Thu, 17 Nov 2011 11:33:47 +0100
Message-ID: <1321526027.2751.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61139 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756365Ab1KQKdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 05:33:51 -0500
Received: by bke11 with SMTP id 11so1787637bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 02:33:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most machines dont use RPS/RFS, and pay a fair amount of instructions in
netif_receive_skb() / get_rps_cpu() just to discover RPS/RFS is not
setup.

Add a jump_label named rps_needed.

If no device rps_map or global rps_sock_flow_table is setup,
netif_receive_skb() does a single instruction instead of many ones,
including conditional jumps.

jmp +0    (if CONFIG_JUMP_LABEL=y)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h  |    5 +++++
 net/core/dev.c             |   14 ++++++--------
 net/core/net-sysfs.c       |    7 +++++--
 net/core/sysctl_net_core.c |    9 +++++++--
 4 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4d5698a..0bbe030 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -214,6 +214,11 @@ enum {
 #include <linux/cache.h>
 #include <linux/skbuff.h>
 
+#ifdef CONFIG_RPS
+#include <linux/jump_label.h>
+extern struct jump_label_key rps_needed;
+#endif
+
 struct neighbour;
 struct neigh_parms;
 struct sk_buff;
diff --git a/net/core/dev.c b/net/core/dev.c
index 26c49d5..4c3942c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2711,6 +2711,8 @@ EXPORT_SYMBOL(__skb_get_rxhash);
 struct rps_sock_flow_table __rcu *rps_sock_flow_table __read_mostly;
 EXPORT_SYMBOL(rps_sock_flow_table);
 
+struct jump_label_key rps_needed __read_mostly;
+
 static struct rps_dev_flow *
 set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	    struct rps_dev_flow *rflow, u16 next_cpu)
@@ -3359,7 +3361,7 @@ int netif_receive_skb(struct sk_buff *skb)
 		return NET_RX_SUCCESS;
 
 #ifdef CONFIG_RPS
-	{
+	if (static_branch(&rps_needed)) {
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
 		int cpu, ret;
 
@@ -3370,16 +3372,12 @@ int netif_receive_skb(struct sk_buff *skb)
 		if (cpu >= 0) {
 			ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
 			rcu_read_unlock();
-		} else {
-			rcu_read_unlock();
-			ret = __netif_receive_skb(skb);
+			return ret;
 		}
-
-		return ret;
+		rcu_read_unlock();
 	}
-#else
-	return __netif_receive_skb(skb);
 #endif
+	return __netif_receive_skb(skb);
 }
 EXPORT_SYMBOL(netif_receive_skb);
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 602b141..db6c2f8 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -606,9 +606,12 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	rcu_assign_pointer(queue->rps_map, map);
 	spin_unlock(&rps_map_lock);
 
-	if (old_map)
+	if (map)
+		jump_label_inc(&rps_needed);
+	if (old_map) {
 		kfree_rcu(old_map, rcu);
-
+		jump_label_dec(&rps_needed);
+	}
 	free_cpumask_var(mask);
 	return len;
 }
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 77a65f0..d05559d 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -68,8 +68,13 @@ static int rps_sock_flow_sysctl(ctl_table *table, int write,
 
 		if (sock_table != orig_sock_table) {
 			rcu_assign_pointer(rps_sock_flow_table, sock_table);
-			synchronize_rcu();
-			vfree(orig_sock_table);
+			if (sock_table)
+				jump_label_inc(&rps_needed);
+			if (orig_sock_table) {
+				jump_label_dec(&rps_needed);
+				synchronize_rcu();
+				vfree(orig_sock_table);
+			}
 		}
 	}
 
