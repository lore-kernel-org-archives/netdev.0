From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] batman-adv: Fix rcu_barrier() miss due to double call_rcu() in TT code
Date: Fri, 17 May 2013 10:10:11 +0200
Message-ID: <1368778211-2142-2-git-send-email-ordex@autistici.org>
References: <1368778211-2142-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:20968 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab3EQIMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:12:10 -0400
In-Reply-To: <1368778211-2142-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

rcu_barrier() only waits for the currently scheduled rcu functions
to finish - it won't wait for any function scheduled via another
call_rcu() within an rcu scheduled function.

Unfortunately our batadv_tt_orig_list_entry_free_ref() does just that,
via a batadv_orig_node_free_ref() call, leading to our rcu_barrier()
call potentially missing such a batadv_orig_node_free_ref().

This patch fixes this issue by calling the batadv_orig_node_free_rcu()
directly from the rcu callback, removing the unnecessary, additional
call_rcu() layer here.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/originator.c        | 16 ++++++++++++++++
 net/batman-adv/originator.h        |  1 +
 net/batman-adv/translation-table.c |  7 ++++++-
 3 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 2f34525..fad1a20 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -156,12 +156,28 @@ static void batadv_orig_node_free_rcu(struct rcu_=
head *rcu)
 	kfree(orig_node);
 }
=20
+/**
+ * batadv_orig_node_free_ref - decrement the orig node refcounter and =
possibly
+ * schedule an rcu callback for freeing it
+ * @orig_node: the orig node to free
+ */
 void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node)
 {
 	if (atomic_dec_and_test(&orig_node->refcount))
 		call_rcu(&orig_node->rcu, batadv_orig_node_free_rcu);
 }
=20
+/**
+ * batadv_orig_node_free_ref_now - decrement the orig node refcounter =
and
+ * possibly free it (without rcu callback)
+ * @orig_node: the orig node to free
+ */
+void batadv_orig_node_free_ref_now(struct batadv_orig_node *orig_node)
+{
+	if (atomic_dec_and_test(&orig_node->refcount))
+		batadv_orig_node_free_rcu(&orig_node->rcu);
+}
+
 void batadv_originator_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 7df48fa..734e5a3 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -26,6 +26,7 @@ int batadv_originator_init(struct batadv_priv *bat_pr=
iv);
 void batadv_originator_free(struct batadv_priv *bat_priv);
 void batadv_purge_orig_ref(struct batadv_priv *bat_priv);
 void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node);
+void batadv_orig_node_free_ref_now(struct batadv_orig_node *orig_node)=
;
 struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_=
priv,
 					      const uint8_t *addr);
 struct batadv_neigh_node *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 5e89dee..9e87485 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -144,7 +144,12 @@ static void batadv_tt_orig_list_entry_free_rcu(str=
uct rcu_head *rcu)
 	struct batadv_tt_orig_list_entry *orig_entry;
=20
 	orig_entry =3D container_of(rcu, struct batadv_tt_orig_list_entry, rc=
u);
-	batadv_orig_node_free_ref(orig_entry->orig_node);
+
+	/* We are in an rcu callback here, therefore we cannot use
+	 * batadv_orig_node_free_ref() and its call_rcu():
+	 * An rcu_barrier() wouldn't wait for that to finish
+	 */
+	batadv_orig_node_free_ref_now(orig_entry->orig_node);
 	kfree(orig_entry);
 }
=20
--=20
1.8.1.5
