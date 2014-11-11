From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v3 1/5] net: Add device Rx page allocation function
Date: Tue, 11 Nov 2014 09:26:34 -0800
Message-ID: <20141111172634.16460.21282.stgit@ahduyck-vm-fedora20>
References: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37638 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087AbaKKR0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 12:26:46 -0500
In-Reply-To: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements __dev_alloc_pages and __dev_alloc_page.  These are
meant to replace the __skb_alloc_pages and __skb_alloc_page functions.  The
reason for doing this is that it occurred to me that __skb_alloc_page is
supposed to be passed an sk_buff pointer, but it is NULL in all cases where
it is used.  Worse is that in the case of ixgbe it is passed NULL via the
sk_buff pointer in the rx_buffer info structure which means the compiler is
not correctly stripping it out.

The naming for these functions is based on dev_alloc_skb and __dev_alloc_skb.
There was originally a netdev_alloc_page, however that was passed a
net_device pointer and this function is not so I thought it best to follow
that naming scheme since that is the same difference between dev_alloc_skb
and netdev_alloc_skb.

In the case of anything greater than order 0 it is assumed that we want a
compound page so __GFP_COMP is set for all allocations as we expect a
compound page when assigning a page frag.

The other change in this patch is to exploit the behaviors of the page
allocator in how it handles flags.  So for example we can always set
__GFP_COMP and __GFP_MEMALLOC since they are ignored if they are not
applicable or are overridden by another flag.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/skbuff.h |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 103fbe8..2e5221f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2185,6 +2185,54 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 }
 
 /**
+ * __dev_alloc_pages - allocate page for network Rx
+ * @gfp_mask: allocation priority. Set __GFP_NOMEMALLOC if not for network Rx
+ * @order: size of the allocation
+ *
+ * Allocate a new page.
+ *
+ * %NULL is returned if there is no free memory.
+*/
+static inline struct page *__dev_alloc_pages(gfp_t gfp_mask,
+					     unsigned int order)
+{
+	/* This piece of code contains several assumptions.
+	 * 1.  This is for device Rx, therefor a cold page is preferred.
+	 * 2.  The expectation is the user wants a compound page.
+	 * 3.  If requesting a order 0 page it will not be compound
+	 *     due to the check to see if order has a value in prep_new_page
+	 * 4.  __GFP_MEMALLOC is ignored if __GFP_NOMEMALLOC is set due to
+	 *     code in gfp_to_alloc_flags that should be enforcing this.
+	 */
+	gfp_mask |= __GFP_COLD | __GFP_COMP | __GFP_MEMALLOC;
+
+	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
+}
+
+static inline struct page *dev_alloc_pages(unsigned int order)
+{
+	return __dev_alloc_pages(GFP_ATOMIC, order);
+}
+
+/**
+ * __dev_alloc_page - allocate a page for network Rx
+ * @gfp_mask: allocation priority. Set __GFP_NOMEMALLOC if not for network Rx
+ *
+ * Allocate a new page.
+ *
+ * %NULL is returned if there is no free memory.
+ */
+static inline struct page *__dev_alloc_page(gfp_t gfp_mask)
+{
+	return __dev_alloc_pages(gfp_mask, 0);
+}
+
+static inline struct page *dev_alloc_page(void)
+{
+	return __dev_alloc_page(GFP_ATOMIC);
+}
+
+/**
  *	__skb_alloc_pages - allocate pages for ps-rx on a skb and preserve pfmemalloc data
  *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
  *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
