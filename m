From: Patrick McHardy <kaber@trash.net>
Subject: netlink 05/12: add nla_policy_len()
Date: Thu, 26 Mar 2009 20:02:37 +0100 (MET)
Message-ID: <20090326190231.23365.93127.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39223 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758775AbZCZTCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 15:02:40 -0400
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e487eb99cf9381a4f8254fa01747a85818da612b
Author: Holger Eitzenberger <holger@eitzenberger.org>
Date:   Wed Mar 25 18:26:30 2009 +0100

    netlink: add nla_policy_len()
    
    It calculates the max. length of a Netlink policy, which is usefull
    for allocating Netlink buffers roughly the size of the actual
    message.
    
    Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 8a6150a..eddb502 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -230,6 +230,7 @@ extern int		nla_validate(struct nlattr *head, int len, int maxtype,
 extern int		nla_parse(struct nlattr *tb[], int maxtype,
 				  struct nlattr *head, int len,
 				  const struct nla_policy *policy);
+extern int		nla_policy_len(const struct nla_policy *, int);
 extern struct nlattr *	nla_find(struct nlattr *head, int len, int attrtype);
 extern size_t		nla_strlcpy(char *dst, const struct nlattr *nla,
 				    size_t dstsize);
diff --git a/net/netlink/attr.c b/net/netlink/attr.c
index 56c3ce7..ae32c57 100644
--- a/net/netlink/attr.c
+++ b/net/netlink/attr.c
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
@@ -456,6 +482,7 @@ int nla_append(struct sk_buff *skb, int attrlen, const void *data)
 }
 
 EXPORT_SYMBOL(nla_validate);
+EXPORT_SYMBOL(nla_policy_len);
 EXPORT_SYMBOL(nla_parse);
 EXPORT_SYMBOL(nla_find);
 EXPORT_SYMBOL(nla_strlcpy);
