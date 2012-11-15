From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] tcp: fix retransmission in repair mode
Date: Thu, 15 Nov 2012 18:03:17 +0400
Message-ID: <1352988197-14414-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, linux-kernel@vger.kernel.org,
	Andrew Vagin <avagin@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Vagin <avagin@openvz.org>

Currently if a socket was repaired with a few packet in a write queue,
a kernel bug may be triggered:

kernel BUG at net/ipv4/tcp_output.c:2330!
RIP: 0010:[<ffffffff8155784f>] tcp_retransmit_skb+0x5ff/0x610

According to the initial realization v3.4-rc2-963-gc0e88ff,
all skb-s should look like already posted. This patch fixes code
according with this sentence.

Here are three points, which were not done in the initial patch:
1. A tcp send head should not be changed
2. Initialize TSO state of a skb
3. Reset the retransmission time

This patch moves logic from tcp_sendmsg to tcp_write_xmit. A packet
passes the ussual way, but isn't sent to network. This patch solves
all described problems and handles tcp_sendpages.

Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/ipv4/tcp.c        | 4 ++--
 net/ipv4/tcp_output.c | 4 ++++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 197c000..083092e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1212,7 +1212,7 @@ new_segment:
 wait_for_sndbuf:
 			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
-			if (copied && likely(!tp->repair))
+			if (copied)
 				tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
 
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
@@ -1223,7 +1223,7 @@ wait_for_memory:
 	}
 
 out:
-	if (copied && likely(!tp->repair))
+	if (copied)
 		tcp_push(sk, flags, mss_now, tp->nonagle);
 	release_sock(sk);
 	return copied + copied_syn;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cfe6ffe..2798706 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1986,6 +1986,9 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
 		BUG_ON(!tso_segs);
 
+		if (unlikely(tp->repair) && tp->repair_queue == TCP_SEND_QUEUE)
+			goto repair; /* Skip network transmission */
+
 		cwnd_quota = tcp_cwnd_test(tp, skb);
 		if (!cwnd_quota)
 			break;
@@ -2026,6 +2029,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
 			break;
 
+repair:
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.
 		 */
-- 
1.7.11.7
