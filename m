From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: by default join ff01::1 and in case of forwarding ff01::2 and ff05:2
Date: Sun, 10 Feb 2013 14:34:31 +0100
Message-ID: <20130210133431.GD18219@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55394 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544Ab3BJNed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 08:34:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Erik Hugne <erik.hugne@ericsson.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/in6.h |  9 +++++++++
 net/ipv6/addrconf.c | 15 +++++++++++++--
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index a16e193..34edf1f 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -36,4 +36,13 @@ extern const struct in6_addr in6addr_linklocal_allnodes;
 extern const struct in6_addr in6addr_linklocal_allrouters;
 #define IN6ADDR_LINKLOCAL_ALLROUTERS_INIT \
 		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,2 } } }
+extern const struct in6_addr in6addr_interfacelocal_allnodes;
+#define IN6ADDR_INTERFACELOCAL_ALLNODES_INIT \
+		{ { { 0xff,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
+extern const struct in6_addr in6addr_interfacelocal_allrouters;
+#define IN6ADDR_INTERFACELOCAL_ALLROUTERS_INIT \
+		{ { { 0xff,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2 } } }
+extern const struct in6_addr in6addr_sitelocal_allrouters;
+#define IN6ADDR_SITELOCAL_ALLROUTERS_INIT \
+		{ { { 0xff,5,0,0,0,0,0,0,0,0,0,0,0,0,0,2 } } }
 #endif
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index bd9f936..b83cd75 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -244,6 +244,9 @@ const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
 const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
 const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
 const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
+const struct in6_addr in6addr_interfacelocal_allnodes = IN6ADDR_INTERFACELOCAL_ALLNODES_INIT;
+const struct in6_addr in6addr_interfacelocal_allrouters = IN6ADDR_INTERFACELOCAL_ALLROUTERS_INIT;
+const struct in6_addr in6addr_sitelocal_allrouters = IN6ADDR_SITELOCAL_ALLROUTERS_INIT;
 
 /* Check if a valid qdisc is available */
 static inline bool addrconf_qdisc_ok(const struct net_device *dev)
@@ -428,6 +431,9 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	/* protected by rtnl_lock */
 	rcu_assign_pointer(dev->ip6_ptr, ndev);
 
+	/* Join interface-local all-node multicast group */
+	ipv6_dev_mc_inc(dev, &in6addr_interfacelocal_allnodes);
+
 	/* Join all-node multicast group */
 	ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
 
@@ -611,10 +617,15 @@ static void dev_forward_change(struct inet6_dev *idev)
 	if (idev->cnf.forwarding)
 		dev_disable_lro(dev);
 	if (dev->flags & IFF_MULTICAST) {
-		if (idev->cnf.forwarding)
+		if (idev->cnf.forwarding) {
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
-		else
+			ipv6_dev_mc_inc(dev, &in6addr_interfacelocal_allrouters);
+			ipv6_dev_mc_inc(dev, &in6addr_sitelocal_allrouters);
+		} else {
 			ipv6_dev_mc_dec(dev, &in6addr_linklocal_allrouters);
+			ipv6_dev_mc_dec(dev, &in6addr_interfacelocal_allrouters);
+			ipv6_dev_mc_inc(dev, &in6addr_sitelocal_allrouters);
+		}
 	}
 
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
-- 
1.8.1.2
