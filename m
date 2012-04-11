From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [RFC] net/bridge: port based vlan filtering for bridges
Date: Wed, 11 Apr 2012 11:10:02 -0400
Message-ID: <20120411151002.GA17739@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:49169 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755152Ab2DKPKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 11:10:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks,

Attached is the first stab at a patch to make it possible to filter packets 
received from other bridge ports based on the port number.  This can be used 
to emulate port based VLANs that some switches support.

The justification for this is a bit interesting.  Initially, I had been 
filtering packets using firewall rules.  Unfortunately, the number of 
filter rules becomes impossible to manage when trying to filter traffic 
between 100 different ports.  CPU overhead of the filters is also a major 
problem.

The particular use-case I'm dealing with is simulating wireless networks 
on a system using LXC containers.  Each guest has a veth device that is a 
member of the bridge, but the topology of which nodes can "hear" each other 
changes at runtime.

Comments/thoughts?

		-ben
---
 br_forward.c  |    3 +++
 br_if.c       |    3 +--
 br_private.h  |    4 ++++
 br_sysfs_if.c |   20 ++++++++++++++++++++
 4 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index ee64287..9b106f8 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -30,6 +30,9 @@ static int deliver_clone(const struct net_bridge_port *prev,
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
+	struct net_bridge_port *from = br_port_get_rcu(skb->dev);
+	if (from && test_bit(from->port_no, p->filter_ports))
+		return 0;
 	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
 		p->state == BR_STATE_FORWARDING);
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f603e5b..2f2e595 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -183,8 +183,7 @@ static int find_portno(struct net_bridge *br)
 	struct net_bridge_port *p;
 	unsigned long *inuse;
 
-	inuse = kcalloc(BITS_TO_LONGS(BR_MAX_PORTS), sizeof(unsigned long),
-			GFP_KERNEL);
+	inuse = kcalloc(BR_PORT_LONGS, sizeof(unsigned long), GFP_KERNEL);
 	if (!inuse)
 		return -ENOMEM;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d7d6fb0..c6fbab0 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -17,6 +17,7 @@
 #include <linux/if_bridge.h>
 #include <linux/netpoll.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/bitops.h>
 #include <net/route.h>
 
 #define BR_HASH_BITS 8
@@ -26,6 +27,7 @@
 
 #define BR_PORT_BITS	10
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
+#define BR_PORT_LONGS	BITS_TO_LONGS(BR_MAX_PORTS)
 
 #define BR_VERSION	"2.3"
 
@@ -156,6 +158,8 @@ struct net_bridge_port
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll			*np;
 #endif
+
+	unsigned long			filter_ports[BR_PORT_LONGS];
 };
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 6229b62..9d95f6a 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -164,6 +164,24 @@ static BRPORT_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
 		   store_multicast_router);
 #endif
 
+static int store_add_filter_port(struct net_bridge_port *p, unsigned long v)
+{
+	if (v >= BR_MAX_PORTS)
+		return -EINVAL;
+	set_bit(v, p->filter_ports);
+	return 0;
+}
+static BRPORT_ATTR(add_filter_port, S_IWUSR, NULL, store_add_filter_port);
+
+static int store_remove_filter_port(struct net_bridge_port *p, unsigned long v)
+{
+	if (v >= BR_MAX_PORTS)
+		return -EINVAL;
+	clear_bit(v, p->filter_ports);
+	return 0;
+}
+static BRPORT_ATTR(remove_filter_port, S_IWUSR, NULL, store_remove_filter_port);
+
 static struct brport_attribute *brport_attrs[] = {
 	&brport_attr_path_cost,
 	&brport_attr_priority,
@@ -184,6 +202,8 @@ static struct brport_attribute *brport_attrs[] = {
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 #endif
+	&brport_attr_add_filter_port,
+	&brport_attr_remove_filter_port,
 	NULL
 };
 
-- 
"Thought is the essence of where you are now."
