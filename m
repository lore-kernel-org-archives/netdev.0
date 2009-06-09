From: Chris Wright <chrisw@sous-sol.org>
Subject: [PATCH] ixgbe: fix mismatched dma map/unmap size
Date: Tue, 9 Jun 2009 10:11:51 -0700
Message-ID: <20090609171151.GM20823@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	andy@greyhouse.net
To: jeffrey.t.kirsher@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

DMA buffer is mapped w/ NET_IP_ALIGN accounted, unmapped w/out.
Dma debugging generates this warning.  Simple fix below.

[   76.356509] ixgbe 0000:04:00.0: DMA-API: device driver frees DMA
memory with different size [device address=0x00000000fff7f022] [map
size=1524 bytes] [unmap size=1522 bytes]
...
[   76.440333]  [<ffffffffa000247f>] ixgbe_clean_rx_irq+0x123/0x41b [ixgbe]
...
[   76.551151] Mapped at:
[   76.553582]  [<ffffffff811bd745>] debug_dma_map_page+0x4d/0xf8
[   76.559584]  [<ffffffffa00012d4>] ixgbe_alloc_rx_buffers+0x204/0x2af [ixgbe]

Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
Fix is against v2.6.30-rc8-73-g3af968e, but still applies to net-next.

 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 07e778d..43aa62d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -669,7 +669,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		if (len && !skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-			                 rx_ring->rx_buf_len,
+			                 rx_ring->rx_buf_len + NET_IP_ALIGN,
 			                 PCI_DMA_FROMDEVICE);
 			skb_put(skb, len);
 		}
@@ -2440,7 +2440,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-			                 rx_ring->rx_buf_len,
+			                 rx_ring->rx_buf_len + NET_IP_ALIGN,
 			                 PCI_DMA_FROMDEVICE);
 			rx_buffer_info->dma = 0;
 		}

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables unlimited
royalty-free distribution of the report engine for externally facing 
server and web deployment.
http://p.sf.net/sfu/businessobjects
