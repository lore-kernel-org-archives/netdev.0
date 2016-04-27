From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 2/7] net: rtnetlink: allow only one idx saving stats attribute
Date: Wed, 27 Apr 2016 18:18:17 +0200
Message-ID: <1461773902-13528-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38524 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbcD0QSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:18:32 -0400
Received: by mail-wm0-f43.google.com with SMTP id u206so57102158wme.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 09:18:31 -0700 (PDT)
In-Reply-To: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't allow more than one stats attribute which uses the local idx
since the result will be a mess. This is a simple check to make sure
only one is being used at a time. Later when the filter_mask's 32 bits
are over we can switch to a bitmap.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/net/rtnetlink.h |  6 ++++++
 net/core/rtnetlink.c    | 17 +++++++++++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 2f87c1ba13de..3f3b0b1b8722 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -150,4 +150,10 @@ int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len);
 
 #define MODULE_ALIAS_RTNL_LINK(kind) MODULE_ALIAS("rtnl-link-" kind)
 
+/* at most one attribute which can save a local idx is allowed to be set
+ * IFLA_STATS_IDX_ATTR_MASK has all the idx saving attributes set and is
+ * used to check if more than one is being requested
+ */
+#define IFLA_STATS_IDX_ATTR_MASK 0
+
 #endif
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index aeb2fa9b1cda..ea03b6cd3d3c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3512,7 +3512,7 @@ static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct if_stats_msg *ifsm;
 	struct net_device *dev = NULL;
 	struct sk_buff *nskb;
-	u32 filter_mask;
+	u32 filter_mask, lidx_filter;
 	int lidx = 0;
 	int err;
 
@@ -3529,6 +3529,14 @@ static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!filter_mask)
 		return -EINVAL;
 
+	/* only one attribute which can save a local idx is allowed at a time
+	 * even though rtnl_stats_get doesn't save the lidx, we need to be
+	 * consistent with the dump side and error out
+	 */
+	lidx_filter = filter_mask & IFLA_STATS_IDX_ATTR_MASK;
+	if (lidx_filter && !is_power_of_2(lidx_filter))
+		return -EINVAL;
+
 	nskb = nlmsg_new(if_nlmsg_stats_size(dev, filter_mask), GFP_KERNEL);
 	if (!nskb)
 		return -ENOBUFS;
@@ -3556,7 +3564,7 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	struct hlist_head *head;
 	unsigned int flags = NLM_F_MULTI;
-	u32 filter_mask = 0;
+	u32 filter_mask = 0, lidx_filter;
 	int err;
 
 	s_h = cb->args[0];
@@ -3570,6 +3578,11 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	if (!filter_mask)
 		return -EINVAL;
 
+	/* only one attribute which can save a local idx is allowed at a time */
+	lidx_filter = filter_mask & IFLA_STATS_IDX_ATTR_MASK;
+	if (lidx_filter && !is_power_of_2(lidx_filter))
+		return -EINVAL;
+
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
-- 
2.4.11
