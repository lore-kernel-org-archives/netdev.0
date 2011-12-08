From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 3/3] bridge: add local MAC address to forwarding
 table (v2)
Date: Thu, 8 Dec 2011 09:17:49 -0800
Message-ID: <20111208091749.121a7bc9@nehalam.linuxnetplumber.net>
References: <20111206230223.191544130@vyatta.com>
 <20111206230316.149318632@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49613 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270Ab1LHRRw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 12:17:52 -0500
In-Reply-To: <20111206230316.149318632@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If user has configured a MAC address that is not one of the existing
ports of the bridge, then we need to add a special entry in the forwarding
table. This forwarding table entry has no outgoing port so it has to be
treated a little differently. The special entry is reported by the netlink
interface with ifindex of bridge, but ignored by the old interface since there
is no usable way to put it in the ABI.

Reported-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - set ifindex in NEWNEIGH to bridge instead of zero

--- a/net/bridge/br_device.c	2011-12-07 10:54:21.616301619 -0800
+++ b/net/bridge/br_device.c	2011-12-07 11:28:14.490336392 -0800
@@ -170,8 +170,11 @@ static int br_set_mac_address(struct net
 		return -EINVAL;
 
 	spin_lock_bh(&br->lock);
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
-	br_stp_change_bridge_id(br, addr->sa_data);
+	if (compare_ether_addr(dev->dev_addr, addr->sa_data)) {
+		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+		br_fdb_change_mac_address(br, addr->sa_data);
+		br_stp_change_bridge_id(br, addr->sa_data);
+	}
 	br->flags |= BR_SET_MAC_ADDR;
 	spin_unlock_bh(&br->lock);
 
--- a/net/bridge/br_fdb.c	2011-12-07 11:27:05.233784054 -0800
+++ b/net/bridge/br_fdb.c	2011-12-07 11:28:44.782581738 -0800
@@ -127,6 +127,18 @@ void br_fdb_changeaddr(struct net_bridge
 	spin_unlock_bh(&br->hash_lock);
 }
 
+void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
+{
+	struct net_bridge_fdb_entry *f;
+
+	/* If old entry was unassociated with any port, then delete it. */
+	f = __br_fdb_get(br, br->dev->dev_addr);
+	if (f && f->is_local && !f->dst)
+		fdb_delete(br, f);
+
+	fdb_insert(br, NULL, newaddr);
+}
+
 void br_fdb_cleanup(unsigned long _data)
 {
 	struct net_bridge *br = (struct net_bridge *)_data;
@@ -250,7 +262,7 @@ int br_fdb_test_addr(struct net_device *
 		ret = 0;
 	else {
 		fdb = __br_fdb_get(port->br, addr);
-		ret = fdb && fdb->dst->dev != dev &&
+		ret = fdb && fdb->dst && fdb->dst->dev != dev &&
 			fdb->dst->state == BR_STATE_FORWARDING;
 	}
 	rcu_read_unlock();
@@ -282,6 +294,10 @@ int br_fdb_fillbuf(struct net_bridge *br
 			if (has_expired(br, f))
 				continue;
 
+			/* ignore pseudo entry for local MAC address */
+			if (!f->dst)
+				continue;
+
 			if (skip) {
 				--skip;
 				continue;
@@ -468,7 +484,7 @@ static int fdb_fill_info(struct sk_buff
 	ndm->ndm_pad2    = 0;
 	ndm->ndm_flags	 = 0;
 	ndm->ndm_type	 = 0;
-	ndm->ndm_ifindex = fdb->dst->dev->ifindex;
+	ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
 	ndm->ndm_state   = fdb_to_nud(fdb);
 
 	NLA_PUT(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr);
--- a/net/bridge/br_forward.c	2011-12-07 10:54:21.616301619 -0800
+++ b/net/bridge/br_forward.c	2011-12-07 11:28:14.490336392 -0800
@@ -98,7 +98,7 @@ static void __br_forward(const struct ne
 /* called with rcu_read_lock */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
-	if (should_deliver(to, skb)) {
+	if (to && should_deliver(to, skb)) {
 		__br_deliver(to, skb);
 		return;
 	}
--- a/net/bridge/br_private.h	2011-12-07 10:54:21.616301619 -0800
+++ b/net/bridge/br_private.h	2011-12-07 11:28:14.490336392 -0800
@@ -348,6 +348,7 @@ extern void br_fdb_fini(void);
 extern void br_fdb_flush(struct net_bridge *br);
 extern void br_fdb_changeaddr(struct net_bridge_port *p,
 			      const unsigned char *newaddr);
+extern void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
 extern void br_fdb_cleanup(unsigned long arg);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
 				  const struct net_bridge_port *p, int do_all);
