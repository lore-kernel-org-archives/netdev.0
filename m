From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 net-next 5/6] bridge: Add addresses from static fdbs to non-promisc ports
Date: Fri, 16 May 2014 09:59:19 -0400
Message-ID: <1400248760-20672-6-git-send-email-vyasevic@redhat.com>
References: <1400248760-20672-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, john.r.fastabend@intel.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932684AbaEPN7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 09:59:33 -0400
In-Reply-To: <1400248760-20672-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a static fdb entry is created, add the mac address
from this fdb entry to any ports that are currently running
in non-promiscuous mode.  These ports need this data so that
they can receive traffic destined to these addresses.
By default ports start in promiscuous mode, so this feature
is disabled.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_fdb.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 69 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index fe124e5..648d0e8 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -85,8 +85,58 @@ static void fdb_rcu_free(struct rcu_head *head)
 	kmem_cache_free(br_fdb_cache, ent);
 }
 
+/* When a static FDB entry is added, the mac address from the entry is
+ * added to the bridge private HW address list and all required ports
+ * are then updated with the new information.
+ * Called under RTNL.
+ */
+static void fdb_add_hw(struct net_bridge *br, const unsigned char *addr)
+{
+	int err;
+	struct net_bridge_port *p, *tmp;
+
+	ASSERT_RTNL();
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (!br_promisc_port(p)) {
+			err = dev_uc_add(p->dev, addr);
+			if (err)
+				goto undo;
+		}
+	}
+
+	return;
+undo:
+	list_for_each_entry(tmp, &br->port_list, list) {
+		if (tmp == p)
+			break;
+		if (!br_promisc_port(tmp))
+			dev_uc_del(tmp->dev, addr);
+	}
+}
+
+/* When a static FDB entry is deleted, the HW address from that entry is
+ * also removed from the bridge private HW address list and updates all
+ * the ports with needed information.
+ * Called under RTNL.
+ */
+static void fdb_del_hw(struct net_bridge *br, const unsigned char *addr)
+{
+	struct net_bridge_port *p;
+
+	ASSERT_RTNL();
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (!br_promisc_port(p))
+			dev_uc_del(p->dev, addr);
+	}
+}
+
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 {
+	if (f->is_static)
+		fdb_del_hw(br, f->addr.addr);
+
 	hlist_del_rcu(&f->hlist);
 	fdb_notify(br, f, RTM_DELNEIGH);
 	call_rcu(&f->rcu, fdb_rcu_free);
@@ -466,6 +516,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		return -ENOMEM;
 
 	fdb->is_local = fdb->is_static = 1;
+	fdb_add_hw(br, addr);
 	fdb_notify(br, fdb, RTM_NEWNEIGH);
 	return 0;
 }
@@ -678,13 +729,25 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 	}
 
 	if (fdb_to_nud(fdb) != state) {
-		if (state & NUD_PERMANENT)
-			fdb->is_local = fdb->is_static = 1;
-		else if (state & NUD_NOARP) {
+		if (state & NUD_PERMANENT) {
+			fdb->is_local = 1;
+			if (!fdb->is_static) {
+				fdb->is_static = 1;
+				fdb_add_hw(br, addr);
+			}
+		} else if (state & NUD_NOARP) {
 			fdb->is_local = 0;
-			fdb->is_static = 1;
-		} else
-			fdb->is_local = fdb->is_static = 0;
+			if (!fdb->is_static) {
+				fdb->is_static = 1;
+				fdb_add_hw(br, addr);
+			}
+		} else {
+			fdb->is_local = 0;
+			if (fdb->is_static) {
+				fdb->is_static = 0;
+				fdb_del_hw(br, addr);
+			}
+		}
 
 		modified = true;
 	}
-- 
1.9.0
