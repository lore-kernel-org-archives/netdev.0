From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH iproute2] ip route: restore_handler should check tb[RTA_PREFSRC] for local networks
Date: Sun,  7 Aug 2016 17:12:30 +0800
Message-ID: <f805ffe5dad63ae04330df32bbe6cf532a6772b7.1470561150.git.lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>, stephen@networkplumber.org,
	phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35269 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbcHGJMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 05:12:36 -0400
Received: by mail-pf0-f194.google.com with SMTP id h186so22932811pfg.2
        for <netdev@vger.kernel.org>; Sun, 07 Aug 2016 02:12:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch, If one route entry's RTA_PREFSRC and RTA_GATEWAY
both were NULL, it was supposed to be restored ONLY as a local address.

But as it didn't check tb[RTA_PREFSRC] when restoring local networks,
rtattr_cmp would return a success if it was NULL, this route entry would
be restored again as a local network.

This patch is to add tb[RTA_PREFSRC] check when restoring local networks.

Fixes: 74af8dd9620e ("ip route: restore route entries in correct order")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index c52294d..3da23af 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1813,7 +1813,7 @@ static int restore_handler(const struct sockaddr_nl *nl,
 	if (!prio && !tb[RTA_GATEWAY] && (!tb[RTA_PREFSRC] ||
 	    !rtattr_cmp(tb[RTA_PREFSRC], tb[RTA_DST])))
 		goto restore;
-	else if (prio == 1 && !tb[RTA_GATEWAY] &&
+	else if (prio == 1 && !tb[RTA_GATEWAY] && tb[RTA_PREFSRC] &&
 		 rtattr_cmp(tb[RTA_PREFSRC], tb[RTA_DST]))
 		goto restore;
 	else if (prio == 2 && tb[RTA_GATEWAY])
-- 
2.1.0
