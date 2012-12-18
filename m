From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2] netlink: align attributes on 64-bits
Date: Tue, 18 Dec 2012 12:57:35 +0000
Message-ID: <20121218125735.GG27746@casper.infradead.org>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
 <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	davem@davemloft.net, David.Laight@ACULAB.COM
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59406 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006Ab2LRM5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 07:57:43 -0500
Content-Disposition: inline
In-Reply-To: <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/12 at 05:49pm, Nicolas Dichtel wrote:
> @@ -492,6 +492,15 @@ static inline struct nlmsghdr *nlmsg_put_answer(struct sk_buff *skb,
>   */
>  static inline struct sk_buff *nlmsg_new(size_t payload, gfp_t flags)
>  {
> +	/* Because attributes may be aligned on 64-bits boundary with fake
> +	 * attribute (type 0, size 4 (attributes are 32-bits align by default)),
> +	 * an exact payload size cannot be calculated. Hence, we need to reserve
> +	 * more space for these attributes.
> +	 * 128 is arbitrary: it allows to align up to 32 attributes.
> +	 */
> +	if (payload < NLMSG_DEFAULT_SIZE)
> +		payload = min(payload + 128, (size_t)NLMSG_DEFAULT_SIZE);

This is doomed to fail eventually. A netlink message may carry
hundreds of attributes eventually. See my suggestion below.

> diff --git a/lib/nlattr.c b/lib/nlattr.c
> index 18eca78..7440a80 100644
> --- a/lib/nlattr.c
> +++ b/lib/nlattr.c
> @@ -450,9 +450,18 @@ EXPORT_SYMBOL(__nla_put_nohdr);
>   */
>  int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
>  {
> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
> +	int align = IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8) ? 0 : 4;

This does not look right. In order for the attribute data to be
aligned properly you would need to check skb_tail_pointer(skb) +
NLA_HDRLEN for proper alignment or you end up aligning the
attribute header.

How about we change nla_total_size() to return the size with
needed padding taken into account. That should fix the message
size caluclation problem and we only need to reserve room for
the initial padding to align the very first attribute.

Below is an untested patch that does this. What do you think?

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 9690b0f..7ce8e76 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -114,7 +114,6 @@
  * Attribute Length Calculations:
  *   nla_attr_size(payload)		length of attribute w/o padding
  *   nla_total_size(payload)		length of attribute w/ padding
- *   nla_padlen(payload)		length of padding
  *
  * Attribute Payload Access:
  *   nla_data(nla)			head of attribute payload
@@ -492,6 +491,14 @@ static inline struct nlmsghdr *nlmsg_put_answer(struct sk_buff *skb,
  */
 static inline struct sk_buff *nlmsg_new(size_t payload, gfp_t flags)
 {
+	/* If an exact size if specified, reserve some additional space to
+	 * align the first attribute, all subsequent attributes should have
+	 * padding accounted for.
+	 */
+	if (payload != NLMSG_DEFAULT_SIZE)
+		payload = min_t(size_t, payload + NLA_ATTR_ALIGN,
+				NLMSG_DEFAULT_SIZE);
+
 	return alloc_skb(nlmsg_total_size(payload), flags);
 }
 
@@ -653,16 +660,12 @@ static inline int nla_attr_size(int payload)
  */
 static inline int nla_total_size(int payload)
 {
-	return NLA_ALIGN(nla_attr_size(payload));
-}
+	size_t len = NLA_ALIGN(nla_attr_size(payload));
 
-/**
- * nla_padlen - length of padding at the tail of attribute
- * @payload: length of payload
- */
-static inline int nla_padlen(int payload)
-{
-	return nla_total_size(payload) - nla_attr_size(payload);
+	if (!IS_ALIGNED(len, NLA_ATTR_ALIGN))
+		len = ALIGN(len + NLA_HDRLEN, NLA_ATTR_ALIGN);
+
+	return len;
 }
 
 /**
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 78d5b8a..1856729 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -149,5 +149,10 @@ struct nlattr {
 #define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
 #define NLA_HDRLEN		((int) NLA_ALIGN(sizeof(struct nlattr)))
 
+/* Padding attribute type, added automatically to align attributes,
+ * must be ignored by readers. */
+#define NLA_PADDING		0
+#define NLA_ATTR_ALIGN		8
+
 
 #endif /* _UAPI__LINUX_NETLINK_H */
diff --git a/lib/nlattr.c b/lib/nlattr.c
index 18eca78..b09473c 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -322,18 +322,36 @@ int nla_strcmp(const struct nlattr *nla, const char *str)
  * Adds a netlink attribute header to a socket buffer and reserves
  * room for the payload but does not copy it.
  *
+ * May add a padding attribute of type NLA_PADDING before the
+ * real attribute to ensure proper alignment.
+ *
  * The caller is responsible to ensure that the skb provides enough
  * tailroom for the attribute header and payload.
  */
 struct nlattr *__nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
 {
 	struct nlattr *nla;
+	size_t offset;
+
+	offset = (size_t) skb_tail_pointer(skb);
+	if (!IS_ALIGNED(offset + NLA_HDRLEN, NLA_ATTR_ALIGN)) {
+		struct nlattr *pad;
+		size_t padlen;
+
+		padlen = nla_total_size(offset) - offset - NLA_HDRLEN;
+		pad = (struct nlattr *) skb_put(skb, nla_attr_size(padlen));
+		pad->nla_type = 0;
+		pad->nla_len = nla_attr_size(padlen);
+
+		memset((unsigned char *) pad + NLA_HDRLEN, 0, padlen);
+	}
 
-	nla = (struct nlattr *) skb_put(skb, nla_total_size(attrlen));
+	nla = (struct nlattr *) skb_put(skb, NLA_ALIGN(nla_attr_size(attrlen)));
 	nla->nla_type = attrtype;
 	nla->nla_len = nla_attr_size(attrlen);
 
-	memset((unsigned char *) nla + nla->nla_len, 0, nla_padlen(attrlen));
+	memset((unsigned char *) nla + nla->nla_len, 0,
+	       NLA_ALIGN(nla->nla_len) - nla->nla_len);
 
 	return nla;
 }
@@ -360,6 +378,23 @@ void *__nla_reserve_nohdr(struct sk_buff *skb, int attrlen)
 }
 EXPORT_SYMBOL(__nla_reserve_nohdr);
 
+static size_t nla_pre_padlen(struct sk_buff *skb)
+{
+	size_t offset = (size_t) skb_tail_pointer(skb);
+
+	if (!IS_ALIGNED(offset + NLA_HDRLEN, NLA_ATTR_ALIGN))
+		return nla_total_size(offset) - offset - NLA_HDRLEN;
+
+	return 0;
+}
+
+static bool nla_insufficient_space(struct sk_buff *skb, int attrlen)
+{
+	size_t needed = nla_pre_padlen(skb) + nla_total_size(attrlen);
+
+	return (skb_tailroom(skb) < needed);
+}
+
 /**
  * nla_reserve - reserve room for attribute on the skb
  * @skb: socket buffer to reserve room on
@@ -374,7 +409,7 @@ EXPORT_SYMBOL(__nla_reserve_nohdr);
  */
 struct nlattr *nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
 {
-	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
+	if (unlikely(nla_insufficient_space(skb, attrlen)))
 		return NULL;
 
 	return __nla_reserve(skb, attrtype, attrlen);
@@ -450,7 +485,7 @@ EXPORT_SYMBOL(__nla_put_nohdr);
  */
 int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
 {
-	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
+	if (unlikely(nla_insufficient_space(skb, attrlen)))
 		return -EMSGSIZE;
 
 	__nla_put(skb, attrtype, attrlen, data);
