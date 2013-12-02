From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 5/7] bridge: Properly check if local fdb entry can be deleted in br_fdb_change_mac_address
Date: Mon,  2 Dec 2013 15:40:36 +0900
Message-ID: <1385966439-26526-6-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:33625 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab3LBGl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 01:41:59 -0500
In-Reply-To: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_change_mac_address() doesn't check if the local entry has the
same address as any of bridge ports.
Although I'm not sure when it is beneficial, current implementation allow
the bridge device to receive any mac address of its ports.
To preserve this behavior, we have to check if the mac address of the
entry we are deleting is identical to that of any port.

With that check, as the logic of changing local entries is almost the
same as br_fdb_changeaddr(), create a common function
br_fdb_change_locals() and call it from br_fdb_changeaddr() and
br_fdb_change_mac_address().
Now these two functions have only one line, make them inline functions.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c     | 37 ++++---------------------------------
 net/bridge/br_private.h | 17 +++++++++++++++--
 2 files changed, 19 insertions(+), 35 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 2c79b1b..d39b525 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -124,11 +124,11 @@ static void fdb_delete_local(struct net_bridge *br,
 	fdb_delete(br, f);
 }
 
-void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
+void br_fdb_change_locals(struct net_bridge *br, struct net_bridge_port *p,
+			  const unsigned char *oldaddr,
+			  const unsigned char *newaddr)
 {
-	struct net_bridge *br = p->br;
 	struct net_port_vlans *pv;
-	const unsigned char *oldaddr = p->prev_addr.addr;
 	u16 vid;
 
 	ASSERT_RTNL();
@@ -147,7 +147,7 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 	 * port.  This function runs under RTNL so the bitmap will not
 	 * change from under us.
 	 */
-	pv = nbp_get_vlan_info(p);
+	pv = p ? nbp_get_vlan_info(p) : br_get_vlan_info(br);
 	if (!pv)
 		goto out;
 
@@ -160,35 +160,6 @@ out:
 	spin_unlock_bh(&br->hash_lock);
 }
 
-void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
-{
-	struct net_bridge_fdb_entry *f;
-	struct net_port_vlans *pv;
-	u16 vid = 0;
-
-	/* If old entry was unassociated with any port, then delete it. */
-	f = __br_fdb_get(br, br->dev->dev_addr, 0);
-	if (f && f->is_local && !f->dst)
-		fdb_delete(br, f);
-
-	fdb_insert(br, NULL, newaddr, 0);
-
-	/* Now remove and add entries for every VLAN configured on the
-	 * bridge.  This function runs under RTNL so the bitmap will not
-	 * change from under us.
-	 */
-	pv = br_get_vlan_info(br);
-	if (!pv)
-		return;
-
-	for_each_set_bit_from(vid, pv->vlan_bitmap, VLAN_N_VID) {
-		f = __br_fdb_get(br, br->dev->dev_addr, vid);
-		if (f && f->is_local && !f->dst)
-			fdb_delete(br, f);
-		fdb_insert(br, NULL, newaddr, vid);
-	}
-}
-
 void br_fdb_cleanup(unsigned long _data)
 {
 	struct net_bridge *br = (struct net_bridge *)_data;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 673ef9d..50f0b0d 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -379,8 +379,9 @@ static inline void br_netpoll_disable(struct net_bridge_port *p)
 int br_fdb_init(void);
 void br_fdb_fini(void);
 void br_fdb_flush(struct net_bridge *br);
-void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr);
-void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
+void br_fdb_change_locals(struct net_bridge *br, struct net_bridge_port *p,
+			  const unsigned char *oldaddr,
+			  const unsigned char *newaddr);
 void br_fdb_cleanup(unsigned long arg);
 void br_fdb_delete_by_port(struct net_bridge *br,
 			   const struct net_bridge_port *p, int do_all);
@@ -402,6 +403,18 @@ int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
 int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		struct net_device *dev, int idx);
 
+static inline void br_fdb_changeaddr(struct net_bridge_port *p,
+				     const unsigned char *newaddr)
+{
+	br_fdb_change_locals(p->br, p, p->prev_addr.addr, newaddr);
+}
+
+static inline void br_fdb_change_mac_address(struct net_bridge *br,
+					     const u8 *newaddr)
+{
+	br_fdb_change_locals(br, NULL, br->dev->dev_addr, newaddr);
+}
+
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
 int br_dev_queue_push_xmit(struct sk_buff *skb);
-- 
1.8.1.2
