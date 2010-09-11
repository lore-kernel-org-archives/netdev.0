From: xiaohui.xin@intel.com
Subject: [RFC PATCH v10 16/16]An example how to alloc user buffer based on napi_gro_frags() interface.
Date: Sat, 11 Sep 2010 17:53:09 +0800
Message-ID: <1284198789-5358-17-git-send-email-xiaohui.xin@intel.com>
References: <1284198789-5358-1-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-2-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-3-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-4-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-5-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-6-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-7-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-8-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-9-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-10-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-11-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-12-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-13-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-14-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-15-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-16-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1284198789-5358-16-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

This example is made on ixgbe driver which using napi_gro_frags().
It can get buffers from guest side directly using netdev_alloc_page()
and release guest buffers using netdev_free_page().

---
 drivers/net/ixgbe/ixgbe_main.c |   25 +++++++++++++++++++++----
 1 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 905d6d2..0977f2f 100644
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
 
@@ -959,6 +969,12 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 						rx_buffer_info->page_skb,
 						rx_buffer_info->page_skb_offset,
 						len);
+				if (dev_is_mpassthru(netdev) &&
+						netdev->mp_port->hash)
+					skb_shinfo(skb)->destructor_arg =
+					netdev->mp_port->hash(netdev,
+					rx_buffer_info->page_skb);
+
 				rx_buffer_info->page_skb = NULL;
 				skb->len += len;
 				skb->data_len += len;
@@ -976,7 +992,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
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

