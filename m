From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv5 net-next 1/6] skbuff: Introduce skb_to_sgvec_nomark to map skb without mark new end
Date: Sat, 18 Jan 2014 09:54:23 +0800
Message-ID: <1390010068-15715-2-git-send-email-fan.du@windriver.com>
References: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33191 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912AbaARByf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 20:54:35 -0500
In-Reply-To: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As compared with skb_to_sgvec, skb_to_sgvec_nomark only map skb to given sglist
without mark the sg which contain last skb data as the end. So the caller can
mannipulate sg list as will when padding new data after the first call without
calling sg_unmark_end to expend sg list.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/linux/skbuff.h |    2 ++
 net/core/skbuff.c      |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1f689e6..4fd28cc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -691,6 +691,8 @@ struct sk_buff *skb_realloc_headroom(struct sk_buff *skb,
 				     unsigned int headroom);
 struct sk_buff *skb_copy_expand(const struct sk_buff *skb, int newheadroom,
 				int newtailroom, gfp_t priority);
+int skb_to_sgvec_nomark(struct sk_buff *skb, struct scatterlist *sg,
+			int offset, int len);
 int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset,
 		 int len);
 int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 15057d2..19387c7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3309,6 +3309,32 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 	return elt;
 }
 
+/* As compared with skb_to_sgvec, skb_to_sgvec_nomark only map skb to given
+ * sglist without mark the sg which contain last skb data as the end.
+ * So the caller can mannipulate sg list as will when padding new data after
+ * the first call without calling sg_unmark_end to expend sg list.
+ *
+ * Scenario to use skb_to_sgvec_nomark:
+ * 1. sg_init_table
+ * 2. skb_to_sgvec_nomark(payload1)
+ * 3. skb_to_sgvec_nomark(payload2)
+ *
+ * This is equivalent to:
+ * 1. sg_init_table
+ * 2. skb_to_sgvec(payload1)
+ * 3. sg_unmark_end
+ * 4. skb_to_sgvec(payload2)
+ *
+ * When mapping mutilple payload conditionally, skb_to_sgvec_nomark
+ * is more preferable.
+ */
+int skb_to_sgvec_nomark(struct sk_buff *skb, struct scatterlist *sg,
+			int offset, int len)
+{
+	return __skb_to_sgvec(skb, sg, offset, len);
+}
+EXPORT_SYMBOL_GPL(skb_to_sgvec_nomark);
+
 int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 {
 	int nsg = __skb_to_sgvec(skb, sg, offset, len);
-- 
1.7.9.5
