From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 14/21] net: rbridge: update forwarding database
Date: Tue,  1 Sep 2015 17:43:09 +0200
Message-ID: <1441122196-11662-15-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:42867 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752344AbbIAPxk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:40 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

update forwarding database to include nickname information used
in encapsulation and decapsulation
add functions to get and update nickname

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/br_fdb.c     | 41 +++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h | 11 +++++++++++
 2 files changed, 52 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9e9875d..14540f1 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -552,8 +552,14 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
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
@@ -587,6 +593,10 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
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
@@ -605,6 +615,16 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
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
 static int fdb_to_nud(const struct net_bridge_fdb_entry *fdb)
 {
 	if (fdb->is_local)
@@ -1076,3 +1096,24 @@ int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 
 	return err;
 }
+
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
+
+	if (is_multicast_ether_addr(dest))
+		return RBRIDGE_NICKNAME_NONE;
+	fdb = fdb_find(head, dest, vid);
+	if (likely(fdb))
+		return fdb->nick;
+	return RBRIDGE_NICKNAME_NONE;
+}
+#endif
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index ceaf5a9..a62e41e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -120,6 +120,9 @@ struct net_bridge_fdb_entry
 					added_by_user:1,
 					added_by_external_learn:1;
 	__u16				vlan_id;
+#ifdef CONFIG_TRILL
+	__u16				nick; /* destination's nickname */
+#endif
 };
 
 struct net_bridge_port_group {
@@ -436,6 +439,14 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
 int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
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
2.1.4
