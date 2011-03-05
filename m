From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 18/28] batman-adv: Increase orig_node refcount before releasing rcu read lock
Date: Sat,  5 Mar 2011 13:28:32 +0100
Message-ID: <1299328122-21468-19-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@ascom.ch>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36323 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332Ab1CEMaC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:02 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@ascom.ch>

When unicast_send_skb() is increasing the orig_node's refcount another
thread might have been freeing this orig_node already. We need to
increase the refcount in the rcu read lock protected area to avoid that=
=2E

Signed-off-by: Linus L=C3=BCssing <linus.luessing@ascom.ch>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c |    3 +++
 net/batman-adv/unicast.c        |    5 ++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index a3e842f..41eba8a 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -54,6 +54,9 @@ void *gw_get_selected(struct bat_priv *bat_priv)
=20
 	orig_node =3D curr_gateway_tmp->orig_node;
=20
+	if (orig_node)
+		kref_get(&orig_node->refcount);
+
 out:
 	rcu_read_unlock();
 	return orig_node;
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 7ca994c..0603cea 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -293,10 +293,9 @@ int unicast_send_skb(struct sk_buff *skb, struct b=
at_priv *bat_priv)
 	spin_lock_bh(&bat_priv->orig_hash_lock);
=20
 	/* get routing information */
-	if (is_multicast_ether_addr(ethhdr->h_dest))
+	if (is_multicast_ether_addr(ethhdr->h_dest)) {
 		orig_node =3D (struct orig_node *)gw_get_selected(bat_priv);
-		if (orig_node) {
-			kref_get(&orig_node->refcount);
+		if (orig_node)
 			goto find_router;
 	}
=20
--=20
1.7.2.3

