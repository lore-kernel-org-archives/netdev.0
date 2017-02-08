From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v2 net-next 1/9] openvswitch: Use inverted tuple in ovs_ct_find_existing() if NATted.
Date: Wed,  8 Feb 2017 11:32:02 -0800
Message-ID: <1486582330-31152-2-git-send-email-jarno@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:39024 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbdBHTeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:34:04 -0500
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 1640C4866D5
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 20:33:28 +0100 (CET)
In-Reply-To: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The conntrack lookup for existing connections fails to invert the
packet 5-tuple for NATted packets, and therefore fails to find the
existing conntrack entry.  Conntrack only stores 5-tuples for incoming
packets, and there are various situations where a lookup on a packet
that has already been transformed by NAT needs to be made.  Looking up
an existing conntrack entry upon executing packet received from the
userspace is one of them.

This patch fixes ovs_ct_find_existing() to invert the packet 5-tuple
for the conntrack lookup whenever the packet has already been
transformed by conntrack from its input form as evidenced by one of
the NAT flags being set in the conntrack state metadata.

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
