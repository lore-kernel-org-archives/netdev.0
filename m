From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 1/2] batman-adv: Add missing refcnt for
	last_candidate
Date: Wed, 14 Sep 2016 14:37:34 +0200
Message-ID: <20160914123735.9411-2-sw@simonwunderlich.de>
References: <20160914123735.9411-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160914123735.9411-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batadv_find_router dereferences last_bonding_candidate from
orig_node without making sure that it has a valid reference. This reference
has to be retrieved by increasing the reference counter while holding
neigh_list_lock. The lock is required to avoid that
batadv_last_bonding_replace removes the current last_bonding_candidate,
reduces the reference counter and maybe destroys the object in this
process.

Fixes: f3b3d9018975 ("batman-adv: add bonding again")
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/routing.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7602c00..3d19947 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -470,6 +470,29 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 }
 
 /**
+ * batadv_last_bonding_get - Get last_bonding_candidate of orig_node
+ * @orig_node: originator node whose last bonding candidate should be retrieved
+ *
+ * Return: last bonding candidate of router or NULL if not found
+ *
+ * The object is returned with refcounter increased by 1.
+ */
+static struct batadv_orig_ifinfo *
+batadv_last_bonding_get(struct batadv_orig_node *orig_node)
+{
+	struct batadv_orig_ifinfo *last_bonding_candidate;
+
+	spin_lock_bh(&orig_node->neigh_list_lock);
+	last_bonding_candidate = orig_node->last_bonding_candidate;
+
+	if (last_bonding_candidate)
+		kref_get(&last_bonding_candidate->refcount);
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+
+	return last_bonding_candidate;
+}
+
+/**
  * batadv_last_bonding_replace - Replace last_bonding_candidate of orig_node
  * @orig_node: originator node whose bonding candidates should be replaced
  * @new_candidate: new bonding candidate or NULL
@@ -539,7 +562,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 	 * router - obviously there are no other candidates.
 	 */
 	rcu_read_lock();
-	last_candidate = orig_node->last_bonding_candidate;
+	last_candidate = batadv_last_bonding_get(orig_node);
 	if (last_candidate)
 		last_cand_router = rcu_dereference(last_candidate->router);
 
@@ -631,6 +654,9 @@ next:
 		batadv_orig_ifinfo_put(next_candidate);
 	}
 
+	if (last_candidate)
+		batadv_orig_ifinfo_put(last_candidate);
+
 	return router;
 }
 
-- 
2.9.3
