From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net] tcp: md5: release request socket instead of listener
Date: Thu, 11 Feb 2016 22:50:29 -0800
Message-ID: <1455259829-17501-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34955 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbcBLGue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 01:50:34 -0500
Received: by mail-pa0-f52.google.com with SMTP id ho8so42271429pac.2
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 22:50:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If tcp_v4_inbound_md5_hash() returns an error, we must release
the refcount on the request socket, not on the listener.

The bug was added for IPv4 only.

Fixes: 079096f103fac ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7f6ff037adaf..c84477949d3a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1600,8 +1600,10 @@ process:
 		struct sock *nsk = NULL;
 
 		sk = req->rsk_listener;
-		if (tcp_v4_inbound_md5_hash(sk, skb))
-			goto discard_and_relse;
+		if (unlikely(tcp_v4_inbound_md5_hash(sk, skb))) {
+			reqsk_put(req);
+			goto discard_it;
+		}
 		if (likely(sk->sk_state == TCP_LISTEN)) {
 			nsk = tcp_check_req(sk, skb, req, false);
 		} else {
-- 
2.7.0.rc3.207.g0ac5344
