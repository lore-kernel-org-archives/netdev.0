From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 3/8] bridge: Add functionality to sync
	static fdb entries to hw
Date: Wed, 14 May 2014 11:09:23 -0400
Message-ID: <1400080168-16625-4-git-send-email-vyasevic@redhat.com>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, mst@redhat.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com,
	john.r.fastabend@intel.com, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Add code that allows static fdb entires to be synced to the
hw list for a specified port.  This will be used later to
program ports that can function in non-promiscuous mode.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_fdb.c     | 56 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h |  2 ++
 2 files changed, 58 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9203d5a..9759b61 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -874,3 +874,59 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 out:
 	return err;
 }
+
+int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p)
+{
+	struct net_bridge_fdb_entry *fdb, *tmp = NULL;
+	int i;
+	int err = 0;
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
index eb906de..712d1e8 100644
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
