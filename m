From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Subject: [PATCH] tcp: possible race between tcp_done() and tcp_poll()
Date: Wed, 29 Mar 2017 14:22:34 +0900
Message-ID: <34d952a3-77cd-ea53-c3e3-ccde91d5cf63@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:23026 "EHLO
        mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752582AbdC2FgK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 01:36:10 -0400
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
        by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 2B19DAC0125
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:24:45 +0900 (JST)
Received: from G01JPEXCHKW15.g01.fujitsu.local (G01JPEXCHKW15.g01.fujitsu.local [10.0.194.54])
        by g01jpfmpwkw03.exch.g01.fujitsu.local (Postfix) with ESMTP id 6CC2EBD6542
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:22:34 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit a4d258036ed9b2a1811.

Between receiving a packet and tcp_poll(), sk->sk_err is protected by memory barriers but
sk->sk_shutdown and sk->sk_state are not. So possibly, POLLIN|POLLRDNORM|POLLRDHUP might
not be set even when receiving a RST packet.

Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>

 net/ipv4/tcp.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cf45555..c8bc86e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -456,6 +456,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 
+	/* This barrier is coupled with smp_wmb() in tcp_reset() */
+	smp_rmb();
 	state = sk_state_load(sk);
 	if (state == TCP_LISTEN)
 		return inet_csk_listen_poll(sk);
@@ -540,8 +542,6 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 		 */
 		mask |= POLLOUT | POLLWRNORM;
 	}
-	/* This barrier is coupled with smp_wmb() in tcp_reset() */
-	smp_rmb();
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR;
 
@@ -3291,6 +3291,9 @@ void tcp_done(struct sock *sk)
 
 	sk->sk_shutdown = SHUTDOWN_MASK;
 
+	/* This barrier is coupled with smp_rmb() in tcp_poll() */
+	smp_wmb();
+
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_state_change(sk);
 	else
