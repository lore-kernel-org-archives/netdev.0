From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] net: Update RFS target at poll for tcp/udp
Date: Fri, 31 May 2013 16:15:38 -0700
Message-ID: <1370042138.24311.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Majnemer <majnemer@google.com>,
	Paul Turner <pjt@google.com>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36988 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187Ab3EaXPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 19:15:39 -0400
Received: by mail-pd0-f171.google.com with SMTP id z11so2939867pdj.2
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 16:15:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Majnemer <majnemer@google.com>

The current state of affairs is that read()/write() will setup
RFS (Receive Flow Steering) for internet protocol sockets while
poll()/epoll() does not.

When poll() gets called with a TCP or UDP socket, we should update
the flow target.

This permits to RFS (if enabled) to select the appropriate CPU for
following incoming packets.

Note: Only connected UDP sockets can benefit from RFS.

Signed-off-by: David Majnemer <majnemer@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Paul Turner <pjt@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/ipv4/tcp.c |    2 ++
 net/ipv4/udp.c |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1f58594..b5d4ad9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -436,6 +436,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	struct sock *sk = sock->sk;
 	const struct tcp_sock *tp = tcp_sk(sk);
 
+	sock_rps_record_flow(sk);
+
 	sock_poll_wait(file, sk_sleep(sk), wait);
 	if (sk->sk_state == TCP_LISTEN)
 		return inet_csk_listen_poll(sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index aa5eff4..c7338ec 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1967,6 +1967,8 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	unsigned int mask = datagram_poll(file, sock, wait);
 	struct sock *sk = sock->sk;
 
+	sock_rps_record_flow(sk);
+
 	/* Check for false positives due to checksum errors */
 	if ((mask & POLLRDNORM) && !(file->f_flags & O_NONBLOCK) &&
 	    !(sk->sk_shutdown & RCV_SHUTDOWN) && !first_packet_length(sk))
