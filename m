From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 1/4] libnl: add more helpers to align attributes on 64-bit
Date: Thu, 21 Apr 2016 18:58:24 +0200
Message-ID: <1461257907-4458-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:52622 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbcDUQ6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 12:58:48 -0400
In-Reply-To: <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netlink.h | 39 +++++++++++++++-----
 lib/nlattr.c          | 99 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 130 insertions(+), 8 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 3c1fd92a52c8..6f51a8a06498 100644
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
 
@@ -1231,6 +1239,27 @@ static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
 }
 
 /**
+ * nla_need_padding_for_64bit - test 64-bit alignment of the next attribute
+ * @skb: socket buffer the message is stored in
+ *
+ * Return true if padding is needed to align the next attribute (nla_data()) to
+ * a 64-bit aligned area.
+ */
+static inline bool nla_need_padding_for_64bit(struct sk_buff *skb)
+{
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	/* The nlattr header is 4 bytes in size, that's why we test
+	 * if the skb->data _is_ aligned.  A NOP attribute, plus
+	 * nlattr header for next attribute, will make nla_data()
+	 * 8-byte aligned.
+	 */
+	if (IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8))
+		return true;
+#endif
+	return false;
+}
+
+/**
  * nla_align_64bit - 64-bit align the nla_data() of next attribute
  * @skb: socket buffer the message is stored in
  * @padattr: attribute type for the padding
@@ -1244,16 +1273,10 @@ static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
  */
 static inline int nla_align_64bit(struct sk_buff *skb, int padattr)
 {
-#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-	/* The nlattr header is 4 bytes in size, that's why we test
-	 * if the skb->data _is_ aligned.  This NOP attribute, plus
-	 * nlattr header for next attribute, will make nla_data()
-	 * 8-byte aligned.
-	 */
-	if (IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8) &&
+	if (nla_need_padding_for_64bit(skb) &&
 	    !nla_reserve(skb, padattr, 0))
 		return -EMSGSIZE;
-#endif
+
 	return 0;
 }
 
diff --git a/lib/nlattr.c b/lib/nlattr.c
index f5907d23272d..2b82f1e2ebc2 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -355,6 +355,29 @@ struct nlattr *__nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
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
+	if (nla_need_padding_for_64bit(skb))
+		nla_align_64bit(skb, padattr);
+
+	return __nla_reserve(skb, attrtype, attrlen);
+}
+EXPORT_SYMBOL(__nla_reserve_64bit);
+
+/**
  * __nla_reserve_nohdr - reserve room for attribute without header
  * @skb: socket buffer to reserve room on
  * @attrlen: length of attribute payload
@@ -397,6 +420,35 @@ struct nlattr *nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
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
+	if (nla_need_padding_for_64bit(skb))
+		len = nla_total_size_64bit(attrlen);
+	else
+		len = nla_total_size(attrlen);
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
@@ -436,6 +488,26 @@ void __nla_put(struct sk_buff *skb, int attrtype, int attrlen,
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
@@ -474,6 +546,33 @@ int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
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
+	if (nla_need_padding_for_64bit(skb))
+		len = nla_total_size_64bit(attrlen);
+	else
+		len = nla_total_size(attrlen);
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
-- 
2.4.2
