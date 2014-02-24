From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 01/13] skbuff: Introduce skb_to_sgvec_nomark to map skb without mark new end
Date: Mon, 24 Feb 2014 10:59:49 +0100
Message-ID: <1393236001-2445-2-git-send-email-steffen.klassert@secunet.com>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39099 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685AbaBXKAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:11 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

As compared with skb_to_sgvec, skb_to_sgvec_nomark only map skb to given sglist
without mark the sg which contain last skb data as the end. So the caller can
mannipulate sg list as will when padding new data after the first call without
calling sg_unmark_end to expend sg list.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/skbuff.h |    2 ++
 net/core/skbuff.c      |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f589c9a..c574bf3 100644
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
index 5976ef0..f28c379 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3281,6 +3281,32 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
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
