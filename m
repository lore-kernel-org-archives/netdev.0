From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Wed, 11 Jun 2008 16:58:40 +0400
Message-ID: <200806111658.41182.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Patrick McManus <mcmanus@ducksong.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:12516 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725AbYFKMze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 08:55:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

While testing network namespace with 2.6.26 OpenVZ kernel port I found
some problem with the patch commit ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 
("[TCP]: TCP_DEFER_ACCEPT updates - process as established")


>--- a/net/ipv4/tcp_timer.c
>+++ b/net/ipv4/tcp_timer.c
>@@ -481,6 +481,11 @@ static void tcp_keepalive_timer (unsigned long data)
> 		goto death;
> 	}
> 
>+	if (tp->defer_tcp_accept.request && sk->sk_state == TCP_ESTABLISHED) {
>+		tcp_send_active_reset(sk, GFP_ATOMIC);
>+		goto death;

Here socket sk is not attached to listening socket's request queue. tcp_done() 
will not call inet_csk_destroy_sock() (and tcp_v4_destroy_sock() which should 
release this sk) as socket is not DEAD. Therefore socket sk will be lost for 
freeing.

>+	}
>+
> 	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state == TCP_CLOSE)
> 		goto out;
>
>diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>index 0ba6e91..167a0f5 100644
>--- a/net/ipv4/tcp_ipv4.c
>+++ b/net/ipv4/tcp_ipv4.c
>@@ -1920,6 +1920,14 @@ int tcp_v4_destroy_sock(struct sock *sk)
> 		sk->sk_sndmsg_page = NULL;
> 	}
> 
>+	if (tp->defer_tcp_accept.request) {
>+		reqsk_free(tp->defer_tcp_accept.request);
>+		sock_put(tp->defer_tcp_accept.listen_sk);
>+		sock_put(sk);
>+		tp->defer_tcp_accept.listen_sk = NULL;
>+		tp->defer_tcp_accept.request = NULL;
>+	}
>+
> 	atomic_dec(&tcp_sockets_allocated);
> 
> 	return 0;

I asked Alexey Kuznetsov about this problem and he answered he didn't know 
what to do yet.

-- 
Thank,
Vitaliy Gusev
