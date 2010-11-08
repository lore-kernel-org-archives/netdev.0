From: xiaohui.xin@intel.com
Subject: Re:[PATCH v14 06/17] Use callback to deal with skb_release_data() specially.
Date: Mon,  8 Nov 2010 16:03:50 +0800
Message-ID: <1289203430-5935-1-git-send-email-xiaohui.xin@intel.com>
References: <1288861663.2659.47.camel@edumazet-laptop>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com,
	mingo@elte.hu, davem@davemloft.net, herbert@gondor.apana.org.au,
	jdi
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288861663.2659.47.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

>> Hmm, I suggest you read the comment two lines above.
>>
>> If destructor_arg is now cleared each time we allocate a new skb, then,
>> please move it before dataref in shinfo structure, so that the following
>> memset() does the job efficiently...
>
>
>Something like :
>
>diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>index e6ba898..2dca504 100644
>--- a/include/linux/skbuff.h
>+++ b/include/linux/skbuff.h
>@@ -195,6 +195,9 @@ struct skb_shared_info {
> 	__be32          ip6_frag_id;
> 	__u8		tx_flags;
> 	struct sk_buff	*frag_list;
>+	/* Intermediate layers must ensure that destructor_arg
>+	 * remains valid until skb destructor */
>+	void		*destructor_arg;
> 	struct skb_shared_hwtstamps hwtstamps;
>
> 	/*
>@@ -202,9 +205,6 @@ struct skb_shared_info {
> 	 */
> 	atomic_t	dataref;
>
>-	/* Intermediate layers must ensure that destructor_arg
>-	 * remains valid until skb destructor */
>-	void *		destructor_arg;
> 	/* must be last field, see pskb_expand_head() */
> 	skb_frag_t	frags[MAX_SKB_FRAGS];
> };
>
>

Will that affect the cache line?
Or, we can move the line to clear destructor_arg to the end of __alloc_skb().
It looks like as the following, which one do you prefer?

Thanks
Xiaohui

---
 net/core/skbuff.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c83b421..df852f2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -224,6 +224,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
+	shinfo->destructor_arg = NULL;
 out:
 	return skb;
 nodata:
@@ -343,6 +344,13 @@ static void skb_release_data(struct sk_buff *skb)
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
