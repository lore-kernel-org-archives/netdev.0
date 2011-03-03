From: David Miller <davem@davemloft.net>
Subject: [v3 RFC PATCH 4/8] netlink: Add NLM_F_NOREPLY flags.
Date: Wed, 02 Mar 2011 17:02:02 -0800 (PST)
Message-ID: <20110302.170202.191408625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48859
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754533Ab1CCBBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 20:01:25 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4BA1224C087
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 17:02:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is used to bypass the response generation for "GET" type
operations.

This mechanism can then be used to allow a query operation to be used
in a "benchmarking" role, since the actual overhead of the netlink
communications will be muted.

The first query to support this is inet_rtm_getroute().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netlink.h |    2 ++
 net/ipv4/route.c        |    3 +++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index e2b9e63..a4bc8d2 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -61,6 +61,8 @@ struct nlmsghdr {
 #define NLM_F_CREATE	0x400	/* Create, if it does not exist	*/
 #define NLM_F_APPEND	0x800	/* Add to end of list		*/
 
+#define NLM_F_NOREPLY	0x1000	/* Do not generate reply	*/
+
 /*
    4.4BSD ADD		NLM_F_CREATE|NLM_F_EXCL
    4.4BSD CHANGE	NLM_F_REPLACE
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index efefefa..e59241f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2110,6 +2110,9 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		goto errout_free;
 
 	skb_dst_set(skb, &rt->dst);
+	if (nlh->nlmsg_flags & NLM_F_NOREPLY)
+		goto errout_free;
+
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-- 
1.7.4.1

