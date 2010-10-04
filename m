From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/9] qlcnic: fix internal loopback test
Date: Mon,  4 Oct 2010 06:45:29 -0700
Message-ID: <1286199938-17367-2-git-send-email-amit.salecha@qlogic.com>
References: <1286199938-17367-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:56014 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753892Ab0JDNpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 09:45:44 -0400
In-Reply-To: <1286199938-17367-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Loop 10 times with delay of 1 ms to rcv packet.
o Print garbage packet.
o Try send/receive MAX(16) packet, instead of exit from test,
  if a packet is not received.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |   26 +++++++++++++++++++-------
 drivers/net/qlcnic/qlcnic_init.c    |   19 ++++++++++++++++++-
 2 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index cb9463b..550cfe9 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -636,6 +636,8 @@ static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 }
 
 #define QLC_ILB_PKT_SIZE 64
+#define QLC_NUM_ILB_PKT	16
+#define QLC_ILB_MAX_RCV_LOOP 10
 
 static void qlcnic_create_loopback_buff(unsigned char *data)
 {
@@ -657,24 +659,34 @@ static int qlcnic_do_ilb_test(struct qlcnic_adapter *adapter)
 	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring = &recv_ctx->sds_rings[0];
 	struct sk_buff *skb;
-	int i;
+	int i, loop, cnt = 0;
 
-	for (i = 0; i < 16; i++) {
+	for (i = 0; i < QLC_NUM_ILB_PKT; i++) {
 		skb = dev_alloc_skb(QLC_ILB_PKT_SIZE);
 		qlcnic_create_loopback_buff(skb->data);
 		skb_put(skb, QLC_ILB_PKT_SIZE);
 
 		adapter->diag_cnt = 0;
-
 		qlcnic_xmit_frame(skb, adapter->netdev);
 
-		msleep(5);
-
-		qlcnic_process_rcv_ring_diag(sds_ring);
+		loop = 0;
+		do {
+			msleep(1);
+			qlcnic_process_rcv_ring_diag(sds_ring);
+		} while (loop++ < QLC_ILB_MAX_RCV_LOOP &&
+			 !adapter->diag_cnt);
 
 		dev_kfree_skb_any(skb);
+
 		if (!adapter->diag_cnt)
-			return -1;
+			dev_warn(&adapter->pdev->dev, "ILB Test: %dth packet"
+				" not recevied\n", i + 1);
+		else
+			cnt++;
+	}
+	if (cnt != i) {
+		dev_warn(&adapter->pdev->dev, "ILB Test failed\n");
+		return -1;
 	}
 	return 0;
 }
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 5c33d15..908a25b 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1693,6 +1693,18 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 	spin_unlock(&rds_ring->lock);
 }
 
+static void dump_skb(struct sk_buff *skb)
+{
+	int i;
+	unsigned char *data = skb->data;
+
+	for (i = 0; i < skb->len; i++) {
+		printk("%02x ", data[i]);
+		if ((i & 0x0f) == 8)
+			printk("\n");
+	}
+}
+
 static struct qlcnic_rx_buffer *
 qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_sds_ring *sds_ring,
@@ -1723,13 +1735,18 @@ qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 	if (!skb)
 		return buffer;
 
-	skb_put(skb, rds_ring->skb_size);
+	if (length > rds_ring->skb_size)
+		skb_put(skb, rds_ring->skb_size);
+	else
+		skb_put(skb, length);
 
 	if (pkt_offset)
 		skb_pull(skb, pkt_offset);
 
 	if (!qlcnic_check_loopback_buff(skb->data))
 		adapter->diag_cnt++;
+	else
+		dump_skb(skb);
 
 	dev_kfree_skb_any(skb);
 	adapter->stats.rx_pkts++;
-- 
1.6.0.2

