From: Greg Rose <gvrose8192@gmail.com>
Subject: [PATCH net] openvswitch: Fix for force/commit action failures
Date: Fri, 14 Jul 2017 09:10:39 -0700
Message-ID: <1500048639-24169-1-git-send-email-gvrose8192@gmail.com>
Cc: Greg Rose <gvrose8192@gmail.com>,
        Pravin Shelar <pshelar@nicira.com>, dev@openvswitch.org,
        Joe Stringer <joe@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34432 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754572AbdGNQKp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 12:10:45 -0400
Received: by mail-pf0-f196.google.com with SMTP id c24so11483606pfe.1
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 09:10:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is an established connection in direction A->B, it is
possible to receive a packet on port B which then executes
ct(commit,force) without first performing ct() - ie, a lookup.
In this case, we would expect that this packet can delete the existing
entry so that we can commit a connection with direction B->A. However,
currently we only perform a check in skb_nfct_cached() for whether
OVS_CS_F_TRACKED is set and OVS_CS_F_INVALID is not set, ie that a
lookup previously occurred. In the above scenario, a lookup has not
occurred but we should still be able to statelessly look up the
existing entry and potentially delete the entry if it is in the
opposite direction.

This patch extends the check to also hint that if the action has the
force flag set, then we will lookup the existing entry so that the
force check at the end of skb_nfct_cached has the ability to delete
the connection.

Fixes: dd41d330b03 ("openvswitch: Add force commit.")
CC: Pravin Shelar <pshelar@nicira.com>
CC: dev@openvswitch.org
Signed-off-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Greg Rose <gvrose8192@gmail.com>
---
 net/openvswitch/conntrack.c | 50 +++++++++++++++++++++++++++++++--------------
 1 file changed, 35 insertions(+), 15 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 08679eb..1260f2b 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -629,6 +629,33 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 	return ct;
 }
 
+struct nf_conn *ovs_ct_executed(struct net *net,
+				const struct sw_flow_key *key,
+				const struct ovs_conntrack_info *info,
+				struct sk_buff *skb,
+				bool *ct_executed)
+{
+	struct nf_conn *ct = NULL;
+
+	/* If no ct, check if we have evidence that an existing conntrack entry
+	 * might be found for this skb.  This happens when we lose a skb->_nfct
+	 * due to an upcall, or if the direction is being forced.  If the
+	 * connection was not confirmed, it is not cached and needs to be run
+	 * through conntrack again.
+	 */
+	*ct_executed = (key->ct_state & OVS_CS_F_TRACKED) &&
+		       !(key->ct_state & OVS_CS_F_INVALID) &&
+		       (key->ct_zone == info->zone.id);
+
+	if (*ct_executed || (!key->ct_state && info->force)) {
+		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
+					  !!(key->ct_state &
+					  OVS_CS_F_NAT_MASK));
+	}
+
+	return ct;
+}
+
 /* Determine whether skb->_nfct is equal to the result of conntrack lookup. */
 static bool skb_nfct_cached(struct net *net,
 			    const struct sw_flow_key *key,
@@ -637,24 +664,17 @@ static bool skb_nfct_cached(struct net *net,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
+	bool ct_executed = true;
 
 	ct = nf_ct_get(skb, &ctinfo);
-	/* If no ct, check if we have evidence that an existing conntrack entry
-	 * might be found for this skb.  This happens when we lose a skb->_nfct
-	 * due to an upcall.  If the connection was not confirmed, it is not
-	 * cached and needs to be run through conntrack again.
-	 */
-	if (!ct && key->ct_state & OVS_CS_F_TRACKED &&
-	    !(key->ct_state & OVS_CS_F_INVALID) &&
-	    key->ct_zone == info->zone.id) {
-		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
-					  !!(key->ct_state
-					     & OVS_CS_F_NAT_MASK));
-		if (ct)
-			nf_ct_get(skb, &ctinfo);
-	}
 	if (!ct)
+		ct = ovs_ct_executed(net, key, info, skb, &ct_executed);
+
+	if (ct)
+		nf_ct_get(skb, &ctinfo);
+	else
 		return false;
+
 	if (!net_eq(net, read_pnet(&ct->ct_net)))
 		return false;
 	if (!nf_ct_zone_equal_any(info->ct, nf_ct_zone(ct)))
@@ -679,7 +699,7 @@ static bool skb_nfct_cached(struct net *net,
 		return false;
 	}
 
-	return true;
+	return ct_executed;
 }
 
 #ifdef CONFIG_NF_NAT_NEEDED
-- 
1.8.3.1
