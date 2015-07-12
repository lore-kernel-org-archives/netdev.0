From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 8/8] can: replace timestamp as unique skb attribute
Date: Sun, 12 Jul 2015 21:18:11 +0200
Message-ID: <1436728691-1145-9-git-send-email-mkl@pengutronix.de>
References: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

Commit 514ac99c64b "can: fix multiple delivery of a single CAN frame for
overlapping CAN filters" requires the skb->tstamp to be set to check for
identical CAN skbs.

Without timestamping to be required by user space applications this timestamp
was not generated which lead to commit 36c01245eb8 "can: fix loss of CAN frames
in raw_rcv" - which forces the timestamp to be set in all CAN related skbuffs
by introducing several __net_timestamp() calls.

This forces e.g. out of tree drivers which are not using alloc_can{,fd}_skb()
to add __net_timestamp() after skbuff creation to prevent the frame loss fixed
in mainline Linux.

This patch removes the timestamp dependency and uses an atomic counter to
create an unique identifier together with the skbuff pointer.

Btw: the new skbcnt element introduced in struct can_skb_priv has to be
initialized with zero in out-of-tree drivers which are not using
alloc_can{,fd}_skb() too.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c   |  7 ++-----
 drivers/net/can/slcan.c |  2 +-
 drivers/net/can/vcan.c  |  3 ---
 include/linux/can/skb.h |  2 ++
 net/can/af_can.c        | 12 +++++++-----
 net/can/bcm.c           |  2 ++
 net/can/raw.c           |  7 ++++---
 7 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index e9b1810d319f..aede704605c6 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -440,9 +440,6 @@ unsigned int can_get_echo_skb(struct net_device *dev, unsigned int idx)
 		struct can_frame *cf = (struct can_frame *)skb->data;
 		u8 dlc = cf->can_dlc;
 
-		if (!(skb->tstamp.tv64))
-			__net_timestamp(skb);
-
 		netif_rx(priv->echo_skb[idx]);
 		priv->echo_skb[idx] = NULL;
 
@@ -578,7 +575,6 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
 	if (unlikely(!skb))
 		return NULL;
 
-	__net_timestamp(skb);
 	skb->protocol = htons(ETH_P_CAN);
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -589,6 +585,7 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
 
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
+	can_skb_prv(skb)->skbcnt = 0;
 
 	*cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
 	memset(*cf, 0, sizeof(struct can_frame));
@@ -607,7 +604,6 @@ struct sk_buff *alloc_canfd_skb(struct net_device *dev,
 	if (unlikely(!skb))
 		return NULL;
 
-	__net_timestamp(skb);
 	skb->protocol = htons(ETH_P_CANFD);
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -618,6 +614,7 @@ struct sk_buff *alloc_canfd_skb(struct net_device *dev,
 
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
+	can_skb_prv(skb)->skbcnt = 0;
 
 	*cfd = (struct canfd_frame *)skb_put(skb, sizeof(struct canfd_frame));
 	memset(*cfd, 0, sizeof(struct canfd_frame));
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index f64f5290d6f8..a23a7af8eb9a 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -207,7 +207,6 @@ static void slc_bump(struct slcan *sl)
 	if (!skb)
 		return;
 
-	__net_timestamp(skb);
 	skb->dev = sl->dev;
 	skb->protocol = htons(ETH_P_CAN);
 	skb->pkt_type = PACKET_BROADCAST;
@@ -215,6 +214,7 @@ static void slc_bump(struct slcan *sl)
 
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = sl->dev->ifindex;
+	can_skb_prv(skb)->skbcnt = 0;
 
 	memcpy(skb_put(skb, sizeof(struct can_frame)),
 	       &cf, sizeof(struct can_frame));
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 0ce868de855d..674f367087c5 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -78,9 +78,6 @@ static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 	skb->dev       = dev;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	if (!(skb->tstamp.tv64))
-		__net_timestamp(skb);
-
 	netif_rx_ni(skb);
 }
 
diff --git a/include/linux/can/skb.h b/include/linux/can/skb.h
index b6a52a4b457a..51bb6532785c 100644
--- a/include/linux/can/skb.h
+++ b/include/linux/can/skb.h
@@ -27,10 +27,12 @@
 /**
  * struct can_skb_priv - private additional data inside CAN sk_buffs
  * @ifindex:	ifindex of the first interface the CAN frame appeared on
+ * @skbcnt:	atomic counter to have an unique id together with skb pointer
  * @cf:		align to the following CAN frame at skb->data
  */
 struct can_skb_priv {
 	int ifindex;
+	int skbcnt;
 	struct can_frame cf[0];
 };
 
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 7933e62a7318..166d436196c1 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -89,6 +89,8 @@ struct timer_list can_stattimer;   /* timer for statistics update */
 struct s_stats    can_stats;       /* packet statistics */
 struct s_pstats   can_pstats;      /* receive list statistics */
 
+static atomic_t skbcounter = ATOMIC_INIT(0);
+
 /*
  * af_can socket functions
  */
@@ -310,12 +312,8 @@ int can_send(struct sk_buff *skb, int loop)
 		return err;
 	}
 
