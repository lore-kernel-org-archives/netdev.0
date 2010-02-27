From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: [net-next-2.6 PATCH] Preserve queue mapping with bonding and VLAN devices
Date: Sat, 27 Feb 2010 12:53:02 +0300
Message-ID: <14541267264382@webmail122.yandex.ru>
References: <33081266938239@webmail48.yandex.ru> <1266940741.2109.7.camel@achroite.uk.solarflarecom.com> <68631266953760@webmail134.yandex.ru> <20100226.055025.30718012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward8.mail.yandex.net ([77.88.61.38]:36362 "EHLO
	forward8.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968104Ab0B0JxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 04:53:07 -0500
In-Reply-To: <20100226.055025.30718012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

26.02.10, 05:50, "David Miller" <davem@davemloft.net>:

>  Your patches are fine, but they are whitespace corrupted by your
>  email client (tabs turned into spaces, etc.) so they won't apply
>  properly.
>  
>  Please fix this up and resend your patches.
>  
>  Thanks!

I'm sorry, corrected it. By the way additional check was added to
return 0 in skb_get_queue_mapping() when skb->queue_mapping = 0.
Initial multiqueue support for bonding is also included here.

---

1. Forwarded packet goes through dev_queue_xmit() more that once
when using bonding or 802.1q VLAN devices, so we've lost rx-tx queue
mapping index for real devices. This is because initial queue index value
(as it recorded by skb_record_tx_queue()) is overwritten
by skb_set_queue_mapping().

2. Initial multiqueue support for bonding devices. Make bonding driver
multiqueue aware.

Signed-off-by: Oleg A. Arkhangelsky  

---
 drivers/net/bnx2.c              |    2 +-
 drivers/net/bnx2x_main.c        |    2 +-
 drivers/net/bonding/bond_main.c |    5 +++--
 drivers/net/bonding/bonding.h   |    1 +
 drivers/net/gianfar.c           |    6 +++---
 drivers/net/igb/igb_main.c      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c  |    6 +++---
 drivers/net/mlx4/en_tx.c        |    2 +-
 drivers/net/niu.c               |    2 +-
 drivers/net/qlge/qlge_main.c    |    2 +-
 drivers/net/s2io.c              |    2 +-
 include/linux/skbuff.h          |   14 ++------------
 net/core/dev.c                  |    2 +-
 13 files changed, 20 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d3f739a..abbbe40 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3199,7 +3199,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 		}
 
-		skb_record_rx_queue(skb, bnapi - &bp->bnx2_napi[0]);
+		skb_set_queue_mapping(skb, bnapi - &bp->bnx2_napi[0]);
 
 #ifdef BCM_VLAN
 		if (hw_vlan)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5adf2a0..6e8e327 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1681,7 +1681,7 @@ reuse_rx:
 			}
 		}
 
