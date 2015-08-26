From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 2/2] drivers: net: xgene: Adding support for TSO
Date: Wed, 26 Aug 2015 11:48:06 -0700
Message-ID: <1440614886-23566-3-git-send-email-isubramanian@apm.com>
References: <1440614886-23566-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35367 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbbHZSsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:48:01 -0400
Received: by pacdd16 with SMTP id dd16so168888423pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 11:48:01 -0700 (PDT)
In-Reply-To: <1440614886-23566-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  16 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 249 ++++++++++++++++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  11 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |   8 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |   2 +
 5 files changed, 262 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 541bed0..ff05bbc 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -193,12 +193,16 @@ enum xgene_enet_rm {
 #define USERINFO_LEN			32
 #define FPQNUM_POS			32
 #define FPQNUM_LEN			12
+#define NV_POS				50
+#define NV_LEN				1
+#define LL_POS				51
+#define LL_LEN				1
 #define LERR_POS			60
 #define LERR_LEN			3
 #define STASH_POS			52
 #define STASH_LEN			2
 #define BUFDATALEN_POS			48
-#define BUFDATALEN_LEN			12
+#define BUFDATALEN_LEN			15
 #define DATAADDR_POS			0
 #define DATAADDR_LEN			42
 #define COHERENT_POS			63
@@ -215,9 +219,19 @@ enum xgene_enet_rm {
 #define IPHDR_LEN			6
 #define EC_POS				22	/* Enable checksum */
 #define EC_LEN				1
+#define ET_POS				23	/* Enable TSO */
 #define IS_POS				24	/* IP protocol select */
 #define IS_LEN				1
 #define TYPE_ETH_WORK_MESSAGE_POS	44
+#define LL_BYTES_MSB_POS		56
+#define LL_BYTES_MSB_LEN		8
+#define LL_BYTES_LSB_POS		48
+#define LL_BYTES_LSB_LEN		12
+#define LL_LEN_POS			48
+#define LL_LEN_LEN			8
+#define DATALEN_MASK			GENMASK(11, 0)
+
+#define LAST_BUFFER			(0x7800ULL << BUFDATALEN_POS)
 
 struct xgene_enet_raw_desc {
 	__le64 m0;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 652b4c3..b330cb6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -147,18 +147,27 @@ static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
 {
 	struct sk_buff *skb;
 	struct device *dev;
+	skb_frag_t *frag;
+	dma_addr_t *frag_dma_addr;
 	u16 skb_index;
 	u8 status;
-	int ret = 0;
+	int i, ret = 0;
 
 	skb_index = GET_VAL(USERINFO, le64_to_cpu(raw_desc->m0));
 	skb = cp_ring->cp_skb[skb_index];
+	frag_dma_addr = &cp_ring->frag_dma_addr[skb_index * MAX_SKB_FRAGS];
 
 	dev = ndev_to_dev(cp_ring->ndev);
 	dma_unmap_single(dev, GET_VAL(DATAADDR, le64_to_cpu(raw_desc->m1)),
-			 GET_VAL(BUFDATALEN, le64_to_cpu(raw_desc->m1)),
+			 skb_headlen(skb),
 			 DMA_TO_DEVICE);
 
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		dma_unmap_page(dev, frag_dma_addr[i], skb_frag_size(frag),
+			       DMA_TO_DEVICE);
+	}
+
 	/* Checking for error */
 	status = GET_VAL(LERR, le64_to_cpu(raw_desc->m0));
 	if (unlikely(status > 2)) {
@@ -179,12 +188,16 @@ static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
 
 static u64 xgene_enet_work_msg(struct sk_buff *skb)
 {
+	struct net_device *ndev = skb->dev;
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct iphdr *iph;
-	u8 l3hlen, l4hlen = 0;
-	u8 csum_enable = 0;
-	u8 proto = 0;
-	u8 ethhdr;
-	u64 hopinfo;
+	u8 l3hlen = 0, l4hlen = 0;
+	u8 ethhdr, proto = 0, csum_enable = 0;
+	u64 hopinfo = 0;
+	u32 hdr_len, mss = 0;
+	u32 i, len, nr_frags;
+
+	ethhdr = xgene_enet_hdr_len(skb->data);
 
 	if (unlikely(skb->protocol != htons(ETH_P_IP)) &&
 	    unlikely(skb->protocol != htons(ETH_P_8021Q)))
@@ -201,14 +214,40 @@ static u64 xgene_enet_work_msg(struct sk_buff *skb)
 		l4hlen = tcp_hdrlen(skb) >> 2;
 		csum_enable = 1;
 		proto = TSO_IPPROTO_TCP;
+		if (ndev->features & NETIF_F_TSO) {
+			hdr_len = ethhdr + ip_hdrlen(skb) + tcp_hdrlen(skb);
+			mss = skb_shinfo(skb)->gso_size;
+
+			if (skb_is_nonlinear(skb)) {
+				len = skb_headlen(skb);
+				nr_frags = skb_shinfo(skb)->nr_frags;
+
+				for (i = 0; i < 2 && i < nr_frags; i++)
+					len += skb_shinfo(skb)->frags[i].size;
+
+				/* HW requires header must reside in 3 buffer */
+				if (unlikely(hdr_len > len)) {
+					if (skb_linearize(skb))
+						return 0;
+				}
+			}
+
+			if (!mss || ((skb->len - hdr_len) <= mss))
+				goto out;
+
+			if (mss != pdata->mss) {
+				pdata->mss = mss;
+				pdata->mac_ops->set_mss(pdata);
+			}
+			hopinfo |= SET_BIT(ET);
+		}
 	} else if (iph->protocol == IPPROTO_UDP) {
 		l4hlen = UDP_HDR_SIZE;
 		csum_enable = 1;
 	}
 out:
 	l3hlen = ip_hdrlen(skb) >> 2;
-	ethhdr = xgene_enet_hdr_len(skb->data);
-	hopinfo = SET_VAL(TCPHDR, l4hlen) |
+	hopinfo |= SET_VAL(TCPHDR, l4hlen) |
 		  SET_VAL(IPHDR, l3hlen) |
 		  SET_VAL(ETHHDR, ethhdr) |
 		  SET_VAL(EC, csum_enable) |
@@ -224,20 +263,54 @@ static u16 xgene_enet_encode_len(u16 len)
 	return (len == BUFLEN_16K) ? 0 : len;
 }
 
+static void xgene_set_addr_len(__le64 *desc, u32 idx, dma_addr_t addr, u32 len)
+{
+	desc[idx ^ 1] = cpu_to_le64(SET_VAL(DATAADDR, addr) |
+				    SET_VAL(BUFDATALEN, len));
+}
+
+static __le64 *xgene_enet_get_exp_bufs(struct xgene_enet_desc_ring *ring)
+{
+	__le64 *exp_bufs;
+
+	exp_bufs = &ring->exp_bufs[ring->exp_buf_tail * MAX_EXP_BUFFS];
+	memset(exp_bufs, 0, sizeof(__le64) * MAX_EXP_BUFFS);
+	ring->exp_buf_tail = (ring->exp_buf_tail + 1) & ((ring->slots / 2) - 1);
+
+	return exp_bufs;
+}
+
+static dma_addr_t *xgene_get_frag_dma_array(struct xgene_enet_desc_ring *ring)
+{
+	return &ring->cp_ring->frag_dma_addr[ring->tail * MAX_SKB_FRAGS];
+}
+
 static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 				    struct sk_buff *skb)
 {
 	struct device *dev = ndev_to_dev(tx_ring->ndev);
 	struct xgene_enet_raw_desc *raw_desc;
-	dma_addr_t dma_addr;
+	__le64 *exp_desc = NULL, *exp_bufs = NULL;
+	dma_addr_t dma_addr, pbuf_addr, *frag_dma_addr;
+	skb_frag_t *frag;
 	u16 tail = tx_ring->tail;
 	u64 hopinfo;
 	u32 len, hw_len;
-	u8 count = 1;
+	u8 ll = 0, nv = 0, idx = 0;
+	bool split = false;
+	u32 size, offset, ell_bytes = 0;
+	u32 i, fidx, nr_frags, count = 1;
 
 	raw_desc = &tx_ring->raw_desc[tail];
+	tail = (tail + 1) & (tx_ring->slots - 1);
 	memset(raw_desc, 0, sizeof(struct xgene_enet_raw_desc));
 
+	hopinfo = xgene_enet_work_msg(skb);
+	if (!hopinfo)
+		return -EINVAL;
+	raw_desc->m3 = cpu_to_le64(SET_VAL(HENQNUM, tx_ring->dst_ring_num) |
+				   hopinfo);
+
 	len = skb_headlen(skb);
 	hw_len = xgene_enet_encode_len(len);
 
@@ -252,13 +325,100 @@ static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 				   SET_VAL(BUFDATALEN, hw_len) |
 				   SET_BIT(COHERENT));
 
-	raw_desc->m0 = cpu_to_le64(SET_VAL(USERINFO, tail));
-	hopinfo = xgene_enet_work_msg(skb);
-	raw_desc->m3 = cpu_to_le64(SET_VAL(HENQNUM, tx_ring->dst_ring_num) |
-				   hopinfo);
-	tx_ring->cp_ring->cp_skb[tail] = skb;
+	if (!skb_is_nonlinear(skb))
+		goto out;
 
+	/* scatter gather */
+	nv = 1;
+	exp_desc = (void *)&tx_ring->raw_desc[tail];
 	tail = (tail + 1) & (tx_ring->slots - 1);
+	memset(exp_desc, 0, sizeof(struct xgene_enet_raw_desc));
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	for (i = nr_frags; i < 4 ; i++)
+		exp_desc[i ^ 1] = cpu_to_le64(LAST_BUFFER);
+
+	frag_dma_addr = xgene_get_frag_dma_array(tx_ring);
+
+	for (i = 0, fidx = 0; split || (fidx < nr_frags); i++) {
+		if (!split) {
+			frag = &skb_shinfo(skb)->frags[fidx];
+			size = skb_frag_size(frag);
+			offset = 0;
+
+			pbuf_addr = skb_frag_dma_map(dev, frag, 0, size,
+						     DMA_TO_DEVICE);
+			if (dma_mapping_error(dev, pbuf_addr))
+				return -EINVAL;
+
+			frag_dma_addr[fidx] = pbuf_addr;
+			fidx++;
+
+			if (size > BUFLEN_16K)
+				split = true;
+		}
+
+		if (size > BUFLEN_16K) {
+			len = BUFLEN_16K;
+			size -= BUFLEN_16K;
+		} else {
+			len = size;
+			split = false;
+		}
+
+		dma_addr = pbuf_addr + offset;
+		hw_len = xgene_enet_encode_len(len);
+
+		switch (i) {
+		case 0:
+		case 1:
+		case 2:
+			xgene_set_addr_len(exp_desc, i, dma_addr, hw_len);
+			break;
+		case 3:
+			if (split || (fidx != nr_frags)) {
+				exp_bufs = xgene_enet_get_exp_bufs(tx_ring);
+				xgene_set_addr_len(exp_bufs, idx, dma_addr,
+						   hw_len);
+				idx++;
+				ell_bytes += len;
+			} else {
+				xgene_set_addr_len(exp_desc, i, dma_addr,
+						   hw_len);
+			}
+			break;
+		default:
+			xgene_set_addr_len(exp_bufs, idx, dma_addr, hw_len);
+			idx++;
+			ell_bytes += len;
+			break;
+		}
+
+		if (split)
+			offset += BUFLEN_16K;
+	}
+	count++;
+
+	if (idx) {
+		ll = 1;
+		dma_addr = dma_map_single(dev, exp_bufs,
+					  sizeof(u64) * MAX_EXP_BUFFS,
+					  DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, dma_addr)) {
+			dev_kfree_skb_any(skb);
+			return -EINVAL;
+		}
+		i = ell_bytes >> LL_BYTES_LSB_LEN;
+		exp_desc[2] = cpu_to_le64(SET_VAL(DATAADDR, dma_addr) |
+					  SET_VAL(LL_BYTES_MSB, i) |
+					  SET_VAL(LL_LEN, idx));
+		raw_desc->m2 = cpu_to_le64(SET_VAL(LL_BYTES_LSB, ell_bytes));
+	}
+
+out:
+	raw_desc->m0 = cpu_to_le64(SET_VAL(LL, ll) | SET_VAL(NV, nv) |
+				   SET_VAL(USERINFO, tx_ring->tail));
+	tx_ring->cp_ring->cp_skb[tx_ring->tail] = skb;
 	tx_ring->tail = tail;
 
 	return count;
@@ -281,6 +441,9 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
+	if (skb_padto(skb, XGENE_MIN_ENET_FRAME_SIZE))
+		return NETDEV_TX_OK;
+
 	count = xgene_enet_setup_tx_desc(tx_ring, skb);
 	if (count <= 0) {
 		dev_kfree_skb_any(skb);
@@ -341,7 +504,7 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 
 	/* strip off CRC as HW isn't doing this */
 	datalen = GET_VAL(BUFDATALEN, le64_to_cpu(raw_desc->m1));
-	datalen -= 4;
+	datalen = (datalen & DATALEN_MASK) - 4;
 	prefetch(skb->data - NET_IP_ALIGN);
 	skb_put(skb, datalen);
 
@@ -373,26 +536,41 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 				   int budget)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
-	struct xgene_enet_raw_desc *raw_desc;
+	struct xgene_enet_raw_desc *raw_desc, *exp_desc;
 	u16 head = ring->head;
 	u16 slots = ring->slots - 1;
-	int ret, count = 0;
+	int ret, count = 0, processed = 0;
 
 	do {
 		raw_desc = &ring->raw_desc[head];
+		exp_desc = NULL;
 		if (unlikely(xgene_enet_is_desc_slot_empty(raw_desc)))
 			break;
 
 		/* read fpqnum field after dataaddr field */
 		dma_rmb();
+		if (GET_BIT(NV, le64_to_cpu(raw_desc->m0))) {
+			head = (head + 1) & slots;
+			exp_desc = &ring->raw_desc[head];
+
+			if (unlikely(xgene_enet_is_desc_slot_empty(exp_desc))) {
+				head = (head - 1) & slots;
+				break;
+			}
+			dma_rmb();
+			count++;
+		}
 		if (is_rx_desc(raw_desc))
 			ret = xgene_enet_rx_frame(ring, raw_desc);
 		else
 			ret = xgene_enet_tx_completion(ring, raw_desc);
 		xgene_enet_mark_desc_slot_empty(raw_desc);
+		if (exp_desc)
+			xgene_enet_mark_desc_slot_empty(exp_desc);
 
 		head = (head + 1) & slots;
 		count++;
+		processed++;
 
 		if (ret)
 			break;
@@ -408,7 +586,7 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 		}
 	}
 
