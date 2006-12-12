From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch] remove NETIF_F_TSO ifdefery
Date: Tue, 12 Dec 2006 14:06:23 +0100
Message-ID: <1165928783.27217.600.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:37446 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751313AbWLLNG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 08:06:28 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBCD6PiP018477
	for <netdev@vger.kernel.org>; Tue, 12 Dec 2006 14:06:25 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBCD6OPs018476
	for netdev@vger.kernel.org; Tue, 12 Dec 2006 14:06:24 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this patch removes the NETIF_F_TSO #ifdef-ery in drivers/net; this was
for old-old-2.4 compat (even current 2.4 has NETIF_F_TSO)
but it's time to get rid of it by now.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>


Index: linux-2.6/drivers/net/bnx2.c
===================================================================
--- linux-2.6.orig/drivers/net/bnx2.c
+++ linux-2.6/drivers/net/bnx2.c
@@ -39,12 +39,10 @@
 #include <linux/if_vlan.h>
 #define BCM_VLAN 1
 #endif
-#ifdef NETIF_F_TSO
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/checksum.h>
 #define BCM_TSO 1
-#endif
 #include <linux/workqueue.h>
 #include <linux/crc32.h>
 #include <linux/prefetch.h>
@@ -1715,7 +1713,7 @@ bnx2_tx_int(struct bnx2 *bp)
 
 		tx_buf = &bp->tx_buf_ring[sw_ring_cons];
 		skb = tx_buf->skb;
-#ifdef BCM_TSO
+
 		/* partial BD completions possible with TSO packets */
 		if (skb_is_gso(skb)) {
 			u16 last_idx, last_ring_idx;
@@ -1731,7 +1729,7 @@ bnx2_tx_int(struct bnx2 *bp)
 				break;
 			}
 		}
-#endif
+
 		pci_unmap_single(bp->pdev, pci_unmap_addr(tx_buf, mapping),
 			skb_headlen(skb), PCI_DMA_TODEVICE);
 
@@ -4503,7 +4501,6 @@ bnx2_start_xmit(struct sk_buff *skb, str
 		vlan_tag_flags |=
 			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
 	}
-#ifdef BCM_TSO
 	if ((mss = skb_shinfo(skb)->gso_size) &&
 		(skb->len > (bp->dev->mtu + ETH_HLEN))) {
 		u32 tcp_opt_len, ip_tcp_len;
@@ -4536,7 +4533,6 @@ bnx2_start_xmit(struct sk_buff *skb, str
 		}
 	}
 	else
-#endif
 	{
 		mss = 0;
 	}
@@ -5533,10 +5529,8 @@ static const struct ethtool_ops bnx2_eth
 	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
-#ifdef BCM_TSO
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= bnx2_set_tso,
-#endif
 	.self_test_count	= bnx2_self_test_count,
 	.self_test		= bnx2_self_test,
 	.get_strings		= bnx2_get_strings,
