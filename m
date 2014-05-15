From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 3/8] bridge: Add functionality to sync static fdb entries to hw
Date: Thu, 15 May 2014 12:56:51 -0400
Message-ID: <1400173016-8952-4-git-send-email-vyasevic@redhat.com>
References: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, john.r.fastabend@intel.com, jhs@mojatatu.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754604AbaEOQ5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 12:57:08 -0400
In-Reply-To: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add code that allows static fdb entires to be synced to the
hw list for a specified port.  This will be used later to
program ports that can function in non-promiscuous mode.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_fdb.c     | 56 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h |  2 ++
 2 files changed, 58 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9203d5a..fe124e5 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -874,3 +874,59 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 out:
 	return err;
 }
+
+int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p)
+{
+	struct net_bridge_fdb_entry *fdb, *tmp;
+	int i;
+	int err;
+
+	ASSERT_RTNL();
+
+	for (i = 0; i < BR_HASH_SIZE; i++) {
+		hlist_for_each_entry(fdb, &br->hash[i], hlist) {
+			/* We only care for static entries */
+			if (!fdb->is_static)
+				continue;
+
+			err = dev_uc_add(p->dev, fdb->addr.addr);
+			if (err)
+				goto rollback;
+		}
+	}
+	return 0;
+
+rollback:
+	for (i = 0; i < BR_HASH_SIZE; i++) {
+		hlist_for_each_entry(tmp, &br->hash[i], hlist) {
+			/* If we reached the fdb that failed, we can stop */
+			if (tmp == fdb)
+				break;
+
+			/* We only care for static entries */
+			if (!tmp->is_static)
+				continue;
+
+			dev_uc_del(p->dev, tmp->addr.addr);
+		}
+	}
+	return err;
+}
+
+void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
+{
+	struct net_bridge_fdb_entry *fdb;
+	int i;
+
+	ASSERT_RTNL();
+
+	for (i = 0; i < BR_HASH_SIZE; i++) {
+		hlist_for_each_entry_rcu(fdb, &br->hash[i], hlist) {
+			/* We only care for static entries */
+			if (!fdb->is_static)
+				continue;
+
+			dev_uc_del(p->dev, fdb->addr.addr);
+		}
+	}
+}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 5ce3191..c0a804b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -399,6 +399,8 @@ int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
 	       const unsigned char *addr, u16 nlh_flags);
 int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		struct net_device *dev, int idx);
+int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
+void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
 
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
-- 
1.9.0
