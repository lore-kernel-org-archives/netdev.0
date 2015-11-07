From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: [RFC PATCH net-next v2 2/8] netfilter: Factor out nf_ct_get_info().
Date: Fri,  6 Nov 2015 16:06:02 -0800
Message-ID: <1446854768-38299-3-git-send-email-jrajahalme@nicira.com>
References: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com>
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org,
	jrajahalme@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34894 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbbKGAGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 19:06:18 -0500
Received: by pasz6 with SMTP id z6so141368226pas.2
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 16:06:17 -0800 (PST)
In-Reply-To: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define a new inline function to map conntrack status to enum
ip_conntrack_info.  This removes the need to otherwise duplicate this
code in a later patch ("openvswitch: Find existing conntrack entry
after upcall.").

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
 include/net/netfilter/nf_conntrack.h | 15 +++++++++++++++
 net/netfilter/nf_conntrack_core.c    | 22 +++-------------------
 2 files changed, 18 insertions(+), 19 deletions(-)

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
index 3cb3cb8..70ddbd8 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1056,25 +1056,9 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
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
+	*set_reply = NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY;
+
 	skb->nfct = &ct->ct_general;
 	skb->nfctinfo = *ctinfo;
 	return ct;
-- 
2.1.4
