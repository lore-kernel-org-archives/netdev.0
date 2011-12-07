From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [net-next PATCH 2/2] be2net: workaround to fix a BE bug
Date: Wed, 7 Dec 2011 17:44:24 -0600
Message-ID: <20111207234424.GA2385@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:28577 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755426Ab1LGXtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 18:49:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For vlan tagged pkts, BE
1) calculates checksum even when CSO is not requested
2) calculates checksum wrongly for padded pkt less than 60 bytes long.
As a workaround disable TX vlan offloading in such cases.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |   16 ++++++++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |   30 +++++++++++++++++++-------
 2 files changed, 38 insertions(+), 8 deletions(-)

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
index b29c447..c5c826f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -555,8 +555,7 @@ static inline void wrb_fill(struct be_eth_wrb *wrb, u64 addr, int len)
 static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		struct sk_buff *skb, u32 wrb_cnt, u32 len)
 {
-	u8 vlan_prio = 0;
-	u16 vlan_tag = 0;
+	u16 vlan_tag;
 
 	memset(hdr, 0, sizeof(*hdr));
 
@@ -587,12 +586,7 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 
 	if (vlan_tx_tag_present(skb)) {
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
 
@@ -695,6 +689,25 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
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
@@ -722,6 +735,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 		txq->head = start;
 		dev_kfree_skb_any(skb);
 	}
+tx_drop:
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.5.4
