From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next 3/3] ipvlan: Always set broadcast bit in multicast filter
Date: Thu, 23 Apr 2015 14:29:55 -0700
Message-ID: <1429824595-23747-1-git-send-email-maheshb@google.com>
Cc: Dan Willems <dcbw@redhat.com>, David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f74.google.com ([209.85.192.74]:33351 "EHLO
	mail-qg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933851AbbDWXLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 19:11:24 -0400
Received: by qgdz60 with SMTP id z60so1022412qgd.0
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 16:11:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Earlier tricks of setting broadcast bit only when IPv4 address is added
onto interface are not good enough especially when autoconf comes in play.
Setting them on always is performance drag but now that multicast /
broadcast is not processed in fast-path; enabling broadcast will let
autoconf work correctly without affecting performance characteristics of
the device.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index a16d3017fdc3..8fe9d5ff331e 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -218,17 +218,6 @@ static void ipvlan_change_rx_flags(struct net_device *dev, int change)
 		dev_set_allmulti(phy_dev, dev->flags & IFF_ALLMULTI? 1 : -1);
 }
 
-static void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, bool set)
-{
-	struct net_device *dev = ipvlan->dev;
-	unsigned int hashbit = ipvlan_mac_hash(dev->broadcast);
-
-	if (set && !test_bit(hashbit, ipvlan->mac_filters))
-		__set_bit(hashbit, ipvlan->mac_filters);
-	else if (!set && test_bit(hashbit, ipvlan->mac_filters))
-		__clear_bit(hashbit, ipvlan->mac_filters);
-}
-
 static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
@@ -243,6 +232,12 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
 		netdev_for_each_mc_addr(ha, dev)
 			__set_bit(ipvlan_mac_hash(ha->addr), mc_filters);
 
+		/* Turn-on broadcast bit irrespective of address family,
+		 * since broadcast is deferred to a work-queue, hence no
+		 * impact on unicast fast-path processing.
+		 */
+		__set_bit(ipvlan_mac_hash(dev->broadcast), mc_filters);
+
 		bitmap_copy(ipvlan->mac_filters, mc_filters,
 			    IPVLAN_MAC_FILTER_SIZE);
 	}
@@ -710,7 +705,6 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	 */
 	if (netif_running(ipvlan->dev))
 		ipvlan_ht_addr_add(ipvlan, addr);
-	ipvlan_set_broadcast_mac_filter(ipvlan, true);
 
 	return 0;
 }
@@ -727,8 +721,6 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	list_del(&addr->anode);
 	ipvlan->ipv4cnt--;
 	WARN_ON(ipvlan->ipv4cnt < 0);
-	if (!ipvlan->ipv4cnt)
-	    ipvlan_set_broadcast_mac_filter(ipvlan, false);
 	kfree_rcu(addr, rcu);
 
 	return;
-- 
2.2.0.rc0.207.ga3a616c
