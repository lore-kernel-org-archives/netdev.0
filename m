From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next iproute2 1/3] netlink: import netlink message parsing from kernel
Date: Mon,  1 May 2017 20:18:23 -0700
Message-ID: <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
References: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Cc: jakub.kicinski@netronome.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35102 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751077AbdEBDSb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:18:31 -0400
Received: by mail-pf0-f175.google.com with SMTP id v14so82507315pfd.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 20:18:30 -0700 (PDT)
In-Reply-To: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include/nlattr.h is pulled from include/net/netlink.h.
lib/nlattr.c is pulled from lib/nlattr.c

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/libnetlink.h |   8 +++
 include/nlattr.h     | 162 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/Makefile         |   2 +-
 lib/libnetlink.c     |   4 --
 lib/nlattr.c         | 145 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 316 insertions(+), 5 deletions(-)
 create mode 100644 include/nlattr.h
 create mode 100644 lib/nlattr.c

diff --git a/include/libnetlink.h b/include/libnetlink.h
index c43ab0a2d9d9..e7c46f1870aa 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -11,6 +11,11 @@
 #include <linux/neighbour.h>
 #include <linux/netconf.h>
 #include <arpa/inet.h>
+#include "nlattr.h"
+
+#ifndef MIN
+#define MIN(a, b) ((a) < (b) ? (a) : (b))
+#endif
 
 struct rtnl_handle {
 	int			fd;
@@ -227,4 +232,7 @@ int rtnl_from_file(FILE *, rtnl_listen_filter_t handler,
  * messages from dump file */
 #define NLMSG_TSTAMP	15
 
+int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
+	      int len, const struct nla_policy *policy);
+
 #endif /* __LIBNETLINK_H__ */
diff --git a/include/nlattr.h b/include/nlattr.h
new file mode 100644
index 000000000000..0859b6ce686c
--- /dev/null
+++ b/include/nlattr.h
@@ -0,0 +1,162 @@
+#ifndef __NLATTR_H
+#define __NLATTR_H
+
+#include <linux/netlink.h>
+
+/**
+ * Standard attribute types to specify validation policy
+ */
+enum {
+	NLA_UNSPEC,
+	NLA_U8,
+	NLA_U16,
+	NLA_U32,
+	NLA_U64,
+	NLA_STRING,
+	NLA_FLAG,
+	NLA_MSECS,
+	NLA_NESTED,
+	NLA_NESTED_COMPAT,
+	NLA_NUL_STRING,
+	NLA_BINARY,
+	NLA_S8,
+	NLA_S16,
+	NLA_S32,
+	NLA_S64,
+	__NLA_TYPE_MAX,
+};
+
+#define NLA_TYPE_MAX (__NLA_TYPE_MAX - 1)
+
+/**
+ * nla_type - attribute type
+ * @nla: netlink attribute
+ */
+static inline int nla_type(const struct nlattr *nla)
+{
+	return nla->nla_type & NLA_TYPE_MASK;
+}
+
+/**
+ * nla_len - length of payload
+ * @nla: netlink attribute
+ */
+static inline int nla_len(const struct nlattr *nla)
+{
+	return nla->nla_len - NLA_HDRLEN;
+}
+
+/**
+ * struct nla_policy - attribute validation policy
+ * @type: Type of attribute or NLA_UNSPEC
+ * @len: Type specific length of payload
+ *
+ * Policies are defined as arrays of this struct, the array must be
+ * accessible by attribute type up to the highest identifier to be expected.
+ *
+ * Meaning of `len' field:
+ *    NLA_STRING           Maximum length of string
+ *    NLA_NUL_STRING       Maximum length of string (excluding NUL)
+ *    NLA_FLAG             Unused
+ *    NLA_BINARY           Maximum length of attribute payload
+ *    NLA_NESTED           Don't use `len' field -- length verification is
+ *                         done by checking len of nested header (or empty)
+ *    NLA_NESTED_COMPAT    Minimum length of structure payload
+ *    NLA_U8, NLA_U16,
+ *    NLA_U32, NLA_U64,
+ *    NLA_S8, NLA_S16,
+ *    NLA_S32, NLA_S64,
+ *    NLA_MSECS            Leaving the length field zero will verify the
+ *                         given type fits, using it verifies minimum length
+ *                         just like "All other"
+ *    All other            Minimum length of attribute payload
+ *
+ * Example:
+ * static const struct nla_policy my_policy[ATTR_MAX+1] = {
+ *      [ATTR_FOO] = { .type = NLA_U16 },
+ *      [ATTR_BAR] = { .type = NLA_STRING, .len = BARSIZ },
+ *      [ATTR_BAZ] = { .len = sizeof(struct mystruct) },
+ * };
+ */
+struct nla_policy {
+	__u16	type;
+	__u16	len;
+};
+
+/**
+ * nla_ok - check if the netlink attribute fits into the remaining bytes
+ * @nla: netlink attribute
+ * @remaining: number of bytes remaining in attribute stream
+ */
+static inline int nla_ok(const struct nlattr *nla, int remaining)
+{
+	return remaining >= (int) sizeof(*nla) &&
+	       nla->nla_len >= sizeof(*nla) &&
+	       nla->nla_len <= remaining;
+}
+
+/**
+ * nla_next - next netlink attribute in attribute stream
+ * @nla: netlink attribute
+ * @remaining: number of bytes remaining in attribute stream
+ *
+ * Returns the next netlink attribute in the attribute stream and
+ * decrements remaining by the size of the current attribute.
+ */
+static inline struct nlattr *nla_next(const struct nlattr *nla, int *remaining)
+{
+	unsigned int totlen = NLA_ALIGN(nla->nla_len);
+
+	*remaining -= totlen;
+	return (struct nlattr *) ((char *) nla + totlen);
+}
+
+/**
+ * nla_for_each_attr - iterate over a stream of attributes
+ * @pos: loop counter, set to current attribute
+ * @head: head of attribute stream
+ * @len: length of attribute stream
+ * @rem: initialized to len, holds bytes currently remaining in stream
+ */
+#define nla_for_each_attr(pos, head, len, rem) \
+	for (pos = head, rem = len; \
+	     nla_ok(pos, rem); \
+	     pos = nla_next(pos, &(rem)))
+
+/**
+ * nla_data - head of payload
+ * @nla: netlink attribute
+ */
+static inline void *nla_data(const struct nlattr *nla)
+{
+	return (char *) nla + NLA_HDRLEN;
+}
+
+/**
+ * nla_get_u32 - return payload of u32 attribute
+ * @nla: u32 netlink attribute
+ */
+static inline __u32 nla_get_u32(const struct nlattr *nla)
+{
+	return *(__u32 *) nla_data(nla);
+}
+
+/**
+ * nla_get_u16 - return payload of u16 attribute
+ * @nla: u16 netlink attribute
+ */
+static inline __u16 nla_get_u16(const struct nlattr *nla)
+{
+	return *(__u16 *) nla_data(nla);
+}
+
+/**
+ * nlmsg_len - length of message payload
+ * @nlh: netlink message header
+ */
+static inline int nlmsg_len(const struct nlmsghdr *nlh)
+{
+	return nlh->nlmsg_len - NLMSG_HDRLEN;
+}
+
+#endif /* __NLATTR_H */
diff --git a/lib/Makefile b/lib/Makefile
index 1d24ca24b9a3..77fac8d59446 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -8,7 +8,7 @@ CFLAGS += -fPIC
 
 UTILOBJ = utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o \
 	inet_proto.o namespace.o json_writer.o \
-	names.o color.o bpf.o exec.o fs.o
+	names.o color.o bpf.o exec.o fs.o nlattr.o
 
 NLOBJ=libgenl.o ll_map.o libnetlink.o
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 5b75b2db4e0b..b5ee751c6b86 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -30,10 +30,6 @@
 #define SOL_NETLINK 270
 #endif
 
-#ifndef MIN
-#define MIN(a, b) ((a) < (b) ? (a) : (b))
-#endif
-
 int rcvbuf = 1024 * 1024;
 
 void rtnl_close(struct rtnl_handle *rth)
diff --git a/lib/nlattr.c b/lib/nlattr.c
new file mode 100644
index 000000000000..2a3a031fdb65
--- /dev/null
+++ b/lib/nlattr.c
@@ -0,0 +1,145 @@
+/*
+ * NETLINK      Netlink attributes
+ *
+ *		Authors:	Thomas Graf <tgraf@suug.ch>
+ *				Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
+ */
+
+#include <errno.h>
+#include "nlattr.h"
+#include "libnetlink.h"
+
+static const __u8 nla_attr_minlen[NLA_TYPE_MAX+1] = {
+	[NLA_U8]	= sizeof(__u8),
+	[NLA_U16]	= sizeof(__u16),
+	[NLA_U32]	= sizeof(__u32),
+	[NLA_U64]	= sizeof(__u64),
+	[NLA_MSECS]	= sizeof(__u64),
+	[NLA_NESTED]	= NLA_HDRLEN,
+	[NLA_S8]	= sizeof(__s8),
+	[NLA_S16]	= sizeof(__s16),
+	[NLA_S32]	= sizeof(__s32),
+	[NLA_S64]	= sizeof(__s64),
+};
+
+static int validate_nla(const struct nlattr *nla, int maxtype,
+			const struct nla_policy *policy)
+{
+	const struct nla_policy *pt;
+	int minlen = 0, attrlen = nla_len(nla), type = nla_type(nla);
+
+	if (type <= 0 || type > maxtype)
+		return 0;
+
+	pt = &policy[type];
+
+	if (pt->type > NLA_TYPE_MAX)
+		return -EINVAL;
+
+	switch (pt->type) {
+	case NLA_FLAG:
+		if (attrlen > 0)
+			return -ERANGE;
+		break;
+
+	case NLA_NUL_STRING:
+		if (pt->len)
+			minlen = MIN(attrlen, pt->len + 1);
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
+
+		if (pt->len) {
+			char *buf = nla_data(nla);
+
+			if (buf[attrlen - 1] == '\0')
+				attrlen--;
+
+			if (attrlen > pt->len)
+				return -ERANGE;
+		}
+		break;
+
+	case NLA_BINARY:
+		if (pt->len && attrlen > pt->len)
+			return -ERANGE;
+		break;
+
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
+	case NLA_NESTED:
+		/* a nested attributes is allowed to be empty; if its not,
+		 * it must have a size of at least NLA_HDRLEN.
+		 */
+		if (attrlen == 0)
+			break;
+	default:
+		if (pt->len)
+			minlen = pt->len;
+		else if (pt->type != NLA_UNSPEC)
+			minlen = nla_attr_minlen[pt->type];
+
+		if (attrlen < minlen)
+			return -ERANGE;
+	}
+
+	return 0;
+}
+
+/**
+ * nla_parse - Parse a stream of attributes into a tb buffer
+ * @tb: destination array with maxtype+1 elements
+ * @maxtype: maximum attribute type to be expected
+ * @head: head of attribute stream
+ * @len: length of attribute stream
+ * @policy: validation policy
+ *
+ * Parses a stream of attributes and stores a pointer to each attribute in
+ * the tb array accessible via the attribute type. Attributes with a type
+ * exceeding maxtype will be silently ignored for backwards compatibility
+ * reasons. policy may be set to NULL if no validation is required.
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
+	      int len, const struct nla_policy *policy)
+{
+	const struct nlattr *nla;
+	int rem, err;
+
+	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
+
+	nla_for_each_attr(nla, head, len, rem) {
+		__u16 type = nla_type(nla);
+
+		if (type > 0 && type <= maxtype) {
+			if (policy) {
+				err = validate_nla(nla, maxtype, policy);
+				if (err < 0)
+					goto errout;
+			}
+
+			tb[type] = (struct nlattr *)nla;
+		}
+	}
+
+	err = 0;
+errout:
+	return err;
+}
-- 
2.1.4
