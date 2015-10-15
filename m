From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 3/9] netlink: strict attribute parsing
Date: Thu, 15 Oct 2015 18:39:08 +0200
Message-ID: <5b2c59e43ccd14676682ad81d1d7ad798c50986d.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32825 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbbJOQji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:38 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance the attribute parsing functions to support strict attribute
checking. Keep the semantics of the current nla_parse and nlmsg_parse
functions, it's better then changing hundreds of call sites all around the
kernel.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/netlink.h | 75 ++++++++++++++++++++++++++++++++++++++++++++-------
 lib/nlattr.c          | 20 +++++++++-----
 2 files changed, 80 insertions(+), 15 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 160e98cea304..dcca6853913d 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -235,8 +235,9 @@ int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 portid,
 
 int nla_validate(const struct nlattr *head, int len, int maxtype,
 		 const struct nla_policy *policy);
-int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
-	      int len, const struct nla_policy *policy);
+int nla_strict_parse(struct nlattr **tb, int maxtype, bool strict,
+		     const struct nlattr *head, int len,
+		     const struct nla_policy *policy);
 int nla_policy_len(const struct nla_policy *, int);
 struct nlattr *nla_find(const struct nlattr *head, int len, int attrtype);
 size_t nla_strlcpy(char *dst, const struct nlattr *nla, size_t dstsize);
@@ -356,6 +357,30 @@ nlmsg_next(const struct nlmsghdr *nlh, int *remaining)
 }
 
 /**
+ * nlmsg_strict_parse - parse attributes of a netlink message
+ * @nlh: netlink message header
+ * @hdrlen: length of family specific header
+ * @tb: destination array with maxtype+1 elements
+ * @maxtype: maximum attribute type to be expected
+ * @strict: whether to perform strict checking
+ * @policy: validation policy
+ *
+ * See nla_strict_parse().
+ */
+static inline int nlmsg_strict_parse(const struct nlmsghdr *nlh, int hdrlen,
+				     struct nlattr *tb[], int maxtype,
+				     bool strict,
+				     const struct nla_policy *policy)
+{
+	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
+		return -EINVAL;
+
+	return nla_strict_parse(tb, maxtype, strict,
+				nlmsg_attrdata(nlh, hdrlen),
+				nlmsg_attrlen(nlh, hdrlen), policy);
+}
+
+/**
  * nlmsg_parse - parse attributes of a netlink message
  * @nlh: netlink message header
  * @hdrlen: length of family specific header
@@ -363,17 +388,13 @@ nlmsg_next(const struct nlmsghdr *nlh, int *remaining)
  * @maxtype: maximum attribute type to be expected
  * @policy: validation policy
  *
- * See nla_parse()
+ * See nla_strict_parse(). Strict checking is not performed.
  */
 static inline int nlmsg_parse(const struct nlmsghdr *nlh, int hdrlen,
 			      struct nlattr *tb[], int maxtype,
 			      const struct nla_policy *policy)
 {
-	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
-		return -EINVAL;
-
-	return nla_parse(tb, maxtype, nlmsg_attrdata(nlh, hdrlen),
-			 nlmsg_attrlen(nlh, hdrlen), policy);
+	return nlmsg_strict_parse(nlh, hdrlen, tb, maxtype, false, policy);
 }
 
 /**
@@ -722,13 +743,49 @@ nla_find_nested(const struct nlattr *nla, int attrtype)
 }
 
 /**
+ * nla_parse - Parse a stream of attributes into a tb buffer
+ * @tb: destination array with maxtype+1 elements
+ * @maxtype: maximum attribute type to be expected
+ * @head: head of attribute stream
+ * @len: length of attribute stream
+ * @policy: validation policy
+ *
+ * See nla_strict_parse(). Strict checking is not performed.
+ */
+static inline int nla_parse(struct nlattr **tb, int maxtype,
+			    const struct nlattr *head, int len,
+			    const struct nla_policy *policy)
+{
+	return nla_strict_parse(tb, maxtype, false, head, len, policy);
+}
+
+/**
+ * nla_strict_parse_nested - parse nested attributes
+ * @tb: destination array with maxtype+1 elements
+ * @maxtype: maximum attribute type to be expected
+ * @strict: whether to perform strict checking
+ * @nla: attribute containing the nested attributes
+ * @policy: validation policy
+ *
+ * See nla_strict_parse(). Strict checking is not performed.
+ */
+static inline int nla_strict_parse_nested(struct nlattr *tb[], int maxtype,
+					  bool strict,
+					  const struct nlattr *nla,
+					  const struct nla_policy *policy)
+{
+	return nla_strict_parse(tb, maxtype, strict, nla_data(nla),
+				nla_len(nla), policy);
+}
+
+/**
  * nla_parse_nested - parse nested attributes
  * @tb: destination array with maxtype+1 elements
  * @maxtype: maximum attribute type to be expected
  * @nla: attribute containing the nested attributes
  * @policy: validation policy
  *
- * See nla_parse()
+ * See nla_strict_parse()
  */
 static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
 				   const struct nlattr *nla,
diff --git a/lib/nlattr.c b/lib/nlattr.c
index b35c3e6c8e81..2b36388eb3a9 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -163,9 +163,10 @@ nla_policy_len(const struct nla_policy *p, int n)
 EXPORT_SYMBOL(nla_policy_len);
 
 /**
- * nla_parse - Parse a stream of attributes into a tb buffer
+ * nla_strict_parse - Parse a stream of attributes into a tb buffer
  * @tb: destination array with maxtype+1 elements
  * @maxtype: maximum attribute type to be expected
+ * @strict: whether to perform strict checking
  * @head: head of attribute stream
  * @len: length of attribute stream
  * @policy: validation policy
@@ -173,12 +174,14 @@ EXPORT_SYMBOL(nla_policy_len);
  * Parses a stream of attributes and stores a pointer to each attribute in
  * the tb array accessible via the attribute type. Attributes with a type
  * exceeding maxtype will be silently ignored for backwards compatibility
- * reasons. policy may be set to NULL if no validation is required.
+ * reasons, unless strict is set. policy may be set to NULL if no validation
+ * is required.
  *
  * Returns 0 on success or a negative error code.
  */
-int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
-	      int len, const struct nla_policy *policy)
+int nla_strict_parse(struct nlattr **tb, int maxtype, bool strict,
+		     const struct nlattr *head, int len,
+		     const struct nla_policy *policy)
 {
 	const struct nlattr *nla;
 	int rem, err;
@@ -196,16 +199,21 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
 			}
 
 			tb[type] = (struct nlattr *)nla;
+		} else if (strict) {
+			return -EINVAL;
 		}
 	}
 
-	if (unlikely(rem > 0))
+	if (unlikely(rem > 0)) {
 		pr_warn_ratelimited("netlink: %d bytes leftover after parsing attributes in process `%s'.\n",
 				    rem, current->comm);
+		if (strict)
+			return -EINVAL;
+	}
 
 	return 0;
 }
-EXPORT_SYMBOL(nla_parse);
+EXPORT_SYMBOL(nla_strict_parse);
 
 /**
  * nla_find - Find a specific attribute in a stream of attributes
-- 
1.8.3.1
