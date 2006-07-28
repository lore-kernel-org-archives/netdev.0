From: Christophe Devriese <christophe.devriese@eth1.org>
Subject: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Fri, 28 Jul 2006 11:44:21 +0200
Message-ID: <20060728094421.GA14903@walrus.eth1.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth1.org ([85.158.215.1]:21175 "EHLO walrus.kotnet.org")
	by vger.kernel.org with ESMTP id S1751148AbWG1JgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 05:36:14 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -rU3 linux-2.6.17.7/net/core/dev.c linux-2.6.17.7-wapper/net/core/dev.c
--- linux-2.6.17.7/net/core/dev.c       2006-07-25 05:36:01.000000000 +0200
+++ linux-2.6.17.7-wapper/net/core/dev.c        2006-07-27 20:16:36.000000000 +0200
@@ -88,6 +88,7 @@
 #include <linux/sockios.h>
 #include <linux/errno.h>
 #include <linux/interrupt.h>
+#include <linux/if_bonding.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -1518,37 +1519,6 @@

 EXPORT_SYMBOL(netif_rx_ni);

-static inline struct net_device *skb_bond(struct sk_buff *skb)
-{
-       struct net_device *dev = skb->dev;
-
-       if (dev->master) {
-               /*
-                * On bonding slaves other than the currently active
-                * slave, suppress duplicates except for 802.3ad
-                * ETH_P_SLOW and alb non-mcast/bcast.
-                */
-               if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
-                       if (dev->master->priv_flags & IFF_MASTER_ALB) {
-                               if (skb->pkt_type != PACKET_BROADCAST &&
-                                   skb->pkt_type != PACKET_MULTICAST)
-                                       goto keep;
-                       }
-
-                       if (dev->master->priv_flags & IFF_MASTER_8023AD &&
-                           skb->protocol == __constant_htons(ETH_P_SLOW))
-                               goto keep;
-
-                       kfree_skb(skb);
-                       return NULL;
-               }
-keep:
-               skb->dev = dev->master;
-       }
-
-       return dev;
-}
-
 static void net_tx_action(struct softirq_action *h)
 {
        struct softnet_data *sd = &__get_cpu_var(softnet_data);

-- 
-----------------------------------------------------------------------
Christophe Devriese                                               EURiD
Network Adminstrator / Developer
christophe.devriese@eth1.org
---------------------------- http://www.eth1.org ----------------------