-	return count;
+	return processed;
 }
 
 static int xgene_enet_napi(struct napi_struct *napi, const int budget)
@@ -753,12 +931,13 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	struct xgene_enet_desc_ring *rx_ring, *tx_ring, *cp_ring;
 	struct xgene_enet_desc_ring *buf_pool = NULL;
 	enum xgene_ring_owner owner;
+	dma_addr_t dma_exp_bufs;
 	u8 cpu_bufnum = pdata->cpu_bufnum;
 	u8 eth_bufnum = pdata->eth_bufnum;
 	u8 bp_bufnum = pdata->bp_bufnum;
 	u16 ring_num = pdata->ring_num;
 	u16 ring_id;
-	int ret;
+	int ret, size;
 
 	/* allocate rx descriptor ring */
 	owner = xgene_derive_ring_owner(pdata);
@@ -809,6 +988,15 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 		ret = -ENOMEM;
 		goto err;
 	}
+
+	size = (tx_ring->slots / 2) * sizeof(__le64) * MAX_EXP_BUFFS;
+	tx_ring->exp_bufs = dma_zalloc_coherent(dev, size, &dma_exp_bufs,
+						GFP_KERNEL);
+	if (!tx_ring->exp_bufs) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
 	pdata->tx_ring = tx_ring;
 
 	if (!pdata->cq_cnt) {
@@ -833,6 +1021,16 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 		ret = -ENOMEM;
 		goto err;
 	}
