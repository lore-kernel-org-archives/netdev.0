From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 03/14] vlan: Don't check for vlan group before vlan_tx_tag_present.
Date: Wed, 20 Oct 2010 16:56:03 -0700
Message-ID: <1287618974-4714-4-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34344 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab0JTX40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:26 -0400
Received: by mail-vw0-f46.google.com with SMTP id 2so2600261vws.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:25 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many (but not all) drivers check to see whether there is a vlan
group configured before using a tag stored in the skb.  There's
not much point in this check since it just throws away data that
should only be present in the expected circumstances.  However,
it will soon be legal and expected to get a vlan tag when no
vlan group is configured, so remove this check from all drivers
to avoid dropping the tags.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/8139cp.c               |    2 +-
 drivers/net/amd8111e.c             |    2 +-
 drivers/net/atl1c/atl1c_main.c     |    2 +-
 drivers/net/atl1e/atl1e_main.c     |    2 +-
 drivers/net/atlx/atl1.c            |    2 +-
 drivers/net/atlx/atl2.c            |    2 +-
 drivers/net/benet/be_main.c        |    7 +++----
 drivers/net/bna/bnad.c             |    2 +-
 drivers/net/bnx2.c                 |    2 +-
 drivers/net/bnx2x/bnx2x_cmn.c      |    3 +--
 drivers/net/chelsio/sge.c          |    2 +-
 drivers/net/cxgb3/sge.c            |    4 ++--
 drivers/net/e1000/e1000_main.c     |    2 +-
 drivers/net/e1000e/netdev.c        |    2 +-
 drivers/net/ehea/ehea_main.c       |    2 +-
 drivers/net/enic/enic_main.c       |    2 +-
 drivers/net/forcedeth.c            |   11 ++++-------
 drivers/net/gianfar.c              |    4 ++--
 drivers/net/igb/igb_main.c         |    2 +-
 drivers/net/ixgbe/ixgbe_main.c     |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/mlx4/en_tx.c           |    4 ++--
 drivers/net/qlge/qlge_main.c       |    2 +-
 drivers/net/r8169.c                |    2 +-
 drivers/net/s2io.c                 |    2 +-
 drivers/net/sky2.c                 |    2 +-
 drivers/net/tg3.c                  |    4 ++--
 drivers/net/via-velocity.c         |    2 +-
 drivers/net/vxge/vxge-main.c       |    2 +-
 29 files changed, 38 insertions(+), 43 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 237d4ea..ac422cd 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -754,7 +754,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 	}
 
 #if CP_VLAN_TAG_USED
