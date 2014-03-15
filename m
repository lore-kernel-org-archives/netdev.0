From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 09/10] netpoll: Move all receive processing under CONFIG_NETPOLL_TRAP
Date: Fri, 14 Mar 2014 20:50:58 -0700
Message-ID: <87r464nmql.fsf_-_@xmission.com>
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
Received: from out03.mta.xmission.com ([166.70.13.233]:54996 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754810AbaCODvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 23:51:06 -0400
In-Reply-To: <877g7wqg8e.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 20:43:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Make rx_skb_hook, and rx in struct netpoll depend on
CONFIG_NETPOLL_TRAP Make rx_lock, rx_np, and neigh_tx in struct
netpoll_info depend on CONFIG_NETPOLL_TRAP

Make the functions netpoll_rx_on, netpoll_rx, and netpoll_receive_skb
no-ops when CONFIG_NETPOLL_TRAP is not set.

Only build netpoll_neigh_reply, checksum_udp service_neigh_queue,
pkt_is_ns, and __netpoll_rx when CONFIG_NETPOLL_TRAP is defined.

Add helper functions netpoll_trap_setup, netpoll_trap_setup_info,
netpoll_trap_cleanup, and netpoll_trap_cleanup_info that initialize
and cleanup the struct netpoll and struct netpoll_info receive
specific fields when CONFIG_NETPOLL_TRAP is enabled and do nothing
otherwise.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netpoll.h |   73 +++++++++++++++++++++++-------------------
 net/core/netpoll.c      |   81 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 104 insertions(+), 50 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index ab9aaaff8d04..a0632af88d8b 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -24,32 +24,38 @@ struct netpoll {
 	struct net_device *dev;
 	char dev_name[IFNAMSIZ];
 	const char *name;
-	void (*rx_skb_hook)(struct netpoll *np, int source, struct sk_buff *skb,
-			    int offset, int len);
 
 	union inet_addr local_ip, remote_ip;
 	bool ipv6;
 	u16 local_port, remote_port;
 	u8 remote_mac[ETH_ALEN];
 
-	struct list_head rx; /* rx_np list element */
 	struct work_struct cleanup_work;
+
+#ifdef CONFIG_NETPOLL_TRAP
+	void (*rx_skb_hook)(struct netpoll *np, int source, struct sk_buff *skb,
+			    int offset, int len);
+	struct list_head rx; /* rx_np list element */
+#endif
 };
 
 struct netpoll_info {
 	atomic_t refcnt;
 
-	spinlock_t rx_lock;
 	struct semaphore dev_lock;
-	struct list_head rx_np; /* netpolls that registered an rx_skb_hook */
 
-	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
 	struct sk_buff_head txq;
 
 	struct delayed_work tx_work;
 
 	struct netpoll *netpoll;
 	struct rcu_head rcu;
+
+#ifdef CONFIG_NETPOLL_TRAP
+	spinlock_t rx_lock;
+	struct list_head rx_np; /* netpolls that registered an rx_skb_hook */
+	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
+#endif
 };
 
 #ifdef CONFIG_NETPOLL
@@ -68,7 +74,6 @@ int netpoll_setup(struct netpoll *np);
 void __netpoll_cleanup(struct netpoll *np);
 void __netpoll_free_async(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
-int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo);
 void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 			     struct net_device *dev);
 static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
@@ -82,25 +87,12 @@ static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 #ifdef CONFIG_NETPOLL_TRAP
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
+int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo);
 static inline bool netpoll_rx_processing(struct netpoll_info *npinfo)
 {
 	return !list_empty(&npinfo->rx_np);
 }
-#else
-static inline int netpoll_trap(void)
-{
-	return 0;
-}
-static inline void netpoll_set_trap(int trap)
-{
-}
-static inline bool netpoll_rx_processing(struct netpoll_info *npinfo)
-{
-	return false;
-}
-#endif
 