-	if (newskb) {
-		if (!(newskb->tstamp.tv64))
-			__net_timestamp(newskb);
-
+	if (newskb)
 		netif_rx_ni(newskb);
-	}
 
 	/* update statistics */
 	can_stats.tx_frames++;
@@ -683,6 +681,10 @@ static void can_receive(struct sk_buff *skb, struct net_device *dev)
 	can_stats.rx_frames++;
 	can_stats.rx_frames_delta++;
 
+	/* create non-zero unique skb identifier together with *skb */
+	while (!(can_skb_prv(skb)->skbcnt))
+		can_skb_prv(skb)->skbcnt = atomic_inc_return(&skbcounter);
+
 	rcu_read_lock();
 
 	/* deliver the packet to sockets listening on all devices */
diff --git a/net/can/bcm.c b/net/can/bcm.c
index b523453585be..a1ba6875c2a2 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -261,6 +261,7 @@ static void bcm_can_tx(struct bcm_op *op)
 
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
+	can_skb_prv(skb)->skbcnt = 0;
 
 	memcpy(skb_put(skb, CFSIZ), cf, CFSIZ);
 
@@ -1217,6 +1218,7 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 	}
 
 	can_skb_prv(skb)->ifindex = dev->ifindex;
+	can_skb_prv(skb)->skbcnt = 0;
 	skb->dev = dev;
 	can_skb_set_owner(skb, sk);
 	err = can_send(skb, 1); /* send with loopback */
diff --git a/net/can/raw.c b/net/can/raw.c
index 31b9748cbb4e..2e67b1423cd3 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -75,7 +75,7 @@ MODULE_ALIAS("can-proto-1");
  */
 
 struct uniqframe {
-	ktime_t tstamp;
+	int skbcnt;
 	const struct sk_buff *skb;
 	unsigned int join_rx_count;
 };
@@ -133,7 +133,7 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 
 	/* eliminate multiple filter matches for the same skb */
 	if (this_cpu_ptr(ro->uniq)->skb == oskb &&
-	    ktime_equal(this_cpu_ptr(ro->uniq)->tstamp, oskb->tstamp)) {
+	    this_cpu_ptr(ro->uniq)->skbcnt == can_skb_prv(oskb)->skbcnt) {
 		if (ro->join_filters) {
 			this_cpu_inc(ro->uniq->join_rx_count);
 			/* drop frame until all enabled filters matched */
@@ -144,7 +144,7 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 		}
 	} else {
 		this_cpu_ptr(ro->uniq)->skb = oskb;
-		this_cpu_ptr(ro->uniq)->tstamp = oskb->tstamp;
+		this_cpu_ptr(ro->uniq)->skbcnt = can_skb_prv(oskb)->skbcnt;
 		this_cpu_ptr(ro->uniq)->join_rx_count = 1;
 		/* drop first frame to check all enabled filters? */
 		if (ro->join_filters && ro->count > 1)
@@ -749,6 +749,7 @@ static int raw_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
+	can_skb_prv(skb)->skbcnt = 0;
 
 	err = memcpy_from_msg(skb_put(skb, size), msg, size);
 	if (err < 0)
-- 
2.1.4

