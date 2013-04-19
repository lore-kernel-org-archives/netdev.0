From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 4/6] net: vlan: add protocol argument to packet tagging functions
Date: Fri, 19 Apr 2013 14:04:30 +0200
Message-ID: <1366373072-19621-5-git-send-email-kaber@trash.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46102 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030204Ab3DSMEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:04:39 -0400
In-Reply-To: <1366373072-19621-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a protocol argument to the VLAN packet tagging functions. In case of HW
tagging, we need that protocol available in the ndo_start_xmit functions,
so it is stored in a new field in the skb. The new field fits into a hole
(on 64 bit) and doesn't increase the sks's size.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 drivers/infiniband/hw/nes/nes_hw.c                |  2 +-
 drivers/net/bonding/bond_alb.c                    |  4 +--
 drivers/net/ethernet/3com/typhoon.c               |  2 +-
 drivers/net/ethernet/adaptec/starfire.c           |  2 +-
 drivers/net/ethernet/alteon/acenic.c              |  2 +-
 drivers/net/ethernet/amd/amd8111e.c               |  2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   |  2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c   |  2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c          |  2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c          |  2 +-
 drivers/net/ethernet/broadcom/bnx2.c              |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |  4 +--
 drivers/net/ethernet/broadcom/tg3.c               |  2 +-
 drivers/net/ethernet/brocade/bna/bnad.c           |  2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.c           |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/sge.c          |  4 +--
 drivers/net/ethernet/chelsio/cxgb4/sge.c          |  4 +--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c        |  5 ++--
 drivers/net/ethernet/cisco/enic/enic_main.c       |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c       |  6 ++---
 drivers/net/ethernet/intel/e1000/e1000_main.c     |  2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c        |  2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |  2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c         |  2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |  4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
 drivers/net/ethernet/jme.c                        |  2 +-
 drivers/net/ethernet/marvell/sky2.c               |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |  4 +--
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c  |  2 +-
 drivers/net/ethernet/natsemi/ns83820.c            |  2 +-
 drivers/net/ethernet/neterion/s2io.c              |  2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c    |  2 +-
 drivers/net/ethernet/nvidia/forcedeth.c           |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c    |  8 +++---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c      |  8 +++---
 drivers/net/ethernet/realtek/8139cp.c             |  2 +-
 drivers/net/ethernet/realtek/r8169.c              |  2 +-
 drivers/net/ethernet/tehuti/tehuti.c              |  2 +-
 drivers/net/ethernet/via/via-rhine.c              |  2 +-
 drivers/net/ethernet/via/via-velocity.c           |  2 +-
 drivers/net/usb/cdc_mbim.c                        |  2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                 |  2 +-
 include/linux/if_vlan.h                           | 33 ++++++++++++++++-------
 include/linux/skbuff.h                            |  2 ++
 net/8021q/vlan_core.c                             |  8 +++---
 net/8021q/vlan_dev.c                              |  2 +-
 net/batman-adv/bridge_loop_avoidance.c            |  2 +-
 net/bridge/br_netfilter.c                         |  2 +-
 net/bridge/br_vlan.c                              |  4 +--
 net/core/dev.c                                    |  5 ++--
 net/core/netpoll.c                                |  5 ++--
 net/core/skbuff.c                                 |  1 +
 net/openvswitch/actions.c                         |  6 ++---
 net/openvswitch/datapath.c                        |  2 +-
 56 files changed, 107 insertions(+), 84 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw/nes/nes_hw.c
index 67647e2..418004c 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -2948,7 +2948,7 @@ void nes_nic_ce_handler(struct nes_device *nesdev, struct nes_hw_nic_cq *cq)
 					nes_debug(NES_DBG_CQ, "%s: Reporting stripped VLAN packet. Tag = 0x%04X\n",
 							nesvnic->netdev->name, vlan_tag);
 
