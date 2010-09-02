From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] drivers/net : avoid some skb->ip_summed
 initializations
Date: Thu, 02 Sep 2010 21:55:01 +0200
Message-ID: <1283457301.3699.117.camel@edumazet-laptop>
References: <1283444746.2454.1132.camel@edumazet-laptop>
	 <20100902.094135.112603353.davem@davemloft.net>
	 <1283454780.3699.22.camel@edumazet-laptop>
	 <20100902.123801.102553189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51903 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585Ab0IBTzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 15:55:08 -0400
Received: by wyb35 with SMTP id 35so93526wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 12:55:06 -0700 (PDT)
In-Reply-To: <20100902.123801.102553189.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 12:38 -0700, David Miller a =C3=A9cri=
t :

> Respin with #1 please, thanks.

Sure !

[PATCH] drivers/net : avoid some skb->ip_summed initializations

fresh skbs have ip_summed set to CHECKSUM_NONE (0)

We can avoid setting again skb->ip_summed to CHECKSUM_NONE in drivers.

Introduce skb_checksum_none_assert() helper so that we keep this
assertion documented in driver sources.

Change most occurrences of :

skb->ip_summed =3D CHECKSUM_NONE;

by :

skb_checksum_none_assert(skb);

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/8139cp.c               |    2 +-
 drivers/net/acenic.c               |    2 +-
 drivers/net/atl1c/atl1c_main.c     |    2 +-
 drivers/net/atl1e/atl1e_main.c     |    2 +-
 drivers/net/atlx/atl1.c            |    2 +-
 drivers/net/b44.c                  |    2 +-
 drivers/net/benet/be_main.c        |    2 +-
 drivers/net/bna/bnad.c             |    2 +-
 drivers/net/bnx2.c                 |    2 +-
 drivers/net/bnx2x/bnx2x_cmn.c      |    2 +-
 drivers/net/cassini.c              |    2 +-
 drivers/net/chelsio/sge.c          |    2 +-
 drivers/net/cpmac.c                |    2 +-
 drivers/net/cxgb3/sge.c            |    2 +-
 drivers/net/cxgb4/sge.c            |    2 +-
 drivers/net/cxgb4vf/sge.c          |    2 +-
 drivers/net/dm9000.c               |    2 +-
 drivers/net/e1000/e1000_main.c     |    3 ++-
 drivers/net/e1000e/netdev.c        |    3 ++-
 drivers/net/gianfar.c              |    2 +-
 drivers/net/greth.c                |    2 +-
 drivers/net/ibmlana.c              |    2 +-
 drivers/net/igb/igb_main.c         |    2 +-
 drivers/net/igbvf/netdev.c         |    2 +-
 drivers/net/ipg.c                  |    6 +++---
 drivers/net/iseries_veth.c         |    2 +-
 drivers/net/ixgb/ixgb_main.c       |    4 ++--
 drivers/net/ixgbe/ixgbe_fcoe.c     |    5 +++--
 drivers/net/ixgbe/ixgbe_main.c     |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/jme.c                  |    2 +-
 drivers/net/ll_temac_main.c        |    2 +-
 drivers/net/macb.c                 |    2 +-
 drivers/net/niu.c                  |    2 +-
 drivers/net/ns83820.c              |    2 +-
 drivers/net/pasemi_mac.c           |    2 +-
 drivers/net/ps3_gelic_net.c        |    4 ++--
 drivers/net/qla3xxx.c              |    4 ++--
 drivers/net/qlcnic/qlcnic_init.c   |    2 +-
 drivers/net/qlge/qlge_main.c       |    6 +++---
 drivers/net/r8169.c                |    2 +-
 drivers/net/s2io.c                 |    4 ++--
 drivers/net/sb1250-mac.c           |    2 +-
 drivers/net/sfc/rx.c               |    2 +-
 drivers/net/sh_eth.c               |    2 +-
 drivers/net/smsc911x.c             |    2 +-
 drivers/net/spider_net.c           |    4 ++--
 drivers/net/stmmac/stmmac_main.c   |    2 +-
 drivers/net/tehuti.c               |    5 +++--
 drivers/net/tg3.c                  |    2 +-
 drivers/net/typhoon.c              |    2 +-
 drivers/net/via-velocity.c         |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c  |    4 ++--
 drivers/net/vxge/vxge-main.c       |    2 +-
 drivers/net/xilinx_emaclite.c      |    2 +-
 include/linux/skbuff.h             |   15 +++++++++++++++
 56 files changed, 86 insertions(+), 67 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f900ffc..cbfa293 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2206,6 +2206,21 @@ static inline void skb_forward_csum(struct sk_bu=
ff *skb)
 		skb->ip_summed =3D CHECKSUM_NONE;
 }
