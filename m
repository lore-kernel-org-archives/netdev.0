From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2 1/2] netpoll: Fix __netpoll_rcu_free so that it can hold the rtnl lock
Date: Mon, 11 Feb 2013 15:25:30 -0500
Message-ID: <1360614331-29247-2-git-send-email-nhorman@tuxdriver.com>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
 <1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35204 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758539Ab3BKU0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 15:26:20 -0500
In-Reply-To: <1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__netpoll_rcu_free is used to free netpoll structures when the rtnl_lock is
already held.  The mechanism is used to asynchronously call __netpoll_cleanup
outside of the holding of the rtnl_lock, so as to avoid deadlock.
Unfortunately, __netpoll_cleanup modifies pointers (dev->np), which means the
rtnl_lock must be held while calling it.  Further, it cannot be held, because
rcu callbacks may be issued in softirq contexts, which cannot sleep.

Fix this by converting the rcu callback to a work queue that is guaranteed to
get scheduled in process context, so that we can hold the rtnl properly while
calling __netpoll_cleanup

Tested successfully by myself.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Cong Wang <amwang@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bonding/bond_main.c |  2 +-
 include/linux/netpoll.h         |  4 ++--
 net/8021q/vlan_dev.c            |  2 +-
 net/bridge/br_device.c          |  2 +-
 net/core/netpoll.c              | 16 ++++++++++------
 5 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2239937..94c1534 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1249,7 +1249,7 @@ static inline void slave_disable_netpoll(struct slave *slave)
 		return;
 
 	slave->np = NULL;
-	__netpoll_free_rcu(np);
+	__netpoll_free_async(np);
 }
 static inline bool slave_dev_support_netpoll(struct net_device *slave_dev)
 {
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index ab856d5..9d7d8c6 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -32,7 +32,7 @@ struct netpoll {
 	u8 remote_mac[ETH_ALEN];
 
 	struct list_head rx; /* rx_np list element */
-	struct rcu_head rcu;
+	struct work_struct cleanup_work;
 };
 
 struct netpoll_info {
@@ -68,7 +68,7 @@ int netpoll_setup(struct netpoll *np);
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
 void __netpoll_cleanup(struct netpoll *np);
-void __netpoll_free_rcu(struct netpoll *np);
+void __netpoll_free_async(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo);
 void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 09f9108..b29fba0 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -723,7 +723,7 @@ static void vlan_dev_netpoll_cleanup(struct net_device *dev)
 
 	vlan->netpoll = NULL;
 
-	__netpoll_free_rcu(netpoll);
+	__netpoll_free_async(netpoll);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e1bc090..bd03084 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -266,7 +266,7 @@ void br_netpoll_disable(struct net_bridge_port *p)
 
 	p->np = NULL;
 
-	__netpoll_free_rcu(np);
+	__netpoll_free_async(np);
 }
 
 #endif
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index edcd9ad..c536474 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -61,6 +61,7 @@ static struct srcu_struct netpoll_srcu;
 
 static void zap_completion_queue(void);
 static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo);
+static void netpoll_async_cleanup(struct work_struct *work);
 
 static unsigned int carrier_timeout = 4;
 module_param(carrier_timeout, uint, 0644);
@@ -1020,6 +1021,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 
 	np->dev = ndev;
 	strlcpy(np->dev_name, ndev->name, IFNAMSIZ);
+	INIT_WORK(&np->cleanup_work, netpoll_async_cleanup);
 
 	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
 	    !ndev->netdev_ops->ndo_poll_controller) {
@@ -1255,25 +1257,27 @@ void __netpoll_cleanup(struct netpoll *np)
 		if (ops->ndo_netpoll_cleanup)
 			ops->ndo_netpoll_cleanup(np->dev);
 
-		RCU_INIT_POINTER(np->dev->npinfo, NULL);
+		rcu_assign_pointer(np->dev->npinfo, NULL);
 		call_rcu_bh(&npinfo->rcu, rcu_cleanup_netpoll_info);
 	}
 }
 EXPORT_SYMBOL_GPL(__netpoll_cleanup);
 
-static void rcu_cleanup_netpoll(struct rcu_head *rcu_head)
+static void netpoll_async_cleanup(struct work_struct *work)
 {
-	struct netpoll *np = container_of(rcu_head, struct netpoll, rcu);
+	struct netpoll *np = container_of(work, struct netpoll, cleanup_work);
 
+	rtnl_lock();
 	__netpoll_cleanup(np);
+	rtnl_unlock();
 	kfree(np);
 }
 
-void __netpoll_free_rcu(struct netpoll *np)
+void __netpoll_free_async(struct netpoll *np)
 {
-	call_rcu_bh(&np->rcu, rcu_cleanup_netpoll);
+	schedule_work(&np->cleanup_work);
 }
-EXPORT_SYMBOL_GPL(__netpoll_free_rcu);
+EXPORT_SYMBOL_GPL(__netpoll_free_async);
 
 void netpoll_cleanup(struct netpoll *np)
 {
-- 
1.7.11.7
