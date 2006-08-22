From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND 1/2] [NETLINK]: Improve string attribute validation
Date: Tue, 22 Aug 2006 15:40:49 +0200
Message-ID: <20060822134049.GF3470@postel.suug.ch>
References: <20060822125354.196502354@postel.suug.ch> <20060822125840.307365394@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:49886 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932240AbWHVNk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 09:40:28 -0400
To: davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060822125840.307365394@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Searching for '\0' with strnchr() doesn't really work :-)

Introduces a new attribute type NLA_NUL_STRING to support NUL
terminated strings. Attributes of this kind require to carry
a terminating NUL within the maximum specified in the policy.

The `old' NLA_STRING which is not required to be NUL terminated
is extended to provide means to specify a maximum length of the
string.

Aims at easing the pain with using nla_strlcpy() on temporary
buffers.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/net/netlink.h
===================================================================
--- net-2.6.19.git.orig/include/net/netlink.h
+++ net-2.6.19.git/include/net/netlink.h
@@ -167,6 +167,7 @@ enum {
 	NLA_FLAG,
 	NLA_MSECS,
 	NLA_NESTED,
+	NLA_NUL_STRING,
 	__NLA_TYPE_MAX,
 };
 
@@ -175,21 +176,27 @@ enum {
 /**
  * struct nla_policy - attribute validation policy
  * @type: Type of attribute or NLA_UNSPEC
- * @minlen: Minimal length of payload required to be available
+ * @len: Type specific length of payload
  *
  * Policies are defined as arrays of this struct, the array must be
  * accessible by attribute type up to the highest identifier to be expected.
  *
+ * Meaning of `len' field:
+ *    NLA_STRING           Maximum length of string
+ *    NLA_NUL_STRING       Maximum length of string (excluding NUL)
+ *    NLA_FLAG             Unused
+ *    All other            Exact length of attribute payload
+ *
  * Example:
  * static struct nla_policy my_policy[ATTR_MAX+1] __read_mostly = {
  * 	[ATTR_FOO] = { .type = NLA_U16 },
- *	[ATTR_BAR] = { .type = NLA_STRING },
- *	[ATTR_BAZ] = { .minlen = sizeof(struct mystruct) },
+ *	[ATTR_BAR] = { .type = NLA_STRING, len = BARSIZ },
+ *	[ATTR_BAZ] = { .len = sizeof(struct mystruct) },
  * };
  */
 struct nla_policy {
 	u16		type;
-	u16		minlen;
+	u16		len;
 };
 
 /**
Index: net-2.6.19.git/net/netlink/attr.c
===================================================================
--- net-2.6.19.git.orig/net/netlink/attr.c
+++ net-2.6.19.git/net/netlink/attr.c
@@ -20,7 +20,6 @@ static u16 nla_attr_minlen[NLA_TYPE_MAX+
 	[NLA_U16]	= sizeof(u16),
 	[NLA_U32]	= sizeof(u32),
 	[NLA_U64]	= sizeof(u64),
-	[NLA_STRING]	= 1,
 	[NLA_NESTED]	= NLA_HDRLEN,
 };
 
@@ -28,7 +27,7 @@ static int validate_nla(struct nlattr *n
 			struct nla_policy *policy)
 {
 	struct nla_policy *pt;
-	int minlen = 0;
+	int minlen = 0, attrlen = nla_len(nla);
 
 	if (nla->nla_type <= 0 || nla->nla_type > maxtype)
 		return 0;
@@ -37,16 +36,46 @@ static int validate_nla(struct nlattr *n
 
 	BUG_ON(pt->type > NLA_TYPE_MAX);
 
-	if (pt->minlen)
-		minlen = pt->minlen;
-	else if (pt->type != NLA_UNSPEC)
-		minlen = nla_attr_minlen[pt->type];
+	switch (pt->type) {
+	case NLA_FLAG:
+		if (attrlen > 0)
+			return -ERANGE;
+		break;
+
+	case NLA_NUL_STRING:
+		if (pt->len)
+			minlen = min_t(int, attrlen, pt->len + 1);
+		else
+			minlen = attrlen;
+
+		if (!minlen || memchr(nla_data(nla), '\0', minlen) == NULL)
+			return -EINVAL;
+		/* fall through */
+
+	case NLA_STRING:
+		if (attrlen < 1)
+			return -ERANGE;
 
-	if (pt->type == NLA_FLAG && nla_len(nla) > 0)
-		return -ERANGE;
+		if (pt->len) {
+			char *buf = nla_data(nla);
 
-	if (nla_len(nla) < minlen)
-		return -ERANGE;
+			if (buf[attrlen - 1] == '\0')
+				attrlen--;
+
+			if (attrlen > pt->len)
+				return -ERANGE;
+		}
+		break;
+
+	default:
+		if (pt->len)
+			minlen = pt->len;
+		else if (pt->type != NLA_UNSPEC)
+			minlen = nla_attr_minlen[pt->type];
+
+		if (attrlen < minlen)
+			return -ERANGE;
+	}
 
 	return 0;
 }
