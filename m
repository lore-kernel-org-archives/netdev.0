From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCHv2 bridge 5/7] bridge: Add vlan support to static neighbors
Date: Wed, 19 Sep 2012 08:42:14 -0400
Message-ID: <1348058536-22607-6-git-send-email-vyasevic@redhat.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23016 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756389Ab2ISMmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 08:42:22 -0400
In-Reply-To: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 include/linux/neighbour.h |    2 +-
 net/bridge/br_fdb.c       |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index 275e5d6..044df8f 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -7,7 +7,7 @@
 struct ndmsg {
 	__u8		ndm_family;
 	__u8		ndm_pad1;
-	__u16		ndm_pad2;
+	__u16		ndm_vlan;
 	__s32		ndm_ifindex;
 	__u16		ndm_state;
 	__u8		ndm_flags;
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e17f9f2..3c21a3d 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -493,7 +493,7 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	ndm = nlmsg_data(nlh);
 	ndm->ndm_family	 = AF_BRIDGE;
 	ndm->ndm_pad1    = 0;
-	ndm->ndm_pad2    = 0;
+	ndm->ndm_vlan    = fdb->vlan_id;
 	ndm->ndm_flags	 = 0;
 	ndm->ndm_type	 = 0;
 	ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
@@ -640,25 +640,25 @@ int br_fdb_add(struct ndmsg *ndm, struct net_device *dev,
 
 	if (ndm->ndm_flags & NTF_USE) {
 		rcu_read_lock();
-		br_fdb_update(p->br, p, addr, 0);
+		br_fdb_update(p->br, p, addr, ndm->ndm_vlan);
 		rcu_read_unlock();
 	} else {
 		spin_lock_bh(&p->br->hash_lock);
 		err = fdb_add_entry(p, addr, ndm->ndm_state, nlh_flags,
-				0);
+				ndm->ndm_vlan);
 		spin_unlock_bh(&p->br->hash_lock);
 	}
 
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge_port *p, u8 *addr)
+static int fdb_delete_by_addr(struct net_bridge_port *p, u8 *addr, u16 vlan)
 {
 	struct net_bridge *br = p->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, 0)];
 	struct net_bridge_fdb_entry *fdb;
 
-	fdb = fdb_find(head, addr, 0);
+	fdb = fdb_find(head, addr, vlan);
 	if (!fdb)
 		return -ENOENT;
 
@@ -681,7 +681,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
 	}
 
 	spin_lock_bh(&p->br->hash_lock);
-	err = fdb_delete_by_addr(p, addr);
+	err = fdb_delete_by_addr(p, addr, ndm->ndm_vlan);
 	spin_unlock_bh(&p->br->hash_lock);
 
 	return err;
-- 
1.7.7.6
