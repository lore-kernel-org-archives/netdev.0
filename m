From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: notify applications if address of bridge device
 changes
Date: Thu, 24 Mar 2011 16:24:01 -0700
Message-ID: <20110324162401.2f322e3e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49303 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851Ab1CXXYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 19:24:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mac address of the bridge device may be changed when a new interface
is added to the bridge. If this happens, then the bridge needs to call
the network notifiers to tickle any other systems that care. Since bridge
can be a module, this also means exporting the notifier function.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_if.c      |    6 +++++-
 net/bridge/br_private.h |    2 +-
 net/bridge/br_stp_if.c  |    9 ++++++---
 net/core/dev.c          |    1 +
 4 files changed, 13 insertions(+), 5 deletions(-)

--- a/net/bridge/br_stp_if.c	2011-03-22 10:13:27.917855706 -0700
+++ b/net/bridge/br_stp_if.c	2011-03-22 10:24:50.416524699 -0700
@@ -204,7 +204,7 @@ void br_stp_change_bridge_id(struct net_
 static const unsigned short br_mac_zero_aligned[ETH_ALEN >> 1];
 
 /* called under bridge lock */
-void br_stp_recalculate_bridge_id(struct net_bridge *br)
+bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 {
 	const unsigned char *br_mac_zero =
 			(const unsigned char *)br_mac_zero_aligned;
@@ -222,8 +222,11 @@ void br_stp_recalculate_bridge_id(struct
 
 	}
 
-	if (compare_ether_addr(br->bridge_id.addr, addr))
-		br_stp_change_bridge_id(br, addr);
+	if (compare_ether_addr(br->bridge_id.addr, addr) == 0)
+		return false;	/* no change */
+
+	br_stp_change_bridge_id(br, addr);
+	return true;
 }
 
 /* called under bridge lock */
--- a/net/core/dev.c	2011-03-22 10:14:12.681547462 -0700
+++ b/net/core/dev.c	2011-03-22 10:24:50.416524699 -0700
@@ -1474,6 +1474,7 @@ int call_netdevice_notifiers(unsigned lo
 	ASSERT_RTNL();
 	return raw_notifier_call_chain(&netdev_chain, val, dev);
 }
+EXPORT_SYMBOL(call_netdevice_notifiers);
 
 /* When > 0 there are consumers of rx skb time stamps */
 static atomic_t netstamp_needed = ATOMIC_INIT(0);
--- a/net/bridge/br_if.c	2011-03-22 10:14:12.669553975 -0700
+++ b/net/bridge/br_if.c	2011-03-22 10:24:50.420524900 -0700
@@ -389,6 +389,7 @@ int br_add_if(struct net_bridge *br, str
 {
 	struct net_bridge_port *p;
 	int err = 0;
+	bool changed_addr;
 
 	/* Don't allow bridging non-ethernet like devices */
 	if ((dev->flags & IFF_LOOPBACK) ||
@@ -446,7 +447,7 @@ int br_add_if(struct net_bridge *br, str
 	list_add_rcu(&p->list, &br->port_list);
 
 	spin_lock_bh(&br->lock);
-	br_stp_recalculate_bridge_id(br);
+	changed_addr = br_stp_recalculate_bridge_id(br);
 	br_features_recompute(br);
 
 	if ((dev->flags & IFF_UP) && netif_carrier_ok(dev) &&
@@ -456,6 +457,9 @@ int br_add_if(struct net_bridge *br, str
 
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
+	if (changed_addr)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+
 	dev_set_mtu(br->dev, br_min_mtu(br));
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
--- a/net/bridge/br_private.h	2011-03-22 10:14:12.673551804 -0700
+++ b/net/bridge/br_private.h	2011-03-22 10:24:50.420524900 -0700
@@ -497,7 +497,7 @@ extern void br_stp_disable_bridge(struct
 extern void br_stp_set_enabled(struct net_bridge *br, unsigned long val);
 extern void br_stp_enable_port(struct net_bridge_port *p);
 extern void br_stp_disable_port(struct net_bridge_port *p);
-extern void br_stp_recalculate_bridge_id(struct net_bridge *br);
+extern bool br_stp_recalculate_bridge_id(struct net_bridge *br);
 extern void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *a);
 extern void br_stp_set_bridge_priority(struct net_bridge *br,
 				       u16 newprio);
