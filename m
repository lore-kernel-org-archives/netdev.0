From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] tcp: update the netstamp_needed counter when cloning sockets
Date: Wed,  6 Jan 2010 01:06:30 +0200
Message-ID: <1262732790-16053-1-git-send-email-opurdila@ixiacom.com>
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:14437 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754255Ab0AEXJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 18:09:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a netstamp_needed accounting issue when the listen socket
has SO_TIMESTAMP set:

    s = socket(AF_INET, SOCK_STREAM, 0);
    setsockopt(s, SOL_SOCKET, SO_TIMESTAMP, 1); -> netstamp_needed = 1
    bind(s, ...);
    listen(s, ...);
    s2 = accept(s, ...); -> netstamp_needed = 1
    close(s2); -> netstamp_needed = 0
    close(s); -> netstamp_needed = -1

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/core/sock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 76ff58d..e1f6f22 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1205,6 +1205,10 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 
 		if (newsk->sk_prot->sockets_allocated)
 			percpu_counter_inc(newsk->sk_prot->sockets_allocated);
+
+		if (sock_flag(newsk, SOCK_TIMESTAMP) ||
+		    sock_flag(newsk, SOCK_TIMESTAMPING_RX_SOFTWARE))
+			net_enable_timestamp();
 	}
 out:
 	return newsk;
-- 
1.5.6.5

