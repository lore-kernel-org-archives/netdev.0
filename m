From: xiaohui.xin@intel.com
Subject: Re: [PATCH v15 00/17] Provide a zero-copy method on KVM virtio-net.
Date: Wed, 10 Nov 2010 17:23:28 +0800
Message-ID: <1289381008-5484-1-git-send-email-xiaohui.xin@intel.com>
References: <20101109.091516.112581012.davem@davemloft.net>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com,
	davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101109.091516.112581012.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

>2) The idea to key off of skb->dev in skb_release_data() is
>   fundamentally flawed since many actions can change skb->dev on you,
>   which will end up causing a leak of your external data areas.

How about this one? If the destructor_arg is not a good candidate,
then I have to add an apparent field in shinfo.

Thanks
Xiaohui

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 10ba67d..ad4636e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -199,14 +199,15 @@ struct skb_shared_info {
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
 
+	/* Intermediate layers must ensure that destructor_arg
+	 * remains valid until skb destructor */
+	void *		destructor_arg;
+
 	/*
 	 * Warning : all fields before dataref are cleared in __alloc_skb()
 	 */
 	atomic_t	dataref;
 
-	/* Intermediate layers must ensure that destructor_arg
-	 * remains valid until skb destructor */
-	void *		destructor_arg;
 	/* must be last field, see pskb_expand_head() */
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c83b421..eb040f4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -343,6 +343,13 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_has_frags(skb))
 			skb_drop_fraglist(skb);
 
+		if (skb_shinfo(skb)->destructor_arg) {
+			struct skb_ext_page *ext_page =
+				skb_shinfo(skb)->destructor_arg;
+			if (ext_page->dtor)
+				ext_page->dtor(ext_page);
+		}
+
 		kfree(skb->head);
 	}
 }
-- 
1.7.3

