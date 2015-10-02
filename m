From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 4/4] bridge: vlan: use br_vlan_should_use
	to simplify __vlan_add/del
Date: Fri,  2 Oct 2015 15:05:13 +0200
Message-ID: <1443791113-12738-5-git-send-email-razor@blackwall.org>
References: <1443791113-12738-1-git-send-email-razor@blackwall.org>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, vyasevich@gmail.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1443791113-12738-1-git-send-email-razor@blackwall.org>
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

The checks that lead to num_vlans change are always what
br_vlan_should_use checks for, namely if the vlan is only a context or
not and depending on that it's either not counted or counted
as a real/used vlan respectively.
Also give better explanation in br_vlan_should_use's comment.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_private.h |  2 +-
 net/bridge/br_vlan.c    | 36 ++++++++++++++----------------------
 2 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4ed8308db66e..1ff6a0faef3f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -400,7 +400,7 @@ static inline bool br_vlan_is_brentry(const struct net_bridge_vlan *v)
 	return v->flags & BRIDGE_VLAN_INFO_BRENTRY;
 }
 
-/* check if we should use the vlan entry is usable */
+/* check if we should use the vlan entry, returns false if it's only context */
 static inline bool br_vlan_should_use(const struct net_bridge_vlan *v)
 {
 	if (br_vlan_is_master(v)) {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 1f6f9f5b2c73..d2811f8ea5f7 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -193,7 +193,7 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 {
 	struct net_bridge_vlan *masterv = NULL;
 	struct net_bridge_port *p = NULL;
-	struct rhashtable *tbl;
+	struct net_bridge_vlan_group *vg;
 	struct net_device *dev;
 	struct net_bridge *br;
 	int err;
@@ -201,12 +201,12 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 	if (br_vlan_is_master(v)) {
 		br = v->br;
 		dev = br->dev;
-		tbl = &br->vlgrp->vlan_hash;
+		vg = br->vlgrp;
 	} else {
 		p = v->port;
 		br = p->br;
 		dev = p->dev;
-		tbl = &p->vlgrp->vlan_hash;
+		vg = p->vlgrp;
 	}
 
 	if (p) {
@@ -232,32 +232,31 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 		v->brvlan = masterv;
 	}
 
-	/* Add the dev mac only if it's a usable vlan */
+	/* Add the dev mac and count the vlan only if it's usable */
 	if (br_vlan_should_use(v)) {
 		err = br_fdb_insert(br, p, dev->dev_addr, v->vid);
 		if (err) {
 			br_err(br, "failed insert local address into bridge forwarding table\n");
 			goto out_filt;
 		}
+		vg->num_vlans++;
 	}
 
-	err = rhashtable_lookup_insert_fast(tbl, &v->vnode, br_vlan_rht_params);
+	err = rhashtable_lookup_insert_fast(&vg->vlan_hash, &v->vnode,
+					    br_vlan_rht_params);
 	if (err)
 		goto out_fdb_insert;
 
 	__vlan_add_list(v);
 	__vlan_add_flags(v, flags);
-	if (br_vlan_is_master(v)) {
-		if (br_vlan_is_brentry(v))
-			br->vlgrp->num_vlans++;
-	} else {
-		p->vlgrp->num_vlans++;
-	}
 out:
 	return err;
 
 out_fdb_insert:
-	br_fdb_find_delete_local(br, p, br->dev->dev_addr, v->vid);
+	if (br_vlan_should_use(v)) {
+		br_fdb_find_delete_local(br, p, dev->dev_addr, v->vid);
+		vg->num_vlans--;
+	}
 
 out_filt:
 	if (p) {
@@ -276,15 +275,12 @@ static int __vlan_del(struct net_bridge_vlan *v)
 	struct net_bridge_vlan *masterv = v;
 	struct net_bridge_vlan_group *vg;
 	struct net_bridge_port *p = NULL;
-	struct net_bridge *br;
 	int err = 0;
 
 	if (br_vlan_is_master(v)) {
-		br = v->br;
 		vg = v->br->vlgrp;
 	} else {
 		p = v->port;
-		br = p->br;
 		vg = v->port->vlgrp;
 		masterv = v->brvlan;
 	}
@@ -296,13 +292,9 @@ static int __vlan_del(struct net_bridge_vlan *v)
 			goto out;
 	}
 
-	if (br_vlan_is_master(v)) {
-		if (br_vlan_is_brentry(v)) {
-			v->flags &= ~BRIDGE_VLAN_INFO_BRENTRY;
-			br->vlgrp->num_vlans--;
-		}
-	} else {
-		p->vlgrp->num_vlans--;
+	if (br_vlan_should_use(v)) {
+		v->flags &= ~BRIDGE_VLAN_INFO_BRENTRY;
+		vg->num_vlans--;
 	}
 
 	if (masterv != v) {
-- 
2.4.3