+
+	size = sizeof(dma_addr_t) * MAX_SKB_FRAGS;
+	cp_ring->frag_dma_addr = devm_kcalloc(dev, tx_ring->slots,
+					      size, GFP_KERNEL);
+	if (!cp_ring->frag_dma_addr) {
+		devm_kfree(dev, cp_ring->cp_skb);
+		ret = -ENOMEM;
+		goto err;
+	}
+
 	pdata->tx_ring->cp_ring = cp_ring;
 	pdata->tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
 
@@ -1188,7 +1386,8 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	xgene_enet_set_ethtool_ops(ndev);
 	ndev->features |= NETIF_F_IP_CSUM |
 			  NETIF_F_GSO |
-			  NETIF_F_GRO;
+			  NETIF_F_GRO |
+			  NETIF_F_SG;
 
 	of_id = of_match_device(xgene_enet_of_match, &pdev->dev);
 	if (of_id) {
@@ -1214,6 +1413,12 @@ static int xgene_enet_probe(struct platform_device *pdev)
 
 	xgene_enet_setup_ops(pdata);
 
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+		ndev->features |= NETIF_F_TSO;
+		pdata->mss = XGENE_ENET_MSS;
+	}
+	ndev->hw_features = ndev->features;
+
 	ret = register_netdev(ndev);
 	if (ret) {
 		netdev_err(ndev, "Failed to register netdev\n");
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 2ac547e..50f92c3 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -43,6 +43,9 @@
 #define BUFLEN_16K	(16 * 1024)
 #define NUM_PKT_BUF	64
 #define NUM_BUFPOOL	32
+#define MAX_EXP_BUFFS	256
+#define XGENE_ENET_MSS	1448
+#define XGENE_MIN_ENET_FRAME_SIZE	60
 
 #define START_CPU_BUFNUM_0	0
 #define START_ETH_BUFNUM_0	2
@@ -80,6 +83,7 @@ struct xgene_enet_desc_ring {
 	u16 num;
 	u16 head;
 	u16 tail;
+	u16 exp_buf_tail;
 	u16 slots;
 	u16 irq;
 	char irq_name[IRQ_ID_SIZE];
@@ -94,6 +98,7 @@ struct xgene_enet_desc_ring {
 	u8 nbufpool;
 	struct sk_buff *(*rx_skb);
 	struct sk_buff *(*cp_skb);
+	dma_addr_t *frag_dma_addr;
 	enum xgene_enet_ring_cfgsize cfgsize;
 	struct xgene_enet_desc_ring *cp_ring;
 	struct xgene_enet_desc_ring *buf_pool;
@@ -103,6 +108,7 @@ struct xgene_enet_desc_ring {
 		struct xgene_enet_raw_desc *raw_desc;
 		struct xgene_enet_raw_desc16 *raw_desc16;
 	};
+	__le64 *exp_bufs;
 };
 
 struct xgene_mac_ops {
@@ -113,6 +119,7 @@ struct xgene_mac_ops {
 	void (*tx_disable)(struct xgene_enet_pdata *pdata);
 	void (*rx_disable)(struct xgene_enet_pdata *pdata);
 	void (*set_mac_addr)(struct xgene_enet_pdata *pdata);
+	void (*set_mss)(struct xgene_enet_pdata *pdata);
 	void (*link_state)(struct work_struct *work);
 };
 
@@ -171,6 +178,7 @@ struct xgene_enet_pdata {
 	u8 eth_bufnum;
 	u8 bp_bufnum;
 	u16 ring_num;
+	u32 mss;
 };
 
 struct xgene_indirect_ctl {
@@ -205,6 +213,9 @@ static inline u64 xgene_enet_get_field_value(int pos, int len, u64 src)
 #define GET_VAL(field, src) \
 		xgene_enet_get_field_value(field ## _POS, field ## _LEN, src)
 
+#define GET_BIT(field, src) \
+		xgene_enet_get_field_value(field ## _POS, 1, src)
+
 static inline struct device *ndev_to_dev(struct net_device *ndev)
 {
 	return ndev->dev.parent;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 05edb84..7a28a48 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -184,6 +184,11 @@ static void xgene_xgmac_set_mac_addr(struct xgene_enet_pdata *pdata)
 	xgene_enet_wr_mac(pdata, HSTMACADR_MSW_ADDR, addr1);
 }
 
+static void xgene_xgmac_set_mss(struct xgene_enet_pdata *pdata)
+{
+	xgene_enet_wr_csr(pdata, XG_TSIF_MSS_REG0_ADDR, pdata->mss);
+}
+
 static u32 xgene_enet_link_status(struct xgene_enet_pdata *pdata)
 {
 	u32 data;
@@ -204,8 +209,8 @@ static void xgene_xgmac_init(struct xgene_enet_pdata *pdata)
 	data &= ~HSTLENCHK;
 	xgene_enet_wr_mac(pdata, AXGMAC_CONFIG_1, data);
 
-	xgene_enet_wr_mac(pdata, HSTMAXFRAME_LENGTH_ADDR, 0x06000600);
 	xgene_xgmac_set_mac_addr(pdata);
+	xgene_xgmac_set_mss(pdata);
 
 	xgene_enet_rd_csr(pdata, XG_RSIF_CONFIG_REG_ADDR, &data);
 	data |= CFG_RSIF_FPBUFF_TIMEOUT_EN;
@@ -329,6 +334,7 @@ struct xgene_mac_ops xgene_xgmac_ops = {
 	.rx_disable = xgene_xgmac_rx_disable,
 	.tx_disable = xgene_xgmac_tx_disable,
 	.set_mac_addr = xgene_xgmac_set_mac_addr,
+	.set_mss = xgene_xgmac_set_mss,
 	.link_state = xgene_enet_link_state
 };
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
index bf0a994..f8f908d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h
@@ -62,7 +62,9 @@
 #define XCLE_BYPASS_REG0_ADDR           0x0160
 #define XCLE_BYPASS_REG1_ADDR           0x0164
 #define XG_CFG_BYPASS_ADDR		0x0204
+#define XG_CFG_LINK_AGGR_RESUME_0_ADDR	0x0214
 #define XG_LINK_STATUS_ADDR		0x0228
+#define XG_TSIF_MSS_REG0_ADDR		0x02a4
 #define XG_ENET_SPARE_CFG_REG_ADDR	0x040c
 #define XG_ENET_SPARE_CFG_REG_1_ADDR	0x0410
 #define XGENET_RX_DV_GATE_REG_0_ADDR	0x0804
-- 
1.9.1
