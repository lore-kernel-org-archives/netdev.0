From: David Majnemer <majnemer@google.com>
Subject: Re: [PATCH] net: Update RPS target at poll for inet
Date: Wed, 29 May 2013 15:23:05 -0700 (PDT)
Message-ID: <20130529222305.7D96681853@donbot.mtv.corp.google.com>
References: <1369789677.3301.589.camel@edumazet-glaptop>
Cc: davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:60658 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935270Ab3E2WXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 18:23:07 -0400
Received: by mail-qa0-f74.google.com with SMTP id bs12so485553qab.5
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 15:23:06 -0700 (PDT)
In-Reply-To: <1369789677.3301.589.camel@edumazet-glaptop>
Cc: netdev@vger.kernel.org
Cc: pjt@google.com
Cc: maze@google.com
Cc: therbert@google.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That's a good point Eric, I've updated this patch to address your comment.

Thanks,
David

-----------------------------8<---------------------------

When poll(2) gets called with an ip socket, update the flow target to be the
poller. The data will be on the appropriate CPU when the poller later calls
recvmsg(2).

Signed-off-by: David Majnemer <majnemer@google.com>
---
 net/ipv4/tcp.c | 2 ++
 net/ipv4/udp.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ba4186e..6aa930a 100644
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
-- 
1.8.2.1
