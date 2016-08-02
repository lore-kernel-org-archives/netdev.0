From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net] openvswitch: Remove incorrect WARN_ONCE().
Date: Mon,  1 Aug 2016 19:36:07 -0700
Message-ID: <1470105367-46582-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:33870 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbcHBE2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 00:28:42 -0400
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id 8B62947AC4E
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2016 04:37:47 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ovs_ct_find_existing() issues a warning if an existing conntrack entry
classified as IP_CT_NEW is found, with the premise that this should
not happen.  However, a newly confirmed, non-expected conntrack entry
remains IP_CT_NEW as long as no reply direction traffic is seen.  This
has resulted into somewhat confusing kernel log messages.  This patch
removes this check and warning.

Fixes: 289f2253 ("openvswitch: Find existing conntrack entry after upcall.")
Suggested-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index c644c78..e054a74 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -433,7 +433,6 @@ ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 	struct nf_conntrack_l4proto *l4proto;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
-	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 	unsigned int dataoff;
 	u8 protonum;
@@ -458,13 +457,8 @@ ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
-	ctinfo = ovs_ct_get_info(h);
-	if (ctinfo == IP_CT_NEW) {
-		/* This should not happen. */
-		WARN_ONCE(1, "ovs_ct_find_existing: new packet for %p\n", ct);
-	}
 	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = ctinfo;
+	skb->nfctinfo = ovs_ct_get_info(h);
 	return ct;
 }
 
-- 
2.1.4
