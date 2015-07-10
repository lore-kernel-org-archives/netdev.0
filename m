From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: mdb: add vlan support for user
	entries
Date: Fri, 10 Jul 2015 08:02:08 -0700
Message-ID: <1436540528-42334-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: netdev@vger.kernel.org
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

Until now all user mdb entries were added in vlan 0, this patch adds
support to allow the user to specify the vlan for the entry.
About the uapi change a hole in struct br_mdb_entry is used so the size
and offsets are kept the same (verified with pahole and tested with older
iproute2).

Example:
$ bridge mdb
dev br0 port eth1 grp 239.0.0.1 permanent vlan 2000
dev br0 port eth1 grp 239.0.0.1 permanent vlan 200
dev br0 port eth1 grp 239.0.0.1 permanent

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
note: an iproute2 patch will follow if this one is accepted

 include/uapi/linux/if_bridge.h | 1 +
 net/bridge/br_mdb.c            | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index eaaea6208b42..3635b7797508 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -182,6 +182,7 @@ struct br_mdb_entry {
 #define MDB_TEMPORARY 0
 #define MDB_PERMANENT 1
 	__u8 state;
+	__u16 vid;
 	struct {
 		union {
 			__be32	ip4;
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 1fb7d076f15c..a8d0e93d43f2 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -85,6 +85,7 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 					memset(&e, 0, sizeof(e));
 					e.ifindex = port->dev->ifindex;
 					e.state = p->state;
+					e.vid = p->addr.vid;
 					if (p->addr.proto == htons(ETH_P_IP))
 						e.addr.u.ip4 = p->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -242,6 +243,7 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 	entry.addr.u.ip6 = group->u.ip6;
 #endif
 	entry.state = state;
+	entry.vid = group->vid;
 	__br_mdb_notify(dev, &entry, type);
 }
 
@@ -264,6 +266,8 @@ static bool is_valid_mdb_entry(struct br_mdb_entry *entry)
 		return false;
 	if (entry->state != MDB_PERMANENT && entry->state != MDB_TEMPORARY)
 		return false;
+	if (entry->vid >= VLAN_VID_MASK)
+		return false;
 
 	return true;
 }
@@ -372,6 +376,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
 		return -EINVAL;
 
+	ip.vid = entry->vid;
 	ip.proto = entry->addr.proto;
 	if (ip.proto == htons(ETH_P_IP))
 		ip.u.ip4 = entry->addr.u.ip4;
@@ -418,6 +423,7 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 	if (!netif_running(br->dev) || br->multicast_disabled)
 		return -EINVAL;
 
+	ip.vid = entry->vid;
 	ip.proto = entry->addr.proto;
 	if (ip.proto == htons(ETH_P_IP)) {
 		if (timer_pending(&br->ip4_other_query.timer))
-- 
1.9.1
