From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: [PATCH net-next-2.6 2/2] mq: preserve queue mapping with bonding and VLAN devices
Date: Sun, 28 Feb 2010 14:35:14 +0300
Message-ID: <68301267356914@webmail50.yandex.ru>
References: <272541267277332@webmail86.yandex.ru> <20100228.013311.242139140.davem@davemloft.net> <20100228.013627.200374267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward12.mail.yandex.net ([95.108.130.94]:34613 "EHLO
	forward12.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031801Ab0B1LfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 06:35:16 -0500
In-Reply-To: <20100228.013627.200374267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  In file included from include/linux/netfilter.h:6,
>                   from include/net/netns/x_tables.h:5,
>                   from include/net/net_namespace.h:18,
>                   from include/linux/init_task.h:13,
>                   from arch/sparc/kernel/init_task.c:5:
>  include/linux/skbuff.h: In function =E2=80=98skb_get_queue_mapping=E2=
=80=99:
>  include/linux/skbuff.h:2022: error: implicit declaration of function=
 =E2=80=98skb_rx_queue_recorded=E2=80=99

Silly me. :( Corrected.

---

=46orwarded packet goes through dev_queue_xmit() more that once
when using bonding or 802.1q VLAN devices, so we've lost rx-tx
queue mapping index for real devices. This is because initial
queue index value (as it recorded by skb_record_tx_queue()) is
overwritten by skb_set_queue_mapping().

Signed-off-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru>

---

 drivers/net/bnx2.c              |    2 +-
 drivers/net/bnx2x_main.c        |    2 +-
 drivers/net/gianfar.c           |    6 +++---
 drivers/net/igb/igb_main.c      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c  |    6 +++---
 drivers/net/mlx4/en_tx.c        |    2 +-
 drivers/net/niu.c               |    2 +-
 drivers/net/qlge/qlge_main.c    |    2 +-
 drivers/net/s2io.c              |    2 +-
 include/linux/skbuff.h          |   24 +++++++-----------------
 net/core/dev.c                  |    2 +-
 11 files changed, 21 insertions(+), 31 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 381887b..fa3406c 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3199,7 +3199,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bn=
api, int budget)
 				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		}
=20
-		skb_record_rx_queue(skb, bnapi - &bp->bnx2_napi[0]);
+		skb_set_queue_mapping(skb, bnapi - &bp->bnx2_napi[0]);
=20
 #ifdef BCM_VLAN
 		if (hw_vlan)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5adf2a0..6e8e327 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1681,7 +1681,7 @@ reuse_rx:
 			}
 		}
