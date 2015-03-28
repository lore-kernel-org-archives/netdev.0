From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 4/4 v2] ipvlan: fix check for IP addresses in control path
Date: Sat, 28 Mar 2015 19:13:25 +0100
Message-ID: <eb0a8f2bcf562329ba7eb3bf1539416ee135af4d.1427566140.git.jbenc@redhat.com>
References: <cover.1427566140.git.jbenc@redhat.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbbC1SNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2015 14:13:42 -0400
In-Reply-To: <cover.1427566140.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an ipvlan interface is down, its addresses are not on the hash list.
Fix checks for existence of addresses not to depend on the hash list, walk
through all interface addresses instead.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---

Note that while this patch is needed and fixes problems like ipv4cnt
underflow and trigerring WARN_ON in ipvlan_del_addr4, it does not fix the
more substantial problem: although the current code suggests that it
prevents assignment of the same IP address to multiple ipvlan interfaces, it
does not really do that. The address will be assigned to both interfaces,
ipvlan just silently considers such address to belong to the first interface
only.

Seems the original intention was to prevent address assignment by returning
NOTIFY_BAD but inet_insert_ifa does not really care about notifier results.
Till such feature is implemented, this patch at least makes sure we don't
have corrupted counters and don't leave kernel traces in the log.
---
 drivers/net/ipvlan/ipvlan.h      |  4 +++-
 drivers/net/ipvlan/ipvlan_core.c | 19 ++++++++++++++-----
 drivers/net/ipvlan/ipvlan_main.c |  8 ++++----
 3 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 924ea98bd531..54549a6223dd 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -114,7 +114,9 @@ unsigned int ipvlan_mac_hash(const unsigned char *addr);
 rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb);
 int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev);
 void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *addr);
-bool ipvlan_addr_busy(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6);
+struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
+				   const void *iaddr, bool is_v6);
+bool ipvlan_addr_busy(struct ipvl_port *port, void *iaddr, bool is_v6);
 struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
 					const void *iaddr, bool is_v6);
 void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync);
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 568628f95aa2..b7877a194cfe 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -92,9 +92,9 @@ void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync)
 		synchronize_rcu();
 }
 
-bool ipvlan_addr_busy(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6)
+struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
+				   const void *iaddr, bool is_v6)
 {
-	struct ipvl_port *port = ipvlan->port;
 	struct ipvl_addr *addr;
 
 	list_for_each_entry(addr, &ipvlan->addrs, anode) {
@@ -102,12 +102,21 @@ bool ipvlan_addr_busy(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6)
 		    ipv6_addr_equal(&addr->ip6addr, iaddr)) ||
 		    (!is_v6 && addr->atype == IPVL_IPV4 &&
 		    addr->ip4addr.s_addr == ((struct in_addr *)iaddr)->s_addr))
-			return true;
+			return addr;
 	}
+	return NULL;
+}
 
-	if (ipvlan_ht_addr_lookup(port, iaddr, is_v6))
-		return true;
+bool ipvlan_addr_busy(struct ipvl_port *port, void *iaddr, bool is_v6)
+{
+	struct ipvl_dev *ipvlan;
+
+	ASSERT_RTNL();
 
+	list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
+		if (ipvlan_find_addr(ipvlan, iaddr, is_v6))
+			return true;
+	}
 	return false;
 }
 
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index aaa005bd21ce..4fa14208d799 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -607,7 +607,7 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 {
 	struct ipvl_addr *addr;
 
-	if (ipvlan_addr_busy(ipvlan, ip6_addr, true)) {
+	if (ipvlan_addr_busy(ipvlan->port, ip6_addr, true)) {
 		netif_err(ipvlan, ifup, ipvlan->dev,
 			  "Failed to add IPv6=%pI6c addr for %s intf\n",
 			  ip6_addr, ipvlan->dev->name);
@@ -635,7 +635,7 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
 {
 	struct ipvl_addr *addr;
 
-	addr = ipvlan_ht_addr_lookup(ipvlan->port, ip6_addr, true);
+	addr = ipvlan_find_addr(ipvlan, ip6_addr, true);
 	if (!addr)
 		return;
 
@@ -679,7 +679,7 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 {
 	struct ipvl_addr *addr;
 
-	if (ipvlan_addr_busy(ipvlan, ip4_addr, false)) {
+	if (ipvlan_addr_busy(ipvlan->port, ip4_addr, false)) {
 		netif_err(ipvlan, ifup, ipvlan->dev,
 			  "Failed to add IPv4=%pI4 on %s intf.\n",
 			  ip4_addr, ipvlan->dev->name);
@@ -708,7 +708,7 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 {
 	struct ipvl_addr *addr;
 
-	addr = ipvlan_ht_addr_lookup(ipvlan->port, ip4_addr, false);
+	addr = ipvlan_find_addr(ipvlan, ip4_addr, false);
 	if (!addr)
 		return;
 
-- 
1.8.3.1
