From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v5 11/19] Use callback to deal with skb_release_data() specially.
Date: Fri,  7 May 2010 17:34:58 +0800
Message-ID: <1273224906-4874-12-git-send-email-xiaohui.xin@intel.com>
References: <1273224906-4874-1-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-2-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-3-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-4-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-5-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-6-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-7-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-8-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-9-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-10-git-send-email-xiaohui.xin@intel.com>
 <1273224906-4874-11-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55769 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755563Ab0EGJaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 05:30:08 -0400
In-Reply-To: <1273224906-4874-11-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

If buffer is external, then use the callback to destruct
buffers.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 net/core/skbuff.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 169f22c..5d93b2d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -385,6 +385,11 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 
 static void skb_release_data(struct sk_buff *skb)
 {
+	/* check if the skb has external buffers, we have use destructor_arg
+	 * here to indicate
+	 */
+	struct skb_external_page *ext_page = skb_shinfo(skb)->destructor_arg;
+
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
@@ -397,6 +402,12 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_has_frags(skb))
 			skb_drop_fraglist(skb);
 
+		/* if the skb has external buffers, use destructor here,
+		 * since after that skb->head will be kfree, in case skb->head
+		 * from external buffer cannot use kfree to destroy.
+		 */
+		if (dev_is_mpassthru(skb->dev) && ext_page && ext_page->dtor)
+			ext_page->dtor(ext_page);
 		kfree(skb->head);
 	}
 }
-- 
1.5.4.4

