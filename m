From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 5/6] batman-adv: fix multicast counter when purging originators
Date: Tue,  6 Jan 2015 12:10:04 +0100
Message-ID: <1420542605-28865-6-git-send-email-antonio@meshcoding.com>
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
Received: from s3.neomailbox.net ([178.209.62.157]:16906 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751AbbAFLKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 06:10:50 -0500
In-Reply-To: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

When purging an orig_node we should only decrease counter tracking the
number of nodes without multicast optimizations support if it was
increased through this orig_node before.

A not yet quite initialized orig_node (meaning it did not have its turn
in the mcast-tvlv handler so far) which gets purged would not adhere to
this and will lead to a counter imbalance.

=46ixing this by adding a check whether the orig_node is mcast-initaliz=
ed
before decreasing the counter in the mcast-orig_node-purging routine.

Introduced by 60432d756cf06e597ef9da511402dd059b112447
("batman-adv: Announce new capability via multicast TVLV")

Reported-by: Tobias Hachmer <tobias@hachmer.de>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/multicast.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index d3503fb..b24e4bb 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -740,7 +740,8 @@ void batadv_mcast_purge_orig(struct batadv_orig_nod=
e *orig)
 {
 	struct batadv_priv *bat_priv =3D orig->bat_priv;
=20
-	if (!(orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST))
+	if (!(orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST) &&
+	    orig->capa_initialized & BATADV_ORIG_CAPA_HAS_MCAST)
 		atomic_dec(&bat_priv->mcast.num_disabled);
=20
 	batadv_mcast_want_unsnoop_update(bat_priv, orig, BATADV_NO_FLAGS);
--=20
2.2.1
