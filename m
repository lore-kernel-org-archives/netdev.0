From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: refactor HW workarounds in be_xmit()
Date: Thu, 23 May 2013 14:34:55 +0530
Message-ID: <1369299895-23388-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:59255 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756577Ab3EWJBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 05:01:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor all TX HW workarounds into a separate routine called
be_xmit_workarounds().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   62 ++++++++++++++++----------
 1 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a444110..7892361 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -842,32 +842,27 @@ static int be_vlan_tag_tx_chk(struct be_adapter *adapter, struct sk_buff *skb)
 	return vlan_tx_tag_present(skb) || adapter->pvid || adapter->qnq_vid;
 }
 
-static int be_ipv6_tx_stall_chk(struct be_adapter *adapter, struct sk_buff *skb)
+static int be_ipv6_tx_stall_chk(struct be_adapter *adapter,
+				struct sk_buff *skb)
 {
-	return BE3_chip(adapter) &&
-		be_ipv6_exthdr_check(skb);
+	return BE3_chip(adapter) && be_ipv6_exthdr_check(skb);
 }
 
-static netdev_tx_t be_xmit(struct sk_buff *skb,
-			struct net_device *netdev)
+static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
+					   struct sk_buff *skb,
+					   bool *skip_hw_vlan)
 {
-	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_tx_obj *txo = &adapter->tx_obj[skb_get_queue_mapping(skb)];
-	struct be_queue_info *txq = &txo->q;
-	struct iphdr *ip = NULL;
-	u32 wrb_cnt = 0, copied = 0;
-	u32 start = txq->head, eth_hdr_len;
-	bool dummy_wrb, stopped = false;
-	bool skip_hw_vlan = false;
 	struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
-
-	eth_hdr_len = ntohs(skb->protocol) == ETH_P_8021Q ?
-		VLAN_ETH_HLEN : ETH_HLEN;
+	unsigned int eth_hdr_len;
+	struct iphdr *ip;
 
 	/* For padded packets, BE HW modifies tot_len field in IP header
 	 * incorrecly when VLAN tag is inserted by HW.
 	 */
-	if (skb->len <= 60 && vlan_tx_tag_present(skb) && is_ipv4_pkt(skb)) {
+	eth_hdr_len = ntohs(skb->protocol) == ETH_P_8021Q ?
+						VLAN_ETH_HLEN : ETH_HLEN;
+	if (skb->len <= 60 && vlan_tx_tag_present(skb) &&
+	    is_ipv4_pkt(skb)) {
 		ip = (struct iphdr *)ip_hdr(skb);
 		pskb_trim(skb, eth_hdr_len + ntohs(ip->tot_len));
 	}
@@ -877,15 +872,15 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	 */
 	if ((adapter->function_mode & UMC_ENABLED) &&
 	    veh->h_vlan_proto == htons(ETH_P_8021Q))
-			skip_hw_vlan = true;
+			*skip_hw_vlan = true;
 
 	/* HW has a bug wherein it will calculate CSUM for VLAN
 	 * pkts even though it is disabled.
 	 * Manually insert VLAN in pkt.
 	 */
 	if (skb->ip_summed != CHECKSUM_PARTIAL &&
-			vlan_tx_tag_present(skb)) {
-		skb = be_insert_vlan_in_pkt(adapter, skb, &skip_hw_vlan);
+	    vlan_tx_tag_present(skb)) {
+		skb = be_insert_vlan_in_pkt(adapter, skb, skip_hw_vlan);
 		if (unlikely(!skb))
 			goto tx_drop;
 	}
@@ -895,8 +890,8 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	 * skip HW tagging is not enabled by FW.
 	 */
 	if (unlikely(be_ipv6_tx_stall_chk(adapter, skb) &&
-		     (adapter->pvid || adapter->qnq_vid) &&
-		     !qnq_async_evt_rcvd(adapter)))
+	    (adapter->pvid || adapter->qnq_vid) &&
+	    !qnq_async_evt_rcvd(adapter)))
 		goto tx_drop;
 
 	/* Manual VLAN tag insertion to prevent:
@@ -907,11 +902,31 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	 */
 	if (be_ipv6_tx_stall_chk(adapter, skb) &&
 	    be_vlan_tag_tx_chk(adapter, skb)) {
-		skb = be_insert_vlan_in_pkt(adapter, skb, &skip_hw_vlan);
+		skb = be_insert_vlan_in_pkt(adapter, skb, skip_hw_vlan);
 		if (unlikely(!skb))
 			goto tx_drop;
 	}
 
+	return skb;
+tx_drop:
+	dev_kfree_skb_any(skb);
+	return NULL;
+}
+
+static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_tx_obj *txo = &adapter->tx_obj[skb_get_queue_mapping(skb)];
+	struct be_queue_info *txq = &txo->q;
+	bool dummy_wrb, stopped = false;
+	u32 wrb_cnt = 0, copied = 0;
+	bool skip_hw_vlan = false;
+	u32 start = txq->head;
+
+	skb = be_xmit_workarounds(adapter, skb, &skip_hw_vlan);
+	if (!skb)
+		return NETDEV_TX_OK;
+
 	wrb_cnt = wrb_cnt_for_skb(adapter, skb, &dummy_wrb);
 
 	copied = make_tx_wrbs(adapter, txq, skb, wrb_cnt, dummy_wrb,
@@ -941,7 +956,6 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 		txq->head = start;
 		dev_kfree_skb_any(skb);
 	}
-tx_drop:
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.1
