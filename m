From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next] cxgb4: set skb->rxhash
Date: Tue, 27 Apr 2010 15:20:25 -0700
Message-ID: <1272406825-11615-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19316 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272Ab0D0W3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:29:49 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o3RMToW8003264
	for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 15:29:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the ->set_flags ethtool method to control NETIF_F_RXHASH and
set skb->rxhash to the HW calculated hash accordingly.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   15 ++++++++++++++-
 drivers/net/cxgb4/sge.c        |    7 ++++++-
 drivers/net/cxgb4/t4_msg.h     |    1 +
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 5f582db..1bad500 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1711,6 +1711,18 @@ static int set_tso(struct net_device *dev, u32 value)
 	return 0;
 }
 
+static int set_flags(struct net_device *dev, u32 flags)
+{
+	if (flags & ~ETH_FLAG_RXHASH)
+		return -EOPNOTSUPP;
+
+	if (flags & ETH_FLAG_RXHASH)
+		dev->features |= NETIF_F_RXHASH;
+	else
+		dev->features &= ~NETIF_F_RXHASH;
+	return 0;
+}
+
 static struct ethtool_ops cxgb_ethtool_ops = {
 	.get_settings      = get_settings,
 	.set_settings      = set_settings,
@@ -1741,6 +1753,7 @@ static struct ethtool_ops cxgb_ethtool_ops = {
 	.get_wol           = get_wol,
 	.set_wol           = set_wol,
 	.set_tso           = set_tso,
+	.set_flags         = set_flags,
 	.flash_device      = set_flash,
 };
 
@@ -3203,7 +3216,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 		netdev->features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6;
 		netdev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-		netdev->features |= NETIF_F_GRO | highdma;
+		netdev->features |= NETIF_F_GRO | NETIF_F_RXHASH | highdma;
 		netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->vlan_features = netdev->features & VLAN_FEAT;
 
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 65d91c4..e804ffc 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1524,6 +1524,8 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->truesize += skb->data_len;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
+	if (rxq->rspq.netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = ntohl(pkt->rsshdr.hash_val);
 
 	if (unlikely(pkt->vlan_ex)) {
 		struct port_info *pi = netdev_priv(rxq->rspq.netdev);
@@ -1565,7 +1567,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	if (unlikely(*(u8 *)rsp == CPL_TRACE_PKT))
 		return handle_trace_pkt(q->adap, si);
 
-	pkt = (void *)&rsp[1];
+	pkt = (const struct cpl_rx_pkt *)rsp;
 	csum_ok = pkt->csum_calc && !pkt->err_vec;
 	if ((pkt->l2info & htonl(RXF_TCP)) &&
 	    (q->netdev->features & NETIF_F_GRO) && csum_ok && !pkt->ip_frag) {
@@ -1583,6 +1585,9 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	__skb_pull(skb, RX_PKT_PAD);      /* remove ethernet header padding */
 	skb->protocol = eth_type_trans(skb, q->netdev);
 	skb_record_rx_queue(skb, q->idx);
+	if (skb->dev->features & NETIF_F_RXHASH)
+		skb->rxhash = ntohl(pkt->rsshdr.hash_val);
+
 	pi = netdev_priv(skb->dev);
 	rxq->stats.pkts++;
 
diff --git a/drivers/net/cxgb4/t4_msg.h b/drivers/net/cxgb4/t4_msg.h
index fdb1174..7a981b8 100644
--- a/drivers/net/cxgb4/t4_msg.h
+++ b/drivers/net/cxgb4/t4_msg.h
@@ -503,6 +503,7 @@ struct cpl_rx_data_ack {
 };
 
 struct cpl_rx_pkt {
+	struct rss_header rsshdr;
 	u8 opcode;
 #if defined(__LITTLE_ENDIAN_BITFIELD)
 	u8 iff:4;
-- 
1.5.4

