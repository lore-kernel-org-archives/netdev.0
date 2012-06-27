From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/18] decnet: dn_table: Move away from NLMSG_NEW().
Date: Tue, 26 Jun 2012 22:02:48 -0700 (PDT)
Message-ID: <20120626.220248.948479706991262607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2F0FCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:49 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id A2414584191
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/dn_table.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 650f338..92ec741 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -299,8 +299,10 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*rtm), flags);
-	rtm = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
+	if (!nlh)
+		goto out_nlmsg_trim;
+	rtm = nlmsg_data(nlh);
 	rtm->rtm_family = AF_DECnet;
 	rtm->rtm_dst_len = dst_len;
 	rtm->rtm_src_len = 0;
@@ -348,8 +350,7 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-
-nlmsg_failure:
+out_nlmsg_trim:
 rtattr_failure:
 	nlmsg_trim(skb, b);
 	return -EMSGSIZE;
@@ -476,7 +477,7 @@ int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		return 0;
 
 	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
-		((struct rtmsg *)NLMSG_DATA(cb->nlh))->rtm_flags&RTM_F_CLONED)
+		((struct rtmsg *)nlmsg_data(cb->nlh))->rtm_flags&RTM_F_CLONED)
 			return dn_cache_dump(skb, cb);
 
 	s_h = cb->args[0];
-- 
1.7.10.2
