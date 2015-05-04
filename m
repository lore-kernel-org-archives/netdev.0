From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 6/6] cxgb4: Discard the packet if the length is greater than mtu
Date: Mon,  4 May 2015 21:58:20 +0530
Message-ID: <1430756900-6086-7-git-send-email-hariprasad@chelsio.com>
References: <1430756900-6086-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24980 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752225AbbEDLQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 07:16:34 -0400
In-Reply-To: <1430756900-6086-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pktgen sends raw udp packets and bypasses most of the
linux networking stack. User can specify different packet sizes.
Hence we need to discard the packet if the length is greater than mtu

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c   | 9 ++++++++-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c | 9 ++++++++-
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index aa05101..9eb17e3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1120,7 +1120,6 @@ cxgb_fcoe_offload(struct sk_buff *skb, struct adapter *adap,
  */
 netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int len;
 	u32 wr_mid;
 	u64 cntrl, *end;
 	int qidx, credits;
@@ -1133,6 +1132,7 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	const struct skb_shared_info *ssi;
 	dma_addr_t addr[MAX_SKB_FRAGS + 1];
 	bool immediate = false;
+	int len, max_pkt_len;
 #ifdef CONFIG_CHELSIO_T4_FCOE
 	int err;
 #endif /* CONFIG_CHELSIO_T4_FCOE */
@@ -1146,6 +1146,13 @@ out_free:	dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
+	/* Discard the packet if the length is greater than mtu */
+	max_pkt_len = ETH_HLEN + dev->mtu;
+	if (skb_vlan_tag_present(skb))
+		max_pkt_len += VLAN_HLEN;
+	if (!skb_shinfo(skb)->gso_size && (unlikely(skb->len > max_pkt_len)))
+		goto out_free;
+
 	pi = netdev_priv(dev);
 	adap = pi->adapter;
 	qidx = skb_get_queue_mapping(skb);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index cc92c69..98cd47c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1160,7 +1160,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	u32 wr_mid;
 	u64 cntrl, *end;
-	int qidx, credits;
+	int qidx, credits, max_pkt_len;
 	unsigned int flits, ndesc;
 	struct adapter *adapter;
 	struct sge_eth_txq *txq;
@@ -1183,6 +1183,13 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb->len < fw_hdr_copy_len))
 		goto out_free;
 
+	/* Discard the packet if the length is greater than mtu */
+	max_pkt_len = ETH_HLEN + dev->mtu;
+	if (skb_vlan_tag_present(skb))
+		max_pkt_len += VLAN_HLEN;
+	if (!skb_shinfo(skb)->gso_size && (unlikely(skb->len > max_pkt_len)))
+		goto out_free;
+
 	/*
 	 * Figure out which TX Queue we're going to use.
 	 */
-- 
2.3.4
