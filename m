From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  1/12] Fix NET/ROM rebuild header mess
Date: Sun, 11 Sep 2005 23:18:35 +0100
Message-ID: <20050911221835.GA9273@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For reason that probably nobody recalls NET/ROM does it's actual packet
transmission in nr_rebuild_header and even treats invocation of it's
hard_start_xmit method nr_xmit as a bug.  Fix that by splitting the
job done by nr_rebuild_header into two halves.  Along with that we now
also can get rid of the silly clone of the skb on transmit.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/netrom/nr_dev.c |   44 +++++++++++++++-----------------------------
 1 files changed, 15 insertions(+), 29 deletions(-)

Index: linux-cvs/net/netrom/nr_dev.c
===================================================================
--- linux-cvs.orig/net/netrom/nr_dev.c
+++ linux-cvs/net/netrom/nr_dev.c
@@ -71,15 +71,10 @@ int nr_rx_ip(struct sk_buff *skb, struct
 
 static int nr_rebuild_header(struct sk_buff *skb)
 {
-	struct net_device *dev = skb->dev;
-	struct net_device_stats *stats = netdev_priv(dev);
-	struct sk_buff *skbn;
 	unsigned char *bp = skb->data;
-	int len;
 
-	if (arp_find(bp + 7, skb)) {
+	if (arp_find(bp + 7, skb))
 		return 1;
-	}
 
 	bp[6] &= ~AX25_CBIT;
 	bp[6] &= ~AX25_EBIT;
@@ -90,27 +85,7 @@ static int nr_rebuild_header(struct sk_b
 	bp[6] |= AX25_EBIT;
 	bp[6] |= AX25_SSSID_SPARE;
 
-	if ((skbn = skb_clone(skb, GFP_ATOMIC)) == NULL) {
-		kfree_skb(skb);
-		return 1;
-	}
-
-	if (skb->sk != NULL)
-		skb_set_owner_w(skbn, skb->sk);
-
-	kfree_skb(skb);
-
-	len = skbn->len;
-
-	if (!nr_route_frame(skbn, NULL)) {
-		kfree_skb(skbn);
-		stats->tx_errors++;
-	}
-
-	stats->tx_packets++;
-	stats->tx_bytes += len;
-
-	return 1;
+	return 0;
 }
 
 #else
@@ -186,8 +161,19 @@ static int nr_close(struct net_device *d
 static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = netdev_priv(dev);
-	dev_kfree_skb(skb);
-	stats->tx_errors++;
+	unsigned int len;
+
+	len = skb->len;
+
+	if (!nr_route_frame(skb, NULL)) {
+		kfree_skb(skb);
+		stats->tx_errors++;
+		return 0;
+	}
+
+	stats->tx_packets++;
+	stats->tx_bytes += len;
+
 	return 0;
 }
 
