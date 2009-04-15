From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH 2/3] net: bridge: use device address list instead of
	dev_addr
Date: Wed, 15 Apr 2009 10:21:18 +0200
Message-ID: <20090415082118.GC21342@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com,
	ivecera@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54060 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756888AbZDOIWq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 04:22:46 -0400
Content-Disposition: inline
In-Reply-To: <20090415081720.GA21342@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the handling of mac addresses of bridge port devices. Now
it uses previously introduced list of device addresses. It allows the bridge to
know more then one local mac address per port which is mandatory for the right
work in some cases.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/bridge/br_fdb.c     |  101 ++++++++++++++++++++++++++++++----------------
 net/bridge/br_if.c      |    2 +-
 net/bridge/br_notify.c  |    2 +-
 net/bridge/br_private.h |    4 +-
 4 files changed, 70 insertions(+), 39 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index a48f5ef..1e63f76 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -77,10 +77,26 @@ static inline void fdb_delete(struct net_bridge_fdb_entry *f)
 	br_fdb_put(f);
 }
 
-void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
+static bool another_port_has_addr(const struct net_bridge_port *p,
+				  struct net_bridge_fdb_entry *f)
+{
+	struct net_bridge *br = p->br;
+	struct net_bridge_port *op;
+
+	list_for_each_entry(op, &br->port_list, list) {
+		if (op != p && is_etherdev_addr(op->dev, f->addr.addr)) {
+			f->dst = op;
+			return 1;
+		}
+	}
+	return 0;
+}
+
+void br_fdb_changeaddr(struct net_bridge_port *p, struct net_device *dev)
 {
 	struct net_bridge *br = p->br;
 	int i;
+	struct netdev_hw_addr *ha;
 
 	spin_lock_bh(&br->hash_lock);
 
@@ -92,26 +108,23 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 
 			f = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 			if (f->dst == p && f->is_local) {
-				/* maybe another port has same hw addr? */
-				struct net_bridge_port *op;
-				list_for_each_entry(op, &br->port_list, list) {
-					if (op != p &&
-					    !compare_ether_addr(op->dev->dev_addr,
-								f->addr.addr)) {
-						f->dst = op;
-						goto insert;
-					}
-				}
-
-				/* delete old one */
-				fdb_delete(f);
-				goto insert;
+				/*
+				 * maybe another port has same hw addr?,
+				 * if not then delete it
+				 */
+				if (!another_port_has_addr(p, f))
+					fdb_delete(f);
 			}
 		}
 	}
- insert:
-	/* insert new address,  may fail if invalid address or dup. */
-	fdb_insert(br, p, newaddr);
+
+	/* insert device addresses, may fail if invalid address. */
+
+	rcu_read_lock();
+	for_each_dev_addr(dev, ha) {
+		fdb_insert(br, p, ha->addr);
+	}
+	rcu_read_unlock();
 
 	spin_unlock_bh(&br->hash_lock);
 }
@@ -189,20 +202,9 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 			 * then when one port is deleted, assign
 			 * the local entry to other port
 			 */
-			if (f->is_local) {
-				struct net_bridge_port *op;
-				list_for_each_entry(op, &br->port_list, list) {
-					if (op != p &&
-					    !compare_ether_addr(op->dev->dev_addr,
-								f->addr.addr)) {
-						f->dst = op;
-						goto skip_delete;
-					}
-				}
-			}
-
-			fdb_delete(f);
-		skip_delete: ;
+			if (!f->is_local ||
+			    !another_port_has_addr(p, f))
+				fdb_delete(f);
 		}
 	}
 	spin_unlock_bh(&br->hash_lock);
@@ -338,7 +340,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 }
 
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr)
+		      const unsigned char *addr)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
 	struct net_bridge_fdb_entry *fdb;
@@ -366,13 +368,42 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 	return 0;
 }
 
+static int fdb_insert_dev(struct net_bridge *br, struct net_bridge_port *source,
+			  struct net_device *dev)
+{
+	struct netdev_hw_addr *ha, *ha2;
+	struct net_bridge_fdb_entry *fdb;
+	struct hlist_head *head;
+	int ret = 0;
+
+	rcu_read_lock();
+	for_each_dev_addr(dev, ha) {
+		ret = fdb_insert(br, source, ha->addr);
+		if (ret)
+			goto unroll;
+	}
+	goto unlock;
+unroll:
+	for_each_dev_addr(dev, ha2) {
+		if (ha2 == ha)
+			break;
+		head = &br->hash[br_mac_hash(ha2->addr)];
+		fdb = fdb_find(head, ha2->addr);
+		if (fdb && fdb->is_local)
+			fdb_delete(fdb);
+	}
+unlock:
+	rcu_read_unlock();
+	return ret;
+}
+
 int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr)
+		  struct net_device *dev)
 {
 	int ret;
 
 	spin_lock_bh(&br->hash_lock);
-	ret = fdb_insert(br, source, addr);
+	ret = fdb_insert_dev(br, source, dev);
 	spin_unlock_bh(&br->hash_lock);
 	return ret;
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 8a96672..789cb30 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -392,7 +392,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err0;
 
-	err = br_fdb_insert(br, p, dev->dev_addr);
+	err = br_fdb_insert(br, p, dev);
 	if (err)
 		goto err1;
 
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 763a3ec..1423541 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -48,7 +48,7 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 
 	case NETDEV_CHANGEADDR:
 		spin_lock_bh(&br->lock);
-		br_fdb_changeaddr(p, dev->dev_addr);
+		br_fdb_changeaddr(p, dev);
 		br_stp_recalculate_bridge_id(br);
 		spin_unlock_bh(&br->lock);
 		break;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b6c3b71..65ffe3d 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -148,7 +148,7 @@ extern int br_fdb_init(void);
 extern void br_fdb_fini(void);
 extern void br_fdb_flush(struct net_bridge *br);
 extern void br_fdb_changeaddr(struct net_bridge_port *p,
-			      const unsigned char *newaddr);
+			      struct net_device *dev);
 extern void br_fdb_cleanup(unsigned long arg);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
 				  const struct net_bridge_port *p, int do_all);
@@ -161,7 +161,7 @@ extern int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 			  unsigned long count, unsigned long off);
 extern int br_fdb_insert(struct net_bridge *br,
 			 struct net_bridge_port *source,
-			 const unsigned char *addr);
+			 struct net_device *dev);
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
 			  const unsigned char *addr);
-- 
1.6.0.6

