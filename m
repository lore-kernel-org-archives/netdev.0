From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/18] decnet: dn_route: Move away from NLMSG_NEW().
Date: Tue, 26 Jun 2012 22:02:44 -0700 (PDT)
Message-ID: <20120626.220244.719090025462954187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2F0FCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:46 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 87A29584196
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/dn_route.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 586302e..cd584f7 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1518,8 +1518,10 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	unsigned char *b = skb_tail_pointer(skb);
 	long expires;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
-	r = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
+	if (!nlh)
+		goto out_nlmsg_trim;
+	r = nlmsg_data(nlh);
 	r->rtm_family = AF_DECnet;
 	r->rtm_dst_len = 16;
 	r->rtm_src_len = 0;
@@ -1559,7 +1561,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-nlmsg_failure:
+out_nlmsg_trim:
 rtattr_failure:
 	nlmsg_trim(skb, b);
 	return -1;
@@ -1572,7 +1574,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct rtattr **rta = arg;
-	struct rtmsg *rtm = NLMSG_DATA(nlh);
+	struct rtmsg *rtm = nlmsg_data(nlh);
 	struct dn_route *rt = NULL;
 	struct dn_skb_cb *cb;
 	int err;
@@ -1669,7 +1671,7 @@ int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (NLMSG_PAYLOAD(cb->nlh, 0) < sizeof(struct rtmsg))
 		return -EINVAL;
-	if (!(((struct rtmsg *)NLMSG_DATA(cb->nlh))->rtm_flags&RTM_F_CLONED))
+	if (!(((struct rtmsg *)nlmsg_data(cb->nlh))->rtm_flags&RTM_F_CLONED))
 		return 0;
 
 	s_h = cb->args[0];
-- 
1.7.10.2
