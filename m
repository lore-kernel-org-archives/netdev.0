From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v3 1/5] ipvlan: remove counters of ipv4 and ipv6 addresses
Date: Tue, 14 Jul 2015 16:35:50 +0300
Message-ID: <20150714133550.22448.31651.stgit@buzz>
References: <20150714132941.22448.42175.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: linux-netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:59146 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751971AbbGNNfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 09:35:54 -0400
In-Reply-To: <20150714132941.22448.42175.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are unused after commit f631c44bbe15 ("ipvlan: Always set broadcast bit in
multicast filter").

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ipvlan/ipvlan.h      |    2 --
 drivers/net/ipvlan/ipvlan_main.c |   33 ++++++++++++---------------------
 2 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 953a97492fab..68e2549c28c6 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -67,8 +67,6 @@ struct ipvl_dev {
 	struct ipvl_port	*port;
 	struct net_device	*phy_dev;
 	struct list_head	addrs;
-	int			ipv4cnt;
-	int			ipv6cnt;
 	struct ipvl_pcpu_stats	__percpu *pcpu_stats;
 	DECLARE_BITMAP(mac_filters, IPVLAN_MAC_FILTER_SIZE);
 	netdev_features_t	sfeatures;
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 1acc283160d9..048ecf0c76fb 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -153,10 +153,9 @@ static int ipvlan_open(struct net_device *dev)
 	else
 		dev->flags &= ~IFF_NOARP;
 
-	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
-		list_for_each_entry(addr, &ipvlan->addrs, anode)
-			ipvlan_ht_addr_add(ipvlan, addr);
-	}
+	list_for_each_entry(addr, &ipvlan->addrs, anode)
+		ipvlan_ht_addr_add(ipvlan, addr);
+
 	return dev_uc_add(phy_dev, phy_dev->dev_addr);
 }
 
@@ -171,10 +170,9 @@ static int ipvlan_stop(struct net_device *dev)
 
 	dev_uc_del(phy_dev, phy_dev->dev_addr);
 
-	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
-		list_for_each_entry(addr, &ipvlan->addrs, anode)
-			ipvlan_ht_addr_del(addr, !dev->dismantle);
-	}
+	list_for_each_entry(addr, &ipvlan->addrs, anode)
+		ipvlan_ht_addr_del(addr, !dev->dismantle);
+
 	return 0;
 }
 
@@ -471,8 +469,6 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	ipvlan->port = port;
 	ipvlan->sfeatures = IPVLAN_FEATURES;
 	INIT_LIST_HEAD(&ipvlan->addrs);
-	ipvlan->ipv4cnt = 0;
-	ipvlan->ipv6cnt = 0;
 
 	/* TODO Probably put random address here to be presented to the
 	 * world but keep using the physical-dev address for the outgoing
@@ -508,12 +504,11 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ipvl_addr *addr, *next;
 
-	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
-		list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
-			ipvlan_ht_addr_del(addr, !dev->dismantle);
-			list_del(&addr->anode);
-		}
+	list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
+		ipvlan_ht_addr_del(addr, !dev->dismantle);
+		list_del(&addr->anode);
 	}
+
 	list_del_rcu(&ipvlan->pnode);
 	unregister_netdevice_queue(dev, head);
 	netdev_upper_dev_unlink(ipvlan->phy_dev, dev);
@@ -627,7 +622,7 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 	memcpy(&addr->ip6addr, ip6_addr, sizeof(struct in6_addr));
 	addr->atype = IPVL_IPV6;
 	list_add_tail(&addr->anode, &ipvlan->addrs);
-	ipvlan->ipv6cnt++;
+
 	/* If the interface is not up, the address will be added to the hash
 	 * list by ipvlan_open.
 	 */
@@ -647,8 +642,6 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 
 	ipvlan_ht_addr_del(addr, true);
 	list_del(&addr->anode);
-	ipvlan->ipv6cnt--;
-	WARN_ON(ipvlan->ipv6cnt < 0);
 	kfree_rcu(addr, rcu);
 
 	return;
@@ -699,7 +692,7 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	memcpy(&addr->ip4addr, ip4_addr, sizeof(struct in_addr));
 	addr->atype = IPVL_IPV4;
 	list_add_tail(&addr->anode, &ipvlan->addrs);
-	ipvlan->ipv4cnt++;
+
 	/* If the interface is not up, the address will be added to the hash
 	 * list by ipvlan_open.
 	 */
@@ -719,8 +712,6 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 
 	ipvlan_ht_addr_del(addr, true);
 	list_del(&addr->anode);
-	ipvlan->ipv4cnt--;
-	WARN_ON(ipvlan->ipv4cnt < 0);
 	kfree_rcu(addr, rcu);
 
 	return;
