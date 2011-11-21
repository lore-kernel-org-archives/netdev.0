From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 3/3] be2net: workaround to fix a BE bug
Date: Sun, 20 Nov 2011 23:22:08 -0600
Message-ID: <20111121052208.GA17689@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:18502 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751640Ab1KUFW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:22:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For vlan tagged pkts, BE
1) calculates checksum even when CSO is not requested
2) calculates checksum wrongly for padded pkt less than 60 bytes long.
As a workaround disable TX vlan offloading in such cases.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |   16 +++++++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |   32 +++++++++++++++++++-------
 2 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 34f162d..c4fcea69 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -518,6 +518,22 @@ static inline void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
 	memcpy(mac, adapter->netdev->dev_addr, 3);
 }
 
+static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
+					struct sk_buff *skb)
+{
+	u8 vlan_prio;
+	u16 vlan_tag;
+
+	vlan_tag = vlan_tx_tag_get(skb);
+	vlan_prio = (vlan_tag & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+	/* If vlan priority provided by OS is NOT in available bmap */
+	if (!(adapter->vlan_prio_bmap & (1 << vlan_prio)))
+		vlan_tag = (vlan_tag & ~VLAN_PRIO_MASK) |
+				adapter->recommended_prio;
+
+	return vlan_tag;
+}
+
 static inline bool be_multi_rxq(const struct be_adapter *adapter)
 {
 	return adapter->num_rx_qs > 1;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 95d41ba..db27269 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -554,8 +554,7 @@ static inline void wrb_fill(struct be_eth_wrb *wrb, u64 addr, int len)
 static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		struct sk_buff *skb, u32 wrb_cnt, u32 len)
 {
-	u8 vlan_prio = 0;
-	u16 vlan_tag = 0;
+	u16 vlan_tag;
 
 	memset(hdr, 0, sizeof(*hdr));
 
@@ -584,14 +583,9 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, udpcs, hdr, 1);
 	}
 
-	if (vlan_tx_tag_present(skb)) {
+	if (adapter->vlans_added && vlan_tx_tag_present(skb)) {
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan, hdr, 1);
-		vlan_tag = vlan_tx_tag_get(skb);
-		vlan_prio = (vlan_tag & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
-		/* If vlan priority provided by OS is NOT in available bmap */
-		if (!(adapter->vlan_prio_bmap & (1 << vlan_prio)))
-			vlan_tag = (vlan_tag & ~VLAN_PRIO_MASK) |
-					adapter->recommended_prio;
+		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, vlan_tag, hdr, vlan_tag);
 	}
 
@@ -694,6 +688,25 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	u32 start = txq->head;
 	bool dummy_wrb, stopped = false;
 
+	/* For vlan tagged pkts, BE
+	 * 1) calculates checksum even when CSO is not requested
+	 * 2) calculates checksum wrongly for padded pkt less than
+	 * 60 bytes long.
+	 * As a workaround disable TX vlan offloading in such cases.
+	 */
+	if (unlikely(vlan_tx_tag_present(skb) &&
+		(skb->ip_summed != CHECKSUM_PARTIAL || skb->len <= 60))) {
+		skb = skb_share_check(skb, GFP_ATOMIC);
+		if (unlikely(!skb))
+			goto tx_drop;
+
+		skb = __vlan_put_tag(skb, be_get_tx_vlan_tag(adapter, skb));
+		if (unlikely(!skb))
+			goto tx_drop;
+
+		skb->vlan_tci = 0;
+	}
+
 	wrb_cnt = wrb_cnt_for_skb(adapter, skb, &dummy_wrb);
 
 	copied = make_tx_wrbs(adapter, txq, skb, wrb_cnt, dummy_wrb);
@@ -719,6 +732,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 				skb_shinfo(skb)->gso_segs, stopped);
 	} else {
 		txq->head = start;
+tx_drop:
 		dev_kfree_skb_any(skb);
 	}
 	return NETDEV_TX_OK;
-- 
1.7.5.4