@@ -6050,9 +6044,7 @@ bnx2_init_one(struct pci_dev *pdev, cons
 #ifdef BCM_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
-#ifdef BCM_TSO
 	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
-#endif
 
 	netif_carrier_off(bp->dev);
 
Index: linux-2.6/drivers/net/e1000/e1000.h
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000.h
+++ linux-2.6/drivers/net/e1000/e1000.h
@@ -59,17 +59,13 @@
 #include <linux/capability.h>
 #include <linux/in.h>
 #include <linux/ip.h>
-#ifdef NETIF_F_TSO6
 #include <linux/ipv6.h>
-#endif
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <net/pkt_sched.h>
 #include <linux/list.h>
 #include <linux/reboot.h>
-#ifdef NETIF_F_TSO
 #include <net/checksum.h>
-#endif
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
@@ -348,9 +344,7 @@ struct e1000_adapter {
 	boolean_t have_msi;
 #endif
 	/* to not mess up cache alignment, always add to the bottom */
-#ifdef NETIF_F_TSO
 	boolean_t tso_force;
-#endif
 	boolean_t smart_power_down;	/* phy smart power down */
 	boolean_t quad_port_a;
 	unsigned long flags;
Index: linux-2.6/drivers/net/e1000/e1000_ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_ethtool.c
+++ linux-2.6/drivers/net/e1000/e1000_ethtool.c
@@ -335,7 +335,6 @@ e1000_set_tx_csum(struct net_device *net
 	return 0;
 }
 
-#ifdef NETIF_F_TSO
 static int
 e1000_set_tso(struct net_device *netdev, uint32_t data)
 {
@@ -349,18 +348,15 @@ e1000_set_tso(struct net_device *netdev,
 	else
 		netdev->features &= ~NETIF_F_TSO;
 
-#ifdef NETIF_F_TSO6
 	if (data)
 		netdev->features |= NETIF_F_TSO6;
 	else
 		netdev->features &= ~NETIF_F_TSO6;
-#endif
 
 	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->tso_force = TRUE;
 	return 0;
 }
-#endif /* NETIF_F_TSO */
 
 static uint32_t
 e1000_get_msglevel(struct net_device *netdev)
@@ -1968,10 +1964,8 @@ static const struct ethtool_ops e1000_et
 	.set_tx_csum            = e1000_set_tx_csum,
 	.get_sg                 = ethtool_op_get_sg,
 	.set_sg                 = ethtool_op_set_sg,
-#ifdef NETIF_F_TSO
 	.get_tso                = ethtool_op_get_tso,
 	.set_tso                = e1000_set_tso,
-#endif
 	.self_test_count        = e1000_diag_test_count,
 	.self_test              = e1000_diag_test,
 	.get_strings            = e1000_get_strings,
Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -852,16 +852,12 @@ e1000_probe(struct pci_dev *pdev,
 			netdev->features &= ~NETIF_F_HW_VLAN_FILTER;
 	}
 
-#ifdef NETIF_F_TSO
 	if ((adapter->hw.mac_type >= e1000_82544) &&
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
-#ifdef NETIF_F_TSO6
 	if (adapter->hw.mac_type > e1000_82547_rev_2)
 		netdev->features |= NETIF_F_TSO6;
-#endif
-#endif
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
@@ -2490,7 +2486,6 @@ e1000_watchdog(unsigned long data)
 				E1000_WRITE_REG(&adapter->hw, TARC0, tarc0);
 			}
 
-#ifdef NETIF_F_TSO
 			/* disable TSO for pcie and 10/100 speeds, to avoid
 			 * some hardware issues */
 			if (!adapter->tso_force &&
@@ -2501,22 +2496,17 @@ e1000_watchdog(unsigned long data)
 					DPRINTK(PROBE,INFO,
 				        "10/100 speed: disabling TSO\n");
 					netdev->features &= ~NETIF_F_TSO;
-#ifdef NETIF_F_TSO6
 					netdev->features &= ~NETIF_F_TSO6;
-#endif
 					break;
 				case SPEED_1000:
 					netdev->features |= NETIF_F_TSO;
-#ifdef NETIF_F_TSO6
 					netdev->features |= NETIF_F_TSO6;
-#endif
 					break;
 				default:
 					/* oops */
 					break;
 				}
 			}
-#endif
 
 			/* enable transmits in the hardware, need to do this
 			 * after setting TARC0 */
@@ -2731,7 +2721,6 @@ static int
 e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
           struct sk_buff *skb)
 {
-#ifdef NETIF_F_TSO
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int i;
@@ -2760,7 +2749,6 @@ e1000_tso(struct e1000_adapter *adapter,
 						   0);
 			cmd_length = E1000_TXD_CMD_IP;
 			ipcse = skb->h.raw - skb->data - 1;
-#ifdef NETIF_F_TSO6
 		} else if (skb->protocol == htons(ETH_P_IPV6)) {
 			skb->nh.ipv6h->payload_len = 0;
 			skb->h.th->check =
@@ -2770,7 +2758,6 @@ e1000_tso(struct e1000_adapter *adapter,
 						 IPPROTO_TCP,
 						 0);
 			ipcse = 0;
-#endif
 		}
 		ipcss = skb->nh.raw - skb->data;
 		ipcso = (void *)&(skb->nh.iph->check) - (void *)skb->data;
@@ -2803,8 +2790,6 @@ e1000_tso(struct e1000_adapter *adapter,
 
 		return TRUE;
 	}
-#endif
-
 	return FALSE;
 }
 
@@ -2861,7 +2846,6 @@ e1000_tx_map(struct e1000_adapter *adapt
 	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, max_per_txd);
