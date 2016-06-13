From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 08/11] bnxt_en: Add GRO logic for BCM5731X chips.
Date: Mon, 13 Jun 2016 02:25:35 -0400
Message-ID: <1465799138-27529-9-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33719 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030182AbcFMGZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:59 -0400
Received: by mail-pf0-f174.google.com with SMTP id y124so43026997pfy.0
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:58 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add bnxt_gro_func_5731x() to handle GRO packets for this chip.  The
completion structures used in the new chip have new data to help determine
the header offsets.  The offsets can be off by 4 if the packet is an
internal loopback packet (e.g. from one VF to another VF).  Some additional
logic is added to adjust the offsets if it is a loopback packet.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 89 ++++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 16 +++++-
 2 files changed, 103 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4e3b9f5..5f9285c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -924,6 +924,7 @@ static void bnxt_tpa_start(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
 	}
 	tpa_info->flags2 = le32_to_cpu(tpa_start1->rx_tpa_start_cmp_flags2);
 	tpa_info->metadata = le32_to_cpu(tpa_start1->rx_tpa_start_cmp_metadata);
+	tpa_info->hdr_info = le32_to_cpu(tpa_start1->rx_tpa_start_cmp_hdr_info);
 
 	rxr->rx_prod = NEXT_RX(prod);
 	cons = NEXT_RX(cons);
@@ -942,6 +943,90 @@ static void bnxt_abort_tpa(struct bnxt *bp, struct bnxt_napi *bnapi,
 		bnxt_reuse_rx_agg_bufs(bnapi, cp_cons, agg_bufs);
 }
 
+static struct sk_buff *bnxt_gro_func_5731x(struct bnxt_tpa_info *tpa_info,
+					   int payload_off, int tcp_ts,
+					   struct sk_buff *skb)
+{
+#ifdef CONFIG_INET
+	struct tcphdr *th;
+	int len, nw_off;
+	u16 outer_ip_off, inner_ip_off, inner_mac_off;
+	u32 hdr_info = tpa_info->hdr_info;
+	bool loopback = false;
+
+	inner_ip_off = BNXT_TPA_INNER_L3_OFF(hdr_info);
+	inner_mac_off = BNXT_TPA_INNER_L2_OFF(hdr_info);
+	outer_ip_off = BNXT_TPA_OUTER_L3_OFF(hdr_info);
+
+	/* If the packet is an internal loopback packet, the offsets will
+	 * have an extra 4 bytes.
+	 */
+	if (inner_mac_off == 4) {
+		loopback = true;
+	} else if (inner_mac_off > 4) {
+		__be16 proto = *((__be16 *)(skb->data + inner_ip_off -
+					    ETH_HLEN - 2));
+
+		/* We only support inner iPv4/ipv6.  If we don't see the
+		 * correct protocol ID, it must be a loopback packet where
+		 * the offsets are off by 4.
+		 */
+		if (proto != htons(ETH_P_IP) && proto && htons(ETH_P_IPV6))
+			loopback = true;
+	}
+	if (loopback) {
+		/* internal loopback packet, subtract all offsets by 4 */
+		inner_ip_off -= 4;
+		inner_mac_off -= 4;
+		outer_ip_off -= 4;
+	}
+
+	nw_off = inner_ip_off - ETH_HLEN;
+	skb_set_network_header(skb, nw_off);
+	if (tpa_info->flags2 & RX_TPA_START_CMP_FLAGS2_IP_TYPE) {
+		struct ipv6hdr *iph = ipv6_hdr(skb);
+
+		skb_set_transport_header(skb, nw_off + sizeof(struct ipv6hdr));
+		len = skb->len - skb_transport_offset(skb);
+		th = tcp_hdr(skb);
+		th->check = ~tcp_v6_check(len, &iph->saddr, &iph->daddr, 0);
+	} else {
+		struct iphdr *iph = ip_hdr(skb);
+
+		skb_set_transport_header(skb, nw_off + sizeof(struct iphdr));
+		len = skb->len - skb_transport_offset(skb);
+		th = tcp_hdr(skb);
+		th->check = ~tcp_v4_check(len, iph->saddr, iph->daddr, 0);
+	}
+
+	if (inner_mac_off) { /* tunnel */
+		struct udphdr *uh = NULL;
+		__be16 proto = *((__be16 *)(skb->data + outer_ip_off -
+					    ETH_HLEN - 2));
+
+		if (proto == htons(ETH_P_IP)) {
+			struct iphdr *iph = (struct iphdr *)skb->data;
+
+			if (iph->protocol == IPPROTO_UDP)
+				uh = (struct udphdr *)(iph + 1);
+		} else {
+			struct ipv6hdr *iph = (struct ipv6hdr *)skb->data;
+
+			if (iph->nexthdr == IPPROTO_UDP)
+				uh = (struct udphdr *)(iph + 1);
+		}
+		if (uh) {
+			if (uh->check)
+				skb_shinfo(skb)->gso_type |=
+					SKB_GSO_UDP_TUNNEL_CSUM;
+			else
+				skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
+		}
+	}
+#endif
+	return skb;
+}
+
 #define BNXT_IPV4_HDR_SIZE	(sizeof(struct iphdr) + sizeof(struct tcphdr))
 #define BNXT_IPV6_HDR_SIZE	(sizeof(struct ipv6hdr) + sizeof(struct tcphdr))
 
