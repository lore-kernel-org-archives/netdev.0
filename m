From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bridge: allow updating existing fdb entries
Date: Fri, 30 Sep 2011 17:37:27 -0700
Message-ID: <20111001003835.411004527@vyatta.com>
References: <20111001003725.449204345@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:51639 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752844Ab1JAAkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 20:40:52 -0400
Content-Disposition: inline; filename=bridge-allow-replace-fdb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to allow application to update existing fdb entries that already
exist. This makes bridge netlink neighbor API have same flags and
semantics as ip neighbor table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_fdb.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

--- a/net/bridge/br_fdb.c	2011-09-16 13:12:58.061369744 -0700
+++ b/net/bridge/br_fdb.c	2011-09-30 10:31:57.478241405 -0700
@@ -558,19 +558,28 @@ skip:
 
 /* Create new static fdb entry */
 static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
-			 __u16 state)
+			 __u16 state, __u16 flags)
 {
 	struct net_bridge *br = source->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
 	struct net_bridge_fdb_entry *fdb;
 
 	fdb = fdb_find(head, addr);
-	if (fdb)
-		return -EEXIST;
-
-	fdb = fdb_create(head, source, addr);
-	if (!fdb)
-		return -ENOMEM;
+	if (fdb == NULL) {
+		if (!(flags & NLM_F_CREATE))
+			return -ENOENT;
+
+		fdb = fdb_create(head, source, addr);
+		if (!fdb)
+			return -ENOMEM;
+	} else {
+		if (flags & NLM_F_EXCL)
+			return -EEXIST;
+
+		if (flags & NLM_F_REPLACE)
+			fdb->updated = fdb->used = jiffies;
+		fdb->is_local = fdb->is_static = 0;
+	}
 
 	if (state & NUD_PERMANENT)
 		fdb->is_local = fdb->is_static = 1;
@@ -626,7 +635,7 @@ int br_fdb_add(struct sk_buff *skb, stru
 	}
 
 	spin_lock_bh(&p->br->hash_lock);
-	err = fdb_add_entry(p, addr, ndm->ndm_state);
+	err = fdb_add_entry(p, addr, ndm->ndm_state, nlh->nlmsg_flags);
 	spin_unlock_bh(&p->br->hash_lock);
 
 	return err;