-					__vlan_hwaccel_put_tag(rx_skb, vlan_tag);
+					__vlan_hwaccel_put_tag(rx_skb, htons(ETH_P_8021Q), vlan_tag);
 				}
 				if (nes_use_lro)
 					lro_receive_skb(&nesvnic->lro_mgr, rx_skb, NULL);
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index f5e0527..e02cc26 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -514,7 +514,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 		skb->dev = client_info->slave->dev;
 
 		if (client_info->tag) {
-			skb = vlan_put_tag(skb, client_info->vlan_id);
+			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), client_info->vlan_id);
 			if (!skb) {
 				pr_err("%s: Error: failed to insert VLAN tag\n",
 				       client_info->slave->bond->dev->name);
@@ -1014,7 +1014,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 				continue;
 			}
 
-			skb = vlan_put_tag(skb, vlan->vlan_id);
+			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan->vlan_id);
 			if (!skb) {
 				pr_err("%s: Error: failed to insert VLAN tag\n",
 				       bond->dev->name);
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 839a962..144942f6 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -1690,7 +1690,7 @@ typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile __le32 * read
 			skb_checksum_none_assert(new_skb);
 
 		if (rx->rxStatus & TYPHOON_RX_VLAN)
-			__vlan_hwaccel_put_tag(new_skb,
+			__vlan_hwaccel_put_tag(new_skb, htons(ETH_P_8021Q),
 					       ntohl(rx->vlanTag) & 0xffff);
 		netif_receive_skb(new_skb);
 
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index cdbc544..8b04bfc 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1498,7 +1498,7 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 				printk(KERN_DEBUG "  netdev_rx() vlanid = %d\n",
 				       vlid);
 			}
-			__vlan_hwaccel_put_tag(skb, vlid);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlid);
 		}
 #endif /* VLAN_SUPPORT */
 		netif_receive_skb(skb);
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index a7689d9..b7894f8 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -2019,7 +2019,7 @@ static void ace_rx_int(struct net_device *dev, u32 rxretprd, u32 rxretcsm)
 
 		/* send it up */
 		if ((bd_flags & BD_FLG_VLAN_TAG))
-			__vlan_hwaccel_put_tag(skb, retdesc->vlan);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), retdesc->vlan);
 		netif_rx(skb);
 
 		dev->stats.rx_packets++;
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 6bad84d..8e6b665 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -793,7 +793,7 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 #if AMD8111E_VLAN_TAG_USED
 			if (vtag == TT_VLAN_TAGGED){
 				u16 vlan_tag = le16_to_cpu(lp->rx_ring[rx_index].tag_ctrl_info);
-				__vlan_hwaccel_put_tag(skb, vlan_tag);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 			}
 #endif
 			netif_receive_skb(skb);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 3565255..0ba9007 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1809,7 +1809,7 @@ rrs_checked:
 
 			AT_TAG_TO_VLAN(rrs->vlan_tag, vlan);
 			vlan = le16_to_cpu(vlan);
-			__vlan_hwaccel_put_tag(skb, vlan);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan);
 		}
 		netif_receive_skb(skb);
 
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 598a611..0688bb8 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1435,7 +1435,7 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 				netdev_dbg(netdev,
 					   "RXD VLAN TAG<RRD>=0x%04x\n",
 					   prrs->vtag);
-				__vlan_hwaccel_put_tag(skb, vlan_tag);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 			}
 			netif_receive_skb(skb);
 
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index fd7d850..fa0915f 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2024,7 +2024,7 @@ rrd_ok:
 					((rrd->vlan_tag & 7) << 13) |
 					((rrd->vlan_tag & 8) << 9);
 
-			__vlan_hwaccel_put_tag(skb, vlan_tag);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 		}
 		netif_receive_skb(skb);
 
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 6b2c08a..265ce1b 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -452,7 +452,7 @@ static void atl2_intr_rx(struct atl2_adapter *adapter)
 					((rxd->status.vtag&7) << 13) |
 					((rxd->status.vtag&8) << 9);
 
-				__vlan_hwaccel_put_tag(skb, vlan_tag);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 			}
 			netif_rx(skb);
 			netdev->stats.rx_bytes += rx_size;
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 42a8bc8..5d20449 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3211,7 +3211,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		}
 		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) &&
 		    !(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG))
