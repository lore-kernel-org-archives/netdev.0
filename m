From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/18] openvswitch: Add commentary to conntrack.c
Date: Tue, 15 Mar 2016 02:27:56 +0100
Message-ID: <1458005282-24665-13-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jarno@ovn.org>

This makes the code easier to understand and the following patches
more focused.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/openvswitch/conntrack.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 3045290..2c2bf07 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -152,8 +152,12 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct) {
 		state = ovs_ct_get_state(ctinfo);
+		/* All unconfirmed entries are NEW connections. */
 		if (!nf_ct_is_confirmed(ct))
 			state |= OVS_CS_F_NEW;
+		/* OVS persists the related flag for the duration of the
+		 * connection.
+		 */
 		if (ct->master)
 			state |= OVS_CS_F_RELATED;
 		zone = nf_ct_zone(ct);
@@ -165,6 +169,9 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 	__ovs_ct_update_key(key, state, zone, ct);
 }
 
+/* This is called to initialize CT key fields possibly coming in from the local
+ * stack.
+ */
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
 {
 	ovs_ct_update_key(skb, NULL, key, false);
@@ -199,7 +206,6 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 	struct nf_conn *ct;
 	u32 new_mark;
 
-
 	/* The connection could be invalid, in which case set_mark is no-op. */
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct)
@@ -375,6 +381,11 @@ static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
 	return true;
 }
 
+/* Pass 'skb' through conntrack in 'net', using zone configured in 'info', if
+ * not done already.  Update key with new CT state.
+ * Note that if the packet is deemed invalid by conntrack, skb->nfct will be
+ * set to NULL and 0 will be returned.
+ */
 static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			   const struct ovs_conntrack_info *info,
 			   struct sk_buff *skb)
@@ -418,6 +429,13 @@ static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 {
 	struct nf_conntrack_expect *exp;
 
+	/* If we pass an expected packet through nf_conntrack_in() the
+	 * expectation is typically removed, but the packet could still be
+	 * lost in upcall processing.  To prevent this from happening we
+	 * perform an explicit expectation lookup.  Expected connections are
+	 * always new, and will be passed through conntrack only when they are
+	 * committed, as it is OK to remove the expectation at that time.
+	 */
 	exp = ovs_ct_expect_find(net, &info->zone, info->family, skb);
 	if (exp) {
 		u8 state;
@@ -455,6 +473,7 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 	err = __ovs_ct_lookup(net, key, info, skb);
 	if (err)
 		return err;
+	/* This is a no-op if the connection has already been confirmed. */
 	if (nf_conntrack_confirm(skb) != NF_ACCEPT)
 		return -EINVAL;
 
-- 
2.1.4

