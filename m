From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 3/4] ipvlan: do not use rcu operations for address list
Date: Fri, 27 Mar 2015 18:30:25 +0100
Message-ID: <a188e1cf1f5a239c10529b2e70e6eaf4f8549ff7.1427476903.git.jbenc@redhat.com>
References: <cover.1427476903.git.jbenc@redhat.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353AbbC0Rap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 13:30:45 -0400
In-Reply-To: <cover.1427476903.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All accesses to ipvlan->addrs are under rtnl.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index dbaf67c722a0..f5b1c7b38770 100644
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
 	 * list by ipvlan_open. */
@@ -639,7 +639,7 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 		return;
 
 	ipvlan_ht_addr_del(addr, true);
-	list_del_rcu(&addr->anode);
+	list_del(&addr->anode);
 	ipvlan->ipv6cnt--;
 	WARN_ON(ipvlan->ipv6cnt < 0);
 	kfree_rcu(addr, rcu);
@@ -691,7 +691,7 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	addr->master = ipvlan;
 	memcpy(&addr->ip4addr, ip4_addr, sizeof(struct in_addr));
 	addr->atype = IPVL_IPV4;
-	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
+	list_add_tail(&addr->anode, &ipvlan->addrs);
 	ipvlan->ipv4cnt++;
 	/* If the interface is not up, the address will be added to the hash
 	 * list by ipvlan_open. */
@@ -711,7 +711,7 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 		return;
 
 	ipvlan_ht_addr_del(addr, true);
-	list_del_rcu(&addr->anode);
+	list_del(&addr->anode);
 	ipvlan->ipv4cnt--;
 	WARN_ON(ipvlan->ipv4cnt < 0);
 	if (!ipvlan->ipv4cnt)
-- 
1.8.3.1
