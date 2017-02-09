From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v4 net-next 02/10] openvswitch: Use inverted tuple in ovs_ct_find_existing() if NATted.
Date: Thu,  9 Feb 2017 11:21:53 -0800
Message-ID: <1486668121-45709-3-git-send-email-jarno@ovn.org>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, davem@davemloft.net, joe@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:51063 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753234AbdBITWT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:22:19 -0500
In-Reply-To: <1486668121-45709-1-git-send-email-jarno@ovn.org>
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
Acked-by: Joe Stringer <joe@ovn.org>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/conntrack.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 5de6d12..4df9a54 100644
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
 	nf_ct_set(skb, ct, ovs_ct_get_info(h));
 	return ct;
 }
@@ -482,7 +500,9 @@ static bool skb_nfct_cached(struct net *net,
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
