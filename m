From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH next] tcp: fastopen: fix rcv_wup initialization for TFO server on SYN/data
Date: Tue, 30 Aug 2016 11:55:23 -0400
Message-ID: <1472572523-10449-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:34884 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756463AbcH3Pze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 11:55:34 -0400
Received: by mail-qt0-f174.google.com with SMTP id 93so11373061qtg.2
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 08:55:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuchung noticed that on the first TFO server data packet sent after
the (TFO) handshake, the server echoed the TCP timestamp value in the
SYN/data instead of the timestamp value in the final ACK of the
handshake. This problem did not happen on regular opens.

The tcp_replace_ts_recent() logic that decides whether to remember an
incoming TS value needs tp->rcv_wup to hold the latest receive
sequence number that we have ACKed (latest tp->rcv_nxt we have
ACKed). This commit fixes this issue by ensuring that a TFO server
properly updates tp->rcv_wup to match tp->rcv_nxt at the time it sends
a SYN/ACK for the SYN/data.

Reported-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
---
 net/ipv4/tcp_fastopen.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 54d9f9b..62a5751 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -226,6 +226,7 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 	tcp_fastopen_add_skb(child, skb);
 
 	tcp_rsk(req)->rcv_nxt = tp->rcv_nxt;
+	tp->rcv_wup = tp->rcv_nxt;
 	/* tcp_conn_request() is sending the SYNACK,
 	 * and queues the child into listener accept queue.
 	 */
-- 
2.8.0.rc3.226.g39d4020
