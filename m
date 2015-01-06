From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 6/6] batman-adv: fix potential TT client + orig-node memory leak
Date: Tue,  6 Jan 2015 12:10:05 +0100
Message-ID: <1420542605-28865-7-git-send-email-antonio@meshcoding.com>
References: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:17277 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754984AbbAFLKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 06:10:51 -0500
In-Reply-To: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

This patch fixes a potential memory leak which can occur once an
originator times out. On timeout the according global translation table
entry might not get purged correctly. Furthermore, the non purged TT
entry will cause its orig-node to leak, too. Which additionally can lea=
d
to the new multicast optimization feature not kicking in because of a
therefore bogus counter.

In detail: The batadv_tt_global_entry->orig_list holds the reference to
the orig-node. Usually this reference is released after
BATADV_PURGE_TIMEOUT through: _batadv_purge_orig()->
batadv_purge_orig_node()->batadv_update_route()->_batadv_update_route()=
->
batadv_tt_global_del_orig() which purges this global tt entry and
releases the reference to the orig-node.

However, if between two batadv_purge_orig_node() calls the orig-node
timeout grew to 2*BATADV_PURGE_TIMEOUT then this call path isn't
reached. Instead the according orig-node is removed from the
originator hash in _batadv_purge_orig(), the batadv_update_route()
part is skipped and won't be reached anymore.

=46ixing the issue by moving batadv_tt_global_del_orig() out of the rcu
callback.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 648bdba..bea8198 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -570,9 +570,6 @@ static void batadv_orig_node_free_rcu(struct rcu_he=
ad *rcu)
=20
 	batadv_frag_purge_orig(orig_node, NULL);
=20
-	batadv_tt_global_del_orig(orig_node->bat_priv, orig_node, -1,
-				  "originator timed out");
-
 	if (orig_node->bat_priv->bat_algo_ops->bat_orig_free)
 		orig_node->bat_priv->bat_algo_ops->bat_orig_free(orig_node);
=20
@@ -978,6 +975,9 @@ static void _batadv_purge_orig(struct batadv_priv *=
bat_priv)
 			if (batadv_purge_orig_node(bat_priv, orig_node)) {
 				batadv_gw_node_delete(bat_priv, orig_node);
 				hlist_del_rcu(&orig_node->hash_entry);
+				batadv_tt_global_del_orig(orig_node->bat_priv,
+							  orig_node, -1,
+							  "originator timed out");
 				batadv_orig_node_free_ref(orig_node);
 				continue;
 			}
--=20
2.2.1
