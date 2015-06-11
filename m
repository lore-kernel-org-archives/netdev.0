From: Mazhar Rana <ranamazharp@gmail.com>
Subject: [PATCH iproute2] mroute: "ip mroute show" not working when "to" and/or "from" is given
Date: Thu, 11 Jun 2015 21:37:36 +0530
Message-ID: <1434038856-18054-1-git-send-email-ranamazharp@gmail.com>
Cc: Mazhar Rana <ranamazharp@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34857 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbbFKQI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 12:08:28 -0400
Received: by pabli10 with SMTP id li10so2389206pab.2
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 09:08:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The command "ip mroute show" is not showing routes when "to" and/or "from"
filter is applied.

root@mazhar:~# ip mroute show
(10.202.30.101, 235.1.2.3)       Iif: eth0       Oifs: eth1

But When I applied filter, it does not show anything.

root@mazhar:~# ip mroute show 235.1.2.3 from 10.202.30.101
root@mazhar:~#

Signed-off-by: Mazhar Rana <ranamazharp@gmail.com>
---
 ip/ipmroute.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index 125a13f..fffa9e2 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -97,15 +97,25 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (filter.af && filter.af != r->rtm_family)
 		return 0;
 
-	if (tb[RTA_DST] &&
-	    filter.mdst.bitlen > 0 &&
-	    inet_addr_match(RTA_DATA(tb[RTA_DST]), &filter.mdst, filter.mdst.bitlen))
-		return 0;
+	if (tb[RTA_DST] && filter.mdst.bitlen > 0) {
+		inet_prefix dst;
+
+		memset(&dst, 0, sizeof(dst));
+		dst.family = r->rtm_family;
+		memcpy(&dst.data, RTA_DATA(tb[RTA_DST]), RTA_PAYLOAD(tb[RTA_DST]));
+		if (inet_addr_match(&dst, &filter.mdst, filter.mdst.bitlen))
+			return 0;
+	}
 
-	if (tb[RTA_SRC] &&
-	    filter.msrc.bitlen > 0 &&
-	    inet_addr_match(RTA_DATA(tb[RTA_SRC]), &filter.msrc, filter.msrc.bitlen))
-		return 0;
+	if (tb[RTA_SRC] && filter.msrc.bitlen > 0) {
+		inet_prefix src;
+
+		memset(&src, 0, sizeof(src));
+		src.family = r->rtm_family;
+		memcpy(&src.data, RTA_DATA(tb[RTA_SRC]), RTA_PAYLOAD(tb[RTA_SRC]));
+		if (inet_addr_match(&src, &filter.msrc, filter.msrc.bitlen))
+			return 0;
+	}
 
 	family = r->rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
 
-- 
1.9.1
