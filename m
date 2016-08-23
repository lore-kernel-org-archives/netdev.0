From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next] alx: add tso support
Date: Tue, 23 Aug 2016 22:21:21 +0200
Message-ID: <1471983681-5661-1-git-send-email-tobias.regnery@gmail.com>
Cc: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net,
        Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35629 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753897AbcHWUWB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:22:01 -0400
Received: by mail-wm0-f66.google.com with SMTP id i5so19589144wmg.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:22:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add tso/tso6 support to the alx driver.
Based on information from the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 75 +++++++++++++++++++++++++++++++--
 1 file changed, 71 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 6453148d066a..4dabb6635b7d 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -993,6 +993,18 @@ static void alx_reset(struct work_struct *work)
 	rtnl_unlock();
 }
 
+static inline int alx_tpd_req(struct sk_buff *skb)
+{
+	int num;
+
+	num = skb_shinfo(skb)->nr_frags + 1;
+	/* we need one extra descriptor for LSOv2 */
+	if (skb_is_gso(skb) && skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		num++;
+
+	return num;
+}
+
 static int alx_tx_csum(struct sk_buff *skb, struct alx_txd *first)
 {
 	u8 cso, css;
@@ -1012,6 +1024,45 @@ static int alx_tx_csum(struct sk_buff *skb, struct alx_txd *first)
 	return 0;
 }
 
+static int alx_tso(struct sk_buff *skb, struct alx_txd *first)
+{
+	int err;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
+	if (!skb_is_gso(skb))
+		return 0;
+
+	err = skb_cow_head(skb, 0);
+	if (err < 0)
+		return err;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
+
+		iph->check = 0;
+		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+							 0, IPPROTO_TCP, 0);
+		first->word1 |= 1 << TPD_IPV4_SHIFT;
+	} else if (skb_is_gso_v6(skb)) {
+		ipv6_hdr(skb)->payload_len = 0;
+		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+						       &ipv6_hdr(skb)->daddr,
+						       0, IPPROTO_TCP, 0);
+		/* LSOv2: the first TPD only provides the packet length */
+		first->adrl.l.pkt_len = skb->len;
+		first->word1 |= 1 << TPD_LSO_V2_SHIFT;
+	}
+
+	first->word1 |= 1 << TPD_LSO_EN_SHIFT;
+	first->word1 |= (skb_transport_offset(skb) &
+			 TPD_L4HDROFFSET_MASK) << TPD_L4HDROFFSET_SHIFT;
+	first->word1 |= (skb_shinfo(skb)->gso_size &
+			 TPD_MSS_MASK) << TPD_MSS_SHIFT;
+	return 1;
+}
+
 static int alx_map_tx_skb(struct alx_priv *alx, struct sk_buff *skb)
 {
 	struct alx_tx_queue *txq = &alx->txq;
@@ -1022,6 +1073,16 @@ static int alx_map_tx_skb(struct alx_priv *alx, struct sk_buff *skb)
 	first_tpd = &txq->tpd[txq->write_idx];
 	tpd = first_tpd;
 
+	if (tpd->word1 & (1 << TPD_LSO_V2_SHIFT)) {
+		if (++txq->write_idx == alx->tx_ringsz)
+			txq->write_idx = 0;
+
+		tpd = &txq->tpd[txq->write_idx];
+		tpd->len = first_tpd->len;
+		tpd->vlan_tag = first_tpd->vlan_tag;
+		tpd->word1 = first_tpd->word1;
+	}
+
 	maplen = skb_headlen(skb);
 	dma = dma_map_single(&alx->hw.pdev->dev, skb->data, maplen,
 			     DMA_TO_DEVICE);
@@ -1082,9 +1143,9 @@ static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
 	struct alx_priv *alx = netdev_priv(netdev);
 	struct alx_tx_queue *txq = &alx->txq;
 	struct alx_txd *first;
-	int tpdreq = skb_shinfo(skb)->nr_frags + 1;
+	int tso;
 
-	if (alx_tpd_avail(alx) < tpdreq) {
+	if (alx_tpd_avail(alx) < alx_tpd_req(skb)) {
 		netif_stop_queue(alx->dev);
 		goto drop;
 	}
@@ -1092,7 +1153,10 @@ static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
 	first = &txq->tpd[txq->write_idx];
 	memset(first, 0, sizeof(*first));
 
-	if (alx_tx_csum(skb, first))
+	tso = alx_tso(skb, first);
+	if (tso < 0)
+		goto drop;
+	else if (!tso && alx_tx_csum(skb, first))
 		goto drop;
 
 	if (alx_map_tx_skb(alx, skb) < 0)
@@ -1351,7 +1415,10 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
-	netdev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
+	netdev->hw_features = NETIF_F_SG |
+			      NETIF_F_HW_CSUM |
+			      NETIF_F_TSO |
+			      NETIF_F_TSO6;
 
 	if (alx_get_perm_macaddr(hw, hw->perm_addr)) {
 		dev_warn(&pdev->dev,
-- 
2.7.4
