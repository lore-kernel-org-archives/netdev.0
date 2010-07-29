From: xiaohui.xin@intel.com
Subject: [RFC PATCH v8 16/16] An example how to alloc user buffer based on napi_gro_frags() interface.
Date: Thu, 29 Jul 2010 19:14:48 +0800
Message-ID: <1280402088-5849-17-git-send-email-xiaohui.xin@intel.com>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-2-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-3-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-4-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-5-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-6-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-7-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-8-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-9-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-10-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-11-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-12-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-13-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-14-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-15-git-send-email-xiaohui.xin@intel.com>
 <1280402088-5849-16-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14693 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756907Ab0G2LBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jul 2010 07:01:43 -0400
In-Reply-To: <1280402088-5849-16-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

This example is made on ixgbe driver which using napi_gro_frags().
It can get buffers from guest side directly using netdev_alloc_page()
and release guest buffers using netdev_free_page().

---
 drivers/net/ixgbe/ixgbe_main.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index cfe6853..de5c6d0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -691,7 +691,14 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
 static bool is_rx_buffer_mapped_as_page(struct ixgbe_rx_buffer *bi,
 					struct net_device *dev)
 {
-	return true;
+	return dev_is_mpassthru(dev);
+}
+
+static u32 get_page_skb_offset(struct net_device *dev)
+{
+	if (!dev_is_mpassthru(dev))
+		return 0;
+	return dev->mp_port->vnet_hlen;
 }
 
 /**
@@ -764,7 +771,8 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 				adapter->alloc_rx_page_failed++;
 				goto no_buffers;
 			}
-			bi->page_skb_offset = 0;
+			bi->page_skb_offset =
+				get_page_skb_offset(adapter->netdev);
 			bi->dma = pci_map_page(pdev, bi->page_skb,
 					bi->page_skb_offset,
 					(PAGE_SIZE / 2),
@@ -899,8 +907,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			len = le16_to_cpu(rx_desc->wb.upper.length);
 		}
 
-		if (is_no_buffer(rx_buffer_info))
+		if (is_no_buffer(rx_buffer_info)) {
+			printk("no buffers\n");
 			break;
+		}
 
 		cleaned = true;
 
@@ -962,7 +972,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			                   upper_len);
 
 			if ((rx_ring->rx_buf_len > (PAGE_SIZE / 2)) ||
-			    (page_count(rx_buffer_info->page) != 1))
+			    (page_count(rx_buffer_info->page) != 1) ||
+				dev_is_mpassthru(netdev))
 				rx_buffer_info->page = NULL;
 			else
 				get_page(rx_buffer_info->page);
-- 
1.5.4.4

