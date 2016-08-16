From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 05/16] batman-adv: netlink: add translation
	table query
Date: Tue, 16 Aug 2016 10:32:33 +0200
Message-ID: <1471336364-16334-6-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Sven Eckelmann <sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1471336364-16334-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>

This adds the commands BATADV_CMD_GET_TRANSTABLE_LOCAL and
BATADV_CMD_GET_TRANSTABLE_GLOBAL, which correspond to the transtable_local
and transtable_global debugfs files.

The batadv_tt_client_flags enum is moved to the UAPI to expose it as part
of the netlink API.

Signed-off-by: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Signed-off-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
[sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org: add policy for attributes, fix includes]
Signed-off-by: Sven Eckelmann <sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
[sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org: fix VID attributes content]
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
---
 include/uapi/linux/batman_adv.h    |  56 ++++++
 net/batman-adv/netlink.c           |  23 ++-
 net/batman-adv/netlink.h           |   3 +
 net/batman-adv/packet.h            |  36 ----
 net/batman-adv/translation-table.c | 377 +++++++++++++++++++++++++++++++++++++
 net/batman-adv/translation-table.h |   4 +
 6 files changed, 462 insertions(+), 37 deletions(-)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 8abcbca..1168d05 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -23,6 +23,42 @@
 #define BATADV_NL_MCAST_GROUP_TPMETER	"tpmeter"
 
 /**
+ * enum batadv_tt_client_flags - TT client specific flags
+ * @BATADV_TT_CLIENT_DEL: the client has to be deleted from the table
+ * @BATADV_TT_CLIENT_ROAM: the client roamed to/from another node and the new
+ *  update telling its new real location has not been received/sent yet
+ * @BATADV_TT_CLIENT_WIFI: this client is connected through a wifi interface.
+ *  This information is used by the "AP Isolation" feature
+ * @BATADV_TT_CLIENT_ISOLA: this client is considered "isolated". This
+ *  information is used by the Extended Isolation feature
+ * @BATADV_TT_CLIENT_NOPURGE: this client should never be removed from the table
+ * @BATADV_TT_CLIENT_NEW: this client has been added to the local table but has
+ *  not been announced yet
+ * @BATADV_TT_CLIENT_PENDING: this client is marked for removal but it is kept
+ *  in the table for one more originator interval for consistency purposes
+ * @BATADV_TT_CLIENT_TEMP: this global client has been detected to be part of
+ *  the network but no nnode has already announced it
+ *
+ * Bits from 0 to 7 are called _remote flags_ because they are sent on the wire.
+ * Bits from 8 to 15 are called _local flags_ because they are used for local
+ * computations only.
+ *
+ * Bits from 4 to 7 - a subset of remote flags - are ensured to be in sync with
+ * the other nodes in the network. To achieve this goal these flags are included
+ * in the TT CRC computation.
+ */
+enum batadv_tt_client_flags {
+	BATADV_TT_CLIENT_DEL     = (1 << 0),
+	BATADV_TT_CLIENT_ROAM    = (1 << 1),
+	BATADV_TT_CLIENT_WIFI    = (1 << 4),
+	BATADV_TT_CLIENT_ISOLA	 = (1 << 5),
+	BATADV_TT_CLIENT_NOPURGE = (1 << 8),
+	BATADV_TT_CLIENT_NEW     = (1 << 9),
+	BATADV_TT_CLIENT_PENDING = (1 << 10),
+	BATADV_TT_CLIENT_TEMP	 = (1 << 11),
+};
+
+/**
  * enum batadv_nl_attrs - batman-adv netlink attributes
  *
  * @BATADV_ATTR_UNSPEC: unspecified attribute to catch errors
@@ -41,6 +77,14 @@
  * @BATADV_ATTR_TPMETER_COOKIE: session cookie to match tp_meter session
  * @BATADV_ATTR_PAD: attribute used for padding for 64-bit alignment
  * @BATADV_ATTR_ACTIVE: Flag indicating if the hard interface is active
+ * @BATADV_ATTR_TT_ADDRESS: Client MAC address
+ * @BATADV_ATTR_TT_TTVN: Translation table version
+ * @BATADV_ATTR_TT_LAST_TTVN: Previous translation table version
+ * @BATADV_ATTR_TT_CRC32: CRC32 over translation table
+ * @BATADV_ATTR_TT_VID: VLAN ID
+ * @BATADV_ATTR_TT_FLAGS: Translation table client flags
+ * @BATADV_ATTR_FLAG_BEST: Flags indicating entry is the best
+ * @BATADV_ATTR_LAST_SEEN_MSECS: Time in milliseconds since last seen
  * @__BATADV_ATTR_AFTER_LAST: internal use
  * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
  * @BATADV_ATTR_MAX: highest attribute number currently defined
@@ -62,6 +106,14 @@ enum batadv_nl_attrs {
 	BATADV_ATTR_TPMETER_COOKIE,
 	BATADV_ATTR_PAD,
 	BATADV_ATTR_ACTIVE,
+	BATADV_ATTR_TT_ADDRESS,
+	BATADV_ATTR_TT_TTVN,
+	BATADV_ATTR_TT_LAST_TTVN,
+	BATADV_ATTR_TT_CRC32,
+	BATADV_ATTR_TT_VID,
+	BATADV_ATTR_TT_FLAGS,
+	BATADV_ATTR_FLAG_BEST,
+	BATADV_ATTR_LAST_SEEN_MSECS,
 	/* add attributes above here, update the policy in netlink.c */
 	__BATADV_ATTR_AFTER_LAST,
 	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
