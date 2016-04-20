From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/4] libnl: add more helpers to align attribute on 64-bit
Date: Wed, 20 Apr 2016 10:57:33 +0200
Message-ID: <1461142655-5067-3-git-send-email-nicolas.dichtel@6wind.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
 <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:56432 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932680AbcDTI5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 04:57:52 -0400
In-Reply-To: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add use it to align IFLA_STATS64.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netlink.h |   8 ++++
 lib/nlattr.c          | 107 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c  |   9 +----
 3 files changed, 117 insertions(+), 7 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 694caac31d2c..c01863b49787 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -244,13 +244,21 @@ int nla_memcpy(void *dest, const struct nlattr *src, int count);
 int nla_memcmp(const struct nlattr *nla, const void *data, size_t size);
 int nla_strcmp(const struct nlattr *nla, const char *str);
 struct nlattr *__nla_reserve(struct sk_buff *skb, int attrtype, int attrlen);
+struct nlattr *__nla_reserve_64bit(struct sk_buff *skb, int attrtype,
+				   int attrlen, int padattr);
 void *__nla_reserve_nohdr(struct sk_buff *skb, int attrlen);
 struct nlattr *nla_reserve(struct sk_buff *skb, int attrtype, int attrlen);
+struct nlattr *nla_reserve_64bit(struct sk_buff *skb, int attrtype,
+				 int attrlen, int padattr);
 void *nla_reserve_nohdr(struct sk_buff *skb, int attrlen);
 void __nla_put(struct sk_buff *skb, int attrtype, int attrlen,
 	       const void *data);
+void __nla_put_64bit(struct sk_buff *skb, int attrtype, int attrlen,
+		     const void *data, int padattr);
 void __nla_put_nohdr(struct sk_buff *skb, int attrlen, const void *data);
 int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
+int nla_put_64bit(struct sk_buff *skb, int attrtype, int attrlen,
+		  const void *data, int padattr);
 int nla_put_nohdr(struct sk_buff *skb, int attrlen, const void *data);
 int nla_append(struct sk_buff *skb, int attrlen, const void *data);
 
diff --git a/lib/nlattr.c b/lib/nlattr.c
index f5907d23272d..cc311b8b6ff0 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -355,6 +355,31 @@ struct nlattr *__nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
 EXPORT_SYMBOL(__nla_reserve);
 
 /**
+ * __nla_reserve_64bit - reserve room for attribute on the skb and align it
+ * @skb: socket buffer to reserve room on
+ * @attrtype: attribute type
+ * @attrlen: length of attribute payload
+ *
+ * Adds a netlink attribute header to a socket buffer and reserves
+ * room for the payload but does not copy it. It also ensure that this
+ * attribute will be 64-bit aign.
+ *
+ * The caller is responsible to ensure that the skb provides enough
+ * tailroom for the attribute header and payload.
+ */
+struct nlattr *__nla_reserve_64bit(struct sk_buff *skb, int attrtype,
+				   int attrlen, int padattr)
+{
+#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+	if (!IS_ALIGNED((unsigned long)skb->data, 8))
+		nla_align_64bit(skb, padattr);
+#endif
+
+	return __nla_reserve(skb, attrtype, attrlen);
+}
+EXPORT_SYMBOL(__nla_reserve_64bit);
+
+/**
  * __nla_reserve_nohdr - reserve room for attribute without header
  * @skb: socket buffer to reserve room on
  * @attrlen: length of attribute payload
@@ -397,6 +422,38 @@ struct nlattr *nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
 EXPORT_SYMBOL(nla_reserve);
 
 /**
+ * nla_reserve_64bit - reserve room for attribute on the skb and align it
+ * @skb: socket buffer to reserve room on
+ * @attrtype: attribute type
+ * @attrlen: length of attribute payload
+ *
+ * Adds a netlink attribute header to a socket buffer and reserves
+ * room for the payload but does not copy it. It also ensure that this
+ * attribute will be 64-bit aign.
+ *
+ * Returns NULL if the tailroom of the skb is insufficient to store
+ * the attribute header and payload.
+ */
+struct nlattr *nla_reserve_64bit(struct sk_buff *skb, int attrtype, int attrlen,
+				 int padattr)
+{
+	size_t len;
+
+#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+	if (!IS_ALIGNED((unsigned long)skb->data, 8))
+		len = nla_total_size_64bit(attrlen);
+	else
+#endif
+		len = nla_total_size(attrlen);
+
+	if (unlikely(skb_tailroom(skb) < len))
+		return NULL;
+
+	return __nla_reserve_64bit(skb, attrtype, attrlen, padattr);
+}
+EXPORT_SYMBOL(nla_reserve_64bit);
+
+/**
  * nla_reserve_nohdr - reserve room for attribute without header
  * @skb: socket buffer to reserve room on
  * @attrlen: length of attribute payload
@@ -436,6 +493,26 @@ void __nla_put(struct sk_buff *skb, int attrtype, int attrlen,
 EXPORT_SYMBOL(__nla_put);
 
 /**
+ * __nla_put_64bit - Add a netlink attribute to a socket buffer and align it
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @attrlen: length of attribute payload
+ * @data: head of attribute payload
+ *
+ * The caller is responsible to ensure that the skb provides enough
+ * tailroom for the attribute header and payload.
+ */
+void __nla_put_64bit(struct sk_buff *skb, int attrtype, int attrlen,
+		     const void *data, int padattr)
+{
+	struct nlattr *nla;
+
+	nla = __nla_reserve_64bit(skb, attrtype, attrlen, padattr);
+	memcpy(nla_data(nla), data, attrlen);
+}
+EXPORT_SYMBOL(__nla_put_64bit);
+
+/**
  * __nla_put_nohdr - Add a netlink attribute without header
  * @skb: socket buffer to add attribute to
  * @attrlen: length of attribute payload
@@ -474,6 +551,36 @@ int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
 EXPORT_SYMBOL(nla_put);
 
 /**
+ * nla_put_64bit - Add a netlink attribute to a socket buffer and align it
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @attrlen: length of attribute payload
+ * @data: head of attribute payload
+ *
+ * Returns -EMSGSIZE if the tailroom of the skb is insufficient to store
+ * the attribute header and payload.
+ */
+int nla_put_64bit(struct sk_buff *skb, int attrtype, int attrlen,
+		  const void *data, int padattr)
+{
+	size_t len;
+
+#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+	if (!IS_ALIGNED((unsigned long)skb->data, 8))
+		len = nla_total_size_64bit(attrlen);
+	else
+#endif
+		len = nla_total_size(attrlen);
+
+	if (unlikely(skb_tailroom(skb) < len))
+		return -EMSGSIZE;
+
+	__nla_put_64bit(skb, attrtype, attrlen, data, padattr);
+	return 0;
+}
+EXPORT_SYMBOL(nla_put_64bit);
+
+/**
  * nla_put_nohdr - Add a netlink attribute without header
  * @skb: socket buffer to add attribute to
  * @attrlen: length of attribute payload
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d3694a13c85a..24cd21273383 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1051,14 +1051,9 @@ static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 {
 	struct rtnl_link_stats64 *sp;
 	struct nlattr *attr;
-	int err;
-
-	err = nla_align_64bit(skb, IFLA_PAD);
-	if (err)
-		return err;
 
-	attr = nla_reserve(skb, IFLA_STATS64,
-			   sizeof(struct rtnl_link_stats64));
+	attr = nla_reserve_64bit(skb, IFLA_STATS64,
+				 sizeof(struct rtnl_link_stats64), IFLA_PAD);
 	if (!attr)
 		return -EMSGSIZE;
 
-- 
2.4.2
