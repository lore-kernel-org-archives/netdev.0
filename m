From: xiaohui.xin@intel.com
Subject: [PATCH v11 06/17]Use callback to deal with skb_release_data() specially.
Date: Sat, 25 Sep 2010 12:27:24 +0800
Message-ID: <08d6446b209d0422e448bf964807846df73426b0.1285385607.git.xiaohui.xin@intel.com>
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

If buffer is external, then use the callback to destruct
buffers.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>

---
 include/linux/skbuff.h |    3 ++-
 net/core/skbuff.c      |    8 ++++++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 74af06c..ab29675 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -197,10 +197,11 @@ struct skb_shared_info {
 	union skb_shared_tx tx_flags;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
-	skb_frag_t	frags[MAX_SKB_FRAGS];
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
 	void *		destructor_arg;
+
+	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
 
 /* The structure is for a skb which pages may point to
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 93c4e06..117d82b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -217,6 +217,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->tx_flags.flags = 0;
+	shinfo->destructor_arg = NULL;
 	skb_frag_list_init(skb);
 	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
 
@@ -350,6 +351,13 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_has_frags(skb))
 			skb_drop_fraglist(skb);
 
+		if (skb->dev && dev_is_mpassthru(skb->dev)) {
+			struct skb_ext_page *ext_page =
+				skb_shinfo(skb)->destructor_arg;
+			if (ext_page && ext_page->dtor)
+				ext_page->dtor(ext_page);
+		}
+
 		kfree(skb->head);
 	}
 }
-- 
1.7.3

