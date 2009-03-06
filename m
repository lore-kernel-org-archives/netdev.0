From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] macvlan:  Deterministic ingress packet delivery
Date: Fri, 06 Mar 2009 12:16:39 -0800
Message-ID: <m1wsb2h0ew.fsf_-_@fess.ebiederm.org>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>
	<m1sklqohw2.fsf@fess.ebiederm.org> <49B13259.9040701@trash.net>
	<m14oy6n15y.fsf@fess.ebiederm.org> <49B13C7D.10308@trash.net>
	<m1bpsellmv.fsf@fess.ebiederm.org> <49B15865.10103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34002 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbZCFUQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 15:16:45 -0500
In-Reply-To: <49B15865.10103@candelatech.com> (Ben Greear's message of "Fri\, 06 Mar 2009 09\:07\:49 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 22d0a3e4ffa91f85c224d171ed7cc2d64a6dda00 Mon Sep 17 00:00:00 2001
From: Eric Biederman <ebiederm@xmission.com>
Date: Fri, 6 Mar 2009 09:16:30 -0800
Subject: 

Changing the mac address when a macvlan device is up will leave the
device on the wrong hash chain making it impossible to receive
packets.

There is no checking of the mac address set on the macvlan.  Allowing
a misconfiguration to grab packets from the the underlying device or
another macvlan.

To resolve these problems I update the hash table of macvlans when the
mac address of a macvlan changes, and when updating the hash table
I verify that the new mac address is usable.

The result is well defined and predictable if not perfect handling of
mac vlan mac addresses.

To keep the code clear I have created a set of hash table maintenance
in macvlan so I am not open coding the hash function and the logic
needed to update the hash table all over the place.

Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/macvlan.c |   73 ++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 60 insertions(+), 13 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b5241fc..70d3ef4 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -60,6 +60,47 @@ static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 	return NULL;
 }
 
+static void macvlan_hash_add(struct macvlan_dev *vlan)
+{
+	struct macvlan_port *port = vlan->port;
+	const unsigned char *addr = vlan->dev->dev_addr;
+
+	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[addr[5]]);
+}
+
+static void macvlan_hash_del(struct macvlan_dev *vlan)
+{
+	hlist_del_rcu(&vlan->hlist);
+	synchronize_rcu();
+}
+
+static void macvlan_hash_change_addr(struct macvlan_dev *vlan,
+					const unsigned char *addr)
+{
+	macvlan_hash_del(vlan);
+	/* Now that we are unhashed it is safe to change the device
+	 * address without confusing packet delivery.
+	 */
+	memcpy(vlan->dev->dev_addr, addr, ETH_ALEN);
+	macvlan_hash_add(vlan);
+}
+
+static int macvlan_addr_busy(const struct macvlan_port *port,
+				const unsigned char *addr)
+{
+	/* Test to see if the specified multicast address is
+	 * currently in use by the underlying device or
+	 * another macvlan.
+	 */
+	if (memcmp(port->dev->dev_addr, addr, ETH_ALEN) == 0)
+		return 1;
+
+	if (macvlan_hash_lookup(port, addr))
+		return 1;
+
+	return 0;
+}
+
 static void macvlan_broadcast(struct sk_buff *skb,
 			      const struct macvlan_port *port)
 {
@@ -184,10 +225,13 @@ static const struct header_ops macvlan_hard_header_ops = {
 static int macvlan_open(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvlan_port *port = vlan->port;
 	struct net_device *lowerdev = vlan->lowerdev;
 	int err;
 
+	err = -EBUSY;
+	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
+		goto out;
+
 	err = dev_unicast_add(lowerdev, dev->dev_addr, ETH_ALEN);
 	if (err < 0)
 		goto out;
@@ -196,8 +240,7 @@ static int macvlan_open(struct net_device *dev)
 		if (err < 0)
 			goto del_unicast;
 	}
-
-	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[dev->dev_addr[5]]);
+	macvlan_hash_add(vlan);
 	return 0;
 
 del_unicast:
@@ -217,8 +260,7 @@ static int macvlan_stop(struct net_device *dev)
 
 	dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
 
-	hlist_del_rcu(&vlan->hlist);
-	synchronize_rcu();
+	macvlan_hash_del(vlan);
 	return 0;
 }
 
@@ -232,16 +274,21 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	if (!(dev->flags & IFF_UP))
-		goto out;
+	if (!(dev->flags & IFF_UP)) {
+		/* Just copy in the new address */
+		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	} else {
+		/* Rehash and update the device filters */
+		if (macvlan_addr_busy(vlan->port, addr->sa_data))
+			return -EBUSY;
 
-	err = dev_unicast_add(lowerdev, addr->sa_data, ETH_ALEN);
-	if (err < 0)
-		return err;
-	dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
+		if ((err = dev_unicast_add(lowerdev, addr->sa_data, ETH_ALEN)))
+			return err;
 
-out:
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+		dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
+
+		macvlan_hash_change_addr(vlan, addr->sa_data);
+	}
 	return 0;
 }
 
-- 
1.6.1.2.350.g88cc

