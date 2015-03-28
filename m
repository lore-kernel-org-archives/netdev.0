From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 3/4 v2] ipvlan: do not use rcu operations for address list
Date: Sat, 28 Mar 2015 19:13:24 +0100
Message-ID: <ac744df9efb58775461c40e222bd1713b87357a7.1427566140.git.jbenc@redhat.com>
References: <cover.1427566140.git.jbenc@redhat.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbbC1SNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2015 14:13:41 -0400
In-Reply-To: <cover.1427566140.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All accesses to ipvlan->addrs are under rtnl.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 1eb3f33e11cc..aaa005bd21ce 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -505,7 +505,7 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
 		list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
 			ipvlan_ht_addr_del(addr, !dev->dismantle);
-			list_del_rcu(&addr->anode);
+			list_del(&addr->anode);
 		}
 	}
 	list_del_rcu(&ipvlan->pnode);
@@ -620,7 +620,7 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 	addr->master = ipvlan;
 	memcpy(&addr->ip6addr, ip6_addr, sizeof(struct in6_addr));
 	addr->atype = IPVL_IPV6;
-	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
+	list_add_tail(&addr->anode, &ipvlan->addrs);
 	ipvlan->ipv6cnt++;
 	/* If the interface is not up, the address will be added to the hash
 	 * list by ipvlan_open.
@@ -640,7 +640,7 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 		return;
 
 	ipvlan_ht_addr_del(addr, true);
-	list_del_rcu(&addr->anode);
+	list_del(&addr->anode);
 	ipvlan->ipv6cnt--;
 	WARN_ON(ipvlan->ipv6cnt < 0);
 	kfree_rcu(addr, rcu);
@@ -692,7 +692,7 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	addr->master = ipvlan;
 	memcpy(&addr->ip4addr, ip4_addr, sizeof(struct in_addr));
 	addr->atype = IPVL_IPV4;
-	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
+	list_add_tail(&addr->anode, &ipvlan->addrs);
 	ipvlan->ipv4cnt++;
 	/* If the interface is not up, the address will be added to the hash
 	 * list by ipvlan_open.
@@ -713,7 +713,7 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 		return;
 
 	ipvlan_ht_addr_del(addr, true);
-	list_del_rcu(&addr->anode);
+	list_del(&addr->anode);
 	ipvlan->ipv4cnt--;
 	WARN_ON(ipvlan->ipv4cnt < 0);
 	if (!ipvlan->ipv4cnt)
-- 
1.8.3.1
