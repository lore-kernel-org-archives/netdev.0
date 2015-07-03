From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v2 4/5] ipvlan: protect addresses with internal spinlock
Date: Fri, 03 Jul 2015 15:58:40 +0300
Message-ID: <20150703125840.24121.91556.stgit@buzz>
References: <20150703125132.24121.50592.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:55998 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754987AbbGCM6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 08:58:47 -0400
In-Reply-To: <20150703125132.24121.50592.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inet6addr notifier is atomic and runs in bh context without RTNL when
ipv6 receives router advertisement packet and performs autoconfiguration.

This patch adds ipvl_port->addr_lock and helpers: ipvlan_addr_lock_bh,
ipvlan_addr_unlock_bh for protecting ipvlan addresses and hash table.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ipvlan/ipvlan.h      |   11 +++++++++++
 drivers/net/ipvlan/ipvlan_core.c |    2 --
 drivers/net/ipvlan/ipvlan_main.c |   33 ++++++++++++++++++++++++++++++---
 3 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 40f9d7e4a0ea..a23069aec4d9 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -97,6 +97,7 @@ struct ipvl_port {
 	struct sk_buff_head	backlog;
 	int			count;
 	u16			mode;
+	spinlock_t		addr_lock;
 };
 
 static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_device *d)
@@ -109,6 +110,16 @@ static inline struct ipvl_port *ipvlan_port_get_rtnl(const struct net_device *d)
 	return rtnl_dereference(d->rx_handler_data);
 }
 
+static inline void ipvlan_addr_lock_bh(struct ipvl_dev *ipvlan)
+{
+	spin_lock_bh(&ipvlan->port->addr_lock);
+}
+
+static inline void ipvlan_addr_unlock_bh(struct ipvl_dev *ipvlan)
+{
+	spin_unlock_bh(&ipvlan->port->addr_lock);
+}
+
 void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev);
 void ipvlan_set_port_mode(struct ipvl_port *port, u32 nval);
 void ipvlan_init_secret(void);
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8f8628a0adba..e7b6359814d0 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -109,8 +109,6 @@ bool ipvlan_addr_busy(struct ipvl_port *port, void *iaddr, bool is_v6)
 {
 	struct ipvl_dev *ipvlan;
 
-	ASSERT_RTNL();
-
 	list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
 		if (ipvlan_find_addr(ipvlan, iaddr, is_v6))
 			return true;
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index c7172b6277e2..83a936f76248 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -56,6 +56,7 @@ static int ipvlan_port_create(struct net_device *dev)
 
 	skb_queue_head_init(&port->backlog);
 	INIT_WORK(&port->wq, ipvlan_process_multicast);
+	spin_lock_init(&port->addr_lock);
 
 	err = netdev_rx_handler_register(dev, ipvlan_handle_frame, port);
 	if (err)
@@ -153,8 +154,10 @@ static int ipvlan_open(struct net_device *dev)
 	else
 		dev->flags &= ~IFF_NOARP;
 
+	ipvlan_addr_lock_bh(ipvlan);
 	list_for_each_entry(addr, &ipvlan->addrs, anode)
 		ipvlan_ht_addr_add(ipvlan, addr);
+	ipvlan_addr_unlock_bh(ipvlan);
 
 	return dev_uc_add(phy_dev, phy_dev->dev_addr);
 }
@@ -170,8 +173,10 @@ static int ipvlan_stop(struct net_device *dev)
 
 	dev_uc_del(phy_dev, phy_dev->dev_addr);
 
+	ipvlan_addr_lock_bh(ipvlan);
 	list_for_each_entry(addr, &ipvlan->addrs, anode)
 		ipvlan_ht_addr_del(addr);
+	ipvlan_addr_unlock_bh(ipvlan);
 
 	return 0;
 }
@@ -504,11 +509,13 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ipvl_addr *addr, *next;
 
