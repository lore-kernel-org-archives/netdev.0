From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v3 1/4] net: rtnetlink: allow rtnl_fill_statsinfo to save private state counter
Date: Sat, 30 Apr 2016 10:25:26 +0200
Message-ID: <1462004729-12185-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1462004729-12185-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37427 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbcD3IZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 04:25:43 -0400
Received: by mail-wm0-f47.google.com with SMTP id a17so69059079wme.0
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 01:25:42 -0700 (PDT)
In-Reply-To: <1462004729-12185-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new prividx argument allows the current dumping device to save a
private state counter which would enable it to continue dumping from
where it left off. And the idxattr is used to save the current idx user
so multiple prividx using attributes can be requested at the same time
as suggested by Roopa Prabhu.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v3: no change
v2: improve the error check in rtnl_fill_statsinfo, rename lidx to
prividx, squash patch 2 into this one and save the current idx user
instead of restricting only one

 net/core/rtnetlink.c | 44 +++++++++++++++++++++++++++++++-------------
 1 file changed, 31 insertions(+), 13 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5503dfe6a050..de529a20cd18 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3444,13 +3444,21 @@ out:
 	return err;
 }
 
+static bool stats_attr_valid(unsigned int mask, int attrid, int idxattr)
+{
+	return (mask & IFLA_STATS_FILTER_BIT(attrid)) &&
+	       (!idxattr || idxattr == attrid);
+}
+
 static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 			       int type, u32 pid, u32 seq, u32 change,
-			       unsigned int flags, unsigned int filter_mask)
+			       unsigned int flags, unsigned int filter_mask,
+			       int *idxattr, int *prividx)
 {
 	struct if_stats_msg *ifsm;
 	struct nlmsghdr *nlh;
 	struct nlattr *attr;
+	int s_prividx = *prividx;
 
 	ASSERT_RTNL();
 
@@ -3462,7 +3470,7 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 	ifsm->ifindex = dev->ifindex;
 	ifsm->filter_mask = filter_mask;
 
-	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64)) {
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_64, *idxattr)) {
 		struct rtnl_link_stats64 *sp;
 
 		attr = nla_reserve_64bit(skb, IFLA_STATS_LINK_64,
@@ -3480,7 +3488,11 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 
 nla_put_failure:
-	nlmsg_cancel(skb, nlh);
+	/* not a multi message or no progress mean a real error */
+	if (!(flags & NLM_F_MULTI) || s_prividx == *prividx)
+		nlmsg_cancel(skb, nlh);
+	else
+		nlmsg_end(skb, nlh);
 
 	return -EMSGSIZE;
 }
@@ -3494,7 +3506,7 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 {
 	size_t size = 0;
 
-	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64))
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_64, 0))
 		size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
 
 	return size;
@@ -3503,8 +3515,9 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
-	struct if_stats_msg *ifsm;
 	struct net_device *dev = NULL;
+	int idxattr = 0, prividx = 0;
+	struct if_stats_msg *ifsm;
 	struct sk_buff *nskb;
 	u32 filter_mask;
 	int err;
@@ -3528,7 +3541,7 @@ static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	err = rtnl_fill_statsinfo(nskb, dev, RTM_NEWSTATS,
 				  NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
-				  0, filter_mask);
+				  0, filter_mask, &idxattr, &prividx);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_stats_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -3542,18 +3555,19 @@ static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	int h, s_h, err, s_idx, s_idxattr, s_prividx;
 	struct net *net = sock_net(skb->sk);
+	unsigned int flags = NLM_F_MULTI;
 	struct if_stats_msg *ifsm;
-	int h, s_h;
-	int idx = 0, s_idx;
-	struct net_device *dev;
 	struct hlist_head *head;
-	unsigned int flags = NLM_F_MULTI;
+	struct net_device *dev;
 	u32 filter_mask = 0;
-	int err;
+	int idx = 0;
 
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
+	s_idxattr = cb->args[2];
+	s_prividx = cb->args[3];
 
 	cb->seq = net->dev_base_seq;
 
@@ -3571,7 +3585,8 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			err = rtnl_fill_statsinfo(skb, dev, RTM_NEWSTATS,
 						  NETLINK_CB(cb->skb).portid,
 						  cb->nlh->nlmsg_seq, 0,
-						  flags, filter_mask);
+						  flags, filter_mask,
+						  &s_idxattr, &s_prividx);
 			/* If we ran out of room on the first message,
 			 * we're in trouble
 			 */
@@ -3579,13 +3594,16 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 			if (err < 0)
 				goto out;
-
+			s_prividx = 0;
+			s_idxattr = 0;
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
 		}
 	}
 out:
+	cb->args[3] = s_prividx;
+	cb->args[2] = s_idxattr;
 	cb->args[1] = idx;
 	cb->args[0] = h;
 
-- 
2.4.11
