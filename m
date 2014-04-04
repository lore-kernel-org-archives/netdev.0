From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2] ipaddress: do not add ifa_flags when not necessary
Date: Thu,  3 Apr 2014 23:05:03 -0700
Message-ID: <1396591503-16632-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:47926 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbaDDGFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 02:05:11 -0400
Received: by mail-pa0-f47.google.com with SMTP id lj1so2984370pab.20
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 23:05:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 37c9b94ed21d5779acc23d89a4 (add support for extended ifa_flags)
introduced a regression:

	# ./ip/ip addr add 192.168.0.1/24 dev eth0
	RTNETLINK answers: Invalid argument

This is due to old kernels don't support IFA_FLAGS flag, it should be skipped
if we don't use this feature at all.

Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 14d1720..71ae8f3 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1398,8 +1398,10 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 		}
 		argc--; argv++;
 	}
-	req.ifa.ifa_flags = ifa_flags;
-	addattr32(&req.n, sizeof(req), IFA_FLAGS, ifa_flags);
+	if (ifa_flags) {
+		req.ifa.ifa_flags = ifa_flags;
+		addattr32(&req.n, sizeof(req), IFA_FLAGS, ifa_flags);
+	}
 
 	if (d == NULL) {
 		fprintf(stderr, "Not enough information: \"dev\" argument is required.\n");
