From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH] Notify userspace about bridge learning MAC on new
	port
Date: Wed, 12 Mar 2014 14:14:56 +0100
Message-ID: <1394630096-14239-1-git-send-email-michael-dev@fami-braun.de>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Michael Braun <michael-dev@fami-braun.de>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

Currently, the userspace is informed about the port the MAC is learned on a
bridge and about the bridge removing the MAC from its forwarding table, but not
when the MAC is learned on a different port.
This is inconsistent and makes it difficult for applications to keep track
of all MACs learned by a bridge on a subset of its ports.

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Cc: <bridge@lists.linux-foundation.org>
Cc: <netdev@vger.kernel.org>
---
 net/bridge/br_fdb.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9203d5a..25a7772 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -487,6 +487,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
+	struct net_bridge_port *origsrc;
 
 	/* some users want to always flood. */
 	if (hold_time(br) == 0)
@@ -507,10 +508,14 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 					source->dev->name);
 		} else {
 			/* fastpath: update of existing entry */
+			origsrc = fdb->dst;
 			fdb->dst = source;
 			fdb->updated = jiffies;
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
+			/* notify applications of modified slave device */
+			if (origsrc != source)
+				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
 	} else {
 		spin_lock(&br->hash_lock);
-- 
1.8.3.2
