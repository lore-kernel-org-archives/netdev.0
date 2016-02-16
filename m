From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 2/3] batman-adv: Only put orig_node_vlan list reference when removed
Date: Tue, 16 Feb 2016 23:01:27 +0800
Message-ID: <1455634888-29400-3-git-send-email-a__35184.2465730899$1455635073$gmane$org@unstable.cc>
References: <1455634888-29400-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:42927 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932930AbcBPPED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 10:04:03 -0500
In-Reply-To: <1455634888-29400-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batadv_orig_node_vlan reference counter in batadv_tt_global_size_mod
can only be reduced when the list entry was actually removed. Otherwise the
reference counter may reach zero when batadv_tt_global_size_mod is called
from two different contexts for the same orig_node_vlan but only one
context is actually removing the entry from the list.

The release function for this orig_node_vlan is not called inside the
vlan_list_lock spinlock protected region because the function
batadv_tt_global_size_mod still holds a orig_node_vlan reference for the
object pointer on the stack. Thus the actual release function (when
required) will be called only at the end of the function.

Fixes: 7ea7b4a14275 ("batman-adv: make the TT CRC logic VLAN specific")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/translation-table.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index cdfc85fa2743..0e80fd1461ab 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -303,9 +303,11 @@ static void batadv_tt_global_size_mod(struct batadv_orig_node *orig_node,
 
 	if (atomic_add_return(v, &vlan->tt.num_entries) == 0) {
 		spin_lock_bh(&orig_node->vlan_list_lock);
-		hlist_del_init_rcu(&vlan->list);
+		if (!hlist_unhashed(&vlan->list)) {
+			hlist_del_init_rcu(&vlan->list);
+			batadv_orig_node_vlan_free_ref(vlan);
+		}
 		spin_unlock_bh(&orig_node->vlan_list_lock);
-		batadv_orig_node_vlan_free_ref(vlan);
 	}
 
 	batadv_orig_node_vlan_free_ref(vlan);
-- 
2.7.1
