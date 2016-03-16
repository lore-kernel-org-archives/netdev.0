From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 2/4] vxlan: move fdb code to common location in vxlan_xmit
Date: Wed, 16 Mar 2016 17:51:10 +0100
Message-ID: <3788bb116d11857a3658c5fd8692a7ca8eda2fbd.1458146189.git.jbenc@redhat.com>
References: <cover.1458146189.git.jbenc@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932550AbcCPQvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 12:51:25 -0400
In-Reply-To: <cover.1458146189.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle VXLAN_F_COLLECT_METADATA before VXLAN_F_PROXY. The latter does not
make sense with the former, as it needs populated fdb which does not happen
in metadata mode.

After this cleanup, the fdb code in vxlan_xmit is moved to a common location
and can be later skipped for VXLAN-GPE which does not necessarily carry
inner Ethernet header.

v2: changed commit description to not reference L3 mode

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bfa1e2a5ba9e..f75786c4bd40 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2107,9 +2107,17 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	info = skb_tunnel_info(skb);
 
 	skb_reset_mac_header(skb);
-	eth = eth_hdr(skb);
 
-	if ((vxlan->flags & VXLAN_F_PROXY)) {
+	if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
+		if (info && info->mode & IP_TUNNEL_INFO_TX)
+			vxlan_xmit_one(skb, dev, NULL, false);
+		else
+			kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (vxlan->flags & VXLAN_F_PROXY) {
+		eth = eth_hdr(skb);
 		if (ntohs(eth->h_proto) == ETH_P_ARP)
 			return arp_reduce(dev, skb);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -2124,18 +2132,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 				    msg->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION)
 					return neigh_reduce(dev, skb);
 		}
-		eth = eth_hdr(skb);
 #endif
 	}
 
-	if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
-		if (info && info->mode & IP_TUNNEL_INFO_TX)
-			vxlan_xmit_one(skb, dev, NULL, false);
-		else
-			kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
-
+	eth = eth_hdr(skb);
 	f = vxlan_find_mac(vxlan, eth->h_dest);
 	did_rsc = false;
 
-- 
1.8.3.1
