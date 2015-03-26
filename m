From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2/2] ipvlan: always allow the broadcast MAC address
Date: Thu, 26 Mar 2015 17:43:42 -0500
Message-ID: <1427409822.18540.13.camel@redhat.com>
References: <1427409698.18540.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101AbbCZWni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 18:43:38 -0400
In-Reply-To: <1427409698.18540.11.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipvlan currently fails DHCP addressing for two reasons:

1) DHCP offers are typically unicast back to the device's MAC
address, and at the IP layer have a destination IP address
matching the new lease address.  In ipvlan unicast packets
are checked against existing addresses assigned to the ipvlan
interface, so clearly this fails hard because the ipvlan
interface has no IP addresses yet.  Workaround: request
that the server broadcast replies (-B for dhclient), which
don't get checked against the IP address list.

2) Even when that's done, mac_filters only allows the
broadcast MAC address when the interface has >= 1 IPv4
addresses, so double-fail, and the incoming DHCP offer
gets dropped on the floor again.

Instead of doing ugly stuff like watching for outgoing DHCP
requests and adding the broadcast MAC to mac_filters for
a period of time, just always allow the broadcast MAC.  This
lets the ipvlan interface be configured with DHCP in
Layer2 mode as long as as broadcast replies are used.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index d34f580..787d7fb 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -214,17 +214,6 @@ static void ipvlan_change_rx_flags(struct net_device *dev, int change)
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
@@ -239,11 +228,11 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
 		netdev_for_each_mc_addr(ha, dev)
 			__set_bit(ipvlan_mac_hash(ha->addr), mc_filters);
 
+		/* always allow broadcast frames */
+		__set_bit(ipvlan_mac_hash(dev->broadcast), mc_filters);
+
 		bitmap_copy(ipvlan->mac_filters, mc_filters,
 			    IPVLAN_MAC_FILTER_SIZE);
-
-		if (ipvlan->ipv4cnt)
-			ipvlan_set_broadcast_mac_filter(ipvlan, true);
 	}
 	dev_uc_sync(ipvlan->phy_dev, dev);
 	dev_mc_sync(ipvlan->phy_dev, dev);
@@ -470,6 +459,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	INIT_LIST_HEAD(&ipvlan->addrs);
 	ipvlan->ipv4cnt = 0;
 	ipvlan->ipv6cnt = 0;
+	__set_bit(ipvlan_mac_hash(dev->broadcast), ipvlan->mac_filters);
 
 	/* TODO Probably put random address here to be presented to the
 	 * world but keep using the physical-dev address for the outgoing
@@ -694,7 +684,6 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
 	ipvlan->ipv4cnt++;
 	ipvlan_ht_addr_add(ipvlan, addr);
-	ipvlan_set_broadcast_mac_filter(ipvlan, true);
 
 	return 0;
 }
@@ -711,8 +700,6 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
 	list_del_rcu(&addr->anode);
 	ipvlan->ipv4cnt--;
 	WARN_ON(ipvlan->ipv4cnt < 0);
-	if (!ipvlan->ipv4cnt)
-	    ipvlan_set_broadcast_mac_filter(ipvlan, false);
 	kfree_rcu(addr, rcu);
 
 	return;
-- 
2.1.0
