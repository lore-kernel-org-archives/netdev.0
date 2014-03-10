From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC 1/3] bridge: Fix handling stacked vlan tags
Date: Mon, 10 Mar 2014 17:11:04 +0900
Message-ID: <1394439067-10477-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:57867 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbaCJILW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 04:11:22 -0400
In-Reply-To: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a bridge with vlan_filtering enabled receives frames with stacked
vlan tags, i.e., they have two vlan tags, br_vlan_untag() strips not
only the outer tag but also the inner tag.

br_vlan_untag() is called only from br_handle_vlan(), and in this case,
it is enough to set skb->vlan_tci to 0 here, because vlan_tci should have
been set before calling br_handle_vlan() (by __netif_receive_skb_core() or
br_allowed_ingress()).

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_vlan.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 8249ca7..cda93e2 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -119,22 +119,6 @@ static void __vlan_flush(struct net_port_vlans *v)
 	kfree_rcu(v, rcu);
 }
 
-/* Strip the tag from the packet.  Will return skb with tci set 0.  */
-static struct sk_buff *br_vlan_untag(struct sk_buff *skb)
-{
-	if (skb->protocol != htons(ETH_P_8021Q)) {
-		skb->vlan_tci = 0;
-		return skb;
-	}
-
-	skb->vlan_tci = 0;
-	skb = vlan_untag(skb);
-	if (skb)
-		skb->vlan_tci = 0;
-
-	return skb;
-}
-
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			       const struct net_port_vlans *pv,
 			       struct sk_buff *skb)
@@ -150,7 +134,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 	 */
 	br_vlan_get_tag(skb, &vid);
 	if (test_bit(vid, pv->untagged_bitmap))
-		skb = br_vlan_untag(skb);
+		skb->vlan_tci = 0;
 
 out:
 	return skb;
-- 
1.8.1.2
