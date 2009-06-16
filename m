From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: dma-debug warning with ixgbe
Date: Tue, 16 Jun 2009 09:33:15 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0906160907580.6076@jbrandeb-desk1.amr.corp.intel.com>
References: <20090616153417.GN5139@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090616153417.GN5139@amd.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 16 Jun 2009, Joerg Roedel wrote:
> today I got this dma-debug warning with the ixgbe driver with a kernel
> near 2.6.30-rc8.

Hi Joerg, thanks for the report, I thought we had fixed all of these 
already but we must have missed this one.

> ------------[ cut here ]------------
> WARNING: at /data/repos/linux-2.6-iommu/lib/dma-debug.c:806
> check_unmap+0x214/0x5c3()
> Hardware name: Toonie
> ixgbe 0000:02:00.0: DMA-API: device driver frees DMA memory with
> different size [device address=0x0000000000045c12] [map size=258
> bytes] [unmap size=256 bytes]

The following patch should fix it, compile tested only, but it is pretty 
straight forward.

---

ixgbe: fix map length bug

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

ixgbe is mapping more than it unmaps, reduce the length of the map call and
remove the "used once" local variable.

found by Joerg Roedel <joerg.roedel@amd.com> in 2.6.30, so is a candidate for
-stable.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Joerg Roedel <joerg.roedel@amd.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)


diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a551a96..01c2193 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -563,7 +563,6 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
-	unsigned int bufsz = rx_ring->rx_buf_len + NET_IP_ALIGN;
 
 	i = rx_ring->next_to_use;
 	bi = &rx_ring->rx_buffer_info[i];
@@ -593,7 +592,9 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 
 		if (!bi->skb) {
 			struct sk_buff *skb;
-			skb = netdev_alloc_skb(adapter->netdev, bufsz);
+			skb = netdev_alloc_skb(adapter->netdev,
+			                       (rx_ring->rx_buf_len +
+			                        NET_IP_ALIGN));
 
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
@@ -608,7 +609,8 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			skb_reserve(skb, NET_IP_ALIGN);
 
 			bi->skb = skb;
-			bi->dma = pci_map_single(pdev, skb->data, bufsz,
+			bi->dma = pci_map_single(pdev, skb->data,
+			                         rx_ring->rx_buf_len,
 			                         PCI_DMA_FROMDEVICE);
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables unlimited
royalty-free distribution of the report engine for externally facing 
server and web deployment.
http://p.sf.net/sfu/businessobjects