-#ifdef NETIF_F_TSO
 		/* Workaround for Controller erratum --
 		 * descriptor for non-tso packet in a linear SKB that follows a
 		 * tso gets written back prematurely before the data is fully
@@ -2876,7 +2860,6 @@ e1000_tx_map(struct e1000_adapter *adapt
 		 * in TSO mode.  Append 4-byte sentinel desc */
 		if (unlikely(mss && !nr_frags && size == len && size > 8))
 			size -= 4;
-#endif
 		/* work-around for errata 10 and it applies
 		 * to all controllers in PCI-X mode
 		 * The fix is to make sure that the first descriptor of a
@@ -2918,12 +2901,10 @@ e1000_tx_map(struct e1000_adapter *adapt
 		while (len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, max_per_txd);
-#ifdef NETIF_F_TSO
 			/* Workaround for premature desc write-backs
 			 * in TSO mode.  Append 4-byte sentinel desc */
 			if (unlikely(mss && f == (nr_frags-1) && size == len && size > 8))
 				size -= 4;
-#endif
 			/* Workaround for potential 82544 hang in PCI-X.
 			 * Avoid terminating buffers within evenly-aligned
 			 * dwords. */
@@ -3148,7 +3129,6 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	if (adapter->hw.mac_type >= e1000_82571)
 		max_per_txd = 8192;
 
-#ifdef NETIF_F_TSO
 	mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
@@ -3192,16 +3172,10 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	if ((mss) || (skb->ip_summed == CHECKSUM_PARTIAL))
 		count++;
 	count++;
-#else
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		count++;
-#endif
 
-#ifdef NETIF_F_TSO
 	/* Controller Erratum workaround */
 	if (!skb->data_len && tx_ring->last_tx_tso && !skb_is_gso(skb))
 		count++;
-#endif
 
 	count += TXD_USE_COUNT(len, max_txd_pwr);
 
Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -1550,12 +1550,10 @@ static int nv_start_xmit(struct sk_buff 
 
 	np->tx_skbuff[nr] = skb;
 
-#ifdef NETIF_F_TSO
 	if (skb_is_gso(skb))
 		tx_flags_extra = NV_TX2_TSO | (skb_shinfo(skb)->gso_size << NV_TX2_TSO_SHIFT);
 	else
-#endif
-	tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
+		tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
 			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
 	/* vlan tag */
@@ -4460,9 +4458,7 @@ static int __devinit nv_probe(struct pci
 		np->rx_csum = 1;
 		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
 		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
-#ifdef NETIF_F_TSO
 		dev->features |= NETIF_F_TSO;
-#endif
  	}
 
 	np->vlanctl_bits = 0;
Index: linux-2.6/drivers/net/ixgb/ixgb.h
===================================================================
--- linux-2.6.orig/drivers/net/ixgb/ixgb.h
+++ linux-2.6/drivers/net/ixgb/ixgb.h
@@ -61,9 +61,7 @@
 #include <net/pkt_sched.h>
 #include <linux/list.h>
 #include <linux/reboot.h>
-#ifdef NETIF_F_TSO
 #include <net/checksum.h>
-#endif
 
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
Index: linux-2.6/drivers/net/ixgb/ixgb_ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgb/ixgb_ethtool.c
+++ linux-2.6/drivers/net/ixgb/ixgb_ethtool.c
@@ -81,10 +81,8 @@ static struct ixgb_stats ixgb_gstrings_s
 	{"tx_timeout_count", IXGB_STAT(tx_timeout_count) },
 	{"rx_long_length_errors", IXGB_STAT(stats.roc)},
 	{"rx_short_length_errors", IXGB_STAT(stats.ruc)},
-#ifdef NETIF_F_TSO
 	{"tx_tcp_seg_good", IXGB_STAT(stats.tsctc)},
 	{"tx_tcp_seg_failed", IXGB_STAT(stats.tsctfc)},
-#endif
 	{"rx_flow_control_xon", IXGB_STAT(stats.xonrxc)},
 	{"rx_flow_control_xoff", IXGB_STAT(stats.xoffrxc)},
 	{"tx_flow_control_xon", IXGB_STAT(stats.xontxc)},
@@ -239,7 +237,6 @@ ixgb_set_tx_csum(struct net_device *netd
 	return 0;
 }
 
-#ifdef NETIF_F_TSO
 static int
 ixgb_set_tso(struct net_device *netdev, uint32_t data)
 {
@@ -249,7 +246,6 @@ ixgb_set_tso(struct net_device *netdev, 
 		netdev->features &= ~NETIF_F_TSO;
 	return 0;
 } 
-#endif /* NETIF_F_TSO */
 
 static uint32_t
 ixgb_get_msglevel(struct net_device *netdev)
@@ -721,10 +717,8 @@ static const struct ethtool_ops ixgb_eth
 	.set_sg	= ethtool_op_set_sg,
 	.get_msglevel = ixgb_get_msglevel,
 	.set_msglevel = ixgb_set_msglevel,
-#ifdef NETIF_F_TSO
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ixgb_set_tso,
-#endif
 	.get_strings = ixgb_get_strings,
 	.phys_id = ixgb_phys_id,
 	.get_stats_count = ixgb_get_stats_count,
Index: linux-2.6/drivers/net/ixgb/ixgb_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgb/ixgb_main.c
+++ linux-2.6/drivers/net/ixgb/ixgb_main.c
@@ -456,9 +456,7 @@ ixgb_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
-#ifdef NETIF_F_TSO
 	netdev->features |= NETIF_F_TSO;
-#endif
 #ifdef NETIF_F_LLTX
 	netdev->features |= NETIF_F_LLTX;
 #endif
@@ -1176,7 +1174,6 @@ ixgb_watchdog(unsigned long data)
 static int
 ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
-#ifdef NETIF_F_TSO
 	struct ixgb_context_desc *context_desc;
 	unsigned int i;
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
@@ -1233,7 +1230,6 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 
 		return 1;
 	}
-#endif
 
 	return 0;
 }
Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c
@@ -1412,10 +1412,8 @@ static const struct ethtool_ops myri10ge
 	.set_tx_csum = ethtool_op_set_tx_hw_csum,
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
-#ifdef NETIF_F_TSO
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
-#endif
 	.get_strings = myri10ge_get_strings,
 	.get_stats_count = myri10ge_get_stats_count,
 	.get_ethtool_stats = myri10ge_get_ethtool_stats,
