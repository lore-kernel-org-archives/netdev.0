From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 6/7] drivers: net: xgene: Add workaround for errata 10GE_8/ENET_11
Date: Wed, 15 Mar 2017 13:27:20 -0700
Message-ID: <1489609641-31557-7-git-send-email-isubramanian@apm.com>
References: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, qnguyen@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Toan Le <toanle@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35917 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbdCOU0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:26:13 -0400
Received: by mail-pg0-f50.google.com with SMTP id g2so14060604pge.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:26:12 -0700 (PDT)
In-Reply-To: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements workaround for errata 10GE_8 and ENET_11:
"HW reports length error for valid 64 byte frames with len <46 bytes"
by recovering them from error.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Toan Le <toanle@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 43 +++++++++++++++---------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  1 +
 4 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index c72a17e..2a835e0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -494,7 +494,7 @@ static void xgene_gmac_set_speed(struct xgene_enet_pdata *pdata)
 		break;
 	}
 
-	mc2 |= FULL_DUPLEX2 | PAD_CRC;
+	mc2 |= FULL_DUPLEX2 | PAD_CRC | LENGTH_CHK;
 	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_2_ADDR, mc2);
 	xgene_enet_wr_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, intf_ctl);
 	xgene_enet_wr_csr(pdata, RGMII_REG_0_ADDR, rgmii);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index b6cd625..d250bfe 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -216,6 +216,7 @@ enum xgene_enet_rm {
 #define ENET_GHD_MODE			BIT(26)
 #define FULL_DUPLEX2			BIT(0)
 #define PAD_CRC				BIT(2)
+#define LENGTH_CHK			BIT(4)
 #define SCAN_AUTO_INCR			BIT(5)
 #define TBYT_ADDR			0x38
 #define TPKT_ADDR			0x39
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index e881365..5f37ed3 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -658,12 +658,24 @@ static void xgene_enet_free_pagepool(struct xgene_enet_desc_ring *buf_pool,
 	buf_pool->head = head;
 }
 
+/* Errata 10GE_8 and ENET_11 - allow packet with length <=64B */
+static bool xgene_enet_errata_10GE_8(struct sk_buff *skb, u32 len, u8 status)
+{
+	if (status == INGRESS_PKT_LEN && len == ETHER_MIN_PACKET) {
+		if (ntohs(eth_hdr(skb)->h_proto) < 46)
+			return true;
+	}
+
+	return false;
+}
+
 static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 			       struct xgene_enet_raw_desc *raw_desc,
 			       struct xgene_enet_raw_desc *exp_desc)
 {
 	struct xgene_enet_desc_ring *buf_pool, *page_pool;
 	u32 datalen, frag_size, skb_index;
+	struct xgene_enet_pdata *pdata;
 	struct net_device *ndev;
 	dma_addr_t dma_addr;
 	struct sk_buff *skb;
@@ -676,6 +688,7 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 	bool nv;
 
 	ndev = rx_ring->ndev;
+	pdata = netdev_priv(ndev);
 	dev = ndev_to_dev(rx_ring->ndev);
 	buf_pool = rx_ring->buf_pool;
 	page_pool = rx_ring->page_pool;
@@ -686,30 +699,29 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 	skb = buf_pool->rx_skb[skb_index];
 	buf_pool->rx_skb[skb_index] = NULL;
 
+	datalen = xgene_enet_get_data_len(le64_to_cpu(raw_desc->m1));
+	skb_put(skb, datalen);
+	prefetch(skb->data - NET_IP_ALIGN);
+	skb->protocol = eth_type_trans(skb, ndev);
+
 	/* checking for error */
 	status = (GET_VAL(ELERR, le64_to_cpu(raw_desc->m0)) << LERR_LEN) |
 		  GET_VAL(LERR, le64_to_cpu(raw_desc->m0));
 	if (unlikely(status)) {
-		dev_kfree_skb_any(skb);
-		xgene_enet_free_pagepool(page_pool, raw_desc, exp_desc);
-		xgene_enet_parse_error(rx_ring, netdev_priv(rx_ring->ndev),
-				       status);
-		ret = -EIO;
-		goto out;
+		if (!xgene_enet_errata_10GE_8(skb, datalen, status)) {
+			dev_kfree_skb_any(skb);
+			xgene_enet_free_pagepool(page_pool, raw_desc, exp_desc);
+			xgene_enet_parse_error(rx_ring, pdata, status);
+			goto out;
+		}
 	}
 
-	/* strip off CRC as HW isn't doing this */
-	datalen = xgene_enet_get_data_len(le64_to_cpu(raw_desc->m1));
-
 	nv = GET_VAL(NV, le64_to_cpu(raw_desc->m0));
-	if (!nv)
+	if (!nv) {
+		/* strip off CRC as HW isn't doing this */
 		datalen -= 4;
-
-	skb_put(skb, datalen);
-	prefetch(skb->data - NET_IP_ALIGN);
-
-	if (!nv)
 		goto skip_jumbo;
+	}
 
 	slots = page_pool->slots - 1;
 	head = page_pool->head;
@@ -738,7 +750,6 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 
 skip_jumbo:
 	skb_checksum_none_assert(skb);
-	skb->protocol = eth_type_trans(skb, ndev);
 	xgene_enet_rx_csum(skb);
 
 	rx_ring->rx_packets++;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 5257174..0d4be24 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -41,6 +41,7 @@
 #include "../../../phy/mdio-xgene.h"
 
 #define XGENE_DRV_VERSION	"v1.0"
+#define ETHER_MIN_PACKET	64
 #define XGENE_ENET_STD_MTU	1536
 #define XGENE_ENET_MAX_MTU	9600
 #define SKB_BUFFER_SIZE		(XGENE_ENET_STD_MTU - NET_IP_ALIGN)
-- 
1.9.1
