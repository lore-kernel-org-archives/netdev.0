From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2] utils: return default family when rtm_family is not RTNL_FAMILY_IPMR/IP6MR
Date: Thu, 27 Jul 2017 17:44:15 +0800
Message-ID: <1501148655-32629-1-git-send-email-liuhangbin@gmail.com>
References: <1501146109-30032-1-git-send-email-liuhangbin@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33089 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdG0Jox (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 05:44:53 -0400
Received: by mail-pg0-f68.google.com with SMTP id 123so9423632pgj.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 02:44:53 -0700 (PDT)
In-Reply-To: <1501146109-30032-1-git-send-email-liuhangbin@gmail.com>
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
 lib/utils.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index e77bd30..9aa3219 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -1215,5 +1215,11 @@ int get_real_family(int rtm_type, int rtm_family)
 	if (rtm_type != RTN_MULTICAST)
 		return rtm_family;
 
-	return rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
+	if (rtm_family == RTNL_FAMILY_IPMR)
+		return AF_INET;
+
+	if (rtm_family == RTNL_FAMILY_IP6MR)
+		return AF_INET6;
+
+	return rtm_family;
 }
-- 
2.5.5
