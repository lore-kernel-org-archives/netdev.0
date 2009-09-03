From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 1/3] netxen: fix lro buffer allocation
Date: Thu,  3 Sep 2009 16:10:53 -0700
Message-ID: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Dhananjay Phadke <dhananjay@qlogic.com>
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:12129 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S932466AbZICXKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 19:10:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@qlogic.com>

Alloc 12k skbuffs so that firmware can aggregate more
packets into one buffer. This doesn't raise memory
consumption since 9k skbs use 16k slab cache anyway.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 +
 drivers/net/netxen/netxen_nic_init.c |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 224a746..ede2fa7 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -149,6 +149,7 @@
 #define NX_P2_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P2_MAX_MTU)
 #define NX_P3_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P3_MAX_MTU)
 #define NX_CT_DEFAULT_RX_BUF_LEN	2048
+#define NX_LRO_BUFFER_EXTRA		2048
 
 #define NX_RX_LRO_BUFFER_LENGTH		(8060)
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 8d4aa6f..04e36f2 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -265,6 +265,10 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			else
 				rds_ring->dma_size =
 					NX_P2_RX_JUMBO_BUF_MAX_LEN;
+
+			if (adapter->capabilities & NX_CAP0_HW_LRO)
+				rds_ring->dma_size += NX_LRO_BUFFER_EXTRA;
+
 			rds_ring->skb_size =
 				rds_ring->dma_size + NET_IP_ALIGN;
 			break;
@@ -1217,6 +1221,7 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 	if (pkt_offset)
 		skb_pull(skb, pkt_offset);
 
+	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	napi_gro_receive(&sds_ring->napi, skb);
@@ -1278,8 +1283,7 @@ netxen_process_lro(struct netxen_adapter *adapter,
 
 	skb_put(skb, lro_length + data_offset);
 
-	skb->truesize = (skb->len + sizeof(struct sk_buff) +
-			((unsigned long)skb->data - (unsigned long)skb->head));
+	skb->truesize = skb->len + sizeof(struct sk_buff) + skb_headroom(skb);
 
 	skb_pull(skb, l2_hdr_offset);
 	skb->protocol = eth_type_trans(skb, netdev);
-- 
1.6.0.2

