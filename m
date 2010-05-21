From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v6 09/19] Ignore room skb_reserve() when device is using external buffer.
Date: Fri, 21 May 2010 17:30:25 +0800
Message-ID: <1274434235-5929-10-git-send-email-xiaohui.xin@intel.com>
References: <1274434235-5929-1-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-2-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-3-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-4-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-5-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-6-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-7-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-8-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-9-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1274434235-5929-9-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

