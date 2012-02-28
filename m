From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 2/8] batman-adv: refactor tt_global_del() to
	avoid misalignment
Date: Tue, 28 Feb 2012 19:32:22 +0800
Message-ID: <1330428748-23137-3-git-send-email-lindner_marek@yahoo.de>
References: <1330428748-23137-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1330428748-23137-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/translation-table.c |   42 ++++++++++++++++++-----------------
 1 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index ff9a1b3..30c2d1b 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -657,29 +657,31 @@ void tt_global_del(struct bat_priv *bat_priv,
 	struct tt_local_entry *tt_local_entry = NULL;
 
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
-	if (!tt_global_entry)
+	if (!tt_global_entry || tt_global_entry->orig_node != orig_node)
 		goto out;
 
-	if (tt_global_entry->orig_node == orig_node) {
-		if (roaming) {
-			/* if we are deleting a global entry due to a roam
-			 * event, there are two possibilities:
-			 * 1) the client roamed from node A to node B => we mark
-			 *    it with TT_CLIENT_ROAM, we start a timer and we
-			 *    wait for node B to claim it. In case of timeout
-			 *    the entry is purged.
-			 * 2) the client roamed to us => we can directly delete
-			 *    the global entry, since it is useless now. */
-			tt_local_entry = tt_local_hash_find(bat_priv,
-							    tt_global_entry->common.addr);
-			if (!tt_local_entry) {
-				tt_global_entry->common.flags |= TT_CLIENT_ROAM;
-				tt_global_entry->roam_at = jiffies;
-				goto out;
-			}
-		}
-		_tt_global_del(bat_priv, tt_global_entry, message);
+	if (!roaming)
+		goto out_del;
+
+	/* if we are deleting a global entry due to a roam
+	 * event, there are two possibilities:
+	 * 1) the client roamed from node A to node B => we mark
+	 *    it with TT_CLIENT_ROAM, we start a timer and we
+	 *    wait for node B to claim it. In case of timeout
+	 *    the entry is purged.
+	 * 2) the client roamed to us => we can directly delete
+	 *    the global entry, since it is useless now. */
+	tt_local_entry = tt_local_hash_find(bat_priv,
+					    tt_global_entry->common.addr);
+	if (!tt_local_entry) {
+		tt_global_entry->common.flags |= TT_CLIENT_ROAM;
+		tt_global_entry->roam_at = jiffies;
+		goto out;
 	}
+
+out_del:
+	_tt_global_del(bat_priv, tt_global_entry, message);
+
 out:
 	if (tt_global_entry)
 		tt_global_entry_free_ref(tt_global_entry);
-- 
1.7.9
