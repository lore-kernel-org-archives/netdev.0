From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCHv3 2/4] macvlan: cleanup rx statistics
Date: Thu, 26 Nov 2009 17:07:09 +0100
Message-ID: <1259251631-11617-3-git-send-email-arnd@arndb.de>
References: <1259251631-11617-1-git-send-email-arnd@arndb.de>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:53476 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760702AbZKZQIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 11:08:34 -0500
In-Reply-To: <1259251631-11617-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have very similar code for rx statistics in
two places in the macvlan driver, with a third
one being added in the next patch.

Consolidate them into one function to improve
overall readability of the driver.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/macvlan.c |   70 ++++++++++++++++++++++++++++--------------------
 1 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index ae2b5c7..1e7faf9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -116,42 +116,58 @@ static int macvlan_addr_busy(const struct macvlan_port *port,
 	return 0;
 }
 
+static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
+				    unsigned int len, bool success,
+				    bool multicast)
+{
+	struct macvlan_rx_stats *rx_stats;
+
+	rx_stats = per_cpu_ptr(vlan->rx_stats, smp_processor_id());
+	if (likely(success)) {
+		rx_stats->rx_packets++;;
+		rx_stats->rx_bytes += len;
+		if (multicast)
+			rx_stats->multicast++;
+	} else {
+		rx_stats->rx_errors++;
+	}
+}
+
+static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
+				 const struct ethhdr *eth)
+{
+	if (!skb)
+		return NET_RX_DROP;
+
+	skb->dev = dev;
+	if (!compare_ether_addr_64bits(eth->h_dest,
+				       dev->broadcast))
+		skb->pkt_type = PACKET_BROADCAST;
+	else
+		skb->pkt_type = PACKET_MULTICAST;
+
+	return netif_rx(skb);
+}
+
 static void macvlan_broadcast(struct sk_buff *skb,
 			      const struct macvlan_port *port)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
 	struct hlist_node *n;
-	struct net_device *dev;
 	struct sk_buff *nskb;
 	unsigned int i;
-	struct macvlan_rx_stats *rx_stats;
+	int err;
 
 	if (skb->protocol == htons(ETH_P_PAUSE))
 		return;
 
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
-			dev = vlan->dev;
-			rx_stats = per_cpu_ptr(vlan->rx_stats, smp_processor_id());
-
 			nskb = skb_clone(skb, GFP_ATOMIC);
-			if (nskb == NULL) {
-				rx_stats->rx_errors++;
-				continue;
-			}
-
-			rx_stats->rx_bytes += skb->len + ETH_HLEN;
-			rx_stats->rx_packets++;
-			rx_stats->multicast++;
-
-			nskb->dev = dev;
-			if (!compare_ether_addr_64bits(eth->h_dest, dev->broadcast))
-				nskb->pkt_type = PACKET_BROADCAST;
-			else
-				nskb->pkt_type = PACKET_MULTICAST;
-
-			netif_rx(nskb);
+			err = macvlan_broadcast_one(nskb, vlan->dev, eth);
+			macvlan_count_rx(vlan, skb->len + ETH_HLEN,
+					 err == NET_RX_SUCCESS, 1);
 		}
 	}
 }
@@ -163,7 +179,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	const struct macvlan_port *port;
 	const struct macvlan_dev *vlan;
 	struct net_device *dev;
-	struct macvlan_rx_stats *rx_stats;
+	unsigned int len;
 
 	port = rcu_dereference(skb->dev->macvlan_port);
 	if (port == NULL)
@@ -183,15 +199,11 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 		kfree_skb(skb);
 		return NULL;
 	}
-	rx_stats = per_cpu_ptr(vlan->rx_stats, smp_processor_id());
+	len = skb->len + ETH_HLEN;
 	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (skb == NULL) {
-		rx_stats->rx_errors++;
+	macvlan_count_rx(vlan, len, skb != NULL, 0);
+	if (!skb)
 		return NULL;
-	}
-
-	rx_stats->rx_bytes += skb->len + ETH_HLEN;
-	rx_stats->rx_packets++;
 
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
-- 
1.6.3.3

