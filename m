From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/4] bridge: vlan: use
	br_vlan_(get|put)_master to deal with refcounts
Date: Fri,  2 Oct 2015 15:05:11 +0200
Message-ID: <1443791113-12738-3-git-send-email-razor@blackwall.org>
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

Introduce br_vlan_(get|put)_master which take a reference (or create the
master vlan first if it didn't exist) and drop a reference respectively.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
There's one slightly longer line (81 chars) but I think it looks better
this way.

 net/bridge/br_vlan.c | 56 ++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 106d3f890b73..8481d2567513 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -144,6 +144,40 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 	return err;
 }
 
+/* Returns a master vlan, if it didn't exist it gets created. In all cases a
+ * a reference is taken to the master vlan before returning.
+ */
+static struct net_bridge_vlan *br_vlan_get_master(struct net_bridge *br, u16 vid)
+{
+	struct net_bridge_vlan *masterv;
+
+	masterv = br_vlan_find(br->vlgrp, vid);
+	if (!masterv) {
+		/* missing global ctx, create it now */
+		if (br_vlan_add(br, vid, 0))
+			return NULL;
+		masterv = br_vlan_find(br->vlgrp, vid);
+		if (WARN_ON(!masterv))
+			return NULL;
+	}
+	atomic_inc(&masterv->refcnt);
+
+	return masterv;
+}
+
+static void br_vlan_put_master(struct net_bridge_vlan *masterv)
+{
+	if (!br_vlan_is_master(masterv))
+		return;
+
+	if (atomic_dec_and_test(&masterv->refcnt)) {
+		rhashtable_remove_fast(&masterv->br->vlgrp->vlan_hash,
+				       &masterv->vnode, br_vlan_rht_params);
+		__vlan_del_list(masterv);
+		kfree_rcu(masterv, rcu);
+	}
+}
+
 /* This is the shared VLAN add function which works for both ports and bridge
  * devices. There are four possible calls to this function in terms of the
  * vlan entry type:
@@ -194,16 +228,9 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 				goto out_filt;
 		}
 
-		masterv = br_vlan_find(br->vlgrp, v->vid);
-		if (!masterv) {
-			/* missing global ctx, create it now */
-			err = br_vlan_add(br, v->vid, 0);
-			if (err)
-				goto out_filt;
-			masterv = br_vlan_find(br->vlgrp, v->vid);
-			WARN_ON(!masterv);
-		}
-		atomic_inc(&masterv->refcnt);
+		masterv = br_vlan_get_master(br, v->vid);
+		if (!masterv)
+			goto out_filt;
 		v->brvlan = masterv;
 	}
 
@@ -238,7 +265,7 @@ out_filt:
 	if (p) {
 		__vlan_vid_del(dev, br, v->vid);
 		if (masterv) {
-			atomic_dec(&masterv->refcnt);
+			br_vlan_put_master(masterv);
 			v->brvlan = NULL;
 		}
 	}
@@ -287,12 +314,7 @@ static int __vlan_del(struct net_bridge_vlan *v)
 		kfree_rcu(v, rcu);
 	}
 
-	if (atomic_dec_and_test(&masterv->refcnt)) {
-		rhashtable_remove_fast(&masterv->br->vlgrp->vlan_hash,
-				       &masterv->vnode, br_vlan_rht_params);
-		__vlan_del_list(masterv);
-		kfree_rcu(masterv, rcu);
-	}
+	br_vlan_put_master(masterv);
 out:
 	return err;
 }
-- 
2.4.3