-			__vlan_hwaccel_put_tag(skb, rx_hdr->l2_fhdr_vlan_tag);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rx_hdr->l2_fhdr_vlan_tag);
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 352e58e..6b50443 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -719,7 +719,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		if (!bnx2x_fill_frag_skb(bp, fp, tpa_info, pages,
 					 skb, cqe, cqe_idx)) {
 			if (tpa_info->parsing_flags & PARSING_FLAGS_VLAN)
-				__vlan_hwaccel_put_tag(skb, tpa_info->vlan_tag);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), tpa_info->vlan_tag);
 			bnx2x_gro_receive(bp, fp, skb);
 		} else {
 			DP(NETIF_MSG_RX_STATUS,
@@ -994,7 +994,7 @@ reuse_rx:
 
 		if (le16_to_cpu(cqe_fp->pars_flags.flags) &
 		    PARSING_FLAGS_VLAN)
-			__vlan_hwaccel_put_tag(skb,
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       le16_to_cpu(cqe_fp->vlan_tag));
 		napi_gro_receive(&fp->napi, skb);
 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0c22c9a..ac83c87 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6715,7 +6715,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 
 		if (desc->type_flags & RXD_FLAG_VLAN &&
 		    !(tp->rx_mode & RX_MODE_KEEP_VLAN_TAG))
-			__vlan_hwaccel_put_tag(skb,
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       desc->err_vlan & RXD_VLAN_MASK);
 
 		napi_gro_receive(&tnapi->napi, skb);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index c0bc44e..ce4a030 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -610,7 +610,7 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		rcb->rxq->rx_bytes += length;
 
 		if (flags & BNA_CQ_EF_VLAN)
-			__vlan_hwaccel_put_tag(skb, ntohs(cmpl->vlan_tag));
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(cmpl->vlan_tag));
 
 		if (BNAD_RXBUF_IS_PAGE(unmap_q->type))
 			napi_gro_frags(&rx_ctrl->napi);
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index f85e065..8061fb0 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1386,7 +1386,7 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 
 	if (p->vlan_valid) {
 		st->vlan_xtract++;
-		__vlan_hwaccel_put_tag(skb, ntohs(p->vlan));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(p->vlan));
 	}
 	netif_receive_skb(skb);
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 9d67eb7..f12e6b8 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -2030,7 +2030,7 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 
 	if (p->vlan_valid) {
 		qs->port_stats[SGE_PSTAT_VLANEX]++;
-		__vlan_hwaccel_put_tag(skb, ntohs(p->vlan));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(p->vlan));
 	}
 	if (rq->polling) {
 		if (lro)
@@ -2132,7 +2132,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 
 	if (cpl->vlan_valid) {
 		qs->port_stats[SGE_PSTAT_VLANEX]++;
-		__vlan_hwaccel_put_tag(skb, ntohs(cpl->vlan));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(cpl->vlan));
 	}
 	napi_gro_frags(&qs->napi);
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 8b47b25..2bfbb20 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1633,7 +1633,7 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 		skb->rxhash = (__force u32)pkt->rsshdr.hash_val;
 
 	if (unlikely(pkt->vlan_ex)) {
-		__vlan_hwaccel_put_tag(skb, ntohs(pkt->vlan));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(pkt->vlan));
 		rxq->stats.vlan_ex++;
 	}
 	ret = napi_gro_frags(&rxq->rspq.napi);
@@ -1705,7 +1705,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 		skb_checksum_none_assert(skb);
 
 	if (unlikely(pkt->vlan_ex)) {
-		__vlan_hwaccel_put_tag(skb, ntohs(pkt->vlan));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(pkt->vlan));
 		rxq->stats.vlan_ex++;
 	}
 	netif_receive_skb(skb);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 61dfb2a..df296af 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1482,7 +1482,8 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb_record_rx_queue(skb, rxq->rspq.idx);
 
 	if (pkt->vlan_ex) {
-		__vlan_hwaccel_put_tag(skb, be16_to_cpu(pkt->vlan));
+		__vlan_hwaccel_put_tag(skb, cpu_to_be16(ETH_P_8021Q),
+					be16_to_cpu(pkt->vlan));
 		rxq->stats.vlan_ex++;
 	}
 	ret = napi_gro_frags(&rxq->rspq.napi);
@@ -1551,7 +1552,7 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 
 	if (pkt->vlan_ex) {
 		rxq->stats.vlan_ex++;
-		__vlan_hwaccel_put_tag(skb, be16_to_cpu(pkt->vlan));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(pkt->vlan));
 	}
 
 	netif_receive_skb(skb);
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 05c1e59..635f559 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1300,7 +1300,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		}
 
 		if (vlan_stripped)
