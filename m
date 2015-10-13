From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] route: fib_validate_source remove the <= RT_SCOPE_HOST test
Date: Wed, 14 Oct 2015 00:40:04 +0800
Message-ID: <a9569cddcdeb5f0b7d138a22086f76f1b9e5acd5.1444754404.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34861 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbbJMQkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 12:40:08 -0400
Received: by pabve7 with SMTP id ve7so26391333pab.2
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 09:40:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fe3edf45792a ("ipv4: Remove all RTCF_DIRECTSRC handliing.").

Before this commit, we had a tristate:
< 0: error
0: ok
1: ok and set RTCF_DIRECTSRC

But now we only care about 0 or < 0.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/fib_frontend.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index d7c2bb0..f5c74d8 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -376,22 +376,14 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	if (FIB_RES_DEV(res) == dev)
 		dev_match = true;
 #endif
-	if (dev_match) {
-		ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
-		return ret;
-	}
+	if (dev_match)
+		return 0;
 	if (no_addr)
 		goto last_resort;
 	if (rpf == 1)
 		goto e_rpf;
-	fl4.flowi4_oif = dev->ifindex;
 
-	ret = 0;
-	if (fib_lookup(net, &fl4, &res, FIB_LOOKUP_IGNORE_LINKSTATE) == 0) {
-		if (res.type == RTN_UNICAST)
-			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
-	}
-	return ret;
+	return 0;
 
 last_resort:
 	if (rpf)
-- 
2.1.0
