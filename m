From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH 2/3] cxgb4: add cxgb4_fcoe.c for FCoE
Date: Tue, 24 Mar 2015 19:14:46 +0530
Message-ID: <1cc49d916480bd8c1804709719bc90e1c16ad8dc.1427199268.git.varun@chelsio.com>
References: <cover.1427199268.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, leedom@chelsio.com,
	anish@chelsio.com, hariprasad@chelsio.com, praveenm@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7629 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752555AbbCXNqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:46:18 -0400
In-Reply-To: <cover.1427199268.git.varun@chelsio.com>
In-Reply-To: <cover.1427199268.git.varun@chelsio.com>
References: <cover.1427199268.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds cxgb4_fcoe.c and enables FCOE_CRC, FCOE_MTU
net device features.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c |  122 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    8 ++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   74 +++++++++++++-
 3 files changed, 201 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
new file mode 100644
index 0000000..062d3c0
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
@@ -0,0 +1,122 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2015 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifdef CONFIG_CHELSIO_T4_FCOE
+
+#include <scsi/fc/fc_fs.h>
+#include <scsi/libfcoe.h>
+#include "cxgb4.h"
+
+bool cxgb_fcoe_sof_eof_supported(struct adapter *adap, struct sk_buff *skb)
+{
+	struct fcoe_hdr *fcoeh = (struct fcoe_hdr *)skb_network_header(skb);
+	u8 sof = fcoeh->fcoe_sof;
+	u8 eof = 0;
+
+	if ((sof != FC_SOF_I3) && (sof != FC_SOF_N3)) {
+		dev_err(adap->pdev_dev, "Unsupported SOF 0x%x\n", sof);
+		return 0;
+	}
+
+	skb_copy_bits(skb, skb->len - 4, &eof, 1);
+
+	if ((eof != FC_EOF_N) && (eof != FC_EOF_T)) {
+		dev_err(adap->pdev_dev, "Unsupported EOF 0x%x\n", eof);
+		return 0;
+	}
+
+	return 1;
+}
+
+/**
+ * cxgb_fcoe_enable - enable FCoE offload features
+ * @netdev: net device
+ *
+ * Returns 0 on success or -EINVAL on failure.
+ */
+int cxgb_fcoe_enable(struct net_device *netdev)
+{
+	struct port_info *pi = netdev_priv(netdev);
+	struct adapter *adap = pi->adapter;
+	struct cxgb_fcoe *fcoe = &pi->fcoe;
+
+	if (is_t4(adap->params.chip))
+		return -EINVAL;
+
+	if (!(adap->flags & FULL_INIT_DONE))
+		return -EINVAL;
+
+	dev_info(adap->pdev_dev, "Enabling FCoE offload features\n");
+
+	netdev->features |= NETIF_F_FCOE_CRC;
+	netdev->vlan_features |= NETIF_F_FCOE_CRC;
+	netdev->features |= NETIF_F_FCOE_MTU;
+	netdev->vlan_features |= NETIF_F_FCOE_MTU;
+
+	netdev_features_change(netdev);
+
+	fcoe->flags |= CXGB_FCOE_ENABLED;
+
+	return 0;
+}
+
+/**
+ * cxgb_fcoe_disable - disable FCoE offload
+ * @netdev: net device
+ *
+ * Returns 0 on success or -EINVAL on failure.
+ */
+int cxgb_fcoe_disable(struct net_device *netdev)
+{
+	struct port_info *pi = netdev_priv(netdev);
+	struct adapter *adap = pi->adapter;
+	struct cxgb_fcoe *fcoe = &pi->fcoe;
+
+	if (!(fcoe->flags & CXGB_FCOE_ENABLED))
+		return -EINVAL;
+
+	dev_info(adap->pdev_dev, "Disabling FCoE offload features\n");
+
+	fcoe->flags &= ~CXGB_FCOE_ENABLED;
+
+	netdev->features &= ~NETIF_F_FCOE_CRC;
+	netdev->vlan_features &= ~NETIF_F_FCOE_CRC;
+	netdev->features &= ~NETIF_F_FCOE_MTU;
+	netdev->vlan_features &= ~NETIF_F_FCOE_MTU;
+
+	netdev_features_change(netdev);
+
+	return 0;
+}
+#endif /* CONFIG_CHELSIO_T4_FCOE */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index dd4b2da..e40e283 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1271,6 +1271,10 @@ static u16 cxgb_select_queue(struct net_device *dev, struct sk_buff *skb,
 			txq = 0;
 		} else {
 			txq = (vlan_tci & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+#ifdef CONFIG_CHELSIO_T4_FCOE
+			if (skb->protocol == htons(ETH_P_FCOE))
+				txq = skb->priority & 0x7;
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 		}
 		return txq;
 	}
@@ -4578,6 +4582,10 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller  = cxgb_netpoll,
 #endif
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	.ndo_fcoe_enable      = cxgb_fcoe_enable,
+	.ndo_fcoe_disable     = cxgb_fcoe_disable,
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll        = cxgb_busy_poll,
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index b4b9f60..c46e7a9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -46,6 +46,9 @@
 #ifdef CONFIG_NET_RX_BUSY_POLL
 #include <net/busy_poll.h>
 #endif /* CONFIG_NET_RX_BUSY_POLL */