-			__vlan_hwaccel_put_tag(skb, vlan_tci);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
 
 		if (netdev->features & NETIF_F_GRO)
 			napi_gro_receive(&enic->napi[q_number], skb);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b413331..811d0a4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -771,7 +771,7 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 
 	if (vlan_tx_tag_present(skb)) {
 		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
-		__vlan_put_tag(skb, vlan_tag);
+		__vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 		skb->vlan_tci = 0;
 	}
 
@@ -1383,7 +1383,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo,
 
 
 	if (rxcp->vlanf)
-		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rxcp->vlan_tag);
 
 	netif_receive_skb(skb);
 }
@@ -1439,7 +1439,7 @@ void be_rx_compl_process_gro(struct be_rx_obj *rxo, struct napi_struct *napi,
 		skb->rxhash = rxcp->rss_hash;
 
 	if (rxcp->vlanf)
-		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rxcp->vlan_tag);
 
 	napi_gro_frags(napi);
 }
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 8239daf..59ad007 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4003,7 +4003,7 @@ static void e1000_receive_skb(struct e1000_adapter *adapter, u8 status,
 	if (status & E1000_RXD_STAT_VP) {
 		u16 vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
 
-		__vlan_hwaccel_put_tag(skb, vid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 	}
 	napi_gro_receive(&adapter->napi, skb);
 }
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 8c17f01..da7f2fa 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -554,7 +554,7 @@ static void e1000_receive_skb(struct e1000_adapter *adapter,
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	if (staterr & E1000_RXD_STAT_VP)
-		__vlan_hwaccel_put_tag(skb, tag);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), tag);
 
 	napi_gro_receive(&adapter->napi, skb);
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e128388..119348f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6654,7 +6654,7 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 		else
 			vid = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-		__vlan_hwaccel_put_tag(skb, vid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 	}
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 3854fd6..93eb7ee 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -116,7 +116,7 @@ static void igbvf_receive_skb(struct igbvf_adapter *adapter,
 		else
 			vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
 		if (test_bit(vid, adapter->active_vlans))
-			__vlan_hwaccel_put_tag(skb, vid);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 	}
 
 	napi_gro_receive(&adapter->rx_ring->napi, skb);
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index a32f274..fce3e92 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -2082,8 +2082,8 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 
 		skb->protocol = eth_type_trans(skb, netdev);
 		if (status & IXGB_RX_DESC_STATUS_VP)
-			__vlan_hwaccel_put_tag(skb,
-					       le16_to_cpu(rx_desc->special));
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       le16_to_cpu(rx_desc->special));
 
 		netif_receive_skb(skb);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d128695..c67f9fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1445,7 +1445,7 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	    ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
 		u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
-		__vlan_hwaccel_put_tag(skb, vid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 	}
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 4bc1f84..1f5166a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -291,7 +291,7 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
 	if (is_vlan && test_bit(tag & VLAN_VID_MASK, adapter->active_vlans))
-		__vlan_hwaccel_put_tag(skb, tag);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), tag);
 
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
 		napi_gro_receive(&q_vector->napi, skb);
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index d28ce6f..070a6f1 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1059,7 +1059,7 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, int idx)
 		if (rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_TAGON)) {
 			u16 vid = le16_to_cpu(rxdesc->descwb.vlan);
 
-			__vlan_hwaccel_put_tag(skb, vid);
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 			NET_STAT(jme).rx_bytes += 4;
 		}
 		jme->jme_rx(skb);
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index bf9da1b..256ae78 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2713,7 +2713,7 @@ static void sky2_rx_tag(struct sky2_port *sky2, u16 length)
 	struct sk_buff *skb;
 
 	skb = sky2->rx_ring[sky2->rx_next].skb;
-	__vlan_hwaccel_put_tag(skb, be16_to_cpu(length));
+	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(length));
 }
 
 static void sky2_rx_hash(struct sky2_port *sky2, u32 status)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c7f8563..4006f88 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -673,7 +673,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)) {
 						u16 vid = be16_to_cpu(cqe->sl_vid);
 
-						__vlan_hwaccel_put_tag(gro_skb, vid);
+						__vlan_hwaccel_put_tag(gro_skb, htons(ETH_P_8021Q), vid);
 					}
 
 					if (dev->features & NETIF_F_RXHASH)
