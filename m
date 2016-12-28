From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net] rtnl: stats - add missing netlink message size checks
Date: Wed, 28 Dec 2016 17:52:15 +0100
Message-ID: <1482943935-18052-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:36312 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbcL1QxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:53:03 -0500
Received: by mail-wj0-f194.google.com with SMTP id j10so55090804wjb.3
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2016 08:52:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We miss to check if the netlink message is actually big enough to contain
a struct if_stats_msg.

Add a check to prevent userland from sending us short messages that would
make us access memory beyond the end of the message.

Fixes: 10c9ead9f3c6 ("rtnetlink: add new RTM_GETSTATS message to dump...")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/rtnetlink.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 18b5aae99bec..75e3ea7bda08 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3898,6 +3898,9 @@ static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u32 filter_mask;
 	int err;
 
+	if (nlmsg_len(nlh) < sizeof(*ifsm))
+		return -EINVAL;
+
 	ifsm = nlmsg_data(nlh);
 	if (ifsm->ifindex > 0)
 		dev = __dev_get_by_index(net, ifsm->ifindex);
@@ -3947,6 +3950,9 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	cb->seq = net->dev_base_seq;
 
+	if (nlmsg_len(cb->nlh) < sizeof(*ifsm))
+		return -EINVAL;
+
 	ifsm = nlmsg_data(cb->nlh);
 	filter_mask = ifsm->filter_mask;
 	if (!filter_mask)
-- 
1.7.10.4
