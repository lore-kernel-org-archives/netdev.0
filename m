From: Patrick McHardy <kaber@trash.net>
Subject: [IFB]: Fix crash on input device removal
Date: Thu, 29 Mar 2007 18:30:48 +0200
Message-ID: <460BE9B8.8030901@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010507020600020006060201"
Cc: jamal <hadi@cyberus.ca>, Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47436 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933115AbXC2QYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 12:24:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010507020600020006060201
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix the crash reported in the "another critical bug ?" thread,
which turned out to be caused by a stale input_dev pointer.
The patch applies to current -git and latest -stable.


--------------010507020600020006060201
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IFB]: Fix crash on input device removal

The input_device pointer is not refcounted, which means the device may
disappear while packets are queued, causing a crash when ifb passes packets
with a stale skb->dev pointer to netif_rx().

Fix by storing the interface index instead and do a lookup where neccessary.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a08b2ee8faa15fc9dcb71f52219db60852909ccf
tree 1e99ccb62cdcd0ba6b672ccd654bf57287ca217b
parent 190a4408ecb577391ea5fbd1f90148a6992a5756
author Patrick McHardy <kaber@trash.net> Thu, 29 Mar 2007 18:20:38 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 29 Mar 2007 18:20:38 +0200

 drivers/net/ifb.c      |   35 +++++++++++++----------------------
 include/linux/skbuff.h |    5 +++--
 include/net/pkt_cls.h  |    7 +++++--
 net/core/dev.c         |    8 ++++----
 net/core/skbuff.c      |    2 +-
 net/sched/act_mirred.c |    2 +-
 6 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index ca2b21f..07b4c0d 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -96,17 +96,24 @@ static void ri_tasklet(unsigned long dev)
 		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
 		stats->tx_packets++;
 		stats->tx_bytes +=skb->len;
+
+		skb->dev = __dev_get_by_index(skb->iif);
+		if (!skb->dev) {
+			dev_kfree_skb(skb);
+			stats->tx_dropped++;
+			break;
+		}
+		skb->iif = _dev->ifindex;
+
 		if (from & AT_EGRESS) {
 			dp->st_rx_frm_egr++;
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
-
 			dp->st_rx_frm_ing++;
+			skb_pull(skb, skb->dev->hard_header_len);
 			netif_rx(skb);
-		} else {
-			dev_kfree_skb(skb);
-			stats->tx_dropped++;
-		}
+		} else
+			BUG();
 	}
 
 	if (netif_tx_trylock(_dev)) {
@@ -157,26 +164,10 @@ static int ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats->rx_packets++;
 	stats->rx_bytes+=skb->len;
 
-	if (!from || !skb->input_dev) {
-dropped:
+	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->iif) {
 		dev_kfree_skb(skb);
 		stats->rx_dropped++;
 		return ret;
-	} else {
-		/*
-		 * note we could be going
-		 * ingress -> egress or
-		 * egress -> ingress
-		*/
-		skb->dev = skb->input_dev;
-		skb->input_dev = dev;
-		if (from & AT_INGRESS) {
-			skb_pull(skb, skb->dev->hard_header_len);
-		} else {
-			if (!(from & AT_EGRESS)) {
-				goto dropped;
-			}
-		}
 	}
 
 	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len) {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..82f43ad 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -188,7 +188,7 @@ enum {
  *	@sk: Socket we are owned by
  *	@tstamp: Time we arrived
  *	@dev: Device we arrived on/are leaving by
- *	@input_dev: Device we arrived on
+ *	@iif: ifindex of device we arrived on
  *	@h: Transport layer header
  *	@nh: Network layer header
  *	@mac: Link layer header
@@ -235,7 +235,8 @@ struct sk_buff {
 	struct sock		*sk;
 	struct skb_timeval	tstamp;
 	struct net_device	*dev;
-	struct net_device	*input_dev;
+	int			iif;
+	/* 4 byte hole on 64 bit*/
 
 	union {
 		struct tcphdr	*th;
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index b902d24..02647fe 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -352,10 +352,13 @@ tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
 static inline int
 tcf_match_indev(struct sk_buff *skb, char *indev)
 {
+	struct net_device *dev;
+
 	if (indev[0]) {
-		if  (!skb->input_dev)
+		if  (!skb->iif)
 			return 0;
-		if (strcmp(indev, skb->input_dev->name))
+		dev = __dev_get_by_index(skb->iif);
+		if (!dev || strcmp(indev, dev->name))
 			return 0;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 5984b55..d44b8f1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1741,8 +1741,8 @@ static int ing_filter(struct sk_buff *skb)
 	if (dev->qdisc_ingress) {
 		__u32 ttl = (__u32) G_TC_RTTL(skb->tc_verd);
 		if (MAX_RED_LOOP < ttl++) {
-			printk(KERN_WARNING "Redir loop detected Dropping packet (%s->%s)\n",
-				skb->input_dev->name, skb->dev->name);
+			printk(KERN_WARNING "Redir loop detected Dropping packet (%d->%d)\n",
+				skb->iif, skb->dev->ifindex);
 			return TC_ACT_SHOT;
 		}
 
@@ -1775,8 +1775,8 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (!skb->tstamp.off_sec)
 		net_timestamp(skb);
 
-	if (!skb->input_dev)
-		skb->input_dev = skb->dev;
+	if (!skb->iif)
+		skb->iif = skb->dev->ifindex;
 
 	orig_dev = skb_bond(skb);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 702fa8f..87573ae 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -496,7 +496,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	n->tc_verd = SET_TC_VERD(skb->tc_verd,0);
 	n->tc_verd = CLR_TC_OK2MUNGE(n->tc_verd);
 	n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
-	C(input_dev);
+	C(iif);
 #endif
 	skb_copy_secmark(n, skb);
 #endif
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 68f26cb..3e93683 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -198,7 +198,7 @@ bad_mirred:
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
 	skb2->dev = dev;
-	skb2->input_dev = skb->dev;
+	skb2->iif = skb->dev->ifindex;
 	dev_queue_xmit(skb2);
 	spin_unlock(&m->tcf_lock);
 	return m->tcf_action;

--------------010507020600020006060201--
