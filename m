From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: set is_local and is_static before fdb entry is added to the fdb hashtable
Date: Mon, 26 Oct 2015 21:04:36 -0700
Message-ID: <1445918676-45416-1-git-send-email-roopa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, nikolay@cumulusnetworks.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33989 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbbJ0EEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 00:04:42 -0400
Received: by padhk11 with SMTP id hk11so208905357pad.1
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 21:04:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Problem Description:
We can add fdbs pointing to the bridge with NULL ->dst but that has a
few race conditions because br_fdb_insert() is used which first creates
the fdb and then, after the fdb has been published/linked, sets
"is_local" to 1 and in that time frame if a packet arrives for that fdb
it may see it as non-local and either do a NULL ptr dereference in
br_forward() or attach the fdb to the port where it arrived, and later
br_fdb_insert() will make it local thus getting a wrong fdb entry.
Call chain br_handle_frame_finish() -> br_forward():
But in br_handle_frame_finish() in order to call br_forward() the dst
should not be local i.e. skb != NULL, whenever the dst is
found to be local skb is set to NULL so we can't forward it,
and here comes the problem since it's running only
with RCU when forwarding packets it can see the entry before "is_local"
is set to 1 and actually try to dereference NULL.
The main issue is that if someone sends a packet to the switch while
it's adding the entry which points to the bridge device, it may
dereference NULL ptr. This is needed now after we can add fdbs
pointing to the bridge.  This poses a problem for
br_fdb_update() as well, while someone's adding a bridge fdb, but
before it has is_local == 1, it might get moved to a port if it comes
as a source mac and then it may get its "is_local" set to 1

This patch changes fdb_create to take is_local and is_static as
arguments to set these values in the fdb entry before it is added to the
hash. Also adds null check for port in br_forward.

Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_fdb.c     | 15 ++++++++-------
 net/bridge/br_forward.c |  2 +-
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index c88bd8e..35a1c7e 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -495,7 +495,9 @@ static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
 static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 					       struct net_bridge_port *source,
 					       const unsigned char *addr,
-					       __u16 vid)
+					       __u16 vid,
+					       unsigned char is_local,
+					       unsigned char is_static)
 {
 	struct net_bridge_fdb_entry *fdb;
 
@@ -504,8 +506,8 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 		memcpy(fdb->addr.addr, addr, ETH_ALEN);
 		fdb->dst = source;
 		fdb->vlan_id = vid;
-		fdb->is_local = 0;
-		fdb->is_static = 0;
+		fdb->is_local = is_local;
+		fdb->is_static = is_static;
 		fdb->added_by_user = 0;
 		fdb->added_by_external_learn = 0;
 		fdb->updated = fdb->used = jiffies;
@@ -536,11 +538,10 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		fdb_delete(br, fdb);
 	}
 
-	fdb = fdb_create(head, source, addr, vid);
+	fdb = fdb_create(head, source, addr, vid, 1, 1);
 	if (!fdb)
 		return -ENOMEM;
 
-	fdb->is_local = fdb->is_static = 1;
 	fdb_add_hw_addr(br, addr);
 	fdb_notify(br, fdb, RTM_NEWNEIGH);
 	return 0;
@@ -597,7 +598,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	} else {
 		spin_lock(&br->hash_lock);
 		if (likely(!fdb_find(head, addr, vid))) {
-			fdb = fdb_create(head, source, addr, vid);
+			fdb = fdb_create(head, source, addr, vid, 0, 0);
 			if (fdb) {
 				if (unlikely(added_by_user))
 					fdb->added_by_user = 1;
@@ -774,7 +775,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
 
-		fdb = fdb_create(head, source, addr, vid);
+		fdb = fdb_create(head, source, addr, vid, 0, 0);
 		if (!fdb)
 			return -ENOMEM;
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index a9d424e..fcdb86d 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -141,7 +141,7 @@ EXPORT_SYMBOL_GPL(br_deliver);
 /* called with rcu_read_lock */
 void br_forward(const struct net_bridge_port *to, struct sk_buff *skb, struct sk_buff *skb0)
 {
-	if (should_deliver(to, skb)) {
+	if (to && should_deliver(to, skb)) {
 		if (skb0)
 			deliver_clone(to, skb, __br_forward);
 		else
-- 
1.9.1
