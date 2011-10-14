From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: use TCP_INIT_CWND in tcp_fixup_sndbuf()
Date: Fri, 14 Oct 2011 06:24:42 +0200
Message-ID: <1318566282.2533.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57296 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948Ab1JNEYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 00:24:50 -0400
Received: by wwf22 with SMTP id 22so2828346wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 21:24:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial cwnd being 10 (TCP_INIT_CWND) instead of 3, change
tcp_fixup_sndbuf() to get more than 16384 bytes (sysctl_tcp_wmem[1]) in
initial sk_sndbuf

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
I believe a similar change in tcp_fixup_rcvbuf() is needed too.

 net/ipv4/tcp_input.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c1653fe..1e848b2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -267,11 +267,9 @@ static void tcp_fixup_sndbuf(struct sock *sk)
 {
 	int sndmem = SKB_TRUESIZE(tcp_sk(sk)->rx_opt.mss_clamp + MAX_TCP_HEADER);
 
-	if (sk->sk_sndbuf < 3 * sndmem) {
-		sk->sk_sndbuf = 3 * sndmem;
-		if (sk->sk_sndbuf > sysctl_tcp_wmem[2])
-			sk->sk_sndbuf = sysctl_tcp_wmem[2];
-	}
+	sndmem *= TCP_INIT_CWND;
+	if (sk->sk_sndbuf < sndmem)
+		sk->sk_sndbuf = min(sndmem, sysctl_tcp_wmem[2]);
 }
 
 /* 2. Tuning advertised window (window_clamp, rcv_ssthresh)
