From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/13] bridge: Convert compare_ether_addr to
	ether_addr_equal
Date: Tue,  8 May 2012 21:56:49 -0700
Message-ID: <06c7fe9d635e717918c9acccb765e5d16856a8d9.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bridge/br_device.c   |    2 +-
 net/bridge/br_fdb.c      |   14 +++++++-------
 net/bridge/br_input.c    |    2 +-
 net/bridge/br_stp_bpdu.c |    2 +-
 net/bridge/br_stp_if.c   |   11 +++++------
 5 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index d6e5929..929e48aed 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -170,7 +170,7 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 		return -EADDRNOTAVAIL;
 
 	spin_lock_bh(&br->lock);
-	if (compare_ether_addr(dev->dev_addr, addr->sa_data)) {
+	if (!ether_addr_equal(dev->dev_addr, addr->sa_data)) {
 		dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 		br_fdb_change_mac_address(br, addr->sa_data);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5945c54..d21f323 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -107,8 +107,8 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 				struct net_bridge_port *op;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&
-					    !compare_ether_addr(op->dev->dev_addr,
-								f->addr.addr)) {
+					    ether_addr_equal(op->dev->dev_addr,
+							     f->addr.addr)) {
 						f->dst = op;
 						goto insert;
 					}
@@ -214,8 +214,8 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 				struct net_bridge_port *op;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&
-					    !compare_ether_addr(op->dev->dev_addr,
-								f->addr.addr)) {
+					    ether_addr_equal(op->dev->dev_addr,
+							     f->addr.addr)) {
 						f->dst = op;
 						goto skip_delete;
 					}
@@ -237,7 +237,7 @@ struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
 	struct net_bridge_fdb_entry *fdb;
 
 	hlist_for_each_entry_rcu(fdb, h, &br->hash[br_mac_hash(addr)], hlist) {
-		if (!compare_ether_addr(fdb->addr.addr, addr)) {
+		if (ether_addr_equal(fdb->addr.addr, addr)) {
 			if (unlikely(has_expired(br, fdb)))
 				break;
 			return fdb;
@@ -331,7 +331,7 @@ static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
 	struct net_bridge_fdb_entry *fdb;
 
 	hlist_for_each_entry(fdb, h, head, hlist) {
-		if (!compare_ether_addr(fdb->addr.addr, addr))
+		if (ether_addr_equal(fdb->addr.addr, addr))
 			return fdb;
 	}
 	return NULL;
@@ -344,7 +344,7 @@ static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
 	struct net_bridge_fdb_entry *fdb;
 
 	hlist_for_each_entry_rcu(fdb, h, head, hlist) {
-		if (!compare_ether_addr(fdb->addr.addr, addr))
+		if (ether_addr_equal(fdb->addr.addr, addr))
 			return fdb;
 	}
 	return NULL;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 5a31731..76f15fd 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -216,7 +216,7 @@ forward:
 		}
 		/* fall through */
 	case BR_STATE_LEARNING:
-		if (!compare_ether_addr(p->br->dev->dev_addr, dest))
+		if (ether_addr_equal(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
 		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index e16aade..fd30a60 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -167,7 +167,7 @@ void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
 	if (p->state == BR_STATE_DISABLED)
 		goto out;
 
-	if (compare_ether_addr(dest, br->group_addr) != 0)
+	if (!ether_addr_equal(dest, br->group_addr))
 		goto out;
 
 	buf = skb_pull(skb, 3);
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index f494496..9d5a414 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -178,7 +178,7 @@ void br_stp_set_enabled(struct net_bridge *br, unsigned long val)
 /* called under bridge lock */
 void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *addr)
 {
-	/* should be aligned on 2 bytes for compare_ether_addr() */
+	/* should be aligned on 2 bytes for ether_addr_equal() */
 	unsigned short oldaddr_aligned[ETH_ALEN >> 1];
 	unsigned char *oldaddr = (unsigned char *)oldaddr_aligned;
 	struct net_bridge_port *p;
@@ -191,12 +191,11 @@ void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *addr)
 	memcpy(br->dev->dev_addr, addr, ETH_ALEN);
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (!compare_ether_addr(p->designated_bridge.addr, oldaddr))
+		if (ether_addr_equal(p->designated_bridge.addr, oldaddr))
 			memcpy(p->designated_bridge.addr, addr, ETH_ALEN);
 
-		if (!compare_ether_addr(p->designated_root.addr, oldaddr))
+		if (ether_addr_equal(p->designated_root.addr, oldaddr))
 			memcpy(p->designated_root.addr, addr, ETH_ALEN);
-
 	}
 
 	br_configuration_update(br);
@@ -205,7 +204,7 @@ void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *addr)
 		br_become_root_bridge(br);
 }
 
-/* should be aligned on 2 bytes for compare_ether_addr() */
+/* should be aligned on 2 bytes for ether_addr_equal() */
 static const unsigned short br_mac_zero_aligned[ETH_ALEN >> 1];
 
 /* called under bridge lock */
@@ -227,7 +226,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 
 	}
 
-	if (compare_ether_addr(br->bridge_id.addr, addr) == 0)
+	if (ether_addr_equal(br->bridge_id.addr, addr))
 		return false;	/* no change */
 
 	br_stp_change_bridge_id(br, addr);
-- 
1.7.8.111.gad25c.dirty
