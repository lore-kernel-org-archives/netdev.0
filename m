From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 1/3] batman-adv: remove references for global
	tt entries
Date: Sat, 29 Oct 2011 10:06:44 +0200
Message-ID: <1319875606-7794-2-git-send-email-lindner_marek@yahoo.de>
References: <1319875606-7794-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1319875606-7794-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

struct tt_global_entry holds a reference to an orig_node which must be
decremented before deallocating the structure.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Tested-by: Alexey Fisher <bug-track-M18mAb7Tlt0yCq4wW13eYl6hYfS7NtTn@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/translation-table.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 873fb3d..abf05cb 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -137,10 +137,22 @@ static void tt_local_entry_free_ref(struct tt_local_entry *tt_local_entry)
 		kfree_rcu(tt_local_entry, rcu);
 }
 
+static void tt_global_entry_free_rcu(struct rcu_head *rcu)
+{
+	struct tt_global_entry *tt_global_entry;
+
+	tt_global_entry = container_of(rcu, struct tt_global_entry, rcu);
+
+	if (tt_global_entry->orig_node)
+		orig_node_free_ref(tt_global_entry->orig_node);
+
+	kfree(tt_global_entry);
+}
+
 static void tt_global_entry_free_ref(struct tt_global_entry *tt_global_entry)
 {
 	if (atomic_dec_and_test(&tt_global_entry->refcount))
-		kfree_rcu(tt_global_entry, rcu);
+		call_rcu(&tt_global_entry->rcu, tt_global_entry_free_rcu);
 }
 
 static void tt_local_event(struct bat_priv *bat_priv, const uint8_t *addr,
-- 
1.7.5.4