=20
-		skb_record_rx_queue(skb, fp->index);
+		skb_set_queue_mapping(skb, fp->index);
=20
 #ifdef BCM_VLAN
 		if ((bp->vlgrp !=3D NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6aa526e..d034f4e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1934,7 +1934,7 @@ static int gfar_start_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 	unsigned int nr_frags, length;
=20
=20
-	rq =3D skb->queue_mapping;
+	rq =3D skb_get_queue_mapping(skb);
 	tx_queue =3D priv->tx_queue[rq];
 	txq =3D netdev_get_tx_queue(dev, rq);
 	base =3D tx_queue->tx_bd_base;
@@ -2466,7 +2466,7 @@ static int gfar_process_frame(struct net_device *=
dev, struct sk_buff *skb,
 	/* Remove the FCB from the skb */
 	/* Remove the padded bytes, if there are any */
 	if (amount_pull) {
-		skb_record_rx_queue(skb, fcb->rq);
+		skb_set_queue_mapping(skb, fcb->rq);
 		skb_pull(skb, amount_pull);
 	}
=20
@@ -2549,7 +2549,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_=
queue, int rx_work_limit)
 				/* Remove the FCS from the packet length */
 				skb_put(skb, pkt_len);
 				rx_queue->stats.rx_bytes +=3D pkt_len;
-				skb_record_rx_queue(skb, rx_queue->qindex);
+				skb_set_queue_mapping(skb, rx_queue->qindex);
 				gfar_process_frame(dev, skb, amount_pull);
=20
 			} else {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 583a21c..def942c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3838,7 +3838,7 @@ static netdev_tx_t igb_xmit_frame_adv(struct sk_b=
uff *skb,
 		return NETDEV_TX_OK;
 	}
=20
-	r_idx =3D skb->queue_mapping & (IGB_ABS_MAX_TX_QUEUES - 1);
+	r_idx =3D skb_get_queue_mapping(skb) & (IGB_ABS_MAX_TX_QUEUES - 1);
 	tx_ring =3D adapter->multi_tx_table[r_idx];
=20
 	/* This goes back to the question of how to logically map a tx queue
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index 45e3532..0d08eba 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5668,17 +5668,17 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_b=
uff *skb,
 		tx_flags |=3D vlan_tx_tag_get(skb);
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			tx_flags &=3D ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
-			tx_flags |=3D ((skb->queue_mapping & 0x7) << 13);
+			tx_flags |=3D ((skb_get_queue_mapping(skb) & 0x7) << 13);
 		}
 		tx_flags <<=3D IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |=3D IXGBE_TX_FLAGS_VLAN;
 	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		tx_flags |=3D ((skb->queue_mapping & 0x7) << 13);
+		tx_flags |=3D ((skb_get_queue_mapping(skb) & 0x7) << 13);
 		tx_flags <<=3D IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |=3D IXGBE_TX_FLAGS_VLAN;
 	}
=20
-	tx_ring =3D adapter->tx_ring[skb->queue_mapping];
+	tx_ring =3D adapter->tx_ring[skb_get_queue_mapping(skb)];
=20
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
 	    (skb->protocol =3D=3D htons(ETH_P_FCOE))) {
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 3d1396a..c1bca72 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -624,7 +624,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struc=
t net_device *dev)
 		goto tx_drop;
 	}
=20
-	tx_ind =3D skb->queue_mapping;
+	tx_ind =3D skb_get_queue_mapping(skb);
 	ring =3D &priv->tx_ring[tx_ind];
 	if (priv->vlgrp && vlan_tx_tag_present(skb))
 		vlan_tag =3D vlan_tx_tag_get(skb);
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0678f31..0819cb2 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3516,7 +3516,7 @@ static int niu_process_rx_pkt(struct napi_struct =
*napi, struct niu *np,
 	rp->rx_bytes +=3D skb->len;
=20
 	skb->protocol =3D eth_type_trans(skb, np->dev);
-	skb_record_rx_queue(skb, rp->rx_channel);
+	skb_set_queue_mapping(skb, rp->rx_channel);
 	napi_gro_receive(napi, skb);
=20
 	return num_rcr;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index c26ec5d..f645d42 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2525,7 +2525,7 @@ static netdev_tx_t qlge_send(struct sk_buff *skb,=
 struct net_device *ndev)
 	struct ql_adapter *qdev =3D netdev_priv(ndev);
 	int tso;
 	struct tx_ring *tx_ring;
-	u32 tx_ring_idx =3D (u32) skb->queue_mapping;
+	u32 tx_ring_idx =3D (u32) skb_get_queue_mapping(skb);
=20
 	tx_ring =3D &qdev->tx_ring[tx_ring_idx];
=20
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 43bc66a..afdab06 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7549,7 +7549,7 @@ static int rx_osm_handler(struct ring_info *ring_=
data, struct RxD_t * rxdp)
=20
 	swstats->mem_freed +=3D skb->truesize;
 send_up:
-	skb_record_rx_queue(skb, ring_no);
+	skb_set_queue_mapping(skb, ring_no);
 	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
 aggregate:
 	sp->mac_control.rings[ring_no].rx_bufs_left -=3D 1;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d266eee..e8325d2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2012,14 +2012,19 @@ static inline void skb_init_secmark(struct sk_b=
uff *skb)
 { }
 #endif
=20
+static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
+{
+	return (skb->queue_mapping !=3D 0);
+}
+
 static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queu=
e_mapping)
 {
-	skb->queue_mapping =3D queue_mapping;
+	skb->queue_mapping =3D queue_mapping + 1;
 }
=20
 static inline u16 skb_get_queue_mapping(const struct sk_buff *skb)
 {
-	return skb->queue_mapping;
+	return skb_rx_queue_recorded(skb) ? skb->queue_mapping - 1 : 0;
 }
=20
 static inline void skb_copy_queue_mapping(struct sk_buff *to, const st=
ruct sk_buff *from)
@@ -2027,21 +2032,6 @@ static inline void skb_copy_queue_mapping(struct=
 sk_buff *to, const struct sk_bu
 	to->queue_mapping =3D from->queue_mapping;
 }
=20
-static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_que=
ue)
-{
-	skb->queue_mapping =3D rx_queue + 1;
-}
-
-static inline u16 skb_get_rx_queue(const struct sk_buff *skb)
-{
-	return skb->queue_mapping - 1;
-}
-
-static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
-{
-	return (skb->queue_mapping !=3D 0);
-}
-
 extern u16 skb_tx_hash(const struct net_device *dev,
 		       const struct sk_buff *skb);
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index e5972f7..61e56b7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1938,7 +1938,7 @@ u16 skb_tx_hash(const struct net_device *dev, con=
st struct sk_buff *skb)
 	u32 hash;
=20
 	if (skb_rx_queue_recorded(skb)) {
-		hash =3D skb_get_rx_queue(skb);
+		hash =3D skb->queue_mapping - 1;
 		while (unlikely(hash >=3D dev->real_num_tx_queues))
 			hash -=3D dev->real_num_tx_queues;
 		return hash;

---

--
wbr, Oleg.