@@ -716,7 +716,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 		if (be32_to_cpu(cqe->vlan_my_qpn) &
 		    MLX4_CQE_VLAN_PRESENT_MASK)
-			__vlan_hwaccel_put_tag(skb, be16_to_cpu(cqe->sl_vid));
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(cqe->sl_vid));
 
 		/* Push it up the stack */
 		netif_receive_skb(skb);
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 46262ea..7be9788 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1290,7 +1290,7 @@ myri10ge_vlan_rx(struct net_device *dev, void *addr, struct sk_buff *skb)
 			skb->csum = csum_sub(skb->csum, vsum);
 		}
 		/* pop tag */
-		__vlan_hwaccel_put_tag(skb, ntohs(veh->h_vlan_TCI));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(veh->h_vlan_TCI));
 		memmove(va + VLAN_HLEN, va, 2 * ETH_ALEN);
 		skb->len -= VLAN_HLEN;
 		skb->data_len -= VLAN_HLEN;
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 60267e9..d3b4700 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -911,7 +911,7 @@ static void rx_irq(struct net_device *ndev)
 				unsigned short tag;
 
 				tag = ntohs(extsts & EXTSTS_VTG_MASK);
-				__vlan_hwaccel_put_tag(skb, tag);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_IPV6), tag);
 			}
 #endif
 			rx_rc = netif_rx(skb);
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index ec82d59..51b0094 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -8555,7 +8555,7 @@ static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 
 	skb->protocol = eth_type_trans(skb, dev);
 	if (vlan_tag && sp->vlan_strip_flag)
-		__vlan_hwaccel_put_tag(skb, vlan_tag);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 	if (sp->config.napi)
 		netif_receive_skb(skb);
 	else
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index a939614..cbfaed5 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -312,7 +312,7 @@ vxge_rx_complete(struct vxge_ring *ring, struct sk_buff *skb, u16 vlan,
 
 	if (ext_info->vlan &&
 	    ring->vlan_tag_strip == VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE)
-		__vlan_hwaccel_put_tag(skb, ext_info->vlan);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ext_info->vlan);
 	napi_gro_receive(ring->napi_p, skb);
 
 	vxge_debug_entryexit(VXGE_TRACE,
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 6c04946..b22f620 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2969,7 +2969,7 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			    vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
 				u16 vid = vlanflags & NV_RX3_VLAN_TAG_MASK;
 
-				__vlan_hwaccel_put_tag(skb, vid);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 			}
 			napi_gro_receive(&np->napi, skb);
 			u64_stats_update_begin(&np->swstats_rx_syncp);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index a85ca63a..56223a6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1050,7 +1050,7 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	if (vid != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 
 	napi_gro_receive(&sds_ring->napi, skb);
 
@@ -1153,7 +1153,7 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	}
 
 	if (vid != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 	netif_receive_skb(skb);
 
 	adapter->stats.lro_pkts++;
@@ -1518,7 +1518,7 @@ qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	if (vid != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 
 	napi_gro_receive(&sds_ring->napi, skb);
 
@@ -1615,7 +1615,7 @@ qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
 	}
 
 	if (vid != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 
 	netif_receive_skb(skb);
 
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index a9016ac..44cf72a 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1498,7 +1498,7 @@ static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rx_ring->cq_id);
 	if (vlan_id != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vlan_id);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	napi_gro_frags(napi);
 }
 
@@ -1574,7 +1574,7 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 
 	skb_record_rx_queue(skb, rx_ring->cq_id);
 	if (vlan_id != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vlan_id);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
 		napi_gro_receive(napi, skb);
 	else
@@ -1670,7 +1670,7 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 
 	skb_record_rx_queue(skb, rx_ring->cq_id);
 	if (vlan_id != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vlan_id);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
 		napi_gro_receive(&rx_ring->napi, skb);
 	else
@@ -1975,7 +1975,7 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 	rx_ring->rx_bytes += skb->len;
 	skb_record_rx_queue(skb, rx_ring->cq_id);
 	if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) && (vlan_id != 0))
