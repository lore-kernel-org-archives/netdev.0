From: Jan Engelhardt <jengelh@medozas.de>
Subject: [patch] netlink: let nlmsg and nla functions take pointer-to-const
 args
Date: Wed, 10 Nov 2010 01:06:36 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011100106010.10874@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:54513 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442Ab0KJAGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 19:06:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parent 2531add5568de01edcabf321d1bbb69a6a6d6c27 (v2.6.36-4468-g2531add)
commit f87d7f1b74689c96cc2f53b8cabfd309d7ad1bda
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Nov 10 00:10:55 2010 +0100

netlink: let nlmsg and nla functions take pointer-to-const args

The changed functions do not modify the NL messages and/or attributes
at all. They should use const (similar to strchr), so that callers
which have a const nlmsg/nlattr around can make use of them without
casting.

While at it, constify a data array.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/net/netlink.h |   23 ++++++++++++++---------
 lib/nlattr.c          |   22 +++++++++++-----------
 2 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index f3b201d..373f1a9 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -225,13 +225,15 @@ extern int		nlmsg_notify(struct sock *sk, struct sk_buff *skb,
 				     u32 pid, unsigned int group, int report,
 				     gfp_t flags);
 
-extern int		nla_validate(struct nlattr *head, int len, int maxtype,
+extern int		nla_validate(const struct nlattr *head,
+				     int len, int maxtype,
 				     const struct nla_policy *policy);
-extern int		nla_parse(struct nlattr *tb[], int maxtype,
-				  struct nlattr *head, int len,
+extern int		nla_parse(struct nlattr **tb, int maxtype,
+				  const struct nlattr *head, int len,
 				  const struct nla_policy *policy);
 extern int		nla_policy_len(const struct nla_policy *, int);
-extern struct nlattr *	nla_find(struct nlattr *head, int len, int attrtype);
+extern struct nlattr *	nla_find(const struct nlattr *head,
+				 int len, int attrtype);
 extern size_t		nla_strlcpy(char *dst, const struct nlattr *nla,
 				    size_t dstsize);
 extern int		nla_memcpy(void *dest, const struct nlattr *src, int count);
@@ -346,7 +348,8 @@ static inline int nlmsg_ok(const struct nlmsghdr *nlh, int remaining)
  * Returns the next netlink message in the message stream and
  * decrements remaining by the size of the current message.
  */
-static inline struct nlmsghdr *nlmsg_next(struct nlmsghdr *nlh, int *remaining)
+static inline struct nlmsghdr *
+nlmsg_next(const struct nlmsghdr *nlh, int *remaining)
 {
 	int totlen = NLMSG_ALIGN(nlh->nlmsg_len);
 
@@ -384,7 +387,7 @@ static inline int nlmsg_parse(const struct nlmsghdr *nlh, int hdrlen,
  *
  * Returns the first attribute which matches the specified type.
  */
-static inline struct nlattr *nlmsg_find_attr(struct nlmsghdr *nlh,
+static inline struct nlattr *nlmsg_find_attr(const struct nlmsghdr *nlh,
 					     int hdrlen, int attrtype)
 {
 	return nla_find(nlmsg_attrdata(nlh, hdrlen),
@@ -398,7 +401,8 @@ static inline struct nlattr *nlmsg_find_attr(struct nlmsghdr *nlh,
  * @maxtype: maximum attribute type to be expected
  * @policy: validation policy
  */
-static inline int nlmsg_validate(struct nlmsghdr *nlh, int hdrlen, int maxtype,
+static inline int nlmsg_validate(const struct nlmsghdr *nlh,
+				 int hdrlen, int maxtype,
 				 const struct nla_policy *policy)
 {
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
@@ -727,7 +731,8 @@ static inline struct nlattr *nla_next(const struct nlattr *nla, int *remaining)
  *
  * Returns the first attribute which matches the specified type.
  */
-static inline struct nlattr *nla_find_nested(struct nlattr *nla, int attrtype)
+static inline struct nlattr *
+nla_find_nested(const struct nlattr *nla, int attrtype)
 {
 	return nla_find(nla_data(nla), nla_len(nla), attrtype);
 }
@@ -1032,7 +1037,7 @@ static inline void nla_nest_cancel(struct sk_buff *skb, struct nlattr *start)
  *
  * Returns 0 on success or a negative error code.
  */
-static inline int nla_validate_nested(struct nlattr *start, int maxtype,
+static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
 				      const struct nla_policy *policy)
 {
 	return nla_validate(nla_data(start), nla_len(start), maxtype, policy);
diff --git a/lib/nlattr.c b/lib/nlattr.c
index c4706eb..00e8a02 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -15,7 +15,7 @@
 #include <linux/types.h>
 #include <net/netlink.h>
 
-static u16 nla_attr_minlen[NLA_TYPE_MAX+1] __read_mostly = {
+static const u16 nla_attr_minlen[NLA_TYPE_MAX+1] = {
 	[NLA_U8]	= sizeof(u8),
 	[NLA_U16]	= sizeof(u16),
 	[NLA_U32]	= sizeof(u32),
@@ -23,7 +23,7 @@ static u16 nla_attr_minlen[NLA_TYPE_MAX+1] __read_mostly = {
 	[NLA_NESTED]	= NLA_HDRLEN,
 };
 
-static int validate_nla(struct nlattr *nla, int maxtype,
+static int validate_nla(const struct nlattr *nla, int maxtype,
 			const struct nla_policy *policy)
 {
 	const struct nla_policy *pt;
@@ -115,10 +115,10 @@ static int validate_nla(struct nlattr *nla, int maxtype,
  *
  * Returns 0 on success or a negative error code.
  */
-int nla_validate(struct nlattr *head, int len, int maxtype,
+int nla_validate(const struct nlattr *head, int len, int maxtype,
 		 const struct nla_policy *policy)
 {
-	struct nlattr *nla;
+	const struct nlattr *nla;
 	int rem, err;
 
 	nla_for_each_attr(nla, head, len, rem) {
@@ -173,10 +173,10 @@ nla_policy_len(const struct nla_policy *p, int n)
  *
  * Returns 0 on success or a negative error code.
  */
-int nla_parse(struct nlattr *tb[], int maxtype, struct nlattr *head, int len,
-	      const struct nla_policy *policy)
+int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
+	      int len, const struct nla_policy *policy)
 {
-	struct nlattr *nla;
+	const struct nlattr *nla;
 	int rem, err;
 
 	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
@@ -191,7 +191,7 @@ int nla_parse(struct nlattr *tb[], int maxtype, struct nlattr *head, int len,
 					goto errout;
 			}
 
-			tb[type] = nla;
+			tb[type] = (struct nlattr *)nla;
 		}
 	}
 
@@ -212,14 +212,14 @@ errout:
  *
  * Returns the first attribute in the stream matching the specified type.
  */
-struct nlattr *nla_find(struct nlattr *head, int len, int attrtype)
+struct nlattr *nla_find(const struct nlattr *head, int len, int attrtype)
 {
-	struct nlattr *nla;
+	const struct nlattr *nla;
 	int rem;
 
 	nla_for_each_attr(nla, head, len, rem)
 		if (nla_type(nla) == attrtype)
-			return nla;
+			return (struct nlattr *)nla;
 
 	return NULL;
 }
-- 
# Created with git-export-patch