@@ -77,6 +129,8 @@ enum batadv_nl_attrs {
  * @BATADV_CMD_TP_METER_CANCEL: Cancel a tp meter session
  * @BATADV_CMD_GET_ROUTING_ALGOS: Query the list of routing algorithms.
  * @BATADV_CMD_GET_HARDIFS: Query list of hard interfaces
+ * @BATADV_CMD_GET_TRANSTABLE_LOCAL: Query list of local translations
+ * @BATADV_CMD_GET_TRANSTABLE_GLOBAL Query list of global translations
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
@@ -87,6 +141,8 @@ enum batadv_nl_commands {
 	BATADV_CMD_TP_METER_CANCEL,
 	BATADV_CMD_GET_ROUTING_ALGOS,
 	BATADV_CMD_GET_HARDIFS,
+	BATADV_CMD_GET_TRANSTABLE_LOCAL,
+	BATADV_CMD_GET_TRANSTABLE_GLOBAL,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 3f872d6..14360ec 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -40,6 +40,7 @@
 #include "hard-interface.h"
 #include "soft-interface.h"
 #include "tp_meter.h"
+#include "translation-table.h"
 
 struct genl_family batadv_netlink_family = {
 	.id = GENL_ID_GENERATE,
@@ -73,6 +74,14 @@ static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_TPMETER_BYTES]	= { .type = NLA_U64 },
 	[BATADV_ATTR_TPMETER_COOKIE]	= { .type = NLA_U32 },
 	[BATADV_ATTR_ACTIVE]		= { .type = NLA_FLAG },
+	[BATADV_ATTR_TT_ADDRESS]	= { .len = ETH_ALEN },
+	[BATADV_ATTR_TT_TTVN]		= { .type = NLA_U8 },
+	[BATADV_ATTR_TT_LAST_TTVN]	= { .type = NLA_U8 },
+	[BATADV_ATTR_TT_CRC32]		= { .type = NLA_U32 },
+	[BATADV_ATTR_TT_VID]		= { .type = NLA_U16 },
+	[BATADV_ATTR_TT_FLAGS]		= { .type = NLA_U32 },
+	[BATADV_ATTR_FLAG_BEST]		= { .type = NLA_FLAG },
+	[BATADV_ATTR_LAST_SEEN_MSECS]	= { .type = NLA_U32 },
 };
 
 /**
@@ -82,7 +91,7 @@ static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
  *
  * Return: interface index, or 0.
  */
-static int
+int
 batadv_netlink_get_ifindex(const struct nlmsghdr *nlh, int attrtype)
 {
 	struct nlattr *attr = nlmsg_find_attr(nlh, GENL_HDRLEN, attrtype);
@@ -530,6 +539,18 @@ static struct genl_ops batadv_netlink_ops[] = {
 		.policy = batadv_netlink_policy,
 		.dumpit = batadv_netlink_dump_hardifs,
 	},
+	{
+		.cmd = BATADV_CMD_GET_TRANSTABLE_LOCAL,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_tt_local_dump,
+	},
+	{
+		.cmd = BATADV_CMD_GET_TRANSTABLE_GLOBAL,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_tt_global_dump,
+	},
 };
 
 /**
diff --git a/net/batman-adv/netlink.h b/net/batman-adv/netlink.h
index b399f49..52eb162 100644
--- a/net/batman-adv/netlink.h
+++ b/net/batman-adv/netlink.h
@@ -23,8 +23,11 @@
 #include <linux/types.h>
 #include <net/genetlink.h>
 
+struct nlmsghdr;
+
 void batadv_netlink_register(void);
 void batadv_netlink_unregister(void);
+int batadv_netlink_get_ifindex(const struct nlmsghdr *nlh, int attrtype);
 
 int batadv_netlink_tpmeter_notify(struct batadv_priv *bat_priv, const u8 *dst,
 				  u8 result, u32 test_time, u64 total_bytes,
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 6b011ff..6afc0b8 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -129,42 +129,6 @@ enum batadv_tt_data_flags {
 };
 
 /**
- * enum batadv_tt_client_flags - TT client specific flags
- * @BATADV_TT_CLIENT_DEL: the client has to be deleted from the table
- * @BATADV_TT_CLIENT_ROAM: the client roamed to/from another node and the new
- *  update telling its new real location has not been received/sent yet
- * @BATADV_TT_CLIENT_WIFI: this client is connected through a wifi interface.
- *  This information is used by the "AP Isolation" feature
- * @BATADV_TT_CLIENT_ISOLA: this client is considered "isolated". This
- *  information is used by the Extended Isolation feature
- * @BATADV_TT_CLIENT_NOPURGE: this client should never be removed from the table
- * @BATADV_TT_CLIENT_NEW: this client has been added to the local table but has
- *  not been announced yet
- * @BATADV_TT_CLIENT_PENDING: this client is marked for removal but it is kept
- *  in the table for one more originator interval for consistency purposes
- * @BATADV_TT_CLIENT_TEMP: this global client has been detected to be part of
- *  the network but no nnode has already announced it
- *
- * Bits from 0 to 7 are called _remote flags_ because they are sent on the wire.
- * Bits from 8 to 15 are called _local flags_ because they are used for local
- * computations only.
- *
- * Bits from 4 to 7 - a subset of remote flags - are ensured to be in sync with
- * the other nodes in the network. To achieve this goal these flags are included
- * in the TT CRC computation.
- */
-enum batadv_tt_client_flags {
-	BATADV_TT_CLIENT_DEL     = BIT(0),
-	BATADV_TT_CLIENT_ROAM    = BIT(1),
-	BATADV_TT_CLIENT_WIFI    = BIT(4),
-	BATADV_TT_CLIENT_ISOLA	 = BIT(5),
-	BATADV_TT_CLIENT_NOPURGE = BIT(8),
-	BATADV_TT_CLIENT_NEW     = BIT(9),
-	BATADV_TT_CLIENT_PENDING = BIT(10),
-	BATADV_TT_CLIENT_TEMP	 = BIT(11),
-};
-
-/**
  * enum batadv_vlan_flags - flags for the four MSB of any vlan ID field
  * @BATADV_VLAN_HAS_TAG: whether the field contains a valid vlan tag or not
  */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index af2bfef..2080407 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -37,20 +37,27 @@
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
+#include <linux/netlink.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
 #include <linux/seq_file.h>
+#include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
 #include <linux/workqueue.h>
+#include <net/genetlink.h>
+#include <net/netlink.h>
+#include <net/sock.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "bridge_loop_avoidance.h"
 #include "hard-interface.h"
 #include "hash.h"
 #include "log.h"
 #include "multicast.h"
+#include "netlink.h"
 #include "originator.h"
 #include "packet.h"
 #include "soft-interface.h"
@@ -1108,6 +1115,164 @@ out:
 	return 0;
 }
 
