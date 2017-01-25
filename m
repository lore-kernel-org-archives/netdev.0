From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] bridge: move maybe_deliver_addr()
	inside #ifdef
Date: Wed, 25 Jan 2017 23:29:33 +0100
Message-ID: <20170125222950.1352566-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Felix Fietkau <nbd@nbd.name>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

The only caller of this new function is inside of an #ifdef checking
for CONFIG_BRIDGE_IGMP_SNOOPING, so we should move the implementation
there too, in order to avoid this harmless warning:

net/bridge/br_forward.c:177:13: error: 'maybe_deliver_addr' defined but not used [-Werror=unused-function]

Fixes: 6db6f0eae605 ("bridge: multicast to unicast")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/bridge/br_forward.c | 50 ++++++++++++++++++++++++-------------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index a0f9d0037d24..5a1f8ef49899 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -174,31 +174,6 @@ static struct net_bridge_port *maybe_deliver(
 	return p;
 }
 
-static void maybe_deliver_addr(struct net_bridge_port *p, struct sk_buff *skb,
-			       const unsigned char *addr, bool local_orig)
-{
-	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
-	const unsigned char *src = eth_hdr(skb)->h_source;
-
-	if (!should_deliver(p, skb))
-		return;
-
-	/* Even with hairpin, no soliloquies - prevent breaking IPv6 DAD */
-	if (skb->dev == p->dev && ether_addr_equal(src, addr))
-		return;
-
-	skb = skb_copy(skb, GFP_ATOMIC);
-	if (!skb) {
-		dev->stats.tx_dropped++;
-		return;
-	}
-
-	if (!is_broadcast_ether_addr(addr))
-		memcpy(eth_hdr(skb)->h_dest, addr, ETH_ALEN);
-
-	__br_forward(p, skb, local_orig);
-}
-
 /* called under rcu_read_lock */
 void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	      enum br_pkt_type pkt_type, bool local_rcv, bool local_orig)
@@ -245,6 +220,31 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
 }
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+static void maybe_deliver_addr(struct net_bridge_port *p, struct sk_buff *skb,
+			       const unsigned char *addr, bool local_orig)
+{
+	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
+	const unsigned char *src = eth_hdr(skb)->h_source;
+
+	if (!should_deliver(p, skb))
+		return;
+
+	/* Even with hairpin, no soliloquies - prevent breaking IPv6 DAD */
+	if (skb->dev == p->dev && ether_addr_equal(src, addr))
+		return;
+
+	skb = skb_copy(skb, GFP_ATOMIC);
+	if (!skb) {
+		dev->stats.tx_dropped++;
+		return;
+	}
+
+	if (!is_broadcast_ether_addr(addr))
+		memcpy(eth_hdr(skb)->h_dest, addr, ETH_ALEN);
+
+	__br_forward(p, skb, local_orig);
+}
+
 /* called with rcu_read_lock */
 void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 			struct sk_buff *skb,
-- 
2.9.0
