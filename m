From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 7/7] bridge: Properly check if local fdb entry can be deleted when deleting vlan
Date: Mon,  2 Dec 2013 15:40:38 +0900
Message-ID: <1385966439-26526-8-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:56249 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865Ab3LBGl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 01:41:59 -0500
In-Reply-To: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlan codes unconditionally delete local fdb entries.
We should consider the possibility that other ports have the same
address and vlan.

Example of problematic case:
  ip link set eth0 address 12:34:56:78:90:ab
  ip link set eth1 address aa:bb:cc:dd:ee:ff
  brctl addif br0 eth0
  brctl addif br0 eth1 # br0 will have mac address 12:34:56:78:90:ab
  bridge vlan add dev eth0 vid 10
  bridge vlan add dev eth1 vid 10
  bridge vlan add dev br0 vid 10 self
We will have fdb entry such that f->dst == eth0, f->vlan_id == 10 and
f->addr == 12:34:56:78:90:ab at this time.
Next, delete eth0 vlan 10.
  bridge vlan del dev eth0 vid 10
In this case, we still need the entry for br0, but it will be deleted.

Note that br0 needs the entry even though its mac address is not set
manually. To delete the entry with proper condition checking,
fdb_delete_local() is suitable to use.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c     | 9 ++++-----
 net/bridge/br_private.h | 3 ++-
 net/bridge/br_vlan.c    | 4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index d87d4cd..2688ea8 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -120,9 +120,8 @@ static void __fdb_delete_local(struct net_bridge *br,
 }
 
 /* Delete a local entry if no other port had the same address. */
-static void fdb_delete_local(struct net_bridge *br,
-			     const struct net_bridge_port *p,
-			     const unsigned char *addr, u16 vid)
+void fdb_delete_local(struct net_bridge *br, const struct net_bridge_port *p,
+		      const unsigned char *addr, u16 vid)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *f;
@@ -737,8 +736,8 @@ out:
 	return err;
 }
 
-int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
-		       u16 vlan)
+static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
+			      u16 vlan)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
 	struct net_bridge_fdb_entry *fdb;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 50f0b0d..1763908 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -379,6 +379,8 @@ static inline void br_netpoll_disable(struct net_bridge_port *p)
 int br_fdb_init(void);
 void br_fdb_fini(void);
 void br_fdb_flush(struct net_bridge *br);
+void fdb_delete_local(struct net_bridge *br, const struct net_bridge_port *p,
+		      const unsigned char *addr, u16 vid);
 void br_fdb_change_locals(struct net_bridge *br, struct net_bridge_port *p,
 			  const unsigned char *oldaddr,
 			  const unsigned char *newaddr);
@@ -394,7 +396,6 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		  const unsigned char *addr, u16 vid);
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		   const unsigned char *addr, u16 vid);
-int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vid);
 
 int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		  struct net_device *dev, const unsigned char *addr);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index f87ab88f..e4d5c7f 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -297,7 +297,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 		return -EINVAL;
 
 	spin_lock_bh(&br->hash_lock);
-	fdb_delete_by_addr(br, br->dev->dev_addr, vid);
+	fdb_delete_local(br, NULL, br->dev->dev_addr, vid);
 	spin_unlock_bh(&br->hash_lock);
 
 	__vlan_del(pv, vid);
@@ -400,7 +400,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 		return -EINVAL;
 
 	spin_lock_bh(&port->br->hash_lock);
-	fdb_delete_by_addr(port->br, port->dev->dev_addr, vid);
+	fdb_delete_local(port->br, port, port->dev->dev_addr, vid);
 	spin_unlock_bh(&port->br->hash_lock);
 
 	return __vlan_del(pv, vid);
-- 
1.8.1.2
