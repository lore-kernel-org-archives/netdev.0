From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 1/5] batman-adv: Check skb size before using encapsulated ETH+VLAN header
Date: Tue, 26 Apr 2016 11:27:15 +0800
Message-ID: <1461641239-7097-2-git-send-email-a@unstable.cc>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:48163 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbcDZD16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 23:27:58 -0400
In-Reply-To: <1461641239-7097-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The encapsulated ethernet and VLAN header may be outside the received
ethernet frame. Thus the skb buffer size has to be checked before it can be
parsed to find out if it encapsulates another batman-adv packet.

Fixes: 420193573f11 ("batman-adv: softif bridge loop avoidance")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/soft-interface.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 0710379491bf..8a136b6a1ff0 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -408,11 +408,17 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	 */
 	nf_reset(skb);
 
+	if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
+		goto dropped;
+
 	vid = batadv_get_vid(skb, 0);
 	ethhdr = eth_hdr(skb);
 
 	switch (ntohs(ethhdr->h_proto)) {
 	case ETH_P_8021Q:
+		if (!pskb_may_pull(skb, VLAN_ETH_HLEN))
+			goto dropped;
+
 		vhdr = (struct vlan_ethhdr *)skb->data;
 
 		if (vhdr->h_vlan_encapsulated_proto != ethertype)
@@ -424,8 +430,6 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	}
 
 	/* skb->dev & skb->pkt_type are set here */
-	if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
-		goto dropped;
 	skb->protocol = eth_type_trans(skb, soft_iface);
 
 	/* should not be necessary anymore as we use skb_pull_rcsum()
-- 
2.8.1
