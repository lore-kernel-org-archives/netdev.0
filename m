From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 3/3] net/tcp_fastopen: Remove mss check in tcp_write_timeout()
Date: Thu, 20 Apr 2017 14:45:48 -0700
Message-ID: <20170420214548.23666-4-tracywwnj@gmail.com>
References: <20170420214548.23666-1-tracywwnj@gmail.com>
 <20170420214548.23666-2-tracywwnj@gmail.com>
 <20170420214548.23666-3-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34409 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034119AbdDTVrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 17:47:11 -0400
Received: by mail-oi0-f44.google.com with SMTP id x184so70042502oia.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 14:47:11 -0700 (PDT)
In-Reply-To: <20170420214548.23666-3-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Christoph Paasch from Apple found another firewall issue for TFO:
After successful 3WHS using TFO, server and client starts to exchange
data. Afterwards, a 10s idle time occurs on this connection. After that,
firewall starts to drop every packet on this connection.

The fix for this issue is to extend existing firewall blackhole detection
logic in tcp_write_timeout() by removing the mss check.

Signed-off-by: Wei Wang <weiwan@google.com>
---
 net/ipv4/tcp_timer.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b2ab411c6d37..14672543cf0b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -201,11 +201,10 @@ static int tcp_write_timeout(struct sock *sk)
 		if (retransmits_timed_out(sk, net->ipv4.sysctl_tcp_retries1, 0, 0)) {
 			/* Some middle-boxes may black-hole Fast Open _after_
 			 * the handshake. Therefore we conservatively disable
-			 * Fast Open on this path on recurring timeouts with
-			 * few or zero bytes acked after Fast Open.
+			 * Fast Open on this path on recurring timeouts after
+			 * successful Fast Open.
 			 */
-			if (tp->syn_data_acked &&
-			    tp->bytes_acked <= tp->rx_opt.mss_clamp) {
+			if (tp->syn_data_acked) {
 				tcp_fastopen_cache_set(sk, 0, NULL, true, 0);
 				if (icsk->icsk_retransmits == net->ipv4.sysctl_tcp_retries1)
 					NET_INC_STATS(sock_net(sk),
-- 
2.12.2.816.g2cccc81164-goog
