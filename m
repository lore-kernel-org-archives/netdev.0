From: roopa@cumulusnetworks.com
Subject: [PATCH net] mpls: modify RTA_NEWDST netlink attribute to include family
Date: Thu, 14 May 2015 21:38:42 -0700
Message-ID: <1431664722-59539-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34225 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbEOEir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 00:38:47 -0400
Received: by ieczm2 with SMTP id zm2so17633820iec.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 21:38:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

RTA_NEWDST netlink attribute today is used to carry mpls
labels. This patch encodes family in RTA_NEWDST.

RTA_NEWDST by its name and its use in iproute2 can be
used as a generic new dst. But it is currently used only for
mpls labels ie with family AF_MPLS. Encoding family in the
attribute will help its reuse in the future.

One usecase where family with RTA_NEWDST becomes necessary
is when we implement mpls label edge router function.

This is a uapi change but RTA_NEWDST has not made
into any release yet. so, trying to rush this change into
4.1 if acceptable.

(iproute2 patch will follow)

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
eric, if you had already thought about other ways to represent
labels for LER function, pls let me know. I am looking for suggestions.

 include/uapi/linux/rtnetlink.h |    7 ++-
 net/mpls/af_mpls.c             |  118 +++++++++++++++++++++++++++++++---------
 net/mpls/internal.h            |    5 +-
 3 files changed, 100 insertions(+), 30 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 974db03..79879cb 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -356,8 +356,13 @@ struct rtvia {
 	__u8			rtvia_addr[0];
 };
 
-/* RTM_CACHEINFO */
+/* RTA_NEWDST */
+struct rtnewdst {
+	__kernel_sa_family_t	family;
+	__u8	dst[0];
+};
 
