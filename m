From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] bridge: fdb: converge fdb_delete_by functions into one
Date: Mon, 13 Feb 2017 14:59:11 +0100
Message-ID: <1486994351-1137-4-git-send-email-nikolay@cumulusnetworks.com>
References: <1486994351-1137-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35156 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752822AbdBMOAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:00:17 -0500
Received: by mail-wm0-f47.google.com with SMTP id v186so158646478wmd.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 06:00:11 -0800 (PST)
In-Reply-To: <1486994351-1137-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can simplify the logic of entries pointing to the bridge by
converging the fdb_delete_by functions, this would allow us to use the
same function for both cases since the fdb's dst is set to NULL if it is
pointing to the bridge thus we can always check for a port match.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_fdb.c | 62 +++++++++++++----------------------------------------
 1 file changed, 15 insertions(+), 47 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index da5ed7d0a3c8..4ac11574117c 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -930,35 +930,10 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
-			      u16 vid)
-{
-	struct net_bridge_fdb_entry *fdb;
-
-	fdb = br_fdb_find(br, addr, vid);
-	if (!fdb)
-		return -ENOENT;
-
-	fdb_delete(br, fdb);
-	return 0;
-}
-
-static int __br_fdb_delete_by_addr(struct net_bridge *br,
-				   const unsigned char *addr, u16 vid)
-{
-	int err;
-
-	spin_lock_bh(&br->hash_lock);
-	err = fdb_delete_by_addr(br, addr, vid);
-	spin_unlock_bh(&br->hash_lock);
-
-	return err;
-}
-
-static int fdb_delete_by_addr_and_port(struct net_bridge_port *p,
+static int fdb_delete_by_addr_and_port(struct net_bridge *br,
+				       const struct net_bridge_port *p,
 				       const u8 *addr, u16 vlan)
 {
-	struct net_bridge *br = p->br;
 	struct net_bridge_fdb_entry *fdb;
 
 	fdb = br_fdb_find(br, addr, vlan);
@@ -966,17 +941,19 @@ static int fdb_delete_by_addr_and_port(struct net_bridge_port *p,
 		return -ENOENT;
 
 	fdb_delete(br, fdb);
+
 	return 0;
 }
 
-static int __br_fdb_delete(struct net_bridge_port *p,
+static int __br_fdb_delete(struct net_bridge *br,
+			   const struct net_bridge_port *p,
 			   const unsigned char *addr, u16 vid)
 {
 	int err;
 
-	spin_lock_bh(&p->br->hash_lock);
-	err = fdb_delete_by_addr_and_port(p, addr, vid);
-	spin_unlock_bh(&p->br->hash_lock);
+	spin_lock_bh(&br->hash_lock);
+	err = fdb_delete_by_addr_and_port(br, p, addr, vid);
+	spin_unlock_bh(&br->hash_lock);
 
 	return err;
 }
@@ -989,7 +966,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	struct net_bridge_vlan_group *vg;
 	struct net_bridge_port *p = NULL;
 	struct net_bridge_vlan *v;
-	struct net_bridge *br = NULL;
+	struct net_bridge *br;
 	int err;
 
 	if (dev->priv_flags & IFF_EBRIDGE) {
@@ -1003,6 +980,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			return -EINVAL;
 		}
 		vg = nbp_vlan_group(p);
+		br = p->br;
 	}
 
 	if (vid) {
@@ -1012,30 +990,20 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			return -EINVAL;
 		}
 
-		if (dev->priv_flags & IFF_EBRIDGE)
-			err = __br_fdb_delete_by_addr(br, addr, vid);
-		else
-			err = __br_fdb_delete(p, addr, vid);
+		err = __br_fdb_delete(br, p, addr, vid);
 	} else {
 		err = -ENOENT;
-		if (dev->priv_flags & IFF_EBRIDGE)
-			err = __br_fdb_delete_by_addr(br, addr, 0);
-		else
-			err &= __br_fdb_delete(p, addr, 0);
-
+		err &= __br_fdb_delete(br, p, addr, 0);
 		if (!vg || !vg->num_vlans)
-			goto out;
+			return err;
 
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			if (!br_vlan_should_use(v))
 				continue;
-			if (dev->priv_flags & IFF_EBRIDGE)
-				err = __br_fdb_delete_by_addr(br, addr, v->vid);
-			else
-				err &= __br_fdb_delete(p, addr, v->vid);
+			err &= __br_fdb_delete(br, p, addr, v->vid);
 		}
 	}
-out:
+
 	return err;
 }
 
-- 
2.1.4
