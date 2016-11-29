From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [WIP] net+mlx4: auto doorbell
Date: Mon, 28 Nov 2016 22:58:36 -0800
Message-ID: <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
         <20161116131609.4e5726b4@redhat.com>
         <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
         <20161116234022.2bad179b@redhat.com>
         <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117091638.5fab8494@redhat.com>
         <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117144248.23500001@redhat.com>
         <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117155753.17b76f5a@redhat.com>
         <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117193021.580589ae@redhat.com>
         <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161121170351.50a09ee1@redhat.com>
         <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32983 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754300AbcK2G6j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:58:39 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so15469469pgd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 22:58:38 -0800 (PST)
In-Reply-To: <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-21 at 10:10 -0800, Eric Dumazet wrote:


> Not sure it this has been tried before, but the doorbell avoidance could
> be done by the driver itself, because it knows a TX completion will come
> shortly (well... if softirqs are not delayed too much !)
> 
> Doorbell would be forced only if :
> 
> (    "skb->xmit_more is not set" AND "TX engine is not 'started yet'" )
> OR
> ( too many [1] packets were put in TX ring buffer, no point deferring
> more)
> 
> Start the pump, but once it is started, let the doorbells being done by
> TX completion.
> 
> ndo_start_xmit and TX completion handler would have to maintain a shared
> state describing if packets were ready but doorbell deferred.
> 
> 
> Note that TX completion means "if at least one packet was drained",
> otherwise busy polling, constantly calling napi->poll() would force a
> doorbell too soon for devices sharing a NAPI for both RX and TX.
> 
> But then, maybe busy poll would like to force a doorbell...
> 
> I could try these ideas on mlx4 shortly.
> 
> 
> [1] limit could be derived from active "ethtool -c" params, eg tx-frames

I have a WIP, that increases pktgen rate by 75 % on mlx4 when bulking is
not used.

lpaa23:~# echo 0 >/sys/class/net/eth0/doorbell_opt 
lpaa23:~# sar -n DEV 1 10|grep eth0
22:43:26         eth0      0.00 5822800.00      0.00 597064.41      0.00      0.00      1.00
22:43:27         eth0     24.00 5788237.00      2.09 593520.26      0.00      0.00      0.00
22:43:28         eth0     12.00 5817777.00      1.43 596551.47      0.00      0.00      1.00
22:43:29         eth0     22.00 5841516.00      1.61 598982.87      0.00      0.00      0.00
22:43:30         eth0      4.00 4389137.00      0.71 450058.08      0.00      0.00      1.00
22:43:31         eth0      4.00 5871008.00      0.72 602007.79      0.00      0.00      0.00
22:43:32         eth0     12.00 5891809.00      1.43 604142.60      0.00      0.00      1.00
22:43:33         eth0     10.00 5901904.00      1.12 605175.70      0.00      0.00      0.00
22:43:34         eth0      5.00 5907982.00      0.69 605798.99      0.00      0.00      1.00
22:43:35         eth0      2.00 5847086.00      0.12 599554.71      0.00      0.00      0.00
Average:         eth0      9.50 5707925.60      0.99 585285.69      0.00      0.00      0.50
lpaa23:~# echo 1 >/sys/class/net/eth0/doorbell_opt 
lpaa23:~# sar -n DEV 1 10|grep eth0
22:43:47         eth0      9.00 10226424.00      1.02 1048608.05      0.00      0.00      1.00
22:43:48         eth0      1.00 10316955.00      0.06 1057890.89      0.00      0.00      0.00
22:43:49         eth0      1.00 10310104.00      0.10 1057188.32      0.00      0.00      1.00
22:43:50         eth0      0.00 10249423.00      0.00 1050966.23      0.00      0.00      0.00
22:43:51         eth0      0.00 10210441.00      0.00 1046969.05      0.00      0.00      1.00
22:43:52         eth0      2.00 10198389.00      0.16 1045733.17      0.00      0.00      1.00
22:43:53         eth0      8.00 10079257.00      1.43 1033517.83      0.00      0.00      0.00
22:43:54         eth0      0.00 7693509.00      0.00 788885.16      0.00      0.00      0.00
22:43:55         eth0      2.00 10343076.00      0.20 1060569.32      0.00      0.00      1.00
22:43:56         eth0      1.00 10224571.00      0.14 1048417.93      0.00      0.00      0.00
Average:         eth0      2.40 9985214.90      0.31 1023874.60      0.00      0.00      0.50

And about 11 % improvement on an mono-flow UDP_STREAM test.