+/* RTM_CACHEINFO */
 struct rta_cacheinfo {
 	__u32	rta_clntref;
 	__u32	rta_lastuse;
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 91ed656..6c31108 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -599,18 +599,13 @@ static int nla_put_via(struct sk_buff *skb,
 	return 0;
 }
 
-int nla_put_labels(struct sk_buff *skb, int attrtype,
+int nla_put_labels(struct sk_buff *skb, void *addr,
 		   u8 labels, const u32 label[])
 {
-	struct nlattr *nla;
-	struct mpls_shim_hdr *nla_label;
+	struct mpls_shim_hdr *nla_label = addr;
 	bool bos;
 	int i;
-	nla = nla_reserve(skb, attrtype, labels*4);
-	if (!nla)
-		return -EMSGSIZE;
 
-	nla_label = nla_data(nla);
 	bos = true;
 	for (i = labels - 1; i >= 0; i--) {
 		nla_label[i] = mpls_entry_encode(label[i], 0, 0, bos);
@@ -620,25 +615,45 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,
 	return 0;
 }
 
-int nla_get_labels(const struct nlattr *nla,
-		   u32 max_labels, u32 *labels, u32 label[])
+int nla_put_newdst(struct sk_buff *skb, int attrtype, int family,
+		   u8 labels, const u32 label[])
 {
-	unsigned len = nla_len(nla);
-	unsigned nla_labels;
-	struct mpls_shim_hdr *nla_label;
-	bool bos;
-	int i;
+	struct nlattr *nla;
+	struct rtnewdst *newdst;
 
-	/* len needs to be an even multiple of 4 (the label size) */
-	if (len & 3)
-		return -EINVAL;
+	nla = nla_reserve(skb, attrtype, 2 + (labels * 4));
+	if (!nla)
+		return -EMSGSIZE;
 
-	/* Limit the number of new labels allowed */
-	nla_labels = len/4;
-	if (nla_labels > max_labels)
-		return -EINVAL;
+	newdst = nla_data(nla);
+	newdst->family = family;
+
+	nla_put_labels(skb, &newdst->dst, labels, label);
+
+	return 0;
+}
+EXPORT_SYMBOL(nla_put_newdst);
+
+int nla_put_dst(struct sk_buff *skb, int attrtype, u8 labels,
+		const u32 label[])
+{
+	struct nlattr *nla;
+
+	nla = nla_reserve(skb, attrtype, labels * 4);
+	if (!nla)
+		return -EMSGSIZE;
+
+	nla_put_labels(skb, nla_data(nla), labels, label);
+
+	return 0;
+}
+
+int nla_get_labels(void *addr, u32 nla_labels, u32 *labels, u32 label[])
+{
+	struct mpls_shim_hdr *nla_label = addr;
+	bool bos;
+	int i;
 
-	nla_label = nla_data(nla);
 	bos = true;
 	for (i = nla_labels - 1; i >= 0; i--, bos = false) {
 		struct mpls_entry_decoded dec;
@@ -665,6 +680,54 @@ int nla_get_labels(const struct nlattr *nla,
 	return 0;
 }
 
+int nla_get_newdst(const struct nlattr *nla, u32 max_labels,
+		   u32 *labels, u32 label[])
+{
+	struct rtnewdst *newdst = nla_data(nla);
+	unsigned nla_labels;
+	unsigned len;
+
+	if (nla_len(nla) < offsetof(struct rtnewdst, dst))
+		return -EINVAL;
+
+	len = nla_len(nla) - sizeof(struct rtnewdst);
+
+	/* len needs to be an even multiple of 4 (the label size) */
+	if (len & 3)
+		return -EINVAL;
+
+	/* Limit the number of new labels allowed */
+	nla_labels = len / 4;
+	if (nla_labels > max_labels)
+		return -EINVAL;
+
+	nla_get_labels(&newdst->dst, nla_labels, labels, label);
+
+	return 0;
+}
+EXPORT_SYMBOL(nla_get_newdst);
+
+int nla_get_dst(const struct nlattr *nla,
+		u32 max_labels, u32 *labels, u32 label[])
+{
+	unsigned len = nla_len(nla);
+	unsigned nla_labels;
+
+	/* len needs to be an even multiple of 4 (the label size) */
+	if (len & 3)
+		return -EINVAL;
+
+	/* Limit the number of new labels allowed */
+	nla_labels = len / 4;
+	if (nla_labels > max_labels)
+		return -EINVAL;
+
+	nla_get_labels(nla_data(nla), nla_labels, labels, label);
+
+	return 0;
+}
+EXPORT_SYMBOL(nla_get_dst);
+
 static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			       struct mpls_route_config *cfg)
 {
@@ -721,7 +784,7 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			cfg->rc_ifindex = nla_get_u32(nla);
 			break;
 		case RTA_NEWDST:
-			if (nla_get_labels(nla, MAX_NEW_LABELS,
+			if (nla_get_newdst(nla, MAX_NEW_LABELS,
 					   &cfg->rc_output_labels,
 					   cfg->rc_output_label))
 				goto errout;
@@ -729,8 +792,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		case RTA_DST:
 		{
 			u32 label_count;
-			if (nla_get_labels(nla, 1, &label_count,
-					   &cfg->rc_label))
+			if (nla_get_dst(nla, 1, &label_count,
+					&cfg->rc_label))
 				goto errout;
 
 			/* The first 16 labels are reserved, and may not be set */
@@ -831,14 +894,15 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	rtm->rtm_flags = 0;
 
 	if (rt->rt_labels &&
-	    nla_put_labels(skb, RTA_NEWDST, rt->rt_labels, rt->rt_label))
+	    nla_put_newdst(skb, RTA_NEWDST, AF_MPLS, rt->rt_labels,
+			   rt->rt_label))
 		goto nla_put_failure;
 	if (nla_put_via(skb, rt->rt_via_table, rt->rt_via, rt->rt_via_alen))
 		goto nla_put_failure;
 	dev = rtnl_dereference(rt->rt_dev);
 	if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
 		goto nla_put_failure;
-	if (nla_put_labels(skb, RTA_DST, 1, &label))
+	if (nla_put_dst(skb, RTA_DST, 1, &label))
 		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index b064c34..99d7a79 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -49,7 +49,8 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
 	return result;
 }
 
-int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels, const u32 label[]);
-int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels, u32 label[]);
+int nla_put_labels(struct sk_buff *skb, void *addr,  u8 labels,
+		   const u32 label[]);
+int nla_get_labels(void *addr, u32 nla_labels, u32 *labels, u32 label[]);
 
 #endif /* MPLS_INTERNAL_H */
-- 
1.7.10.4
