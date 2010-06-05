From: xiaohui.xin@intel.com
Subject: [RFC PATCH v7 07/19] Add interface to get external buffers.
Date: Sat,  5 Jun 2010 18:14:46 +0800
Message-ID: <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Currently, it can get external buffers from mp device.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/skbuff.h |   12 ++++++++++++
 net/core/skbuff.c      |   16 ++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cf309c9..281a1c0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1519,6 +1519,18 @@ static inline void netdev_free_page(struct net_device *dev, struct page *page)
 	__free_page(page);
 }
 
+extern struct skb_external_page *netdev_alloc_external_pages(
+					struct net_device *dev,
+					struct sk_buff *skb, int npages);
+
+static inline struct skb_external_page *netdev_alloc_external_page(
+		struct net_device *dev,
+		struct sk_buff *skb, unsigned int size)
+{
+	return netdev_alloc_external_pages(dev, skb,
+					   DIV_ROUND_UP(size, PAGE_SIZE));
+}
+
 /**
  *	skb_clone_writable - is the header of a clone writable
  *	@skb: buffer to check
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 93c4e06..fbdb1f1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -278,6 +278,22 @@ struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(__netdev_alloc_page);
 
+struct skb_external_page *netdev_alloc_external_pages(struct net_device *dev,
+			struct sk_buff *skb, int npages)
+{
+	struct mpassthru_port *port;
+	struct skb_external_page *ext_page = NULL;
+
+	port = rcu_dereference(dev->mp_port);
+	if (!port)
+		goto out;
+	WARN_ON(npages > port->npages);
+	ext_page = port->ctor(port, skb, npages);
+out:
+	return ext_page;
+}
+EXPORT_SYMBOL(netdev_alloc_external_pages);
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
-- 
1.5.4.4
