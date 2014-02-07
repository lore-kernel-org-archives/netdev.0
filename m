From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v3 net 8/9] bridge: Properly check if local fdb entry can be deleted when deleting vlan
Date: Fri,  7 Feb 2014 16:48:25 +0900
Message-ID: <1391759306-24956-9-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:39804 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaBGHsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 02:48:43 -0500
In-Reply-To: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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
Acked-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_fdb.c     | 20 ++++++++++++++++++--
 net/bridge/br_private.h |  4 +++-
 net/bridge/br_vlan.c    |  8 ++------
 3 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 43e54d1..0426dff 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -27,6 +27,9 @@
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
+static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
+					     const unsigned char *addr,
+					     __u16 vid);
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		      const unsigned char *addr, u16 vid);
 static void fdb_notify(struct net_bridge *br,
@@ -119,6 +122,20 @@ static void fdb_delete_local(struct net_bridge *br,
 	fdb_delete(br, f);
 }
 
+void br_fdb_find_delete_local(struct net_bridge *br,
+			      const struct net_bridge_port *p,
+			      const unsigned char *addr, u16 vid)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
+	struct net_bridge_fdb_entry *f;
+
+	spin_lock_bh(&br->hash_lock);
+	f = fdb_find(head, addr, vid);
+	if (f && f->is_local && !f->added_by_user && f->dst == p)
+		fdb_delete_local(br, p, f);
+	spin_unlock_bh(&br->hash_lock);
+}
+
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
 	struct net_bridge *br = p->br;
@@ -770,8 +787,7 @@ out:
 	return err;
 }
 
-int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
-		       u16 vlan)
+static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vlan)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
 	struct net_bridge_fdb_entry *fdb;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f91e1d9..3ba11bc 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -371,6 +371,9 @@ static inline void br_netpoll_disable(struct net_bridge_port *p)
 int br_fdb_init(void);
 void br_fdb_fini(void);
 void br_fdb_flush(struct net_bridge *br);
+void br_fdb_find_delete_local(struct net_bridge *br,
+			      const struct net_bridge_port *p,
+			      const unsigned char *addr, u16 vid);
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr);
 void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
 void br_fdb_cleanup(unsigned long arg);
@@ -385,7 +388,6 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		  const unsigned char *addr, u16 vid);
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		   const unsigned char *addr, u16 vid, bool added_by_user);
-int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vid);
 
 int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		  struct net_device *dev, const unsigned char *addr);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 233ec1c..8249ca7 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -275,9 +275,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 	if (!pv)
 		return -EINVAL;
 
-	spin_lock_bh(&br->hash_lock);
-	fdb_delete_by_addr(br, br->dev->dev_addr, vid);
-	spin_unlock_bh(&br->hash_lock);
+	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
 
 	__vlan_del(pv, vid);
 	return 0;
@@ -378,9 +376,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 	if (!pv)
 		return -EINVAL;
 
-	spin_lock_bh(&port->br->hash_lock);
-	fdb_delete_by_addr(port->br, port->dev->dev_addr, vid);
-	spin_unlock_bh(&port->br->hash_lock);
+	br_fdb_find_delete_local(port->br, port, port->dev->dev_addr, vid);
 
 	return __vlan_del(pv, vid);
 }
-- 
1.8.1.2
