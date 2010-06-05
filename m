From: xiaohui.xin@intel.com
Subject: [RFC PATCH v7 09/19] Ignore room skb_reserve() when device is using external buffer.
Date: Sat,  5 Jun 2010 18:14:48 +0800
Message-ID: <1275732899-5423-9-git-send-email-xiaohui.xin@intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65455 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932872Ab0FEKHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 06:07:06 -0400
In-Reply-To: <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Make the skb->data and skb->head from external buffer
to be consistent, we ignore the room reserved by driver
for kernel skb.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/skbuff.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5ff8c27..193b259 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1200,6 +1200,15 @@ static inline int skb_tailroom(const struct sk_buff *skb)
  */
 static inline void skb_reserve(struct sk_buff *skb, int len)
 {
+	/* Since skb_reserve() is only for an empty buffer,
+	 * and when the skb is getting external buffer, we cannot
+	 * retain the external buffer has the same reserved space
+	 * in the header which kernel allocatd skb has, so have to
+	 * ignore this. And we have recorded the external buffer
+	 * info in the destructor_arg field, so use it as indicator.
+	 */
+	if (skb_shinfo(skb)->destructor_arg)
+		return;
 	skb->data += len;
 	skb->tail += len;
 }
-- 
1.5.4.4

