From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 2/2] batman-adv: delete global entry in case
	of roaming
Date: Wed,  7 Dec 2011 13:42:41 +0800
Message-ID: <1323236561-25262-1-git-send-email-lindner_marek@yahoo.de>
References: <1323236203-24711-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1323236203-24711-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

When receiving a DEL change for a client due to a roaming event (change is
marked with TT_CLIENT_ROAM), each node  has to check if the client roamed
to itself or somewhere else.

In the latter case the global entry is kept to avoid having no route at all
otherwise we can safely delete the global entry

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/translation-table.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index c46b140..5f09a57 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -696,6 +696,7 @@ void tt_global_del(struct bat_priv *bat_priv,
 		   const char *message, bool roaming)
 {
 	struct tt_global_entry *tt_global_entry = NULL;
+	struct tt_local_entry *tt_local_entry = NULL;
 
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 	if (!tt_global_entry)
@@ -703,15 +704,29 @@ void tt_global_del(struct bat_priv *bat_priv,
 
 	if (tt_global_entry->orig_node == orig_node) {
 		if (roaming) {
-			tt_global_entry->flags |= TT_CLIENT_ROAM;
-			tt_global_entry->roam_at = jiffies;
-			goto out;
+			/* if we are deleting a global entry due to a roam
+			 * event, there are two possibilities:
+			 * 1) the client roamed from node A to node B => we mark
+			 *    it with TT_CLIENT_ROAM, we start a timer and we
+			 *    wait for node B to claim it. In case of timeout
+			 *    the entry is purged.
+			 * 2) the client roamed to us => we can directly delete
+			 *    the global entry, since it is useless now. */
+			tt_local_entry = tt_local_hash_find(bat_priv,
+							tt_global_entry->addr);
+			if (!tt_local_entry) {
+				tt_global_entry->flags |= TT_CLIENT_ROAM;
+				tt_global_entry->roam_at = jiffies;
+				goto out;
+			}
 		}
 		_tt_global_del(bat_priv, tt_global_entry, message);
 	}
 out:
 	if (tt_global_entry)
 		tt_global_entry_free_ref(tt_global_entry);
+	if (tt_local_entry)
+		tt_local_entry_free_ref(tt_local_entry);
 }
 
 void tt_global_del_orig(struct bat_priv *bat_priv,
-- 
1.7.5.4
