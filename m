From: xiaohui.xin@intel.com
Subject: [PATCH v11 08/17] Modify netdev_free_page() to release external buffer
Date: Sat, 25 Sep 2010 12:27:26 +0800
Message-ID: <f5b3b0f213d191ab89ddc62dd90f5c0948d579cb.1285385607.git.xiaohui.xin@intel.com>
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
 include/linux/skbuff.h |    4 +++-
 net/core/skbuff.c      |   24 ++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ab29675..3d7f70e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1512,9 +1512,11 @@ static inline struct page *netdev_alloc_page(struct net_device *dev)
 	return __netdev_alloc_page(dev, GFP_ATOMIC);
 }
 
+extern void __netdev_free_page(struct net_device *dev, struct page *page);
+
 static inline void netdev_free_page(struct net_device *dev, struct page *page)
 {
-	__free_page(page);
+	__netdev_free_page(dev, page);
 }
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1a61e2b..bbf4707 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -306,6 +306,30 @@ struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(__netdev_alloc_page);
 
+void netdev_free_ext_page(struct net_device *dev, struct page *page)
+{
+	struct skb_ext_page *ext_page = NULL;
+	if (dev_is_mpassthru(dev) && dev->mp_port->hash) {
+		ext_page = dev->mp_port->hash(dev, page);
+		if (ext_page)
+			ext_page->dtor(ext_page);
+		else
+			__free_page(page);
+	}
+}
+EXPORT_SYMBOL(netdev_free_ext_page);
+
+void __netdev_free_page(struct net_device *dev, struct page *page)
+{
+	if (dev_is_mpassthru(dev)) {
+		netdev_free_ext_page(dev, page);
+		return;
+	}
+
+	__free_page(page);
+}
+EXPORT_SYMBOL(__netdev_free_page);
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
-- 
1.7.3

