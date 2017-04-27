From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_rack_reo_timeout() must update
 tp->tcp_mstamp
Date: Wed, 26 Apr 2017 21:10:55 -0700
Message-ID: <1493266255.6453.103.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36580 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751603AbdD0EK5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 00:10:57 -0400
Received: by mail-pf0-f193.google.com with SMTP id v14so5587861pfd.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 21:10:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I wrongly assumed tp->tcp_mstamp was up to date at the time
tcp_rack_reo_timeout() was called.

It is not true, since we only update tcp->tcp_mstamp when receiving
a packet (as initially done in commit 69e996c58a35 ("tcp: add
tp->tcp_mstamp field")

tcp_rack_reo_timeout() being called by a timer and not an incoming
packet, we need to refresh tp->tcp_mstamp

Fixes: 7c1c7308592f ("tcp: do not pass timestamp to tcp_rack_detect_loss()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_recovery.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index cd72b3d3879e88181c8a4639f0334a24e4cda852..362b8c75bfab44cf87c2a01398a146a271bc1119 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -166,6 +166,7 @@ void tcp_rack_reo_timeout(struct sock *sk)
 	u32 timeout, prior_inflight;
 
 	prior_inflight = tcp_packets_in_flight(tp);
+	skb_mstamp_get(&tp->tcp_mstamp);
 	tcp_rack_detect_loss(sk, &timeout);
 	if (prior_inflight != tcp_packets_in_flight(tp)) {
 		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Recovery) {
