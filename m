From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/07: nf_conntrack: use mod_timer_pending() for conntrack refresh
Date: Sat, 13 Jun 2009 15:09:37 +0200 (MEST)
Message-ID: <20090613130937.2112.22333.sendpatchset@x2.localnet>
References: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 65cb9fda32be613216f601a330b311c3bd7a8436
Author: Patrick McHardy <kaber@trash.net>
Date:   Sat Jun 13 12:21:49 2009 +0200

    netfilter: nf_conntrack: use mod_timer_pending() for conntrack refresh
    
    Use mod_timer_pending() instead of atomic sequence of del_timer()/
    add_timer(). mod_timer_pending() does not rearm an inactive timer,
    so we don't need the conntrack lock anymore to make sure we don't
    accidentally rearm a timer of a conntrack which is in the process
    of being destroyed.
    
    With this change, we don't need to take the global lock anymore at all,
    counter updates can be performed under the per-conntrack lock.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index edf9569..d8dffe7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -807,8 +807,6 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 	NF_CT_ASSERT(ct->timeout.data == (unsigned long)ct);
 	NF_CT_ASSERT(skb);
 
-	spin_lock_bh(&nf_conntrack_lock);
-
 	/* Only update if this is not a fixed timeout */
 	if (test_bit(IPS_FIXED_TIMEOUT_BIT, &ct->status))
 		goto acct;
@@ -822,11 +820,8 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 		/* Only update the timeout if the new timeout is at least
 		   HZ jiffies from the old timeout. Need del_timer for race
 		   avoidance (may already be dying). */
-		if (newtime - ct->timeout.expires >= HZ
-		    && del_timer(&ct->timeout)) {
-			ct->timeout.expires = newtime;
-			add_timer(&ct->timeout);
-		}
+		if (newtime - ct->timeout.expires >= HZ)
+			mod_timer_pending(&ct->timeout, newtime);
 	}
 
 acct:
@@ -835,13 +830,13 @@ acct:
 
 		acct = nf_conn_acct_find(ct);
 		if (acct) {
+			spin_lock_bh(&ct->lock);
 			acct[CTINFO2DIR(ctinfo)].packets++;
 			acct[CTINFO2DIR(ctinfo)].bytes +=
 				skb->len - skb_network_offset(skb);
+			spin_unlock_bh(&ct->lock);
 		}
 	}
-
-	spin_unlock_bh(&nf_conntrack_lock);
 }
 EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
 
@@ -853,14 +848,14 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 	if (do_acct) {
 		struct nf_conn_counter *acct;
 
-		spin_lock_bh(&nf_conntrack_lock);
 		acct = nf_conn_acct_find(ct);
 		if (acct) {
+			spin_lock_bh(&ct->lock);
 			acct[CTINFO2DIR(ctinfo)].packets++;
 			acct[CTINFO2DIR(ctinfo)].bytes +=
 				skb->len - skb_network_offset(skb);
+			spin_unlock_bh(&ct->lock);
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
 	}
 
 	if (del_timer(&ct->timeout)) {
