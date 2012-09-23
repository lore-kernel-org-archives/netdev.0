From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: TCP Fast Open Server - record retransmits after 3WHS
Date: Sat, 22 Sep 2012 23:03:47 -0400
Message-ID: <1348369427-29563-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:44025 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258Ab2IWDDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 23:03:50 -0400
Received: by vbis24 with SMTP id s24so615389vbi.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 20:03:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When recording the number of SYNACK retransmits for servers using TCP
Fast Open, fix the code to ensure that we copy over the retransmit
count from the request_sock after we receive the ACK that completes
the 3-way handshake.

The story here is similar to that of SYNACK RTT
measurements. Previously we were always doing this in
tcp_v4_syn_recv_sock(). However, for TCP Fast Open connections
tcp_v4_conn_req_fastopen() calls tcp_v4_syn_recv_sock() at the time we
receive the SYN. So for TFO we must copy the final SYNACK retransmit
count in tcp_rcv_state_process().

Note that copying over the SYNACK retransmit count will give us the
correct count since, as is mentioned in a comment in
tcp_retransmit_timer(), before we receive an ACK for our SYN-ACK a TFO
passive connection does not retransmit anything else (e.g., data or
FIN segments).

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 36e069a1..e037697 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5985,6 +5985,8 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				 */
 				if (req) {
 					tcp_synack_rtt_meas(sk, req);
+					tp->total_retrans = req->retrans;
+
 					reqsk_fastopen_remove(sk, req, false);
 				} else {
 					/* Make sure socket is routed, for
-- 
1.7.7.3
