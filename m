From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 2/2] bridge: Fix handling stacked vlan tags
Date: Thu, 27 Mar 2014 21:46:56 +0900
Message-ID: <1395924416-12325-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

If a bridge with vlan_filtering enabled receives frames with stacked
vlan tags, i.e., they have two vlan tags, br_vlan_untag() strips not
only the outer tag but also the inner tag.

br_vlan_untag() is called only from br_handle_vlan(), and in this case,
it is enough to set skb->vlan_tci to 0 here, because vlan_tci has already
been set before calling br_handle_vlan().

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_vlan.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 44f31af..c77eed5 100644
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
