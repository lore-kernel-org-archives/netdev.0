From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 07/10] netpoll: Move netpoll_trap under CONFIG_NETPOLL_TRAP
Date: Fri, 14 Mar 2014 20:49:43 -0700
Message-ID: <8738ikp1d4.fsf_-_@xmission.com>
References: <87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
	<20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:54785 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617AbaCODtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 23:49:49 -0400
In-Reply-To: <877g7wqg8e.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 20:43:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that we no longer need to receive packets to safely drain the
network drivers receive queue move netpoll_trap and netpoll_set_trap
under CONFIG_NETPOLL_TRAP

Making netpoll_trap and netpoll_set_trap noop inline functions
when CONFIG_NETPOLL_TRAP is not set.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netpoll.h |   11 +++++++++--
 net/core/netpoll.c      |   14 +++++++++-----
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 154f9776056c..ab9aaaff8d04 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -65,8 +65,6 @@ void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
 int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp);
 int netpoll_setup(struct netpoll *np);
-int netpoll_trap(void);
-void netpoll_set_trap(int trap);
 void __netpoll_cleanup(struct netpoll *np);
 void __netpoll_free_async(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
@@ -82,11 +80,20 @@ static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 }
 
 #ifdef CONFIG_NETPOLL_TRAP
+int netpoll_trap(void);
+void netpoll_set_trap(int trap);
 static inline bool netpoll_rx_processing(struct netpoll_info *npinfo)
 {
 	return !list_empty(&npinfo->rx_np);
 }
 #else
+static inline int netpoll_trap(void)
+{
+	return 0;
+}
+static inline void netpoll_set_trap(int trap)
+{
+}
 static inline bool netpoll_rx_processing(struct netpoll_info *npinfo)
 {
 	return false;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 793dc04d2f19..0e45835f1737 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -46,7 +46,9 @@
 
 static struct sk_buff_head skb_pool;
 
+#ifdef CONFIG_NETPOLL_TRAP
 static atomic_t trapped;
+#endif
 
 DEFINE_STATIC_SRCU(netpoll_srcu);
 
@@ -207,7 +209,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	}
 
 	if (rx_processing)
-		atomic_inc(&trapped);
+		netpoll_set_trap(1);
 
 	ops = dev->netdev_ops;
 	if (!ops->ndo_poll_controller) {
@@ -221,7 +223,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	poll_napi(dev, budget);
 
 	if (rx_processing)
-		atomic_dec(&trapped);
+		netpoll_set_trap(0);
 
 	up(&ni->dev_lock);
 
@@ -776,10 +778,10 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 		goto out;
 
 	/* check if netpoll clients need ARP */
-	if (skb->protocol == htons(ETH_P_ARP) && atomic_read(&trapped)) {
+	if (skb->protocol == htons(ETH_P_ARP) && netpoll_trap()) {
 		skb_queue_tail(&npinfo->neigh_tx, skb);
 		return 1;
-	} else if (pkt_is_ns(skb) && atomic_read(&trapped)) {
+	} else if (pkt_is_ns(skb) && netpoll_trap()) {
 		skb_queue_tail(&npinfo->neigh_tx, skb);
 		return 1;
 	}
@@ -896,7 +898,7 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 	return 1;
 
 out:
-	if (atomic_read(&trapped)) {
+	if (netpoll_trap()) {
 		kfree_skb(skb);
 		return 1;
 	}
@@ -1302,6 +1304,7 @@ out:
 }
 EXPORT_SYMBOL(netpoll_cleanup);
 
+#ifdef CONFIG_NETPOLL_TRAP
 int netpoll_trap(void)
 {
 	return atomic_read(&trapped);
@@ -1316,3 +1319,4 @@ void netpoll_set_trap(int trap)
 		atomic_dec(&trapped);
 }
 EXPORT_SYMBOL(netpoll_set_trap);
+#endif /* CONFIG_NETPOLL_TRAP */
-- 
1.7.5.4
