From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] tcp: initialize rcv_mss to TCP_MIN_MSS instead of 0
Date: Thu, 18 May 2017 11:22:33 -0700
Message-ID: <20170518182233.100933-1-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33338 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdERSWh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 14:22:37 -0400
Received: by mail-pf0-f178.google.com with SMTP id e193so27718270pfh.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 11:22:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

When tcp_disconnect() is called, inet_csk_delack_init() sets
icsk->icsk_ack.rcv_mss to 0.
This could potentially cause tcp_recvmsg() => tcp_cleanup_rbuf() =>
__tcp_select_window() call path to have division by 0 issue.
So this patch initializes rcv_mss to TCP_MIN_MSS instead of 0.

Reported-by: Andrey Konovalov  <andreyknvl@google.com>
Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1e4c76d2b827..842b575f8fdd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2320,6 +2320,10 @@ int tcp_disconnect(struct sock *sk, int flags)
 	tcp_set_ca_state(sk, TCP_CA_Open);
 	tcp_clear_retrans(tp);
 	inet_csk_delack_init(sk);
+	/* Initialize rcv_mss to TCP_MIN_MSS to avoid division by 0
+	 * issue in __tcp_select_window()
+	 */
+	icsk->icsk_ack.rcv_mss = TCP_MIN_MSS;
 	tcp_init_send_head(sk);
 	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
 	__sk_dst_reset(sk);
-- 
2.13.0.303.g4ebf302169-goog
