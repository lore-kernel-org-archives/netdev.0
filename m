From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/9] [NETLINK]: Extend netlink messaging interface
Date: Sat, 05 Aug 2006 00:00:01 +0200
Message-ID: <20060805003535.507943887@postel.suug.ch>
References: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:4589 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422674AbWHEAnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:43:04 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_api
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds:
 nlmsg_get_pos()                 return current position in message
 nlmsg_trim()                    trim part of message
 nla_reserve_nohdr(skb, len)     reserve room for an attribute w/o hdr
 nla_put_nohdr(skb, len, data)   add attribute w/o hdr
 nla_find_nested()               find attribute in nested attributes

Fixes nlmsg_new() to take allocation flags and consider size.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/include/net/netlink.h
===================================================================
--- net-2.6.19.orig/include/net/netlink.h
+++ net-2.6.19/include/net/netlink.h
@@ -35,6 +35,8 @@
  *   nlmsg_put()			add a netlink message to an skb
  *   nlmsg_put_answer()			callback based nlmsg_put()
  *   nlmsg_end()			finanlize netlink message
+ *   nlmsg_get_pos()			return current position in message
+ *   nlmsg_trim()			trim part of message
  *   nlmsg_cancel()			cancel message construction
  *   nlmsg_free()			free a netlink message
  *
@@ -80,8 +82,10 @@
  *   struct nlattr			netlink attribtue header
  *
  * Attribute Construction:
- *   nla_reserve(skb, type, len)	reserve skb tailroom for an attribute
+ *   nla_reserve(skb, type, len)	reserve room for an attribute
+ *   nla_reserve_nohdr(skb, len)	reserve room for an attribute w/o hdr
  *   nla_put(skb, type, len, data)	add attribute to skb
+ *   nla_put_nohdr(skb, len, data)	add attribute w/o hdr
  *
  * Attribute Construction for Basic Types:
  *   nla_put_u8(skb, type, value)	add u8 attribute to skb
@@ -139,6 +143,7 @@
  *   nla_next(nla, remaining)		get next netlink attribute
  *   nla_validate()			validate a stream of attributes
  *   nla_find()				find attribute in stream of attributes
+ *   nla_find_nested()			find attribute in nested attributes
  *   nla_parse()			parse and validate stream of attrs
  *   nla_parse_nested()			parse nested attribuets
  *   nla_for_each_attr()		loop over all attributes
