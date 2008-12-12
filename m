From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] ixgbe: fix dma mapping unbalance
Date: Fri, 12 Dec 2008 01:51:05 -0800
Message-ID: <20081212095104.4380.49487.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Joerg Roedel <joerg.roedel@amd.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:42471 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751411AbYLLJv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 04:51:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This issue was initially reported by Joerg Roedel <joerg.roedel@amd.com>
It appears that ixgbe has had a long standing bug where it was unmapping a different size than it had mapped.

ixgbe 0000:02:00.0: PCI-DMA: device driver frees DMA memory with different sizes than it mapped.
ixgbe 0000:02:00.0: PCI-DMA: device driver frees DMA memory with different size [device address=0x0000000003fed812] [map size=258 bytes] [unmap size=256 bytes]
Pid: 6178, comm: rmmod Not tainted 2.6.28-rc5 #4 Call Trace:
 [<ffffffff8022a2ae>] iommu_queue_inv_iommu_pages+0x5e/0x70
 [<ffffffff80225956>] check_unmap+0x1c6/0x240  [<ffffffff80225ff5>] debug_unmap_single+0xb5/0x110  [<ffffffffa0213997>] ixgbe_clean_rx_ring+0x147/0x220  [<ffffffffa0214d7d>] ixgbe_down+0x2fd/0x3d0 [ixgbe]  [<ffffffffa02150b3>] ixgbe_close+0x13/0xc0 [ixgbe]  [<ffffffff80431326>] dev_close+0x56/0xa0  [<ffffffff804313b3>] rollback_registered+0x43/0x220  [<ffffffff804315a5>] unregister_netdevice+0x15/0x60  [<ffffffff80431601>] unregister_netdev+0x11/0x20  [<ffffffffa021aef8>] ixgbe_remove+0x48/0x16e [ixgbe]  [<ffffffff80386ffc>] pci_device_remove+0x2c/0x60  [<ffffffff803ef929>] __device_release_driver+0x99/0x100
 [<ffffffff803efa48>] driver_detach+0xb8/0xc0  [<ffffffff803eea6e>] bus_remove_driver+0x8e/0xd0  [<ffffffff80387374>] pci_unregister_driver+0x34/0x90  [<ffffffff8026c6c7>] sys_delete_module+0x1c7/0x2a0  [<ffffffff802a9ce9>] do_munmap+0x349/0x390  [<ffffffff80374481>] __up_write+0x21/0x150  [<ffffffff8020c30b>] system_call_fastpath+0x16/0x1b

CC: Joerg Roedel <joerg.roedel@amd.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d6f666a..92b35cf 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -479,7 +479,6 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
-	unsigned int bufsz = rx_ring->rx_buf_len + NET_IP_ALIGN;
 
 	i = rx_ring->next_to_use;
 	bi = &rx_ring->rx_buffer_info[i];
@@ -508,8 +507,10 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		}
 
 		if (!bi->skb) {
-			struct sk_buff *skb = netdev_alloc_skb(adapter->netdev,
-			                                       bufsz);
+			struct sk_buff *skb;
+			skb = netdev_alloc_skb(adapter->netdev,
+			                       (rx_ring->rx_buf_len +
+			                        NET_IP_ALIGN));
 
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
@@ -524,7 +525,8 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			skb_reserve(skb, NET_IP_ALIGN);
 
 			bi->skb = skb;
-			bi->dma = pci_map_single(pdev, skb->data, bufsz,
+			bi->dma = pci_map_single(pdev, skb->data,
+			                         rx_ring->rx_buf_len,
 			                         PCI_DMA_FROMDEVICE);
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
@@ -615,7 +617,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 
 		if (len && !skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-			                 rx_ring->rx_buf_len + NET_IP_ALIGN,
+			                 rx_ring->rx_buf_len,
 			                 PCI_DMA_FROMDEVICE);
 			skb_put(skb, len);
 		}