-		__vlan_hwaccel_put_tag(skb, vlan_id);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
 		napi_gro_receive(&rx_ring->napi, skb);
 	else
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 6d03b52..7d1fb9a 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -431,7 +431,7 @@ static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
 	cp->dev->stats.rx_bytes += skb->len;
 
 	if (opts2 & RxVlanTagged)
-		__vlan_hwaccel_put_tag(skb, swab16(opts2 & 0xffff));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), swab16(opts2 & 0xffff));
 
 	napi_gro_receive(&cp->napi, skb);
 }
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 86d5d79..c6dac38 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1843,7 +1843,7 @@ static void rtl8169_rx_vlan_tag(struct RxDesc *desc, struct sk_buff *skb)
 	u32 opts2 = le32_to_cpu(desc->opts2);
 
 	if (opts2 & RxVlanTag)
-		__vlan_hwaccel_put_tag(skb, swab16(opts2 & 0xffff));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), swab16(opts2 & 0xffff));
 }
 
 static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index f7050c5..571452e 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1148,7 +1148,7 @@ NETIF_RX_MUX(struct bdx_priv *priv, u32 rxd_val1, u16 rxd_vlan,
 		    priv->ndev->name,
 		    GET_RXD_VLAN_ID(rxd_vlan),
 		    GET_RXD_VTAG(rxd_val1));
-		__vlan_hwaccel_put_tag(skb, GET_RXD_VLAN_TCI(rxd_vlan));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), GET_RXD_VLAN_TCI(rxd_vlan));
 	}
 	netif_receive_skb(skb);
 }
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 2a60d71..d994818 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1936,7 +1936,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 			skb->protocol = eth_type_trans(skb, dev);
 
 			if (unlikely(desc_length & DescTag))
-				__vlan_hwaccel_put_tag(skb, vlan_tci);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
 			netif_receive_skb(skb);
 
 			u64_stats_update_begin(&rp->rx_stats.syncp);
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 91cd591..fb62489 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2080,7 +2080,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	if (rd->rdesc0.RSR & RSR_DETAG) {
 		u16 vid = swab16(le16_to_cpu(rd->rdesc1.PQTAG));
 
-		__vlan_hwaccel_put_tag(skb, vid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 	}
 	netif_rx(skb);
 
diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index b7e9cd7..cc6dfe4 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -221,7 +221,7 @@ static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *buf, size_
 
 	/* map MBIM session to VLAN */
 	if (tci)
-		vlan_put_tag(skb, tci);
+		vlan_put_tag(skb, htons(ETH_P_8021Q), tci);
 err:
 	return skb;
 }
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 27b8899..55a62ca 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1293,7 +1293,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			skb->protocol = eth_type_trans(skb, adapter->netdev);
 
 			if (unlikely(rcd->ts))
-				__vlan_hwaccel_put_tag(skb, rcd->tci);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rcd->tci);
 
 			if (adapter->netdev->features & NETIF_F_LRO)
 				netif_receive_skb(skb);
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 2c9fb65..8086ff9 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -157,9 +157,18 @@ static inline bool vlan_uses_dev(const struct net_device *dev)
 }
 #endif
 
+static inline bool vlan_hw_offload_capable(netdev_features_t features,
+					   __be16 proto)
+{
+	if (proto == htons(ETH_P_8021Q) && features & NETIF_F_HW_VLAN_CTAG_TX)
+		return true;
+	return false;
+}
+
 /**
  * vlan_insert_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
+ * @vlan_proto: VLAN encapsulation protocol
  * @vlan_tci: VLAN TCI to insert
  *
  * Inserts the VLAN tag into @skb as part of the payload
@@ -170,7 +179,8 @@ static inline bool vlan_uses_dev(const struct net_device *dev)
  *
  * Does not change skb->protocol so this function can be used during receive.
  */
