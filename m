From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCHv1 net-next 1/5] netlink: mmap: introduce mmaped skb helper
 functions
Date: Wed, 12 Aug 2015 17:31:04 +0900
Message-ID: <20150812083103.GB13385@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33486 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933560AbbHLIbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 04:31:09 -0400
Received: by pdrh1 with SMTP id h1so5053966pdr.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 01:31:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150812082824.GA13385@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that we need helper functions for skb which is allocated
at netlink_alloc_skb() since it does not have skb_shared_info.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 include/linux/netlink.h  |   21 +++++-------------
 net/netlink/af_netlink.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+), 16 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 9120edb..60492bf 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -70,6 +70,11 @@ extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 					 u32 dst_portid, gfp_t gfp_mask);
+extern struct sk_buff *netlink_skb_copy(const struct sk_buff *skb, gfp_t gfp_mask);
+extern struct sk_buff *netlink_skb_clone(struct sk_buff *skb, gfp_t gfp_mask);
+extern void netlink_free_skb(struct sk_buff *skb);
+void netlink_consume_skb(struct sk_buff *skb);
+
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
 			     __u32 group, gfp_t allocation);
@@ -88,22 +93,6 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 
-static inline struct sk_buff *
-netlink_skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
-{
-	struct sk_buff *nskb;
-
-	nskb = skb_clone(skb, gfp_mask);
-	if (!nskb)
-		return NULL;
-
-	/* This is a large skb, set destructor callback to release head */
-	if (is_vmalloc_addr(skb->head))
-		nskb->destructor = skb->destructor;
-
-	return nskb;
-}
-
 /*
  *	skb should fit one page. This choice is good for headerless malloc.
  *	But we should limit to 8K so that userspace does not have to
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d8e2e39..98ed579 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1894,6 +1894,61 @@ out:
 }
 EXPORT_SYMBOL_GPL(netlink_alloc_skb);
 
+struct sk_buff *netlink_skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
+{
+#ifdef CONFIG_NETLINK_MMAP
+	if (netlink_skb_is_mmaped(skb)) {
+		struct sk_buff *n = alloc_skb(skb->len, gfp_mask);
+		if (!n)
+			return NULL;
+
+		skb_put(n, skb->len);
+		NETLINK_CB(n).portid = NETLINK_CB(skb).portid;
+		memcpy(n->data, skb->data, skb->len);
+		return n;
+	} else
+#endif
+		return skb_copy(skb, gfp_mask);
+}
+EXPORT_SYMBOL_GPL(netlink_skb_copy);
+
+struct sk_buff *netlink_skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
+{
+	struct sk_buff *nskb;
+
+#ifdef CONFIG_NETLINK_MMAP
+	if (netlink_skb_is_mmaped(skb))
+		return netlink_skb_copy(skb, gfp_mask);
+#endif
+	nskb = skb_clone(skb, gfp_mask);
+	if (!nskb)
+		return NULL;
+
+	/* This is a large skb, set destructor callback to release head */
+	if (is_vmalloc_addr(skb->head))
+		nskb->destructor = skb->destructor;
+
+	return nskb;
+}
+EXPORT_SYMBOL_GPL(netlink_skb_clone);
+
+void netlink_free_skb(struct sk_buff *skb)
+{
+	kfree_skb_partial(skb, netlink_skb_is_mmaped(skb));
+}
+EXPORT_SYMBOL_GPL(netlink_free_skb);
+
+void netlink_consume_skb(struct sk_buff *skb)
+{
+#ifdef CONFIG_NETLINK_MMAP
+	if (netlink_skb_is_mmaped(skb))
+		kfree_skb_partial(skb, true);
+	else
+#endif
+		consume_skb(skb);
+}
+EXPORT_SYMBOL_GPL(netlink_consume_skb);
+
 int netlink_has_listeners(struct sock *sk, unsigned int group)
 {
 	int res = 0;
-- 
1.7.10.4
