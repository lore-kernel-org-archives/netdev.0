From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v2 3/5] ipvlan: unhash addresses without synchronize_rcu
Date: Fri, 03 Jul 2015 15:58:39 +0300
Message-ID: <20150703125839.24121.84981.stgit@buzz>
References: <20150703125132.24121.50592.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:55324 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754801AbbGCNGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 09:06:54 -0400
In-Reply-To: <20150703125132.24121.50592.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All structures used in traffic forwarding are rcu-protected:
ipvl_addr, ipvl_dev and ipvl_port. Thus we can unhash addresses
without synchronization. We'll anyway hash it back into the same
bucket, in worst case lockless lookup will scan hash once again.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ipvlan/ipvlan.h      |    2 +-
 drivers/net/ipvlan/ipvlan_core.c |    4 +---
 drivers/net/ipvlan/ipvlan_main.c |    8 ++++----
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 68e2549c28c6..40f9d7e4a0ea 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -122,5 +122,5 @@ struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
 bool ipvlan_addr_busy(struct ipvl_port *port, void *iaddr, bool is_v6);
 struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
 					const void *iaddr, bool is_v6);
-void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync);
+void ipvlan_ht_addr_del(struct ipvl_addr *addr);
 #endif /* __IPVLAN_H */
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8afbedad620d..8f8628a0adba 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -85,11 +85,9 @@ void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *addr)
 		hlist_add_head_rcu(&addr->hlnode, &port->hlhead[hash]);
 }
 
-void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync)
+void ipvlan_ht_addr_del(struct ipvl_addr *addr)
 {
 	hlist_del_init_rcu(&addr->hlnode);
-	if (sync)
-		synchronize_rcu();
 }
 
 struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 4c3a0ac85381..c7172b6277e2 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -171,7 +171,7 @@ static int ipvlan_stop(struct net_device *dev)
 	dev_uc_del(phy_dev, phy_dev->dev_addr);
 
 	list_for_each_entry(addr, &ipvlan->addrs, anode)
-		ipvlan_ht_addr_del(addr, !dev->dismantle);
+		ipvlan_ht_addr_del(addr);
 
 	return 0;
 }
@@ -505,7 +505,7 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 	struct ipvl_addr *addr, *next;
 
 	list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
-		ipvlan_ht_addr_del(addr, !dev->dismantle);
+		ipvlan_ht_addr_del(addr);
 		list_del(&addr->anode);
 		kfree_rcu(addr, rcu);
 	}
@@ -640,7 +640,7 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 
 	addr = ipvlan_find_addr(ipvlan, ip6_addr, true);
 	if (addr) {
-		ipvlan_ht_addr_del(addr, true);
+		ipvlan_ht_addr_del(addr);
 		list_del(&addr->anode);
 		kfree_rcu(addr, rcu);
 	}
@@ -708,7 +708,7 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 
 	addr = ipvlan_find_addr(ipvlan, ip4_addr, false);
 	if (addr) {
-		ipvlan_ht_addr_del(addr, true);
+		ipvlan_ht_addr_del(addr);
 		list_del(&addr->anode);
 		kfree_rcu(addr, rcu);
 	}