@@ -2283,7 +2368,7 @@ static void bnxt_set_tpa_flags(struct bnxt *bp)
 	bp->flags &= ~BNXT_FLAG_TPA;
 	if (bp->dev->features & NETIF_F_LRO)
 		bp->flags |= BNXT_FLAG_LRO;
-	if ((bp->dev->features & NETIF_F_GRO) && (bp->pdev->revision > 0))
+	if (bp->dev->features & NETIF_F_GRO)
 		bp->flags |= BNXT_FLAG_GRO;
 }
 
@@ -6433,6 +6518,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto init_err;
 
 	bp->gro_func = bnxt_gro_func_5730x;
+	if (BNXT_CHIP_NUM_57X1X(bp->chip_num))
+		bp->gro_func = bnxt_gro_func_5731x;
 
 	rc = bnxt_hwrm_func_drv_rgtr(bp);
 	if (rc)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index d62f4c2..c1b41fb 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -298,13 +298,14 @@ struct rx_tpa_start_cmp_ext {
 	#define RX_TPA_START_CMP_FLAGS2_L4_CS_CALC		(0x1 << 1)
 	#define RX_TPA_START_CMP_FLAGS2_T_IP_CS_CALC		(0x1 << 2)
 	#define RX_TPA_START_CMP_FLAGS2_T_L4_CS_CALC		(0x1 << 3)
+	#define RX_TPA_START_CMP_FLAGS2_IP_TYPE			(0x1 << 8)
 
 	__le32 rx_tpa_start_cmp_metadata;
 	__le32 rx_tpa_start_cmp_cfa_code_v2;
 	#define RX_TPA_START_CMP_V2				(0x1 << 0)
 	#define RX_TPA_START_CMP_CFA_CODE			(0xffff << 16)
 	 #define RX_TPA_START_CMPL_CFA_CODE_SHIFT		 16
-	__le32 rx_tpa_start_cmp_unused5;
+	__le32 rx_tpa_start_cmp_hdr_info;
 };
 
 struct rx_tpa_end_cmp {
@@ -584,6 +585,19 @@ struct bnxt_tpa_info {
 	u32			metadata;
 	enum pkt_hash_types	hash_type;
 	u32			rss_hash;
+	u32			hdr_info;
+
+#define BNXT_TPA_L4_SIZE(hdr_info)	\
+	(((hdr_info) & 0xf8000000) ? ((hdr_info) >> 27) : 32)
+
+#define BNXT_TPA_INNER_L3_OFF(hdr_info)	\
+	(((hdr_info) >> 18) & 0x1ff)
+
+#define BNXT_TPA_INNER_L2_OFF(hdr_info)	\
+	(((hdr_info) >> 9) & 0x1ff)
+
+#define BNXT_TPA_OUTER_L3_OFF(hdr_info)	\
+	((hdr_info) & 0x1ff)
 };
 
 struct bnxt_rx_ring_info {
-- 
1.8.3.1
