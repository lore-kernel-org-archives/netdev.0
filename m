From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 2/4] vxlan: move fdb code to common location in vxlan_xmit
Date: Tue,  5 Apr 2016 14:47:11 +0200
Message-ID: <5a92777074e01b12e6a1e8c91a09723e91a3e4f9.1459860270.git.jbenc@redhat.com>
References: <cover.1459860270.git.jbenc@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbcDEMrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 08:47:31 -0400
In-Reply-To: <cover.1459860270.git.jbenc@redhat.com>
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
index 6bd5b874ead7..d62eebaa9720 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2106,9 +2106,17 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -2123,18 +2131,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
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
