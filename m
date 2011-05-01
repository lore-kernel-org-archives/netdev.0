From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 3/4] batman-adv: fix gw_node_update() and
	gw_election()
Date: Sun,  1 May 2011 23:10:33 +0200
Message-ID: <1304284234-27338-4-git-send-email-sven@narfation.org>
References: <1304284234-27338-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1304284234-27338-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

This is a regression from c4aac1ab9b973798163b34939b522f01e4d28ac9

- gw_node_update() doesn't add a new gw_node in case of empty curr_gw.
This means that at the beginning no gw_node is added, leading to an
empty gateway list.

- gw_election() is terminating in case of curr_gw == NULL. It has to
terminate in case of curr_gw != NULL

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_client.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 2acd7a6..af128ef 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -127,7 +127,7 @@ void gw_election(struct bat_priv *bat_priv)
 		return;
 
 	curr_gw = gw_get_selected_gw_node(bat_priv);
-	if (!curr_gw)
+	if (curr_gw)
 		goto out;
 
 	rcu_read_lock();
@@ -310,9 +310,13 @@ void gw_node_update(struct bat_priv *bat_priv,
 	struct hlist_node *node;
 	struct gw_node *gw_node, *curr_gw;
 
+	/**
+	 * Note: We don't need a NULL check here, since curr_gw never gets
+	 * dereferenced. If curr_gw is NULL we also should not exit as we may
+	 * have this gateway in our list (duplication check!) even though we
+	 * have no currently selected gateway.
+	 */
 	curr_gw = gw_get_selected_gw_node(bat_priv);
-	if (!curr_gw)
-		goto out;
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
@@ -350,7 +354,7 @@ deselect:
 	gw_deselect(bat_priv);
 unlock:
 	rcu_read_unlock();
-out:
+
 	if (curr_gw)
 		gw_node_free_ref(curr_gw);
 }
-- 
1.7.4.4