skb_set_owner_w() is now the most consuming function.


lpaa23:~# ./udpsnd -4 -H 10.246.7.152 -d 2 &
[1] 13696
lpaa23:~# echo 0 >/sys/class/net/eth0/doorbell_opt
lpaa23:~# sar -n DEV 1 10|grep eth0
22:50:47         eth0      3.00 1355422.00      0.45 319706.04      0.00      0.00      0.00
22:50:48         eth0      2.00 1344270.00      0.42 317035.21      0.00      0.00      1.00
22:50:49         eth0      3.00 1350503.00      0.51 318478.34      0.00      0.00      0.00
22:50:50         eth0     29.00 1348593.00      2.86 318113.02      0.00      0.00      1.00
22:50:51         eth0     14.00 1354855.00      1.83 319508.56      0.00      0.00      0.00
22:50:52         eth0      7.00 1357794.00      0.73 320226.89      0.00      0.00      1.00
22:50:53         eth0      5.00 1326130.00      0.63 312784.72      0.00      0.00      0.00
22:50:54         eth0      2.00 994584.00      0.12 234598.40      0.00      0.00      1.00
22:50:55         eth0      5.00 1318209.00      0.75 310932.46      0.00      0.00      0.00
22:50:56         eth0     20.00 1323445.00      1.73 312178.11      0.00      0.00      1.00
Average:         eth0      9.00 1307380.50      1.00 308356.18      0.00      0.00      0.50
lpaa23:~# echo 3 >/sys/class/net/eth0/doorbell_opt
lpaa23:~# sar -n DEV 1 10|grep eth0
22:51:03         eth0      4.00 1512055.00      0.54 356599.40      0.00      0.00      0.00
22:51:04         eth0      4.00 1507631.00      0.55 355609.46      0.00      0.00      1.00
22:51:05         eth0      4.00 1487789.00      0.42 350917.47      0.00      0.00      0.00
22:51:06         eth0      7.00 1474460.00      1.22 347811.16      0.00      0.00      1.00
22:51:07         eth0      2.00 1496529.00      0.24 352995.18      0.00      0.00      0.00
22:51:08         eth0      3.00 1485856.00      0.49 350425.65      0.00      0.00      1.00
22:51:09         eth0      1.00 1114808.00      0.06 262905.38      0.00      0.00      0.00
22:51:10         eth0      2.00 1510924.00      0.30 356397.53      0.00      0.00      1.00
22:51:11         eth0      2.00 1506408.00      0.30 355345.76      0.00      0.00      0.00
22:51:12         eth0      2.00 1499122.00      0.32 353668.75      0.00      0.00      1.00
Average:         eth0      3.10 1459558.20      0.44 344267.57      0.00      0.00      0.50

 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    2 
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   90 +++++++++++------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    4 
 include/linux/netdevice.h                    |    1 
 net/core/net-sysfs.c                         |   18 +++
 5 files changed, 83 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6562f78b07f4..fbea83218fc0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1089,7 +1089,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 	if (polled) {
 		if (doorbell_pending)
-			mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);
+			mlx4_en_xmit_doorbell(dev, priv->tx_ring[TX_XDP][cq->ring]);
 
 		mlx4_cq_set_ci(&cq->mcq);
 		wmb(); /* ensure HW sees CQ consumer before we post new buffers */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 4b597dca5c52..affebb435679 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -67,7 +67,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	ring->size = size;
 	ring->size_mask = size - 1;
 	ring->sp_stride = stride;
-	ring->full_size = ring->size - HEADROOM - MAX_DESC_TXBBS;
+	ring->full_size = ring->size - HEADROOM - 2*MAX_DESC_TXBBS;
 
 	tmp = size * sizeof(struct mlx4_en_tx_info);
 	ring->tx_info = kmalloc_node(tmp, GFP_KERNEL | __GFP_NOWARN, node);
@@ -193,6 +193,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	ring->sp_cqn = cq;
 	ring->prod = 0;
 	ring->cons = 0xffffffff;
+	ring->ncons = 0;
 	ring->last_nr_txbb = 1;
 	memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
 	memset(ring->buf, 0, ring->buf_size);
@@ -227,9 +228,9 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &ring->sp_qp);
 }
 
-static inline bool mlx4_en_is_tx_ring_full(struct mlx4_en_tx_ring *ring)
+static inline bool mlx4_en_is_tx_ring_full(const struct mlx4_en_tx_ring *ring)
 {
-	return ring->prod - ring->cons > ring->full_size;
+	return READ_ONCE(ring->prod) - READ_ONCE(ring->cons) > ring->full_size;
 }
 
 static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
