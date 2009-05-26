From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next] bonding: allow bond in mode balance-alb to work
	properly in bridge -try4.1
Date: Tue, 26 May 2009 17:17:17 +0200
Message-ID: <20090526151717.GB11147@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090326155205.GA28868@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48279 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752563AbZEZPSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2009 11:18:33 -0400
Content-Disposition: inline
In-Reply-To: <20090326155205.GA28868@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next] bonding: allow bond in mode balance-alb to work properly in bridge -try4.1

Hi all.

The problem is described in following bugzilla:
https://bugzilla.redhat.com/show_bug.cgi?id=487763

Basically here's what's going on. In every mode, bonding interface uses the same
mac address for all enslaved devices (except fail_over_mac). Only balance-alb
will simultaneously use multiple MAC addresses across different slaves. When you
put this kind of bond device into a bridge it will only add one of mac adresses
into a hash list of mac addresses, say X. This mac address is marked as local.
But this bonding interface also has mac address Y. Now then packet arrives with
destination address Y, this address is not marked as local and the packed looks
like it needs to be forwarded. This packet is then lost which is wrong.

Notice that interfaces can be added and removed from bond while it is in bridge.

***
When the multiple addresses for bridge port approach failed to solve this issue
due to STP I started to think other way to solve this. I returned to previous
solution but tweaked one.

This patch solves the situation in the bonding without touching bridge code.
For every incoming frame to bonding the destination address is compared to
current address of the slave device from which tha packet came. If these two
match destination address is replaced by mac address of the master. This address
is known by bridge so it is delivered properly.

I experimentally tried that this works as good as searching through the slave
list (v4 of this patch).

I was forced to create a new header because I need to use
compare_ether_addr_64bits() (defined in linux/etherdevice.h) in
linux/netdevice.h. I've hit some cross include issues. I think that it's good
to have skb_bond_should_drop() in a separate file anyway.

Jirka


Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/include/linux/bonding.h b/include/linux/bonding.h
new file mode 100644
index 0000000..3081ddb
--- /dev/null
+++ b/include/linux/bonding.h
@@ -0,0 +1,78 @@
+/*
+ * include/linux/bonding.h
+ *
+ * Copyright (C) 2009 Jiri Pirko <jpirko@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * Bonding device helpers.
+ */
+
+#ifndef _LINUX_BONDING_H
+#define _LINUX_BONDING_H
+
+#ifdef __KERNEL__
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/if.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+
+static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
+					      struct net_device *dev,
+					      struct net_device *master)
+{
+	unsigned char *dest = eth_hdr(skb)->h_dest;
+
+	if (compare_ether_addr_64bits(dest, master->dev_addr) &&
+	    !compare_ether_addr_64bits(dest, dev->dev_addr))
+		memcpy(dest, master->dev_addr, ETH_ALEN);
+}
+
+/* On bonding slaves other than the currently active slave, suppress
+ * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
+ * ARP on active-backup slaves with arp_validate enabled.
+ */
+static inline int skb_bond_should_drop(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct net_device *master = dev->master;
+
+	if (master) {
+		if (master->priv_flags & IFF_MASTER_ARPMON)
+			dev->last_rx = jiffies;
+
+		if ((master->priv_flags & IFF_MASTER_ALB) && master->br_port) {
+			/* Do address unmangle. The local destination address
+			 * will be always the one master has. Provides the right
+			 * functionality in a bridge.
+			 */
+			skb_bond_set_mac_by_master(skb, dev, master);
+		}
+
+		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
+			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
+			    skb->protocol == __cpu_to_be16(ETH_P_ARP))
+				return 0;
+
+			if (master->priv_flags & IFF_MASTER_ALB) {
+				if (skb->pkt_type != PACKET_BROADCAST &&
+				    skb->pkt_type != PACKET_MULTICAST)
+					return 0;
+			}
+			if (master->priv_flags & IFF_MASTER_8023AD &&
+			    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
+				return 0;
+
+			return 1;
+		}
+	}
+	return 0;
+}
+
+#endif /* __KERNEL__ */
+
+#endif	/* _LINUX_BONDING_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ae3c209..06e24ae 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1897,39 +1897,6 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
-/* On bonding slaves other than the currently active slave, suppress
- * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
- * ARP on active-backup slaves with arp_validate enabled.
- */
-static inline int skb_bond_should_drop(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-	struct net_device *master = dev->master;
-
-	if (master) {
-		if (master->priv_flags & IFF_MASTER_ARPMON)
-			dev->last_rx = jiffies;
-
-		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
-			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
-			    skb->protocol == __cpu_to_be16(ETH_P_ARP))
-				return 0;
-
-			if (master->priv_flags & IFF_MASTER_ALB) {
-				if (skb->pkt_type != PACKET_BROADCAST &&
-				    skb->pkt_type != PACKET_MULTICAST)
-					return 0;
-			}
-			if (master->priv_flags & IFF_MASTER_8023AD &&
-			    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
-				return 0;
-
-			return 1;
-		}
-	}
-	return 0;
-}
-
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 static inline int dev_ethtool_get_settings(struct net_device *dev,
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 7f7de1a..c6eae40 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -2,6 +2,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
 #include <linux/netpoll.h>
+#include <linux/bonding.h>
 #include "vlan.h"
 
 /* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
diff --git a/net/core/dev.c b/net/core/dev.c
index 241613f..221b43f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -127,6 +127,7 @@
 #include <linux/jhash.h>
 #include <linux/random.h>
 #include <trace/napi.h>
+#include <linux/bonding.h>
 
 #include "net-sysfs.h"
 
