From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 7/8] qlcnic: protect resource access
Date: Thu, 22 Apr 2010 05:51:41 -0700
Message-ID: <1271940702-17064-8-git-send-email-amit.salecha@qlogic.com>
References: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24051 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754592Ab0DVMvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:51:45 -0400
In-Reply-To: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do netif_device_attach, even if resource allocation fails.
Driver callbacks can be called, if device is attached.
All these callbacks need to be protected by ADAPTER_UP_MAGIC check.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index bfc5510..ee573fe 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -208,6 +208,9 @@ qlcnic_napi_enable(struct qlcnic_adapter *adapter)
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
 
+	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+		return;
+
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 		napi_enable(&sds_ring->napi);
@@ -222,6 +225,9 @@ qlcnic_napi_disable(struct qlcnic_adapter *adapter)
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
 
+	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+		return;
+
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 		qlcnic_disable_int(sds_ring);
@@ -1573,6 +1579,11 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	int frag_count, no_of_desc;
 	u32 num_txd = tx_ring->num_desc;
 
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+		netif_stop_queue(netdev);
+		return NETDEV_TX_BUSY;
+	}
+
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
 
 	/* 4 fragments per cmd des */
-- 
1.6.0.2

