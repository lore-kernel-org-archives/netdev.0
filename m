From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/3] bridge: rearrange fdb notifications
Date: Tue, 06 Dec 2011 15:02:25 -0800
Message-ID: <20111206230316.026471682@vyatta.com>
References: <20111206230223.191544130@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:49455 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753874Ab1LFXFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 18:05:48 -0500
Content-Disposition: inline; filename=br-notify-refactor.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass bridge to fdb_notify so it can determine correct namespace based
on namespace of bridge rather than namespace of destination port.
Also makes next patch easier.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_fdb.c	2011-12-06 15:01:23.656521166 -0800
+++ b/net/bridge/br_fdb.c	2011-12-06 15:02:12.448870810 -0800
@@ -28,7 +28,8 @@
 static struct kmem_cache *br_fdb_cache __read_mostly;
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		      const unsigned char *addr);
-static void fdb_notify(const struct net_bridge_fdb_entry *, int);
+static void fdb_notify(struct net_bridge *br,
+		       const struct net_bridge_fdb_entry *, int);
 
 static u32 fdb_salt __read_mostly;
 
@@ -80,10 +81,10 @@ static void fdb_rcu_free(struct rcu_head
 	kmem_cache_free(br_fdb_cache, ent);
 }
 
-static inline void fdb_delete(struct net_bridge_fdb_entry *f)
+static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 {
-	fdb_notify(f, RTM_DELNEIGH);
 	hlist_del_rcu(&f->hlist);
+	fdb_notify(br, f, RTM_DELNEIGH);
 	call_rcu(&f->rcu, fdb_rcu_free);
 }
 
@@ -114,7 +115,7 @@ void br_fdb_changeaddr(struct net_bridge
 				}
 
 				/* delete old one */
-				fdb_delete(f);
+				fdb_delete(br, f);
 				goto insert;
 			}
 		}
@@ -144,7 +145,7 @@ void br_fdb_cleanup(unsigned long _data)
 				continue;
 			this_timer = f->updated + delay;
 			if (time_before_eq(this_timer, jiffies))
-				fdb_delete(f);
+				fdb_delete(br, f);
 			else if (time_before(this_timer, next_timer))
 				next_timer = this_timer;
 		}
@@ -165,7 +166,7 @@ void br_fdb_flush(struct net_bridge *br)
 		struct hlist_node *h, *n;
 		hlist_for_each_entry_safe(f, h, n, &br->hash[i], hlist) {
 			if (!f->is_static)
-				fdb_delete(f);
+				fdb_delete(br, f);
 		}
 	}
 	spin_unlock_bh(&br->hash_lock);
@@ -209,7 +210,7 @@ void br_fdb_delete_by_port(struct net_br
 				}
 			}
 
-			fdb_delete(f);
+			fdb_delete(br, f);
 		skip_delete: ;
 		}
 	}
@@ -370,7 +371,7 @@ static int fdb_insert(struct net_bridge
 		br_warn(br, "adding interface %s with same address "
 		       "as a received packet\n",
 		       source->dev->name);
-		fdb_delete(fdb);
+		fdb_delete(br, fdb);
 	}
 
 	fdb = fdb_create(head, source, addr);
@@ -378,7 +379,7 @@ static int fdb_insert(struct net_bridge
 		return -ENOMEM;
 
 	fdb->is_local = fdb->is_static = 1;
-	fdb_notify(fdb, RTM_NEWNEIGH);
+	fdb_notify(br, fdb, RTM_NEWNEIGH);
 	return 0;
 }
 
@@ -493,9 +494,10 @@ static inline size_t fdb_nlmsg_size(void
 		+ nla_total_size(sizeof(struct nda_cacheinfo));
 }
 
-static void fdb_notify(const struct net_bridge_fdb_entry *fdb, int type)
+static void fdb_notify(struct net_bridge *br,
+		       const struct net_bridge_fdb_entry *fdb, int type)
 {
-	struct net *net = dev_net(fdb->dst->dev);
+	struct net *net = dev_net(br->dev);
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
@@ -574,7 +576,7 @@ static int fdb_add_entry(struct net_brid
 		fdb = fdb_create(head, source, addr);
 		if (!fdb)
 			return -ENOMEM;
-		fdb_notify(fdb, RTM_NEWNEIGH);
+		fdb_notify(br, fdb, RTM_NEWNEIGH);
 	} else {
 		if (flags & NLM_F_EXCL)
 			return -EEXIST;
@@ -590,7 +592,7 @@ static int fdb_add_entry(struct net_brid
 			fdb->is_local = fdb->is_static = 0;
 
 		fdb->updated = fdb->used = jiffies;
-		fdb_notify(fdb, RTM_NEWNEIGH);
+		fdb_notify(br, fdb, RTM_NEWNEIGH);
 	}
 
 	return 0;
@@ -670,7 +672,7 @@ static int fdb_delete_by_addr(struct net
 	if (!fdb)
 		return -ENOENT;
 
-	fdb_delete(fdb);
+	fdb_delete(p->br, fdb);
 	return 0;
 }
 