-#ifdef CONFIG_NETPOLL
 static inline bool netpoll_rx_on(struct sk_buff *skb)
 {
 	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
@@ -138,6 +130,33 @@ static inline int netpoll_receive_skb(struct sk_buff *skb)
 	return 0;
 }
 
+#else
+static inline int netpoll_trap(void)
+{
+	return 0;
+}
+static inline void netpoll_set_trap(int trap)
+{
+}
+static inline bool netpoll_rx_processing(struct netpoll_info *npinfo)
+{
+	return false;
+}
+static inline bool netpoll_rx(struct sk_buff *skb)
+{
+	return false;
+}
+static inline bool netpoll_rx_on(struct sk_buff *skb)
+{
+	return false;
+}
+static inline int netpoll_receive_skb(struct sk_buff *skb)
+{
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_NETPOLL
 static inline void *netpoll_poll_lock(struct napi_struct *napi)
 {
 	struct net_device *dev = napi->dev;
@@ -166,18 +185,6 @@ static inline bool netpoll_tx_running(struct net_device *dev)
 }
 
 #else
-static inline bool netpoll_rx(struct sk_buff *skb)
-{
-	return false;
-}
-static inline bool netpoll_rx_on(struct sk_buff *skb)
-{
-	return false;
-}
-static inline int netpoll_receive_skb(struct sk_buff *skb)
-{
-	return 0;
-}
 static inline void *netpoll_poll_lock(struct napi_struct *napi)
 {
 	return NULL;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index b69bb3f1ba3f..adb5768be5a5 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -48,6 +48,7 @@ static struct sk_buff_head skb_pool;
 
 #ifdef CONFIG_NETPOLL_TRAP
 static atomic_t trapped;
+static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo);
 #endif
 
 DEFINE_STATIC_SRCU(netpoll_srcu);
@@ -61,7 +62,6 @@ DEFINE_STATIC_SRCU(netpoll_srcu);
 	 MAX_UDP_CHUNK)
 
 static void zap_completion_queue(void);
-static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo);
 static void netpoll_async_cleanup(struct work_struct *work);
 
 static unsigned int carrier_timeout = 4;
@@ -109,6 +109,7 @@ static void queue_process(struct work_struct *work)
 	}
 }
 
+#ifdef CONFIG_NETPOLL_TRAP
 static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
 			    unsigned short ulen, __be32 saddr, __be32 daddr)
 {
@@ -127,6 +128,7 @@ static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
 
 	return __skb_checksum_complete(skb);
 }
+#endif /* CONFIG_NETPOLL_TRAP */
 
 /*
  * Check whether delayed processing was scheduled for our NIC. If so,
@@ -179,6 +181,7 @@ static void poll_napi(struct net_device *dev, int budget)
 	}
 }
 
+#ifdef CONFIG_NETPOLL_TRAP
 static void service_neigh_queue(struct net_device *dev,
 				struct netpoll_info *npi)
 {
@@ -197,6 +200,12 @@ static void service_neigh_queue(struct net_device *dev,
 	while ((skb = skb_dequeue(&npi->neigh_tx)))
 		netpoll_neigh_reply(skb, npi);
 }
+#else /* !CONFIG_NETPOLL_TRAP */
+static inline void service_neigh_queue(struct net_device *dev,
+				struct netpoll_info *npi)
+{
+}
+#endif /* CONFIG_NETPOLL_TRAP */
 
 static void netpoll_poll_dev(struct net_device *dev)
 {
@@ -522,6 +531,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 }
 EXPORT_SYMBOL(netpoll_send_udp);
 
+#ifdef CONFIG_NETPOLL_TRAP
 static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
 {
 	int size, type = ARPOP_REPLY;
@@ -900,6 +910,55 @@ out:
 	return 0;
 }
 
