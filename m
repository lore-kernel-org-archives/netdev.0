From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 3/8] batman-adv: Simplify gw_check_election(),
	use gw_get_selected()
Date: Sun, 17 Apr 2011 21:30:13 +0200
Message-ID: <1303068618-27928-4-git-send-email-sven@narfation.org>
References: <1303068618-27928-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1303068618-27928-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>

gw_get_selected() can get us the desired orig_node directly, therefore
reusing that function in gw_check_election().

Signed-off-by: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_client.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_cli=
ent.c
index 27b87ad..879ac15 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -23,6 +23,7 @@
 #include "gateway_client.h"
 #include "gateway_common.h"
 #include "hard-interface.h"
+#include "originator.h"
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/udp.h>
@@ -203,28 +204,25 @@ void gw_election(struct bat_priv *bat_priv)
=20
 void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig=
_node)
 {
-	struct gw_node *curr_gateway_tmp;
+	struct orig_node *curr_gw_orig;
 	uint8_t gw_tq_avg, orig_tq_avg;
=20
+	curr_gw_orig =3D gw_get_selected(bat_priv);
+	if (!curr_gw_orig)
+		goto deselect;
+
 	rcu_read_lock();
-	curr_gateway_tmp =3D rcu_dereference(bat_priv->curr_gw);
-	if (!curr_gateway_tmp)
-		goto out_rcu;
-
-	if (!curr_gateway_tmp->orig_node)
-		goto deselect_rcu;
-
-	if (!curr_gateway_tmp->orig_node->router)
+	if (!curr_gw_orig->router)
 		goto deselect_rcu;
=20
 	/* this node already is the gateway */
-	if (curr_gateway_tmp->orig_node =3D=3D orig_node)
+	if (curr_gw_orig =3D=3D orig_node)
 		goto out_rcu;
=20
 	if (!orig_node->router)
 		goto out_rcu;
=20
-	gw_tq_avg =3D curr_gateway_tmp->orig_node->router->tq_avg;
+	gw_tq_avg =3D curr_gw_orig->router->tq_avg;
 	rcu_read_unlock();
=20
 	orig_tq_avg =3D orig_node->router->tq_avg;
@@ -255,6 +253,9 @@ deselect_rcu:
 deselect:
 	gw_deselect(bat_priv);
 out:
+	if (curr_gw_orig)
+		orig_node_free_ref(curr_gw_orig);
+
 	return;
 }
=20
--=20
1.7.4.4
