From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] Export accept queue len of a TCP listening socket via
	rx_queue
Date: Thu, 22 Jun 2006 10:38:17 -0700
Message-ID: <1150997897.8365.11.camel@w-sridhar2.beaverton.ibm.com>
References: <E1FtDPD-0005mc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:46023 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751495AbWFVRjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 13:39:13 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5MHdBdT001061
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 13:39:12 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5MHd9Tr283400
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 13:39:09 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5MHd8GV014526
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 13:39:09 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FtDPD-0005mc-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 10:50 +1000, Herbert Xu wrote:
> Sridhar Samudrala <sri@us.ibm.com> wrote:
> >> 
> >> What about using the same fields (rqueue/wqueue) as you did for /proc?
> > 
> > I meant extending tcp_info structure to add new fields. I think the user
> > space also uses this structure.
> 
> What about putting it into inet_idiag_msg.idiag_[rw]queue instead?

OK. I was under the mistaken assumption that [rw]queue fields are exported
via tcp_info. This makes it pretty simple to support netlink users also. 
Here is the updated patch.

Thanks
Sridhar

While debugging a TCP server hang issue, we noticed that currently there is 
no way for a user to get the acceptq backlog value for a TCP listen socket.

All the standard networking utilities that display socket info like netstat,
ss and /proc/net/tcp have 2 fields called rx_queue and tx_queue. These
fields do not mean much for listening sockets. This patch uses one of these
unused fields(rx_queue) to export the accept queue len for listening sockets.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index c148c10..b56399c 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -26,7 +26,10 @@ static void tcp_diag_get_info(struct soc
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_info *info = _info;
 
-	r->idiag_rqueue = tp->rcv_nxt - tp->copied_seq;
+	if (sk->sk_state == TCP_LISTEN)
+		r->idiag_rqueue = sk->sk_ack_backlog;
+	else
+		r->idiag_rqueue = tp->rcv_nxt - tp->copied_seq;
 	r->idiag_wqueue = tp->write_seq - tp->snd_una;
 	if (info != NULL)
 		tcp_get_info(sk, info);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 25ecc6e..4c6ef47 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1726,7 +1726,8 @@ static void get_tcp4_sock(struct sock *s
 	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
 			"%08X %5d %8d %lu %d %p %u %u %u %u %d",
 		i, src, srcp, dest, destp, sp->sk_state,
-		tp->write_seq - tp->snd_una, tp->rcv_nxt - tp->copied_seq,
+		tp->write_seq - tp->snd_una,
+		(sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
 		timer_active,
 		jiffies_to_clock_t(timer_expires - jiffies),
 		icsk->icsk_retransmits,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a50eb30..b36d5b2 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1469,7 +1469,8 @@ static void get_tcp6_sock(struct seq_fil
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
 		   sp->sk_state, 
-		   tp->write_seq-tp->snd_una, tp->rcv_nxt-tp->copied_seq,
+		   tp->write_seq-tp->snd_una,
+		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
 		   timer_active,
 		   jiffies_to_clock_t(timer_expires - jiffies),
 		   icsk->icsk_retransmits,