@@ -1934,13 +1932,11 @@ again:
 	mss = 0;
 	max_segments = MXGEFW_MAX_SEND_DESC;
 
-#ifdef NETIF_F_TSO
 	if (skb->len > (dev->mtu + ETH_HLEN)) {
 		mss = skb_shinfo(skb)->gso_size;
 		if (mss != 0)
 			max_segments = MYRI10GE_MAX_SEND_DESC_TSO;
 	}
-#endif				/*NETIF_F_TSO */
 
 	if ((unlikely(avail < max_segments))) {
 		/* we are out of transmit resources */
@@ -1972,7 +1968,6 @@ again:
 
 	cum_len = 0;
 
-#ifdef NETIF_F_TSO
 	if (mss) {		/* TSO */
 		/* this removes any CKSUM flag from before */
 		flags = (MXGEFW_FLAGS_TSO_HDR | MXGEFW_FLAGS_FIRST);
@@ -1988,7 +1983,6 @@ again:
 		 * the checksum by parsing the header. */
 		pseudo_hdr_offset = mss;
 	} else
-#endif				/*NETIF_F_TSO */
 		/* Mark small packets, and pad out tiny packets */
 	if (skb->len <= MXGEFW_SEND_SMALL_SIZE) {
 		flags |= MXGEFW_FLAGS_SMALL;
@@ -2056,7 +2050,6 @@ again:
 				seglen = len;
 			flags_next = flags & ~MXGEFW_FLAGS_FIRST;
 			cum_len_next = cum_len + seglen;
-#ifdef NETIF_F_TSO
 			if (mss) {	/* TSO */
 				(req - rdma_count)->rdma_count = rdma_count + 1;
 
@@ -2083,7 +2076,6 @@ again:
 					    (small * MXGEFW_FLAGS_SMALL);
 				}
 			}
-#endif				/* NETIF_F_TSO */
 			req->addr_high = high_swapped;
 			req->addr_low = htonl(low);
 			req->pseudo_hdr_offset = htons(pseudo_hdr_offset);
@@ -2120,14 +2112,12 @@ again:
 	}
 
 	(req - rdma_count)->rdma_count = rdma_count;
-#ifdef NETIF_F_TSO
 	if (mss)
 		do {
 			req--;
 			req->flags |= MXGEFW_FLAGS_TSO_LAST;
 		} while (!(req->flags & (MXGEFW_FLAGS_TSO_CHOP |
 					 MXGEFW_FLAGS_FIRST)));
