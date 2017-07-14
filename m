From: Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V3 net] openvswitch: Fix for force/commit action
	failures
Date: Fri, 14 Jul 2017 12:42:49 -0700
Message-ID: <1500061369-27918-1-git-send-email-gvrose8192@gmail.com>
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
CC: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
CC: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Signed-off-by: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Signed-off-by: Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

V2: Make sure nf_conntrack_in() is called for force case
V3: Fix compiler warning for newer compilers
---
 net/openvswitch/conntrack.c | 51 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 36 insertions(+), 15 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 08679eb..e3c4c6c 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -629,6 +629,34 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 	return ct;
 }
 
+static
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
@@ -637,24 +665,17 @@ static bool skb_nfct_cached(struct net *net,
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
@@ -679,7 +700,7 @@ static bool skb_nfct_cached(struct net *net,
 		return false;
 	}
 
-	return true;
+	return ct_executed;
 }
 
 #ifdef CONFIG_NF_NAT_NEEDED
-- 
1.8.3.1
