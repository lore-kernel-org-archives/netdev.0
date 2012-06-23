From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 2/2 net] batman-adv: fix race condition in TT
	full-table replacement
Date: Sat, 23 Jun 2012 17:30:59 +0200
Message-ID: <1340465459-2949-3-git-send-email-ordex@autistici.org>
References: <1340465459-2949-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340465459-2949-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

bug introduced with cea194d90b11aff7fc289149e4c7f305fad3535a

In the current TT code, when a TT_Response containing a full table is received
from an originator, first the node purges all the clients for that originator in
the global translation-table and then merges the newly received table.
During the purging phase each client deletion is done by means of a call_rcu()
invocation and at the end of this phase the global entry counter for that
originator is set to 0. However the invoked rcu function decreases the global
entry counter for that originator by one too and since the rcu invocation is
likely to be postponed, the node will end up in first setting the counter to 0
and then decreasing it one by one for each deleted client.

This bug leads to having a wrong global entry counter for the related node, say
X. Then when the node with the broken counter will answer to a TT_REQUEST on
behalf of node X, it will create faulty TT_RESPONSE that will generate an
unrecoverable situation on the node that asked for the full table recover.

The non-recoverability is given by the fact that the node with the broken
counter will keep answering on behalf of X because its knowledge about X's state
(ttvn + tt_crc) is correct.

To solve this problem the counter is not explicitly set to 0 anymore and the
counter decrement is performed right before the invocation of call_rcu().

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/translation-table.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 660c40f..2ab83d7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -141,13 +141,14 @@ static void tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
 	struct tt_orig_list_entry *orig_entry;
 
 	orig_entry = container_of(rcu, struct tt_orig_list_entry, rcu);
-	atomic_dec(&orig_entry->orig_node->tt_size);
 	orig_node_free_ref(orig_entry->orig_node);
 	kfree(orig_entry);
 }
 
 static void tt_orig_list_entry_free_ref(struct tt_orig_list_entry *orig_entry)
 {
+	/* to avoid race conditions, immediately decrease the tt counter */
+	atomic_dec(&orig_entry->orig_node->tt_size);
 	call_rcu(&orig_entry->rcu, tt_orig_list_entry_free_rcu);
 }
 
@@ -910,7 +911,6 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 		}
 		spin_unlock_bh(list_lock);
 	}
-	atomic_set(&orig_node->tt_size, 0);
 	orig_node->tt_initialised = false;
 }
 
-- 
1.7.9.4