-		skb_record_rx_queue(skb, fp->index);
+		skb_set_queue_mapping(skb, fp->index);
 
 #ifdef BCM_VLAN
 		if ((bp->vlgrp != NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1787e3c..f54f590 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4928,8 +4928,9 @@ int bond_create(struct net *net, const char *name)
 
 	rtnl_lock();
 
-	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
-				bond_setup);
+	bond_dev = alloc_netdev_mq(sizeof(struct bonding), name ? name : "",
+				bond_setup,
+				min_t(u32, BOND_MAX_TX_QUEUES, num_online_cpus()));
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
 		res = -ENOMEM;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 257a7a4..4a6cfb4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -29,6 +29,7 @@
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
 #define BOND_MAX_ARP_TARGETS	16
+#define BOND_MAX_TX_QUEUES	8 
 
 #define IS_UP(dev)					   \
 	      ((((dev)->flags & IFF_UP) == IFF_UP)	&& \
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6aa526e..d034f4e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1934,7 +1934,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int nr_frags, length;
 
 
-	rq = skb->queue_mapping;
+	rq = skb_get_queue_mapping(skb);
 	tx_queue = priv->tx_queue[rq];
 	txq = netdev_get_tx_queue(dev, rq);
 	base = tx_queue->tx_bd_base;
@@ -2466,7 +2466,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	/* Remove the FCB from the skb */
 	/* Remove the padded bytes, if there are any */
 	if (amount_pull) {
-		skb_record_rx_queue(skb, fcb->rq);
+		skb_set_queue_mapping(skb, fcb->rq);
 		skb_pull(skb, amount_pull);
 	}
 
@@ -2549,7 +2549,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				/* Remove the FCS from the packet length */
 				skb_put(skb, pkt_len);
 				rx_queue->stats.rx_bytes += pkt_len;
-				skb_record_rx_queue(skb, rx_queue->qindex);
+				skb_set_queue_mapping(skb, rx_queue->qindex);
 				gfar_process_frame(dev, skb, amount_pull);
 
 			} else {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 583a21c..def942c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3838,7 +3838,7 @@ static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	r_idx = skb->queue_mapping & (IGB_ABS_MAX_TX_QUEUES - 1);
+	r_idx = skb_get_queue_mapping(skb) & (IGB_ABS_MAX_TX_QUEUES - 1);
 	tx_ring = adapter->multi_tx_table[r_idx];
 
 	/* This goes back to the question of how to logically map a tx queue
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a961da2..c6a3231 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5662,13 +5662,13 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		tx_flags |= vlan_tx_tag_get(skb);
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
-			tx_flags |= ((skb->queue_mapping & 0x7) << 13);
+			tx_flags |= ((skb_get_queue_mapping(skb) & 0x7) << 13);
 		}
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 		if (skb->priority != TC_PRIO_CONTROL) {
-			tx_flags |= ((skb->queue_mapping & 0x7) << 13);
+			tx_flags |= ((skb_get_queue_mapping(skb) & 0x7) << 13);
 			tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 			tx_flags |= IXGBE_TX_FLAGS_VLAN;
 		} else {
@@ -5677,7 +5677,7 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		}
 	}
 
-	tx_ring = adapter->tx_ring[skb->queue_mapping];
+	tx_ring = adapter->tx_ring[skb_get_queue_mapping(skb)];
 
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
 	    (skb->protocol == htons(ETH_P_FCOE))) {
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 3d1396a..c1bca72 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -624,7 +624,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_drop;
 	}
 
-	tx_ind = skb->queue_mapping;
+	tx_ind = skb_get_queue_mapping(skb);
 	ring = &priv->tx_ring[tx_ind];
 	if (priv->vlgrp && vlan_tx_tag_present(skb))
 		vlan_tag = vlan_tx_tag_get(skb);
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0678f31..0819cb2 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3516,7 +3516,7 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 	rp->rx_bytes += skb->len;
 
 	skb->protocol = eth_type_trans(skb, np->dev);
-	skb_record_rx_queue(skb, rp->rx_channel);
+	skb_set_queue_mapping(skb, rp->rx_channel);
 	napi_gro_receive(napi, skb);
 
 	return num_rcr;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c26ec5d..f645d42 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2525,7 +2525,7 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int tso;
 	struct tx_ring *tx_ring;
-	u32 tx_ring_idx = (u32) skb->queue_mapping;
+	u32 tx_ring_idx = (u32) skb_get_queue_mapping(skb);
 
 	tx_ring = &qdev->tx_ring[tx_ring_idx];
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 43bc66a..afdab06 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7549,7 +7549,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 
 	swstats->mem_freed += skb->truesize;
 send_up:
-	skb_record_rx_queue(skb, ring_no);
+	skb_set_queue_mapping(skb, ring_no);
 	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
 aggregate:
 	sp->mac_control.rings[ring_no].rx_bufs_left -= 1;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ba0f8e3..c01cc1d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2013,12 +2013,12 @@ static inline void skb_init_secmark(struct sk_buff *skb)
 
 static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queue_mapping)
 {
-	skb->queue_mapping = queue_mapping;
+	skb->queue_mapping = queue_mapping + 1;
 }
 
 static inline u16 skb_get_queue_mapping(const struct sk_buff *skb)
 {
-	return skb->queue_mapping;
+	return skb_rx_queue_recorded(skb) ? skb->queue_mapping - 1 : 0;
 }
 
 static inline void skb_copy_queue_mapping(struct sk_buff *to, const struct sk_buff *from)
@@ -2026,16 +2026,6 @@ static inline void skb_copy_queue_mapping(struct sk_buff *to, const struct sk_bu
 	to->queue_mapping = from->queue_mapping;
 }
 
-static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_queue)
-{
-	skb->queue_mapping = rx_queue + 1;
-}
-
-static inline u16 skb_get_rx_queue(const struct sk_buff *skb)
-{
-	return skb->queue_mapping - 1;
-}
-
 static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 {
 	return (skb->queue_mapping != 0);
diff --git a/net/core/dev.c b/net/core/dev.c
index eb7f1a4..3beaa21 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1916,7 +1916,7 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 	u32 hash;
 
 	if (skb_rx_queue_recorded(skb)) {
-		hash = skb_get_rx_queue(skb);
+		hash = skb->queue_mapping - 1;
 		while (unlikely(hash >= dev->real_num_tx_queues))
 			hash -= dev->real_num_tx_queues;
 		return hash;
---

-- 
wbr, Oleg.
