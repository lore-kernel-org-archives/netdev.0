From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next 1/7] openvswitch: Use inverted tuple in ovs_ct_find_existing() if NATted.
Date: Thu,  2 Feb 2017 17:10:00 -0800
Message-ID: <1486084206-109903-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:56759 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbdBCBKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 20:10:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When looking for an existing conntrack entry, the packet 5-tuple
must be inverted if NAT has already been applied, as the current
packet headers do not match any conntrack tuple.  For
example, if a packet from private address X to a public address B is
source-NATted to A, the conntrack entry will have the following tuples
(ignoring the protocol and port numbers) after the conntrack entry is
committed:

Original direction tuple: (X,B)
Reply direction tuple: (B,A)

Now, if a reply packet is already transformed back to the private
address space (e.g., with a CT(nat) action), the tuple corresponding
to the current packet headers is:

Current packet tuple: (B,X)

This does not match either of the conntrack tuples above.  Normally
this does not matter, as the conntrack lookup was already done using
the tuple (B,A), but if the current packet does not match any flow in
the OVS datapath, the packet is sent to userspace via an upcall,
during which the packet's skb is freed, and the conntrack entry
pointer in the skb is lost.  When the packet is reintroduced to the
datapath, any further conntrack action will need to perform a new
conntrack lookup to find the entry again.  Prior to this patch this
second lookup failed for NATted packets.  The datapath flow setup
corresponding to the upcall can succeed, however, allowing all further
packets in the reply direction to re-use the conntrack entry pointer
in the skb, so typically the lookup failure only causes a packet drop.

The solution is to invert the tuple derived from the current packet
headers in case the conntrack state stored in the packet metadata
indicates that the packet has been transformed by NAT:

Inverted tuple: (X,B)

With this the conntrack entry can be found, matching the original
direction tuple.

This same logic also works for the original direction packets:

Current packet tuple (after NAT): (A,B)
Inverted tuple: (B,A)

While the current packet tuple (A,B) does not match either of the
conntrack tuples, the inverted one (B,A) does match the reply
direction tuple.

Since the inverted tuple matches the reverse direction tuple the
direction of the packet must be reversed as well.

Fixes: 05752523e565 ("openvswitch: Interface with NAT.")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 54253ea..b91baa2 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -430,7 +430,7 @@ ovs_ct_get_info(const struct nf_conntrack_tuple_hash *h)
  */
 static struct nf_conn *
 ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
-		     u8 l3num, struct sk_buff *skb)
+		     u8 l3num, struct sk_buff *skb, bool natted)
 {
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
@@ -453,6 +453,17 @@ ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 		return NULL;
 	}
 
+	/* Must invert the tuple if skb has been transformed by NAT. */
+	if (natted) {
+		struct nf_conntrack_tuple inverse;
+
+		if (!nf_ct_invert_tuple(&inverse, &tuple, l3proto, l4proto)) {
+			pr_debug("ovs_ct_find_existing: Inversion failed!\n");
+			return NULL;
+		}
+		tuple = inverse;
+	}
+
 	/* look for tuple match */
 	h = nf_conntrack_find_get(net, zone, &tuple);
 	if (!h)
@@ -460,6 +471,13 @@ ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
+	/* Inverted packet tuple matches the reverse direction conntrack tuple,
+	 * select the other tuplehash to get the right 'ctinfo' bits for this
+	 * packet.
+	 */
+	if (natted)
+		h = &ct->tuplehash[!h->tuple.dst.dir];
+
 	skb->nfct = &ct->ct_general;
 	skb->nfctinfo = ovs_ct_get_info(h);
 	return ct;
@@ -483,7 +501,9 @@ static bool skb_nfct_cached(struct net *net,
 	if (!ct && key->ct.state & OVS_CS_F_TRACKED &&
 	    !(key->ct.state & OVS_CS_F_INVALID) &&
 	    key->ct.zone == info->zone.id)
-		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb);
+		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
+					  !!(key->ct.state
+					     & OVS_CS_F_NAT_MASK));
 	if (!ct)
 		return false;
 	if (!net_eq(net, read_pnet(&ct->ct_net)))
-- 
2.1.4
