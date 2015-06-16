From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/2] batman-adv: Avoid u32 overflow during gateway select
Date: Tue, 16 Jun 2015 21:06:23 +0200
Message-ID: <1434481584-1275-2-git-send-email-antonio@meshcoding.com>
References: <1434481584-1275-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Ruben Wisniewski <ruben@freifunk-nrw.de>,
	Ruben Wisniewsi <ruben@vfn-nrw.de>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:24798 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932169AbbFPTIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 15:08:40 -0400
In-Reply-To: <1434481584-1275-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ruben Wisniewski <ruben@freifunk-nrw.de>

The gateway selection based on fast connections is using a single value
calculated from the average tq (0-255) and the download bandwidth (in
100Kibit). The formula for the first step (tq ** 2 * 10000 * bandwidth)
tends to overflow a u32 with low bandwidth settings like 50 [100KiBit]
and a tq value of over 92.

Changing this to a 64 bit unsigned integer allows to support a
bandwidth_down with up to ~2.8e10 [100KiBit] and a perfect tq of 255. This
is ~6.6 times higher than the maximum possible value of the gateway
announcement TVLV.

This problem only affects the non-default gw_sel_class 1.

Signed-off-by: Ruben Wisniewsi <ruben@vfn-nrw.de>
[sven@narfation.org: rewritten commit message, changed to kernel type]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 090828c..ca734f8 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -133,7 +133,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	struct batadv_neigh_node *router;
 	struct batadv_neigh_ifinfo *router_ifinfo;
 	struct batadv_gw_node *gw_node, *curr_gw = NULL;
-	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
+	uint64_t max_gw_factor = 0, tmp_gw_factor = 0;
 	uint32_t gw_divisor;
 	uint8_t max_tq = 0;
 	uint8_t tq_avg;
-- 
2.4.3