-	if (cp->vlgrp && vlan_tx_tag_present(skb))
+	if (vlan_tx_tag_present(skb))
 		vlan_tag = TxVlanTag | swab16(vlan_tx_tag_get(skb));
 #endif
 
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 58a0ab4..2ca880b 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1315,7 +1315,7 @@ static netdev_tx_t amd8111e_start_xmit(struct sk_buff *skb,
 	lp->tx_ring[tx_index].tx_flags = 0;
 
 #if AMD8111E_VLAN_TAG_USED
-	if((lp->vlgrp != NULL) && vlan_tx_tag_present(skb)){
+	if (vlan_tx_tag_present(skb)) {
 		lp->tx_ring[tx_index].tag_ctrl_cmd |=
 				cpu_to_le16(TCC_VLAN_INSERT);
 		lp->tx_ring[tx_index].tag_ctrl_info =
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 553230e..99ffcf6 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -2243,7 +2243,7 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	if (unlikely(adapter->vlgrp && vlan_tx_tag_present(skb))) {
+	if (unlikely(vlan_tx_tag_present(skb))) {
 		u16 vlan = vlan_tx_tag_get(skb);
 		__le16 tag;
 
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 56ace3f..ef6349b 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1814,7 +1814,7 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 
 	tpd = atl1e_get_tpd(adapter);
 
-	if (unlikely(adapter->vlgrp && vlan_tx_tag_present(skb))) {
+	if (unlikely(vlan_tx_tag_present(skb))) {
 		u16 vlan_tag = vlan_tx_tag_get(skb);
 		u16 atl1e_vlan_tag;
 
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index b8c053f..dbd27b8 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2408,7 +2408,7 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 		(u16) atomic_read(&tpd_ring->next_to_use));
 	memset(ptpd, 0, sizeof(struct tx_packet_desc));
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		vlan_tag = vlan_tx_tag_get(skb);
 		vlan_tag = (vlan_tag << 4) | (vlan_tag >> 13) |
 			((vlan_tag >> 9) & 0x8);
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 29c0265..35b14be 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -870,7 +870,7 @@ static netdev_tx_t atl2_xmit_frame(struct sk_buff *skb,
 		offset = ((u32)(skb->len-copy_len + 3) & ~3);
 	}
 #ifdef NETIF_F_HW_VLAN_TX
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		u16 vlan_tag = vlan_tx_tag_get(skb);
 		vlan_tag = (vlan_tag << 4) |
 			(vlan_tag >> 13) |
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 4b59e53..d5e7968 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -430,7 +430,7 @@ static inline void wrb_fill(struct be_eth_wrb *wrb, u64 addr, int len)
 }
 
 static void wrb_fill_hdr(struct be_eth_hdr_wrb *hdr, struct sk_buff *skb,
-		bool vlan, u32 wrb_cnt, u32 len)
+		u32 wrb_cnt, u32 len)
 {
 	memset(hdr, 0, sizeof(*hdr));
 
@@ -449,7 +449,7 @@ static void wrb_fill_hdr(struct be_eth_hdr_wrb *hdr, struct sk_buff *skb,
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, udpcs, hdr, 1);
 	}
 
-	if (vlan && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan, hdr, 1);
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan_tag,
 			hdr, vlan_tx_tag_get(skb));
@@ -532,8 +532,7 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 		queue_head_inc(txq);
 	}
 
-	wrb_fill_hdr(hdr, first_skb, adapter->vlan_grp ? true : false,
-		wrb_cnt, copied);
+	wrb_fill_hdr(hdr, first_skb, wrb_cnt, copied);
 	be_dws_cpu_to_le(hdr, sizeof(*hdr));
 
 	return copied;
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 74c64d6..7e839b9 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -2501,7 +2501,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		htons((skb_is_gso(skb) ? BNA_TXQ_WI_SEND_LSO :
 		       BNA_TXQ_WI_SEND));
 
-	if (bnad->vlan_grp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		vlan_tag = (u16) vlan_tx_tag_get(skb);
 		flags |= (BNA_TXQ_WI_CF_INS_PRIO | BNA_TXQ_WI_CF_INS_VLAN);
 	}
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ae894bc..363ca8b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6429,7 +6429,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 #ifdef BCM_VLAN
-	if (bp->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		vlan_tag_flags |=
 			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
 	}
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 1966cee..6905b2e 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2026,8 +2026,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_start_bd);
 
 #ifdef BCM_VLAN
-	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb) &&
-	    (bp->flags & HW_VLAN_TX_FLAG)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_start_bd->vlan_or_ethertype =
 		    cpu_to_le16(vlan_tx_tag_get(skb));
 		tx_start_bd->bd_flags.as_bitfield |=
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 340b537..70221ca 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1870,7 +1870,7 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	cpl->iff = dev->if_port;
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-	if (adapter->vlan_grp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		cpl->vlan_valid = 1;
 		cpl->vlan = htons(vlan_tx_tag_get(skb));
 		st->vlan_insert++;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index c5a142b..7ad4625 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1145,7 +1145,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 	cpl->len = htonl(skb->len);
 	cntrl = V_TXPKT_INTF(pi->port_id);
 
-	if (vlan_tx_tag_present(skb) && pi->vlan_grp)
+	if (vlan_tx_tag_present(skb))
 		cntrl |= F_TXPKT_VLAN_VLD | V_TXPKT_VLAN(vlan_tx_tag_get(skb));
 
 	tso_info = V_LSO_MSS(skb_shinfo(skb)->gso_size);
@@ -1279,7 +1279,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		qs->port_stats[SGE_PSTAT_TX_CSUM]++;
 	if (skb_shinfo(skb)->gso_size)
 		qs->port_stats[SGE_PSTAT_TSO]++;
-	if (vlan_tx_tag_present(skb) && pi->vlan_grp)
+	if (vlan_tx_tag_present(skb))
 		qs->port_stats[SGE_PSTAT_VLANINS]++;
 
 	/*
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 232ac2d..a117f2a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3119,7 +3119,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		}
 	}
 
-	if (unlikely(adapter->vlgrp && vlan_tx_tag_present(skb))) {
+	if (unlikely(vlan_tx_tag_present(skb))) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
 	}
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5d6cdea..ec8cf3f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4800,7 +4800,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (e1000_maybe_stop_tx(netdev, count + 2))
 		return NETDEV_TX_BUSY;
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
 	}
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 6932578..a0d1170 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2272,7 +2272,7 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	pr->swqe_id_counter += 1;
 
-	if (port->vgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		swqe->tx_control |= EHEA_SWQE_VLAN_INSERT;
 		swqe->vlan_tag = vlan_tx_tag_get(skb);
 	}
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index a1f92f1..cfb6db4 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -743,7 +743,7 @@ static inline void enic_queue_wq_skb(struct enic *enic,
 	int vlan_tag_insert = 0;
 	int loopback = 0;
 
-	if (enic->vlan_group && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		/* VLAN tag from trunking driver */
 		vlan_tag_insert = 1;
 		vlan_tag = vlan_tx_tag_get(skb);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index ddac63c..0fa1776 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2321,14 +2321,11 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
 	/* vlan tag */
-	if (likely(!np->vlangrp)) {
+	if (vlan_tx_tag_present(skb))
+		start_tx->txvlan = cpu_to_le32(NV_TX3_VLAN_TAG_PRESENT |
+					vlan_tx_tag_get(skb));
+	else
 		start_tx->txvlan = 0;
-	} else {
-		if (vlan_tx_tag_present(skb))
-			start_tx->txvlan = cpu_to_le32(NV_TX3_VLAN_TAG_PRESENT | vlan_tx_tag_get(skb));
-		else
-			start_tx->txvlan = 0;
-	}
 
 	spin_lock_irqsave(&np->lock, flags);
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6180089..4c4cc80 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2075,7 +2075,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* make space for additional header when fcb is needed */
 	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
-			(priv->vlgrp && vlan_tx_tag_present(skb)) ||
+			vlan_tx_tag_present(skb) ||
 			unlikely(do_tstamp)) &&
 			(skb_headroom(skb) < GMAC_FCB_LEN)) {
 		struct sk_buff *skb_new;
@@ -2161,7 +2161,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		gfar_tx_checksum(skb, fcb);
 	}
 
