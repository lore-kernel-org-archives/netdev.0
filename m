From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] tcp: fix regression in urgent data handling
Date: Tue, 18 Sep 2012 09:54:10 +0200
Message-ID: <1347954850.26523.211.camel@edumazet-glaptop>
References: <1347922299.26523.198.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephan Springl <springl-k@bfw-online.de>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36023 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab2IRHyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 03:54:17 -0400
Received: by bkwj10 with SMTP id j10so2947477bkw.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 00:54:15 -0700 (PDT)
In-Reply-To: <1347922299.26523.198.camel@edumazet-glaptop>
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
Reported-by: Stephan Springl <springl-k@bfw-online.de>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
v2: Changed Stephan Springl email address in changelog/CC

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
