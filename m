From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 09/10] amd-xgbe: Use napi_alloc_skb when allocating
 skb in softirq
Date: Thu, 19 Mar 2015 12:13:19 -0500
Message-ID: <20150319171319.26446.11901.stgit@tlendack-t1.amdoffice.net>
References: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0119.outbound.protection.outlook.com ([207.46.100.119]:61356
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030231AbbCSR1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 13:27:55 -0400
In-Reply-To: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the napi_alloc_skb function to allocate an skb when running within
the softirq context to avoid calls to local_irq_save/restore.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 2927d7c..89b1fca 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1819,16 +1819,15 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
 			  lower_32_bits(rdata->rdesc_dma));
 }
 
-static struct sk_buff *xgbe_create_skb(struct xgbe_prv_data *pdata,
+static struct sk_buff *xgbe_create_skb(struct napi_struct *napi,
 				       struct xgbe_ring_data *rdata,
 				       unsigned int *len)
 {
-	struct net_device *netdev = pdata->netdev;
 	struct sk_buff *skb;
 	u8 *packet;
 	unsigned int copy_len;
 
-	skb = netdev_alloc_skb_ip_align(netdev, rdata->rx.hdr.dma_len);
+	skb = napi_alloc_skb(napi, rdata->rx.hdr.dma_len);
 	if (!skb)
 		return NULL;
 
@@ -1998,7 +1997,7 @@ read_again:
 							rdata->rx.hdr.dma_len,
 							DMA_FROM_DEVICE);
 
-				skb = xgbe_create_skb(pdata, rdata, &put_len);
+				skb = xgbe_create_skb(napi, rdata, &put_len);
 				if (!skb) {
 					error = 1;
 					goto skip_data;
