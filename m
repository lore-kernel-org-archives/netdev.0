From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] ip route: timeout for routes has to be set in seconds
Date: Wed, 29 Jun 2016 02:27:14 +0300
Message-ID: <1467156434-2157-1-git-send-email-avagin@openvz.org>
Cc: Andrew Vagin <avagin@virtuozzo.com>,
	Xin Long <lucien.xin@gmail.com>,
	Hangbin Liu <liuhangbin@gmail.com>,
	Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33954 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbcF1X1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 19:27:33 -0400
Received: by mail-pa0-f66.google.com with SMTP id us13so2812611pab.1
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 16:27:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Vagin <avagin@virtuozzo.com>

Currently a timeout is multiplied by HZ in user-space and
then it multiplied by HZ in kernel-space.

$ ./ip/ip r add 2002::0/64 dev veth1 expires 10
$ ./ip/ip -6 r
2002::/64 dev veth1  metric 1024 linkdown  expires 996sec pref medium

Cc: Xin Long <lucien.xin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
Cc: Stephen Hemminger <shemming@brocade.com>
Fixes: 68eede250500 ("route: allow routes to be configured with expire values")
Signed-off-by: Andrew Vagin <avagin@virtuozzo.com>
---
 ip/iproute.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8224d7f..7c0f5a4 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -839,7 +839,6 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 	int table_ok = 0;
 	int raw = 0;
 	int type_ok = 0;
-	static int hz;
 
 	memset(&req, 0, sizeof(req));
 
@@ -923,9 +922,7 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 			NEXT_ARG();
 			if (get_u32(&expires, *argv, 0))
 				invarg("\"expires\" value is invalid\n", *argv);
-			if (!hz)
-				hz = get_user_hz();
-			addattr32(&req.n, sizeof(req), RTA_EXPIRES, expires*hz);
+			addattr32(&req.n, sizeof(req), RTA_EXPIRES, expires);
 		} else if (matches(*argv, "metric") == 0 ||
 			   matches(*argv, "priority") == 0 ||
 			   strcmp(*argv, "preference") == 0) {
-- 
2.7.4
