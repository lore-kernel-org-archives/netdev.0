From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] ipvlan: fix addr hash list corruption
Date: Mon, 23 Mar 2015 22:10:19 +0100
Message-ID: <2ca7312e5e3df10ce129315f89c3ab5d82d4d428.1427145009.git.jbenc@redhat.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557AbbCWVLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 17:11:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ipvlan interface with IP addresses attached is brought down and then
deleted, the assigned addresses are deleted twice from the address hash
list, first on the interface down and second on the link deletion.
Similarly, when an address is added while the interface is down, it is added
second time once the interface is brought up.

Check the interface status before adding/removing to the hash list in the
notifiers.

Reported-by: Dan Williams <dcbw@redhat.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 4f4099d5603d..04cfa7a13645 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -504,7 +504,8 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 
 	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
 		list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
-			ipvlan_ht_addr_del(addr, !dev->dismantle);
+			if (netif_running(dev))
+				ipvlan_ht_addr_del(addr, !dev->dismantle);
 			list_del_rcu(&addr->anode);
 		}
 	}
@@ -622,7 +623,8 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 	addr->atype = IPVL_IPV6;
 	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
 	ipvlan->ipv6cnt++;
-	ipvlan_ht_addr_add(ipvlan, addr);
+	if (netif_running(ipvlan->dev))
+		ipvlan_ht_addr_add(ipvlan, addr);
 
 	return 0;
 }
@@ -635,7 +637,8 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 	if (!addr)
 		return;
 
-	ipvlan_ht_addr_del(addr, true);
+	if (netif_running(ipvlan->dev))
+		ipvlan_ht_addr_del(addr, true);
 	list_del_rcu(&addr->anode);
 	ipvlan->ipv6cnt--;
 	WARN_ON(ipvlan->ipv6cnt < 0);
@@ -690,7 +693,8 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	addr->atype = IPVL_IPV4;
 	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
 	ipvlan->ipv4cnt++;
-	ipvlan_ht_addr_add(ipvlan, addr);
+	if (netif_running(ipvlan->dev))
+		ipvlan_ht_addr_add(ipvlan, addr);
 	ipvlan_set_broadcast_mac_filter(ipvlan, true);
 
 	return 0;
@@ -704,7 +708,8 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	if (!addr)
 		return;
 
-	ipvlan_ht_addr_del(addr, true);
+	if (netif_running(ipvlan->dev))
+		ipvlan_ht_addr_del(addr, true);
 	list_del_rcu(&addr->anode);
 	ipvlan->ipv4cnt--;
 	WARN_ON(ipvlan->ipv4cnt < 0);
-- 
1.8.3.1