@@ -203,12 +208,18 @@ extern int		nla_memcmp(const struct nlat
 extern int		nla_strcmp(const struct nlattr *nla, const char *str);
 extern struct nlattr *	__nla_reserve(struct sk_buff *skb, int attrtype,
 				      int attrlen);
+extern void *		__nla_reserve_nohdr(struct sk_buff *skb, int attrlen);
 extern struct nlattr *	nla_reserve(struct sk_buff *skb, int attrtype,
 				    int attrlen);
+extern void *		nla_reserve_nohdr(struct sk_buff *skb, int attrlen);
 extern void		__nla_put(struct sk_buff *skb, int attrtype,
 				  int attrlen, const void *data);
+extern void		__nla_put_nohdr(struct sk_buff *skb, int attrlen,
+					const void *data);
 extern int		nla_put(struct sk_buff *skb, int attrtype,
 				int attrlen, const void *data);
+extern int		nla_put_nohdr(struct sk_buff *skb, int attrlen,
+				      const void *data);
 
 /**************************************************************************
  * Netlink Messages
@@ -453,12 +464,13 @@ static inline struct nlmsghdr *nlmsg_put
 /**
  * nlmsg_new - Allocate a new netlink message
  * @size: maximum size of message
+ * @flags: the type of memory to allocate.
  *
  * Use NLMSG_GOODSIZE if size isn't know and you need a good default size.
  */
-static inline struct sk_buff *nlmsg_new(int size)
+static inline struct sk_buff *nlmsg_new(int size, gfp_t flags)
 {
-	return alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	return alloc_skb(size, flags);
 }
 
 /**
@@ -480,6 +492,32 @@ static inline int nlmsg_end(struct sk_bu
 }
 
 /**
+ * nlmsg_get_pos - return current position in netlink message
+ * @skb: socket buffer the message is stored in
+ *
+ * Returns a pointer to the current tail of the message.
+ */
+static inline void *nlmsg_get_pos(struct sk_buff *skb)
+{
+	return skb->tail;
+}
+
+/**
+ * nlmsg_trim - Trim message to a mark
+ * @skb: socket buffer the message is stored in
+ * @mark: mark to trim to
+ *
+ * Trims the message to the provided mark. Returns -1.
+ */
+static inline int nlmsg_trim(struct sk_buff *skb, void *mark)
+{
+	if (mark)
+		skb_trim(skb, (unsigned char *) mark - skb->data);
+
+	return -1;
+}
+
+/**
  * nlmsg_cancel - Cancel construction of a netlink message
  * @skb: socket buffer the message is stored in
  * @nlh: netlink message header
@@ -489,9 +527,7 @@ static inline int nlmsg_end(struct sk_bu
  */
 static inline int nlmsg_cancel(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	skb_trim(skb, (unsigned char *) nlh - skb->data);
-
-	return -1;
+	return nlmsg_trim(skb, nlh);
 }
 
 /**
@@ -631,6 +667,18 @@ static inline struct nlattr *nla_next(co
 }
 
 /**
+ * nla_find_nested - find attribute in a set of nested attributes
+ * @nla: attribute containing the nested attributes
+ * @attrtype: type of attribute to look for
+ *
+ * Returns the first attribute which matches the specified type.
+ */
+static inline struct nlattr *nla_find_nested(struct nlattr *nla, int attrtype)
+{
+	return nla_find(nla_data(nla), nla_len(nla), attrtype);
+}
+
+/**
  * nla_parse_nested - parse nested attributes
  * @tb: destination array with maxtype+1 elements
  * @maxtype: maximum attribute type to be expected
@@ -862,10 +910,7 @@ static inline int nla_nest_end(struct sk
  */
 static inline int nla_nest_cancel(struct sk_buff *skb, struct nlattr *start)
 {
-	if (start)
-		skb_trim(skb, (unsigned char *) start - skb->data);
-
-	return -1;
+	return nlmsg_trim(skb, start);
 }
 
 /**
@@ -880,4 +925,13 @@ static inline int nla_nest_cancel(struct
 	     nla_ok(pos, rem); \
 	     pos = nla_next(pos, &(rem)))
 
+/**
+ * nla_for_each_nested - iterate over nested attributes
+ * @pos: loop counter, set to current attribute
+ * @nla: attribute containing the nested attributes
+ * @rem: initialized to len, holds bytes currently remaining in stream
+ */
+#define nla_for_each_nested(pos, nla, rem) \
+	nla_for_each_attr(pos, nla_data(nla), nla_len(nla), rem)
+
 #endif
Index: net-2.6.19/net/netlink/attr.c
===================================================================
--- net-2.6.19.orig/net/netlink/attr.c
+++ net-2.6.19/net/netlink/attr.c
@@ -255,6 +255,26 @@ struct nlattr *__nla_reserve(struct sk_b
 }
 
 /**
+ * __nla_reserve_nohdr - reserve room for attribute without header
+ * @skb: socket buffer to reserve room on
+ * @attrlen: length of attribute payload
+ *
+ * Reserves room for attribute payload without a header.
+ *
+ * The caller is responsible to ensure that the skb provides enough
+ * tailroom for the payload.
+ */
+void *__nla_reserve_nohdr(struct sk_buff *skb, int attrlen)
+{
+	void *start;
+
+	start = skb_put(skb, NLA_ALIGN(attrlen));
+	memset(start, 0, NLA_ALIGN(attrlen));
+
+	return start;
+}
+
+/**
  * nla_reserve - reserve room for attribute on the skb
  * @skb: socket buffer to reserve room on
  * @attrtype: attribute type
@@ -275,6 +295,24 @@ struct nlattr *nla_reserve(struct sk_buf
 }
 
 /**
+ * nla_reserve - reserve room for attribute without header
+ * @skb: socket buffer to reserve room on
+ * @len: length of attribute payload
+ *
+ * Reserves room for attribute payload without a header.
+ *
+ * Returns NULL if the tailroom of the skb is insufficient to store
+ * the attribute payload.
+ */
+void *nla_reserve_nohdr(struct sk_buff *skb, int attrlen)
+{
+	if (unlikely(skb_tailroom(skb) < NLA_ALIGN(attrlen)))
+		return NULL;
+
+	return __nla_reserve_nohdr(skb, attrlen);
+}
+
+/**
  * __nla_put - Add a netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
@@ -293,6 +331,22 @@ void __nla_put(struct sk_buff *skb, int 
 	memcpy(nla_data(nla), data, attrlen);
 }
 
+/**
+ * __nla_put_nohdr - Add a netlink attribute without header
+ * @skb: socket buffer to add attribute to
+ * @attrlen: length of attribute payload
+ * @data: head of attribute payload
+ *
+ * The caller is responsible to ensure that the skb provides enough
+ * tailroom for the attribute payload.
+ */
+void __nla_put_nohdr(struct sk_buff *skb, int attrlen, const void *data)
+{
+	void *start;
+
+	start = __nla_reserve_nohdr(skb, attrlen);
+	memcpy(start, data, attrlen);
+}
 
 /**
  * nla_put - Add a netlink attribute to a socket buffer
@@ -313,15 +367,36 @@ int nla_put(struct sk_buff *skb, int att
 	return 0;
 }
 
+/**
+ * nla_put_nohdr - Add a netlink attribute without header
+ * @skb: socket buffer to add attribute to
+ * @attrlen: length of attribute payload
+ * @data: head of attribute payload
+ *
+ * Returns -1 if the tailroom of the skb is insufficient to store
+ * the attribute payload.
+ */
+int nla_put_nohdr(struct sk_buff *skb, int attrlen, const void *data)
+{
+	if (unlikely(skb_tailroom(skb) < NLA_ALIGN(attrlen)))
+		return -1;
+
+	__nla_put_nohdr(skb, attrlen, data);
+	return 0;
+}
 
 EXPORT_SYMBOL(nla_validate);
 EXPORT_SYMBOL(nla_parse);
 EXPORT_SYMBOL(nla_find);
 EXPORT_SYMBOL(nla_strlcpy);
 EXPORT_SYMBOL(__nla_reserve);
+EXPORT_SYMBOL(__nla_reserve_nohdr);
 EXPORT_SYMBOL(nla_reserve);
+EXPORT_SYMBOL(nla_reserve_nohdr);
 EXPORT_SYMBOL(__nla_put);
+EXPORT_SYMBOL(__nla_put_nohdr);
 EXPORT_SYMBOL(nla_put);
+EXPORT_SYMBOL(nla_put_nohdr);
 EXPORT_SYMBOL(nla_memcpy);
 EXPORT_SYMBOL(nla_memcmp);
 EXPORT_SYMBOL(nla_strcmp);
Index: net-2.6.19/kernel/taskstats.c
===================================================================
--- net-2.6.19.orig/kernel/taskstats.c
+++ net-2.6.19/kernel/taskstats.c
@@ -75,7 +75,7 @@ static int prepare_reply(struct genl_inf
 	/*
 	 * If new attributes are added, please revisit this allocation
 	 */
-	skb = nlmsg_new(size);
+	skb = nlmsg_new(size, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 
Index: net-2.6.19/net/netlink/genetlink.c
===================================================================
--- net-2.6.19.orig/net/netlink/genetlink.c
+++ net-2.6.19/net/netlink/genetlink.c
@@ -440,7 +440,7 @@ static struct sk_buff *ctrl_build_msg(st
 	struct sk_buff *skb;
 	int err;
 
-	skb = nlmsg_new(NLMSG_GOODSIZE);
+	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
 		return ERR_PTR(-ENOBUFS);
 