=20
+/**
+ * skb_checksum_none_assert - make sure skb ip_summed is CHECKSUM_NONE
+ * @skb: skb to check
+ *
+ * fresh skbs have their ip_summed set to CHECKSUM_NONE.
+ * Instead of forcing ip_summed to CHECKSUM_NONE, we can
+ * use this helper, to document places where we make this assertion.
+ */
+static inline void skb_checksum_none_assert(struct sk_buff *skb)
+{
+#ifdef DEBUG
+	BUG(skb->ip_summed !=3D CHECKSUM_NONE);
+#endif
+}
+
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 4a4f6b8..c124a03 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -561,7 +561,7 @@ rx_status_loop:
 		if (cp_rx_csum_ok(status))
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
=20
 		skb_put(skb, len);
=20
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index b9a5916..d7245b1 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2033,7 +2033,7 @@ static void ace_rx_int(struct net_device *dev, u3=
2 rxretprd, u32 rxretcsm)
 			skb->csum =3D htons(csum);
 			skb->ip_summed =3D CHECKSUM_COMPLETE;
 		} else {
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
 		}
=20
 		/* send it up */
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_m=
ain.c
index 61f1634..c247f9c 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -1719,7 +1719,7 @@ static inline void atl1c_rx_checksum(struct atl1c=
_adapter *adapter,
 	 * cannot figure out if the packet is fragmented or not,
 	 * so we tell the KERNEL CHECKSUM_NONE
 	 */
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
 }
=20
 static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter, const =
int ringid)
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_m=
ain.c
index 1ae44bb..72d6f04 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1331,7 +1331,7 @@ static inline void atl1e_rx_checksum(struct atl1e=
_adapter *adapter,
 	u16 pkt_flags;
 	u16 err_flags;
=20
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
 	pkt_flags =3D prrs->pkt_flag;
 	err_flags =3D prrs->err_flag;
 	if (((pkt_flags & RRS_IS_IPV4) || (pkt_flags & RRS_IS_IPV6)) &&
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 5837b01..97b1f3d 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1805,7 +1805,7 @@ static void atl1_rx_checksum(struct atl1_adapter =
*adapter,
 	 * the higher layers and let it be sorted out there.
 	 */
=20
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
 		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 37617ab..9d3b8c0 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -818,7 +818,7 @@ static int b44_rx(struct b44 *bp, int budget)
 							 copy_skb->data, len);
 			skb =3D copy_skb;
 		}
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 		skb->protocol =3D eth_type_trans(skb, bp->dev);
 		netif_receive_skb(skb);
 		received++;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9db10fe..98c4f01 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1016,7 +1016,7 @@ static void be_rx_compl_process(struct be_adapter=
 *adapter,
 	skb_fill_rx_data(adapter, skb, rxcp, num_rcvd);
=20
 	if (do_pkt_csum(rxcp, adapter->rx_csum))
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 	else
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index cbc1d56..b179809 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -510,7 +510,7 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb=
, int budget)
 		      (flags & BNA_CQ_EF_L4_CKSUM_OK)))
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
=20
 		rcb->rxq->rx_packets++;
 		rcb->rxq->rx_bytes +=3D skb->len;
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a0e02aa..ea5185b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3218,7 +3218,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bn=
api, int budget)
=20
 		}
