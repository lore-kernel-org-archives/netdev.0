From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 4/9] netlink: strict attribute validation
Date: Thu, 15 Oct 2015 18:39:09 +0200
Message-ID: <a01e1014c7e44b9505d84772e74b38d244f3f403.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752803AbbJOQjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:39 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance the attribute validation functions to support strict attribute
checking. Keep the semantics of the current nla_validate and nlmsg_validate
functions.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/netlink.h | 67 ++++++++++++++++++++++++++++++++++++++++++++-------
 lib/nlattr.c          | 24 +++++++++++-------
 2 files changed, 73 insertions(+), 18 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index dcca6853913d..233a68e1c955 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -233,8 +233,8 @@ int netlink_rcv_skb(struct sk_buff *skb, bool strict_supported,
 int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 portid,
 		 unsigned int group, int report, gfp_t flags);
 
-int nla_validate(const struct nlattr *head, int len, int maxtype,
-		 const struct nla_policy *policy);
+int nla_strict_validate(const struct nlattr *head, int len, int maxtype,
+			bool strict, const struct nla_policy *policy);
 int nla_strict_parse(struct nlattr **tb, int maxtype, bool strict,
 		     const struct nlattr *head, int len,
 		     const struct nla_policy *policy);
@@ -413,6 +413,26 @@ static inline struct nlattr *nlmsg_find_attr(const struct nlmsghdr *nlh,
 }
 
 /**
+ * nlmsg_strict_validate - validate a netlink message including attributes
+ * @nlh: netlinket message header
+ * @hdrlen: length of familiy specific header
+ * @maxtype: maximum attribute type to be expected
+ * @strict: whether to perform strict checking
+ * @policy: validation policy
+ */
+static inline int nlmsg_strict_validate(const struct nlmsghdr *nlh,
+					int hdrlen, int maxtype, bool strict,
+					const struct nla_policy *policy)
+{
+	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
+		return -EINVAL;
+
+	return nla_strict_validate(nlmsg_attrdata(nlh, hdrlen),
+				   nlmsg_attrlen(nlh, hdrlen), maxtype,
+				   strict, policy);
+}
+
+/**
  * nlmsg_validate - validate a netlink message including attributes
  * @nlh: netlinket message header
  * @hdrlen: length of familiy specific header
@@ -423,11 +443,7 @@ static inline int nlmsg_validate(const struct nlmsghdr *nlh,
 				 int hdrlen, int maxtype,
 				 const struct nla_policy *policy)
 {
-	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
-		return -EINVAL;
-
-	return nla_validate(nlmsg_attrdata(nlh, hdrlen),
-			    nlmsg_attrlen(nlh, hdrlen), maxtype, policy);
+	return nlmsg_strict_validate(nlh, hdrlen, maxtype, false, policy);
 }
 
 /**
@@ -1270,17 +1286,50 @@ static inline void nla_nest_cancel(struct sk_buff *skb, struct nlattr *start)
 }
 
 /**
- * nla_validate_nested - Validate a stream of nested attributes
+ * nla_validate - Validate a stream of attributes
+ * @head: head of attribute stream
+ * @len: length of attribute stream
+ * @maxtype: maximum attribute type to be expected
+ * @policy: validation policy
+ *
+ * See nla_strict_validate(). Strict checking is not performed.
+ */
+static inline int nla_validate(const struct nlattr *head, int len,
+			       int maxtype, const struct nla_policy *policy)
+{
+	return nla_strict_validate(head, len, maxtype, false, policy);
+}
+
+/**
+ * nla_strict_validate_nested - Validate a stream of nested attributes
  * @start: container attribute
  * @maxtype: maximum attribute type to be expected
+ * @strict: whether to perform strict checking
  * @policy: validation policy
  *
  * Validates all attributes in the nested attribute stream against the
  * specified policy. Attributes with a type exceeding maxtype will be
- * ignored. See documenation of struct nla_policy for more details.
+ * ignored, unless strict is set. See documenation of struct nla_policy for
+ * more details.
  *
  * Returns 0 on success or a negative error code.
  */
+static inline int nla_strict_validate_nested(const struct nlattr *start,
+					     int maxtype, bool strict,
+					     const struct nla_policy *policy)
+{
+	return nla_strict_validate(nla_data(start), nla_len(start), maxtype,
+				   strict, policy);
+}
+
+/**
+ * nla_validate_nested - Validate a stream of nested attributes
+ * @start: container attribute
+ * @maxtype: maximum attribute type to be expected
+ * @policy: validation policy
+ *
+ * See nla_strict_validate_nested(). Strict checking is not performed.
+ */
 static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
 				      const struct nla_policy *policy)
 {
diff --git a/lib/nlattr.c b/lib/nlattr.c
index 2b36388eb3a9..86bc0662caee 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -27,14 +27,17 @@ static const u16 nla_attr_minlen[NLA_TYPE_MAX+1] = {
 	[NLA_S64]	= sizeof(s64),
 };
 
-static int validate_nla(const struct nlattr *nla, int maxtype,
+static int validate_nla(const struct nlattr *nla, int maxtype, bool strict,
 			const struct nla_policy *policy)
 {
 	const struct nla_policy *pt;
 	int minlen = 0, attrlen = nla_len(nla), type = nla_type(nla);
 
-	if (type <= 0 || type > maxtype)
+	if (type <= 0 || type > maxtype) {
+		if (strict)
+			return -EINVAL;
 		return 0;
+	}
 
 	pt = &policy[type];
 
@@ -107,33 +110,35 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
 }
 
 /**
- * nla_validate - Validate a stream of attributes
+ * nla_strict_validate - Validate a stream of attributes
  * @head: head of attribute stream
  * @len: length of attribute stream
  * @maxtype: maximum attribute type to be expected
+ * @strict: whether to perform strict checking
  * @policy: validation policy
  *
  * Validates all attributes in the specified attribute stream against the
  * specified policy. Attributes with a type exceeding maxtype will be
- * ignored. See documenation of struct nla_policy for more details.
+ * ignored, unless strict is set. See documenation of struct nla_policy for
+ * more details.
  *
  * Returns 0 on success or a negative error code.
  */
-int nla_validate(const struct nlattr *head, int len, int maxtype,
-		 const struct nla_policy *policy)
+int nla_strict_validate(const struct nlattr *head, int len, int maxtype,
+			bool strict, const struct nla_policy *policy)
 {
 	const struct nlattr *nla;
 	int rem, err;
 
 	nla_for_each_attr(nla, head, len, rem) {
-		err = validate_nla(nla, maxtype, policy);
+		err = validate_nla(nla, maxtype, strict, policy);
 		if (err < 0)
 			return err;
 	}
 
 	return 0;
 }
-EXPORT_SYMBOL(nla_validate);
+EXPORT_SYMBOL(nla_strict_validate);
 
 /**
  * nla_policy_len - Determin the max. length of a policy
@@ -193,7 +198,8 @@ int nla_strict_parse(struct nlattr **tb, int maxtype, bool strict,
 
 		if (type > 0 && type <= maxtype) {
 			if (policy) {
-				err = validate_nla(nla, maxtype, policy);
+				err = validate_nla(nla, maxtype, strict,
+						   policy);
 				if (err < 0)
 					return err;
 			}
-- 
1.8.3.1
