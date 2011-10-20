From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: use TCP_DEFAULT_INIT_RCVWND in
 tcp_fixup_rcvbuf()
Date: Thu, 20 Oct 2011 21:16:26 +0200
Message-ID: <1319138186.2854.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64315 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab1JTTQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 15:16:31 -0400
Received: by wwe6 with SMTP id 6so4647141wwe.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 12:16:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 356f039822b (TCP: increase default initial receive
window.), we allow sender to send 10 (TCP_DEFAULT_INIT_RCVWND) segments.

Change tcp_fixup_rcvbuf() to reflect this change, even if no real change 
is expected, since sysctl_tcp_rmem[1] = 87380 and this value
is bigger than tcp_fixup_rcvbuf() computed rcvmem (~23720)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_input.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1e848b2..5a29ecc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -345,17 +345,15 @@ static void tcp_grow_window(struct sock *sk, struct sk_buff *skb)
 
 static void tcp_fixup_rcvbuf(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	int rcvmem = SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
+	const struct tcp_sock *tp = tcp_sk(sk);
+	unsigned int mss = min_t(unsigned int, tp->advmss, 1460);
+	int rcvmem = SKB_TRUESIZE(mss + MAX_TCP_HEADER);
 
-	/* Try to select rcvbuf so that 4 mss-sized segments
-	 * will fit to window and corresponding skbs will fit to our rcvbuf.
-	 * (was 3; 4 is minimum to allow fast retransmit to work.)
-	 */
-	while (tcp_win_from_space(rcvmem) < tp->advmss)
+	while (tcp_win_from_space(rcvmem) < mss)
 		rcvmem += 128;
-	if (sk->sk_rcvbuf < 4 * rcvmem)
-		sk->sk_rcvbuf = min(4 * rcvmem, sysctl_tcp_rmem[2]);
+	rcvmem *= TCP_DEFAULT_INIT_RCVWND;
+	if (sk->sk_rcvbuf < rcvmem)
+		sk->sk_rcvbuf = min(rcvmem, sysctl_tcp_rmem[2]);
 }
 
 /* 4. Try to fixup all. It is made immediately after connection enters
