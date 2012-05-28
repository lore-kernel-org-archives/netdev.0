From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling to
	mitigate SYN floods
Date: Mon, 28 May 2012 13:52:26 +0200
Message-ID: <20120528115226.12068.31850.stgit@localhost.localdomain>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 0304ds2-fs.1.fullrate.dk ([89.150.128.48]:14371 "EHLO
	firesoul.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753125Ab2E1L7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 07:59:12 -0400
In-Reply-To: <20120528115102.12068.79994.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP SYN handling is on the slow path via tcp_v4_rcv(), and is
performed while holding spinlock bh_lock_sock().

Real-life and testlab experiments show, that the kernel choks
when reaching 130Kpps SYN floods (powerful Nehalem 16 cores).
Measuring with perf reveals, that its caused by
bh_lock_sock_nested() call in tcp_v4_rcv().

With this patch, the machine can handle 750Kpps (max of the SYN
flood generator) with cycles to spare, CPU load on the big machine
dropped to 1%, from 100%.

Notice we only handle syn cookie early on, normal SYN packets
are still processed under the bh_lock_sock().

Signed-off-by: Martin Topholm <mph@hoth.dk>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/tcp_ipv4.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 15958b2..7480fc2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1386,8 +1386,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	/* SYN cookie handling */
-	if (tcp_v4_syn_conn_limit(sk, skb))
-		goto drop;
+//	if (tcp_v4_syn_conn_limit(sk, skb))
+//		goto drop;
 
 	req = inet_reqsk_alloc(&tcp_request_sock_ops);
 	if (!req)
@@ -1795,6 +1795,12 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	/* Early and parallel SYN limit check, that sends syncookies */
+	if (sk->sk_state == TCP_LISTEN && th->syn && !th->ack && !th->fin) {
+		if (tcp_v4_syn_conn_limit(sk, skb))
+			goto discard_and_relse;
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
