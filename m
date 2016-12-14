From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: ipvlan: Define common functions to decrease duplicated codes used to add or del IP address
Date: Wed, 14 Dec 2016 22:52:45 +0800
Message-ID: <1481727165-18824-1-git-send-email-fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg321.qq.com ([14.17.32.30]:60644 "EHLO smtpbg321.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755280AbcLNPDY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 10:03:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

There are some duplicated codes in ipvlan_add_addr6/4 and
ipvlan_del_addr6/4. Now define two common functions ipvlan_add_addr
and ipvlan_del_addr to decrease the duplicated codes.
It could be helful to maintain the codes.

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 68 +++++++++++++++++-----------------------
 1 file changed, 29 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 693ec5b..5874d30 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -669,23 +669,22 @@ static int ipvlan_device_event(struct notifier_block *unused,
 	return NOTIFY_DONE;
 }
 
-static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
+static int ipvlan_add_addr(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6)
 {
 	struct ipvl_addr *addr;
 
-	if (ipvlan_addr_busy(ipvlan->port, ip6_addr, true)) {
-		netif_err(ipvlan, ifup, ipvlan->dev,
-			  "Failed to add IPv6=%pI6c addr for %s intf\n",
-			  ip6_addr, ipvlan->dev->name);
-		return -EINVAL;
-	}
 	addr = kzalloc(sizeof(struct ipvl_addr), GFP_ATOMIC);
 	if (!addr)
 		return -ENOMEM;
 
 	addr->master = ipvlan;
-	memcpy(&addr->ip6addr, ip6_addr, sizeof(struct in6_addr));
-	addr->atype = IPVL_IPV6;
+	if (is_v6) {
+		memcpy(&addr->ip6addr, iaddr, sizeof(struct in6_addr));
+		addr->atype = IPVL_IPV6;
+	} else {
+		memcpy(&addr->ip4addr, iaddr, sizeof(struct in_addr));
+		addr->atype = IPVL_IPV4;
+	}
 	list_add_tail(&addr->anode, &ipvlan->addrs);
 
 	/* If the interface is not up, the address will be added to the hash
@@ -697,11 +696,11 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 	return 0;
 }
 
-static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
+static void ipvlan_del_addr(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6)
 {
 	struct ipvl_addr *addr;
 
-	addr = ipvlan_find_addr(ipvlan, ip6_addr, true);
+	addr = ipvlan_find_addr(ipvlan, iaddr, is_v6);
 	if (!addr)
 		return;
 
@@ -712,6 +711,23 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 	return;
 }
 
+static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
+{
+	if (ipvlan_addr_busy(ipvlan->port, ip6_addr, true)) {
+		netif_err(ipvlan, ifup, ipvlan->dev,
+			  "Failed to add IPv6=%pI6c addr for %s intf\n",
+			  ip6_addr, ipvlan->dev->name);
+		return -EINVAL;
+	}
+
+	return ipvlan_add_addr(ipvlan, ip6_addr, true);
+}
+
+static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
+{
+	return ipvlan_del_addr(ipvlan, ip6_addr, true);
+}
+
 static int ipvlan_addr6_event(struct notifier_block *unused,
 			      unsigned long event, void *ptr)
 {
@@ -745,45 +761,19 @@ static int ipvlan_addr6_event(struct notifier_block *unused,
 
 static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 {
-	struct ipvl_addr *addr;
-
 	if (ipvlan_addr_busy(ipvlan->port, ip4_addr, false)) {
 		netif_err(ipvlan, ifup, ipvlan->dev,
 			  "Failed to add IPv4=%pI4 on %s intf.\n",
 			  ip4_addr, ipvlan->dev->name);
 		return -EINVAL;
 	}
-	addr = kzalloc(sizeof(struct ipvl_addr), GFP_KERNEL);
-	if (!addr)
-		return -ENOMEM;
-
-	addr->master = ipvlan;
-	memcpy(&addr->ip4addr, ip4_addr, sizeof(struct in_addr));
-	addr->atype = IPVL_IPV4;
-	list_add_tail(&addr->anode, &ipvlan->addrs);
-
-	/* If the interface is not up, the address will be added to the hash
-	 * list by ipvlan_open.
-	 */
-	if (netif_running(ipvlan->dev))
-		ipvlan_ht_addr_add(ipvlan, addr);
 
-	return 0;
+	return ipvlan_add_addr(ipvlan, ip4_addr, false);
 }
 
 static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 {
-	struct ipvl_addr *addr;
-
-	addr = ipvlan_find_addr(ipvlan, ip4_addr, false);
-	if (!addr)
-		return;
-
-	ipvlan_ht_addr_del(addr);
-	list_del(&addr->anode);
-	kfree_rcu(addr, rcu);
-
-	return;
+	return ipvlan_del_addr(ipvlan, ip4_addr, false);
 }
 
 static int ipvlan_addr4_event(struct notifier_block *unused,
-- 
1.9.1