=20
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 		if (bp->rx_csum &&
 			(status & (L2_FHDR_STATUS_TCP_SEGMENT |
 			L2_FHDR_STATUS_UDP_DATAGRAM))) {
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cm=
n.c
index da96d1a..a6afe14 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -623,7 +623,7 @@ reuse_rx:
 			/* Set Toeplitz hash for a none-LRO skb */
 			bnx2x_set_skb_rxhash(bp, cqe, skb);
=20
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
 			if (bp->rx_csum) {
 				if (likely(BNX2X_RX_CSUM_OK(cqe)))
 					skb->ip_summed =3D CHECKSUM_UNNECESSARY;
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 28c88ee..a75f47f 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2149,7 +2149,7 @@ end_copy_pkt:
 		skb->csum =3D csum_unfold(~csum);
 		skb->ip_summed =3D CHECKSUM_COMPLETE;
 	} else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 	return len;
 }
=20
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index f01cfdb..943877a 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1388,7 +1388,7 @@ static void sge_rx(struct sge *sge, struct freelQ=
 *fl, unsigned int len)
 		++st->rx_cso_good;
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	} else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
=20
 	if (unlikely(adapter->vlan_grp && p->vlan_valid)) {
 		st->vlan_xtract++;
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 5a5af1c..b4c56a1 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -391,7 +391,7 @@ static struct sk_buff *cpmac_rx_one(struct cpmac_pr=
iv *priv,
 	if (likely(skb)) {
 		skb_put(desc->skb, desc->datalen);
 		desc->skb->protocol =3D eth_type_trans(desc->skb, priv->dev);
-		desc->skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(desc->skb);
 		priv->dev->stats.rx_packets++;
 		priv->dev->stats.rx_bytes +=3D desc->datalen;
 		result =3D desc->skb;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 8ff96c6..f753bf6 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2022,7 +2022,7 @@ static void rx_eth(struct adapter *adap, struct s=
ge_rspq *rq,
 		qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	} else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 	skb_record_rx_queue(skb, qs - &adap->sge.qs[0]);
=20
 	if (unlikely(p->vlan_valid)) {
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 6ddb3bb..3b8476c 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1605,7 +1605,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const __=
be64 *rsp,
 			rxq->stats.rx_cso++;
 		}
 	} else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
=20
 	if (unlikely(pkt->vlan_ex)) {
 		struct vlan_group *grp =3D pi->vlan_grp;
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index eb5a1c9..ef54203 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1535,7 +1535,7 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, con=
st __be64 *rsp,
 		}
 		rxq->stats.rx_cso++;
 	} else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
=20
 	if (unlikely(pkt->vlan_ex)) {
 		struct vlan_group *grp =3D pi->vlan_grp;
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 4fd6b2b..7ee7612 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1056,7 +1056,7 @@ dm9000_rx(struct net_device *dev)
 				if ((((rxbyte & 0x1c) << 3) & rxbyte) =3D=3D 0)
 					skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 				else
-					skb->ip_summed =3D CHECKSUM_NONE;
+					skb_checksum_none_assert(skb);
 			}
 			netif_rx(skb);
 			dev->stats.rx_packets++;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index 3e8ac4b..b23d1de 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3552,7 +3552,8 @@ static void e1000_rx_checksum(struct e1000_adapte=
r *adapter, u32 status_err,
 	struct e1000_hw *hw =3D &adapter->hw;
 	u16 status =3D (u16)status_err;
 	u8 errors =3D (u8)(status_err >> 24);
-	skb->ip_summed =3D CHECKSUM_NONE;
+
+	skb_checksum_none_assert(skb);
=20
 	/* 82543 or newer only */
 	if (unlikely(hw->mac_type < e1000_82543)) return;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5f3eac6..92a7290 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -475,7 +475,8 @@ static void e1000_rx_checksum(struct e1000_adapter =
*adapter, u32 status_err,
 {
 	u16 status =3D (u16)status_err;
 	u8 errors =3D (u8)(status_err >> 24);
-	skb->ip_summed =3D CHECKSUM_NONE;
+
+	skb_checksum_none_assert(skb);
=20
 	/* Ignore Checksum bit is set */
 	if (status & E1000_RXD_STAT_IXSM)
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index e6048d6..91de20c 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2654,7 +2654,7 @@ static inline void gfar_rx_checksum(struct sk_buf=
f *skb, struct rxfcb *fcb)
 	if ((fcb->flags & RXFCB_CSUM_MASK) =3D=3D (RXFCB_CIP | RXFCB_CTU))
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 }
=20
=20
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index fbeaf70..dbacb1e 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -893,7 +893,7 @@ static int greth_rx_gbit(struct net_device *dev, in=
t limit)
 				if (greth->flags & GRETH_FLAG_RX_CSUM && hw_checksummed(status))
 					skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 				else
-					skb->ip_summed =3D CHECKSUM_NONE;
+					skb_checksum_none_assert(skb);
=20
 				skb->protocol =3D eth_type_trans(skb, dev);
 				dev->stats.rx_packets++;
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 294ccfb..3779438 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -602,7 +602,7 @@ static void irqrx_handler(struct net_device *dev)
 				/* set up skb fields */
=20
 				skb->protocol =3D eth_type_trans(skb, dev);
-				skb->ip_summed =3D CHECKSUM_NONE;
+				skb_checksum_none_assert(skb);
=20
 				/* bookkeeping */
 				dev->stats.rx_packets++;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d35cc38..ee7f11b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5455,7 +5455,7 @@ static void igb_receive_skb(struct igb_q_vector *=
q_vector,
 static inline void igb_rx_checksum_adv(struct igb_ring *ring,
 				       u32 status_err, struct sk_buff *skb)
 {
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	/* Ignore Checksum bit is set or checksum is disabled through ethtool=
 */
 	if (!(ring->flags & IGB_RING_FLAG_RX_CSUM) ||
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index c539f7c..214cc63 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -103,7 +103,7 @@ static void igbvf_receive_skb(struct igbvf_adapter =
*adapter,
 static inline void igbvf_rx_checksum_adv(struct igbvf_adapter *adapter=
,
                                          u32 status_err, struct sk_buf=
f *skb)
 {
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	/* Ignore Checksum bit is set or checksum is disabled through ethtool=
 */
 	if ((status_err & E1000_RXD_STAT_IXSM) ||
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 72e3d2d..f0456ab 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1213,7 +1213,7 @@ static void ipg_nic_rx_with_start_and_end(struct =
net_device *dev,
=20
 	skb_put(skb, framelen);
 	skb->protocol =3D eth_type_trans(skb, dev);
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
 	netif_rx(skb);
 	sp->rx_buff[entry] =3D NULL;
 }
@@ -1278,7 +1278,7 @@ static void ipg_nic_rx_with_end(struct net_device=
 *dev,
 				jumbo->skb->protocol =3D
 				    eth_type_trans(jumbo->skb, dev);
=20
-				jumbo->skb->ip_summed =3D CHECKSUM_NONE;
+				skb_checksum_none_assert(jumbo->skb);
 				netif_rx(jumbo->skb);
 			}
 		}
@@ -1476,7 +1476,7 @@ static int ipg_nic_rx(struct net_device *dev)
 			 * IP/TCP/UDP frame was received. Let the
 			 * upper layer decide.
 			 */
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
=20
 			/* Hand off frame for higher layer processing.
 			 * The function netif_rx() releases the sk_buff
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index ba1de59..94c8164 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -1524,7 +1524,7 @@ static void veth_receive(struct veth_lpar_connect=
ion *cnx,
=20
 		skb_put(skb, length);
 		skb->protocol =3D eth_type_trans(skb, dev);
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 		netif_rx(skb);	/* send it up */
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes +=3D length;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.=
c
index 33c4ffe..831c960 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1905,7 +1905,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
 	 */
 	if ((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
 	   (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 		return;
 	}
=20
@@ -1913,7 +1913,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
 	/* now look at the TCP checksum error bit */
 	if (rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
 		/* let the stack verify checksum errors */
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 		adapter->hw_csum_rx_error++;
 	} else {
 		/* TCP checksum is good */
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_f=
coe.c
index 86fa07c..710e012 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -304,12 +304,13 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	if (!ixgbe_rx_is_fcoe(rx_desc))
 		goto ddp_out;
=20
-	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	sterr =3D le32_to_cpu(rx_desc->wb.upper.status_error);
 	fcerr =3D (sterr & IXGBE_RXDADV_ERR_FCERR);
 	fceofe =3D (sterr & IXGBE_RXDADV_ERR_FCEOFE);
 	if (fcerr =3D=3D IXGBE_FCERR_BADCRC)
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
+	else
+		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
 	if (eth_hdr(skb)->h_proto =3D=3D htons(ETH_P_8021Q))
 		fh =3D (struct fc_frame_header *)(skb->data +
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index 5e4dc1b..8581bb1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -980,7 +980,7 @@ static inline void ixgbe_rx_checksum(struct ixgbe_a=
dapter *adapter,
 {
 	u32 status_err =3D le32_to_cpu(rx_desc->wb.upper.status_error);
=20
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	/* Rx csum disabled */
 	if (!(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/i=
xgbevf_main.c
index 5d3c869..4da5677 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -356,7 +356,7 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_ve=
ctor *q_vector,
 static inline void ixgbevf_rx_checksum(struct ixgbevf_adapter *adapter=
,
 				       u32 status_err, struct sk_buff *skb)
 {
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	/* Rx csum disabled */
 	if (!(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 99f24f5..c4a5d4c 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -936,7 +936,7 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, int=
 idx)
 		if (jme_rxsum_ok(jme, le16_to_cpu(rxdesc->descwb.flags)))
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
=20
 		if (rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_TAGON)) {
 			if (jme->vlgrp) {
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index bdf2149..593e716 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -760,7 +760,7 @@ static void ll_temac_recv(struct net_device *ndev)
 		skb_put(skb, length);
 		skb->dev =3D ndev;
 		skb->protocol =3D eth_type_trans(skb, ndev);
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
=20
 		/* if we're doing rx csum offload, set it up */
 		if (((lp->temac_features & TEMAC_FEATURE_RX_CSUM) !=3D 0) &&
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index ff2f158..98ee212 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -407,7 +407,7 @@ static int macb_rx_frame(struct macb *bp, unsigned =
int first_frag,
 	}
=20
 	skb_reserve(skb, RX_OFFSET);
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
 	skb_put(skb, len);
=20
 	for (frag =3D first_frag; ; frag =3D NEXT_RX(frag)) {
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index b4cc61f..1f94e9b 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3484,7 +3484,7 @@ static int niu_process_rx_pkt(struct napi_struct =
*napi, struct niu *np,
 				     RCR_ENTRY_ERROR)))
 				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 			else
-				skb->ip_summed =3D CHECKSUM_NONE;
+				skb_checksum_none_assert(skb);
 		} else if (!(val & RCR_ENTRY_MULTI))
 			append_size =3D len - skb->len;
=20
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 447c2c4..3f75531 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -923,7 +923,7 @@ static void rx_irq(struct net_device *ndev)
 			if ((extsts & 0x002a0000) && !(extsts & 0x00540000)) {
 				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 			} else {
-				skb->ip_summed =3D CHECKSUM_NONE;
+				skb_checksum_none_assert(skb);
 			}
 			skb->protocol =3D eth_type_trans(skb, ndev);
 #ifdef NS83820_VLAN_ACCEL_SUPPORT
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 8ab6ae0..e31b194 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -808,7 +808,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac_rx=
ring *rx,
 			skb->csum =3D (macrx & XCT_MACRX_CSUM_M) >>
 					   XCT_MACRX_CSUM_S;
 		} else
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
=20
 		packets++;
 		tot_bytes +=3D len;
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 87d6b8f..5089fbf 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -956,9 +956,9 @@ static void gelic_net_pass_skb_up(struct gelic_desc=
r *descr,
 		    (!(data_error & GELIC_DESCR_DATA_ERROR_CHK_MASK)))
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
 	} else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
=20
 	/* update netdevice statistics */
 	netdev->stats.rx_packets++;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 6168a13..53dd13c 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2029,7 +2029,7 @@ static void ql_process_mac_rx_intr(struct ql3_ada=
pter *qdev,
 			 dma_unmap_len(lrg_buf_cb2, maplen),
 			 PCI_DMA_FROMDEVICE);
 	prefetch(skb->data);
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
 	skb->protocol =3D eth_type_trans(skb, qdev->ndev);
=20
 	netif_receive_skb(skb);
@@ -2076,7 +2076,7 @@ static void ql_process_macip_rx_intr(struct ql3_a=
dapter *qdev,
 			 PCI_DMA_FROMDEVICE);
 	prefetch(skb2->data);
=20
-	skb2->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb2);
 	if (qdev->device_id =3D=3D QL3022_DEVICE_ID) {
 		/*
 		 * Copy the ethhdr from first buffer to second. This
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcn=
ic_init.c
index 8e47d7a..f131a29 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1369,7 +1369,7 @@ static struct sk_buff *qlcnic_process_rxbuf(struc=
t qlcnic_adapter *adapter,
 		adapter->stats.csummed++;
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	} else {
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 	}
=20
 	skb->dev =3D adapter->netdev;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index 5a24521..efda005 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1566,7 +1566,7 @@ static void ql_process_mac_rx_page(struct ql_adap=
ter *qdev,
 	rx_ring->rx_packets++;
 	rx_ring->rx_bytes +=3D skb->len;
 	skb->protocol =3D eth_type_trans(skb, ndev);
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	if (qdev->rx_csum &&
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
@@ -1676,7 +1676,7 @@ static void ql_process_mac_rx_skb(struct ql_adapt=
er *qdev,
 	rx_ring->rx_packets++;
 	rx_ring->rx_bytes +=3D skb->len;
 	skb->protocol =3D eth_type_trans(skb, ndev);
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	/* If rx checksum is on, and there are no
 	 * csum or frame errors.
@@ -1996,7 +1996,7 @@ static void ql_process_mac_split_rx_intr(struct q=
l_adapter *qdev,
 	}
=20
 	skb->protocol =3D eth_type_trans(skb, ndev);
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	/* If rx checksum is on, and there are no
 	 * csum or frame errors.
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 078bbf4..6c06dff 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4460,7 +4460,7 @@ static inline void rtl8169_rx_csum(struct sk_buff=
 *skb, struct RxDesc *desc)
 	    ((status =3D=3D RxProtoIP) && !(opts1 & IPFail)))
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 }
=20
 static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff,
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 7061fc8..75591b4 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7603,10 +7603,10 @@ static int rx_osm_handler(struct ring_info *rin=
g_data, struct RxD_t * rxdp)
 			 * Packet with erroneous checksum, let the
 			 * upper layers deal with it.
 			 */
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
 		}
 	} else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
=20
 	swstats->mem_freed +=3D skb->truesize;
 send_up:
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 8e6bd45..1a6b931 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -1170,7 +1170,7 @@ again:
 						sb->ip_summed =3D CHECKSUM_UNNECESSARY;
 						/* don't need to set sb->csum */
 					} else {
-						sb->ip_summed =3D CHECKSUM_NONE;
+						skb_checksum_none_assert(sb);
 					}
 				}
 				prefetch(sb->data);
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 799c461..ef9944d 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -615,7 +615,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 	EFX_BUG_ON_PARANOID(!skb);
=20
 	/* Set the SKB flags */
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	/* Pass the packet up */
 	netif_receive_skb(skb);
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index a812efc..aff0dae 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -798,7 +798,7 @@ static int sh_eth_rx(struct net_device *ndev)
 			skb->dev =3D ndev;
 			sh_eth_set_receive_align(skb);
=20
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
 			rxdesc->addr =3D virt_to_phys(PTR_ALIGN(skb->data, 4));
 		}
 		if (entry >=3D RX_RING_SIZE - 1)
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 0909ae9..7a5b9b3 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1048,7 +1048,7 @@ static int smsc911x_poll(struct napi_struct *napi=
, int budget)
 		smsc911x_rx_readfifo(pdata, (unsigned int *)skb->head,
 				     pktwords);
 		skb->protocol =3D eth_type_trans(skb, dev);
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 		netif_receive_skb(skb);
=20
 		/* Update counters */
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 1636a34..1adc5de 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1000,9 +1000,9 @@ spider_net_pass_skb_up(struct spider_net_descr *d=
escr,
 		     !(data_error & SPIDER_NET_DATA_ERR_CKSUM_MASK))
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
 	} else
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
=20
 	if (data_status & SPIDER_NET_VLAN_PACKET) {
 		/* further enhancements: HW-accel VLAN
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmm=
ac_main.c
index e3f002e..c7c3169 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1256,7 +1256,7 @@ static int stmmac_rx(struct stmmac_priv *priv, in=
t limit)
=20
 			if (unlikely(status =3D=3D csum_none)) {
 				/* always for the old mac 10/100 */
-				skb->ip_summed =3D CHECKSUM_NONE;
+				skb_checksum_none_assert(skb);
 				netif_receive_skb(skb);
 			} else {
 				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 3128d6a..c2f9bad 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1297,12 +1297,13 @@ static int bdx_rx_receive(struct bdx_priv *priv=
, struct rxd_fifo *f, int budget)
 		ndev->stats.rx_bytes +=3D len;
=20
 		skb_put(skb, len);
-		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		skb->protocol =3D eth_type_trans(skb, ndev);
=20
 		/* Non-IP packets aren't checksum-offloaded */
 		if (GET_RXD_PKT_ID(rxd_val1) =3D=3D 0)
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
+		else
+			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
 		NETIF_RX_MUX(priv, rxd_val1, rxd_vlan, skb);
=20
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bc3af78..bb8c33a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4719,7 +4719,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int bud=
get)
 		      >> RXD_TCPCSUM_SHIFT) =3D=3D 0xffff))
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
=20
 		skb->protocol =3D eth_type_trans(skb, tp->dev);
=20
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 3f4681f..7ecfbb5 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1760,7 +1760,7 @@ typhoon_rx(struct typhoon *tp, struct basic_ring =
*rxRing, volatile __le32 * read
 		   (TYPHOON_RX_IP_CHK_GOOD | TYPHOON_RX_UDP_CHK_GOOD)) {
 			new_skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		} else
-			new_skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(new_skb);
=20
 		spin_lock(&tp->state_lock);
 		if(tp->vlgrp !=3D NULL && rx->rxStatus & TYPHOON_RX_VLAN)
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index fd69095..10bd69b 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1954,7 +1954,7 @@ static int velocity_tx_srv(struct velocity_info *=
vptr)
  */
 static inline void velocity_rx_csum(struct rx_desc *rd, struct sk_buff=
 *skb)
 {
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	if (rd->rdesc1.CSM & CSM_IPKT) {
 		if (rd->rdesc1.CSM & CSM_IPOK) {
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vm=
xnet3_drv.c
index abe0ff5..3a1d312 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1042,11 +1042,11 @@ vmxnet3_rx_csum(struct vmxnet3_adapter *adapter=
,
 				skb->csum =3D htons(gdesc->rcd.csum);
 				skb->ip_summed =3D CHECKSUM_PARTIAL;
 			} else {
-				skb->ip_summed =3D CHECKSUM_NONE;
+				skb_checksum_none_assert(skb);
 			}
 		}
 	} else {
-		skb->ip_summed =3D CHECKSUM_NONE;
+		skb_checksum_none_assert(skb);
 	}
 }
=20
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.=
c
index 01cdec7..7cc3323 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -501,7 +501,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void=
 *dtr,
 		    ext_info.l4_cksum =3D=3D VXGE_HW_L4_CKSUM_OK)
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else
-			skb->ip_summed =3D CHECKSUM_NONE;
+			skb_checksum_none_assert(skb);
=20
 		vxge_rx_complete(ring, skb, ext_info.vlan,
 			pkt_length, &ext_info);
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclit=
e.c
index 71122ee..7ab982f 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -641,7 +641,7 @@ static void xemaclite_rx_handler(struct net_device =
*dev)
 	skb_put(skb, len);	/* Tell the skb how much data we got */
=20
 	skb->protocol =3D eth_type_trans(skb, dev);
-	skb->ip_summed =3D CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
=20
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes +=3D len;


