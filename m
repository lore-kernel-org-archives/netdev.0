From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v5 2/8] netfilter: Factor out nf_ct_get_info().
Date: Wed, 16 Dec 2015 16:36:41 -0800
Message-ID: <1450312607-44050-3-git-send-email-jarno@ovn.org>
References: <1450312607-44050-1-git-send-email-jarno@ovn.org>
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:49984 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbbLQAh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 19:37:26 -0500
In-Reply-To: <1450312607-44050-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define a new inline function to map conntrack status to enum
ip_conntrack_info.  This removes the need to otherwise duplicate this
code in a later patch ("openvswitch: Find existing conntrack entry
after upcall.").

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 include/net/netfilter/nf_conntrack.h | 15 +++++++++++++++
 net/netfilter/nf_conntrack_core.c    | 28 +++++++++-------------------
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index fde4068..b3de10e 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -125,6 +125,21 @@ nf_ct_tuplehash_to_ctrack(const struct nf_conntrack_tuple_hash *hash)
 			    tuplehash[hash->tuple.dst.dir]);
 }
 
+static inline enum ip_conntrack_info
+nf_ct_get_info(const struct nf_conntrack_tuple_hash *h)
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
 static inline u_int16_t nf_ct_l3num(const struct nf_conn *ct)
 {
 	return ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.l3num;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3cb3cb8..7546fc7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1056,25 +1056,15 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
 	/* It exists; we have (non-exclusive) reference. */
-	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY) {
-		*ctinfo = IP_CT_ESTABLISHED_REPLY;
-		/* Please set reply bit if this packet OK */
-		*set_reply = 1;
-	} else {
-		/* Once we've had two way comms, always ESTABLISHED. */
-		if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
-			pr_debug("nf_conntrack_in: normal packet for %p\n", ct);
-			*ctinfo = IP_CT_ESTABLISHED;
-		} else if (test_bit(IPS_EXPECTED_BIT, &ct->status)) {
-			pr_debug("nf_conntrack_in: related packet for %p\n",
-				 ct);
-			*ctinfo = IP_CT_RELATED;
-		} else {
-			pr_debug("nf_conntrack_in: new packet for %p\n", ct);
-			*ctinfo = IP_CT_NEW;
-		}
-		*set_reply = 0;
-	}
+	*ctinfo = nf_ct_get_info(h);
+	if (*ctinfo == IP_CT_ESTABLISHED)
+		pr_debug("nf_conntrack_in: normal packet for %p\n", ct);
+	else if (*ctinfo == IP_CT_RELATED)
+		pr_debug("nf_conntrack_in: related packet for %p\n", ct);
+	else if (*ctinfo == IP_CT_NEW)
+		pr_debug("nf_conntrack_in: new packet for %p\n", ct);
+	*set_reply = NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY;
+
 	skb->nfct = &ct->ct_general;
 	skb->nfctinfo = *ctinfo;
 	return ct;
-- 
2.1.4
