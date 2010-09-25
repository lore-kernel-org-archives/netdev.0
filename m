From: xiaohui.xin@intel.com
Subject: [PATCH v11 07/17] Modify netdev_alloc_page() to get external buffer
Date: Sat, 25 Sep 2010 12:27:25 +0800
Message-ID: <8cf1dad79db07e71707cfd256927ef3324adfda9.1285385607.git.xiaohui.xin@intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Currently, it can get external buffers from mp device.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>

---
 net/core/skbuff.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 117d82b..1a61e2b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -269,11 +269,38 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 }
 EXPORT_SYMBOL(__netdev_alloc_skb);
 
+struct page *netdev_alloc_ext_pages(struct net_device *dev, int npages)
+{
+	struct mpassthru_port *port;
+	struct skb_ext_page *ext_page = NULL;
+
+	port = dev->mp_port;
+	if (!port)
+		goto out;
+	ext_page = port->ctor(port, NULL, npages);
+	if (ext_page)
+		return ext_page->page;
+out:
+	return NULL;
+
+}
+EXPORT_SYMBOL(netdev_alloc_ext_pages);
+
+struct page *netdev_alloc_ext_page(struct net_device *dev)
+{
+	return netdev_alloc_ext_pages(dev, 1);
+
+}
+EXPORT_SYMBOL(netdev_alloc_ext_page);
+
 struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
 {
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct page *page;
 
+	if (dev_is_mpassthru(dev))
+		return netdev_alloc_ext_page(dev);
+
 	page = alloc_pages_node(node, gfp_mask, 0);
 	return page;
 }
-- 
1.7.3