+#ifdef CONFIG_CHELSIO_T4_FCOE
+#include <scsi/fc/fc_fcoe.h>
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 #include "cxgb4.h"
 #include "t4_regs.h"
 #include "t4_values.h"
@@ -1044,6 +1047,38 @@ static inline void txq_advance(struct sge_txq *q, unsigned int n)
 		q->pidx -= q->size;
 }
 
+#ifdef CONFIG_CHELSIO_T4_FCOE
+static inline int
+cxgb_fcoe_offload(struct sk_buff *skb, struct adapter *adap,
+		  const struct port_info *pi, u64 *cntrl)
+{
+	const struct cxgb_fcoe *fcoe = &pi->fcoe;
+
+	if (!(fcoe->flags & CXGB_FCOE_ENABLED))
+		return 0;
+
+	if (skb->protocol != htons(ETH_P_FCOE))
+		return 0;
+
+	skb_reset_mac_header(skb);
+	skb->mac_len = sizeof(struct ethhdr);
+
+	skb_set_network_header(skb, skb->mac_len);
+	skb_set_transport_header(skb, skb->mac_len + sizeof(struct fcoe_hdr));
+
+	if (!cxgb_fcoe_sof_eof_supported(adap, skb))
+		return -ENOTSUPP;
+
+	/* FC CRC offload */
+	*cntrl = TXPKT_CSUM_TYPE(TX_CSUM_FCOE) |
+		     TXPKT_L4CSUM_DIS | TXPKT_IPCSUM_DIS |
+		     TXPKT_CSUM_START(CXGB_FCOE_TXPKT_CSUM_START) |
+		     TXPKT_CSUM_END(CXGB_FCOE_TXPKT_CSUM_END) |
+		     TXPKT_CSUM_LOC(CXGB_FCOE_TXPKT_CSUM_END);
+	return 0;
+}
+#endif /* CONFIG_CHELSIO_T4_FCOE */
+
 /**
  *	t4_eth_xmit - add a packet to an Ethernet Tx queue
  *	@skb: the packet
@@ -1066,6 +1101,9 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	const struct skb_shared_info *ssi;
 	dma_addr_t addr[MAX_SKB_FRAGS + 1];
 	bool immediate = false;
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	int err;
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 
 	/*
 	 * The chip min packet length is 10 octets but play safe and reject
@@ -1082,6 +1120,13 @@ out_free:	dev_kfree_skb_any(skb);
 	q = &adap->sge.ethtxq[qidx + pi->first_qset];
 
 	reclaim_completed_tx(adap, &q->q, true);
+	cntrl = TXPKT_L4CSUM_DIS | TXPKT_IPCSUM_DIS;
+
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	err = cxgb_fcoe_offload(skb, adap, pi, &cntrl);
+	if (unlikely(err == -ENOTSUPP))
+		goto out_free;
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 
 	flits = calc_tx_flits(skb);
 	ndesc = flits_to_desc(flits);
@@ -1153,13 +1198,17 @@ out_free:	dev_kfree_skb_any(skb);
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS;
 			q->tx_cso++;
-		} else
-			cntrl = TXPKT_L4CSUM_DIS | TXPKT_IPCSUM_DIS;
+		}
 	}
 
 	if (skb_vlan_tag_present(skb)) {
 		q->vlan_ins++;
 		cntrl |= TXPKT_VLAN_VLD | TXPKT_VLAN(skb_vlan_tag_get(skb));
+#ifdef CONFIG_CHELSIO_T4_FCOE
+		if (skb->protocol == htons(ETH_P_FCOE))
+			cntrl |= TXPKT_VLAN(
+				 ((skb->priority & 0x7) << VLAN_PRIO_SHIFT));
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 	}
 
 	cpl->ctrl0 = htonl(TXPKT_OPCODE(CPL_TX_PKT_XT) |
@@ -1759,6 +1808,9 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	struct sge *s = &q->adap->sge;
 	int cpl_trace_pkt = is_t4(q->adap->params.chip) ?
 			    CPL_TRACE_PKT : CPL_TRACE_PKT_T5;
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	struct port_info *pi;
+#endif
 
 	if (unlikely(*(u8 *)rsp == cpl_trace_pkt))
 		return handle_trace_pkt(q->adap, si);
@@ -1799,8 +1851,24 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 			skb->ip_summed = CHECKSUM_COMPLETE;
 			rxq->stats.rx_cso++;
 		}
-	} else
+	} else {
 		skb_checksum_none_assert(skb);
+#ifdef CONFIG_CHELSIO_T4_FCOE
+#define CPL_RX_PKT_FLAGS (RXF_PSH_F | RXF_SYN_F | RXF_UDP_F | \
+			  RXF_TCP_F | RXF_IP_F | RXF_IP6_F | RXF_LRO_F)
+
+		pi = netdev_priv(skb->dev);
+		if (!(pkt->l2info & cpu_to_be32(CPL_RX_PKT_FLAGS))) {
+			if ((pkt->l2info & cpu_to_be32(RXF_FCOE_F)) &&
+			    (pi->fcoe.flags & CXGB_FCOE_ENABLED)) {
+				if (!(pkt->err_vec & cpu_to_be16(RXERR_CSUM_F)))
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+			}
+		}
+
+#undef CPL_RX_PKT_FLAGS
+#endif /* CONFIG_CHELSIO_T4_FCOE */
+	}
 
 	if (unlikely(pkt->vlan_ex)) {
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(pkt->vlan));
-- 
1.7.1
