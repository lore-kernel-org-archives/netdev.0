From: xiaohui.xin@intel.com
Subject: [PATCH v14 17/17] An example how to alloc user buffer based on napi_gro_frags() interface.
Date: Thu,  4 Nov 2010 17:05:13 +0800
Message-ID: <6de07ce567594537ada454180c180ec2910fee0e.1288860478.git.xiaohui.xin@intel.com>
References: <1288861513-5707-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14233 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754914Ab0KDIoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 04:44:25 -0400
In-Reply-To: <1288861513-5707-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1288860477.git.xiaohui.xin@intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1288860477.git.xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

This example is made on ixgbe driver which using napi_gro_frags().
It can get buffers from guest side directly using netdev_alloc_page()
and release guest buffers using netdev_free_page().

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   37 +++++++++++++++++++++++++++++++++----
 1 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a4a5263..9f5598b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1032,7 +1032,14 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
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
@@ -1105,7 +1112,8 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 				adapter->alloc_rx_page_failed++;
 				goto no_buffers;
 			}
-			bi->page_skb_offset = 0;
+			bi->page_skb_offset =
+				get_page_skb_offset(adapter->netdev);
 			bi->dma = dma_map_page(&pdev->dev, bi->page_skb,
 					bi->page_skb_offset,
 					(PAGE_SIZE / 2),
@@ -1242,8 +1250,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			len = le16_to_cpu(rx_desc->wb.upper.length);
 		}
 
-		if (is_no_buffer(rx_buffer_info))
+		if (is_no_buffer(rx_buffer_info)) {
+			printk("no buffers\n");
 			break;
+		}
 		cleaned = true;
 
 		if (!rx_buffer_info->mapped_as_page) {
@@ -1299,6 +1309,11 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 						rx_buffer_info->page_skb,
 						rx_buffer_info->page_skb_offset,
 						len);
+				if (dev_is_mpassthru(netdev) &&
+						netdev->mp_port->hash)
+					skb_shinfo(skb)->destructor_arg =
+						netdev->mp_port->hash(netdev,
+						rx_buffer_info->page_skb);
 				rx_buffer_info->page_skb = NULL;
 				skb->len += len;
 				skb->data_len += len;
@@ -1316,7 +1331,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			                   upper_len);
 
 			if ((rx_ring->rx_buf_len > (PAGE_SIZE / 2)) ||
-			    (page_count(rx_buffer_info->page) != 1))
+			    (page_count(rx_buffer_info->page) != 1) ||
+				dev_is_mpassthru(netdev))
 				rx_buffer_info->page = NULL;
 			else
 				get_page(rx_buffer_info->page);
@@ -6529,6 +6545,16 @@ static void ixgbe_netpoll(struct net_device *netdev)
 }
 #endif
 
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+static int ixgbe_ndo_mp_port_prep(struct net_device *dev, struct mp_port *port)
+{
+	port->hdr_len = 128;
+	port->data_len = 2048;
+	port->npages = 1;
+	return 0;
+}
+#endif
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open 		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -6548,6 +6574,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
 	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+	.ndo_mp_port_prep	= ixgbe_ndo_mp_port_prep,
+#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
-- 
1.7.3