-static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
+static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
+					      __be16 vlan_proto, u16 vlan_tci)
 {
 	struct vlan_ethhdr *veth;
 
@@ -185,7 +195,7 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
 	skb->mac_header -= VLAN_HLEN;
 
 	/* first, the ethernet type */
-	veth->h_vlan_proto = htons(ETH_P_8021Q);
+	veth->h_vlan_proto = vlan_proto;
 
 	/* now, the TCI */
 	veth->h_vlan_TCI = htons(vlan_tci);
@@ -204,24 +214,28 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
  * Following the skb_unshare() example, in case of error, the calling function
  * doesn't have to worry about freeing the original skb.
  */
-static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
+static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb,
+					     __be16 vlan_proto, u16 vlan_tci)
 {
-	skb = vlan_insert_tag(skb, vlan_tci);
+	skb = vlan_insert_tag(skb, vlan_proto, vlan_tci);
 	if (skb)
-		skb->protocol = htons(ETH_P_8021Q);
+		skb->protocol = vlan_proto;
 	return skb;
 }
 
 /**
  * __vlan_hwaccel_put_tag - hardware accelerated VLAN inserting
  * @skb: skbuff to tag
+ * @vlan_proto: VLAN encapsulation protocol
  * @vlan_tci: VLAN TCI to insert
  *
  * Puts the VLAN TCI in @skb->vlan_tci and lets the device do the rest
  */
 static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
+						     __be16 vlan_proto,
 						     u16 vlan_tci)
 {
+	skb->vlan_proto = vlan_proto;
 	skb->vlan_tci = VLAN_TAG_PRESENT | vlan_tci;
 	return skb;
 }
@@ -236,12 +250,13 @@ static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
  * Assumes skb->dev is the target that will xmit this frame.
  * Returns a VLAN tagged skb.
  */