-#endif
 	idx = ((count - 1) + tx->req) & tx->mask;
 	tx->info[idx].last = 1;
 	if (tx->wc_fifo == NULL)
Index: linux-2.6/drivers/net/s2io.c
===================================================================
--- linux-2.6.orig/drivers/net/s2io.c
+++ linux-2.6/drivers/net/s2io.c
@@ -3888,12 +3888,10 @@ static int s2io_xmit(struct sk_buff *skb
 	}
 
 	offload_type = s2io_offload_type(skb);
-#ifdef NETIF_F_TSO
 	if (offload_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
 		txdp->Control_1 |= TXD_TCP_LSO_EN;
 		txdp->Control_1 |= TXD_TCP_LSO_MSS(s2io_tcp_mss(skb));
 	}
-#endif
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		txdp->Control_2 |=
 		    (TXD_TX_CKO_IPV4_EN | TXD_TX_CKO_TCP_EN |
@@ -5751,10 +5749,8 @@ static const struct ethtool_ops netdev_e
 	.set_tx_csum = s2io_ethtool_op_set_tx_csum,
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
-#ifdef NETIF_F_TSO
 	.get_tso = s2io_ethtool_op_get_tso,
 	.set_tso = s2io_ethtool_op_set_tso,
-#endif
 	.get_ufo = ethtool_op_get_ufo,
 	.set_ufo = ethtool_op_set_ufo,
 	.self_test_count = s2io_ethtool_self_test_count,
@@ -6979,12 +6975,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 	if (sp->high_dma_flag == TRUE)
 		dev->features |= NETIF_F_HIGHDMA;
-#ifdef NETIF_F_TSO
 	dev->features |= NETIF_F_TSO;
-#endif
-#ifdef NETIF_F_TSO6
 	dev->features |= NETIF_F_TSO6;
-#endif
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		dev->features |= NETIF_F_UFO;
 		dev->features |= NETIF_F_HW_CSUM;
Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c
+++ linux-2.6/drivers/net/tg3.c
@@ -58,11 +58,7 @@
 #define TG3_VLAN_TAG_USED 0
 #endif
 
-#ifdef NETIF_F_TSO
 #define TG3_TSO_SUPPORT	1
-#else
-#define TG3_TSO_SUPPORT	0
-#endif
 
 #include "tg3.h"
 
@@ -3853,7 +3849,6 @@ static int tg3_start_xmit(struct sk_buff
 
 	entry = tp->tx_prod;
 	base_flags = 0;
-#if TG3_TSO_SUPPORT != 0
 	mss = 0;
 	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
 	    (mss = skb_shinfo(skb)->gso_size) != 0) {
@@ -3886,11 +3881,6 @@ static int tg3_start_xmit(struct sk_buff
 	}
 	else if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-#else
-	mss = 0;
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-#endif
 #if TG3_VLAN_TAG_USED
 	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
 		base_flags |= (TXD_FLAG_VLAN |
@@ -3950,7 +3940,6 @@ out_unlock:
 	return NETDEV_TX_OK;
 }
 
-#if TG3_TSO_SUPPORT != 0
 static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
 
 /* Use GSO to workaround a rare TSO bug that may be triggered when the
@@ -3982,7 +3971,6 @@ tg3_tso_bug_end:
 
 	return NETDEV_TX_OK;
 }
-#endif
 
 /* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
  * support TG3_FLG2_HW_TSO_1 or firmware TSO only.
@@ -4016,7 +4004,6 @@ static int tg3_start_xmit_dma_bug(struct
 	base_flags = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-#if TG3_TSO_SUPPORT != 0
 	mss = 0;
 	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
 	    (mss = skb_shinfo(skb)->gso_size) != 0) {
@@ -4071,9 +4058,6 @@ static int tg3_start_xmit_dma_bug(struct
 			}
 		}
 	}
-#else
-	mss = 0;
-#endif
 #if TG3_VLAN_TAG_USED
 	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
 		base_flags |= (TXD_FLAG_VLAN |
@@ -5316,7 +5300,6 @@ static int tg3_load_5701_a0_firmware_fix
 	return 0;
 }
 
-#if TG3_TSO_SUPPORT != 0
 
 #define TG3_TSO_FW_RELEASE_MAJOR	0x1
 #define TG3_TSO_FW_RELASE_MINOR		0x6
@@ -5893,7 +5876,6 @@ static int tg3_load_tso_firmware(struct 
 	return 0;
 }
 
-#endif /* TG3_TSO_SUPPORT != 0 */
 
 /* tp->lock is held. */
 static void __tg3_set_mac_addr(struct tg3 *tp)
@@ -6107,7 +6089,6 @@ static int tg3_reset_hw(struct tg3 *tp, 
 		tw32(BUFMGR_DMA_DESC_POOL_ADDR, NIC_SRAM_DMA_DESC_POOL_BASE);
 		tw32(BUFMGR_DMA_DESC_POOL_SIZE, NIC_SRAM_DMA_DESC_POOL_SIZE);
 	}
-#if TG3_TSO_SUPPORT != 0
 	else if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
 		int fw_len;
 
@@ -6122,7 +6103,6 @@ static int tg3_reset_hw(struct tg3 *tp, 
 		tw32(BUFMGR_MB_POOL_SIZE,
 		     NIC_SRAM_MBUF_POOL_SIZE5705 - fw_len - 0xa00);
 	}
-#endif
 
 	if (tp->dev->mtu <= ETH_DATA_LEN) {
 		tw32(BUFMGR_MB_RDMA_LOW_WATER,
@@ -6324,10 +6304,8 @@ static int tg3_reset_hw(struct tg3 *tp, 
 	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)
 		rdmac_mode |= RDMAC_MODE_FIFO_LONG_BURST;
 
-#if TG3_TSO_SUPPORT != 0
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
 		rdmac_mode |= (1 << 27);
-#endif
 
 	/* Receive/send statistics. */
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
@@ -6498,10 +6476,8 @@ static int tg3_reset_hw(struct tg3 *tp, 
 	tw32(RCVBDI_MODE, RCVBDI_MODE_ENABLE | RCVBDI_MODE_RCB_ATTN_ENAB);
 	tw32(RCVDBDI_MODE, RCVDBDI_MODE_ENABLE | RCVDBDI_MODE_INV_RING_SZ);
 	tw32(SNDDATAI_MODE, SNDDATAI_MODE_ENABLE);
-#if TG3_TSO_SUPPORT != 0
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
 		tw32(SNDDATAI_MODE, SNDDATAI_MODE_ENABLE | 0x8);
-#endif
 	tw32(SNDBDI_MODE, SNDBDI_MODE_ENABLE | SNDBDI_MODE_ATTN_ENABLE);
 	tw32(SNDBDS_MODE, SNDBDS_MODE_ENABLE | SNDBDS_MODE_ATTN_ENABLE);
 
@@ -6511,13 +6487,11 @@ static int tg3_reset_hw(struct tg3 *tp, 
 			return err;
 	}
 
-#if TG3_TSO_SUPPORT != 0
 	if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
 		err = tg3_load_tso_firmware(tp);
 		if (err)
 			return err;
 	}
-#endif
 
 	tp->tx_mode = TX_MODE_ENABLE;
 	tw32_f(MAC_TX_MODE, tp->tx_mode);
@@ -8043,7 +8017,6 @@ static void tg3_set_msglevel(struct net_
 	tp->msg_enable = value;
 }
 
-#if TG3_TSO_SUPPORT != 0
 static int tg3_set_tso(struct net_device *dev, u32 value)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -8062,7 +8035,6 @@ static int tg3_set_tso(struct net_device
 	}
 	return ethtool_op_set_tso(dev, value);
 }
-#endif
 
 static int tg3_nway_reset(struct net_device *dev)
 {
@@ -9193,10 +9165,8 @@ static const struct ethtool_ops tg3_etht
 	.set_tx_csum		= tg3_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
-#if TG3_TSO_SUPPORT != 0
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= tg3_set_tso,
-#endif
 	.self_test_count	= tg3_get_test_count,
 	.self_test		= tg3_self_test,
 	.get_strings		= tg3_get_strings,
@@ -11835,7 +11805,6 @@ static int __devinit tg3_init_one(struct
 
 	tg3_init_bufmgr_config(tp);
 
-#if TG3_TSO_SUPPORT != 0
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
 		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
 	}
@@ -11860,7 +11829,6 @@ static int __devinit tg3_init_one(struct
 			dev->features |= NETIF_F_TSO6;
 	}
 
-#endif
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
 	    !(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&

