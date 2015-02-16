From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH v2 net-next 1/4] be2net: Refactor wrb_fill_hdr() routine
Date: Mon, 16 Feb 2015 08:03:45 +0530
Message-ID: <1424054028-23659-2-git-send-email-sriharsha.basavapatna@emulex.com>
References: <1424054028-23659-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:25688 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbBPClz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 21:41:55 -0500
In-Reply-To: <1424054028-23659-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The WRB header is setup by wrb_fill_hdr() routine. This routine currently
gets some of the WRB params as args and figures out rest of the WRB params
by looking at various fields in skb (like gso, checksum, vlan-tag etc).
All these params could instead be retrieved from the skb into a structure
and passed to this routine. This separates wrb_fill_hdr() to only provide
chip-specific code to fill the WRB. This also makes it simple to support
chips with different WRB formats.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  33 +++++++++
 drivers/net/ethernet/emulex/benet/be_main.c | 105 +++++++++++++++++-----------
 2 files changed, 99 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 27de37a..bc7f3d6 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -417,6 +417,39 @@ struct rss_info {
 	u8 rss_hkey[RSS_HASH_KEY_LEN];
 };
 
+/* Macros to read/write the 'features' word of be_wrb_params structure.
+ */
+#define	BE_WRB_F_BIT(name)			BE_WRB_F_##name##_BIT
+#define	BE_WRB_F_MASK(name)			BIT_MASK(BE_WRB_F_##name##_BIT)
+
+#define	BE_WRB_F_GET(word, name)	\
+	(((word) & (BE_WRB_F_MASK(name))) >> BE_WRB_F_BIT(name))
+
+#define	BE_WRB_F_SET(word, name, val)	\
+	((word) |= (((val) << BE_WRB_F_BIT(name)) & BE_WRB_F_MASK(name)))
+
+/* Feature/offload bits */
+enum {
+	BE_WRB_F_CRC_BIT,		/* Ethernet CRC */
+	BE_WRB_F_IPCS_BIT,		/* IP csum */
+	BE_WRB_F_TCPCS_BIT,		/* TCP csum */
+	BE_WRB_F_UDPCS_BIT,		/* UDP csum */
+	BE_WRB_F_LSO_BIT,		/* LSO */
+	BE_WRB_F_LSO6_BIT,		/* LSO6 */
+	BE_WRB_F_VLAN_BIT,		/* VLAN */
+	BE_WRB_F_VLAN_SKIP_HW_BIT	/* Skip VLAN tag (workaround) */
+};
+
+/* The structure below provides a HW-agnostic abstraction of WRB params
+ * retrieved from a TX skb. This is in turn passed to chip specific routines
+ * during transmit, to set the corresponding params in the WRB.
+ */
+struct be_wrb_params {
+	u32 features;	/* Feature bits */
+	u16 vlan_tag;	/* VLAN tag */
+	u16 lso_mss;	/* MSS for LSO */
+};
+
 struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 932b93a..40f54c0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -728,48 +728,71 @@ static u16 skb_ip_proto(struct sk_buff *skb)
 		ip_hdr(skb)->protocol : ipv6_hdr(skb)->nexthdr;
 }
 
