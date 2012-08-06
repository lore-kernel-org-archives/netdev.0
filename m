From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/8] netpoll: make __netpoll_cleanup non-block
Date: Mon,  6 Aug 2012 22:23:26 +0800
Message-ID: <1344263012-4031-3-git-send-email-amwang@redhat.com>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756551Ab2HFOXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 10:23:49 -0400
In-Reply-To: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like the previous patch, slave_disable_netpoll() and __netpoll_cleanup()
may be called with read_lock() held too, so we should make them
non-block, by moving the cleanup and kfree() to call_rcu_bh() callbacks.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/bonding/bond_main.c |    4 +--
 include/linux/netpoll.h         |    3 ++
 net/8021q/vlan_dev.c            |    6 +----
 net/bridge/br_device.c          |    6 +----
 net/core/netpoll.c              |   42 +++++++++++++++++++++++++++++---------
 5 files changed, 38 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8697136..e428916 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1257,9 +1257,7 @@ static inline void slave_disable_netpoll(struct slave *slave)
 		return;
 
 	slave->np = NULL;
-	synchronize_rcu_bh();
-	__netpoll_cleanup(np);
-	kfree(np);
+	__netpoll_free_rcu(np);
 }
 static inline bool slave_dev_support_netpoll(struct net_device *slave_dev)
 {
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index bf2d51e..907812e 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -23,6 +23,7 @@ struct netpoll {
 	u8 remote_mac[ETH_ALEN];
 
 	struct list_head rx; /* rx_np list element */
+	struct rcu_head rcu;
 };
 
 struct netpoll_info {
@@ -38,6 +39,7 @@ struct netpoll_info {
 	struct delayed_work tx_work;
 
 	struct netpoll *netpoll;
+	struct rcu_head rcu;
 };
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
@@ -48,6 +50,7 @@ int netpoll_setup(struct netpoll *np);
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
 void __netpoll_cleanup(struct netpoll *np);
+void __netpoll_free_rcu(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb);
 void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ee4ae09..b65623f 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -704,11 +704,7 @@ static void vlan_dev_netpoll_cleanup(struct net_device *dev)
 
 	info->netpoll = NULL;
 
-        /* Wait for transmitting packets to finish before freeing. */
-        synchronize_rcu_bh();
-
-        __netpoll_cleanup(netpoll);
-        kfree(netpoll);
+	__netpoll_free_rcu(netpoll);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ed0e0f9..f41ba40 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -267,11 +267,7 @@ void br_netpoll_disable(struct net_bridge_port *p)
 
 	p->np = NULL;
 
-	/* Wait for transmitting packets to finish before freeing. */
-	synchronize_rcu_bh();
-
-	__netpoll_cleanup(np);
-	kfree(np);
+	__netpoll_free_rcu(np);
 }
 
 #endif
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 37cc854..dc17f1d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -878,6 +878,24 @@ static int __init netpoll_init(void)
 }
 core_initcall(netpoll_init);
 
+static void rcu_cleanup_netpoll_info(struct rcu_head *rcu_head)
+{
+	struct netpoll_info *npinfo =
+			container_of(rcu_head, struct netpoll_info, rcu);
+
+	skb_queue_purge(&npinfo->arp_tx);
+	skb_queue_purge(&npinfo->txq);
+
+	/* we can't call cancel_delayed_work_sync here, as we are in softirq */
+	cancel_delayed_work(&npinfo->tx_work);
+
+	/* clean after last, unfinished work */
+	__skb_queue_purge(&npinfo->txq);
+	/* now cancel it again */
+	cancel_delayed_work(&npinfo->tx_work);
+	kfree(npinfo);
+}
+
 void __netpoll_cleanup(struct netpoll *np)
 {
 	struct netpoll_info *npinfo;
@@ -903,20 +921,24 @@ void __netpoll_cleanup(struct netpoll *np)
 			ops->ndo_netpoll_cleanup(np->dev);
 
 		RCU_INIT_POINTER(np->dev->npinfo, NULL);
+		call_rcu_bh(&npinfo->rcu, rcu_cleanup_netpoll_info);
+	}
+}
+EXPORT_SYMBOL_GPL(__netpoll_cleanup);
 
-		/* avoid racing with NAPI reading npinfo */
-		synchronize_rcu_bh();
+static void rcu_cleanup_netpoll(struct rcu_head *rcu_head)
+{
+	struct netpoll *np = container_of(rcu_head, struct netpoll, rcu);
 
-		skb_queue_purge(&npinfo->arp_tx);
-		skb_queue_purge(&npinfo->txq);
-		cancel_delayed_work_sync(&npinfo->tx_work);
+	__netpoll_cleanup(np);
+	kfree(np);
+}
 
-		/* clean after last, unfinished work */
-		__skb_queue_purge(&npinfo->txq);
-		kfree(npinfo);
-	}
+void __netpoll_free_rcu(struct netpoll *np)
+{
+	call_rcu_bh(&np->rcu, rcu_cleanup_netpoll);
 }
-EXPORT_SYMBOL_GPL(__netpoll_cleanup);
+EXPORT_SYMBOL_GPL(__netpoll_free_rcu);
 
 void netpoll_cleanup(struct netpoll *np)
 {
-- 
1.7.7.6
