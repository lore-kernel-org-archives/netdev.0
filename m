From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH net 2/2] batman-adv: Fix symmetry check / route flapping in multi interface setups
Date: Tue, 25 Sep 2012 17:57:17 +0200
Message-ID: <1348588637-18441-3-git-send-email-ordex@autistici.org>
References: <1348588637-18441-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:64065 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756959Ab2IYP5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 11:57:52 -0400
In-Reply-To: <1348588637-18441-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

If receiving an OGM from a neighbor other than the currently selected
and if it has the same TQ then we are supposed to switch if this
neighbor provides a more symmetric link than the currently selected one=
=2E

However this symmetry check currently is broken if the interface of the
neighbor we received the OGM from and the one of the currently selected
neighbor differ: We are currently trying to determine the symmetry of t=
he
link towards the selected router via the link we received the OGM from
instead of just checking via the link towards the currently selected
router.

This leads to way more route switches than necessary and can lead to
permanent route flapping in many common multi interface setups.

This patch fixes this issue by using the right interface for this
symmetry check.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index e877af8..469daab 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -642,7 +642,8 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_p=
riv,
 	struct batadv_neigh_node *router =3D NULL;
 	struct batadv_orig_node *orig_node_tmp;
 	struct hlist_node *node;
-	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
+	int if_num;
+	uint8_t sum_orig, sum_neigh;
 	uint8_t *neigh_addr;
=20
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -727,17 +728,17 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat=
_priv,
 	if (router && (neigh_node->tq_avg =3D=3D router->tq_avg)) {
 		orig_node_tmp =3D router->orig_node;
 		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
-		bcast_own_sum_orig =3D
-			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
+		if_num =3D router->if_incoming->if_num;
+		sum_orig =3D orig_node_tmp->bcast_own_sum[if_num];
 		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
=20
 		orig_node_tmp =3D neigh_node->orig_node;
 		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
-		bcast_own_sum_neigh =3D
-			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
+		if_num =3D neigh_node->if_incoming->if_num;
+		sum_neigh =3D orig_node_tmp->bcast_own_sum[if_num];
 		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
=20
-		if (bcast_own_sum_orig >=3D bcast_own_sum_neigh)
+		if (sum_orig >=3D sum_neigh)
 			goto update_tt;
 	}
=20
--=20
1.7.12
