From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Subject: [PATCH] macvlan: Remove an unnecessary goto
Date: Mon, 18 Mar 2013 22:03:39 +0900
Message-ID: <20130318130339.4F76662C03B@msa106.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use else instead.

Signed-off-by: Kusanagi Kouichi <slash@ac.auone-net.jp>
---
 drivers/net/macvlan.c |   27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 73abbc1..92d16ad 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -251,31 +251,30 @@ out:
 static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
-	const struct macvlan_port *port = vlan->port;
-	const struct macvlan_dev *dest;
-	__u8 ip_summed = skb->ip_summed;
 
 	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
 		const struct ethhdr *eth = (void *)skb->data;
+		const struct macvlan_port * const port = vlan->port;
+		const __u8 ip_summed = skb->ip_summed;
+
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		/* send to other bridge ports directly */
 		if (is_multicast_ether_addr(eth->h_dest)) {
+			/* send to other bridge ports directly */
 			macvlan_broadcast(skb, port, dev, MACVLAN_MODE_BRIDGE);
-			goto xmit_world;
+		} else {
+			const struct macvlan_dev * const dest =
+				macvlan_hash_lookup(port, eth->h_dest);
+			if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
+				/* send to lowerdev first for its network taps */
+				dev_forward_skb(vlan->lowerdev, skb);
+				return NET_XMIT_SUCCESS;
+			}
 		}
 
-		dest = macvlan_hash_lookup(port, eth->h_dest);
-		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
-			/* send to lowerdev first for its network taps */
-			dev_forward_skb(vlan->lowerdev, skb);
-
-			return NET_XMIT_SUCCESS;
-		}
+		skb->ip_summed = ip_summed;
 	}
 
-xmit_world:
-	skb->ip_summed = ip_summed;
 	skb->dev = vlan->lowerdev;
 	return dev_queue_xmit(skb);
 }
-- 
1.7.10.4
