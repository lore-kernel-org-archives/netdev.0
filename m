From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH 06/10] ipv6: Avoid deleting RTF_CACHE route from ip6_route_del()
Date: Fri, 10 Apr 2015 18:54:09 -0700
Message-ID: <1428717253-1006248-7-git-send-email-kafai@fb.com>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37773 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753841AbbDKByc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:54:32 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t3B1ra79009407
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1tpry9032j-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:31 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 b1573798dfed11e4aeea0002c9521c9e-f31d32c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:54:30 -0700
In-Reply-To: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before patch 'Allow pmtu update on /128 via gateway route',
RTF_CACHE route was not created for DST_HOST.  It also requires changes on both
delete code path and rt6_select() code patch.

This patch fixes the delete code path to avoid deleting the RTF_CACHE
route by 'ip -6 r del...'

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 75f3b5d..5d0fd6c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1780,6 +1780,9 @@ static int ip6_route_del(struct fib6_config *cfg)
 
 	if (fn) {
 		for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
+			if ((rt->rt6i_flags & RTF_CACHE) &&
+			    !(cfg->fc_flags & RTF_CACHE))
+				continue;
 			if (cfg->fc_ifindex &&
 			    (!rt->dst.dev ||
 			     rt->dst.dev->ifindex != cfg->fc_ifindex))
@@ -2424,6 +2427,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (rtm->rtm_type == RTN_LOCAL)
 		cfg->fc_flags |= RTF_LOCAL;
 
+	if (rtm->rtm_flags & RTM_F_CLONED)
+		cfg->fc_flags |= RTF_CACHE;
+
 	cfg->fc_nlinfo.portid = NETLINK_CB(skb).portid;
 	cfg->fc_nlinfo.nlh = nlh;
 	cfg->fc_nlinfo.nl_net = sock_net(skb->sk);
-- 
1.8.1