-static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
-			 struct sk_buff *skb, u32 wrb_cnt, u32 len,
-			 bool skip_hw_vlan)
+static void be_get_wrb_params_from_skb(struct be_adapter *adapter,
+				       struct sk_buff *skb,
+				       struct be_wrb_params *wrb_params)
 {
-	u16 vlan_tag, proto;
-
-	memset(hdr, 0, sizeof(*hdr));
-
-	SET_TX_WRB_HDR_BITS(crc, hdr, 1);
+	u16 proto;
 
 	if (skb_is_gso(skb)) {
-		SET_TX_WRB_HDR_BITS(lso, hdr, 1);
-		SET_TX_WRB_HDR_BITS(lso_mss, hdr, skb_shinfo(skb)->gso_size);
+		BE_WRB_F_SET(wrb_params->features, LSO, 1);
+		wrb_params->lso_mss = skb_shinfo(skb)->gso_size;
 		if (skb_is_gso_v6(skb) && !lancer_chip(adapter))
-			SET_TX_WRB_HDR_BITS(lso6, hdr, 1);
+			BE_WRB_F_SET(wrb_params->features, LSO6, 1);
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (skb->encapsulation) {
-			SET_TX_WRB_HDR_BITS(ipcs, hdr, 1);
+			BE_WRB_F_SET(wrb_params->features, IPCS, 1);
 			proto = skb_inner_ip_proto(skb);
 		} else {
 			proto = skb_ip_proto(skb);
 		}
 		if (proto == IPPROTO_TCP)
-			SET_TX_WRB_HDR_BITS(tcpcs, hdr, 1);
+			BE_WRB_F_SET(wrb_params->features, TCPCS, 1);
 		else if (proto == IPPROTO_UDP)
-			SET_TX_WRB_HDR_BITS(udpcs, hdr, 1);
+			BE_WRB_F_SET(wrb_params->features, UDPCS, 1);
 	}
 
 	if (skb_vlan_tag_present(skb)) {
-		SET_TX_WRB_HDR_BITS(vlan, hdr, 1);
-		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
-		SET_TX_WRB_HDR_BITS(vlan_tag, hdr, vlan_tag);
+		BE_WRB_F_SET(wrb_params->features, VLAN, 1);
+		wrb_params->vlan_tag = be_get_tx_vlan_tag(adapter, skb);
 	}
 
-	SET_TX_WRB_HDR_BITS(num_wrb, hdr, wrb_cnt);
-	SET_TX_WRB_HDR_BITS(len, hdr, len);
+	BE_WRB_F_SET(wrb_params->features, CRC, 1);
+}
+
+static void wrb_fill_hdr(struct be_adapter *adapter,
+			 struct be_eth_hdr_wrb *hdr,
+			 struct be_wrb_params *wrb_params,
+			 struct sk_buff *skb)
+{
+	memset(hdr, 0, sizeof(*hdr));
 
-	/* Hack to skip HW VLAN tagging needs evt = 1, compl = 0
-	 * When this hack is not needed, the evt bit is set while ringing DB
+	SET_TX_WRB_HDR_BITS(crc, hdr,
+			    BE_WRB_F_GET(wrb_params->features, CRC));
+	SET_TX_WRB_HDR_BITS(ipcs, hdr,
+			    BE_WRB_F_GET(wrb_params->features, IPCS));
+	SET_TX_WRB_HDR_BITS(tcpcs, hdr,
+			    BE_WRB_F_GET(wrb_params->features, TCPCS));
+	SET_TX_WRB_HDR_BITS(udpcs, hdr,
+			    BE_WRB_F_GET(wrb_params->features, UDPCS));
+
+	SET_TX_WRB_HDR_BITS(lso, hdr,
+			    BE_WRB_F_GET(wrb_params->features, LSO));
+	SET_TX_WRB_HDR_BITS(lso6, hdr,
+			    BE_WRB_F_GET(wrb_params->features, LSO6));
+	SET_TX_WRB_HDR_BITS(lso_mss, hdr, wrb_params->lso_mss);
+
+	/* Hack to skip HW VLAN tagging needs evt = 1, compl = 0. When this
+	 * hack is not needed, the evt bit is set while ringing DB.
 	 */
-	if (skip_hw_vlan)
-		SET_TX_WRB_HDR_BITS(event, hdr, 1);
+	SET_TX_WRB_HDR_BITS(event, hdr,
+			    BE_WRB_F_GET(wrb_params->features, VLAN_SKIP_HW));
+	SET_TX_WRB_HDR_BITS(vlan, hdr,
+			    BE_WRB_F_GET(wrb_params->features, VLAN));
+	SET_TX_WRB_HDR_BITS(vlan_tag, hdr, wrb_params->vlan_tag);
+
+	SET_TX_WRB_HDR_BITS(num_wrb, hdr, skb_wrb_cnt(skb));
+	SET_TX_WRB_HDR_BITS(len, hdr, skb->len);
 }
 
 static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
@@ -791,7 +814,8 @@ static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
 
 /* Returns the number of WRBs used up by the skb */
 static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
-			   struct sk_buff *skb, bool skip_hw_vlan)
+			   struct sk_buff *skb,
+			   struct be_wrb_params *wrb_params)
 {
 	u32 i, copied = 0, wrb_cnt = skb_wrb_cnt(skb);
 	struct device *dev = &adapter->pdev->dev;
@@ -803,7 +827,7 @@ static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
 	u16 head = txq->head;
 
 	hdr = queue_head_node(txq);
-	wrb_fill_hdr(adapter, hdr, skb, wrb_cnt, skb->len, skip_hw_vlan);
+	wrb_fill_hdr(adapter, hdr, wrb_params, skb);
 	be_dws_cpu_to_le(hdr, sizeof(*hdr));
 
 	queue_head_inc(txq);
@@ -870,7 +894,8 @@ static inline int qnq_async_evt_rcvd(struct be_adapter *adapter)
 
 static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 					     struct sk_buff *skb,
-					     bool *skip_hw_vlan)
+					     struct be_wrb_params
+					     *wrb_params)
 {
 	u16 vlan_tag = 0;
 
@@ -887,8 +912,7 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 		/* f/w workaround to set skip_hw_vlan = 1, informs the F/W to
 		 * skip VLAN insertion
 		 */
-		if (skip_hw_vlan)
-			*skip_hw_vlan = true;
+		BE_WRB_F_SET(wrb_params->features, VLAN_SKIP_HW, 1);
 	}
 
 	if (vlan_tag) {
@@ -906,8 +930,7 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 						vlan_tag);
 		if (unlikely(!skb))
 			return skb;
