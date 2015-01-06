From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 4/6] batman-adv: fix counter for multicast supporting nodes
Date: Tue,  6 Jan 2015 12:10:03 +0100
Message-ID: <1420542605-28865-5-git-send-email-antonio@meshcoding.com>
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
Received: from s3.neomailbox.net ([178.209.62.157]:25020 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939AbbAFLKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 06:10:49 -0500
In-Reply-To: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

A miscounting of nodes having multicast optimizations enabled can lead
to multicast packet loss in the following scenario:

If the first OGM a node receives from another one has no multicast
optimizations support (no multicast tvlv) then we are missing to
increase the counter. This potentially leads to the wrong assumption
that we could safely use multicast optimizations.

=46ixings this by increasing the counter if the initial OGM has the
multicast TVLV unset, too.

Introduced by 60432d756cf06e597ef9da511402dd059b112447
("batman-adv: Announce new capability via multicast TVLV")

Reported-by: Tobias Hachmer <tobias@hachmer.de>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/multicast.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index ab6bb2a..d3503fb 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -685,11 +685,13 @@ static void batadv_mcast_tvlv_ogm_handler_v1(stru=
ct batadv_priv *bat_priv,
 		if (orig_initialized)
 			atomic_dec(&bat_priv->mcast.num_disabled);
 		orig->capabilities |=3D BATADV_ORIG_CAPA_HAS_MCAST;
-	/* If mcast support is being switched off increase the disabled
-	 * mcast node counter.
+	/* If mcast support is being switched off or if this is an initial
+	 * OGM without mcast support then increase the disabled mcast
+	 * node counter.
 	 */
 	} else if (!orig_mcast_enabled &&
-		   orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST) {
+		   (orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST ||
+		    !orig_initialized)) {
 		atomic_inc(&bat_priv->mcast.num_disabled);
 		orig->capabilities &=3D ~BATADV_ORIG_CAPA_HAS_MCAST;
 	}
--=20
2.2.1
