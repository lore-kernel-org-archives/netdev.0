From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 16/24] net: rbridge: Update forwarding database
Date: Wed, 24 Sep 2014 17:52:12 +0200
Message-ID: <1411573940-14079-17-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:45308 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbaIXQDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:10 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

update forwarding database to include nickname information used
in encapsulation and decapsulation
add functions to get and update nickname

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/br_fdb.c     | 40 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h | 11 +++++++++++
 2 files changed, 51 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 6f6c95c..544151f 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -531,8 +531,14 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 	return ret;
 }
 
+#ifdef CONFIG_TRILL
+void br_fdb_update_nick(struct net_bridge *br, struct net_bridge_port *source,
+			const unsigned char *addr, u16 vid, bool added_by_user,
+			uint16_t nick)
+#else
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		   const unsigned char *addr, u16 vid, bool added_by_user)
+#endif
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
@@ -566,6 +572,10 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 				fdb->added_by_user = 1;
 			if (unlikely(fdb_modified))
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
+#ifdef CONFIG_TRILL
+			if (nick != RBRIDGE_NICKNAME_UNUSED)
+				fdb->nick = nick;
+#endif
 		}
 	} else {
 		spin_lock(&br->hash_lock);
@@ -584,6 +594,17 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	}
 }
 
+#ifdef CONFIG_TRILL
+void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
+		   const unsigned char *addr, u16 vid, bool added_by_user)
+{
+	br_fdb_update_nick(br, source, addr, vid, added_by_user,
+			   RBRIDGE_NICKNAME_UNUSED);
+}
+
+#endif
+
+
 static int fdb_to_nud(const struct net_bridge_fdb_entry *fdb)
 {
 	if (fdb->is_local)
@@ -1014,3 +1035,22 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
 		}
 	}
 }
+#ifdef CONFIG_TRILL
+/* get_nick_from_mac: used to get correspondant nick to Mac address
+ * used only on ingress/Egress Rbridge (those how encapsulate
+ * and decapsulate frames)
+ * must be called while encapsulating  to get mac <-> nick correspondance
+ */
+uint16_t get_nick_from_mac(struct net_bridge_port *p, unsigned char *dest,
+			   u16 vid)
+{
+	struct hlist_head *head = &p->br->hash[br_mac_hash(dest, vid)];
+	struct net_bridge_fdb_entry *fdb;
+	if (is_multicast_ether_addr(dest))
+		return RBRIDGE_NICKNAME_NONE;
+	fdb = fdb_find(head, dest, vid);
+	if (likely(fdb))
+		return fdb->nick;
+	return RBRIDGE_NICKNAME_NONE;
+}
+#endif
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2d15b35..37456cf 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -118,6 +118,9 @@ struct net_bridge_fdb_entry
 	unsigned char			is_static;
 	unsigned char			added_by_user;
 	__u16				vlan_id;
+#ifdef CONFIG_TRILL
+	__u16				nick; /* destination's nickname */
+#endif
 };
 
 struct net_bridge_port_group {
@@ -428,6 +431,14 @@ int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		struct net_device *dev, struct net_device *fdev, int idx);
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
 void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
+#ifdef CONFIG_TRILL
+void br_fdb_update_nick(struct net_bridge *br,
+			struct net_bridge_port *source,
+			const unsigned char *addr,
+			u16 vid, bool added_by_user, uint16_t nick);
+uint16_t get_nick_from_mac(struct net_bridge_port *p, unsigned char *dest,
+			   u16 vid);
+#endif
 
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
-- 
1.9.1
