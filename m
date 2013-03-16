From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH 3/3] e1000e: Add missing
	dma_mapping_error-call in e1000_alloc_jumbo_rx_buffers
Date: Sat, 16 Mar 2013 11:32:05 +0100
Message-ID: <1363429925-12724-4-git-send-email-christoph.paasch@uclouvain.be>
References: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

After dma_map_page, dma_mapping_error must be called. It seems safe to
not free the skb/page allocated in this function, as the skb/page can be
reused later.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 142ca39..5706dcd 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -846,11 +846,16 @@ check_page:
 			}
 		}
 
-		if (!buffer_info->dma)
+		if (!buffer_info->dma) {
 			buffer_info->dma = dma_map_page(&pdev->dev,
 							buffer_info->page, 0,
 							PAGE_SIZE,
 							DMA_FROM_DEVICE);
+			if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
+				adapter->alloc_rx_buff_failed++;
+				break;
+			}
+		}
 
 		rx_desc = E1000_RX_DESC_EXT(*rx_ring, i);
 		rx_desc->read.buffer_addr = cpu_to_le64(buffer_info->dma);
-- 
1.8.1.227.g44fe835


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_mar
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
