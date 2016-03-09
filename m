From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH nf-next v8 5/8] openvswitch: Find existing conntrack entry after upcall.
Date: Tue,  8 Mar 2016 16:24:41 -0800
Message-ID: <1457483084-13944-5-git-send-email-jarno@ovn.org>
References: <1457483084-13944-1-git-send-email-jarno@ovn.org>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:59480 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbcCIAZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 19:25:25 -0500
In-Reply-To: <1457483084-13944-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new function ovs_ct_find_existing() to find an existing
conntrack entry for which this packet was already applied to.  This is
only to be called when there is evidence that the packet was already
tracked and committed, but we lost the ct reference due to an
userspace upcall.

ovs_ct_find_existing() is called from skb_nfct_cached(), which can now
hide the fact that the ct reference may have been lost due to an
upcall.  This allows ovs_ct_commit() to be simplified.

This patch is needed by later "openvswitch: Interface with NAT" patch,
as we need to be able to pass the packet through NAT using the
original ct reference also after the reference is lost after an
upcall.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 103 ++++++++++++++++++++++++++++++++++++++------
 1 file changed, 90 insertions(+), 13 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index da804d3..b838536 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -356,14 +356,101 @@ ovs_ct_expect_find(struct net *net, const struct nf_conntrack_zone *zone,
 	return __nf_ct_expect_find(net, zone, &tuple);
 }
 
+/* This replicates logic from nf_conntrack_core.c that is not exported. */
+static enum ip_conntrack_info
+ovs_ct_get_info(const struct nf_conntrack_tuple_hash *h)
+{
+	const struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
+
+	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
+		return IP_CT_ESTABLISHED_REPLY;
+	/* Once we've had two way comms, always ESTABLISHED. */
+	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status))
+		return IP_CT_ESTABLISHED;
+	if (test_bit(IPS_EXPECTED_BIT, &ct->status))
+		return IP_CT_RELATED;
+	return IP_CT_NEW;
+}
+
+/* Find an existing connection which this packet belongs to without
+ * re-attributing statistics or modifying the connection state.  This allows an
+ * skb->nfct lost due to an upcall to be recovered during actions execution.
+ *
+ * Must be called with rcu_read_lock.
+ *
+ * On success, populates skb->nfct and skb->nfctinfo, and returns the
+ * connection.  Returns NULL if there is no existing entry.
+ */
+static struct nf_conn *
+ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
+		     u8 l3num, struct sk_buff *skb)
+{
+	struct nf_conntrack_l3proto *l3proto;
+	struct nf_conntrack_l4proto *l4proto;
+	struct nf_conntrack_tuple tuple;
+	struct nf_conntrack_tuple_hash *h;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	unsigned int dataoff;
+	u8 protonum;
+
+	l3proto = __nf_ct_l3proto_find(l3num);
+	if (!l3proto) {
+		pr_debug("ovs_ct_find_existing: Can't get l3proto\n");
+		return NULL;
+	}
+	if (l3proto->get_l4proto(skb, skb_network_offset(skb), &dataoff,
+				 &protonum) <= 0) {
+		pr_debug("ovs_ct_find_existing: Can't get protonum\n");
+		return NULL;
+	}
+	l4proto = __nf_ct_l4proto_find(l3num, protonum);
+	if (!l4proto) {
+		pr_debug("ovs_ct_find_existing: Can't get l4proto\n");
+		return NULL;
+	}
+	if (!nf_ct_get_tuple(skb, skb_network_offset(skb), dataoff, l3num,
+			     protonum, net, &tuple, l3proto, l4proto)) {
+		pr_debug("ovs_ct_find_existing: Can't get tuple\n");
+		return NULL;
+	}
+
+	/* look for tuple match */
+	h = nf_conntrack_find_get(net, zone, &tuple);
+	if (!h)
+		return NULL;   /* Not found. */
+
+	ct = nf_ct_tuplehash_to_ctrack(h);
+
+	ctinfo = ovs_ct_get_info(h);
+	if (ctinfo == IP_CT_NEW) {
+		/* This should not happen. */
+		WARN_ONCE(1, "ovs_ct_find_existing: new packet for %p\n", ct);
+	}
+	skb->nfct = &ct->ct_general;
+	skb->nfctinfo = ctinfo;
+	return ct;
+}
+
 /* Determine whether skb->nfct is equal to the result of conntrack lookup. */
-static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
-			    const struct ovs_conntrack_info *info)
+static bool skb_nfct_cached(struct net *net,
+			    const struct sw_flow_key *key,
+			    const struct ovs_conntrack_info *info,
+			    struct sk_buff *skb)
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 
 	ct = nf_ct_get(skb, &ctinfo);
+	/* If no ct, check if we have evidence that an existing conntrack entry
+	 * might be found for this skb.  This happens when we lose a skb->nfct
+	 * due to an upcall.  If the connection was not confirmed, it is not
+	 * cached and needs to be run through conntrack again.
+	 */
+	if (!ct && key->ct.state & OVS_CS_F_TRACKED &&
+	    !(key->ct.state & OVS_CS_F_INVALID) &&
+	    key->ct.zone == info->zone.id)
+		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb);
 	if (!ct)
 		return false;
 	if (!net_eq(net, read_pnet(&ct->ct_net)))
@@ -396,7 +483,7 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 	 * actually run the packet through conntrack twice unless it's for a
 	 * different zone.
 	 */
-	if (!skb_nfct_cached(net, skb, info)) {
+	if (!skb_nfct_cached(net, key, info, skb)) {
 		struct nf_conn *tmpl = info->ct;
 
 		/* Associate skb with specified zone. */
@@ -459,18 +546,8 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 			 const struct ovs_conntrack_info *info,
 			 struct sk_buff *skb)
 {
-	u8 state;
 	int err;
 
-	state = key->ct.state;
-	if (key->ct.zone == info->zone.id &&
-	    ((state & OVS_CS_F_TRACKED) && !(state & OVS_CS_F_NEW))) {
-		/* Previous lookup has shown that this connection is already
-		 * tracked and committed. Skip committing.
-		 */
-		return 0;
-	}
-
 	err = __ovs_ct_lookup(net, key, info, skb);
 	if (err)
 		return err;
-- 
2.1.4