-	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		if (unlikely(NULL == fcb)) {
 			fcb = gfar_add_fcb(skb);
 			lstatus |= BD_LFLAG(TXBD_TOE);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0f0939c..75155a2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4128,7 +4128,7 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 		tx_flags |= IGB_TX_FLAGS_TSTAMP;
 	}
 
-	if (vlan_tx_tag_present(skb) && adapter->vlgrp) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= IGB_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << IGB_TX_FLAGS_VLAN_SHIFT);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1d42442..998debe 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6311,7 +6311,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 	int count = 0;
 	unsigned int f;
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb);
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 78bfbe4..dc03c96 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3134,7 +3134,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	tx_ring = &adapter->tx_ring[r_idx];
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb);
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 98dd620..a680cd4 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -583,7 +583,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 	/* If we support per priority flow control and the packet contains
 	 * a vlan tag, send the packet to the TX ring assigned to that priority
 	 */
-	if (priv->prof->rx_ppp && priv->vlgrp && vlan_tx_tag_present(skb)) {
+	if (priv->prof->rx_ppp && vlan_tx_tag_present(skb)) {
 		vlan_tag = vlan_tx_tag_get(skb);
 		return MLX4_EN_NUM_TX_RINGS + (vlan_tag >> 13);
 	}
@@ -634,7 +634,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_ind = skb->queue_mapping;
 	ring = &priv->tx_ring[tx_ind];
-	if (priv->vlgrp && vlan_tx_tag_present(skb))
+	if (vlan_tx_tag_present(skb))
 		vlan_tag = vlan_tx_tag_get(skb);
 
 	/* Check available TXBBs And 2K spare for prefetch */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 4ffebe8..ba0053d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2572,7 +2572,7 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 
 	mac_iocb_ptr->frame_len = cpu_to_le16((u16) skb->len);
 
-	if (qdev->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		netif_printk(qdev, tx_queued, KERN_DEBUG, qdev->ndev,
 			     "Adding a vlan tag %d.\n", vlan_tx_tag_get(skb));
 		mac_iocb_ptr->flags3 |= OB_MAC_IOCB_V;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1760533..242748b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1034,7 +1034,7 @@ static int rtl8169_set_rx_csum(struct net_device *dev, u32 data)
 static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
 				      struct sk_buff *skb)
 {
-	return (tp->vlgrp && vlan_tx_tag_present(skb)) ?
+	return (vlan_tx_tag_present(skb)) ?
 		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
 }
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index c70ad51..ecc25aa 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4101,7 +4101,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	queue = 0;
-	if (sp->vlgrp && vlan_tx_tag_present(skb))
+	if (vlan_tx_tag_present(skb))
 		vlan_tag = vlan_tx_tag_get(skb);
 	if (sp->config.tx_steering_type == TX_DEFAULT_STEERING) {
 		if (skb->protocol == htons(ETH_P_IP)) {
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 3ef9b67..d657708 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1782,7 +1782,7 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 	ctrl = 0;
 #ifdef SKY2_VLAN_TAG_USED
 	/* Add VLAN tag, can piggyback on LRGLEN or ADDR64 */
-	if (sky2->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		if (!le) {
 			le = get_tx_le(sky2, &slot);
 			le->addr = 0;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5b4c510..22720ee 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5745,7 +5745,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 	}
 
 #if TG3_VLAN_TAG_USED
-	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
+	if (vlan_tx_tag_present(skb))
 		base_flags |= (TXD_FLAG_VLAN |
 			       (vlan_tx_tag_get(skb) << 16));
 #endif
@@ -5991,7 +5991,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 		}
 	}
 #if TG3_VLAN_TAG_USED
-	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
+	if (vlan_tx_tag_present(skb))
 		base_flags |= (TXD_FLAG_VLAN |
 			       (vlan_tx_tag_get(skb) << 16));
 #endif
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index f199561..cab96ad 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2592,7 +2592,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 
 	td_ptr->tdesc1.cmd = TCPLS_NORMAL + (tdinfo->nskb_dma + 1) * 16;
 
-	if (vptr->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		td_ptr->tdesc1.vlan = cpu_to_le16(vlan_tx_tag_get(skb));
 		td_ptr->tdesc1.TCR |= TCR0_VETAG;
 	}
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 0bda7fe..a69542e 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -822,7 +822,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->name, __func__, __LINE__,
 		fifo_hw, dtr, dtr_priv);
 
-	if (vdev->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		u16 vlan_tag = vlan_tx_tag_get(skb);
 		vxge_hw_fifo_txdl_vlan_set(dtr, vlan_tag);
 	}
-- 
1.7.1

