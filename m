From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] Revert "netfilter: conntrack: fix race in __nf_conntrack_confirm against get_next_corpse"
Date: Tue, 25 Nov 2014 19:54:47 +0100
Message-ID: <1416941687-25471-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, brouer@redhat.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60197 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbaKYSwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 13:52:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 5195c14c8b27cc0b18220ddbf0e5ad3328a04187.

If the conntrack clashes with an existing one, it is left out of
the unconfirmed list, thus, crashing when dropping the packet and
releasing the conntrack since golden rule is that conntracks are
always placed in any of the existing lists for traceability reasons.

Reported-by: Daniel Borkmann <dborkman@redhat.com>
Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=88841
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
Hi David,

Could you manually apply this to your net tree? We have a better
candidate fix to replace this broken patch that I will pass to you
once it gets sufficient testing.

Thanks!

 net/netfilter/nf_conntrack_core.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 2c69975..5016a69 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -611,16 +611,12 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	 */
 	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
 	pr_debug("Confirming conntrack %p\n", ct);
-
-	/* We have to check the DYING flag after unlink to prevent
-	 * a race against nf_ct_get_next_corpse() possibly called from
-	 * user context, else we insert an already 'dead' hash, blocking
-	 * further use of that particular connection -JM.
-	 */
-	nf_ct_del_from_dying_or_unconfirmed_list(ct);
+	/* We have to check the DYING flag inside the lock to prevent
+	   a race against nf_ct_get_next_corpse() possibly called from
+	   user context, else we insert an already 'dead' hash, blocking
+	   further use of that particular connection -JM */
 
 	if (unlikely(nf_ct_is_dying(ct))) {
-		nf_ct_add_to_dying_list(ct);
 		nf_conntrack_double_unlock(hash, reply_hash);
 		local_bh_enable();
 		return NF_ACCEPT;
@@ -640,6 +636,8 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
 
+	nf_ct_del_from_dying_or_unconfirmed_list(ct);
+
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
 	   weird delay cases. */
-- 
1.7.10.4
