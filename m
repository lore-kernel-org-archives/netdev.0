From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/14] batman-adv: Avoid u32 overflow during gateway select
Date: Tue,  4 Aug 2015 18:35:22 +0200
Message-ID: <1438706134-3492-3-git-send-email-antonio__17605.7919431061$1438707389$gmane$org@meshcoding.com>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Ruben Wisniewski <ruben@freifunk-nrw.de>,
	Ruben Wisniewsi <ruben@vfn-nrw.de>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:47723 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753780AbbHDQ4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:56:21 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
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
[sven@narfation.org: rewritten commit message]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index e1e1f31..4ac24d8 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -153,7 +153,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	struct batadv_neigh_node *router;
 	struct batadv_neigh_ifinfo *router_ifinfo;
 	struct batadv_gw_node *gw_node, *curr_gw = NULL;
-	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
+	uint64_t max_gw_factor = 0, tmp_gw_factor = 0;
 	uint8_t max_tq = 0;
 	uint8_t tq_avg;
 	struct batadv_orig_node *orig_node;
-- 
2.5.0
