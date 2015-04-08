From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not rearm rsk_timer on FastOpen requests
Date: Wed, 08 Apr 2015 15:34:04 -0700
Message-ID: <1428532444.25985.231.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35233 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722AbbDHWeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 18:34:06 -0400
Received: by iggg4 with SMTP id g4so52624402igg.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 15:34:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

FastOpen requests are not like other regular request sockets.

They do not yet use rsk_timer : tcp_fastopen_queue_check()
simply manually removes one expired request from fastopenq->rskq_rst
list.

Therefore, tcp_check_req() must not call mod_timer_pending(),
otherwise we crash because rsk_timer was not initialized.

Fixes: fa76ce7328b ("inet: get rid of central tcp/dccp listener timer")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_minisocks.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index d7003911c894075c209756a0ce26950a6a31aba4..2088fdcca14140f23aa01f60a1675c116f734a57 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -628,10 +628,16 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 					  LINUX_MIB_TCPACKSKIPPEDSYNRECV,
 					  &tcp_rsk(req)->last_oow_ack_time) &&
 
-		    !inet_rtx_syn_ack(sk, req))
-			mod_timer_pending(&req->rsk_timer, jiffies +
-				min(TCP_TIMEOUT_INIT << req->num_timeout,
-				    TCP_RTO_MAX));
+		    !inet_rtx_syn_ack(sk, req)) {
+			unsigned long expires = jiffies;
+
+			expires += min(TCP_TIMEOUT_INIT << req->num_timeout,
+				       TCP_RTO_MAX);
+			if (!fastopen)
+				mod_timer_pending(&req->rsk_timer, expires);
+			else
+				req->rsk_timer.expires = expires;
+		}
 		return NULL;
 	}
 
