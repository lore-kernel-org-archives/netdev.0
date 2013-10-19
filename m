From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/18] batman-adv: make the GW module correctly talk to the new VLAN-TT
Date: Sun, 20 Oct 2013 00:22:00 +0200
Message-ID: <1382221330-3769-9-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:10206 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab3JSWXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:23:04 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

The gateway code is now adapted in order to correctly
interact with the Translation Table component by using the
vlan ID

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index a920946..4ed410f 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -726,7 +726,20 @@ bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 	return true;
 }
 
-/* this call might reallocate skb data */
+/**
+ * batadv_gw_out_of_range - check if the dhcp request destination is the best gw
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the outgoing packet
+ *
+ * Check if the skb is a DHCP request and if it is sent to the current best GW
+ * server. Due to topology changes it may be the case that the GW server
+ * previously selected is not the best one anymore.
+ *
+ * Returns true if the packet destination is unicast and it is not the best gw,
+ * false otherwise.
+ *
+ * This call might reallocate skb data.
+ */
 bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 			    struct sk_buff *skb)
 {
@@ -737,6 +750,9 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 	bool ret, out_of_range = false;
 	unsigned int header_len = 0;
 	uint8_t curr_tq_avg;
+	unsigned short vid;
+
+	vid = batadv_get_vid(skb, 0);
 
 	ret = batadv_gw_is_dhcp_target(skb, &header_len);
 	if (!ret)
@@ -744,8 +760,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 
 	ethhdr = (struct ethhdr *)skb->data;
 	orig_dst_node = batadv_transtable_search(bat_priv, ethhdr->h_source,
-						 ethhdr->h_dest,
-						 BATADV_NO_FLAGS);
+						 ethhdr->h_dest, vid);
 	if (!orig_dst_node)
 		goto out;
 
-- 
1.8.4
