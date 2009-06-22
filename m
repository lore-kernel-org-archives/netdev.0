From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/07: nf_conntrack: fix confirmation race condition
Date: Mon, 22 Jun 2009 14:53:51 +0200 (MEST)
Message-ID: <20090622125351.6531.50859.sendpatchset@x2.localnet>
References: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39233 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbZFVMxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 08:53:49 -0400
In-Reply-To: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 5c8ec910e789a92229978d8fd1fce7b62e8ac711
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 22 14:14:16 2009 +0200

    netfilter: nf_conntrack: fix confirmation race condition
    
    New connection tracking entries are inserted into the hash before they
    are fully set up, namely the CONFIRMED bit is not set and the timer not
    started yet. This can theoretically lead to a race with timer, which
    would set the timeout value to a relative value, most likely already in
    the past.
    
    Perform hash insertion as the final step to fix this.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5276a2d..b0b06c7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -425,7 +425,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* Remove from unconfirmed list */
 	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 
-	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
 	   weird delay cases. */
@@ -433,8 +432,16 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	add_timer(&ct->timeout);
 	atomic_inc(&ct->ct_general.use);
 	set_bit(IPS_CONFIRMED_BIT, &ct->status);
+
+	/* Since the lookup is lockless, hash insertion must be done after
+	 * starting the timer and setting the CONFIRMED bit. The RCU barriers
+	 * guarantee that no other CPU can find the conntrack before the above
+	 * stores are visible.
+	 */
+	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
+
 	help = nfct_help(ct);
 	if (help && help->helper)
 		nf_conntrack_event_cache(IPCT_HELPER, ct);
