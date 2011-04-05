From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/7] bridge: track last used time in forwarding table
Date: Mon, 04 Apr 2011 17:03:28 -0700
Message-ID: <20110405000537.094334160@vyatta.com>
References: <20110405000326.714524584@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42821 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812Ab1DEAJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 20:09:49 -0400
Content-Disposition: inline; filename=br-fdb-used.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds tracking the last used time in forwarding table.
Rename ageing_timer to updated to better describe it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_fdb.c     |   10 +++++-----
 net/bridge/br_input.c   |    5 +++--
 net/bridge/br_private.h |    3 ++-
 3 files changed, 10 insertions(+), 8 deletions(-)

--- a/net/bridge/br_fdb.c	2011-04-03 09:39:13.000000000 -0700
+++ b/net/bridge/br_fdb.c	2011-04-03 09:39:21.221199041 -0700
@@ -62,7 +62,7 @@ static inline int has_expired(const stru
 				  const struct net_bridge_fdb_entry *fdb)
 {
 	return !fdb->is_static &&
-		time_before_eq(fdb->ageing_timer + hold_time(br), jiffies);
+		time_before_eq(fdb->updated + hold_time(br), jiffies);
 }
 
 static inline int br_mac_hash(const unsigned char *mac)
@@ -140,7 +140,7 @@ void br_fdb_cleanup(unsigned long _data)
 			unsigned long this_timer;
 			if (f->is_static)
 				continue;
-			this_timer = f->ageing_timer + delay;
+			this_timer = f->updated + delay;
 			if (time_before_eq(this_timer, jiffies))
 				fdb_delete(f);
 			else if (time_before(this_timer, next_timer))
@@ -293,7 +293,7 @@ int br_fdb_fillbuf(struct net_bridge *br
 
 			fe->is_local = f->is_local;
 			if (!f->is_static)
-				fe->ageing_timer_value = jiffies_to_clock_t(jiffies - f->ageing_timer);
+				fe->ageing_timer_value = jiffies_to_clock_t(jiffies - f->updated);
 			++fe;
 			++num;
 		}
@@ -330,7 +330,7 @@ static struct net_bridge_fdb_entry *fdb_
 		fdb->dst = source;
 		fdb->is_local = 0;
 		fdb->is_static = 0;
-		fdb->ageing_timer = jiffies;
+		fdb->updated = fdb->used = jiffies;
 		hlist_add_head_rcu(&fdb->hlist, head);
 	}
 	return fdb;
@@ -404,7 +404,7 @@ void br_fdb_update(struct net_bridge *br
 		} else {
 			/* fastpath: update of existing entry */
 			fdb->dst = source;
-			fdb->ageing_timer = jiffies;
+			fdb->updated = jiffies;
 		}
 	} else {
 		spin_lock(&br->hash_lock);
--- a/net/bridge/br_input.c	2011-04-01 11:30:16.000000000 -0700
+++ b/net/bridge/br_input.c	2011-04-03 09:39:21.221199041 -0700
@@ -98,9 +98,10 @@ int br_handle_frame_finish(struct sk_buf
 	}
 
 	if (skb) {
-		if (dst)
+		if (dst) {
+			dst->used = jiffies;
 			br_forward(dst->dst, skb, skb2);
-		else
+		} else
 			br_flood_forward(br, skb, skb2);
 	}
 
--- a/net/bridge/br_private.h	2011-04-01 11:30:16.000000000 -0700
+++ b/net/bridge/br_private.h	2011-04-03 09:39:21.221199041 -0700
@@ -64,7 +64,8 @@ struct net_bridge_fdb_entry
 	struct net_bridge_port		*dst;
 
 	struct rcu_head			rcu;
-	unsigned long			ageing_timer;
+	unsigned long			updated;
+	unsigned long			used;
 	mac_addr			addr;
 	unsigned char			is_local;
 	unsigned char			is_static;


