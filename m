From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] utils: also check AF_INET family when rtm_type is RTN_MULTICAST
Date: Thu, 27 Jul 2017 17:01:49 +0800
Message-ID: <1501146109-30032-1-git-send-email-liuhangbin@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37555 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdG0JCU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 05:02:20 -0400
Received: by mail-pg0-f68.google.com with SMTP id k190so4179647pgk.4
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 02:02:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we get a multicast route, the rtm_type is RTN_MULTICAST, but the
rtm_family may be AF_INET. If we only check the type with RTNL_FAMILY_IPMR,
we will get malformed address. e.g.

+ ip -4 route add multicast 172.111.1.1 dev em1 table main

Before fix:
+ ip route list type multicast table main
multicast ac6f:101:800:400:400:0:3c00:0 dev em1 scope link

After fix:
+ ip route list type multicast table main
multicast 172.111.1.1 dev em1 scope link

Fixes: 56e3eb4c3400 ("ip: route: fix multicast route dumps")
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 lib/utils.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index e77bd30..0479e00 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -1215,5 +1215,6 @@ int get_real_family(int rtm_type, int rtm_family)
 	if (rtm_type != RTN_MULTICAST)
 		return rtm_family;
 
-	return rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
+	return (rtm_family == RTNL_FAMILY_IPMR ||
+		rtm_family == AF_INET) ? AF_INET : AF_INET6;
 }
-- 
2.5.5