@@ -374,6 +375,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 
 	/* Skip last polled descriptor */
 	ring->cons += ring->last_nr_txbb;
+	ring->ncons += ring->last_nr_txbb;
 	en_dbg(DRV, priv, "Freeing Tx buf - cons:0x%x prod:0x%x\n",
 		 ring->cons, ring->prod);
 
@@ -389,6 +391,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 						!!(ring->cons & ring->size), 0,
 						0 /* Non-NAPI caller */);
 		ring->cons += ring->last_nr_txbb;
+		ring->ncons += ring->last_nr_txbb;
 		cnt++;
 	}
 
@@ -401,6 +404,38 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	return cnt;
 }
 
+void mlx4_en_xmit_doorbell(const struct net_device *dev,
+			   struct mlx4_en_tx_ring *ring)
+{
+
+	if (dev->doorbell_opt & 1) {
+		u32 oval = READ_ONCE(ring->prod_bell);
+		u32 nval = READ_ONCE(ring->prod);
+
+		if (oval == nval)
+			return;
+
+		/* I can not tell yet if a cmpxchg() is needed or not */
+		if (dev->doorbell_opt & 2)
+			WRITE_ONCE(ring->prod_bell, nval);
+		else
+			if (cmpxchg(&ring->prod_bell, oval, nval) != oval)
+				return;
+	}
+	/* Since there is no iowrite*_native() that writes the
+	 * value as is, without byteswapping - using the one
+	 * the doesn't do byteswapping in the relevant arch
+	 * endianness.
+	 */
+#if defined(__LITTLE_ENDIAN)
+	iowrite32(
+#else
+	iowrite32be(
+#endif
+		  ring->doorbell_qpn,
+		  ring->bf.uar->map + MLX4_SEND_DOORBELL);
+}
+
 static bool mlx4_en_process_tx_cq(struct net_device *dev,
 				  struct mlx4_en_cq *cq, int napi_budget)
 {
@@ -496,8 +531,13 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	wmb();
 
 	/* we want to dirty this cache line once */
-	ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
-	ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
+	WRITE_ONCE(ring->last_nr_txbb, last_nr_txbb);
+	ring_cons += txbbs_skipped;
+	WRITE_ONCE(ring->cons, ring_cons);
+	WRITE_ONCE(ring->ncons, ring_cons + last_nr_txbb);
+
+	if (dev->doorbell_opt)
+		mlx4_en_xmit_doorbell(dev, ring);
 
 	if (ring->free_tx_desc == mlx4_en_recycle_tx_desc)
 		return done < budget;
@@ -725,29 +765,14 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
 	__iowrite64_copy(dst, src, bytecnt / 8);
 }
 
-void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring)
-{
-	wmb();
-	/* Since there is no iowrite*_native() that writes the
-	 * value as is, without byteswapping - using the one
-	 * the doesn't do byteswapping in the relevant arch
-	 * endianness.
-	 */
-#if defined(__LITTLE_ENDIAN)
-	iowrite32(
-#else
-	iowrite32be(
-#endif
-		  ring->doorbell_qpn,
-		  ring->bf.uar->map + MLX4_SEND_DOORBELL);
-}
 
 static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
 				  struct mlx4_en_tx_desc *tx_desc,
 				  union mlx4_wqe_qpn_vlan qpn_vlan,
 				  int desc_size, int bf_index,
 				  __be32 op_own, bool bf_ok,
-				  bool send_doorbell)
+				  bool send_doorbell,
+				  const struct net_device *dev, int nr_txbb)
 {
 	tx_desc->ctrl.qpn_vlan = qpn_vlan;
 
@@ -761,6 +786,7 @@ static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
 
 		wmb();
 
+		ring->prod += nr_txbb;
 		mlx4_bf_copy(ring->bf.reg + ring->bf.offset, &tx_desc->ctrl,
 			     desc_size);
 
@@ -773,8 +799,9 @@ static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
 		 */
 		dma_wmb();
 		tx_desc->ctrl.owner_opcode = op_own;
+		ring->prod += nr_txbb;
 		if (send_doorbell)
-			mlx4_en_xmit_doorbell(ring);
+			mlx4_en_xmit_doorbell(dev, ring);
 		else
 			ring->xmit_more++;
 	}
@@ -1017,8 +1044,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
 	}
 