-static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
+static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb,
+					   __be16 vlan_proto, u16 vlan_tci)
 {
-	if (skb->dev->features & NETIF_F_HW_VLAN_CTAG_TX) {
-		return __vlan_hwaccel_put_tag(skb, vlan_tci);
+	if (vlan_hw_offload_capable(skb->dev->features, vlan_proto)) {
+		return __vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
 	} else {
-		return __vlan_put_tag(skb, vlan_tci);
+		return __vlan_put_tag(skb, vlan_proto, vlan_tci);
 	}
 }
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e27d1c7..f5bed7b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -387,6 +387,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@secmark: security marking
  *	@mark: Generic packet mark
  *	@dropcount: total number of sk_receive_queue overflows
+ *	@vlan_proto: vlan encapsulation protocol
  *	@vlan_tci: vlan tag control information
  *	@inner_transport_header: Inner transport layer header (encapsulation)
  *	@inner_network_header: Network layer header (encapsulation)
@@ -465,6 +466,7 @@ struct sk_buff {
 
 	__u32			rxhash;
 
+	__be16			vlan_proto;
 	__u16			vlan_tci;
 
 #ifdef CONFIG_NET_SCHED
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 4e4c360..bdb0b9d 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -8,11 +8,12 @@
 bool vlan_do_receive(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
+	__be16 vlan_proto = skb->vlan_proto;
 	u16 vlan_id = skb->vlan_tci & VLAN_VID_MASK;
 	struct net_device *vlan_dev;
 	struct vlan_pcpu_stats *rx_stats;
 
-	vlan_dev = vlan_find_dev(skb->dev, htons(ETH_P_8021Q), vlan_id);
+	vlan_dev = vlan_find_dev(skb->dev, vlan_proto, vlan_id);
 	if (!vlan_dev)
 		return false;
 
@@ -38,7 +39,8 @@ bool vlan_do_receive(struct sk_buff **skbp)
 		 * original position later
 		 */
 		skb_push(skb, offset);
-		skb = *skbp = vlan_insert_tag(skb, skb->vlan_tci);
+		skb = *skbp = vlan_insert_tag(skb, skb->vlan_proto,
+					      skb->vlan_tci);
 		if (!skb)
 			return false;
 		skb_pull(skb, offset + VLAN_HLEN);
@@ -127,7 +129,7 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
 
 	vhdr = (struct vlan_hdr *) skb->data;
 	vlan_tci = ntohs(vhdr->h_vlan_TCI);
-	__vlan_hwaccel_put_tag(skb, vlan_tci);
+	__vlan_hwaccel_put_tag(skb, skb->protocol, vlan_tci);
 
 	skb_pull_rcsum(skb, VLAN_HLEN);
 	vlan_set_encap_proto(skb, vhdr);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index d7457b7..8af5085 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -167,7 +167,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 		u16 vlan_tci;
 		vlan_tci = vlan->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-		skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
+		skb = __vlan_hwaccel_put_tag(skb, vlan->vlan_proto, vlan_tci);
 	}
 
 	skb->dev = vlan->real_dev;
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 6a4f728..379061c 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -341,7 +341,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 	}
 
 	if (vid != -1)
-		skb = vlan_insert_tag(skb, vid);
+		skb = vlan_insert_tag(skb, htons(ETH_P_8021Q), vid);
 
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_type_trans(skb, soft_iface);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index bd61bf5..1ed75bf 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -535,7 +535,7 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 	if (brnf_pass_vlan_indev == 0 || !vlan_tx_tag_present(skb))
 		return br;
 
-	vlan = __vlan_find_dev_deep(br, htons(ETH_P_8021Q),
+	vlan = __vlan_find_dev_deep(br, skb->vlan_proto,
 				    vlan_tx_tag_get(skb) & VLAN_VID_MASK);
 
 	return vlan ? vlan : br;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index c3076e2..bd58b45 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -175,7 +175,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			 * mac header.
 			 */
 			skb_push(skb, ETH_HLEN);
-			skb = __vlan_put_tag(skb, skb->vlan_tci);
+			skb = __vlan_put_tag(skb, skb->vlan_proto, skb->vlan_tci);
 			if (!skb)
 				goto out;
 			/* put skb->data back to where it was */
@@ -217,7 +217,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 		/* PVID is set on this port.  Any untagged ingress
 		 * frame is considered to belong to this vlan.
 		 */
-		__vlan_hwaccel_put_tag(skb, pvid);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
 		return true;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 07a8e9d..3a12ee1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2482,8 +2482,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		features = netif_skb_features(skb);
 
 		if (vlan_tx_tag_present(skb) &&
-		    !(features & NETIF_F_HW_VLAN_CTAG_TX)) {
-			skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
+		    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
+			skb = __vlan_put_tag(skb, skb->vlan_proto,
+					     vlan_tx_tag_get(skb));
 			if (unlikely(!skb))
 				goto out;
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 8de961e..4c28602 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -383,8 +383,9 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_xmit_stopped(txq)) {
 					if (vlan_tx_tag_present(skb) &&
-					    !(netif_skb_features(skb) & NETIF_F_HW_VLAN_CTAG_TX)) {
-						skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
+					    !vlan_hw_offload_capable(netif_skb_features(skb),
+						    		     skb->vlan_proto)) {
+						skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
 						if (unlikely(!skb))
 							break;
 						skb->vlan_tci = 0;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ba64614..a92d9e7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -707,6 +707,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->tc_verd		= old->tc_verd;
 #endif
 #endif
+	new->vlan_proto		= old->vlan_proto;
 	new->vlan_tci		= old->vlan_tci;
 
 	skb_copy_secmark(new, old);
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index d4d5363..894b6cb 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -98,7 +98,7 @@ static int pop_vlan(struct sk_buff *skb)
 	if (unlikely(err))
 		return err;
 
-	__vlan_hwaccel_put_tag(skb, ntohs(tci));
+	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(tci));
 	return 0;
 }
 
@@ -110,7 +110,7 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
 		/* push down current VLAN tag */
 		current_tag = vlan_tx_tag_get(skb);
 
-		if (!__vlan_put_tag(skb, current_tag))
+		if (!__vlan_put_tag(skb, skb->vlan_proto, current_tag))
 			return -ENOMEM;
 
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
@@ -118,7 +118,7 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
 					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
 
 	}
-	__vlan_hwaccel_put_tag(skb, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
+	__vlan_hwaccel_put_tag(skb, vlan->vlan_tpid, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
 	return 0;
 }
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index b7d0b7c..7bb5d4f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -401,7 +401,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 		if (!nskb)
 			return -ENOMEM;
 
-		nskb = __vlan_put_tag(nskb, vlan_tx_tag_get(nskb));
+		nskb = __vlan_put_tag(nskb, nskb->vlan_proto, vlan_tx_tag_get(nskb));
 		if (!nskb)
 			return -ENOMEM;
 
-- 
1.8.1.4
