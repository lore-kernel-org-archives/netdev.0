From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix regression in urgent data handling
Date: Tue, 18 Sep 2012 00:51:39 +0200
Message-ID: <1347922299.26523.198.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephan Springl <springl-k@lar.bfw.de>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:33450 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755374Ab2IQWvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 18:51:45 -0400
Received: by weyx8 with SMTP id x8so4194516wey.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 15:51:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Stephan Springl found that commit 1402d366019fed "tcp: introduce
tcp_try_coalesce" introduced a regression for rlogin

It turns out problem comes from TCP urgent data handling and
a change in behavior in input path.

rlogin sends two one-byte packets with URG ptr set, and when next data
frame is coalesced, we lack sk_data_ready() calls to wakeup consumer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Stephan Springl <springl-k@lar.bfw.de>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/tcp_input.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6e38c6c..d377f48 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4661,7 +4661,7 @@ queue_and_out:
 
 		if (eaten > 0)
 			kfree_skb_partial(skb, fragstolen);
-		else if (!sock_flag(sk, SOCK_DEAD))
+		if (!sock_flag(sk, SOCK_DEAD))
 			sk->sk_data_ready(sk, 0);
 		return;
 	}
@@ -5556,8 +5556,7 @@ no_ack:
 #endif
 			if (eaten)
 				kfree_skb_partial(skb, fragstolen);
-			else
-				sk->sk_data_ready(sk, 0);
+			sk->sk_data_ready(sk, 0);
 			return 0;
 		}
 	}
