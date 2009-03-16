From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 2/6] netlink: add nla_policy_len()
Date: Mon, 16 Mar 2009 23:07:01 +0100
Message-ID: <20090316221137.034320718@jonathan.eitzenberger.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=netlink-add-nla_policy_len.diff
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It calculates the max. length of a Netlink policy, which is usefull
for allocating Netlink buffers roughly the size of the actual
message.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: net-next-2.6/include/net/netlink.h
===================================================================
--- net-next-2.6.orig/include/net/netlink.h
+++ net-next-2.6/include/net/netlink.h
@@ -230,6 +230,7 @@ extern int		nla_validate(struct nlattr *
 extern int		nla_parse(struct nlattr *tb[], int maxtype,
 				  struct nlattr *head, int len,
 				  const struct nla_policy *policy);
+extern int		nla_policy_len(const struct nla_policy *, int);
 extern struct nlattr *	nla_find(struct nlattr *head, int len, int attrtype);
 extern size_t		nla_strlcpy(char *dst, const struct nlattr *nla,
 				    size_t dstsize);
Index: net-next-2.6/net/netlink/attr.c
===================================================================
--- net-next-2.6.orig/net/netlink/attr.c
+++ net-next-2.6/net/netlink/attr.c
@@ -133,6 +133,32 @@ errout:
 }
 
 /**
+ * nla_policy_len - Determin the max. length of a policy
+ * @policy: policy to use
+ * @n: number of policies
+ *
+ * Determines the max. length of the policy.  It is currently used
+ * to allocated Netlink buffers roughly the size of the actual
+ * message.
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int
+nla_policy_len(const struct nla_policy *p, int n)
+{
+	int i, len = 0;
+
+	for (i = 0; i < n; i++) {
+		if (p->len)
+			len += nla_total_size(p->len);
+		else if (nla_attr_minlen[p->type])
+			len += nla_total_size(nla_attr_minlen[p->type]);
+	}
+
+	return len;
+}
+
+/**
  * nla_parse - Parse a stream of attributes into a tb buffer
  * @tb: destination array with maxtype+1 elements
  * @maxtype: maximum attribute type to be expected
@@ -456,6 +482,7 @@ int nla_append(struct sk_buff *skb, int 
 }
 
 EXPORT_SYMBOL(nla_validate);
+EXPORT_SYMBOL(nla_policy_len);
 EXPORT_SYMBOL(nla_parse);
 EXPORT_SYMBOL(nla_find);
 EXPORT_SYMBOL(nla_strlcpy);

-- 
