From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 06/19] net: bridge: Receive notification about successful FDB offload
Date: Thu,  8 Jun 2017 08:44:15 +0200
Message-ID: <20170608064428.4785-7-jiri@resnulli.us>
References: <20170608064428.4785-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36299 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdFHGok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:44:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id d17so821908wme.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:44:40 -0700 (PDT)
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

When a new static FDB is added to the bridge a notification is sent to
the driver for offload. In case of successful offload the driver should
notify the bridge back, which in turn should mark the FDB as offloaded.

Currently, externally learned is equivalent for being offloaded which is
not correct due to the fact that FDBs which are added from user-space are
also marked as externally learned. In order to specify if an FDB was
successfully offloaded a new flag is introduced.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h        |  1 +
 include/uapi/linux/neighbour.h |  1 +
 net/bridge/br.c                | 11 ++++++++++-
 net/bridge/br_fdb.c            | 22 +++++++++++++++++++++-
 net/bridge/br_private.h        |  5 ++++-
 5 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8165ed9..c784a6a 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -159,6 +159,7 @@ enum switchdev_notifier_type {
 	SWITCHDEV_FDB_DEL_TO_BRIDGE,
 	SWITCHDEV_FDB_ADD_TO_DEVICE,
 	SWITCHDEV_FDB_DEL_TO_DEVICE,
+	SWITCHDEV_FDB_OFFLOADED,
 };
 
 struct switchdev_notifier_info {
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index f3d16db..3199d28 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -41,6 +41,7 @@ enum {
 #define NTF_MASTER	0x04
 #define NTF_PROXY	0x08	/* == ATF_PUBL */
 #define NTF_EXT_LEARNED	0x10
+#define NTF_OFFLOADED   0x20
 #define NTF_ROUTER	0x80
 
 /*
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 96d209c..1407d1b 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -142,8 +142,12 @@ static int br_switchdev_event(struct notifier_block *unused,
 		fdb_info = ptr;
 		err = br_fdb_external_learn_add(br, p, fdb_info->addr,
 						fdb_info->vid);
-		if (err)
+		if (err) {
 			err = notifier_from_errno(err);
+			break;
+		}
+		br_fdb_offloaded_set(br, p, fdb_info->addr,
+				     fdb_info->vid);
 		break;
 	case SWITCHDEV_FDB_DEL_TO_BRIDGE:
 		fdb_info = ptr;
@@ -152,6 +156,11 @@ static int br_switchdev_event(struct notifier_block *unused,
 		if (err)
 			err = notifier_from_errno(err);
 		break;
+	case SWITCHDEV_FDB_OFFLOADED:
+		fdb_info = ptr;
+		br_fdb_offloaded_set(br, p, fdb_info->addr,
+				     fdb_info->vid);
+		break;
 	}
 
 out:
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 26a1dae..fef7872 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -511,6 +511,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 		fdb->is_static = is_static;
 		fdb->added_by_user = 0;
 		fdb->added_by_external_learn = 0;
+		fdb->offloaded = 0;
 		fdb->updated = fdb->used = jiffies;
 		hlist_add_head_rcu(&fdb->hlist, head);
 	}
@@ -647,11 +648,16 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	ndm->ndm_family	 = AF_BRIDGE;
 	ndm->ndm_pad1    = 0;
 	ndm->ndm_pad2    = 0;
-	ndm->ndm_flags	 = fdb->added_by_external_learn ? NTF_EXT_LEARNED : 0;
+	ndm->ndm_flags	 = 0;
 	ndm->ndm_type	 = 0;
 	ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
 	ndm->ndm_state   = fdb_to_nud(br, fdb);
 
+	if (fdb->offloaded)
+		ndm->ndm_flags |= NTF_OFFLOADED;
+	if (fdb->added_by_external_learn)
+		ndm->ndm_flags |= NTF_EXT_LEARNED;
+
 	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr))
 		goto nla_put_failure;
 	if (nla_put_u32(skb, NDA_MASTER, br->dev->ifindex))
@@ -1123,3 +1129,17 @@ int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 
 	return err;
 }
+
+void br_fdb_offloaded_set(struct net_bridge *br, struct net_bridge_port *p,
+			  const unsigned char *addr, u16 vid)
+{
+	struct net_bridge_fdb_entry *fdb;
+
+	spin_lock_bh(&br->hash_lock);
+
+	fdb = br_fdb_find(br, addr, vid);
+	if (fdb)
+		fdb->offloaded = 1;
+
+	spin_unlock_bh(&br->hash_lock);
+}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 98410ea..c18682f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -169,7 +169,8 @@ struct net_bridge_fdb_entry {
 	unsigned char			is_local:1,
 					is_static:1,
 					added_by_user:1,
-					added_by_external_learn:1;
+					added_by_external_learn:1,
+					offloaded:1;
 
 	/* write-heavy members should not affect lookups */
 	unsigned long			updated ____cacheline_aligned_in_smp;
@@ -536,6 +537,8 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
 int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
+void br_fdb_offloaded_set(struct net_bridge *br, struct net_bridge_port *p,
+			  const unsigned char *addr, u16 vid);
 
 /* br_forward.c */
 enum br_pkt_type {
-- 
2.9.3
