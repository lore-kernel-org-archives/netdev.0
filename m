From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/7] net: rtnetlink: allow rtnl_fill_statsinfo to save private state counter
Date: Wed, 27 Apr 2016 18:18:16 +0200
Message-ID: <1461773902-13528-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37525 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbcD0QSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:18:30 -0400
Received: by mail-wm0-f42.google.com with SMTP id a17so22920436wme.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 09:18:30 -0700 (PDT)
In-Reply-To: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new lidx argument allows the current dumping device to save a
private state counter which would enable it to continue dumping from
where it left off.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5ec059d52823..aeb2fa9b1cda 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3446,11 +3446,13 @@ out:
 
 static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 			       int type, u32 pid, u32 seq, u32 change,
-			       unsigned int flags, unsigned int filter_mask)
+			       unsigned int flags, unsigned int filter_mask,
+			       int *lidx)
 {
 	struct if_stats_msg *ifsm;
 	struct nlmsghdr *nlh;
 	struct nlattr *attr;
+	int s_lidx = *lidx;
 
 	ASSERT_RTNL();
 
@@ -3480,7 +3482,11 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 
 nla_put_failure:
-	nlmsg_cancel(skb, nlh);
+	/* If we haven't made progress, it's a real error */
+	if (s_lidx == *lidx)
+		nlmsg_cancel(skb, nlh);
+	else
+		nlmsg_end(skb, nlh);
 
 	return -EMSGSIZE;
 }
@@ -3507,6 +3513,7 @@ static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct net_device *dev = NULL;
 	struct sk_buff *nskb;
 	u32 filter_mask;
+	int lidx = 0;
 	int err;
 
 	ifsm = nlmsg_data(nlh);
@@ -3528,7 +3535,7 @@ static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	err = rtnl_fill_statsinfo(nskb, dev, RTM_NEWSTATS,
 				  NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
-				  0, filter_mask);
+				  0, filter_mask, &lidx);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_stats_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -3545,7 +3552,7 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = sock_net(skb->sk);
 	struct if_stats_msg *ifsm;
 	int h, s_h;
-	int idx = 0, s_idx;
+	int idx = 0, s_idx, s_lidx;
 	struct net_device *dev;
 	struct hlist_head *head;
 	unsigned int flags = NLM_F_MULTI;
@@ -3554,6 +3561,7 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
+	s_lidx = cb->args[2];
 
 	cb->seq = net->dev_base_seq;
 
@@ -3571,7 +3579,7 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			err = rtnl_fill_statsinfo(skb, dev, RTM_NEWSTATS,
 						  NETLINK_CB(cb->skb).portid,
 						  cb->nlh->nlmsg_seq, 0,
-						  flags, filter_mask);
+						  flags, filter_mask, &s_lidx);
 			/* If we ran out of room on the first message,
 			 * we're in trouble
 			 */
@@ -3579,13 +3587,14 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 			if (err < 0)
 				goto out;
-
+			s_lidx = 0;
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
 		}
 	}
 out:
+	cb->args[2] = s_lidx;
 	cb->args[1] = idx;
 	cb->args[0] = h;
 
-- 
2.4.11
