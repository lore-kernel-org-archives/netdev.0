From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 01/10] batman-adv: fix soft-interface MTU computation
Date: Mon, 17 Feb 2014 21:48:40 +0100
Message-ID: <1392670129-2498-2-git-send-email-antonio@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:19169 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaBQUwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:52:55 -0500
In-Reply-To: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current MTU computation always returns a value
smaller than 1500bytes even if the real interfaces
have an MTU large enough to compensate the batman-adv
overhead.

Fix the computation by properly returning the highest
admitted value.

Introduced by a19d3d85e1b854e4a483a55d740a42458085560d
("batman-adv: limit local translation table max size")

Reported-by: Russell Senior <russell@personaltelco.net>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/hard-interface.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 3d417d3..b851cc5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -241,7 +241,7 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 {
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	const struct batadv_hard_iface *hard_iface;
-	int min_mtu = ETH_DATA_LEN;
+	int min_mtu = INT_MAX;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -256,8 +256,6 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 	}
 	rcu_read_unlock();
 
-	atomic_set(&bat_priv->packet_size_max, min_mtu);
-
 	if (atomic_read(&bat_priv->fragmentation) == 0)
 		goto out;
 
@@ -268,13 +266,21 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 	min_mtu = min_t(int, min_mtu, BATADV_FRAG_MAX_FRAG_SIZE);
 	min_mtu -= sizeof(struct batadv_frag_packet);
 	min_mtu *= BATADV_FRAG_MAX_FRAGMENTS;
-	atomic_set(&bat_priv->packet_size_max, min_mtu);
-
-	/* with fragmentation enabled we can fragment external packets easily */
-	min_mtu = min_t(int, min_mtu, ETH_DATA_LEN);
 
 out:
-	return min_mtu - batadv_max_header_len();
+	/* report to the other components the maximum amount of bytes that
+	 * batman-adv can send over the wire (without considering the payload
+	 * overhead). For example, this value is used by TT to compute the
+	 * maximum local table table size
+	 */
+	atomic_set(&bat_priv->packet_size_max, min_mtu);
+
+	/* the real soft-interface MTU is computed by removing the payload
+	 * overhead from the maximum amount of bytes that was just computed.
+	 *
+	 * However batman-adv does not support MTUs bigger than ETH_DATA_LEN
+	 */
+	return min_t(int, min_mtu - batadv_max_header_len(), ETH_DATA_LEN);
 }
 
 /* adjusts the MTU if a new interface with a smaller MTU appeared. */
-- 
1.8.5.3
