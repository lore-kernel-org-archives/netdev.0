From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] bridge: make bridge address settings sticky
Date: Tue, 17 Jun 2008 09:52:13 -0700
Message-ID: <20080617165223.184830407@vyatta.com>
References: <20080617165211.615620784@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:56911 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754279AbYFQQwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 12:52:55 -0400
Content-Disposition: inline; filename=br-sticky-mac.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Normally, the bridge just chooses the smallest mac address as the
bridge id and mac address of bridge device. But if the administrator
has explictly set the interface address then don't change it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_device.c	2008-06-17 09:18:02.000000000 -0700
+++ b/net/bridge/br_device.c	2008-06-17 09:18:16.000000000 -0700
@@ -95,6 +95,7 @@ static int br_set_mac_address(struct net
 	spin_lock_bh(&br->lock);
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	br_stp_change_bridge_id(br, addr->sa_data);
+	br->flags |= BR_SET_MAC_ADDR;
 	spin_unlock_bh(&br->lock);
 
 	return 0;
--- a/net/bridge/br_private.h	2008-06-17 09:14:42.000000000 -0700
+++ b/net/bridge/br_private.h	2008-06-17 09:21:10.000000000 -0700
@@ -95,6 +95,8 @@ struct net_bridge
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;
 	unsigned long			feature_mask;
+	unsigned long			flags;
+#define BR_SET_MAC_ADDR		0x00000001
 
 	/* STP */
 	bridge_id			designated_root;
--- a/net/bridge/br_stp_if.c	2008-06-17 09:20:06.000000000 -0700
+++ b/net/bridge/br_stp_if.c	2008-06-17 09:21:00.000000000 -0700
@@ -216,6 +216,10 @@ void br_stp_recalculate_bridge_id(struct
 	const unsigned char *addr = br_mac_zero;
 	struct net_bridge_port *p;
 
+	/* user has chosen a value so keep it */
+	if (br->flags & BR_SET_MAC_ADDR)
+		return;
+
 	list_for_each_entry(p, &br->port_list, list) {
 		if (addr == br_mac_zero ||
 		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)

-- 

