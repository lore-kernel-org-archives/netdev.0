From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH V2 3/5] Add userspace buffers callback in skb_share_info
Date: Fri, 10 Dec 2010 02:01:22 -0800
Message-ID: <1291975282.2167.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 include/linux/skbuff.h |   13 +++++++++++++
 net/core/skbuff.c      |   13 ++++++++++++-
 2 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e6ba898..938a7cb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -183,6 +183,15 @@ enum {
 	SKBTX_DRV_NEEDS_SK_REF = 1 << 3,
 };
 
+/* The callback notifies userspace to release buffers when skb DMA is done in
+ * lower device, the desc is used to track userspace buffer index.
+ */
+struct skb_ubuf_info {
+	/* support buffers allocation from userspace */
+	void		(*callback)(struct sk_buff *);
+	size_t		desc;
+};
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -205,6 +214,10 @@ struct skb_shared_info {
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
 	void *		destructor_arg;
+
+	/* DMA mapping from userspace buffers */
+	struct skb_ubuf_info ubuf;
+
 	/* must be last field, see pskb_expand_head() */
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 104f844..f9468a0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -210,6 +210,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	shinfo = skb_shinfo(skb);
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
+	shinfo->ubuf.callback = NULL;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -329,6 +330,15 @@ static void skb_release_data(struct sk_buff *skb)
 
 		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
+		
+		/*
+		 * if skb buf is from userspace, we need to notify the caller
+		 * the lower device DMA has done;
+		 */
+		if (skb_shinfo(skb)->ubuf.callback) {
+			skb_shinfo(skb)->ubuf.callback(skb);
+			skb_shinfo(skb)->ubuf.callback = NULL;
+		}
 
 		kfree(skb->head);
 	}
@@ -492,6 +502,7 @@ bool skb_recycle_check(struct sk_buff *skb, int skb_size)
 	shinfo = skb_shinfo(skb);
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
+	shinfo->ubuf.callback = NULL;
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data = skb->head + NET_SKB_PAD;