-	ring->prod += nr_txbb;
-
 	/* If we used a bounce buffer then copy descriptor back into place */
 	if (unlikely(bounce))
 		tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
@@ -1033,6 +1058,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
 
+	/* Doorbell avoidance : We can omit doorbell if we know a TX completion
+	 * will happen shortly.
+	 */
+	if (send_doorbell &&
+	    dev->doorbell_opt &&
+	    (s32)(READ_ONCE(ring->prod_bell) - READ_ONCE(ring->ncons)) > 0)
+		send_doorbell = false;
+
 	real_size = (real_size / 16) & 0x3f;
 
 	bf_ok &= desc_size <= MAX_BF && send_doorbell;
@@ -1043,7 +1076,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		qpn_vlan.fence_size = real_size;
 
 	mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, desc_size, bf_index,
-			      op_own, bf_ok, send_doorbell);
+			      op_own, bf_ok, send_doorbell, dev, nr_txbb);
 
 	if (unlikely(stop_queue)) {
 		/* If queue was emptied after the if (stop_queue) , and before
@@ -1054,7 +1087,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		smp_rmb();
 
-		ring_cons = ACCESS_ONCE(ring->cons);
 		if (unlikely(!mlx4_en_is_tx_ring_full(ring))) {
 			netif_tx_wake_queue(ring->tx_queue);
 			ring->wake_queue++;
@@ -1158,8 +1190,6 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 	rx_ring->xdp_tx++;
 	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, length);
 
-	ring->prod += nr_txbb;
-
 	stop_queue = mlx4_en_is_tx_ring_full(ring);
 	send_doorbell = stop_queue ||
 				*doorbell_pending > MLX4_EN_DOORBELL_BUDGET;
@@ -1173,7 +1203,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 		qpn_vlan.fence_size = real_size;
 
 	mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, TXBB_SIZE, bf_index,
-			      op_own, bf_ok, send_doorbell);
+			      op_own, bf_ok, send_doorbell, dev, nr_txbb);
 	*doorbell_pending = send_doorbell ? 0 : *doorbell_pending + 1;
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 574bcbb1b38f..c3fd0deda198 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -280,6 +280,7 @@ struct mlx4_en_tx_ring {
 	 */
 	u32			last_nr_txbb;
 	u32			cons;
+	u32			ncons;
 	unsigned long		wake_queue;
 	struct netdev_queue	*tx_queue;
 	u32			(*free_tx_desc)(struct mlx4_en_priv *priv,
@@ -290,6 +291,7 @@ struct mlx4_en_tx_ring {
 
 	/* cache line used and dirtied in mlx4_en_xmit() */
 	u32			prod ____cacheline_aligned_in_smp;
+	u32			prod_bell;
 	unsigned int		tx_dropped;
 	unsigned long		bytes;
 	unsigned long		packets;
@@ -699,7 +701,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 			       struct mlx4_en_rx_alloc *frame,
 			       struct net_device *dev, unsigned int length,
 			       int tx_ind, int *doorbell_pending);
-void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring);
+void mlx4_en_xmit_doorbell(const struct net_device *dev, struct mlx4_en_tx_ring *ring);
 bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
 			struct mlx4_en_rx_alloc *frame);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4ffcd874cc20..39565b5425a6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1816,6 +1816,7 @@ struct net_device {
 	DECLARE_HASHTABLE	(qdisc_hash, 4);
 #endif
 	unsigned long		tx_queue_len;
+	unsigned long		doorbell_opt;
 	spinlock_t		tx_global_lock;
 	int			watchdog_timeo;
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b0c04cf4851d..df05f81f5150 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -367,6 +367,23 @@ static ssize_t gro_flush_timeout_store(struct device *dev,
 }
 NETDEVICE_SHOW_RW(gro_flush_timeout, fmt_ulong);
 
+static int change_doorbell_opt(struct net_device *dev, unsigned long val)
+{
+	dev->doorbell_opt = val;
+	return 0;
+}
+
+static ssize_t doorbell_opt_store(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t len)
+{
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return netdev_store(dev, attr, buf, len, change_doorbell_opt);
+}
+NETDEVICE_SHOW_RW(doorbell_opt, fmt_ulong);
+
 static ssize_t ifalias_store(struct device *dev, struct device_attribute *attr,
 			     const char *buf, size_t len)
 {
@@ -531,6 +548,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_phys_port_name.attr,
 	&dev_attr_phys_switch_id.attr,
 	&dev_attr_proto_down.attr,
+	&dev_attr_doorbell_opt.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(net_class);
