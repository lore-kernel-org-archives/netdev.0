From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: use TCP_DEFAULT_INIT_RCVWND in
 tcp_fixup_rcvbuf()
Date: Thu, 20 Oct 2011 22:41:21 +0200
Message-ID: <1319143281.2854.25.camel@edumazet-laptop>
References: <1319138186.2854.5.camel@edumazet-laptop>
	 <20111020.155002.555965434596006787.davem@davemloft.net>
	 <1319140954.2854.12.camel@edumazet-laptop>
	 <20111020.161356.2120784879469409197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:44099 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab1JTUl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:41:27 -0400
Received: by wwn22 with SMTP id 22so31944wwn.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 13:41:26 -0700 (PDT)
In-Reply-To: <20111020.161356.2120784879469409197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 356f039822b (TCP: increase default initial receive
window.), we allow sender to send 10 (TCP_DEFAULT_INIT_RCVWND) segments.

Change tcp_fixup_rcvbuf() to reflect this change, even if no real change
is expected, since sysctl_tcp_rmem[1] = 87380 and this value
is bigger than tcp_fixup_rcvbuf() computed rcvmem (~23720)

Note: Since commit 356f039822b limited default window to maximum of
10*1460 and 2*MSS, we use same heuristic in this patch.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_input.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1e848b2..e8e6d49 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -345,17 +345,24 @@ static void tcp_grow_window(struct sock *sk, struct sk_buff *skb)
 
 static void tcp_fixup_rcvbuf(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	int rcvmem = SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
+	u32 mss = tcp_sk(sk)->advmss;
+	u32 icwnd = TCP_DEFAULT_INIT_RCVWND;
+	int rcvmem;
 
-	/* Try to select rcvbuf so that 4 mss-sized segments
-	 * will fit to window and corresponding skbs will fit to our rcvbuf.
-	 * (was 3; 4 is minimum to allow fast retransmit to work.)
+	/* Limit to 10 segments if mss <= 1460,
+	 * or 14600/mss segments, with a minimum of two segments.
 	 */
-	while (tcp_win_from_space(rcvmem) < tp->advmss)
+	if (mss > 1460)
+		icwnd = max_t(u32, (1460 * TCP_DEFAULT_INIT_RCVWND) / mss, 2);
+
+	rcvmem = SKB_TRUESIZE(mss + MAX_TCP_HEADER);
+	while (tcp_win_from_space(rcvmem) < mss)
 		rcvmem += 128;
-	if (sk->sk_rcvbuf < 4 * rcvmem)
-		sk->sk_rcvbuf = min(4 * rcvmem, sysctl_tcp_rmem[2]);
+
+	rcvmem *= icwnd;
+
+	if (sk->sk_rcvbuf < rcvmem)
+		sk->sk_rcvbuf = min(rcvmem, sysctl_tcp_rmem[2]);
 }
 
 /* 4. Try to fixup all. It is made immediately after connection enters
