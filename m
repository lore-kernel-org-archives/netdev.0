From: Denis Ovsienko <infrastation@yandex.ru>
Subject: [PATCH] ipv6: fix RTPROT_RA markup of RA routes w/nexthops
Date: Tue, 10 Jul 2012 18:45:50 +0400
Message-ID: <20120710184550.7a5a8d89802473b4c28d07bf@yandex.ru>
References: <1405671341819473@web18d.yandex.ru>
	<20120709.144002.6394436211445151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward16.mail.yandex.net ([95.108.253.141]:35707 "EHLO
	forward16.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab2GJOxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 10:53:17 -0400
Received: from smtp17.mail.yandex.net (smtp17.mail.yandex.net [95.108.252.17])
	by forward16.mail.yandex.net (Yandex) with ESMTP id 69359D216D5
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 18:45:51 +0400 (MSK)
Received: from smtp17.mail.yandex.net (localhost [127.0.0.1])
	by smtp17.mail.yandex.net (Yandex) with ESMTP id 56BB819003A1
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 18:45:51 +0400 (MSK)
In-Reply-To: <20120709.144002.6394436211445151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Ovsienko <infrastation@yandex.ru>

Userspace implementations of network routing protocols sometimes need to
tell RA-originated IPv6 routes from other kernel routes to make proper
routing decisions. This makes most sense for RA routes with nexthops,
namely, default routes and Route Information routes.

The intended mean of preserving RA route origin in a netlink message is
through indicating RTPROT_RA as protocol code. Function rt6_fill_node()
tried to do that for default routes, but its test condition was taken
wrong. This change is modeled after the original mailing list posting
by Jeff Haran. It fixes the test condition for default route case and
sets the same behaviour for Route Information case (both types use
nexthops). Handling of the 3rd RA route type, Prefix Information, is
left unchanged, as it stands for interface connected routes (without
nexthops).

Signed-off-by: Denis Ovsienko <infrastation@yandex.ru>
---
 net/ipv6/route.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 999a982..238b1ee 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2440,10 +2440,12 @@ static int rt6_fill_node(struct net *net,
 	rtm->rtm_protocol = rt->rt6i_protocol;
 	if (rt->rt6i_flags & RTF_DYNAMIC)
 		rtm->rtm_protocol = RTPROT_REDIRECT;
-	else if (rt->rt6i_flags & RTF_ADDRCONF)
-		rtm->rtm_protocol = RTPROT_KERNEL;
-	else if (rt->rt6i_flags & RTF_DEFAULT)
-		rtm->rtm_protocol = RTPROT_RA;
+	else if (rt->rt6i_flags & RTF_ADDRCONF) {
+		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
+			rtm->rtm_protocol = RTPROT_RA;
+		else
+			rtm->rtm_protocol = RTPROT_KERNEL;
+	}
 
 	if (rt->rt6i_flags & RTF_CACHE)
 		rtm->rtm_flags |= RTM_F_CLONED;
-- 
1.7.7.6
