From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 3/5] vxlan: move fdb code to common location in vxlan_xmit
Date: Fri, 26 Feb 2016 08:48:39 +0100
Message-ID: <75f3094c1be66df9236270439427b49aa733d907.1456472746.git.jbenc@redhat.com>
References: <cover.1456472746.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753637AbcBZHs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 02:48:59 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 5096C7EBAE
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:48:59 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-33.brq.redhat.com [10.40.204.33])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1Q7mrUw021506
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 02:48:58 -0500
In-Reply-To: <cover.1456472746.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle VXLAN_F_COLLECT_METADATA before VXLAN_F_PROXY. The latter does not
make sense with the former, as it needs populated fdb which does not happen
in metadata mode.

After this cleanup, the fdb code in vxlan_xmit is moved to a common location
and can be later skipped for L3 mode vxlan tunnels.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 49fcca8d8a8e..029e0e5b0b2b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2139,9 +2139,17 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -2156,18 +2164,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
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
