From: WingMan Kwok <w-kwok2@ti.com>
Subject: [PATCH 2/2] net: netcp: Allocate RX packet buffers using __GFP_DMA
Date: Wed, 29 Jul 2015 11:10:53 -0400
Message-ID: <1438182653-2136-2-git-send-email-w-kwok2@ti.com>
References: <1438182653-2136-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>, "Reece R. Pollack" <x0183204@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438182653-2136-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Keystone II DMA hardware can only access addresses in the
lower 2 GiB of SDRAM. This patch makes sure the RX buffers are
allocated using the __GFP_DMA flag so they meet this requirement.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Reece R. Pollack <x0183204@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 2d07701..39c68df 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -820,11 +820,13 @@ static void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 				SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 		if (primary_buf_len <= PAGE_SIZE) {
-			bufptr = netdev_alloc_frag(primary_buf_len);
+			bufptr = __netdev_alloc_frag(primary_buf_len,
+						     GFP_ATOMIC | __GFP_COLD |
+						     __GFP_DMA);
 			pad[1] = primary_buf_len;
 		} else {
 			bufptr = kmalloc(primary_buf_len, GFP_ATOMIC |
-					 GFP_DMA32 | __GFP_COLD);
+					 __GFP_COLD | __GFP_DMA);
 			pad[1] = 0;
 		}
 
@@ -838,9 +840,10 @@ static void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 
 	} else {
 		/* Allocate a secondary receive queue entry */
-		page = alloc_page(GFP_ATOMIC | GFP_DMA32 | __GFP_COLD);
+		page = alloc_page(GFP_ATOMIC | __GFP_COLD | __GFP_DMA);
 		if (unlikely(!page)) {
-			dev_warn_ratelimited(netcp->ndev_dev, "Secondary page alloc failed\n");
+			dev_warn_ratelimited(netcp->ndev_dev,
+					     "Secondary page alloc failed\n");
 			goto fail;
 		}
 		buf_len = PAGE_SIZE;
-- 
1.7.9.5
