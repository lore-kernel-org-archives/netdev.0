From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 02/08: nf_conntrack: fix confirmation race condition
Date: Thu, 23 Jul 2009 16:15:27 +0200 (MEST)
Message-ID: <20090723141526.19029.4804.sendpatchset@x2.localnet>
References: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 0293f8bc787be0f6a0ff9dba877c2f87f43dc60f
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 3 10:33:04 2009 +0200

    netfilter: nf_conntrack: fix confirmation race condition
    
    Upstream commit 5c8ec910:
    
    New connection tracking entries are inserted into the hash before they
    are fully set up, namely the CONFIRMED bit is not set and the timer not
    started yet. This can theoretically lead to a race with timer, which
    would set the timeout value to a relative value, most likely already in
    the past.
    
    Perform hash insertion as the final step to fix this.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 8020db6..c8bd559 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -385,7 +385,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* Remove from unconfirmed list */
 	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 
-	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
 	   weird delay cases. */
@@ -393,8 +392,16 @@ __nf_conntrack_confirm(struct sk_buff *skb)
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
