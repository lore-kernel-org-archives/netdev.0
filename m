From: Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] datapath: Fix for force/commit action failures
Date: Thu, 13 Jul 2017 09:25:24 -0700
Message-ID: <1499963124-7841-1-git-send-email-gvrose8192@gmail.com>
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

CC: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
CC: Pravin Shalar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Signed-off-by: Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/conntrack.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 08679eb..9041cf8 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -641,17 +641,21 @@ static bool skb_nfct_cached(struct net *net,
 	ct = nf_ct_get(skb, &ctinfo);
 	/* If no ct, check if we have evidence that an existing conntrack entry
 	 * might be found for this skb.  This happens when we lose a skb->_nfct
-	 * due to an upcall.  If the connection was not confirmed, it is not
-	 * cached and needs to be run through conntrack again.
+	 * due to an upcall, or if the direction is being forced.  If the
+	 * connection was not confirmed, it is not cached and needs to be run
+	 * through conntrack again.
 	 */
-	if (!ct && key->ct_state & OVS_CS_F_TRACKED &&
+	if ((!ct && (key->ct_state & OVS_CS_F_TRACKED) &&
 	    !(key->ct_state & OVS_CS_F_INVALID) &&
-	    key->ct_zone == info->zone.id) {
+	     key->ct_zone == info->zone.id) ||
+	     (!key->ct_state && info->force)) {
 		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
 					  !!(key->ct_state
 					     & OVS_CS_F_NAT_MASK));
 		if (ct)
 			nf_ct_get(skb, &ctinfo);
+		else
+			return false;
 	}
 	if (!ct)
 		return false;
-- 
1.8.3.1
