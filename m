From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods
Date: Thu, 24 May 2012 15:01:07 +0200
Message-ID: <1337864467.13491.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin Topholm <mph@hoth.dk>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597Ab2EXNBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 09:01:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I have been doing some TCP performance measurements with SYN flooding,
and have found that, we don't handle this case well.

I have made a patch for fast/early SYN handling in tcp_v4_rcv() in
net/ipv4/tcp_ipv4.c.  This increases SYN performance from 130 kpps to
750 kpps (max of the generator), with idle CPU cycles.

Current locking:
 During a SYN flood (against a single port) all CPUs are spinning on
the same spinlock, namely bh_lock_sock_nested(sk), in tcp_ipv4.c.  The
lock dates back to a commit by DaveM in May 1999, see historic
commit[1].  It seem that TCP runs fully locked, per sock.

I need some help with locking, as the patch seems to work fine, with
NO-PREEMPT, but with PREEMPT enabled I start to see warnings (in
reqsk_queue_destroy) and oopses (in inet_csk_reqsk_queue_prune).

What am I missing?

[1] Historic commit: http://git.kernel.org/?p=linux/kernel/git/davem/netdev-vger-cvs.git;a=commitdiff;h=5744fad55cefbd6f079410500a507443d92d63ff

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


[RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods

TCP SYN handling is on the slow path via tcp_v4_rcv(), and is
performed while holding spinlock bh_lock_sock().

Real-life and testlab experiments show, that the kernel choks
when reaching 130Kpps SYN floods (powerful Nehalem 16 cores).
Measuring with perf reveals, that its caused by
bh_lock_sock_nested() call in tcp_v4_rcv().

With this patch, the machine can handle 750Kpps (max of the SYN
flood generator) with cycles to spare.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/tcp_ipv4.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2e76ffb..7d7e8e0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1718,6 +1718,22 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	/* Fast/early SYN handling, to mitigate SYN attacks */
+	if (sk->sk_state == TCP_LISTEN && th->syn && !th->ack && !th->fin) {
+		//bh_lock_sock_nested(sk); /* Don't think lock is needed */
+		/* Handles syn cookie, normally called from
+		 * tcp_rcv_state_process() */
+		tcp_v4_conn_request(sk, skb);
+		//bh_unlock_sock(sk);
+
+		/* Questions, do we (really) need to create a new sk,
+		 * as in tcp_v4_hnd_req() ?
+		 */
+		sock_put(sk);
+		kfree_skb(skb);
+		return 0;
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
