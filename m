From: Eric Garver <e@erig.me>
Subject: [PATCH net-next v2] openvswitch: add ct_clear action
Date: Tue, 10 Oct 2017 16:54:44 -0400
Message-ID: <20171010205444.20628-1-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This adds a ct_clear action for clearing conntrack state. ct_clear is
currently implemented in OVS userspace, but is not backed by an action
in the kernel datapath. This is useful for flows that may modify a
packet tuple after a ct lookup has already occurred.

Signed-off-by: Eric Garver <e@erig.me>
---
v2:
	- Use IP_CT_UNTRACKED for nf_ct_set()
	- Only fill key if previously conntracked

 include/uapi/linux/openvswitch.h |  2 ++
 net/openvswitch/actions.c        |  4 ++++
 net/openvswitch/conntrack.c      | 11 +++++++++++
 net/openvswitch/conntrack.h      |  7 +++++++
 net/openvswitch/flow_netlink.c   |  5 +++++
 5 files changed, 29 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index efdbfbfd3ee2..0cd6f8833147 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -807,6 +807,7 @@ struct ovs_action_push_eth {
  * packet.
  * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
  * packet.
+ * @OVS_ACTION_ATTR_CT_CLEAR: Clear conntrack state from the packet.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -836,6 +837,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
 	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
 	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
+	OVS_ACTION_ATTR_CT_CLEAR,     /* No argument. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index a54a556fcdb5..a551232daf61 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1203,6 +1203,10 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 				return err == -EINPROGRESS ? 0 : err;
 			break;
 
+		case OVS_ACTION_ATTR_CT_CLEAR:
+			err = ovs_ct_clear(skb, key);
+			break;
+
 		case OVS_ACTION_ATTR_PUSH_ETH:
 			err = push_eth(skb, key, nla_data(a));
 			break;
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index d558e882ca0c..fe861e2f0deb 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -1129,6 +1129,17 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 	return err;
 }
 
+int ovs_ct_clear(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	if (skb_nfct(skb)) {
+		nf_conntrack_put(skb_nfct(skb));
+		nf_ct_set(skb, NULL, IP_CT_UNTRACKED);
+		ovs_ct_fill_key(skb, key);
+	}
+
+	return 0;
+}
+
 static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
 			     const struct sw_flow_key *key, bool log)
 {
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index bc7efd1867ab..399dfdd2c4f9 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -30,6 +30,7 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *, struct sk_buff *);
 
 int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
 		   const struct ovs_conntrack_info *);
+int ovs_ct_clear(struct sk_buff *skb, struct sw_flow_key *key);
 
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
 int ovs_ct_put_key(const struct sw_flow_key *swkey,
@@ -73,6 +74,12 @@ static inline int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 	return -ENOTSUPP;
 }
 
+static inline int ovs_ct_clear(struct sk_buff *skb,
+			       struct sw_flow_key *key)
+{
+	return -ENOTSUPP;
+}
+
 static inline void ovs_ct_fill_key(const struct sk_buff *skb,
 				   struct sw_flow_key *key)
 {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index fc0ca9a89b8e..dc0d79092e74 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -76,6 +76,7 @@ static bool actions_may_change_flow(const struct nlattr *actions)
 			break;
 
 		case OVS_ACTION_ATTR_CT:
+		case OVS_ACTION_ATTR_CT_CLEAR:
 		case OVS_ACTION_ATTR_HASH:
 		case OVS_ACTION_ATTR_POP_ETH:
 		case OVS_ACTION_ATTR_POP_MPLS:
@@ -2528,6 +2529,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1,
 			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash),
 			[OVS_ACTION_ATTR_CT] = (u32)-1,
+			[OVS_ACTION_ATTR_CT_CLEAR] = 0,
 			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
 			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
 			[OVS_ACTION_ATTR_POP_ETH] = 0,
@@ -2669,6 +2671,9 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			skip_copy = true;
 			break;
 
+		case OVS_ACTION_ATTR_CT_CLEAR:
+			break;
+
 		case OVS_ACTION_ATTR_PUSH_ETH:
 			/* Disallow pushing an Ethernet header if one
 			 * is already present */
-- 
2.12.0
