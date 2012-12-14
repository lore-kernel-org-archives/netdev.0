From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] netlink: align attributes on 64-bits
Date: Fri, 14 Dec 2012 14:16:42 +0100
Message-ID: <1355491002-3931-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20121211184013.GD27746@casper.infradead.org>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	David.Laight@ACULAB.COM,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41787 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab2LNNTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 08:19:43 -0500
In-Reply-To: <20121211184013.GD27746@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 64 bits arch, we must ensure that attributes are always aligned on 64-bits
boundary. We do that by adding attributes of type 0, size 4 (alignment on
32-bits is already done) when needed. Attribute type 0 should be available and
unused in all netlink families.

Some callers of nlmsg_new() calculates the exact length of the attributes they
want to add to their netlink messages. Because we may add some unexpected
attributes type 0, we should take more room for that.

Note that I made the choice to align all kind of netlink attributes (even u8,
u16, ...) to simplify netlink API. Having two sort of nla_put() functions will
certainly be a source of wrong usage. Moreover, it ensures that all existing
code will be fine.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netlink.h |  9 +++++++++
 lib/nlattr.c          | 11 ++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 9690b0f..aeb9fba 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -492,6 +492,15 @@ static inline struct nlmsghdr *nlmsg_put_answer(struct sk_buff *skb,
  */
 static inline struct sk_buff *nlmsg_new(size_t payload, gfp_t flags)
 {
+	/* Because attributes may be aligned on 64-bits boundary with fake
+	 * attribute (type 0, size 4 (attributes are 32-bits align by default)),
+	 * an exact payload size cannot be calculated. Hence, we need to reserve
+	 * more space for these attributes.
+	 * 128 is arbitrary: it allows to align up to 32 attributes.
+	 */
+	if (sizeof(void *) > 4 && payload < NLMSG_DEFAULT_SIZE)
+		payload = min(payload + 128, (size_t)NLMSG_DEFAULT_SIZE);
+
 	return alloc_skb(nlmsg_total_size(payload), flags);
 }
 
diff --git a/lib/nlattr.c b/lib/nlattr.c
index 18eca78..29ace9f 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -450,9 +450,18 @@ EXPORT_SYMBOL(__nla_put_nohdr);
  */
 int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
 {
-	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
+	int align = IS_ALIGNED((unsigned long)skb_tail_pointer(skb), sizeof(void *)) ? 0 : 4;
+
+	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen) + align))
 		return -EMSGSIZE;
 
+	if (align) {
+		/* Goal is to add an attribute with size 4. We know that
+		 * NLA_HDRLEN is 4, hence payload is 0.
+		 */
+		__nla_reserve(skb, 0, 0);
+	}
+
 	__nla_put(skb, attrtype, attrlen, data);
 	return 0;
 }
-- 
1.8.0.1
