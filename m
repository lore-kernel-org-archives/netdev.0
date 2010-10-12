From: nhorman@tuxdriver.com
Subject: [PATCH 1/5] Fix bonding drivers improper modification of netpoll structure
Date: Tue, 12 Oct 2010 16:29:33 -0400
Message-ID: <1286915377-1612-2-git-send-email-nhorman@tuxdriver.com>
References: <1286915377-1612-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-076-182-075-229.nc.res.rr.com ([76.182.75.229]:50234 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750927Ab0JLVXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 17:23:09 -0400
In-Reply-To: <1286915377-1612-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

The bonding driver currently modifies the netpoll structure in its xmit path
while sending frames from netpoll.  This is racy, as other cpus can access the
netpoll structure in parallel. Since the bonding driver points np->dev to a
slave device, other cpus can inadvertently attempt to send data directly to
slave devices, leading to improper locking with the bonding master, lost frames,
and deadlocks.  This patch fixes that up.

This patch also removes the real_dev pointer from the netpoll structure as that
data is really only used by bonding in the poll_controller, and we can emulate
its behavior by check each slave for IS_UP.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/bonding/bond_main.c |   15 +++++++++------
 include/linux/netpoll.h         |    9 +++++++--
 net/core/netpoll.c              |    6 +++---
 3 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a0bf35d..eb7d089 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -449,11 +449,9 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 	if (unlikely(bond->dev->priv_flags & IFF_IN_NETPOLL)) {
 		struct netpoll *np = bond->dev->npinfo->netpoll;
 		slave_dev->npinfo = bond->dev->npinfo;
-		np->real_dev = np->dev = skb->dev;
 		slave_dev->priv_flags |= IFF_IN_NETPOLL;
-		netpoll_send_skb(np, skb);
+		netpoll_send_skb_on_dev(np, skb, slave_dev);
 		slave_dev->priv_flags &= ~IFF_IN_NETPOLL;
-		np->dev = bond->dev;
 	} else
 #endif
 		dev_queue_xmit(skb);
@@ -1332,9 +1330,14 @@ static bool slaves_support_netpoll(struct net_device *bond_dev)
 
 static void bond_poll_controller(struct net_device *bond_dev)
 {
-	struct net_device *dev = bond_dev->npinfo->netpoll->real_dev;
-	if (dev != bond_dev)
-		netpoll_poll_dev(dev);
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	int i;
+
+	bond_for_each_slave(bond, slave, i) {
+		if (slave->dev && IS_UP(slave->dev))
+			netpoll_poll_dev(slave->dev);
+	}
 }
 
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 50d8009..79358bb 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -14,7 +14,6 @@
 
 struct netpoll {
 	struct net_device *dev;
-	struct net_device *real_dev;
 	char dev_name[IFNAMSIZ];
 	const char *name;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
@@ -53,7 +52,13 @@ void netpoll_set_trap(int trap);
 void __netpoll_cleanup(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb);
-void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
+void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
+			     struct net_device *dev);
+static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
+{
+	netpoll_send_skb_on_dev(np, skb, np->dev);
+}
+
 
 
 #ifdef CONFIG_NETPOLL
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 537e01a..4e98ffa 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -288,11 +288,11 @@ static int netpoll_owner_active(struct net_device *dev)
 	return 0;
 }
 
-void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
+void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
+			     struct net_device *dev)
 {
 	int status = NETDEV_TX_BUSY;
 	unsigned long tries;
-	struct net_device *dev = np->dev;
 	const struct net_device_ops *ops = dev->netdev_ops;
 	/* It is up to the caller to keep npinfo alive. */
 	struct netpoll_info *npinfo = np->dev->npinfo;
@@ -346,7 +346,7 @@ void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 		schedule_delayed_work(&npinfo->tx_work,0);
 	}
 }
-EXPORT_SYMBOL(netpoll_send_skb);
+EXPORT_SYMBOL(netpoll_send_skb_on_dev);
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 {
-- 
1.7.2.3

