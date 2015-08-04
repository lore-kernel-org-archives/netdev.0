From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/14] batman-adv: initialize up/down values when adding a gateway
Date: Tue,  4 Aug 2015 18:35:32 +0200
Message-ID: <1438706134-3492-13-git-send-email-antonio__35550.0272861265$1438707254$gmane$org@meshcoding.com>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:9835 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753419AbbHDQyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:54:00 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

Without this initialization, gateways which actually announce up/down
bandwidth of 0/0 could be added. If these nodes get purged via
_batadv_purge_orig() later, the gw_node structure does not get removed
since batadv_gw_node_delete() updates the gw_node with up/down
bandwidth of 0/0, and the updating function then discards the change
and does not free gw_node.

This results in leaking the gw_node structures, which references other
structures: gw_node -> orig_node -> orig_node_ifinfo -> hardif. When
removing the interface later, the open reference on the hardif may cause
hangs with the infamous "unregister_netdevice: waiting for mesh1 to
become free. Usage count = 1" message.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_client.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 4ac24d8..6012e2b 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -435,6 +435,8 @@ static void batadv_gw_node_add(struct batadv_priv *bat_priv,
 
 	INIT_HLIST_NODE(&gw_node->list);
 	gw_node->orig_node = orig_node;
+	gw_node->bandwidth_down = ntohl(gateway->bandwidth_down);
+	gw_node->bandwidth_up = ntohl(gateway->bandwidth_up);
 	atomic_set(&gw_node->refcount, 1);
 
 	spin_lock_bh(&bat_priv->gw.list_lock);
-- 
2.5.0
