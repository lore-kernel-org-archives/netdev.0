From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 1/2] bridge: Fix inabillity to retrieve vlan tags when tx offload is disabled
Date: Thu, 27 Mar 2014 21:46:55 +0900
Message-ID: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:49601 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754893AbaC0MrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:47:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge vlan code (br_vlan_get_tag()) assumes that all frames have vlan_tci
if they are tagged, but if vlan tx offload is manually disabled on bridge
device and frames are sent from vlan device on the bridge device, the tags
are embedded in skb->data and they break this assumption.
Extract embedded vlan tags and move them to vlan_tci at ingress.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_device.c |  6 +++---
 net/bridge/br_vlan.c   | 12 ++++++++++++
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 63f0455..8fe8b71 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -49,14 +49,14 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
-	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb, &vid))
-		goto out;
-
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
+	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb, &vid))
+		goto out;
+
 	if (is_broadcast_ether_addr(dest))
 		br_flood_deliver(br, skb, false);
 	else if (is_multicast_ether_addr(dest)) {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 8249ca7..44f31af 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -174,6 +174,18 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	if (!v)
 		return false;
 
+	/* If vlan tx offload is disabled on bridge device and frame was
+	 * sent from vlan device on the bridge device, it does not have
+	 * HW accelerated vlan tag.
+	 */
+	if (unlikely(!vlan_tx_tag_present(skb) &&
+		     (skb->protocol == htons(ETH_P_8021Q) ||
+		      skb->protocol == htons(ETH_P_8021AD)))) {
+		skb = vlan_untag(skb);
+		if (unlikely(!skb))
+			return false;
+	}
+
 	err = br_vlan_get_tag(skb, vid);
 	if (!*vid) {
 		u16 pvid = br_get_pvid(v);
-- 
1.8.1.2