-		if (skip_hw_vlan)
-			*skip_hw_vlan = true;
+		BE_WRB_F_SET(wrb_params->features, VLAN_SKIP_HW, 1);
 	}
 
 	return skb;
@@ -947,7 +970,8 @@ static int be_ipv6_tx_stall_chk(struct be_adapter *adapter, struct sk_buff *skb)
 
 static struct sk_buff *be_lancer_xmit_workarounds(struct be_adapter *adapter,
 						  struct sk_buff *skb,
-						  bool *skip_hw_vlan)
+						  struct be_wrb_params
+						  *wrb_params)
 {
 	struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 	unsigned int eth_hdr_len;
@@ -971,7 +995,7 @@ static struct sk_buff *be_lancer_xmit_workarounds(struct be_adapter *adapter,
 	 */
 	if (be_pvid_tagging_enabled(adapter) &&
 	    veh->h_vlan_proto == htons(ETH_P_8021Q))
-		*skip_hw_vlan = true;
+		BE_WRB_F_SET(wrb_params->features, VLAN_SKIP_HW, 1);
 
 	/* HW has a bug wherein it will calculate CSUM for VLAN
 	 * pkts even though it is disabled.
@@ -979,7 +1003,7 @@ static struct sk_buff *be_lancer_xmit_workarounds(struct be_adapter *adapter,
 	 */
 	if (skb->ip_summed != CHECKSUM_PARTIAL &&
 	    skb_vlan_tag_present(skb)) {
-		skb = be_insert_vlan_in_pkt(adapter, skb, skip_hw_vlan);
+		skb = be_insert_vlan_in_pkt(adapter, skb, wrb_params);
 		if (unlikely(!skb))
 			goto err;
 	}
@@ -1001,7 +1025,7 @@ static struct sk_buff *be_lancer_xmit_workarounds(struct be_adapter *adapter,
 	 */
 	if (be_ipv6_tx_stall_chk(adapter, skb) &&
 	    be_vlan_tag_tx_chk(adapter, skb)) {
-		skb = be_insert_vlan_in_pkt(adapter, skb, skip_hw_vlan);
+		skb = be_insert_vlan_in_pkt(adapter, skb, wrb_params);
 		if (unlikely(!skb))
 			goto err;
 	}
@@ -1015,7 +1039,7 @@ err:
 
 static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 					   struct sk_buff *skb,
-					   bool *skip_hw_vlan)
+					   struct be_wrb_params *wrb_params)
 {
 	/* Lancer, SH-R ASICs have a bug wherein Packets that are 32 bytes or
 	 * less may cause a transmit stall on that port. So the work-around is
@@ -1027,7 +1051,7 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	}
 
 	if (BEx_chip(adapter) || lancer_chip(adapter)) {
-		skb = be_lancer_xmit_workarounds(adapter, skb, skip_hw_vlan);
+		skb = be_lancer_xmit_workarounds(adapter, skb, wrb_params);
 		if (!skb)
 			return NULL;
 	}
@@ -1061,18 +1085,21 @@ static void be_xmit_flush(struct be_adapter *adapter, struct be_tx_obj *txo)
 
 static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
-	bool skip_hw_vlan = false, flush = !skb->xmit_more;
 	struct be_adapter *adapter = netdev_priv(netdev);
 	u16 q_idx = skb_get_queue_mapping(skb);
 	struct be_tx_obj *txo = &adapter->tx_obj[q_idx];
+	struct be_wrb_params wrb_params = { 0 };
 	struct be_queue_info *txq = &txo->q;
+	bool flush = !skb->xmit_more;
 	u16 wrb_cnt;
 
-	skb = be_xmit_workarounds(adapter, skb, &skip_hw_vlan);
+	skb = be_xmit_workarounds(adapter, skb, &wrb_params);
 	if (unlikely(!skb))
 		goto drop;
 
-	wrb_cnt = be_xmit_enqueue(adapter, txo, skb, skip_hw_vlan);
+	be_get_wrb_params_from_skb(adapter, skb, &wrb_params);
+
+	wrb_cnt = be_xmit_enqueue(adapter, txo, skb, &wrb_params);
 	if (unlikely(!wrb_cnt)) {
 		dev_kfree_skb_any(skb);
 		goto drop;
-- 
2.2.0.65.g9abc44b
