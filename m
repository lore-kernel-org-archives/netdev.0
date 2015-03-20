From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v3 9/9] amd-xgbe: Use napi_alloc_skb when
 allocating skb in softirq
Date: Fri, 20 Mar 2015 11:50:41 -0500
Message-ID: <20150320165041.13799.86206.stgit@tlendack-t1.amdoffice.net>
References: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0127.outbound.protection.outlook.com ([65.55.169.127]:10620
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751704AbbCTQur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 12:50:47 -0400
In-Reply-To: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the napi_alloc_skb function to allocate an skb when running within
the softirq context to avoid calls to local_irq_save/restore.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index fc362be..347fe24 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1821,16 +1821,15 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
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
 
@@ -2000,7 +1999,7 @@ read_again:
 							rdata->rx.hdr.dma_len,
 							DMA_FROM_DEVICE);
 
-				skb = xgbe_create_skb(pdata, rdata, &put_len);
+				skb = xgbe_create_skb(napi, rdata, &put_len);
 				if (!skb) {
 					error = 1;
 					goto skip_data;
