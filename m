From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/3] cxgb - fix T2 GSO
Date: Tue, 27 Nov 2007 13:30:09 -0800
Message-ID: <20071127213009.804.49490.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greearb@candelatech.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:13321 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399AbXK0VaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 16:30:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

The patch ensures that a GSO skb has enough headroom
to push an encapsulating cpl_tx_pkt_lso header.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/chelsio/cxgb2.c |    3 ++-
 drivers/net/chelsio/sge.c   |   34 +++++++++++++++-------------------
 drivers/net/chelsio/sge.h   |    1 +
 3 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
old mode 100644
new mode 100755
index 2dbf8dc..2461f91
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -401,7 +401,8 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"TxTso",
 	"RxVlan",
 	"TxVlan",
-
+	"TxNeedHeadroom", 
+	
 	/* Interrupt stats */
 	"rx drops",
 	"pure_rsps",
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
old mode 100644
new mode 100755
index 4436662..e8b1036
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -991,6 +991,7 @@ void t1_sge_get_port_stats(const struct sge *sge, int port,
 		ss->tx_packets += st->tx_packets;
 		ss->tx_cso += st->tx_cso;
 		ss->tx_tso += st->tx_tso;
+		ss->tx_need_hdrroom += st->tx_need_hdrroom;
 		ss->vlan_xtract += st->vlan_xtract;
 		ss->vlan_insert += st->vlan_insert;
 	}
@@ -1848,7 +1849,8 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct adapter *adapter = dev->priv;
 	struct sge *sge = adapter->sge;
-	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port], smp_processor_id());
+	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port],
+						smp_processor_id());
 	struct cpl_tx_pkt *cpl;
 	struct sk_buff *orig_skb = skb;
 	int ret;
@@ -1856,6 +1858,18 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb->protocol == htons(ETH_P_CPL5))
 		goto send;
 
+	/*
+	 * We are using a non-standard hard_header_len.
+	 * Allocate more header room in the rare cases it is not big enough.
+	 */
+	if (unlikely(skb_headroom(skb) < dev->hard_header_len - ETH_HLEN)) {
+		skb = skb_realloc_headroom(skb, sizeof(struct cpl_tx_pkt_lso));
+		++st->tx_need_hdrroom;
+		dev_kfree_skb_any(orig_skb);
+		if (!skb)
+			return NETDEV_TX_OK;
+	}
+
 	if (skb_shinfo(skb)->gso_size) {
 		int eth_type;
 		struct cpl_tx_pkt_lso *hdr;
@@ -1889,24 +1903,6 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			return NETDEV_TX_OK;
 		}
 
-		/*
-		 * We are using a non-standard hard_header_len and some kernel
-		 * components, such as pktgen, do not handle it right.
-		 * Complain when this happens but try to fix things up.
-		 */
-		if (unlikely(skb_headroom(skb) < dev->hard_header_len - ETH_HLEN)) {
-			pr_debug("%s: headroom %d header_len %d\n", dev->name,
-				 skb_headroom(skb), dev->hard_header_len);
-
-			if (net_ratelimit())
-				printk(KERN_ERR "%s: inadequate headroom in "
-				       "Tx packet\n", dev->name);
-			skb = skb_realloc_headroom(skb, sizeof(*cpl));
-			dev_kfree_skb_any(orig_skb);
-			if (!skb)
-				return NETDEV_TX_OK;
-		}
-
 		if (!(adapter->flags & UDP_CSUM_CAPABLE) &&
 		    skb->ip_summed == CHECKSUM_PARTIAL &&
 		    ip_hdr(skb)->protocol == IPPROTO_UDP) {
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
old mode 100644
new mode 100755
index 713d9c5..285bbb2
--- a/drivers/net/chelsio/sge.h
+++ b/drivers/net/chelsio/sge.h
@@ -64,6 +64,7 @@ struct sge_port_stats {
 	u64 tx_tso;          /* # of TSO requests */
 	u64 vlan_xtract;     /* # of VLAN tag extractions */
 	u64 vlan_insert;     /* # of VLAN tag insertions */
+	u64 tx_need_hdrroom; /* # of TX skbs in need of more header room */
 };
 
 struct sk_buff;
