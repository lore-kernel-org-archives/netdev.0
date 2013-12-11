From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH -next 2/3] batman-adv: Use seq_overflow
Date: Tue, 10 Dec 2013 21:12:43 -0800
Message-ID: <e7104b35287b1e1ec456734c1b5e1aa98dac99f8.1386738050.git.joe@perches.com>
References: <cover.1386738050.git.joe@perches.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <cover.1386738050.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
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

Convert the uses of the return of seq_printf to
instead check seq_overflow to determine if a buffer
overflow has occurred.

This will eventually allow seq_printf & seq_puts to
be converted to a void return instead of the often
misused return that is often assumed to be an int for
the number of bytes emitted ala printk.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/batman-adv/gateway_client.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 2449afa..dfa5d2d 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -517,29 +517,28 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 {
 	struct batadv_gw_node *curr_gw;
 	struct batadv_neigh_node *router;
-	int ret = -1;
 
 	router = batadv_orig_node_get_router(gw_node->orig_node);
 	if (!router)
-		goto out;
+		return -1;
 
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
-	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
-			 (curr_gw == gw_node ? "=>" : "  "),
-			 gw_node->orig_node->orig,
-			 router->bat_iv.tq_avg, router->addr,
-			 router->if_incoming->net_dev->name,
-			 gw_node->bandwidth_down / 10,
-			 gw_node->bandwidth_down % 10,
-			 gw_node->bandwidth_up / 10,
-			 gw_node->bandwidth_up % 10);
+	seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
+		   (curr_gw == gw_node ? "=>" : "  "),
+		   gw_node->orig_node->orig,
+		   router->bat_iv.tq_avg, router->addr,
+		   router->if_incoming->net_dev->name,
+		   gw_node->bandwidth_down / 10,
+		   gw_node->bandwidth_down % 10,
+		   gw_node->bandwidth_up / 10,
+		   gw_node->bandwidth_up % 10);
 
 	batadv_neigh_node_free_ref(router);
 	if (curr_gw)
 		batadv_gw_node_free_ref(curr_gw);
-out:
-	return ret;
+
+	return seq_overflow(seq);
 }
 
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
-- 
1.8.1.2.459.gbcd45b4.dirty
