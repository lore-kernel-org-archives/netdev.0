From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2] netlink: align attributes on 64-bits
Date: Mon, 17 Dec 2012 17:49:40 +0100
Message-ID: <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
Cc: tgraf@suug.ch, netdev@vger.kernel.org, davem@davemloft.net,
	David.Laight@ACULAB.COM,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44727 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159Ab2LQQx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 11:53:56 -0500
In-Reply-To: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must ensure that attributes are always aligned on 64-bits boundary because
some arch may trap when accessing unaligned 64 bits value. We do that by adding
attributes of type 0, size 4 (alignment on 32-bits is already done) when needed.
Attribute type 0 should be available and unused in all netlink families.

Some callers of nlmsg_new() calculates the exact length of the attributes they
want to add to their netlink messages. Because we may add some unexpected
attributes type 0, we should take more room for that.

Note that I made the choice to align all kind of netlink attributes (even u8,
u16, ...) to simplify netlink API. Having two sort of nla_put() functions will
certainly be a source of wrong usage. Moreover, it ensures that all existing
code will be fine.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: align attributes on all arch, not only on 64-bits arch

 include/net/netlink.h |  9 +++++++++
 lib/nlattr.c          | 11 ++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 9690b0f..bd9e48f 100644
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
+	if (payload < NLMSG_DEFAULT_SIZE)
+		payload = min(payload + 128, (size_t)NLMSG_DEFAULT_SIZE);
+
 	return alloc_skb(nlmsg_total_size(payload), flags);
 }
 
diff --git a/lib/nlattr.c b/lib/nlattr.c
index 18eca78..7440a80 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -450,9 +450,18 @@ EXPORT_SYMBOL(__nla_put_nohdr);
  */
 int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
 {
-	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
+	int align = IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8) ? 0 : 4;
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
