From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 2.6.38-rc8 build failure] net: bridge builtin vs. ipv6
 modular
Date: Thu, 10 Mar 2011 13:28:01 -0800
Message-ID: <20110310132801.4a919df2.randy.dunlap@oracle.com>
References: <1299752394.4109.31.camel@lat1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Patrick Schaaf <netdev@bof.de>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50960 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab1CJV2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 16:28:52 -0500
In-Reply-To: <1299752394.4109.31.camel@lat1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This can be fixed in either of 2 ways.  One way is to require that the
bridge code building depend on how the IPV6 code is built (builtin or modular);
the other way is to handle the kconfig variations in net/bridge/br_multicast.c --
but this loses some functionality if IPV6=m and BRIDGE=y.

I prefer the Kconfig patch over the br_multicast.c patch.
Both patches are below for consideration.

---
From: Randy Dunlap <randy.dunlap@oracle.com>

When configs BRIDGE=y and IPV6=m, this build error occurs:

br_multicast.c:(.text+0xa3341): undefined reference to `ipv6_dev_get_saddr'

BRIDGE_IGMP_SNOOPING is boolean; if it were tristate, then adding
	depends on IPV6 || IPV6=n
to BRIDGE_IGMP_SNOOPING would be a good fix.  As it is currently,
making BRIDGE depend on the IPV6 config works.

Reported-by: Patrick Schaaf <netdev@bof.de>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/bridge/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- lnx-2638-rc8.orig/net/bridge/Kconfig
+++ lnx-2638-rc8/net/bridge/Kconfig
@@ -6,6 +6,7 @@ config BRIDGE
 	tristate "802.1d Ethernet Bridging"
 	select LLC
 	select STP
+	depends on IPV6 || IPV6=n
 	---help---
 	  If you say Y here, then your Linux box will be able to act as an
 	  Ethernet bridge, which means that the different Ethernet segments it

===== alternate patch =====
From: Randy Dunlap <randy.dunlap@oracle.com>

Handle IPV6 vs. BRIDGE config differences in br_multicast.c.
This allows IPV6 to be modular with bridge code either built-in
or modular, but if IPV6=m and BRIDGE=y, some functionality is
lost.

Built with all 6 combinations of IPV6={ymn} and BRIDGE={ym}.

Reported-by: Patrick Schaaf <netdev@bof.de>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/bridge/br_multicast.c |   37 ++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

--- lnx-2638-rc8.orig/net/bridge/br_multicast.c
+++ lnx-2638-rc8/net/bridge/br_multicast.c
@@ -10,6 +10,11 @@
  *
  */
 
+#if defined(CONFIG_IPV6) || \
+    (defined(CONFIG_IPV6_MODULE) && defined(CONFIG_BRIDGE_MODULE))
+#define USE_IPV6	1
+#endif
+
 #include <linux/err.h>
 #include <linux/if_ether.h>
 #include <linux/igmp.h>
@@ -24,7 +29,7 @@
 #include <linux/slab.h>
 #include <linux/timer.h>
 #include <net/ip.h>
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 #include <net/ipv6.h>
 #include <net/mld.h>
 #include <net/addrconf.h>
@@ -36,7 +41,7 @@
 #define mlock_dereference(X, br) \
 	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static inline int ipv6_is_transient_multicast(const struct in6_addr *addr)
 {
 	if (ipv6_addr_is_multicast(addr) && IPV6_ADDR_MC_FLAG_TRANSIENT(addr))
@@ -52,7 +57,7 @@ static inline int br_ip_equal(const stru
 	switch (a->proto) {
 	case htons(ETH_P_IP):
 		return a->u.ip4 == b->u.ip4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 	case htons(ETH_P_IPV6):
 		return ipv6_addr_equal(&a->u.ip6, &b->u.ip6);
 #endif
@@ -65,7 +70,7 @@ static inline int __br_ip4_hash(struct n
 	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
 				const struct in6_addr *ip)
 {
@@ -79,7 +84,7 @@ static inline int br_ip_hash(struct net_
 	switch (ip->proto) {
 	case htons(ETH_P_IP):
 		return __br_ip4_hash(mdb, ip->u.ip4);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 	case htons(ETH_P_IPV6):
 		return __br_ip6_hash(mdb, &ip->u.ip6);
 #endif
@@ -121,7 +126,7 @@ static struct net_bridge_mdb_entry *br_m
 	return br_mdb_ip_get(mdb, &br_dst);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static struct net_bridge_mdb_entry *br_mdb_ip6_get(
 	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst)
 {
@@ -152,7 +157,7 @@ struct net_bridge_mdb_entry *br_mdb_get(
 	case htons(ETH_P_IP):
 		ip.u.ip4 = ip_hdr(skb)->daddr;
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 	case htons(ETH_P_IPV6):
 		ipv6_addr_copy(&ip.u.ip6, &ipv6_hdr(skb)->daddr);
 		break;
@@ -411,7 +416,7 @@ out:
 	return skb;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
 						    struct in6_addr *group)
 {
@@ -496,7 +501,7 @@ static struct sk_buff *br_multicast_allo
 	switch (addr->proto) {
 	case htons(ETH_P_IP):
 		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 	case htons(ETH_P_IPV6):
 		return br_ip6_multicast_alloc_query(br, &addr->u.ip6);
 #endif
@@ -773,7 +778,7 @@ static int br_ip4_multicast_add_group(st
 	return br_multicast_add_group(br, port, &br_group);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static int br_ip6_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
 				      const struct in6_addr *group)
@@ -845,7 +850,7 @@ static void br_multicast_send_query(stru
 	br_group.proto = htons(ETH_P_IP);
 	__br_multicast_send_query(br, port, &br_group);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 	br_group.proto = htons(ETH_P_IPV6);
 	__br_multicast_send_query(br, port, &br_group);
 #endif
@@ -989,7 +994,7 @@ static int br_ip4_multicast_igmp3_report
 	return err;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 					struct net_bridge_port *port,
 					struct sk_buff *skb)
@@ -1185,7 +1190,7 @@ out:
 	return err;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static int br_ip6_multicast_query(struct net_bridge *br,
 				  struct net_bridge_port *port,
 				  struct sk_buff *skb)
@@ -1334,7 +1339,7 @@ static void br_ip4_multicast_leave_group
 	br_multicast_leave_group(br, port, &br_group);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static void br_ip6_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
 					 const struct in6_addr *group)
@@ -1446,7 +1451,7 @@ err_out:
 	return err;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb)
@@ -1583,7 +1588,7 @@ int br_multicast_rcv(struct net_bridge *
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return br_multicast_ipv4_rcv(br, port, skb);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if defined(USE_IPV6)
 	case htons(ETH_P_IPV6):
 		return br_multicast_ipv6_rcv(br, port, skb);
 #endif

