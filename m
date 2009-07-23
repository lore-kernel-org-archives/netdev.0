From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 03/08: nf_conntrack: fix conntrack lookup race
Date: Thu, 23 Jul 2009 16:15:28 +0200 (MEST)
Message-ID: <20090723141527.19029.52538.sendpatchset@x2.localnet>
References: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39719 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbZGWOP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 10:15:29 -0400
In-Reply-To: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1c91562def07c7186c2e17fc23efef75fb4dbd14
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 3 10:33:45 2009 +0200

    netfilter: nf_conntrack: fix conntrack lookup race
    
    Upstream commit 8d8890b7:
    
    The RCU protected conntrack hash lookup only checks whether the entry
    has a refcount of zero to decide whether it is stale. This is not
    sufficient, entries are explicitly removed while there is at least
    one reference left, possibly more. Explicitly check whether the entry
    has been marked as dying to fix this.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c8bd559..2d3584f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -295,7 +295,8 @@ begin:
 	h = __nf_conntrack_find(net, tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
-		if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		if (unlikely(nf_ct_is_dying(ct) ||
+			     !atomic_inc_not_zero(&ct->ct_general.use)))
 			h = NULL;
 		else {
 			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple))) {
@@ -474,7 +475,8 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 			cnt++;
 		}
 
-		if (ct && unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		if (ct && unlikely(nf_ct_is_dying(ct) ||
+				   !atomic_inc_not_zero(&ct->ct_general.use)))
 			ct = NULL;
 		if (ct || cnt >= NF_CT_EVICTION_RANGE)
 			break;