+/**
+ * batadv_tt_local_dump_entry - Dump one TT local entry into a message
+ * @msg :Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @common: tt local & tt global common data
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_tt_local_dump_entry(struct sk_buff *msg, u32 portid, u32 seq,
+			   struct batadv_priv *bat_priv,
+			   struct batadv_tt_common_entry *common)
+{
+	void *hdr;
+	struct batadv_softif_vlan *vlan;
+	struct batadv_tt_local_entry *local;
+	unsigned int last_seen_msecs;
+	u32 crc;
+
+	local = container_of(common, struct batadv_tt_local_entry, common);
+	last_seen_msecs = jiffies_to_msecs(jiffies - local->last_seen);
+
+	vlan = batadv_softif_vlan_get(bat_priv, common->vid);
+	if (!vlan)
+		return 0;
+
+	crc = vlan->tt.crc;
+
+	batadv_softif_vlan_put(vlan);
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family,
+			  NLM_F_MULTI,
+			  BATADV_CMD_GET_TRANSTABLE_LOCAL);
+	if (!hdr)
+		return -ENOBUFS;
+
+	if (nla_put(msg, BATADV_ATTR_TT_ADDRESS, ETH_ALEN, common->addr) ||
+	    nla_put_u32(msg, BATADV_ATTR_TT_CRC32, crc) ||
+	    nla_put_u16(msg, BATADV_ATTR_TT_VID, common->vid) ||
+	    nla_put_u32(msg, BATADV_ATTR_TT_FLAGS, common->flags))
+		goto nla_put_failure;
+
+	if (!(common->flags & BATADV_TT_CLIENT_NOPURGE) &&
+	    nla_put_u32(msg, BATADV_ATTR_LAST_SEEN_MSECS, last_seen_msecs))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+ nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+/**
+ * batadv_tt_local_dump_bucket - Dump one TT local bucket into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @head: Pointer to the list containing the local tt entries
+ * @idx_s: Number of entries to skip
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_tt_local_dump_bucket(struct sk_buff *msg, u32 portid, u32 seq,
+			    struct batadv_priv *bat_priv,
+			    struct hlist_head *head, int *idx_s)
+{
+	struct batadv_tt_common_entry *common;
+	int idx = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(common, head, hash_entry) {
+		if (idx++ < *idx_s)
+			continue;
+
+		if (batadv_tt_local_dump_entry(msg, portid, seq, bat_priv,
+					       common)) {
+			rcu_read_unlock();
+			*idx_s = idx - 1;
+			return -EMSGSIZE;
+		}
+	}
+	rcu_read_unlock();
+
+	*idx_s = 0;
+	return 0;
+}
+
+/**
+ * batadv_tt_local_dump - Dump TT local entries into a message
+ * @msg: Netlink message to dump into
+ * @cb: Parameters from query
+ *
+ * Return: Error code, or 0 on success
+ */
+int batadv_tt_local_dump(struct sk_buff *msg, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(cb->skb->sk);
+	struct net_device *soft_iface;
+	struct batadv_priv *bat_priv;
+	struct batadv_hard_iface *primary_if = NULL;
+	struct batadv_hashtable *hash;
+	struct hlist_head *head;
+	int ret;
+	int ifindex;
+	int bucket = cb->args[0];
+	int idx = cb->args[1];
+	int portid = NETLINK_CB(cb->skb).portid;
+
+	ifindex = batadv_netlink_get_ifindex(cb->nlh, BATADV_ATTR_MESH_IFINDEX);
+	if (!ifindex)
+		return -EINVAL;
+
+	soft_iface = dev_get_by_index(net, ifindex);
+	if (!soft_iface || !batadv_softif_is_valid(soft_iface)) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	bat_priv = netdev_priv(soft_iface);
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if || primary_if->if_status != BATADV_IF_ACTIVE) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	hash = bat_priv->tt.local_hash;
+
+	while (bucket < hash->size) {
+		head = &hash->table[bucket];
+
+		if (batadv_tt_local_dump_bucket(msg, portid, cb->nlh->nlmsg_seq,
+						bat_priv, head, &idx))
+			break;
+
+		bucket++;
+	}
+
+	ret = msg->len;
+
+ out:
+	if (primary_if)
+		batadv_hardif_put(primary_if);
+	if (soft_iface)
+		dev_put(soft_iface);
+
+	cb->args[0] = bucket;
+	cb->args[1] = idx;
+
+	return ret;
+}
+
 static void
 batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
 			    struct batadv_tt_local_entry *tt_local_entry,
