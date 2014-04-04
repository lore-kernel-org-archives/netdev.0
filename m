From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2 v2] ipaddress: do not add IFA_FLAGS when not necessary
Date: Fri,  4 Apr 2014 10:07:20 -0700
Message-ID: <1396631240-14924-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:63528 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbaDDRHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 13:07:37 -0400
Received: by mail-pa0-f52.google.com with SMTP id rd3so3758982pab.11
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 10:07:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 37c9b94ed21d5779acc23d89a4 (add support for extended ifa_flags)
introduced a regression:

        # ./ip/ip addr add 192.168.0.1/24 dev eth0
        RTNETLINK answers: Invalid argument

This is due to old kernels don't support IFA_FLAGS flag, we should not
use it if we don't use the flags beyond old .ifa_flags.

Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 14d1720..e3be5b2 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1398,8 +1398,10 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 		}
 		argc--; argv++;
 	}
-	req.ifa.ifa_flags = ifa_flags;
-	addattr32(&req.n, sizeof(req), IFA_FLAGS, ifa_flags);
+	if (ifa_flags <= 0xff)
+		req.ifa.ifa_flags = ifa_flags;
+	else
+		addattr32(&req.n, sizeof(req), IFA_FLAGS, ifa_flags);
 
 	if (d == NULL) {
 		fprintf(stderr, "Not enough information: \"dev\" argument is required.\n");
