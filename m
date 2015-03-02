From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 03/15] rose: Transmit packets in rose_xmit not rose_rebuild_header
Date: Mon, 02 Mar 2015 00:02:19 -0600
Message-ID: <871tl89btg.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Patterned after the similar code in net/rom this turns out
to be a trivial obviously correct transmformation.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/rose/rose_dev.c | 38 +++++++++++---------------------------
 1 file changed, 11 insertions(+), 27 deletions(-)

diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 24d2b40b6c6b..90209c1fa49b 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -59,38 +59,14 @@ static int rose_header(struct sk_buff *skb, struct net_device *dev,
 static int rose_rebuild_header(struct sk_buff *skb)
 {
 #ifdef CONFIG_INET
-	struct net_device *dev = skb->dev;
-	struct net_device_stats *stats = &dev->stats;
 	unsigned char *bp = (unsigned char *)skb->data;
-	struct sk_buff *skbn;
-	unsigned int len;
 
 	if (arp_find(bp + 7, skb)) {
 		return 1;
 	}
 
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
-	if (!rose_route_frame(skbn, NULL)) {
-		kfree_skb(skbn);
-		stats->tx_errors++;
-		return 1;
-	}
-
-	stats->tx_packets++;
-	stats->tx_bytes += len;
 #endif
-	return 1;
+	return 0;
 }
 
 static int rose_set_mac_address(struct net_device *dev, void *addr)
@@ -137,13 +113,21 @@ static int rose_close(struct net_device *dev)
 static netdev_tx_t rose_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
+	unsigned int len = skb->len;
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "ROSE: rose_xmit - called when iface is down\n");
 		return NETDEV_TX_BUSY;
 	}
-	dev_kfree_skb(skb);
-	stats->tx_errors++;
+
+	if (!rose_route_frame(skb, NULL)) {
+		dev_kfree_skb(skb);
+		stats->tx_errors++;
+		return NETDEV_TX_OK;
+	}
+
+	stats->tx_packets++;
+	stats->tx_bytes += len;
 	return NETDEV_TX_OK;
 }
 
-- 
2.2.1

