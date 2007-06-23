From: Patrick McHardy <kaber@trash.net>
Subject: [NETLINK]: attr: add nested compat attribute type
Date: Sat, 23 Jun 2007 11:26:49 +0200
Message-ID: <467CE759.3070003@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000009010205040809010202"
Cc: Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49656 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbXFWJ04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 05:26:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000009010205040809010202
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Add support for the nested compat attribute type to netlink.

Thomas, I forgot to CC you on the related rtnetlink/iproute
patches, please have a look on netdev.


--------------000009010205040809010202
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETLINK]: attr: add nested compat attribute type

Add a nested compat attribute type that can be used to convert
attributes that contain a structure to nested attributes in a
backwards compatible way.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit fb99bf7aa7d9dd2af24d75d3a574ef17c4bae079
tree 4373b1c05a23d2544e7f53a9769ccc973ab913f7
parent 82a7e0e31d94515507be3ed8ac8e7866ab9ab928
author Patrick McHardy <kaber@trash.net> Sat, 23 Jun 2007 11:24:26 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 23 Jun 2007 11:24:26 +0200

 include/net/netlink.h |   84 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/netlink/attr.c    |   11 ++++++
 2 files changed, 95 insertions(+), 0 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 7b510a9..d7b824b 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -118,6 +118,9 @@
  * Nested Attributes Construction:
  *   nla_nest_start(skb, type)		start a nested attribute
  *   nla_nest_end(skb, nla)		finalize a nested attribute
+ *   nla_nest_compat_start(skb, type,	start a nested compat attribute
+ *			   len, data)
+ *   nla_nest_compat_end(skb, type)	finalize a nested compat attribute
  *   nla_nest_cancel(skb, nla)		cancel nested attribute construction
  *
  * Attribute Length Calculations:
@@ -152,6 +155,7 @@
  *   nla_find_nested()			find attribute in nested attributes
  *   nla_parse()			parse and validate stream of attrs
  *   nla_parse_nested()			parse nested attribuets
+ *   nla_parse_nested_compat()		parse nested compat attributes
  *   nla_for_each_attr()		loop over all attributes
  *   nla_for_each_nested()		loop over the nested attributes
  *=========================================================================
@@ -170,6 +174,7 @@ enum {
 	NLA_FLAG,
 	NLA_MSECS,
 	NLA_NESTED,
+	NLA_NESTED_COMPAT,
 	NLA_NUL_STRING,
 	NLA_BINARY,
 	__NLA_TYPE_MAX,
@@ -190,6 +195,7 @@ enum {
  *    NLA_NUL_STRING       Maximum length of string (excluding NUL)
  *    NLA_FLAG             Unused
  *    NLA_BINARY           Maximum length of attribute payload
+ *    NLA_NESTED_COMPAT    Exact length of structure payload
  *    All other            Exact length of attribute payload
  *
  * Example:
@@ -733,6 +739,39 @@ static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
 {
 	return nla_parse(tb, maxtype, nla_data(nla), nla_len(nla), policy);
 }
+
+/**
+ * nla_parse_nested_compat - parse nested compat attributes
+ * @tb: destination array with maxtype+1 elements
+ * @maxtype: maximum attribute type to be expected
+ * @nla: attribute containing the nested attributes
+ * @data: pointer to point to contained structure
+ * @len: length of contained structure
+ * @policy: validation policy
+ *
+ * Parse a nested compat attribute. The compat attribute contains a structure
+ * and optionally a set of nested attributes. On success the data pointer
+ * points to the nested data and tb contains the parsed attributes
+ * (see nla_parse).
+ */
+static inline int __nla_parse_nested_compat(struct nlattr *tb[], int maxtype,
+					    struct nlattr *nla,
+					    const struct nla_policy *policy,
+					    int len)
+{
+	if (nla_len(nla) < len)
+		return -1;
+	if (nla_len(nla) >= NLA_ALIGN(len) + sizeof(struct nlattr))
+		return nla_parse_nested(tb, maxtype,
+					nla_data(nla) + NLA_ALIGN(len),
+					policy);
+	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
+	return 0;
+}
+
+#define nla_parse_nested_compat(tb, maxtype, nla, policy, data, len) \
+({	data = nla_len(nla) >= len ? nla_data(nla) : NULL; \
+	__nla_parse_nested_compat(tb, maxtype, nla, policy, len); })
 /**
  * nla_put_u8 - Add a u16 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
@@ -965,6 +1004,51 @@ static inline int nla_nest_end(struct sk_buff *skb, struct nlattr *start)
 }
 
 /**
+ * nla_nest_compat_start - Start a new level of nested compat attributes
+ * @skb: socket buffer to add attributes to
+ * @attrtype: attribute type of container
+ * @attrlen: length of structure
+ * @data: pointer to structure
+ *
+ * Start a nested compat attribute that contains both a structure and
+ * a set of nested attributes.
+ *
+ * Returns the container attribute
+ */
+static inline struct nlattr *nla_nest_compat_start(struct sk_buff *skb,
+						   int attrtype, int attrlen,
+						   const void *data)
+{
+	struct nlattr *start = (struct nlattr *)skb_tail_pointer(skb);
+
+	if (nla_put(skb, attrtype, attrlen, data) < 0)
+		return NULL;
+	if (nla_nest_start(skb, attrtype) == NULL) {
+		nlmsg_trim(skb, start);
+		return NULL;
+	}
+	return start;
+}
+
+/**
+ * nla_nest_compat_end - Finalize nesting of compat attributes
+ * @skb: socket buffer the attribtues are stored in
+ * @start: container attribute
+ *
+ * Corrects the container attribute header to include the all
+ * appeneded attributes.
+ *
+ * Returns the total data length of the skb.
+ */
+static inline int nla_nest_compat_end(struct sk_buff *skb, struct nlattr *start)
+{
+	struct nlattr *nest = (void *)start + NLMSG_ALIGN(start->nla_len);
+
+	start->nla_len = skb_tail_pointer(skb) - (unsigned char *)start;
+	return nla_nest_end(skb, nest);
+}
+
+/**
  * nla_nest_cancel - Cancel nesting of attributes
  * @skb: socket buffer the message is stored in
  * @start: container attribute
diff --git a/net/netlink/attr.c b/net/netlink/attr.c
index c591212..e4d7bed 100644
--- a/net/netlink/attr.c
+++ b/net/netlink/attr.c
@@ -72,6 +72,17 @@ static int validate_nla(struct nlattr *nla, int maxtype,
 			return -ERANGE;
 		break;
 
+	case NLA_NESTED_COMPAT:
+		if (attrlen < pt->len)
+			return -ERANGE;
+		if (attrlen < NLA_ALIGN(pt->len))
+			break;
+		if (attrlen < NLA_ALIGN(pt->len) + NLA_HDRLEN)
+			return -ERANGE;
+		nla = nla_data(nla) + NLA_ALIGN(pt->len);
+		if (attrlen < NLA_ALIGN(pt->len) + NLA_HDRLEN + nla_len(nla))
+			return -ERANGE;
+		break;
 	default:
 		if (pt->len)
 			minlen = pt->len;

--------------000009010205040809010202--