@@ -1756,6 +1921,218 @@ out:
 }
 
 /**
+ * batadv_tt_global_dump_subentry - Dump all TT local entries into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @common: tt local & tt global common data
+ * @orig: Originator node announcing a non-mesh client
+ * @best: Is the best originator for the TT entry
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_tt_global_dump_subentry(struct sk_buff *msg, u32 portid, u32 seq,
+			       struct batadv_tt_common_entry *common,
+			       struct batadv_tt_orig_list_entry *orig,
+			       bool best)
+{
+	void *hdr;
+	struct batadv_orig_node_vlan *vlan;
+	u8 last_ttvn;
+	u32 crc;
+
+	vlan = batadv_orig_node_vlan_get(orig->orig_node,
+					 common->vid);
+	if (!vlan)
+		return 0;
+
+	crc = vlan->tt.crc;
+
+	batadv_orig_node_vlan_put(vlan);
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family,
+			  NLM_F_MULTI,
+			  BATADV_CMD_GET_TRANSTABLE_GLOBAL);
+	if (!hdr)
+		return -ENOBUFS;
+
+	last_ttvn = atomic_read(&orig->orig_node->last_ttvn);
+
+	if (nla_put(msg, BATADV_ATTR_TT_ADDRESS, ETH_ALEN, common->addr) ||
+	    nla_put(msg, BATADV_ATTR_ORIG_ADDRESS, ETH_ALEN,
+		    orig->orig_node->orig) ||
+	    nla_put_u8(msg, BATADV_ATTR_TT_TTVN, orig->ttvn) ||
+	    nla_put_u8(msg, BATADV_ATTR_TT_LAST_TTVN, last_ttvn) ||
+	    nla_put_u32(msg, BATADV_ATTR_TT_CRC32, crc) ||
+	    nla_put_u16(msg, BATADV_ATTR_TT_VID, common->vid) ||
+	    nla_put_u32(msg, BATADV_ATTR_TT_FLAGS, common->flags))
+		goto nla_put_failure;
+
+	if (best && nla_put_flag(msg, BATADV_ATTR_FLAG_BEST))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+ nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+/**
+ * batadv_tt_global_dump_entry - Dump one TT global entry into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @common: tt local & tt global common data
+ * @sub_s: Number of entries to skip
+ *
+ * This function assumes the caller holds rcu_read_lock().
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_tt_global_dump_entry(struct sk_buff *msg, u32 portid, u32 seq,
+			    struct batadv_priv *bat_priv,
+			    struct batadv_tt_common_entry *common, int *sub_s)
+{
+	struct batadv_tt_orig_list_entry *orig_entry, *best_entry;
+	struct batadv_tt_global_entry *global;
+	struct hlist_head *head;
+	int sub = 0;
+	bool best;
+
+	global = container_of(common, struct batadv_tt_global_entry, common);
+	best_entry = batadv_transtable_best_orig(bat_priv, global);
+	head = &global->orig_list;
+
+	hlist_for_each_entry_rcu(orig_entry, head, list) {
+		if (sub++ < *sub_s)
+			continue;
+
+		best = (orig_entry == best_entry);
+
+		if (batadv_tt_global_dump_subentry(msg, portid, seq, common,
+						   orig_entry, best)) {
+			*sub_s = sub - 1;
+			return -EMSGSIZE;
+		}
+	}
+
+	*sub_s = 0;
+	return 0;
+}
+
+/**
+ * batadv_tt_global_dump_bucket - Dump one TT local bucket into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @head: Pointer to the list containing the global tt entries
+ * @idx_s: Number of entries to skip
+ * @sub: Number of entries to skip
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_tt_global_dump_bucket(struct sk_buff *msg, u32 portid, u32 seq,
+			     struct batadv_priv *bat_priv,
+			     struct hlist_head *head, int *idx_s, int *sub)
+{
+	struct batadv_tt_common_entry *common;
+	int idx = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(common, head, hash_entry) {
+		if (idx++ < *idx_s)
+			continue;
+
+		if (batadv_tt_global_dump_entry(msg, portid, seq, bat_priv,
+						common, sub)) {
+			rcu_read_unlock();
+			*idx_s = idx - 1;
+			return -EMSGSIZE;
+		}
+	}
+	rcu_read_unlock();
+
+	*idx_s = 0;
+	*sub = 0;
+	return 0;
+}
+
+/**
+ * batadv_tt_global_dump -  Dump TT global entries into a message
+ * @msg: Netlink message to dump into
+ * @cb: Parameters from query
+ *
+ * Return: Error code, or length of message on success
+ */
+int batadv_tt_global_dump(struct sk_buff *msg, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(cb->skb->sk);
+	struct net_device *soft_iface;
+	struct batadv_priv *bat_priv;
+	struct batadv_hard_iface *primary_if = NULL;
+	struct batadv_hashtable *hash;
+	struct hlist_head *head;
+	int ret;
+	int ifindex;
+	int bucket = cb->args[0];
+	int idx = cb->args[1];
+	int sub = cb->args[2];
+	int portid = NETLINK_CB(cb->skb).portid;
+
+	ifindex = batadv_netlink_get_ifindex(cb->nlh, BATADV_ATTR_MESH_IFINDEX);
+	if (!ifindex)
+		return -EINVAL;
+
+	soft_iface = dev_get_by_index(net, ifindex);
+	if (!soft_iface || !batadv_softif_is_valid(soft_iface)) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	bat_priv = netdev_priv(soft_iface);
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if || primary_if->if_status != BATADV_IF_ACTIVE) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	hash = bat_priv->tt.global_hash;
+
+	while (bucket < hash->size) {
+		head = &hash->table[bucket];
+
+		if (batadv_tt_global_dump_bucket(msg, portid,
+						 cb->nlh->nlmsg_seq, bat_priv,
+						 head, &idx, &sub))
+			break;
+
+		bucket++;
+	}
+
+	ret = msg->len;
+
+ out:
+	if (primary_if)
+		batadv_hardif_put(primary_if);
+	if (soft_iface)
+		dev_put(soft_iface);
+
+	cb->args[0] = bucket;
+	cb->args[1] = idx;
+	cb->args[2] = sub;
+
+	return ret;
+}
+
+/**
  * _batadv_tt_global_del_orig_entry - remove and free an orig_entry
  * @tt_global_entry: the global entry to remove the orig_entry from
  * @orig_entry: the orig entry to remove and free
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 02b0f85..783fdba 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -22,8 +22,10 @@
 
 #include <linux/types.h>
 
+struct netlink_callback;
 struct net_device;
 struct seq_file;
+struct sk_buff;
 
 int batadv_tt_init(struct batadv_priv *bat_priv);
 bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
@@ -33,6 +35,8 @@ u16 batadv_tt_local_remove(struct batadv_priv *bat_priv,
 			   const char *message, bool roaming);
 int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_tt_local_dump(struct sk_buff *msg, struct netlink_callback *cb);
+int batadv_tt_global_dump(struct sk_buff *msg, struct netlink_callback *cb);
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
 			       s32 match_vid, const char *message);
-- 
2.8.1
