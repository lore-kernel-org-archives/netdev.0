From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Report TCP timetstamp info in cacheinfo just like
 ipv4 does.
Date: Thu, 29 Dec 2011 15:23:07 -0500 (EST)
Message-ID: <20111229.152307.2117046467310069170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421Ab1L2UXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 15:23:09 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBTKN7a3022095
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 12:23:08 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I missed this while adding ipv6 support to inet_peer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0940729..30de9e7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2360,11 +2360,13 @@ static int rt6_fill_node(struct net *net,
 			 int iif, int type, u32 pid, u32 seq,
 			 int prefix, int nowait, unsigned int flags)
 {
+	const struct inet_peer *peer;
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
 	long expires;
 	u32 table;
 	struct neighbour *n;
+	u32 ts, tsage;
 
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -2471,7 +2473,14 @@ static int rt6_fill_node(struct net *net,
 	else
 		expires = INT_MAX;
 
-	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0,
+	peer = rt->rt6i_peer;
+	ts = tsage = 0;
+	if (peer && peer->tcp_ts_stamp) {
+		ts = peer->tcp_ts;
+		tsage = get_seconds() - peer->tcp_ts_stamp;
+	}
+
+	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, ts, tsage,
 			       expires, rt->dst.error) < 0)
 		goto nla_put_failure;
 
-- 
1.7.7.4