+static void netpoll_trap_setup_info(struct netpoll_info *npinfo)
+{
+	INIT_LIST_HEAD(&npinfo->rx_np);
+	spin_lock_init(&npinfo->rx_lock);
+	skb_queue_head_init(&npinfo->neigh_tx);
+}
+
+static void netpoll_trap_cleanup_info(struct netpoll_info *npinfo)
+{
+	skb_queue_purge(&npinfo->neigh_tx);
+}
+
+static void netpoll_trap_setup(struct netpoll *np, struct netpoll_info *npinfo)
+{
+	unsigned long flags;
+	if (np->rx_skb_hook) {
+		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		list_add_tail(&np->rx, &npinfo->rx_np);
+		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+	}
+}
+
+static void netpoll_trap_cleanup(struct netpoll *np, struct netpoll_info *npinfo)
+{
+	unsigned long flags;
+	if (!list_empty(&npinfo->rx_np)) {
+		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		list_del(&np->rx);
+		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+	}
+}
+
+#else /* !CONFIG_NETPOLL_TRAP */
+static inline void netpoll_trap_setup_info(struct netpoll_info *npinfo)
+{
+}
+static inline void netpoll_trap_cleanup_info(struct netpoll_info *npinfo)
+{
+}
+static inline 
+void netpoll_trap_setup(struct netpoll *np, struct netpoll_info *npinfo)
+{
+}
+static inline
+void netpoll_trap_cleanup(struct netpoll *np, struct netpoll_info *npinfo)
+{
+}
+#endif /* CONFIG_NETPOLL_TRAP */
+
 void netpoll_print_options(struct netpoll *np)
 {
 	np_info(np, "local port %d\n", np->local_port);
@@ -1023,7 +1082,6 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 {
 	struct netpoll_info *npinfo;
 	const struct net_device_ops *ops;
-	unsigned long flags;
 	int err;
 
 	np->dev = ndev;
@@ -1045,11 +1103,9 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 			goto out;
 		}
 
-		INIT_LIST_HEAD(&npinfo->rx_np);
+		netpoll_trap_setup_info(npinfo);
 
-		spin_lock_init(&npinfo->rx_lock);
 		sema_init(&npinfo->dev_lock, 1);
-		skb_queue_head_init(&npinfo->neigh_tx);
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
 
@@ -1068,11 +1124,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 
 	npinfo->netpoll = np;
 
-	if (np->rx_skb_hook) {
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		list_add_tail(&np->rx, &npinfo->rx_np);
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-	}
+	netpoll_trap_setup(np, npinfo);
 
 	/* last thing to do is link it to the net device structure */
 	rcu_assign_pointer(ndev->npinfo, npinfo);
@@ -1222,7 +1274,7 @@ static void rcu_cleanup_netpoll_info(struct rcu_head *rcu_head)
 	struct netpoll_info *npinfo =
 			container_of(rcu_head, struct netpoll_info, rcu);
 
-	skb_queue_purge(&npinfo->neigh_tx);
+	netpoll_trap_cleanup_info(npinfo);
 	skb_queue_purge(&npinfo->txq);
 
 	/* we can't call cancel_delayed_work_sync here, as we are in softirq */
@@ -1238,7 +1290,6 @@ static void rcu_cleanup_netpoll_info(struct rcu_head *rcu_head)
 void __netpoll_cleanup(struct netpoll *np)
 {
 	struct netpoll_info *npinfo;
-	unsigned long flags;
 
 	/* rtnl_dereference would be preferable here but
 	 * rcu_cleanup_netpoll path can put us in here safely without
@@ -1248,11 +1299,7 @@ void __netpoll_cleanup(struct netpoll *np)
 	if (!npinfo)
 		return;
 
-	if (!list_empty(&npinfo->rx_np)) {
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		list_del(&np->rx);
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-	}
+	netpoll_trap_cleanup(np, npinfo);
 
 	synchronize_srcu(&netpoll_srcu);
 
-- 
1.7.5.4
