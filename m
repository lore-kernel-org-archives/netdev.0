From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] ipv4: avoid passing NULL to inet_putpeer() in icmpv4_xrlim_allow()
Date: Sat, 24 Nov 2012 23:54:37 -0500
Message-ID: <1353819277-2350-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f74.google.com ([74.125.83.74]:56588 "EHLO
	mail-ee0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625Ab2KYEyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2012 23:54:41 -0500
Received: by mail-ee0-f74.google.com with SMTP id t10so700436eei.1
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 20:54:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_getpeer_v4() can return NULL under OOM conditions, and while
inet_peer_xrlim_allow() is OK with a NULL peer, inet_putpeer() will
crash.

This code path now uses the same idiom as the others from:
1d861aa4b3fb08822055345f480850205ffe6170 ("inet: Minimize use of
cached route inetpeer.").

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/icmp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f2eccd5..17ff9fd 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -257,7 +257,8 @@ static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 		struct inet_peer *peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, 1);
 		rc = inet_peer_xrlim_allow(peer,
 					   net->ipv4.sysctl_icmp_ratelimit);
-		inet_putpeer(peer);
+		if (peer)
+			inet_putpeer(peer);
 	}
 out:
 	return rc;
-- 
1.7.7.3
