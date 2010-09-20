From: Tom Marshall <tdm.code@gmail.com>
Subject: [PATCH] Fix race in tcp_poll
Date: Mon, 20 Sep 2010 12:18:52 -0700
Message-ID: <20100920185719.GA13355@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:65267 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754896Ab0ITTSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 15:18:55 -0400
Received: by iwn5 with SMTP id 5so4433866iwn.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 12:18:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a RST comes in immediately after checking sk->sk_err, tcp_poll will
return POLLIN but not POLLOUT.  Fix this by checking sk->sk_err at the end
of tcp_poll.  Additionally, ensure the correct order of operations on SMP
machines with memory barriers.

Signed-off-by: Tom Marshall <tdm.code@gmail.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3fb1428..95d75d4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -386,8 +386,6 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	 */
 
 	mask = 0;
-	if (sk->sk_err)
-		mask = POLLERR;
 
 	/*
 	 * POLLHUP is certainly not done right. But poll() doesn't
@@ -457,6 +455,11 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 		if (tp->urg_data & TCP_URG_VALID)
 			mask |= POLLPRI;
 	}
+	/* This barrier is coupled with smp_wmb() in tcp_reset() */
+	smp_rmb();
+	if (sk->sk_err)
+		mask |= POLLERR;
+
 	return mask;
 }
 EXPORT_SYMBOL(tcp_poll);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e663b78..149e79a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4048,6 +4048,8 @@ static void tcp_reset(struct sock *sk)
 	default:
 		sk->sk_err = ECONNRESET;
 	}
+	/* This barrier is coupled with smp_rmb() in tcp_poll() */
+	smp_wmb();
 
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_error_report(sk);

