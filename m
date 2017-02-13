From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] bridge: fdb: add proper lock checks in searching functions
Date: Mon, 13 Feb 2017 14:59:10 +0100
Message-ID: <1486994351-1137-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1486994351-1137-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33143 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752656AbdBMOAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:00:15 -0500
Received: by mail-wm0-f44.google.com with SMTP id t18so6715152wmt.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 06:00:10 -0800 (PST)
In-Reply-To: <1486994351-1137-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to avoid new errors add checks to br_fdb_find and fdb_find_rcu
functions. The first requires hash_lock, the second obviously RCU.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_fdb.c     | 4 ++++
 net/bridge/br_private.h | 9 +++++++++
 2 files changed, 13 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 04a53a0b733d..da5ed7d0a3c8 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -89,6 +89,8 @@ static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
 {
 	struct net_bridge_fdb_entry *f;
 
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
 	hlist_for_each_entry_rcu(f, head, hlist)
 		if (ether_addr_equal(f->addr.addr, addr) && f->vlan_id == vid)
 			break;
@@ -104,6 +106,8 @@ static struct net_bridge_fdb_entry *br_fdb_find(struct net_bridge *br,
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
 
+	WARN_ON_ONCE(!br_hash_lock_held(br));
+
 	rcu_read_lock();
 	fdb = fdb_find_rcu(head, addr, vid);
 	rcu_read_unlock();
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 61368186edea..2288fca7756c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -531,6 +531,15 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
 
+static inline bool br_hash_lock_held(struct net_bridge *br)
+{
+#ifdef CONFIG_LOCKDEP
+	return lockdep_is_held(&br->hash_lock);
+#else
+	return true;
+#endif
+}
+
 /* br_forward.c */
 enum br_pkt_type {
 	BR_PKT_UNICAST,
-- 
2.1.4