+	ipvlan_addr_lock_bh(ipvlan);
 	list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
 		ipvlan_ht_addr_del(addr);
 		list_del(&addr->anode);
 		kfree_rcu(addr, rcu);
 	}
+	ipvlan_addr_unlock_bh(ipvlan);
 
 	list_del_rcu(&ipvlan->pnode);
 	unregister_netdevice_queue(dev, head);
@@ -609,15 +616,21 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 {
 	struct ipvl_addr *addr;
 
+	ipvlan_addr_lock_bh(ipvlan);
+
 	if (ipvlan_addr_busy(ipvlan->port, ip6_addr, true)) {
 		netif_err(ipvlan, ifup, ipvlan->dev,
 			  "Failed to add IPv6=%pI6c addr for %s intf\n",
 			  ip6_addr, ipvlan->dev->name);
+		ipvlan_addr_unlock_bh(ipvlan);
 		return -EINVAL;
 	}
+
 	addr = kzalloc(sizeof(struct ipvl_addr), GFP_ATOMIC);
-	if (!addr)
+	if (!addr) {
+		ipvlan_addr_unlock_bh(ipvlan);
 		return -ENOMEM;
+	}
 
 	addr->master = ipvlan;
 	memcpy(&addr->ip6addr, ip6_addr, sizeof(struct in6_addr));
@@ -631,6 +644,8 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 	if (netif_running(ipvlan->dev))
 		ipvlan_ht_addr_add(ipvlan, addr);
 
+	ipvlan_addr_unlock_bh(ipvlan);
+
 	return 0;
 }
 
@@ -638,12 +653,14 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 {
 	struct ipvl_addr *addr;
 
+	ipvlan_addr_lock_bh(ipvlan);
 	addr = ipvlan_find_addr(ipvlan, ip6_addr, true);
 	if (addr) {
 		ipvlan_ht_addr_del(addr);
 		list_del(&addr->anode);
 		kfree_rcu(addr, rcu);
 	}
+	ipvlan_addr_unlock_bh(ipvlan);
 }
 
 static int ipvlan_addr6_event(struct notifier_block *unused,
@@ -677,15 +694,21 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 {
 	struct ipvl_addr *addr;
 
+	ipvlan_addr_lock_bh(ipvlan);
+
 	if (ipvlan_addr_busy(ipvlan->port, ip4_addr, false)) {
 		netif_err(ipvlan, ifup, ipvlan->dev,
 			  "Failed to add IPv4=%pI4 on %s intf.\n",
 			  ip4_addr, ipvlan->dev->name);
+		ipvlan_addr_unlock_bh(ipvlan);
 		return -EINVAL;
 	}
-	addr = kzalloc(sizeof(struct ipvl_addr), GFP_KERNEL);
-	if (!addr)
+
+	addr = kzalloc(sizeof(struct ipvl_addr), GFP_ATOMIC);
+	if (!addr) {
+		ipvlan_addr_unlock_bh(ipvlan);
 		return -ENOMEM;
+	}
 
 	addr->master = ipvlan;
 	memcpy(&addr->ip4addr, ip4_addr, sizeof(struct in_addr));
@@ -699,6 +722,8 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	if (netif_running(ipvlan->dev))
 		ipvlan_ht_addr_add(ipvlan, addr);
 
+	ipvlan_addr_unlock_bh(ipvlan);
+
 	return 0;
 }
 
@@ -706,12 +731,14 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 {
 	struct ipvl_addr *addr;
 
+	ipvlan_addr_lock_bh(ipvlan);
 	addr = ipvlan_find_addr(ipvlan, ip4_addr, false);
 	if (addr) {
 		ipvlan_ht_addr_del(addr);
 		list_del(&addr->anode);
 		kfree_rcu(addr, rcu);
 	}
+	ipvlan_addr_unlock_bh(ipvlan);
 }
 
 static int ipvlan_addr4_event(struct notifier_block *unused,
